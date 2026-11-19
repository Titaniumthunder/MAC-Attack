"""Only the tests that protect a rule: model/ unchanged, locked sets refused, causal inputs, chip fit."""
import subprocess

import numpy as np
import pandas as pd
import pytest
import torch

import config as c
import net as N
import pipeline as F
import prep
import anomaly_baseline as ab
import mtl_model as mm
from export import build


def test_model_folder_unchanged():
    """git sees no change or new file in model/ (tracked or untracked), and importing it left no __pycache__ there."""
    for args in (("status", "--porcelain"), ("diff", "HEAD")):
        r = subprocess.run(["git", *args, "--", "model"], cwd=c.REPO, capture_output=True, text=True)
        assert r.returncode == 0 and r.stdout == ""
    assert not list(c.MODEL.glob("__pycache__"))
    with pytest.raises(RuntimeError):
        c.writable(c.MODEL / "x.txt")


@pytest.mark.skipif(c.FROZEN.exists(), reason="a model is frozen: the locked sets are open")
def test_locked_bearings_refused():
    for b in c.PAD_LOCKED:
        with pytest.raises(RuntimeError):
            prep.paderborn_table(b)
    with pytest.raises(RuntimeError):
        prep.ottawa_table([c.OTT_LOCKED[0]])
    assert not set(c.PAD_LOCKED) & set(c.PAD_DEV) and not set(c.OTT_LOCKED) & set(c.OTT_DEV)


def inputs_of(d):
    m = F.baseline(d.iloc[:c.REF_N])
    s, Z = ab.score(d, m)
    return F.network_inputs(Z, s, np.exp(d.ln_speed), F.history(Z), np.full(len(d), c.HIST))


def test_inputs_are_causal():
    """Changing later rows changes neither the baseline nor any earlier row's inputs."""
    rng = np.random.default_rng(0)
    d = pd.DataFrame({f"accA_{n}": np.exp(rng.normal(size=300)) for n in F.NAMES})
    d["ln_speed"] = np.log(rng.uniform(1500, 3000, 300))
    e = d.copy()
    e.iloc[200:, :len(F.NAMES)] *= 7.0
    a, b = inputs_of(d), inputs_of(e)
    assert np.array_equal(a[:200], b[:200]) and not np.array_equal(a[200:], b[200:])
    assert a.shape[1] == len(c.INPUTS)


def test_network_fits_the_chip():
    net = N.mlp()
    lin = [m for m in net if isinstance(m, torch.nn.Linear)]
    assert len(lin) <= 4 and all(m.in_features <= 64 and m.out_features <= 64 for m in lin)
    assert all(isinstance(m, (torch.nn.Linear, torch.nn.ReLU)) for m in net) and lin[-1].out_features == 4
    X = np.random.default_rng(0).uniform(-9.2, 9.2, (256, len(c.INPUTS))).astype(np.float32)
    layers, scales = build(net, X, c.S_X)
    for L in layers:
        assert np.abs(L["W"]).max() <= 127 and np.abs(L["bias"]).max() < 2 ** 31
        assert L["shift"].min() >= 1 and L["shift"].max() <= 48
    Xq, C, real = mm.int8_forward(X, layers, scales, c.S_X)       # asserts the 22-bit accumulator never overflows
    assert np.abs(Xq).max() <= 127 and real.shape == (256, 4)
    with torch.no_grad():
        assert np.abs(real - net(torch.tensor(X)).numpy()).max() < 0.5
