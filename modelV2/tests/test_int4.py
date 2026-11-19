"""INT4 for Tiny-TPU Version 1 (int4.py): the trained network, the integer host flow and the PE agree."""
import numpy as np
import pytest
import torch

import config as c
import int4 as I
import net as N


def rows(n=500, seed=0):
    """Inputs shaped like network_inputs(): slog values, mostly small and positive, some large (damage)."""
    r = np.random.default_rng(seed)
    x = r.normal(0.5, 1.0, (n, len(c.INPUTS)))
    x[r.random(n) < 0.1] *= 4
    return x.astype(np.float32)


def qnet(seed=0):
    X = rows()
    q = I.QMLP([len(c.INPUTS), *c.HIDDEN, 4], seed=seed)
    q.standardize(X)
    q.calibrate(X)
    q.quant.fill_(1)
    return q.eval(), X


def test_fake_quantization_is_the_integer_flow():
    """Training sees what the host + PE compute: same INT4 decisions, outputs equal to float32 rounding."""
    q, X = qnet()
    with torch.no_grad():
        fq = q(torch.tensor(X)).double().numpy()
    a0, sums, out = I.forward_int(X, I.integer_model(q))
    assert np.abs(fq - out).max() < 1e-4 * max(1.0, np.abs(out).max())
    assert (fq[:, :3].argmax(1) == out[:, :3].argmax(1)).mean() > 0.99
    assert a0.min() >= -7 and a0.max() <= 7
    assert [s.shape[1] for s in sums] == [*c.HIDDEN, 4]


def test_pe_model_matches_the_dot_products_and_the_rtl_overflow_rule():
    q, X = qnet(1)
    m = I.integer_model(q)
    a0, sums, _ = I.forward_int(X[:20], m)
    for r in range(20):
        for j in range(c.HIDDEN[0]):
            assert I.pe_neuron(a0[r], m["layers"][0]["W"][j]) == (sums[0][r, j], 0)
    assert I.pe_neuron([7] * 668, [7] * 668) == (32732, 0)            # the RTL test's numbers
    assert I.pe_neuron([7] * 669, [7] * 669)[1] == 1
    assert all(np.abs(L["W"]).max() <= 7 for L in m["layers"])


def test_post_training_int4_keeps_the_fp32_network():
    """from_fp32 folds the input standardization into layer 0: with quantization off it is the FP32 net."""
    fp = N.mlp(seed=3)
    X = torch.tensor(rows(300, 3))
    q = I.QMLP.from_fp32(fp, X)
    q.quant.fill_(0)
    with torch.no_grad():
        assert (q(X) - fp(X)).abs().max() < 1e-4


def test_quantization_aware_training_learns_and_moves_the_scales():
    q, X = qnet(2)
    q.train()
    X = torch.tensor(X)
    y = (X[:, 0] > 0.5).long()
    opt = torch.optim.Adam(q.parameters(), lr=3e-3)
    before = q.log_sa.detach().clone()
    loss0 = None
    for _ in range(200):
        loss = torch.nn.functional.cross_entropy(q(X)[:, :3], y)
        loss0 = loss0 or loss.item()
        opt.zero_grad()
        loss.backward()
        opt.step()
    assert loss.item() < 0.5 * loss0
    assert not torch.equal(before, q.log_sa.detach())
    q.eval()
    with torch.no_grad():
        fq = q(X).numpy()
    out = I.forward_int(X.numpy(), I.integer_model(q))[2]
    assert (fq[:, :3].argmax(1) == out[:, :3].argmax(1)).mean() > 0.99


def test_build_and_load_both_kinds(tmp_path):
    q, _ = qnet()
    torch.save(q.state_dict(), tmp_path / "q.pt")
    cfg = {"int4": True, "sizes": [len(c.INPUTS), *c.HIDDEN, 4]}
    r = N.load(tmp_path / "q.pt", cfg)
    assert int(r.quant) == 1 and torch.equal(r.log_sa, q.log_sa)
    assert N.hidden(r, torch.zeros(2, len(c.INPUTS))).shape == (2, c.HIDDEN[-1])
    fp = N.build({"sizes": [len(c.INPUTS), 48, 24, 4]})
    assert N.hidden(fp, torch.zeros(2, len(c.INPUTS))).shape == (2, 24)


def test_too_wide_a_layer_is_refused():
    q = I.QMLP([700, 4])
    q.quant.fill_(1)
    with pytest.raises(AssertionError):
        I.integer_model(q)


def test_sixteen_hidden_levels_use_the_full_pe_range_exactly():
    """--hidden-levels 16: hidden values 0..15 go to the PE as -8..7, the host adds 8 * sum(w) back: the same outputs
    as the fake quantization, and the PE model gives the same sums for those operands."""
    X = rows()
    q = I.QMLP([len(c.INPUTS), *c.HIDDEN, 4], seed=4, hidden_levels=16)
    q.standardize(X)
    q.calibrate(X)
    q.quant.fill_(1)
    q.eval()
    with torch.no_grad():
        fq = q(torch.tensor(X)).double().numpy()
    m = I.integer_model(q)
    ins = []
    a0, sums, out = I.forward_int(X, m)
    I.forward_from_a0(a0, m, ins)
    assert np.abs(fq - out).max() < 1e-4 * max(1.0, np.abs(out).max())
    assert ins[1].min() >= -8 and ins[1].max() <= 7 and ins[1].min() < 0       # the negative half is really used
    assert (m["layers"][0]["corr"] == 0).all() and (m["layers"][1]["corr"] == 8 * m["layers"][1]["W"].sum(1)).all()
    for r in range(10):
        assert I.pe_neuron(ins[1][r], m["layers"][1]["W"][0]) == (sums[1][r, 0], 0)
