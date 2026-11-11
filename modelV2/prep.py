"""Data prep: raw Paderborn and Ottawa recordings -> feature tables -> baselines -> modelV2/data/rows.npz and folds.json.

  model/.venv/bin/python modelV2/prep.py

Feature tables are cached in modelV2/data/ (delete a CSV to recompute it). Locked bearings are refused.
"""
import json, re
from concurrent.futures import ProcessPoolExecutor

import numpy as np
import pandas as pd
import scipy.io as sio

import config as c
import pipeline as F
import anomaly_baseline as ab                      # model/
import labels as lb                                # model/: the documented end-stage rule
import paderborn as pb                             # model/: CSV readers and row annotation

OTT_FOLDER = {"inner": ("2_Inner_Race_Faults", "I"), "outer": ("3_Outer_Race_Faults", "O"),
              "ball": ("4_Ball_Faults", "B"), "cage": ("5_Cage_Faults", "C")}


def pad_file(path):
    m = sio.loadmat(path, variable_names=["measTime", "accHorizRear_A"])
    fs = min(F.RESAMPLE, key=lambda n: abs(n - 1 / np.diff(m["measTime"].ravel()).mean()))
    x = F.to_42k(m["accHorizRear_A"].ravel().astype(float) * pb.P["g_per_v"], fs)
    if len(x) != c.WIN:
        raise ValueError(f"{path}: {len(x)} samples at 42 kHz, expected {c.WIN}")
    return F.window_features(x)


def mat_files(folder, exp):
    """The bearing's .mat files in measurement order (by number: names have 4 or 5 digits), checked to be 1..n."""
    num = lambda p: int(re.fullmatch(rf"data_{exp}_M(\d{{4,5}})\.mat", p.name).group(1))
    files = sorted((folder / "vibrationData").glob("*.mat"), key=num)
    ids = [num(p) for p in files]
    if ids != list(range(1, len(ids) + 1)):
        raise SystemExit(f"{exp}: measurement ids are not 1..{len(ids)}")
    return files, ids


def paderborn_table(exp):
    """One row per measurement: the 42-kHz rear-accelerometer features merged with the rig's CSVs."""
    c.assert_unlocked([exp])
    cache = c.DATA / f"paderborn_{exp}.csv"
    if cache.exists():
        return pd.read_csv(cache, parse_dates=["timestamp"])
    folder = c.PADERBORN_RAW / exp
    files, ids = mat_files(folder, exp)
    df = pb.load_csvs(folder, exp)
    if len(files) != len(df):
        raise SystemExit(f"{exp}: {len(files)} .mat files but {len(df)} CSV rows")
    with ProcessPoolExecutor(8) as ex:
        feats = pd.DataFrame(list(ex.map(pad_file, files, chunksize=16)))
    feats.insert(0, "measurement_id", ids)
    df = pb.annotate(pd.concat([feats, df], axis=1), pb.META["experiments"].get(exp))
    df.insert(0, "experiment", exp)
    df.to_csv(c.writable(cache), index=False, float_format="%.9g")
    return df


def ottawa_file(n, stage):
    folder, letter = ("1_Healthy", "H") if stage == 0 else OTT_FOLDER[c.OTT_TYPE[n]]
    return c.OTTAWA_RAW / folder / f"{letter}_{n}_{stage}.mat"


def ottawa_table(bearings=c.OTT_DEV):
    """One row per 1.6-s window (50 % overlap). role: baseline (first 5 s of the healthy recording), healthy (last
    5 s), skip (the window across the middle), or stage (a stage-1 or stage-2 recording)."""
    c.assert_unlocked(bearings)
    cache = c.DATA / "ottawa.csv"
    if cache.exists() and bearings == c.OTT_DEV:
        return pd.read_csv(cache)
    rows = []
    for n in bearings:
        for stage in (0, 1, 2):
            p = ottawa_file(n, stage)
            a = sio.loadmat(p)[p.stem]              # Accelerometer, Acoustic, Speed, Load, Temperature Difference
            x, half = F.to_42k(a[:, 0], c.FS), len(a) // 2
            for w, i in enumerate(range(0, len(x) - c.WIN + 1, c.WIN // 2)):
                role = "stage" if stage else "baseline" if i + c.WIN <= half else "healthy" if i >= half else "skip"
                rows.append({"bearing": n, "stage": stage, "win": w, "role": role, "speed_rpm": a[0, 2],
                             "temp_diff": a[i:i + c.WIN, 4].mean(), **F.window_features(x[i:i + c.WIN])})
    df = pd.DataFrame(rows)
    df["ln_speed"] = np.log(df.speed_rpm)
    if bearings == c.OTT_DEV:
        df.to_csv(c.writable(cache), index=False, float_format="%.9g")
    return df


def paderborn_rows(exp, table, floor, end_labels=True):
    """Baseline, scores, labels and targets of one bearing, from the start of its healthy reference."""
    d = ab.prepare(table)
    start, Ds = F.commission(d)
    d = d.iloc[start:].reset_index(drop=True)
    m = F.baseline(d.iloc[:c.REF_N], floor)
    s, Z = ab.score(d, m)
    n = len(d)
    y = np.full(n, -1)
    y[:c.REF_N + c.HOLD_N] = 0
    if end_labels:                                  # model/labels.py decides whether the recording ends at a documented stop
        y[lb.label(exp, full=table, end_n=c.END_N)[0].y_det.to_numpy()[start:] == 1] = 2
    else:
        y[-c.END_N:] = 2
    onset = F.sustained_onset(s, m["tau"], c.REF_N + c.HOLD_N) or n - c.END_N
    info = {"rows": n, "reference_start": int(start), "step_D": Ds, "tau": m["tau"], "sigma": m["sigma"].tolist(),
            "rpm_term": m["cond"] == "speed", "onset_row": int(onset),
            "end_score_over_tau": float(np.median(s[-c.END_N:]) / m["tau"]),     # how far the end stage is from the baseline
            "onset_min_before_end": float(d.operating_min.iloc[-1] - d.operating_min.iloc[onset])}
    return {"ds": np.zeros(n, int), "bearing": np.full(n, exp), "seq": np.zeros(n, int), "k": np.arange(n), "Z": Z,
            "s": s, "tau": np.full(n, m["tau"]), "rpm": d.speed_rpm.to_numpy(), "M": F.history(Z), "y": y,
            "health": F.health_target(s), "post": np.arange(n) >= onset, "minutes": d.operating_min.to_numpy(),
            "mid": d.measurement_id.to_numpy()}, info


def ottawa_rows(n, t, floor):
    """t: the windows of one bearing. Every window is scored against the bearing's own healthy baseline."""
    m = F.baseline(t[t.role == "baseline"], floor)
    s, Z = ab.score(t, m)
    keep = t.role.isin(["healthy", "stage"]).to_numpy()
    # history within a recording, over the kept windows only (not the baseline windows the z-values were fitted on)
    M = np.concatenate([F.history(Z[keep & (t.stage == st).to_numpy()]) for st in (0, 1, 2)])
    k = int(keep.sum())
    return {"ds": np.ones(k, int), "bearing": np.full(k, f"U{n:02d}"), "seq": t.stage.to_numpy()[keep],
            "k": t.win.to_numpy()[keep], "Z": Z[keep], "s": s[keep], "tau": np.full(k, m["tau"]),
            "rpm": t.speed_rpm.to_numpy()[keep], "M": M, "y": t.stage.to_numpy()[keep],
            "health": np.full(k, np.nan), "post": np.zeros(k, bool), "minutes": np.zeros(k), "mid": np.zeros(k, int)}


def folds(pad, ott=c.OTT_DEV):
    """Leave one Paderborn bearing out per fold; the Ottawa bearings are dealt round the folds, fault types interleaved."""
    by_type = [[n for n in ott if c.OTT_TYPE[n] == t] for t in OTT_FOLDER]
    order = [(i, g[i]) for i in range(max(map(len, by_type))) for g in by_type if i < len(g)]
    # (j + i): without it, 4 folds and 4 fault types would hold out one whole fault type per fold
    return [{"pad": b, "ott": [f"U{n:02d}" for j, (i, n) in enumerate(order) if (j + i) % len(pad) == f]}
            for f, b in enumerate(pad)]


def main():
    have = [b for b in c.PAD_DEV if (c.DATA / f"paderborn_{b}.csv").exists() or (c.PADERBORN_RAW / b).exists()]
    missing = [b for b in c.PAD_DEV if b not in have]
    if not c.OTTAWA_RAW.exists():
        raise SystemExit(f"Ottawa UORED-VAFCLS not found: put its folder (or a link to it) at {c.RAW / 'ottawa'}")
    tables = {b: paderborn_table(b) for b in have}
    floor = np.array(c.SIGMA_FLOOR)
    parts, info = [], {"sigma_floor": dict(zip(F.NAMES, floor.tolist())), "paderborn": {}, "missing": missing}
    for b, t in tables.items():
        rows, info["paderborn"][b] = paderborn_rows(b, t, floor)
        parts.append(rows)
    ott = ottawa_table()
    parts += [ottawa_rows(n, t.reset_index(drop=True), floor) for n, t in ott.groupby("bearing")]
    rows = {k: np.concatenate([p[k] for p in parts]) for k in parts[0]}
    np.savez(c.writable(c.DATA / "rows.npz"), **rows)
    rec = ott.groupby(["bearing", "stage"]).temp_diff.agg(["min", "max", "median"]).reset_index()
    bad = rec[(rec[["min", "max"]].abs() > 1000).any(axis=1)]                # not physical: a corrupt recording
    info["ottawa_temperature"] = {
        "column": "Temperature Difference (not used by the model)",
        "median_by_stage": rec[~rec.index.isin(bad.index)].groupby("stage")["median"].median().round(1).to_dict(),
        "corrupt_recordings": [f"bearing {r.bearing} stage {r.stage}" for r in bad.itertuples()]}
    info["counts"] = {f"{'paderborn' if ds == 0 else 'ottawa'} class {y}": int(((rows["ds"] == ds) & (rows["y"] == y)).sum())
                      for ds in (0, 1) for y in (-1, 0, 1, 2)}
    c.writable(c.DATA / "summary.json").write_text(json.dumps(info, indent=1) + "\n")
    c.writable(c.DATA / "folds.json").write_text(json.dumps(folds(have), indent=1) + "\n")
    for b, i in info["paderborn"].items():
        print(f"{b}: {i['rows']} rows, reference starts at row {i['reference_start']} (step D {max(i['step_D'][:1]):.1f}), "
              f"onset row {i['onset_row']} ({i['onset_min_before_end']:.0f} min before the end), "
              f"end-stage score {i['end_score_over_tau']:.1f} x threshold")
    print("rows per class:", info["counts"])
    print("Ottawa temperature:", info["ottawa_temperature"])
    if missing:
        print(f"\nMISSING raw data: {missing}. Put each bearing's folder in {c.PADERBORN_RAW}/ and run prep again.")


if __name__ == "__main__":
    main()
