"""Checks of the single-accelerometer models (and that E3 is untouched). Run inside model/:

  python -m pytest test_single_accel.py -q

Needs the trained files (python single_accel.py, health.py --accels <k> --name H1_single_accel_a<k>, export.py ...).
The RTL is checked by rtl_check.py, not here.
"""
import csv, json, subprocess, sys

import numpy as np
import pytest
import torch

import features as ft
import health as hl
from dataset import HERE, MAC_DIR
from export import quantize_inputs
from single_accel import ACCELS, EXP, NAME
from train import EXPERIMENTS, SEEDS, SPLITS, load, log_inputs, mlp, recording_scores, run

sys.path.insert(0, str(MAC_DIR))
from mac import golden_mlp, read_hex   # noqa: E402

ROWS = load("windows")
SEL = json.loads((HERE / "weights" / NAME / "selected.json").read_text())


def info(name):
    return json.loads((HERE / "weights" / name / "model.json").read_text())


@pytest.mark.parametrize("k", ACCELS)
def test_one_accelerometer_eight_inputs_in_order(k):
    i = info(EXP[k])
    want = [f"a{k}_log_std", f"a{k}_log_rms", f"a{k}_log_absmax", f"a{k}_log_p2p", f"a{k}_crest", f"a{k}_skew",
            f"a{k}_kurt", "log_f"]
    assert i["inputs"] == want
    assert {n.split("_")[0] for n in i["inputs"][:-1]} == {f"a{k}"}
    assert i["sizes"] == [8, 32, 16, 1] and i["relu"] == [1, 1, 0]
    X, names = EXPERIMENTS[EXP[k]]["inputs"](ROWS)
    assert names == want and X.shape == (len(ROWS), 8)
    # the same columns as E3's (one accelerometer's block of E3's 22 inputs, then ln f)
    X3, n3 = EXPERIMENTS["E3"]["inputs"](ROWS)
    assert np.array_equal(X, X3[:, [n3.index(n) for n in names]])


@pytest.mark.parametrize("k", ACCELS)
def test_standardizer_from_train_only(k):
    i = info(EXP[k])
    X, _ = EXPERIMENTS[EXP[k]]["inputs"](ROWS)
    tr = np.array([r["split"] == "train" for r in ROWS])
    assert np.allclose(i["scaler"]["mean"], X[tr].mean(axis=0), rtol=0, atol=1e-12)
    assert np.allclose(i["scaler"]["std"], X[tr].std(axis=0), rtol=0, atol=1e-12)
    assert not np.allclose(i["scaler"]["mean"], X.mean(axis=0))      # would hold if val/test leaked in
    assert i["n"] == {"train": 640, "val": 320, "test": 320}


def test_split_has_no_leakage():
    split = {}
    for r in ROWS:
        assert split.setdefault(r["file"], r["split"]) == r["split"]   # every window of a recording in one split
    files = {sp: {f for f, s in split.items() if s == sp} for sp in SPLITS}
    assert not (files["train"] & files["val"] or files["train"] & files["test"] or files["val"] & files["test"])
    assert all(sum(1 for r in ROWS if r["file"] == f) == 10 for f in split)


@pytest.mark.parametrize("k", ACCELS)
@pytest.mark.parametrize("seed", SEEDS)
def test_saved_model_loads_and_infers(k, seed):
    net = mlp(8)
    net.load_state_dict(torch.load(HERE / "weights" / EXP[k] / f"seed{seed}.pt", weights_only=True))
    shapes = [tuple(p.shape) for p in net.parameters()]
    assert shapes == [(32, 8), (32,), (16, 32), (16,), (1, 16), (1,)]
    i = info(EXP[k])
    X, _ = EXPERIMENTS[EXP[k]]["inputs"](ROWS)
    with torch.no_grad():
        z = net(torch.tensor((X - i["scaler"]["mean"]) / np.array(i["scaler"]["std"]), dtype=torch.float32))
    z = z[:, 0].double().numpy()
    assert np.isfinite(z).all()
    recs, score = recording_scores(ROWS, z)
    with open(HERE / "results" / EXP[k] / "scores.csv", newline="") as f:
        saved = {r["file"]: (float(r[f"score_s{seed}"]), int(r[f"faulty_s{seed}"])) for r in csv.DictReader(f)}
    cut = i["seeds"][str(seed)]["cut"]
    for r, s in zip(recs, score):
        assert abs(saved[r["file"]][0] - s) <= 1e-5 and int(s >= cut) == saved[r["file"]][1]


def test_runtime_features_match_the_tables():
    """features.window_inputs (board side, raw samples) = the table path (stats -> log_inputs)."""
    rng = np.random.default_rng(0)
    x = 5.0 + 0.3 * rng.standard_normal(ft.FS) + 0.2 * np.sin(np.arange(ft.FS) * 2 * np.pi * 30 / ft.FS)
    st = ft.stats(x.reshape(-1, 1))[0]
    row = {f"a2_{s}": float(v) for s, v in zip(ft.STATS, st)} | {"f_hz": 30.0}
    X, names = log_inputs([row], np.array([30.0]), accels=(2,))
    assert np.allclose(ft.window_inputs(x, 30.0), X[0], rtol=1e-12, atol=1e-12)
    assert len(ft.window_inputs(x, 30.0, extra=(np.array([40.0]),))) == 9          # a later sensor group appends


def test_selection_used_validation_only():
    a = json.loads((HERE / "results" / NAME / "analysis.json").read_text())
    keys = {k: tuple(round(x, 9) for x in [*(a["variants"][str(k)]["mean"]["val"][m] for m in
                                              ("recall", "balanced_accuracy", "f1", "precision", "specificity",
                                               "roc_auc")),
                                            a["variants"][str(k)]["worst_val_recall"],
                                            a["variants"][str(k)]["mean"]["val"]["window_roc_auc"],
                                            -a["variants"][str(k)]["mean"]["best_val_loss"]]) for k in ACCELS}
    assert max(ACCELS, key=lambda k: keys[k]) == SEL["accel"]
    assert SEL["experiment"] == EXP[SEL["accel"]] and SEL["seed"] == 42
    assert {k: tuple(v) for k, v in SEL["keys"].items()} == {str(k): keys[k] for k in ACCELS}


def test_health_index_uses_the_selected_accelerometer():
    k = SEL["accel"]
    h = json.loads((HERE / "weights" / SEL["health"] / "health.json").read_text())
    assert h["statistics"] == info(EXP[k])["inputs"][:-1]
    assert len(h["alpha"]) == len(h["beta"]) == len(h["sigma"]) == 7
    X, lf, names = hl.statistics(ROWS, (k,))
    ref, D, loso, d100, d0 = hl.anchors(ROWS, X, lf)                 # fitted on train only
    assert np.allclose(h["alpha"], ref["alpha"]) and np.allclose(h["sigma"], ref["sigma"])
    assert np.isclose(h["d_100"], d100) and np.isclose(h["d_0"], d0) and d0 > d100
    with open(HERE / "results" / SEL["health"] / "health.csv", newline="") as f:
        hi = [float(r["HI"]) for r in csv.DictReader(f)]
    assert all(0.0 <= v <= 100.0 for v in hi) and len(hi) == 128


DEPLOYED = json.loads((HERE / "weights" / NAME / "deployed.json").read_text())
CHANGED = {"E3_single_accel_a2": ["R_M_1_0.csv"], "E3_single_accel_a1": []}   # docs/Model/supporting_single_accel/02c_Single_accel_hardware_report.md


def test_deployed_model_is_recorded_as_post_test():
    assert DEPLOYED["experiment"] == EXP[DEPLOYED["accel"]] and DEPLOYED["post_test_decision"] is True
    h = json.loads((HERE / "weights" / DEPLOYED["health"] / "health.json").read_text())
    assert h["statistics"] == info(DEPLOYED["experiment"])["inputs"][:-1]
    assert json.loads((HERE / DEPLOYED["export"] / "quant.json").read_text())["experiment"] == DEPLOYED["experiment"]


@pytest.mark.parametrize("name", sorted(CHANGED))
def test_int8_export_matches_golden_and_fp32(name):
    out = HERE / "export" / name
    q = json.loads((out / "quant.json").read_text())
    assert q["sizes"] == [8, 32, 16, 1] and q["inputs"] == info(name)["inputs"]
    layers = []
    for l in range(3):
        W = read_hex(out / f"W{l}.hex", 8).reshape(q["sizes"][l], q["sizes"][l + 1])
        assert np.abs(W).max() <= 127
        scl = read_hex(out / f"Scl{l}.hex", 24) & 0xFFFFFF
        layers.append({"W": W, "bias": read_hex(out / f"Bias{l}.hex", 32), "m0": scl & 0xFFFF, "shift": scl >> 16,
                       "relu": q["layers"][l]["relu"]})
    i = info(name)
    X, _ = EXPERIMENTS[name]["inputs"](ROWS)
    Xq = quantize_inputs((X - i["scaler"]["mean"]) / np.array(i["scaler"]["std"]), q["s_x"])
    assert Xq.min() >= -127 and Xq.max() <= 127
    C, _ = golden_mlp(Xq, layers)
    with open(out / "vectors" / "test_windows.csv", newline="") as f:
        vec = list(csv.DictReader(f))
    test = [j for j, r in enumerate(ROWS) if r["split"] == "test"]
    assert [int(v["C"]) for v in vec] == [int(C[j, 0]) for j in test]
    assert [[int(v[f"q{c}"]) for c in range(8)] for v in vec] == Xq[test].tolist()
    err = np.abs((C[test, 0] + q["bias_last"]) * q["logit_scale"] - np.array([float(v["logit_fp32"]) for v in vec]))
    assert err.mean() < 0.5                                          # quantization error, real logit units
    with open(out / "vectors" / "test_recordings.csv", newline="") as f:
        recs = list(csv.DictReader(f))
    changed = [r["file"] for r in recs if r["faulty_int8"] != r["faulty_fp32"]]
    assert changed == CHANGED[name]


def test_e3_files_unchanged_in_git():
    paths = ["weights/E3", "results/E3", "export/E3", "weights/H1", "results/H1"]
    r = subprocess.run(["git", "status", "--porcelain", "--", *paths], cwd=HERE, capture_output=True, text=True)
    assert r.returncode == 0 and r.stdout == ""


def test_e3_retrains_to_the_same_decisions(tmp_path):
    run("E3", tmp_path)
    for f in ("scores.csv",):
        with open(HERE / "results" / "E3" / f, newline="") as a, open(tmp_path / "results" / "E3" / f, newline="") as b:
            for x, y in zip(csv.DictReader(a), csv.DictReader(b)):
                for s in SEEDS:
                    assert x[f"faulty_s{s}"] == y[f"faulty_s{s}"]
                    assert abs(float(x[f"score_s{s}"]) - float(y[f"score_s{s}"])) <= 1e-4
