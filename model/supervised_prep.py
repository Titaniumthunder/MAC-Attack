"""Preparation for supervised training of the deterioration head: data checks, inputs, folds, the baseline to beat, and
the gate that keeps training from starting early. Nothing is trained here.

  python supervised_prep.py     -> results/supervised/dataset_<EXP>.csv, folds.json, baseline_comparison.json,
                                   readiness.json   (run paderborn.py on the bearing and labels.py first)

  inputs      mtl_inputs.py unchanged, profile A42 (the 42.67-kHz chain: the only profile every experiment has), rear
              accelerometer A, per-bearing commissioning. x8 (temp_resid_z) is set to 0, the "not calibrated" value,
              when the bearing's thermal calibration fails the validity rule V1-V3 of phase2_review.py.
  labels      labels.py (start 0, end 1 only at a documented stop, middle masked; y_hi masked everywhere).
  folds       leave-one-bearing-out over the processed development bearings, from results/splits/splits.json; the
              locked test bearings B06, B07, B13, B17 are never loaded.
  baseline    anomaly_baseline.fit / score unchanged, per bearing on its own commissioning, in memory (baseline.json is
              not rewritten): the prototype's configuration A | F128 | speed, and A | F42 | speed (the same sensor
              information as the MLP's A42 inputs). Also the rig's own stop rule (rear RMS > 6.5 g, B02 log) as a
              reference: the vibration-stopped bearings' end labels sit where that rule fired, so a trained head
              must be compared with it (it would otherwise look good just by relearning the stop criterion). Scored on each held-out bearing with detector_metrics(), the
              function the trained MLP will be scored with.
  gate        ready() lists what still blocks training; require_ready() raises while anything does:
                - B02 and B04 processed, and every bearing's hard data checks pass
                - at least two bearings with an end label (every fold then trains on one)
                - label_review.json: a person has checked label_table.json against the documents (bound to its hash)
                - the network is still the 8 -> 32 -> 16 -> 2 MLP of mtl_model.py (850 parameters)
              The health-index head is not trained: y_hi has no labels, and training must also freeze hi_head.

The start rows are each bearing's commissioning reference, so the baseline is fitted on them (in-sample, flagged), and
the MLP's z-inputs are ~0 there by construction. The end rows are where damage is documented, not where it began
(labels.py A3): "end rows alarmed" and "first alarm before the last record" are not detection rates or delays.
"""
import json

import numpy as np
import pandas as pd

import anomaly_baseline as ab
import labels as lb
import mtl_inputs as mi
import phase2_review as pr
import splits
from paderborn import HERE, META, load

OUT = lb.OUT
PROFILE = "A42"
REQUIRED_NEW = ("B02", "B04")
DETECTORS = {"baseline A|F128|speed (prototype)": ("A", "F128", "speed"), "baseline A|F42|speed": ("A", "F42", "speed")}
REVIEW = OUT / "label_review.json"
RIG_LIMIT_G = 6.5                        # B02 log: accelerometer RMS 0.65 V x 10 g/V; the rig's own stop rule
SPEED_TOL = 0.05


def data_checks(exp):
    """Hard checks (any failure blocks the bearing) and soft ones (reported for the person reviewing checks.json)."""
    p = HERE / "results" / "paderborn" / exp / "checks.json"
    if not p.exists():
        return {"processed": False, "hard_failures": ["not processed (run paderborn.py)"], "soft": {}}
    c = json.loads(p.read_text(encoding="utf-8"))
    m = META["experiments"][exp]
    hard = {"ids contiguous, none missing or extra": c["ids_contiguous"] and not c["missing_ids"] and not c["extra_ids"],
            "as many .mat files as CSV rows": c["n_mat"] == c["n_csv_rows"],
            "file count as in the description": c["n_mat"] == m["description"]["n_files"],
            "sample count and rate": c["all_samples_ok"] and c["fs_hz"] == [float(m["fs_hz"])],
            "all samples finite": c["all_finite"],
            "timestamps increasing, no duplicates": c["timestamps_monotonic"] and c["duplicate_timestamps"] == 0,
            "file <-> row alignment at lag 0": c["alignment"]["lag0_clear"],
            "log transcribed": bool(m.get("log_end")),
            "measured speed = set speed (or a documented recording note)":
                abs(speed_ratio(exp) - 1) <= SPEED_TOL or bool(m.get("recording_note"))}
    soft = {k: c.get(k) for k in ("speed_not_reached", "static_load_off_150N", "setSpeed_out_of_log_range",
                                  "combined_set_outside_range", "records_after_log_end", "last_record_vs_log_end_s")}
    soft["segments"] = len(c["segments"])
    soft["median_measured_over_set_speed"] = round(speed_ratio(exp), 4)
    soft["recording_note"] = m.get("recording_note")
    return {"processed": True, "hard_failures": [k for k, v in hard.items() if not v], "soft": soft}


def speed_ratio(exp):
    """Median measured / set speed over the operating rows (B04's recorded speed is about half the set
    speed: a suspected logging/scaling discrepancy, not confirmed by the dataset authors)."""
    d = load(exp)
    d = d[~d.warmup]
    return float((d.speed_rpm / d.setSpeed_rpm).median())


def commissioned_alarm(d, cfg):
    """The baseline's per-bearing (commissioned) score, threshold and first persistent alarm id."""
    m = ab.fit(d[d.ref], *cfg)
    s, _ = ab.score(d, m)
    i0 = ab.first_persistent(s, m["tau"], ab.REF_N)
    return s, m["tau"], (None if i0 is None else int(d.measurement_id[i0]))


def dataset(exp):
    """The 8 A42 inputs, the labels and the thermal validity of one development bearing, in measurement order."""
    splits.assert_development([exp])
    full = load(exp)
    cal = mi.calibrate(full, PROFILE)
    x = mi.inputs(full, cal)
    _, _, alarm = commissioned_alarm(ab.prepare(full), ab.PRIMARY)
    v = pr.thermal_validity(full, cal, alarm if alarm is not None else 10 ** 9)
    if not v["valid"]:
        x["temp_resid_z"] = 0.0
    y, info = lb.label(exp, full)
    if not (y.measurement_id.to_numpy() == x.measurement_id.to_numpy()).all():
        raise ValueError(f"{exp}: labels and inputs are not the same measurements")
    keep = ["measurement_id", "timestamp", "segment", "reference"] + mi.input_names(PROFILE) + ["clipped"]
    out = x[keep].assign(temp_input_masked=not v["valid"], y_det=y.y_det.to_numpy(), y_hi=np.nan,
                         label_source=y.label_source.to_numpy())
    return out, cal, v, info


def confirmed(above, run=ab.RUN):
    """Causal persistent state: the last RUN values all above (as mtl_inputs.inputs's status)."""
    c = np.convolve(above.astype(int), np.ones(run, int))[:len(above)] == run
    c[:run - 1] = False
    return c


def detector_metrics(s, tau, y, ts, ids, in_sample_start=False):
    """One detector on one held-out bearing. s: per-measurement score (or probability), tau: its threshold, y: y_det,
    ts / ids: timestamps and measurement ids. The alarm is the causal confirmed state (RUN in a row above tau)."""
    s, y = np.asarray(s, float), np.asarray(y, float)
    above, conf = s > tau, confirmed(s > tau)
    start, end, masked = y == 0, y == 1, np.isnan(y)
    hours = (ts[start].iloc[-1] - ts[start].iloc[0]).total_seconds() / 3600 if start.any() else np.nan
    episodes = int((conf[start] & ~np.r_[False, conf[start][:-1]]).sum())
    after = np.flatnonzero(conf & ~start)
    first = int(after[0]) if len(after) else None
    tail = conf[first:] if first is not None else conf[:0]
    return {"start_rows": int(start.sum()), "start_in_sample": in_sample_start,
            "start_above_fraction": float(above[start].mean()) if start.any() else None,
            "start_alarm_episodes": episodes, "start_alarm_episodes_per_hour": episodes / hours if hours else None,
            "end_rows": int(end.sum()),
            "end_above_fraction": float(above[end].mean()) if end.any() else None,
            "end_alarmed_fraction": float(conf[end].mean()) if end.any() else None,
            "masked_alarmed_fraction (descriptive only)": float(conf[masked].mean()) if masked.any() else None,
            "first_confirmed_alarm_measurement_id": int(ids[first]) if first is not None else None,
            "first_alarm_minutes_before_last_record (not a detection delay)":
                float((ts.iloc[-1] - ts.iloc[first]).total_seconds() / 60) if first is not None else None,
            "alarm_state_changes_after_first_alarm": int(np.abs(np.diff(tail.astype(int))).sum()) if len(tail) > 1 else 0}


def folds(bearings):
    have = set(bearings)
    return [{"held_out": f["held_out"], "train": [b for b in f["train"] if b in have]}
            for f in splits.load()["development_folds"] if f["held_out"] in have]


def ready(info=None):
    """What still blocks supervised training (empty = ready)."""
    info = info if info is not None else {e: lb.label(e)[1] for e in lb.available()}
    block = []
    for e in REQUIRED_NEW:
        if e not in info:
            block.append(f"{e} not processed (put its files in newdata/{e}/, transcribe its log, run paderborn.py)")
    for e in info:
        f = data_checks(e)["hard_failures"]
        if f:
            block.append(f"{e} data checks fail: {', '.join(f)}")
    with_end = [e for e, i in info.items() if i["end"]["label"] == 1]
    if len(with_end) < 2:
        block.append(f"only {len(with_end)} bearing(s) with an end label ({', '.join(with_end) or 'none'}); need 2")
    table = OUT / "label_table.json"
    if not table.exists():
        block.append("label_table.json missing (run labels.py)")
    elif (lambda d: d["sha256"] != lb.table_digest(d["table"]))(json.loads(table.read_text(encoding="utf-8"))):
        block.append("label_table.json was edited after labels.py wrote it: its content no longer matches its hash")
    elif not REVIEW.exists():
        block.append("label_review.json missing: a person must check label_table.json against the documents")
    else:
        rv, doc = json.loads(REVIEW.read_text(encoding="utf-8")), json.loads(table.read_text(encoding="utf-8"))
        if rv.get("label_table_sha256") != doc["sha256"] or not rv.get("checked_by"):
            block.append("label_review.json does not sign off the current label_table.json")
        elif [i.get("check") for i in rv.get("items") or []] != [i["check"] for i in json.loads(
                (OUT / "label_review.TEMPLATE.json").read_text(encoding="utf-8"))["items"]]:
            block.append("label_review.json items differ from the current template (copy the template again)")
        elif not all(i.get("confirmed") is True for i in rv["items"]):
            block.append("label_review.json has items not confirmed")
        elif not rv.get("independent_check_by") or rv["independent_check_by"] == rv["checked_by"]:
            block.append("label_review.json needs an independent check by a second person (independent_check_by)")
    import mtl_model as mm
    if mm.HIDDEN != (32, 16) or mm.N_IN != 8 or mm.n_params(mm.MultiTaskMLP()) != 850:
        block.append("mtl_model.py is not the 8 -> 32 -> 16 -> 2 architecture")
    return block


def require_ready():
    block = ready()
    if block:
        raise RuntimeError("supervised training is blocked:\n  " + "\n  ".join(block))


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    bearings = lb.available()
    infos, comp, thermal = {}, {}, {}
    for e in bearings:
        ds, cal, v, info = dataset(e)
        infos[e], thermal[e] = info, v
        ds.to_csv(OUT / f"dataset_{e}.csv", index=False, float_format="%.6g")
        d = ab.prepare(load(e))
        comp[e] = {}
        for name, cfg in DETECTORS.items():
            s, tau, _ = commissioned_alarm(d, cfg)
            comp[e][name] = detector_metrics(s, tau, ds.y_det.to_numpy(), ds.timestamp.reset_index(drop=True),
                                             ds.measurement_id.to_numpy(), in_sample_start=True)
        comp[e][f"reference: rig stop rule, rear RMS > {RIG_LIMIT_G} g"] = detector_metrics(
            d.accA_rms.to_numpy(), RIG_LIMIT_G, ds.y_det.to_numpy(), ds.timestamp.reset_index(drop=True),
            ds.measurement_id.to_numpy())
        comp[e]["multi-task MLP (A42)"] = "not trained: blocked by supervised_prep.ready()"
    # a bearing with no label at all (B01) is neither held out nor trained on: it has nothing to score or learn from
    labelled = [e for e in bearings if infos[e]["start"]["label"] == 0 or infos[e]["end"]["label"] == 1]
    fl = folds(labelled)
    for f in fl:
        f["train_bearings_with_end_label"] = [b for b in f["train"] if infos[b]["end"]["label"] == 1]
    checks = {e: data_checks(e) for e in bearings + [e for e in REQUIRED_NEW if e not in bearings]}
    block = ready(infos)
    (OUT / "folds.json").write_text(json.dumps({"profile": PROFILE, "test_set": "locked (splits.py)",
                                                "without_labels": [e for e in bearings if e not in labelled], "folds": fl},
                                               indent=1) + "\n", encoding="utf-8")
    (OUT / "baseline_comparison.json").write_text(json.dumps(
        {"note": "per held-out bearing; start rows are the baseline's own reference (in-sample); end rows mark documented "
                 "damage, not onset", "thermal_validity": thermal, "detectors": comp}, indent=1, default=str) + "\n",
        encoding="utf-8")
    (OUT / "readiness.json").write_text(json.dumps({"ready": not block, "blockers": block, "data_checks": checks},
                                                   indent=1, default=str) + "\n", encoding="utf-8")
    for e in bearings:
        p = comp[e]["baseline A|F128|speed (prototype)"]
        print(f"{e}: start label {'yes' if infos[e]['start']['label'] == 0 else 'withheld'}; end label "
              f"{'yes' if infos[e]['end']['label'] else 'withheld'}; thermal input "
              f"{'used' if thermal[e]['valid'] else 'masked'}; prototype start above "
              f"{'-' if p['start_above_fraction'] is None else round(p['start_above_fraction'], 2)}, "
              f"end alarmed {p['end_alarmed_fraction'] if p['end_alarmed_fraction'] is not None else '-'}")
    print("ready" if not block else "BLOCKED:\n  " + "\n  ".join(block))


if __name__ == "__main__":
    main()
