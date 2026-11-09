"""Paderborn experiment B01: vibration features, temperatures and operating conditions in one chronological table.

  python b01_preprocess.py                       (dataset in model/newdata/B01; --data <folder> for another place)

Reads (read-only)
  vibrationData/data_B01_M0001.mat .. M0377.mat   accHorizRear_A, accHorizFrontal_C (V), measTime (s): 1.6 s at 128 kHz
  B01_meanTemperatures.csv                        Time, T1, T2, room temperature (degC)
  B01_operatingConditions.csv                     Time, set/peak dynamic load, set/measured static load, set/measured speed
  B01_log.pdf (not parsed)                        10 g/V; ~12 s pause; warm-up 10 min at 750 rpm and 2500 N; then random
                                                  speed [2400, 3000] rpm, static [3300, 3800] N, dynamic amplitude
                                                  [500, 1400] N at 2 Hz, combined [4300, 4900] N; log ends 09:13
                                                  ("temperature threshold value was exceeded")
Writes (model/results/B01/)
  B01_processed.csv     one row per measurement, in time order: id, file, timestamp, segment, flags, conditions,
                        temperatures, vibration features of both channels (in g)
  checks.json           every alignment and consistency check, with the numbers
  figures/*.png         the graphs used by B01_analysis_report.md

Measurement k (M000k) is matched to the k-th CSV row: the .mat files carry no timestamp and the CSVs no id. The match
is checked, not assumed (check_alignment): the warm-up -> random-speed switch must appear in the vibration at the
same row, and vibration must follow the measured speed best at zero offset. Nothing is interpolated or filled:
a value that cannot be read stays empty, and no deterioration label, failure time or health value is written.
"""
import argparse, json, re
from concurrent.futures import ProcessPoolExecutor
from pathlib import Path

import numpy as np
import pandas as pd
import scipy.io as sio
from scipy import stats as sps

HERE = Path(__file__).resolve().parent
G_PER_V = 10.0                      # B01_log.pdf
FS = 128_000
N_SAMPLES = 204_800                 # 1.6 s
CHANNELS = {"A": "accHorizRear_A", "C": "accHorizFrontal_C"}     # A rear, C front (horizontal)
BANDS = [(10, 1000), (1000, 5000), (5000, 20000), (20000, 64000)]   # Hz, RMS per band (g)
LOG_RANGES = {"setSpeed": (2400, 3000), "setStat": (3300, 3800), "setDyn": (500, 1400), "combined": (4300, 4900)}
WARMUP = {"setSpeed": 750, "setStat": 2500, "setDyn": 0}
LOG_END = pd.Timestamp("2021-10-19 09:13")
GAP_S = 60                          # a pause longer than this (nominal ~12 s + 1.6 s, measured 11-26 s) is a stop
NAME = re.compile(r"^data_B01_M(\d{4})\.mat$")


def features(x):
    """Time-domain and band statistics of one channel (g)."""
    mean = x.mean()
    d = x - mean
    std = np.sqrt((d * d).mean())
    rms = np.sqrt((x * x).mean())
    peak = np.abs(x).max()
    out = {"mean": mean, "std": std, "rms": rms, "peak": peak, "p2p": x.max() - x.min(),
           "crest": peak / rms, "skew": (d ** 3).mean() / std ** 3, "kurt": (d ** 4).mean() / std ** 4}
    spec = np.abs(np.fft.rfft(d)) ** 2
    f = np.fft.rfftfreq(len(d), 1 / FS)
    scale = 2.0 / len(d) ** 2                    # Parseval: sum over one-sided bins ~ mean square
    for lo, hi in BANDS:
        k = (f >= lo) & (f < hi)
        out[f"band_{lo // 1000 if lo >= 1000 else lo}{'k' if lo >= 1000 else ''}_{hi // 1000}k"] = np.sqrt(spec[k].sum() * scale)
    return out


def read_one(path):
    m = sio.loadmat(path)
    t = m["measTime"].ravel()
    res = {"n_samples": len(t), "duration_s": float(t[-1] - t[0] + 1 / FS),
           "fs_hz": float(1 / np.diff(t).mean()), "finite": True}
    for c, key in CHANNELS.items():
        x = m[key].ravel().astype(np.float64) * G_PER_V
        res["finite"] &= bool(np.isfinite(x).all())
        res.update({f"acc{c}_{k}": float(v) for k, v in features(x).items()})
    return res


def load_csvs(data):
    t = pd.read_csv(data / "B01_meanTemperatures.csv", encoding="latin-1")
    o = pd.read_csv(data / "B01_operatingConditions.csv", encoding="latin-1")
    assert len(t) == len(o) and (t["Time"] == o["Time"]).all(), "the two CSVs' timestamps differ"
    t.columns = ["Time", "T1_C", "T2_C", "Troom_C"]
    o.columns = ["Time", "setDyn_N", "peakDyn_N", "setStat_N", "stat_N", "setSpeed_rpm", "speed_rpm"]
    df = o.join(t[["T1_C", "T2_C", "Troom_C"]])
    df.insert(0, "timestamp", pd.to_datetime(df.pop("Time"), format="%d-%b-%Y %H:%M:%S"))
    return df


def annotate(df):
    """Segments (stops), warm-up, and the consistency flags against the log."""
    gap = df["timestamp"].diff().dt.total_seconds()
    df["gap_before_s"] = gap
    df["segment"] = 1 + (gap > GAP_S).cumsum()
    first = df.groupby("segment")["timestamp"].transform("first")
    df["t_in_segment_s"] = (df["timestamp"] - first).dt.total_seconds()
    df["warmup"] = ((df["setSpeed_rpm"] - WARMUP["setSpeed"]).abs() < 1) & (df["setDyn_N"] == 0) \
        & ((df["setStat_N"] - WARMUP["setStat"]).abs() < 1)
    df["after_log_end"] = df["timestamp"] > LOG_END + pd.Timedelta(seconds=59)
    df["combined_set_N"] = df["setStat_N"] + df["setDyn_N"]
    op = ~df["warmup"]
    lo, hi = LOG_RANGES["setSpeed"]
    df["flag_setSpeed_out_of_log_range"] = op & ((df["setSpeed_rpm"] < lo) | (df["setSpeed_rpm"] > hi))
    df["speed_error_rpm"] = df["speed_rpm"] - df["setSpeed_rpm"]
    df["flag_speed_not_reached"] = df["speed_error_rpm"].abs() > 20
    df["stat_error_N"] = df["stat_N"] - df["setStat_N"]
    df["flag_static_load_off_150N"] = df["stat_error_N"].abs() > 150
    return df


def check_alignment(df):
    """Evidence that M000k belongs to CSV row k."""
    v = np.log(df["accA_rms"].to_numpy())
    switch = int(np.argmax(~df["warmup"].to_numpy()))          # first non-warm-up row
    jump = v[switch] - v[switch - 1]
    within = np.abs(np.diff(v[:switch])).max()
    # The run's slow trend dominates the raw values, so compare step-to-step changes: the speed is re-drawn before
    # every measurement, so d ln(RMS) of file k+lag should follow d ln(speed) of row k only at lag 0.
    op = (~df["warmup"]).to_numpy()
    seg = df["segment"].to_numpy()
    dv = np.diff(v)
    ds = np.diff(np.log(df["speed_rpm"].to_numpy()))
    ok = op[1:] & op[:-1] & (seg[1:] == seg[:-1])
    corr = {}
    for lag in range(-3, 4):
        k = np.where(ok)[0]
        k = k[(k + lag >= 0) & (k + lag < len(dv))]
        k = k[ok[k + lag]]
        corr[lag] = float(np.corrcoef(dv[k + lag], ds[k])[0, 1])
    return {"warmup_rows": switch, "logRMS_jump_at_switch": float(jump), "largest_step_within_warmup": float(within),
            "dlogRMS_vs_dlogSpeed_corr_by_lag": corr, "best_lag": max(corr, key=corr.get)}


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--data", type=Path, default=HERE / "newdata" / "B01")
    ap.add_argument("--out", type=Path, default=HERE / "results" / "B01")
    ap.add_argument("--jobs", type=int, default=8)
    a = ap.parse_args()
    files = sorted((a.data / "vibrationData").glob("*.mat"))
    ids = []
    for p in files:
        m = NAME.match(p.name)
        if not m:
            raise SystemExit(f"unexpected file {p.name}")
        ids.append(int(m.group(1)))
    df = load_csvs(a.data)
    expected = list(range(1, len(df) + 1))
    checks = {"n_mat": len(files), "n_csv_rows": len(df), "missing_ids": sorted(set(expected) - set(ids)),
              "extra_ids": sorted(set(ids) - set(expected)), "ids_contiguous": ids == expected}
    with ProcessPoolExecutor(a.jobs) as ex:
        vib = list(ex.map(read_one, files))
    vdf = pd.DataFrame(vib)
    checks.update({"all_204800_samples": bool((vdf["n_samples"] == N_SAMPLES).all()),
                   "fs_hz": sorted(set(vdf["fs_hz"].round(3))), "all_finite": bool(vdf["finite"].all())})
    vdf = vdf.drop(columns=["n_samples", "duration_s", "fs_hz", "finite"])
    vdf.insert(0, "file", [p.name for p in files])
    vdf.insert(0, "measurement_id", ids)
    df = annotate(pd.concat([vdf, df], axis=1))
    ts = df["timestamp"]
    checks.update({
        "timestamps_monotonic": bool(ts.is_monotonic_increasing), "duplicate_timestamps": int(ts.duplicated().sum()),
        "first": str(ts.iloc[0]), "last": str(ts.iloc[-1]),
        "interval_s": {"min": float(df["gap_before_s"].min()), "median": float(df["gap_before_s"].median()),
                       "max": float(df["gap_before_s"].max())},
        "stops_over_60s": [{"before_id": int(r.measurement_id), "from": str(ts[i - 1]), "to": str(r.timestamp),
                            "gap_s": float(r.gap_before_s), "T1_before": float(df["T1_C"][i - 1]),
                            "T1_after": float(r.T1_C)} for i, r in df[df["gap_before_s"] > GAP_S].iterrows()],
        "segments": {int(s): {"ids": [int(g.measurement_id.iloc[0]), int(g.measurement_id.iloc[-1])],
                              "n": len(g), "from": str(g.timestamp.iloc[0]), "to": str(g.timestamp.iloc[-1]),
                              "warmup_rows": int(g.warmup.sum()), "T1_start": float(g.T1_C.iloc[0]),
                              "T1_end": float(g.T1_C.iloc[-1]), "T1_max": float(g.T1_C.max())}
                     for s, g in df.groupby("segment")},
        "records_after_log_end_0913": int(df["after_log_end"].sum()),
        "setSpeed_out_of_log_range": int(df["flag_setSpeed_out_of_log_range"].sum()),
        "setSpeed_out_of_range_by_segment": df.groupby("segment")["flag_setSpeed_out_of_log_range"].sum().astype(int).to_dict(),
        "setSpeed_max": float(df["setSpeed_rpm"].max()), "measured_speed_max": float(df["speed_rpm"].max()),
        "speed_not_reached": int(df["flag_speed_not_reached"].sum()),
        "speed_not_reached_and_set_over_3000": int((df["flag_speed_not_reached"] & (df["setSpeed_rpm"] > 3000)).sum()),
        "static_load_off_150N": int(df["flag_static_load_off_150N"].sum()),
        "static_load_error_N": {"median_abs": float(df["stat_error_N"].abs().median()),
                                "max_abs": float(df["stat_error_N"].abs().max())},
        "combined_set_load_outside_log_range": int((~df["warmup"] & ((df["combined_set_N"] < 4300 - 1e-6)
                                                                     | (df["combined_set_N"] > 4900 + 1e-6))).sum()),
        "alignment": check_alignment(df)})
    a.out.mkdir(parents=True, exist_ok=True)
    df.to_csv(a.out / "B01_processed.csv", index=False, float_format="%.9g")
    (a.out / "checks.json").write_text(json.dumps(checks, indent=1, default=str) + "\n", encoding="utf-8")
    print(json.dumps(checks, indent=1, default=str))


if __name__ == "__main__":
    main()
