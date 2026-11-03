"""Training Run 3 preparation: the seven labelled development bearings B02, B03, B04, B08, B09, B11, B12 (3 Nov 2026).

  python run3_prep.py      -> results/supervised/run3/prep/   (refuses to overwrite; Runs 1-2 files are not touched)

Uses the existing pipeline unchanged: paderborn.py outputs, labels.label (the 2 Nov rule), supervised_prep.dataset (the A42
inputs, per-bearing commissioning, thermal validity V1-V3), anomaly_baseline. Nothing is written to results/supervised/
itself: labels.py / supervised_prep.py as scripts would overwrite Run 1-2's label_table.json, dataset_*.csv and folds.json.

Writes:
  inputs_<EXP>.npz       the same arrays at full precision (X clipped, R raw, y, ids, timestamps, scores), read by training
  dataset_<EXP>.csv      per operating measurement: ids, time, segment, the 8 inputs (clipped at +-16, as Runs 1-2),
                         raw_<input> (the same inputs before clipping), y_det, label source, anomaly scores, rear RMS
  label_table_run3.json  the label rule, evidence and every bearing's labels, with its SHA-256; plus the check that the
                         B02-B04 part reproduces Run 1-2's label_table.json digest exactly
  folds_run3.json        outer leave-one-bearing-out folds and, inside each, the inner folds (nested LOBO)
  data_quality.json      hard and soft data checks, thermal validity (with the prototype's alarm and with A|F42|speed's),
                         clipping counts, detector thresholds and alarms
B01 is excluded (no labels); the locked test bearings B06, B07, B13, B17 are refused by splits.assert_development.
"""
import json

import numpy as np
import pandas as pd

import anomaly_baseline as ab
import labels as lb
import mtl_inputs as mi
import phase2_review as pr
import splits
import supervised_prep as sp
from paderborn import HERE, load

OUT = sp.OUT / "run3" / "prep"
BEARINGS = ("B02", "B03", "B04", "B08", "B09", "B11", "B12")
NEW = ("B08", "B09", "B11", "B12")
LOCKED = ("B06", "B07", "B13", "B17")
NAMES = mi.input_names(sp.PROFILE)


def raw_inputs(e):
    """The same 8 inputs as supervised_prep.dataset, before the +-16 clip (Z_CLIP lifted only inside this call)."""
    keep = mi.Z_CLIP
    try:
        mi.Z_CLIP = float("inf")
        ds, _, _, _ = sp.dataset(e)
    finally:
        mi.Z_CLIP = keep
    return ds


def main():
    if OUT.exists():
        raise SystemExit(f"{OUT} exists: not overwritten")
    splits.assert_development(BEARINGS)
    assert not set(BEARINGS) & set(LOCKED) and set(LOCKED) == set(splits.load()["test"].values())
    OUT.mkdir(parents=True)
    table = {"rule": {"start_n": lb.START_N, "start_withheld": lb.START_WITHHELD, "end_n": lb.END_N,
                      "end_tolerance_s": lb.END_TOLERANCE_S, "sensitivity_end_n": list(lb.SENSITIVITY_END_N),
                      "health_index": "no labels (no measured severity)"},
             "evidence": lb.EVIDENCE, "bearings": {}}
    quality = {}
    _, table["bearings"]["B01"] = lb.label("B01")        # listed with its withheld labels, as in Run 1-2's table
    for e in BEARINGS:
        dc = sp.data_checks(e)
        if dc["hard_failures"]:
            raise SystemExit(f"{e}: hard data checks fail: {dc['hard_failures']}")
        y, info = lb.label(e)
        ds, cal, v, _ = sp.dataset(e)
        raw = raw_inputs(e)
        assert (raw.measurement_id.to_numpy() == ds.measurement_id.to_numpy()).all()
        assert np.allclose(np.clip(raw[NAMES].to_numpy(), -mi.Z_CLIP, mi.Z_CLIP), ds[NAMES].to_numpy())
        full = load(e)
        d = ab.prepare(full)
        assert (d.measurement_id.to_numpy() == ds.measurement_id.to_numpy()).all()
        out = ds.copy()
        for n in NAMES:
            out[f"raw_{n}"] = raw[n].to_numpy()
        det = {}
        for name, cfg in sp.DETECTORS.items():
            s, tau, alarm = sp.commissioned_alarm(d, cfg)
            out[f"score_{cfg[1]}"], out[f"tau_{cfg[1]}"] = s, tau
            det[name] = {"tau": None if not np.isfinite(tau) else float(tau), "persistent_alarm_id": alarm,
                         "available": bool(np.isfinite(s).all())}
        out["rear_rms_g"] = d.accA_rms.to_numpy()
        out.to_csv(OUT / f"dataset_{e}.csv", index=False, float_format="%.9g")
        np.savez(OUT / f"inputs_{e}.npz", X=ds[NAMES].to_numpy(np.float64), R=raw[NAMES].to_numpy(np.float64),
                 y=ds.y_det.to_numpy(np.float64), ids=ds.measurement_id.to_numpy(np.int64),
                 ts=ds.timestamp.to_numpy("datetime64[ns]").astype(np.int64), rms=d.accA_rms.to_numpy(np.float64),
                 **{f"score_{cfg[1]}": out[f"score_{cfg[1]}"].to_numpy(np.float64) for cfg in sp.DETECTORS.values()},
                 **{f"tau_{cfg[1]}": np.float64(out[f"tau_{cfg[1]}"].iloc[0]) for cfg in sp.DETECTORS.values()})
        _, _, a42 = sp.commissioned_alarm(d, ("A", "F42", "speed"))
        v42 = pr.thermal_validity(full, cal, a42 if a42 is not None else 10 ** 9)
        c = json.loads((HERE / "results" / "paderborn" / e / "checks.json").read_text())
        rawv = raw[NAMES].to_numpy()
        quality[e] = {"hard_failures": dc["hard_failures"], "soft": dc["soft"], "fs_hz": c["fs_hz"],
                      "first_record": c["first"], "last_record": c["last"], "segments": c["segments"],
                      "stops_over_60s": c["stops_over_60s"], "interval_s": c["interval_s"],
                      "warmup_rows": c["alignment"]["warmup_rows"], "alignment_lag0_r": c["alignment"]["dlogRMS_vs_dlogSpeed_corr_by_lag"]["0"]
                      if "0" in c["alignment"]["dlogRMS_vs_dlogSpeed_corr_by_lag"] else c["alignment"]["dlogRMS_vs_dlogSpeed_corr_by_lag"].get(0),
                      "lag0_clear": c["alignment"]["lag0_clear"], "T1_max_C": c["T1_max"],
                      "operating_measurements": len(ds),
                      "thermal_validity_as_used": v, "thermal_validity_with_A_F42_alarm": v42,
                      "temp_input_masked": bool(not v["valid"]),
                      "rows_with_an_input_clipped": int(ds.clipped.sum()),
                      "clipped_rows_per_input": {n: int((np.abs(rawv[:, j]) > mi.Z_CLIP).sum()) for j, n in enumerate(NAMES)},
                      "raw_max_per_input": {n: float(np.nanmax(np.abs(rawv[:, j]))) for j, n in enumerate(NAMES)},
                      "detectors": det, "rig_rule_rows_above_6.5g": int((d.accA_rms > sp.RIG_LIMIT_G).sum())}
        table["bearings"][e] = info
        print(f"{e}: {len(ds)} operating, labels {int((ds.y_det == 0).sum())} healthy / {int((ds.y_det == 1).sum())} end-stage, "
              f"x8 masked {not v['valid']}, clipped rows {int(ds.clipped.sum())}")
    digest = lb.table_digest(table)
    old = json.loads((sp.OUT / "label_table.json").read_text())
    sub = dict(table, bearings={e: table["bearings"][e] for e in ("B01", "B02", "B03", "B04")})
    doc = {"table": table, "sha256": digest,
           "provenance": {"rule_file": "labels.py (unchanged)", "run12_label_table_sha256": old["sha256"],
                          "b02_b04_part_reproduces_run12_table": lb.table_digest(sub) == old["sha256"],
                          "manual_two_person_review": "not required for this exploratory run (team decision); labels are "
                                                      "PROVISIONAL (A1-A4)",
                          "new_bearing_logs": "paderborn_experiments.json, transcribed 3 Nov 2026 (backup of the previous "
                                              "file: results/supervised/run3/provenance/paderborn_experiments.before_run3.json)"}}
    (OUT / "label_table_run3.json").write_text(json.dumps(doc, indent=1, default=str) + "\n", encoding="utf-8")
    folds = {"bearings": list(BEARINGS), "locked_test_never_loaded": list(LOCKED), "excluded": {"B01": "no labels"},
             "outer": [{"held_out": o, "train": [b for b in BEARINGS if b != o],
                        "inner": [{"validation": i, "train": [b for b in BEARINGS if b not in (o, i)]}
                                  for b in BEARINGS if b != o for i in [b]]} for o in BEARINGS]}
    (OUT / "folds_run3.json").write_text(json.dumps(folds, indent=1) + "\n", encoding="utf-8")
    (OUT / "data_quality.json").write_text(json.dumps(quality, indent=1, default=str) + "\n", encoding="utf-8")
    print(f"label table sha256 {digest[:16]}...; B02-B04 part reproduces Run 1-2's: "
          f"{doc['provenance']['b02_b04_part_reproduces_run12_table']}")


if __name__ == "__main__":
    main()
