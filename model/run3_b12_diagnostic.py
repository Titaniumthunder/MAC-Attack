"""Post-hoc diagnostic (NOT part of Run 3's evaluation, changes no label or result): why every Run 3 MLP misses B12.

  python run3_b12_diagnostic.py   -> results/supervised/run3/diagnostics/b12_recommissioned.json

The data review found an undocumented, lasting vibration step at M0061 (rear RMS ~0.56 -> ~1.37 g, 12 min after the
start), inside B12's first 100 operating measurements, which are both its healthy labels and its commissioning reference.
A reference that straddles a level change inflates the reference spread (sigma) and shrinks every later z-input.
Test: commission B12 on M0061-M0160 instead (the 100 measurements after the step), recompute the same 8 inputs and the
anomaly detector, and score them with the Run 3 OUTER models for B12 (trained on the other 6 bearings only, never on
B12). This is a what-if on one bearing chosen after seeing its result: it explains, it does not re-evaluate.
"""
import json

import numpy as np
import pandas as pd
import torch

import anomaly_baseline as ab
import mtl_inputs as mi
import supervised_prep as sp
import train_deterioration_run2 as r2
import train_deterioration_run3 as r3
from paderborn import load

OUT = r3.OUT.parent / "diagnostics"
NAMES = r3.td.NAMES


def inputs_from(full, no_thermal=False):
    """no_thermal: the thermal model cannot be fitted on the shortened recording (polyfit fails), so x8 is "not
    calibrated" (0) there; E does not use x8, C's x8 is then 0 on every row."""
    keep, keep_th = mi.Z_CLIP, mi.thermal_calibration
    try:
        mi.Z_CLIP = float("inf")
        if no_thermal:
            mi.thermal_calibration = lambda f, ref_end: ({"complete": False}, None)
        cal = mi.calibrate(full, sp.PROFILE)
        x = mi.inputs(full, cal)
    finally:
        mi.Z_CLIP, mi.thermal_calibration = keep, keep_th
    return x, cal


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    full = load("B12")
    sub = full[full.measurement_id >= 61].reset_index(drop=True)
    sub["t_in_segment_s"] = (sub.timestamp - sub.timestamp.iloc[0]).dt.total_seconds()   # the recording now starts at M0061
    res = {"note": __doc__.strip(), "variants": {}}
    for name, f in (("as used in Run 3 (reference M0001-M0100)", full), ("re-commissioned on M0061-M0160", sub)):
        x, cal = inputs_from(f, no_thermal=name.startswith("re"))
        v_thermal = "not calibrated (x8 = 0)" if name.startswith("re") else "as Run 3"
        ids = x.measurement_id.to_numpy()
        ts = pd.Series(pd.to_datetime(x.timestamp.to_numpy()))
        n = len(x)
        y = np.full(n, np.nan)
        y[-5:] = 1.0
        y[:100] = 0.0 if name.startswith("re") else y[:100]
        if not name.startswith("re"):
            y[:100] = 0.0
        R = x[NAMES].to_numpy(np.float64)
        Xs = np.sign(R) * np.log1p(np.minimum(np.abs(R), r3.ZCAP))
        Xs_c = Xs.copy()
        Xs[:, 7] = 0.0                                          # E: no temperature input
        v = {"x8": v_thermal, "reference_ids": cal["ref_measurement_ids"], "vib_sigma_ln_lr_rms": float(cal["vib_sigma"][0]),
             "end_stage_raw_z_ln_lr_rms": [round(float(a), 2) for a in R[-5:, 0]], "models": {}}
        for cfg, X in (("E_wd_slog_noT", Xs), ("C_wd_slog", Xs_c)):
            ps = []
            for s in r3.SEEDS:
                net = mm_load(cfg, s)
                with torch.no_grad():
                    p = torch.sigmoid(net(torch.tensor(X, dtype=torch.float32))[0]).double().numpy()
                ps.append(p)
                m = r2.alarm_metrics(r2.latched(p > r3.THR), p > r3.THR, y, ts, ids)
                v["models"].setdefault(cfg, []).append({"seed": s, "first_alarm_id": m["first_alarm_id"],
                                                        "min_before_last_record": m["first_alarm_min_before_last_record"],
                                                        "end_recall": m["end_recall"], "healthy_rows_alarmed": m["healthy_rows_alarmed"],
                                                        "end_stage_p": [round(float(a), 3) for a in p[-5:]]})
        d = ab.prepare(f)
        s_, tau, alarm = sp.commissioned_alarm(d, ("A", "F42", "speed"))
        m = r2.alarm_metrics(r2.latched(s_ > tau), s_ > tau, y, ts, ids)
        v["anomaly A|F42|speed"] = {"tau": float(tau), "first_alarm_id": m["first_alarm_id"],
                                    "min_before_last_record": m["first_alarm_min_before_last_record"], "end_recall": m["end_recall"]}
        res["variants"][name] = v
    (OUT / "b12_recommissioned.json").write_text(json.dumps(res, indent=1, default=str) + "\n", encoding="utf-8")
    for k, v in res["variants"].items():
        print(k, "| sigma", round(v["vib_sigma_ln_lr_rms"], 3), "| end z", v["end_stage_raw_z_ln_lr_rms"])
        for cfg, rows in v["models"].items():
            print("   ", cfg, [(r["first_alarm_id"], r["min_before_last_record"], r["end_recall"]) for r in rows])
        print("    anomaly", v["anomaly A|F42|speed"])


def mm_load(cfg, s):
    import mtl_model as mm
    net = mm.MultiTaskMLP(seed=s)
    net.load_state_dict(torch.load(r3.OUT / "models" / cfg / f"fold_B12_seed{s}.pt", weights_only=True))
    return net.eval()


if __name__ == "__main__":
    main()
