"""Checks of the supervised-training preparation (labels.py, supervised_prep.py). Run inside model/:

  python -m pytest test_supervised.py -q
"""
import json

import numpy as np
import pandas as pd
import pytest

import anomaly_baseline as ab
import labels as lb
import mtl_inputs as mi
import supervised_prep as sp
from paderborn import HERE, load

BASE = json.loads((HERE / "results" / "paderborn" / "anomaly" / "baseline.json").read_text())


# ---------- labels ----------

def test_b03_labels_are_start_end_and_masked_middle():
    y, info = lb.label("B03")
    assert (y.y_det[:lb.START_N] == 0).all() and (y.y_det[-lb.END_N:] == 1).all()
    assert y.y_det[lb.START_N:-lb.END_N].isna().all() and y.y_hi.isna().all()
    assert info["end"]["measurement_ids"] == [610, 614] and info["health_index_labels"] == 0


def test_b01_end_label_is_withheld():
    y, info = lb.label("B01")
    assert info["end"]["label"] is None and not (y.y_det == 1).any()
    assert any("no stop criterion" in w for w in info["end"]["withheld_because"])


def test_b01_has_no_label_at_all_and_is_left_out_of_the_folds():
    y, info = lb.label("B01")
    assert info["start"]["label"] is None and info["end"]["label"] is None and y.y_det.isna().all()
    for e in ("B02", "B03", "B04"):                                 # the withholding applies to B01 only
        if (HERE / "results" / "paderborn" / e / f"{e}_processed.csv").exists():
            assert lb.label(e)[1]["start"]["n"] == lb.START_N
    folds = json.loads((lb.OUT / "folds.json").read_text(encoding="utf-8"))
    assert "B01" in folds["without_labels"]
    assert all(f["held_out"] != "B01" and "B01" not in f["train"] for f in folds["folds"])


def test_labels_never_read_a_measurement_value():
    """Scrambling every vibration, temperature, speed and load column leaves the labels unchanged."""
    full = load("B03")
    rng = np.random.default_rng(0)
    scr = full.copy()
    for c in full.columns:
        if c.startswith("acc") or c in ("T1_C", "T2_C", "Troom_C", "speed_rpm", "stat_N", "peakDyn_N"):
            scr[c] = rng.permutation(full[c].to_numpy())
    a, _ = lb.label("B03", full)
    b, _ = lb.label("B03", scr)
    pd.testing.assert_frame_equal(a, b)


def test_end_rule_needs_a_documented_stop():
    ok, _ = lb.end_rule("B03", {"records_after_log_end": 0, "last_record_vs_log_end_s": 40.0})
    assert ok
    assert not lb.end_rule("B03", {"records_after_log_end": 3, "last_record_vs_log_end_s": 40.0})[0]
    assert not lb.end_rule("B02", {})[0]                          # log not transcribed yet
    assert not lb.end_rule("B05", {})[0]                          # interrupted


def test_test_bearings_are_refused():
    for e in ("B06", "B07", "B13", "B17"):
        with pytest.raises(RuntimeError):
            lb.label(e)
        with pytest.raises(RuntimeError):
            sp.dataset(e)
    assert not {"B06", "B07", "B13", "B17"} & set(lb.available())


# ---------- inputs, folds, baseline ----------

def test_dataset_uses_a42_and_masks_an_invalid_thermal_input():
    ds3, cal3, v3, _ = sp.dataset("B03")
    x = mi.inputs(load("B03"), mi.calibrate(load("B03"), "A42"))
    names = mi.input_names("A42")
    assert cal3["profile"] == "A42" and v3["valid"]
    assert np.allclose(ds3[names].to_numpy(), x[names].to_numpy())
    ds1, _, v1, _ = sp.dataset("B01")
    assert not v1["valid"] and (ds1.temp_resid_z == 0).all() and ds1.temp_input_masked.all()


def test_folds_hold_out_whole_development_bearings():
    f = sp.folds(["B01", "B02", "B03"])
    assert [x["held_out"] for x in f] == ["B01", "B02", "B03"]
    assert all(x["held_out"] not in x["train"] and set(x["train"]) <= {"B01", "B02", "B03"} for x in f)


def test_detector_metrics_on_a_synthetic_bearing():
    n = 120
    y = np.full(n, np.nan)
    y[:100], y[-5:] = 0, 1
    s = np.zeros(n)
    s[110:] = 2.0
    ts = pd.Series(pd.date_range("2026-01-01", periods=n, freq="12s"))
    m = sp.detector_metrics(s, 1.0, y, ts, np.arange(1, n + 1))
    assert m["start_above_fraction"] == 0 and m["end_alarmed_fraction"] == 1
    assert m["first_confirmed_alarm_measurement_id"] == 113 and m["alarm_state_changes_after_first_alarm"] == 0


def test_prototype_comparison_matches_the_stored_baseline():
    """The in-memory baseline is the stored one: confirmed RUN - 1 measurements after its first persistent alarm."""
    for e in ("B01", "B03"):
        _, _, alarm = sp.commissioned_alarm(ab.prepare(load(e)), ab.PRIMARY)
        assert alarm == BASE["experiments"][e]["primary"]["first_alarm"]["measurement_id"]


# ---------- the gate ----------

def test_training_is_blocked_until_b02_b04_are_checked_and_labels_reviewed():
    block = sp.ready()
    if not all((HERE / "results" / "paderborn" / e / f"{e}_processed.csv").exists() for e in sp.REQUIRED_NEW):
        assert any("B02" in b for b in block) and any("B04" in b for b in block)
    if not sp.REVIEW.exists():
        assert any("label_review.json" in b for b in block)
    if block:
        with pytest.raises(RuntimeError):
            sp.require_ready()


# ---------- B02, B04 ----------

needs_b02_b04 = pytest.mark.skipif(not all((HERE / "results" / "paderborn" / e / f"{e}_processed.csv").exists()
                                          for e in ("B02", "B04")), reason="B02/B04 not processed")


@needs_b02_b04
def test_b02_b04_pass_the_hard_data_checks():
    for e in ("B02", "B04"):
        assert sp.data_checks(e)["hard_failures"] == [], e


@needs_b02_b04
def test_b02_b04_end_labels_and_the_b02_intermediate_stop_stays_masked():
    y2, i2 = lb.label("B02")
    y4, i4 = lb.label("B04")
    assert i2["end"]["measurement_ids"] == [1112, 1116] and i4["end"]["measurement_ids"] == [1110, 1114]
    assert y2.set_index("measurement_id").y_det.loc[915:925].isna().all()     # the 13:32 stop: not a dismantling


@needs_b02_b04
def test_b04_half_scale_speed_does_not_change_the_inputs():
    d = load("B04")
    fixed = d.assign(speed_rpm=2 * d.speed_rpm)
    names = mi.input_names("A42")
    a = mi.inputs(d, mi.calibrate(d, "A42"))[names].to_numpy()
    b = mi.inputs(fixed, mi.calibrate(fixed, "A42"))[names].to_numpy()
    assert np.allclose(a, b, atol=1e-5)
    assert abs(sp.speed_ratio("B04") - 0.5) < 0.01 and abs(sp.speed_ratio("B02") - 1) < 0.01


def test_an_unconfirmed_review_does_not_unblock_training(tmp_path, monkeypatch):
    doc = json.loads((lb.OUT / "label_table.json").read_text(encoding="utf-8"))
    checks = [i["check"] for i in json.loads((lb.OUT / "label_review.TEMPLATE.json").read_text(encoding="utf-8"))["items"]]
    review = tmp_path / "label_review.json"
    review.write_text(json.dumps({"label_table_sha256": doc["sha256"], "checked_by": "someone",
                                  "items": [{"check": c, "confirmed": None} for c in checks]}))
    monkeypatch.setattr(sp, "REVIEW", review)
    assert any("not confirmed" in b for b in sp.ready())
    review.write_text(json.dumps({"label_table_sha256": "0" * 64, "checked_by": "someone",
                                  "items": [{"check": c, "confirmed": True} for c in checks]}))
    assert any("does not sign off" in b for b in sp.ready())
    review.write_text(json.dumps({"label_table_sha256": doc["sha256"], "checked_by": "someone",
                                  "independent_check_by": "someone", "items": [{"check": c, "confirmed": True} for c in checks]}))
    assert any("independent check" in b for b in sp.ready())


def test_the_review_must_use_the_current_template_and_an_unedited_table(tmp_path, monkeypatch):
    doc = json.loads((lb.OUT / "label_table.json").read_text(encoding="utf-8"))
    tpl = json.loads((lb.OUT / "label_review.TEMPLATE.json").read_text(encoding="utf-8"))
    review = tmp_path / "label_review.json"
    old = [{"check": "an older wording", "confirmed": True}] * len(tpl["items"])
    review.write_text(json.dumps({"label_table_sha256": doc["sha256"], "checked_by": "a", "independent_check_by": "b",
                                  "items": old}))
    monkeypatch.setattr(sp, "REVIEW", review)
    assert any("differ from the current template" in b for b in sp.ready())
    edited = tmp_path / "supervised"
    edited.mkdir()
    doc["table"]["bearings"]["B02"]["end"]["n"] = 6                 # an edit after labels.py wrote the table
    (edited / "label_table.json").write_text(json.dumps(doc))
    monkeypatch.setattr(sp, "OUT", edited)
    assert any("edited after labels.py" in b for b in sp.ready())


# ---------- the prepared training run (train_deterioration.py; synthetic data only, nothing real is trained) ----------

def test_training_run_refuses_before_sign_off():
    import train_deterioration as td
    if sp.ready():
        with pytest.raises(RuntimeError):
            td.main()
        assert not td.OUT.exists()


def test_train_fold_leaves_the_health_head_untouched_on_synthetic_data(monkeypatch):
    import train_deterioration as td
    monkeypatch.setattr(td, "STEPS", 50)
    rng = np.random.default_rng(0)
    X = rng.normal(size=(120, 8)).astype(np.float32)
    y = np.r_[np.zeros(110), np.ones(10)]
    X[y == 1, :6] += 4.0                                           # a separable toy signal
    import mtl_model as mm
    ref = mm.MultiTaskMLP(seed=1)
    net, curve = td.train_fold(X, y, 1)
    assert all(torch_equal(a, b) for a, b in zip(ref.hi_head.parameters(), net.hi_head.parameters()))
    assert not bool(net.trained) and len(curve) == 50
    p = td.probability(net, X)
    assert p[y == 1].mean() > p[y == 0].mean()


def torch_equal(a, b):
    import torch
    return torch.equal(a.detach(), b.detach())
