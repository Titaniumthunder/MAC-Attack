"""Checks of the dataset-validation phase: multi-experiment preprocessing, the experiment registry, the locked split and
the input-pipeline guards. Run inside model/:

  python -m pytest test_phase2.py -q
"""
import json

import numpy as np
import pandas as pd
import pytest

import mtl_inputs as mi
import paderborn as pb
import splits
from paderborn import HERE, load

REG = json.loads((HERE / "paderborn_experiments.json").read_text(encoding="utf-8"))["experiments"]


# ---------- preprocessing at 128 and 64 kHz ----------

def tone(fs, f, amp=1.0, seconds=1.6):
    t = np.arange(int(fs * seconds)) / fs
    return amp * np.sin(2 * np.pi * f * t)


@pytest.mark.parametrize("fs", [128000, 64000])
def test_band_energy_lands_in_the_right_band(fs):
    x = tone(fs, 3000, 2.0) + tone(fs, 12000, 0.5)
    f = pb.features(x, fs)
    assert f["band_1k_5k"] == pytest.approx(2.0 / np.sqrt(2), rel=1e-3)
    assert f["band_5k_20k"] == pytest.approx(0.5 / np.sqrt(2), rel=1e-3)
    assert f["band_10_1k"] < 1e-6
    if fs == 64000:
        assert np.isnan(f["band_20k_64k"])                      # above Nyquist: left empty, not invented
    else:
        assert f["band_20k_64k"] < 1e-6


def test_lr_features_agree_between_sample_rates():
    """The same band-limited signal recorded at 128 and 64 kHz gives the same 42.67-kHz statistics."""
    sig = lambda fs: tone(fs, 2500, 1.0) + tone(fs, 9000, 0.3)
    a, b = pb.features(sig(128000), 128000), pb.features(sig(64000), 64000)
    for k in ("lr_rms", "lr_std", "lr_kurt", "lr_crest"):
        assert a[k] == pytest.approx(b[k], rel=0.02), k


def test_unknown_sample_rate_is_refused():
    with pytest.raises(ValueError):
        pb.features(tone(50000, 1000), 50000)


@pytest.mark.skipif(not (HERE / "newdata" / "B03" / "vibrationData").exists(), reason="raw B03 not present")
def test_reprocessing_reproduces_stored_b03_rows():
    stored = load("B03")
    for i in (0, 1, 300, 613):
        p = HERE / "newdata" / "B03" / "vibrationData" / stored.file[i]
        r = pb.read_one(p)
        for c in [c for c in r if c.startswith("acc")]:
            assert r[c] == pytest.approx(stored[c][i], rel=1e-7, nan_ok=True), (i, c)


# ---------- registry ----------

def test_registry_lists_all_17_with_published_metadata():
    assert sorted(REG) == [f"B{i:02d}" for i in range(1, 18)]
    for b, e in REG.items():
        assert e["fs_hz"] == (128000 if int(b[1:]) <= 9 else 64000)
        assert set(e["description"]) == {"approx_duration_h", "n_files", "threshold_criterion", "defect_after_dismantling"}
        assert set(e["description"]["defect_after_dismantling"].replace(" ", "").split(",")) <= {"IR", "OR", "B"}
        assert {"setSpeed_rpm", "setStat_N", "setDyn_N"} <= set(e["ranges"])
    assert REG["B01"]["log_end"] == "2021-10-19 09:13" and REG["B03"]["temperature_limit_C"] == 110
    assert {b for b, e in REG.items() if e["description"]["threshold_criterion"] is None} == {"B01", "B05", "B16"}


def test_registry_holds_no_degradation_label_or_time():
    text = json.dumps(REG).lower()
    for word in ("health", "rul", "onset", "severity", "label", "transition"):
        assert word not in text, word


# ---------- locked split ----------

def test_split_is_the_declared_draw_and_unedited():
    s = splits.load()                                          # also checks the stored hash
    assert s == splits.draw()


def test_split_partitions_whole_bearings():
    s = splits.load()
    test = set(s["test"].values())
    assert len(test) == 4 and test.isdisjoint(s["development"])
    assert sorted(test | set(s["development"])) == splits.ALL
    assert not test & set(splits.NOT_ELIGIBLE)
    for g, b in s["test"].items():
        assert b in splits.REGIMES[g]
    assert all(f["held_out"] not in f["train"] and not test & set(f["train"]) for f in s["development_folds"])


def test_test_set_is_locked():
    with pytest.raises(RuntimeError):
        splits.test_bearings()
    with pytest.raises(RuntimeError):
        splits.assert_development(["B02", "B06"])
    splits.assert_development(["B01", "B03"])


# ---------- input-pipeline guards for the new experiments ----------

def test_constant_speed_experiment_gets_no_rpm_term():
    full = load("B03").copy()
    full["setSpeed_rpm"] = 2700.0                                  # as B14-B17
    cal = mi.calibrate(full)
    o = mi.inputs(full, cal)
    assert cal["rpm_correction"] is False and not any(cal["vib_b1_ln_rpm"])
    assert np.isfinite(o[mi.input_names()].to_numpy()).all() and np.abs(o.rpm_z).max() < 1


def test_64khz_experiment_needs_the_42khz_profile():
    full = load("B03").copy()
    full["accA_band_20k_64k"] = np.nan                            # as B10-B17
    with pytest.raises(ValueError):
        mi.calibrate(full, "A128")
    o = mi.inputs(full, mi.calibrate(full, "A42"))
    assert np.isfinite(o[mi.input_names("A42")].to_numpy()).all()


def test_b01_b03_inputs_unchanged_by_the_guards():
    for e in ("B01", "B03"):
        full = load(e)
        o = mi.inputs(full, mi.calibrate(full))
        old = pd.read_csv(HERE / "results" / "multitask" / f"inputs_{e}.csv")
        assert np.allclose(o[mi.input_names()].to_numpy(), old[mi.input_names()].to_numpy(), rtol=1e-5)


# ---------- thermal calibration validity (phase2_review.py) ----------

def test_thermal_validity_rule():
    import phase2_review as pr
    base = pr.BASE["experiments"]
    v = {e: pr.thermal_validity(load(e), mi.calibrate(load(e)), base[e]["primary"]["first_alarm"]["measurement_id"])
         for e in ("B01", "B03")}
    assert v["B03"]["valid"] and not v["B01"]["valid"]
    assert not v["B01"]["V1_uninterrupted_cold_start"] and not v["B01"]["V2_steady_before_first_alarm"]
