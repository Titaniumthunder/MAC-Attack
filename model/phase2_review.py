"""Dataset-validation review for supervised training: the final single-sensor chain and B01's temperature calibration.

  python phase2_review.py        -> results/phase2/review.json, figures/thermal_B01.png, figures/sensor_inputs.png

Nothing is trained and no label is made. Uses the unchanged pipeline (mtl_inputs.py, anomaly_baseline.py) on B01, B03.

1. Final sensor chain (one accelerometer, one temperature sensor, RPM): the 8 multi-task inputs for each accelerometer
   position (A rear, C front) and each sample-rate profile (A128: 128-kHz bands; A42: what a 42.67-kHz chain sees,
   the only profile available for all 17 experiments): how far commissioning-standardized inputs wander before the
   anomaly onset (fraction of measurements with any |x| > 3), how many saturate at +-16 after it, and the baseline's
   alarm with the same channel and sample rate.
2. B01 temperature: why the thermal model failed, against B03, and a validity rule for a thermal calibration that can
   be checked on the device at commissioning time (no future data):
     V1 one uninterrupted segment from a cold start (first T1 within 10 degC of ambient)  -> the warm-up curve is whole
     V2 steady state (STEADY_MIN min without warming) reached before the first vibration alarm
     V3 steady-state residual <= 1 degC (the sensor's accuracy at 110 degC is +-0.85 degC)
   The B01/B03 numbers below were looked at before the rule was written down; it is a proposal to test on B02-B17.
"""
import json
from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import matplotlib.dates as mdates
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

import anomaly_baseline as ab
import mtl_inputs as mi
from paderborn import HERE, load

OUT = HERE / "results" / "phase2"
EXPS = ("B01", "B03")
BASE = json.loads((HERE / "results" / "paderborn" / "anomaly" / "baseline.json").read_text())
plt.rcParams.update({"font.family": "DejaVu Sans", "font.size": 9, "axes.spines.top": False, "axes.spines.right": False,
                     "axes.grid": True, "grid.color": "#e4e3df", "legend.frameon": False, "axes.edgecolor": ab.MUTED})


def inputs_for(full, channel, profile):
    """mtl_inputs with another accelerometer: CHANNEL is a module constant, set and restored here."""
    keep = mi.CHANNEL
    mi.CHANNEL = channel
    try:
        cal = mi.calibrate(full, profile)
        return cal, mi.inputs(full, cal)
    finally:
        mi.CHANNEL = keep


def sensor_review(data):
    rows = []
    for e, full in data.items():
        onset = BASE["experiments"][e]["primary"]["first_alarm"]["measurement_id"]
        for ch in "AC":
            for prof, fset in (("A128", "F128"), ("A42", "F42")):
                cal, o = inputs_for(full, ch, prof)
                X = np.abs(o[mi.input_names(prof)[:6]].to_numpy())
                mon = (~o.reference.to_numpy()) & (o.measurement_id.to_numpy() < onset)
                post = o.measurement_id.to_numpy() >= onset
                v = BASE["experiments"][e]["variants"][f"{ch}|{fset}|speed"]
                fa = v["first_alarm"]
                rows.append({"experiment": e, "channel": ch, "profile": prof,
                             "pre_onset_rows": int(mon.sum()),
                             "pre_onset_any_abs_z_gt3": float((X[mon] > 3).any(axis=1).mean()),
                             "pre_onset_max_abs_z": float(X[mon].max()),
                             "post_onset_rows": int(post.sum()),
                             "post_onset_any_saturated": float((X[post] >= mi.Z_CLIP).any(axis=1).mean()),
                             "post_onset_median_abs_z": float(np.median(X[post])),
                             "baseline_first_alarm": fa and fa["measurement_id"],
                             "baseline_pre_alarm_exceed": f"{v['post_ref_pre_alarm_exceed']}/{v['post_ref_pre_alarm_n']}",
                             "baseline_median_after_over_tau": fa and fa["median_score_after_over_tau"]})
    return rows


def thermal_validity(full, cal, first_alarm_id):
    th = cal["thermal"]
    end = th["end_index"]
    seg = full.segment.to_numpy()[:end + 1]
    v1 = bool((seg == seg[0]).all() and full.T1_C.iloc[0] - full.Troom_C.iloc[0] <= 10)
    v2 = bool(th["end_measurement_id"] < first_alarm_id)
    v3 = bool(th["sigma_T_raw_degC"] <= 1.0)
    return {"V1_uninterrupted_cold_start": v1, "V2_steady_before_first_alarm": v2, "V3_steady_residual_le_1C": v3,
            "valid": v1 and v2 and v3, "segments_in_calibration": sorted(set(int(s) for s in seg)),
            "T1_start_minus_ambient_C": float(full.T1_C.iloc[0] - full.Troom_C.iloc[0]),
            "calibration_end_id": th["end_measurement_id"], "first_alarm_id": first_alarm_id,
            "sigma_T_raw_C": th["sigma_T_raw_degC"], "a_degC_per_krpm": th["a_degC_per_krpm"], "tau_min": th["tau_min"]}


def heating(full):
    """T1 rise in the first 15 and 25 minutes of operation at test conditions (warm-up rows excluded) of segment 1."""
    d = full[(full.segment == 1) & ~full.warmup]
    t = (d.timestamp - d.timestamp.iloc[0]).dt.total_seconds() / 60
    out = {"T1_at_start": float(d.T1_C.iloc[0])}
    for m in (15, 25):
        k = int(np.searchsorted(t.to_numpy(), m))
        if k < len(d):
            out[f"T1_after_{m}_min"] = float(d.T1_C.iloc[k])
    out["segment1_minutes"] = float(t.iloc[-1])
    out["segment1_T1_end"] = float(d.T1_C.iloc[-1])
    return out


def b01_alternatives(full, cal3):
    """Expected-temperature residuals on B01's plateau (10:15-10:50) under three calibrations: the pipeline's, a fit on
    segment 3 only (restart to just before the vibration onset), and B03's parameters (another bearing)."""
    from scipy.optimize import least_squares
    t = (full.timestamp - full.timestamp.iloc[0]).dt.total_seconds().to_numpy() / 60
    T, rpm = full.T1_C.to_numpy(), full.speed_rpm.to_numpy()
    dt = np.r_[0.0, np.diff(t)]
    new = np.r_[True, np.diff(full.segment.to_numpy()) != 0]
    plateau = ((full.timestamp >= "2021-10-19 10:15") & (full.timestamp <= "2021-10-19 10:50")).to_numpy()
    res = {}
    th = cal3["B01"]["thermal"]
    sim = mi.thermal_sim((th["a_degC_per_krpm"], th["tau_min"]), T, rpm, dt, new, th["T_amb"])
    res["pipeline (calibrated to M0215, 3 segments)"] = {"a": th["a_degC_per_krpm"], "tau": th["tau_min"],
                                                          "plateau_median_resid_C": float(np.median((T - sim)[plateau]))}
    s3 = (full.segment == 3).to_numpy() & (full.measurement_id < 208).to_numpy()
    i = np.flatnonzero(s3)
    r = least_squares(lambda p: mi.thermal_sim(p, T[i], rpm[i], dt[i], np.r_[True, np.zeros(len(i) - 1, bool)],
                                               th["T_amb"]) - T[i], [30.0, 15.0], bounds=([0.0, 0.5], [500.0, 600.0]))
    sim3 = mi.thermal_sim(r.x, T, rpm, dt, new, th["T_amb"])
    res["segment 3 only, before M0208"] = {"a": float(r.x[0]), "tau": float(r.x[1]), "fit_rows": int(len(i)),
                                           "plateau_median_resid_C": float(np.median((T - sim3)[plateau]))}
    b3 = cal3["B03"]["thermal"]
    simb = mi.thermal_sim((b3["a_degC_per_krpm"], b3["tau_min"]), T, rpm, dt, new, th["T_amb"])
    res["B03's parameters (cross-bearing)"] = {"a": b3["a_degC_per_krpm"], "tau": b3["tau_min"],
                                               "plateau_median_resid_C": float(np.median((T - simb)[plateau]))}
    return res, {"pipeline": sim, "segment 3 only": sim3, "B03 parameters": simb}


def thermal_figure(full, sims):
    fig, ax = plt.subplots(figsize=(9, 3.6))
    t = full.timestamp
    w = full.warmup.to_numpy()
    ax.plot(t[~w], full.T1_C[~w], ".", ms=3, color=ab.INK2, label="T1 measured")
    ax.plot(t[w], full.T1_C[w], ".", ms=3, color=ab.MUTED, label="T1, 750-rpm warm-up")
    for (name, s), col in zip(sims.items(), (ab.ORANGE, ab.BLUE, ab.AQUA)):
        for k, (_, g) in enumerate(full.groupby("segment")):
            ax.plot(t[g.index], s[g.index], color=col, linewidth=1.1, label=f"expected: {name}" if k == 0 else None)
    for ts, txt in (("2021-10-19 09:13", "log: stop, temperature\nthreshold exceeded"),
                    ("2021-10-19 10:06:24", "vibration onset\nM0208")):
        ax.axvline(pd.Timestamp(ts), color=ab.MUTED, linestyle=":", linewidth=0.9)
        ax.text(pd.Timestamp(ts), 30, " " + txt, fontsize=7.5, color=ab.INK2, va="bottom")
    ax.set_ylabel("°C")
    ax.set_ylim(15, 140)
    ax.xaxis.set_major_formatter(mdates.DateFormatter("%H:%M"))
    ax.legend(fontsize=7.5, loc="upper left", ncol=3)
    ax.set_title("B01: housing temperature T1 and three thermal calibrations", fontsize=9, loc="left")
    fig.tight_layout()
    fig.savefig(OUT / "figures" / "thermal_B01.png", dpi=150)
    plt.close(fig)


def sensor_figure(rows):
    fig, ax = plt.subplots(figsize=(9, 2.8))
    labels = [f"{r['experiment']} {r['channel']} {r['profile'][1:]} kHz" for r in rows]
    y = np.arange(len(rows))
    ax.scatter([r["pre_onset_any_abs_z_gt3"] * 100 for r in rows], y, color=ab.BLUE, s=22,
               label="before onset: rows with any |z| > 3 (%)")
    ax.scatter([r["post_onset_any_saturated"] * 100 for r in rows], y, color=ab.ORANGE, s=22, marker="s",
               label="after onset (rear-sensor baseline): rows with an input at ±16 (%)")
    ax.set_yticks(y, labels, fontsize=7.5)
    ax.invert_yaxis()
    ax.set_xlim(-3, 103)
    ax.set_xlabel("% of measurements")
    ax.legend(fontsize=7.5, loc="lower left", bbox_to_anchor=(0, 1.0), ncol=2)
    fig.tight_layout()
    fig.savefig(OUT / "figures" / "sensor_inputs.png", dpi=150)
    plt.close(fig)


def main():
    (OUT / "figures").mkdir(parents=True, exist_ok=True)
    data = {e: load(e) for e in EXPS}
    cal = {e: mi.calibrate(data[e]) for e in EXPS}
    rows = sensor_review(data)
    validity = {e: thermal_validity(data[e], cal[e], BASE["experiments"][e]["primary"]["first_alarm"]["measurement_id"])
                for e in EXPS}
    alts, sims = b01_alternatives(data["B01"], cal)
    review = {"sensor_inputs": rows, "thermal_validity": validity, "heating": {e: heating(data[e]) for e in EXPS},
              "b01_thermal_alternatives": alts}
    (OUT / "review.json").write_text(json.dumps(review, indent=1) + "\n", encoding="utf-8")
    thermal_figure(data["B01"], sims)
    sensor_figure(rows)
    print(json.dumps(review, indent=1))


if __name__ == "__main__":
    main()
