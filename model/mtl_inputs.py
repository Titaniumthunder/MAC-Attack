"""Sensor input pipeline for the Machine Guardian multi-task MLP (Paderborn B01, B03, ...), and the working prototype.

  python mtl_inputs.py                 every processed experiment in results/paderborn/ (run paderborn.py first)
  python mtl_inputs.py B01 B03

The three sensors of the final hardware only: ONE accelerometer (channel A, the rear one, as the anomaly baseline's
primary configuration), the measured temperature T1 and the measured RPM. Load is not an input (the hardware has no
load sensor). Each motor is calibrated on its own commissioning period; nothing is fitted across motors.

Per measurement (one 1.6-s vibration window every ~12 s; rows stay in measurement order, never shuffled), 8 inputs:
  x1..x6  vibration, RPM-corrected: z_j = (f_j - b0_j - b1_j ln rpm) / sigma_j, fitted by least squares on the motor's
          commissioning reference (its first REF_N = 100 operating measurements, as anomaly_baseline.py).
          PROFILES["A128"] (128-kHz chain, primary): ln RMS, ln peak, kurtosis, ln 1-5 kHz, ln 5-20 kHz, ln 20-64 kHz
          PROFILES["A42"]  (42.67-kHz chain):       ln lr_RMS, ln lr_peak, lr_kurtosis, ln 1-5 kHz, ln 5-20 kHz, lr_crest
  x7      operating point: (ln rpm - mean) / std over the reference (the speed itself, so the network can condition on
          it; the vibration inputs are already corrected for it)
  x8      temperature residual: (T1 - T_expected) / sigma_T, T_expected from the motor's own thermal model below;
          0 while the thermal calibration is not finished (temp_valid = False)
Inputs are clipped to +-Z_CLIP before they reach the network (the INT8 input scale is Z_CLIP / 127).

Temperature (its own input, not a regressor for vibration; see PADERBORN_BASELINE_REPORT.md section 6):
  thermal model   first order, driven by the measured RPM: T_ss = T_amb + a * rpm / 1000,
                  T[k] = T_ss[k-1] - (T_ss[k-1] - T[k-1]) * exp(-dt / tau), simulated open loop from the measured
                  temperature at the start of each segment (a restart after a stop re-initializes it); T_amb = the first
                  measured temperature (the motor is cold when it is commissioned).
  warming         no temperature verdict while the motor is expected to be heating up. Before the thermal calibration:
                  the measured slope of T1 over the last SLOPE_MIN minutes of the segment is >= WARM_RATE degC/min, or
                  the segment is younger than SLOPE_MIN minutes. After it: the model's expected rate
                  (T_ss - T_expected) / tau is >= WARM_RATE (after a start or restart). A rise the model does not expect
                  (in steady state) is therefore not hidden as "warming".
  calibration     (a, tau) fitted by least squares on every measurement (warm-up rows included) up to the later of the
                  vibration reference's end and the first time the motor has been out of "warming" for STEADY_MIN
                  minutes; sigma_T = the residual std over the non-warming calibration rows, at least SIGMA_T_MIN.
  The thresholds (0.5 degC/min, 5 and 10 min, 0.5 degC) are design choices made from the shape of the B01/B03
  temperature curves; they were not tuned on any vibration or alarm result.

Prototype (what the system reports today): the anomaly baseline, unchanged (anomaly_baseline.fit / score with its
primary configuration A | F128 | speed, threshold = 99th percentile of the reference, RUN = 3 in a row):
  status     "commissioning" in the reference; then "abnormal" when the last RUN scores are all above the threshold
             (causal: confirmed RUN - 1 measurements after the baseline's first persistent alarm), else "normal"
  severity   s / tau (1 = the threshold). A distance from the motor's own commissioning baseline: NOT a health %.
  temperature  its own state, reported next to the status and not merged into it: "warming", "calibrating",
             "normal" or "above expected" (residual > TEMP_Z sigma_T for RUN measurements in a row); informational.

Writes results/multitask/inputs_<EXP>.csv, calibration_<EXP>.json (what the ARM would store per motor), figures/.
"""
import json, sys
from pathlib import Path

import numpy as np
import pandas as pd
from scipy.optimize import least_squares

import anomaly_baseline as ab
from paderborn import HERE, load

OUT = HERE / "results" / "multitask"
REF_N, RUN = ab.REF_N, ab.RUN
CHANNEL = "A"
PROFILES = {"A128": [("rms", True), ("peak", True), ("kurt", False), ("band_1k_5k", True), ("band_5k_20k", True),
                     ("band_20k_64k", True)],
            "A42": [("lr_rms", True), ("lr_peak", True), ("lr_kurt", False), ("band_1k_5k", True),
                    ("band_5k_20k", True), ("lr_crest", False)]}
PRIMARY_PROFILE = "A128"
Z_CLIP = 16.0
WARM_RATE, SLOPE_MIN, STEADY_MIN, SIGMA_T_MIN, TEMP_Z = 0.5, 5.0, 10.0, 0.5, 3.0


def input_names(profile=PRIMARY_PROFILE):
    vib = [f"z_{'ln_' if lg else ''}{n}" for n, lg in PROFILES[profile]]
    return vib + ["rpm_z", "temp_resid_z"]


def vib_features(d, profile):
    cols = [d[f"acc{CHANNEL}_{n}"].to_numpy() for n, _ in PROFILES[profile]]
    return np.column_stack([np.log(c) if lg else c for c, (_, lg) in zip(cols, PROFILES[profile])])


# ---------- temperature ----------

def thermal_sim(p, T, rpm, dt_min, new_seg, T_amb):
    a, tau = p
    out = np.empty_like(T, dtype=float)
    for k in range(len(T)):
        if new_seg[k]:
            out[k] = T[k]
        else:
            Tss = T_amb + a * rpm[k - 1] / 1000.0
            out[k] = Tss - (Tss - out[k - 1]) * np.exp(-dt_min[k] / tau)
    return out


def warming(d):
    """True where T1 rises >= WARM_RATE degC/min over the last SLOPE_MIN minutes of the segment, or the segment is
    younger than SLOPE_MIN minutes (no slope yet)."""
    t = (d.timestamp - d.timestamp.iloc[0]).dt.total_seconds().to_numpy() / 60
    T, seg, ts = d.T1_C.to_numpy(), d.segment.to_numpy(), d.t_in_segment_s.to_numpy() / 60
    w = np.ones(len(d), bool)
    for k in range(len(d)):
        if ts[k] < SLOPE_MIN:
            continue
        m = (t >= t[k] - SLOPE_MIN) & (t <= t[k]) & (seg == seg[k])
        w[k] = np.polyfit(t[m], T[m], 1)[0] >= WARM_RATE
    return w


def thermal_calibration(d, ref_end):
    """Fit the thermal model on the motor's own start. d: every row (warm-up included), in order."""
    t = (d.timestamp - d.timestamp.iloc[0]).dt.total_seconds().to_numpy() / 60
    warm = warming(d)
    end = None
    for k in range(len(d)):
        m = (t >= t[k] - STEADY_MIN) & (t <= t[k]) & (d.segment.to_numpy() == d.segment.iloc[k])
        if t[k] - t[m].min() >= STEADY_MIN * 0.9 and not warm[m].any():
            end = max(k, ref_end)
            break
    T, rpm = d.T1_C.to_numpy(), d.speed_rpm.to_numpy()
    dt = np.r_[0.0, np.diff(t)]
    new = np.r_[True, np.diff(d.segment.to_numpy()) != 0]
    cal = {"T_amb": float(T[0]), "complete": end is not None}
    if end is None:
        return cal, warm
    i = slice(0, end + 1)
    r = least_squares(lambda p: thermal_sim(p, T[i], rpm[i], dt[i], new[i], T[0]) - T[i], [30.0, 15.0],
                      bounds=([0.0, 0.5], [500.0, 600.0]))
    res = T - thermal_sim(r.x, T, rpm, dt, new, T[0])
    steady = ~warm[i]
    cal.update({"a_degC_per_krpm": float(r.x[0]), "tau_min": float(r.x[1]), "end_index": int(end),
                "end_measurement_id": int(d.measurement_id.iloc[end]), "end_timestamp": str(d.timestamp.iloc[end]),
                "fit_rms_degC": float(np.sqrt((res[i] ** 2).mean())),
                "sigma_T_degC": float(max(res[i][steady].std(), SIGMA_T_MIN)),
                "sigma_T_raw_degC": float(res[i][steady].std())})
    return cal, warm


def expected_warming(d, cal, T_exp):
    Tss = cal["T_amb"] + cal["a_degC_per_krpm"] * d.speed_rpm.to_numpy() / 1000.0
    return (Tss - T_exp) / cal["tau_min"] >= WARM_RATE


def thermal_expected(d, cal):
    t = (d.timestamp - d.timestamp.iloc[0]).dt.total_seconds().to_numpy() / 60
    new = np.r_[True, np.diff(d.segment.to_numpy()) != 0]
    return thermal_sim((cal["a_degC_per_krpm"], cal["tau_min"]), d.T1_C.to_numpy(), d.speed_rpm.to_numpy(),
                       np.r_[0.0, np.diff(t)], new, cal["T_amb"])


# ---------- calibration and inputs ----------

def calibrate(full, profile=PRIMARY_PROFILE):
    """Per-motor commissioning: RPM correction of every vibration feature, the operating point, the thermal model and the
    anomaly baseline (primary configuration). full: the processed table of one experiment (warm-up rows included)."""
    full = full.reset_index(drop=True)
    op_idx = np.flatnonzero(~full.warmup.to_numpy())
    if len(op_idx) < REF_N:
        raise ValueError(f"{len(op_idx)} operating measurements, commissioning needs {REF_N}")
    ref_end = int(op_idx[REF_N - 1])
    d = ab.prepare(full)
    ref = d[d.ref]
    F = vib_features(ref, profile)
    if not np.isfinite(F).all():         # e.g. the 20-64 kHz band of a 64-kHz experiment (B10-B17): use profile A42
        raise ValueError(f"profile {profile} needs features this experiment does not have (sampled below 128 kHz?)")
    # constant set speed (B14-B17 run at 2700 rpm): the measured RPM only jitters, so no RPM term is fitted
    rpm_varies = ref.setSpeed_rpm.nunique() > 1
    X = np.column_stack([np.ones(len(ref)), ref.ln_speed] if rpm_varies else [np.ones(len(ref))])
    B, *_ = np.linalg.lstsq(X, F, rcond=None)
    sig = (F - X @ B).std(axis=0)
    b1 = B[1] if rpm_varies else np.zeros(F.shape[1])
    thermal, _ = thermal_calibration(full, ref_end)
    base = ab.fit(ref, *ab.PRIMARY)
    return {"profile": profile, "channel": CHANNEL, "inputs": input_names(profile), "ref_n": REF_N,
            "ref_measurement_ids": [int(ref.measurement_id.iloc[0]), int(ref.measurement_id.iloc[-1])],
            "rpm_correction": bool(rpm_varies),
            "vib_b0": B[0].tolist(), "vib_b1_ln_rpm": b1.tolist(), "vib_sigma": np.where(sig > 1e-12, sig, 1.0).tolist(),
            "ln_rpm_mean": float(ref.ln_speed.mean()), "ln_rpm_std": float(ref.ln_speed.std()) if rpm_varies else 1.0,
            "z_clip": Z_CLIP, "thermal": thermal,
            "anomaly": {"config": list(ab.PRIMARY), "features": base["names"], "B": base["B"].tolist(),
                        "sigma": base["sigma"].tolist(), "tau": base["tau"], "run": RUN}}


def inputs(full, cal):
    """The 8 network inputs and the prototype outputs for every operating measurement, in measurement order."""
    full = full.reset_index(drop=True)
    keep = ~full.warmup.to_numpy()
    d = ab.prepare(full)
    if not (d.measurement_id.diff().dropna() > 0).all() or not (d.timestamp.diff().dropna() >= pd.Timedelta(0)).all():
        raise ValueError("measurements are not in chronological order")
    F = vib_features(d, cal["profile"])
    Z = (F - np.array(cal["vib_b0"]) - np.outer(d.ln_speed, cal["vib_b1_ln_rpm"])) / np.array(cal["vib_sigma"])
    rz = (d.ln_speed.to_numpy() - cal["ln_rpm_mean"]) / cal["ln_rpm_std"]
    th = cal["thermal"]
    pos = np.arange(len(d))
    if th["complete"]:
        T_all = thermal_expected(full, th)
        valid = np.flatnonzero(keep) > th["end_index"]
        warm = np.where(valid, expected_warming(full, th, T_all)[keep], warming(full)[keep])
        T_exp = T_all[keep]
        resid = d.T1_C.to_numpy() - T_exp
    else:
        T_exp = resid = np.full(len(d), np.nan)
        valid = np.zeros(len(d), bool)
        warm = warming(full)[keep]
    tz = np.where(valid, resid / th.get("sigma_T_degC", 1.0), 0.0)
    Xraw = np.column_stack([Z, rz, tz])
    X = np.clip(Xraw, -Z_CLIP, Z_CLIP)
    # prototype: the baseline's score and threshold, unchanged
    m = {k: (np.array(v) if k in ("B", "sigma") else v) for k, v in cal["anomaly"].items()}
    m.update({"ch": m["config"][0], "fset": m["config"][1], "cond": m["config"][2]})
    s, _ = ab.score(d, m)
    tau = cal["anomaly"]["tau"]
    above = s > tau
    confirmed = np.array([k >= RUN - 1 and above[k - RUN + 1:k + 1].all() for k in pos])
    status = np.where(d.ref, "commissioning", np.where(confirmed & ~d.ref.to_numpy(), "abnormal", "normal"))
    t_above = valid & ~warm & (tz > TEMP_Z)
    t_conf = np.array([k >= RUN - 1 and t_above[k - RUN + 1:k + 1].all() for k in pos])
    t_state = np.where(~valid, "calibrating", np.where(warm, "warming", np.where(t_conf, "above expected", "normal")))
    out = pd.DataFrame({"measurement_id": d.measurement_id, "timestamp": d.timestamp, "segment": d.segment,
                        "reference": d.ref, "speed_rpm": d.speed_rpm, "T1_C": d.T1_C, "T_expected_C": T_exp,
                        "temp_resid_C": resid, "temp_valid": valid, "warming": warm})
    for j, n in enumerate(cal["inputs"]):
        out[n] = X[:, j]
    out["clipped"] = (np.abs(Xraw) > Z_CLIP).any(axis=1)
    out["anomaly_score"] = s
    out["threshold"] = tau
    out["severity"] = s / tau
    out["status"] = status
    out["temperature_state"] = t_state
    return out


def lobo_folds(experiments):
    """Leave-one-bearing-out: each experiment is held out whole (its own commissioning is the only part of it that may be
    fitted, as on a deployed unit)."""
    return [{"test": e, "train": [k for k in experiments if k != e]} for e in experiments]


def summary(e, cal, out):
    op = out[~out.reference]
    ab_ = op[op.status == "abnormal"]
    th = cal["thermal"]
    return {"experiment": e, "n_operating": len(out), "ref_ids": cal["ref_measurement_ids"], "tau": cal["anomaly"]["tau"],
            "first_confirmed_abnormal": None if ab_.empty else {"measurement_id": int(ab_.measurement_id.iloc[0]),
                                                                "timestamp": str(ab_.timestamp.iloc[0])},
            "abnormal_fraction_after_first": None if ab_.empty else
            float((op.status[op.index >= ab_.index[0]] == "abnormal").mean()),
            "clipped_rows": int(out.clipped.sum()),
            "thermal": th,
            "temperature_states": out.temperature_state.value_counts().to_dict(),
            "temp_resid_after_calibration_C": None if not out.temp_valid.any() else
            {q: float(np.percentile(out.temp_resid_C[out.temp_valid], q)) for q in (1, 50, 99)},
            "first_temp_above_expected": None if not (out.temperature_state == "above expected").any() else
            str(out.timestamp[out.temperature_state == "above expected"].iloc[0])}


def figure(results):
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.dates as mdates
    import matplotlib.pyplot as plt
    plt.rcParams.update({"font.family": "DejaVu Sans", "font.size": 9, "axes.spines.top": False,
                         "axes.spines.right": False, "axes.grid": True, "grid.color": "#e4e3df",
                         "legend.frameon": False, "axes.edgecolor": ab.MUTED})
    (OUT / "figures").mkdir(parents=True, exist_ok=True)
    fig, axs = plt.subplots(3, len(results), figsize=(10, 7.2), sharex="col", squeeze=False)
    for c, (e, (cal, out)) in enumerate(results.items()):
        t = out.timestamp
        ax = axs[0, c]
        segs = [g.index for _, g in out.groupby("segment")]          # no line across a stop
        for n, col in zip(cal["inputs"][:6], ["#2a78d6", "#eb6834", "#1baf7a", "#8a6bd1", "#d1a12a", "#52514e"]):
            for k, ix in enumerate(segs):
                ax.plot(t[ix], out[n][ix], linewidth=0.8, color=col, label=n.replace("z_", "") if k == 0 else None)
        ax.set_ylim(-Z_CLIP - 1, Z_CLIP + 1)
        ax.set_title(f"{e}: inputs x1-x6, vibration z (RPM-corrected)", fontsize=9, loc="left")
        if c == len(results) - 1:
            ax.legend(fontsize=7, ncol=2, loc="upper left")
        ax = axs[1, c]
        ax.plot(t, out.T1_C, ".", ms=2.5, color=ab.BLUE, label="T1 measured")
        for k, ix in enumerate(segs):
            ax.plot(t[ix], out.T_expected_C[ix], linewidth=1, color=ab.ORANGE,
                    label="expected (own thermal model)" if k == 0 else None)
        w = out.warming.to_numpy()
        ax.plot(t[w], out.T1_C[w], ".", ms=2.5, color=ab.MUTED, label="warming (no verdict)")
        th = cal["thermal"]
        if th["complete"]:
            ax.axvline(pd.Timestamp(th["end_timestamp"]), color=ab.INK2, linestyle=":", linewidth=0.9)
        ax.set_ylabel("°C")
        ax.set_title("T1 and its expected value (dotted: thermal calibration done)", fontsize=9, loc="left")
        ax.legend(fontsize=7, loc="lower right")
        ax = axs[2, c]
        col = np.where(out.status == "abnormal", ab.ORANGE, np.where(out.reference, ab.AQUA, ab.BLUE))
        ax.scatter(t, out.severity, s=3, c=col)
        ax.axhline(1, color=ab.INK2, linestyle="--", linewidth=0.9)
        ax.set_yscale("log")
        ax.set_ylabel("severity  s / tau")
        ax.set_title("prototype severity: commissioning, normal, abnormal", fontsize=9, loc="left")
        ax.xaxis.set_major_formatter(mdates.DateFormatter("%H:%M"))
    fig.tight_layout()
    fig.savefig(OUT / "figures" / "mtl_inputs.png", dpi=150)
    plt.close(fig)


def main():
    root = HERE / "results" / "paderborn"
    exps = sys.argv[1:] or sorted(p.name for p in root.iterdir() if (p / f"{p.name}_processed.csv").exists())
    OUT.mkdir(parents=True, exist_ok=True)
    results, summ = {}, {}
    for e in exps:
        full = load(e)
        cal = calibrate(full)
        out = inputs(full, cal)
        results[e] = (cal, out)
        out.to_csv(OUT / f"inputs_{e}.csv", index=False, float_format="%.6g")
        (OUT / f"calibration_{e}.json").write_text(json.dumps(cal, indent=1) + "\n", encoding="utf-8")
        summ[e] = summary(e, cal, out)
        s = summ[e]
        fa = s["first_confirmed_abnormal"]
        th = cal["thermal"]
        print(f"{e}: {s['n_operating']} rows x {len(cal['inputs'])} inputs; tau {s['tau']:.2f}; first confirmed abnormal "
              f"{'M%04d %s' % (fa['measurement_id'], fa['timestamp']) if fa else 'none'}; clipped rows {s['clipped_rows']}; "
              + (f"thermal a {th['a_degC_per_krpm']:.1f} degC/krpm, tau {th['tau_min']:.1f} min, calibrated to "
                 f"M{th['end_measurement_id']:04d}, sigma_T {th['sigma_T_degC']:.2f} degC" if th["complete"] else
                 "thermal calibration not complete"))
    (OUT / "summary.json").write_text(json.dumps({"lobo_folds": lobo_folds(exps), "experiments": summ}, indent=1,
                                                 default=str) + "\n", encoding="utf-8")
    figure(results)


if __name__ == "__main__":
    main()
