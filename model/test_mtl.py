"""Checks of the multi-task architecture, its input pipeline and the prototype. Run inside model/:

  python -m pytest test_mtl.py -q

Needs results/paderborn/<EXP>/ (paderborn.py) and results/paderborn/anomaly/ (anomaly_baseline.py). Dummy inputs are
random numbers used only to check shapes and arithmetic; no head is trained and no label is made up.
"""
import json, subprocess

import numpy as np
import pandas as pd
import pytest
import torch

import anomaly_baseline as ab
import mtl_inputs as mi
import mtl_model as mm
from paderborn import HERE, load

EXPS = ("B01", "B03")
DATA = {e: load(e) for e in EXPS}
CAL = {e: mi.calibrate(DATA[e]) for e in EXPS}
OUTS = {e: mi.inputs(DATA[e], CAL[e]) for e in EXPS}
BASE = json.loads((HERE / "results" / "paderborn" / "anomaly" / "baseline.json").read_text())


# ---------- architecture: shapes and numbers ----------

def test_layer_sizes_and_parameter_count():
    net = mm.MultiTaskMLP()
    lin = [m for m in net.modules() if isinstance(m, torch.nn.Linear)]
    assert [(m.in_features, m.out_features) for m in lin] == [(8, 32), (32, 16), (16, 1), (16, 1)]
    assert mm.n_params(net) == 8 * 32 + 32 + 32 * 16 + 16 + 2 * (16 + 1) == 850


@pytest.mark.parametrize("M", [1, 3, 64, 1000])
def test_shapes_on_dummy_inputs(M):
    net = mm.MultiTaskMLP().eval()
    d, h = net(torch.randn(M, 8))
    assert d.shape == (M,) and h.shape == (M,)
    o = mm.outputs(d, h)
    assert ((o["deterioration_probability"] > 0) & (o["deterioration_probability"] < 1)).all()
    assert ((o["health_index_pct"] >= 0) & (o["health_index_pct"] <= 100)).all()


def test_two_heads_equal_the_two_column_layer_the_chip_runs():
    net = mm.MultiTaskMLP(seed=3).eval()
    x = torch.randn(257, 8)
    with torch.no_grad():
        d, h = net(x)
        y = net.as_sequential()(x)
    assert torch.allclose(y[:, 0], d, atol=1e-6) and torch.allclose(y[:, 1], h, atol=1e-6)


def test_deterministic_initialization_and_batch_independence():
    a, b = mm.MultiTaskMLP(seed=7).eval(), mm.MultiTaskMLP(seed=7).eval()
    x = torch.randn(50, 8)
    with torch.no_grad():
        assert torch.equal(a(x)[0], b(x)[0])
        one = torch.stack([a(x[i:i + 1])[0][0] for i in range(50)])
        assert torch.allclose(one, a(x)[0], atol=1e-6)        # each measurement is scored on its own


def test_numerically_finite_at_the_input_limits():
    net = mm.MultiTaskMLP().eval()
    x = torch.tensor([[mi.Z_CLIP] * 8, [-mi.Z_CLIP] * 8, [0.0] * 8])
    with torch.no_grad():
        d, h = net(x)
    assert torch.isfinite(d).all() and torch.isfinite(h).all()


def test_gradients_of_the_masked_loss():
    """Finite-difference check of the loss on random tensors (a numerical test; no optimizer step, no training)."""
    torch.manual_seed(0)
    d, h = torch.randn(6, dtype=torch.float64, requires_grad=True), torch.randn(6, dtype=torch.float64, requires_grad=True)
    y_det = torch.tensor([0, 1, float("nan"), 1, float("nan"), 0], dtype=torch.float64)
    y_hi = torch.tensor([float("nan"), 50, 20, float("nan"), 90, 100], dtype=torch.float64)
    assert torch.autograd.gradcheck(lambda a, b: mm.multitask_loss(a, b, y_det, y_hi)[0], (d, h))
    total, parts = mm.multitask_loss(d, h, y_det, y_hi)
    assert parts["n_det"] == 4 and parts["n_hi"] == 4
    total.backward()
    assert d.grad[2] == 0 and d.grad[4] == 0 and h.grad[0] == 0 and h.grad[3] == 0    # unlabeled rows: no gradient


def test_loss_with_no_labels_is_zero_and_carries_no_gradient():
    net = mm.MultiTaskMLP()
    d, h = net(torch.randn(10, 8))
    nan = torch.full((10,), float("nan"))
    total, parts = mm.multitask_loss(d, h, nan, nan)
    total.backward()
    assert float(total.detach()) == 0.0 and parts["n_det"] == parts["n_hi"] == 0
    assert all(p.grad is None or torch.all(p.grad == 0) for p in net.parameters())


def test_untrained_network_refuses_to_predict():
    with pytest.raises(RuntimeError, match="untrained"):
        mm.predict(mm.MultiTaskMLP(), torch.zeros(1, 8))


# ---------- INT8 / accelerator ----------

def test_int8_inference_on_real_inputs():
    X = np.vstack([OUTS[e][mi.input_names()].to_numpy() for e in EXPS])
    net = mm.MultiTaskMLP(seed=0).eval()
    seq, layers, scales, s_x = mm.int8_model(net, X)
    assert [L["W"].shape for L in layers] == [(8, 32), (32, 16), (16, 2)]
    assert all(np.abs(L["W"]).max() <= 127 for L in layers)
    Xq, C, real = mm.int8_forward(X, layers, scales, s_x)     # asserts no accumulator overflow
    assert Xq.dtype == np.int64 and np.abs(Xq).max() <= 127 and C.shape == (len(X), 2)
    with torch.no_grad():
        fp = seq(torch.tensor(X, dtype=torch.float32)).double().numpy()
    span = fp.max(axis=0) - fp.min(axis=0)
    assert (np.abs(real - fp).max(axis=0) < 0.05 * span + 0.05).all()


def test_cycles_fit_the_array_as_e3_single_accel():
    assert mm.cycles(1)[3] == 382 and mm.cycles(10)[3] == 562     # docs/Model/supporting_single_accel/02c_Single_accel_hardware_report.md (xsim)


# ---------- input pipeline ----------

@pytest.mark.parametrize("e", EXPS)
def test_inputs_shape_order_and_range(e):
    o = OUTS[e]
    names = mi.input_names()
    assert names == ["z_ln_rms", "z_ln_peak", "z_kurt", "z_ln_band_1k_5k", "z_ln_band_5k_20k", "z_ln_band_20k_64k",
                     "rpm_z", "temp_resid_z"]
    X = o[names].to_numpy()
    assert X.shape == (int((~DATA[e].warmup).sum()), 8) and np.isfinite(X).all()
    assert np.abs(X).max() <= mi.Z_CLIP
    assert o.measurement_id.is_monotonic_increasing and o.timestamp.is_monotonic_increasing


@pytest.mark.parametrize("e", EXPS)
def test_only_the_three_sensors_and_one_accelerometer(e):
    used = {c for n, _ in mi.PROFILES[mi.PRIMARY_PROFILE] for c in [f"accA_{n}"]}
    assert all(c.startswith("accA_") for c in used)
    # changing the other accelerometer, the load or the other temperatures does not change the inputs
    d = DATA[e].copy()
    for c in [c for c in d if c.startswith("accC_")] + ["stat_N", "peakDyn_N", "setStat_N", "setDyn_N", "T2_C", "Troom_C"]:
        d[c] = d[c] * 1.37 + 1
    o = mi.inputs(d, mi.calibrate(d))
    assert np.allclose(o[mi.input_names()].to_numpy(), OUTS[e][mi.input_names()].to_numpy())


@pytest.mark.parametrize("e", EXPS)
def test_commissioning_reference_is_standardized(e):
    o = OUTS[e]
    Z = o.loc[o.reference, mi.input_names()[:6]].to_numpy()
    assert np.allclose(Z.mean(axis=0), 0, atol=1e-8) and np.allclose(Z.std(axis=0), 1, atol=1e-8)
    assert abs(o.rpm_z[o.reference].mean()) < 1e-8


@pytest.mark.parametrize("e", EXPS)
def test_rpm_correction_removes_the_speed_dependence_in_the_reference(e):
    o = OUTS[e]
    r = o[o.reference]
    for n in mi.input_names()[:6]:
        assert abs(np.corrcoef(r[n], np.log(r.speed_rpm))[0, 1]) < 1e-8


@pytest.mark.parametrize("e", EXPS)
def test_calibration_uses_only_the_motors_own_commissioning(e):
    """Changing anything after the reference changes no calibration value of the vibration or the anomaly baseline."""
    d = DATA[e].copy()
    op = np.flatnonzero(~d.warmup.to_numpy())
    later = op[mi.REF_N:]
    for c in [c for c in d if c.startswith("accA_")]:
        d.loc[later, c] = d.loc[later, c] * 3.0
    c2 = mi.calibrate(d)
    for k in ("vib_b0", "vib_b1_ln_rpm", "vib_sigma"):
        assert np.allclose(c2[k], CAL[e][k])
    assert c2["anomaly"]["tau"] == CAL[e]["anomaly"]["tau"]


def test_temperature_is_its_own_input_with_a_warm_up_state():
    for e in EXPS:
        o = OUTS[e]
        th = CAL[e]["thermal"]
        assert th["complete"]
        assert (o.temp_resid_z[~o.temp_valid] == 0).all()                 # no value before the thermal calibration
        assert set(o.temperature_state) <= {"warming", "calibrating", "normal", "above expected"}
        assert (o.temperature_state[~o.temp_valid] == "calibrating").all()
    # B03's warm-up curve: first-order model with a minutes-scale time constant, small residual on the plateau
    th = CAL["B03"]["thermal"]
    assert 5 < th["tau_min"] < 20 and th["sigma_T_degC"] <= 1.0


def test_lobo_folds_hold_out_whole_bearings():
    f = mi.lobo_folds(list(EXPS))
    assert f == [{"test": "B01", "train": ["B03"]}, {"test": "B03", "train": ["B01"]}]


# ---------- prototype = the anomaly baseline, unchanged ----------

@pytest.mark.parametrize("e", EXPS)
def test_prototype_reproduces_the_baseline(e):
    o = OUTS[e]
    s = pd.read_csv(HERE / "results" / "paderborn" / "anomaly" / f"scores_{e}.csv")
    assert np.allclose(o.anomaly_score, s.score, rtol=1e-5) and np.allclose(o.threshold, s.threshold, rtol=1e-5)
    fa = BASE["experiments"][e]["primary"]["first_alarm"]["measurement_id"]
    i0 = int(np.flatnonzero(o.measurement_id.to_numpy() == fa)[0])
    first = o[o.status == "abnormal"].index[0]
    assert first == i0 + mi.RUN - 1                                   # causal confirmation of the same alarm
    assert (o.status[o.reference] == "commissioning").all()
    assert np.allclose(o.severity, o.anomaly_score / o.threshold)


@pytest.mark.parametrize("e", EXPS)
def test_prototype_reports_no_health_percentage(e):
    cols = set(OUTS[e].columns)
    assert not {c for c in cols if "health" in c or "pct" in c or "%" in c}
    assert set(OUTS[e].status) == {"commissioning", "normal", "abnormal"}


# ---------- nothing existing changed ----------

def test_existing_models_and_results_untouched():
    r = subprocess.run(["git", "status", "--porcelain", "--", "weights", "export", "results", "train.py", "health.py",
                        "export.py", "features.py", "anomaly_baseline.py", "mtl_model.py", "b01_preprocess.py",
                        "b01_analysis.py"], cwd=HERE, capture_output=True, text=True, check=True)
    changed = [ln for ln in r.stdout.splitlines() if not ln.startswith("??")]
    assert changed == [], changed                    # tracked files: no modification
