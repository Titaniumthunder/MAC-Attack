"""Paderborn run-to-failure experiments (B01, B03, ...): one preprocessing pipeline for every experiment.

  python paderborn.py B03                   preprocess model/newdata/B03 -> results/paderborn/B03/
  python paderborn.py B01 B03               several
  python paderborn.py B07 --data <folder>   an experiment stored elsewhere

The same steps as b01_preprocess.py (kept unchanged: it made results/B01/ and its report), for any experiment:
  - every data_<EXP>_MXXXX.mat: both accelerometers (accHorizRear_A, accHorizFrontal_C), V -> g (10 g/V);
    per 1.6-s measurement: mean, std, RMS, peak, peak-to-peak, crest, skewness, kurtosis, RMS in 4 bands
    (10 Hz-1 kHz, 1-5 kHz, 5-20 kHz, 20-64 kHz); NEW: the same time-domain statistics of the signal low-pass
    filtered and decimated to 128/3 = 42.67 kHz ("lr_": what a ~42 kHz sensor chain would see, as the Ottawa
    pipeline's 42 kHz);
  - merged with <EXP>_meanTemperatures.csv and <EXP>_operatingConditions.csv in time order;
  - checks: files contiguous and complete, sample count and rate, timestamps, the file <-> row alignment,
    stops (segments), warm-up rows, every condition against the protocol ranges and the log (paderborn_experiments.json).
Writes results/paderborn/<EXP>/<EXP>_processed.csv, checks.json, figures/<EXP>_overview.png.
Nothing is filled in, and no label, failure time or health value is written.
"""
import argparse, json, re
from concurrent.futures import ProcessPoolExecutor
from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import matplotlib.dates as mdates
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import scipy.io as sio
from scipy import signal

HERE = Path(__file__).resolve().parent
META = json.loads((HERE / "paderborn_experiments.json").read_text(encoding="utf-8"))
P = META["protocol"]
FS = P["fs_hz"]
N_SAMPLES = int(FS * P["duration_s"])
CHANNELS = {"A": "accHorizRear_A", "C": "accHorizFrontal_C"}      # A rear, C front (horizontal)
BANDS = [(10, 1000), (1000, 5000), (5000, 20000), (20000, 64000)]
DECIM = 3                                                          # 128 kHz / 3 = 42.67 kHz
GAP_S = 60                                                         # a pause longer than this is a stop


def band_name(lo, hi):
    return f"band_{lo // 1000 if lo >= 1000 else lo}{'k' if lo >= 1000 else ''}_{hi // 1000}k"


def time_stats(x):
    mean = x.mean()
    d = x - mean
    std = np.sqrt((d * d).mean())
    rms = np.sqrt((x * x).mean())
    peak = np.abs(x).max()
    return {"mean": mean, "std": std, "rms": rms, "peak": peak, "p2p": x.max() - x.min(), "crest": peak / rms,
            "skew": (d ** 3).mean() / std ** 3, "kurt": (d ** 4).mean() / std ** 4}


def features(x):
    """One channel (g): the b01_preprocess.py features, then the 42.67-kHz ones."""
    out = time_stats(x)
    d = x - out["mean"]
    spec = np.abs(np.fft.rfft(d)) ** 2
    f = np.fft.rfftfreq(len(d), 1 / FS)
    scale = 2.0 / len(d) ** 2
    for lo, hi in BANDS:
        k = (f >= lo) & (f < hi)
        out[band_name(lo, hi)] = np.sqrt(spec[k].sum() * scale)
    lr = signal.decimate(x, DECIM, ftype="fir", zero_phase=True)     # anti-alias FIR, then every 3rd sample
    out.update({f"lr_{k}": v for k, v in time_stats(lr).items() if k in ("std", "rms", "peak", "crest", "kurt", "skew")})
    return out


def read_one(path):
    m = sio.loadmat(path)
    t = m["measTime"].ravel()
    res = {"n_samples": len(t), "fs_hz": float(1 / np.diff(t).mean()), "finite": True}
    for c, key in CHANNELS.items():
        x = m[key].ravel().astype(np.float64) * P["g_per_v"]
        res["finite"] &= bool(np.isfinite(x).all())
        res.update({f"acc{c}_{k}": float(v) for k, v in features(x).items()})
    return res


def load_csvs(data, exp):
    t = pd.read_csv(data / f"{exp}_meanTemperatures.csv", encoding="latin-1")
    o = pd.read_csv(data / f"{exp}_operatingConditions.csv", encoding="latin-1")
    if len(t) != len(o) or not (t["Time"] == o["Time"]).all():
        raise SystemExit(f"{exp}: the two CSVs' timestamps differ")
    t.columns = ["Time", "T1_C", "T2_C", "Troom_C"]
    o.columns = ["Time", "setDyn_N", "peakDyn_N", "setStat_N", "stat_N", "setSpeed_rpm", "speed_rpm"]
    df = o.join(t[["T1_C", "T2_C", "Troom_C"]])
    df.insert(0, "timestamp", pd.to_datetime(df.pop("Time"), format="%d-%b-%Y %H:%M:%S"))
    return df


def annotate(df, meta):
    gap = df["timestamp"].diff().dt.total_seconds()
    df["gap_before_s"] = gap
    df["segment"] = 1 + (gap > GAP_S).cumsum()
    first = df.groupby("segment")["timestamp"].transform("first")
    df["t_in_segment_s"] = (df["timestamp"] - first).dt.total_seconds()
    w = P["warmup"]
    df["warmup"] = ((df["setSpeed_rpm"] - w["setSpeed_rpm"]).abs() < 1) & (df["setDyn_N"] == w["setDyn_N"]) \
        & ((df["setStat_N"] - w["setStat_N"]).abs() < 1)
    end = pd.Timestamp(meta["log_end"]) + pd.Timedelta(seconds=59) if meta and meta.get("log_end") else None
    df["after_log_end"] = df["timestamp"] > end if end is not None else False
    df["combined_set_N"] = df["setStat_N"] + df["setDyn_N"]
    op = ~df["warmup"]
    lo, hi = P["ranges"]["setSpeed_rpm"]
    df["flag_setSpeed_out_of_log_range"] = op & ((df["setSpeed_rpm"] < lo) | (df["setSpeed_rpm"] > hi))
    df["speed_error_rpm"] = df["speed_rpm"] - df["setSpeed_rpm"]
    df["flag_speed_not_reached"] = df["speed_error_rpm"].abs() > 20
    df["stat_error_N"] = df["stat_N"] - df["setStat_N"]
    df["flag_static_load_off_150N"] = df["stat_error_N"].abs() > 150
    # operating minutes: time since the first record, not counting stops (each stop counts as one nominal interval)
    step = gap.where(gap <= GAP_S, P["pause_s"] + P["duration_s"]).fillna(0)
    df["operating_min"] = step.cumsum() / 60
    return df


def alignment(df):
    """Evidence that M000k belongs to CSV row k: the warm-up -> operation switch (if recorded), and step-to-step
    changes of ln RMS following those of ln speed only at lag 0."""
    v = np.log(df["accA_rms"].to_numpy())
    out = {}
    wu = df["warmup"].to_numpy()
    if wu[0] and not wu.all():
        s = int(np.argmax(~wu))
        out.update({"warmup_rows": s, "logRMS_jump_at_switch": float(v[s] - v[s - 1]),
                    "largest_step_within_warmup": float(np.abs(np.diff(v[:s])).max())})
    else:
        out["warmup_rows"] = int(wu.sum())
    op, seg = ~wu, df["segment"].to_numpy()
    dv, ds = np.diff(v), np.diff(np.log(df["speed_rpm"].to_numpy()))
    ok = op[1:] & op[:-1] & (seg[1:] == seg[:-1])
    corr = {}
    for lag in range(-3, 4):
        k = np.where(ok)[0]
        k = k[(k + lag >= 0) & (k + lag < len(dv))]
        k = k[ok[k + lag]]
        corr[lag] = float(np.corrcoef(dv[k + lag], ds[k])[0, 1])
    out["dlogRMS_vs_dlogSpeed_corr_by_lag"] = corr
    out["best_lag"] = max(corr, key=corr.get)
    # differencing makes neighbouring steps anti-correlated (about -0.5 at lags +-1 when the speed is redrawn every
    # time), so lag 0 is "clear" when it is the largest and more than twice any positive correlation at another lag
    out["lag0_clear"] = out["best_lag"] == 0 and corr[0] > 2 * max(max(c for l, c in corr.items() if l != 0), 0.0)
    return out


def checks(df, ids, vdf_raw, meta):
    ts = df["timestamp"]
    expected = list(range(1, len(df) + 1))
    c = {"n_mat": len(ids), "n_csv_rows": len(df), "missing_ids": sorted(set(expected) - set(ids)),
         "extra_ids": sorted(set(ids) - set(expected)), "ids_contiguous": ids == expected,
         "all_samples_ok": bool((vdf_raw["n_samples"] == N_SAMPLES).all()),
         "fs_hz": sorted(set(vdf_raw["fs_hz"].round(3))), "all_finite": bool(vdf_raw["finite"].all()),
         "timestamps_monotonic": bool(ts.is_monotonic_increasing), "duplicate_timestamps": int(ts.duplicated().sum()),
         "first": str(ts.iloc[0]), "last": str(ts.iloc[-1]),
         "interval_s": {"min": float(df["gap_before_s"].min()), "median": float(df["gap_before_s"].median()),
                        "max": float(df["gap_before_s"].max())},
         "log": meta if meta else "no entry in paderborn_experiments.json (log not transcribed)",
         "stops_over_60s": [{"before_id": int(r.measurement_id), "from": str(ts[i - 1]), "to": str(r.timestamp),
                             "gap_s": float(r.gap_before_s), "T1_before": float(df["T1_C"][i - 1]),
                             "T1_after": float(r.T1_C)} for i, r in df[df["gap_before_s"] > GAP_S].iterrows()],
         "segments": {int(s): {"ids": [int(g.measurement_id.iloc[0]), int(g.measurement_id.iloc[-1])], "n": len(g),
                               "from": str(g.timestamp.iloc[0]), "to": str(g.timestamp.iloc[-1]),
                               "warmup_rows": int(g.warmup.sum()), "T1_start": float(g.T1_C.iloc[0]),
                               "T1_end": float(g.T1_C.iloc[-1]), "T1_max": float(g.T1_C.max())}
                      for s, g in df.groupby("segment")},
         "warmup_recorded": bool(df["warmup"].any()),
         "records_after_log_end": int(df["after_log_end"].sum()),
         "last_record_vs_log_end_s": (float((ts.iloc[-1] - pd.Timestamp(meta["log_end"])).total_seconds())
                                      if meta and meta.get("log_end") else None),
         "T1_max": float(df["T1_C"].max()), "T2_max": float(df["T2_C"].max()),
         "setSpeed_out_of_log_range": int(df["flag_setSpeed_out_of_log_range"].sum()),
         "setSpeed_max": float(df["setSpeed_rpm"].max()), "measured_speed_max": float(df["speed_rpm"].max()),
         "speed_not_reached": int(df["flag_speed_not_reached"].sum()),
         "static_load_off_150N": int(df["flag_static_load_off_150N"].sum()),
         "combined_set_at_4300": int((~df["warmup"] & (df["combined_set_N"].round(3) == 4300)).sum()),
         "combined_set_outside_range": int((~df["warmup"] & ((df["combined_set_N"] < 4300 - 1e-6)
                                                             | (df["combined_set_N"] > 4900 + 1e-6))).sum()),
         "alignment": alignment(df)}
    return c


def plot_overview(df, exp, path, meta):
    BLUE, ORANGE, AQUA, MUTED, INK2 = "#2a78d6", "#eb6834", "#1baf7a", "#8a8984", "#52514e"
    plt.rcParams.update({"font.family": "DejaVu Sans", "font.size": 9, "axes.spines.top": False,
                         "axes.spines.right": False, "axes.grid": True, "grid.color": "#e4e3df", "legend.frameon": False})
    t = df["timestamp"]
    fig, axs = plt.subplots(4, 1, figsize=(9, 9), sharex=True)
    axs[0].plot(t, df["accA_rms"], ".", ms=3.5, color=BLUE, label="rear (A)")
    axs[0].plot(t, df["accC_rms"], ".", ms=3.5, color=ORANGE, label="front (C)")
    axs[0].set_yscale("log")
    axs[0].set_ylabel("Vibration RMS (g)")
    axs[0].legend(loc="lower left", bbox_to_anchor=(0, 1.0), ncol=2)
    axs[1].plot(t, df["T1_C"], ".", ms=3, color=BLUE, label="T1")
    axs[1].plot(t, df["T2_C"], ".", ms=3, color=ORANGE, label="T2")
    axs[1].plot(t, df["Troom_C"], ".", ms=3, color=AQUA, label="room")
    axs[1].set_ylabel("Temperature (°C)")
    axs[1].legend(loc="upper left", ncol=3)
    axs[2].plot(t, df["setSpeed_rpm"], "x", ms=3.5, color=MUTED, label="set")
    axs[2].plot(t, df["speed_rpm"], ".", ms=3.5, color=BLUE, label="measured")
    axs[2].set_ylabel("Speed (rpm)")
    axs[2].legend(loc="lower right", ncol=2)
    axs[3].plot(t, df["stat_N"], ".", ms=3.5, color=BLUE, label="static (measured)")
    axs[3].plot(t, df["peakDyn_N"], ".", ms=3.5, color=ORANGE, label="dynamic amplitude (peak)")
    axs[3].set_ylabel("Load (N)")
    axs[3].legend(loc="center right", ncol=2, fontsize=8)
    for ax in axs:
        for s, g in df.groupby("segment"):
            if s > 1:
                ax.axvline(g.timestamp.iloc[0], color=MUTED, linewidth=0.8, linestyle=":")
        if meta and meta.get("log_end"):
            ax.axvline(pd.Timestamp(meta["log_end"]), color=INK2, linewidth=0.8, linestyle="--")
    axs[3].xaxis.set_major_formatter(mdates.DateFormatter("%H:%M"))
    axs[3].set_xlabel(f"{exp}, {t.iloc[0]:%d %b %Y} (dotted: restarts after stops; dashed: last log entry)")
    fig.tight_layout()
    fig.savefig(path, dpi=160)
    plt.close(fig)


def preprocess(exp, data, out, jobs=8):
    meta = META["experiments"].get(exp)
    name = re.compile(rf"^data_{exp}_M(\d{{4}})\.mat$")
    files = sorted((data / "vibrationData").glob("*.mat"))
    ids = []
    for p in files:
        m = name.match(p.name)
        if not m:
            raise SystemExit(f"unexpected file {p.name}")
        ids.append(int(m.group(1)))
    df = load_csvs(data, exp)
    with ProcessPoolExecutor(jobs) as ex:
        vraw = pd.DataFrame(list(ex.map(read_one, files)))
    vdf = vraw.drop(columns=["n_samples", "fs_hz", "finite"])
    vdf.insert(0, "file", [p.name for p in files])
    vdf.insert(0, "measurement_id", ids)
    if len(vdf) != len(df):
        raise SystemExit(f"{exp}: {len(vdf)} .mat files but {len(df)} CSV rows; not merged (no guessing)")
    df = annotate(pd.concat([vdf, df], axis=1), meta)
    df.insert(0, "experiment", exp)
    c = checks(df, ids, vraw, meta)
    out.mkdir(parents=True, exist_ok=True)
    (out / "figures").mkdir(exist_ok=True)
    df.to_csv(out / f"{exp}_processed.csv", index=False, float_format="%.9g")
    (out / "checks.json").write_text(json.dumps(c, indent=1, default=str) + "\n", encoding="utf-8")
    plot_overview(df, exp, out / "figures" / f"{exp}_overview.png", meta)
    a = c["alignment"]
    print(f"{exp}: {len(df)} measurements, {c['first']} .. {c['last']}, {len(c['segments'])} segment(s), "
          f"warm-up rows {a['warmup_rows']}, alignment lag-0 r = {a['dlogRMS_vs_dlogSpeed_corr_by_lag'][0]:+.2f} "
          f"({'clear' if a['lag0_clear'] else 'NOT clear'}), missing ids {c['missing_ids']}, T1 max {c['T1_max']:.1f} C"
          + ("" if meta else "  [no log entry in paderborn_experiments.json]"))
    return df, c


def load(exp, root=HERE / "results" / "paderborn"):
    return pd.read_csv(root / exp / f"{exp}_processed.csv", parse_dates=["timestamp"])


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("experiments", nargs="+", help="e.g. B01 B03")
    ap.add_argument("--data", type=Path, help="the experiment's folder (default model/newdata/<EXP>; one experiment only)")
    ap.add_argument("--out", type=Path, default=HERE / "results" / "paderborn")
    ap.add_argument("--jobs", type=int, default=8)
    a = ap.parse_args()
    if a.data and len(a.experiments) > 1:
        raise SystemExit("--data takes one experiment")
    for exp in a.experiments:
        preprocess(exp, a.data or HERE / "newdata" / exp, a.out / exp, a.jobs)


if __name__ == "__main__":
    main()
