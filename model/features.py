"""Read every recording once and save the statistics the experiments use.

  python features.py --data "<folder>/University of Ottawa Electric Motor Dataset – Vibr"

The dataset stays where it is (2.5 GB of CSV, README rule 4); only these small tables go into git:
  features/recordings.csv   one row per 10-s recording (128 rows)
  features/windows.csv      one row per 1-s window, 10 per recording (1,280 rows)
  features/speed.csv        one row per recording: the drive command used for f (speed.py), and the fit behind it
  features/tracks.csv       the tracked 1x line of every ramp recording (file, t, hz), for checking the fits
Each row: file, cls, label, speed, load, split (windows also: window, t0, t1, f_hz), then 8 statistics for each of
accelerometers 1, 2 and 3 (a1_mean ... a3_kurt). The microphone and temperature columns are not read.
Values are written exactly (shortest round-trip form), so training from the tables gives the same numbers
as training from the raw data. f_hz is the drive command's mean over the window (speed.py: the nominal command, or
for a ramp the drive clearly did not follow, the fitted ramp-and-hold command). A recording's nominal commanded
frequency comes from dataset.commanded_hz() (E1).
"""
import argparse, csv, time
from concurrent.futures import ProcessPoolExecutor

import numpy as np
from scipy import stats as sps

import speed as spd
from dataset import ACCEL_COLS, FEATURES, FS, HEADER, ROWS, SPEED_HZ, WINDOWS, recordings

STATS = ["mean", "std", "rms", "absmax", "p2p", "crest", "skew", "kurt"]
META = ["file", "cls", "label", "speed", "load", "split"]
COLS = [f"a{a}_{s}" for a in ACCEL_COLS for s in STATS]
SPEED_COLS = ["profile", "t_start", "t_end", "fit_t_start", "fit_t_end", "fit_mae_hz", "fit_dev_hz", "measured_1x_hz"]


def stats(x):
    """The 8 statistics along the second-to-last axis of x (..., samples, channels), in float64:
    mean, population std, RMS, max|x|, peak-to-peak, crest = max|x| / max(RMS, 1e-12),
    skewness m3 / std^3 and Pearson kurtosis m4 / std^4 (both 0 where std <= 1e-12).
    Returns (..., channels, 8)."""
    mean = x.mean(axis=-2)
    d = x - mean[..., None, :]
    std = np.sqrt((d * d).mean(axis=-2))
    rms = np.sqrt((x * x).mean(axis=-2))
    absmax = np.abs(x).max(axis=-2)
    p2p = x.max(axis=-2) - x.min(axis=-2)
    crest = absmax / np.maximum(rms, 1e-12)
    flat = std <= 1e-12
    s = np.where(flat, 1.0, std)
    skew = np.where(flat, 0.0, (d ** 3).mean(axis=-2) / s ** 3)
    kurt = np.where(flat, 0.0, (d ** 4).mean(axis=-2) / s ** 4)
    return np.stack([mean, std, rms, absmax, p2p, crest, skew, kurt], axis=-1)


MODEL_STATS = ("std", "rms", "absmax", "p2p", "crest", "skew", "kurt")   # the model's 7 per accelerometer (no mean)
LOG_STATS = ("std", "rms", "absmax", "p2p")                              # amplitudes, used as ln


def vibration_inputs(x):
    """One accelerometer's 1-s window (FS samples, m/s^2) -> its 7 model inputs, in the model's order:
    ln std, ln RMS, ln max|x|, ln peak-to-peak, crest, skewness, kurtosis (train.log_inputs on the tables)."""
    s = dict(zip(STATS, stats(np.asarray(x, np.float64).reshape(-1, 1))[0]))
    return np.array([np.log(s[k]) if k in LOG_STATS else s[k] for k in MODEL_STATS])


def drive_inputs(f_hz):
    """The drive's commanded frequency (Hz, from the drive, not a shaft-speed sensor) -> [ln f]."""
    return np.array([np.log(f_hz)])


def window_inputs(accel, f_hz, extra=()):
    """The board-side input vector of one 1-s window for the single-accelerometer models: the vibration inputs of the
    one accelerometer, then ln f, then any later sensor groups in `extra` (arrays, e.g. temperature or measured RPM
    features: not used yet, no model is trained with them). Order = model.json's "inputs"."""
    return np.concatenate([vibration_inputs(accel), drive_inputs(f_hz), *extra])


def read(path):
    """Accelerometers 1, 2, 3 of one recording: ROWS x 3 float64. The header starts with a byte-order mark."""
    with open(path, encoding="utf-8-sig") as f:
        header = f.readline().rstrip("\r\n").split(",")
    if header != HEADER:
        raise SystemExit(f"{path.name}: unexpected header {header}")
    x = np.loadtxt(path, delimiter=",", skiprows=1, usecols=list(ACCEL_COLS.values()), encoding="utf-8-sig")
    if x.shape != (ROWS, len(ACCEL_COLS)) or not np.isfinite(x).all():
        raise SystemExit(f"{path.name}: {x.shape} values, expected {ROWS} x {len(ACCEL_COLS)}, all finite")
    return x


def one(path, speed):
    """Read one file (once) and return its recording and window statistics, the largest relative difference from
    SciPy's std, skewness and kurtosis (a check of stats()), and from accelerometers 2 and 3 the tracked 1x line
    (ramps) or the measured 1x frequency (constant speeds)."""
    x = read(path)
    rec, win = stats(x), stats(x.reshape(WINDOWS, FS, x.shape[1]))
    ref = np.stack([x.std(axis=0), sps.skew(x, axis=0), sps.kurtosis(x, axis=0, fisher=False)], axis=-1)
    diff = np.max(np.abs(rec[:, [1, 6, 7]] - ref) / np.maximum(np.abs(ref), 1e-300))
    a23 = x[:, [list(ACCEL_COLS).index(2), list(ACCEL_COLS).index(3)]]
    a, b = SPEED_HZ[speed]
    line = spd.track(a23) if a != b else spd.steady_hz(a23, a)
    return rec, win, float(diff), line


def check_windows(rec, win):
    """The windows must add back up to their recording: mean, variance (law of total variance over equal
    windows), RMS and max|x|. Returns the largest relative error."""
    i = {s: STATS.index(s) for s in STATS}
    got = [win[:, :, i["mean"]].mean(axis=0),
           (win[:, :, i["std"]] ** 2).mean(axis=0) + win[:, :, i["mean"]].var(axis=0),
           np.sqrt((win[:, :, i["rms"]] ** 2).mean(axis=0)),
           win[:, :, i["absmax"]].max(axis=0)]
    want = [rec[:, i["mean"]], rec[:, i["std"]] ** 2, rec[:, i["rms"]], rec[:, i["absmax"]]]
    return max(float(np.max(np.abs(g - w) / np.maximum(np.abs(w), 1e-12))) for g, w in zip(got, want))


def write(path, header, rows):
    with open(path, "w", newline="") as f:
        w = csv.writer(f, lineterminator="\n")
        w.writerow(header)
        w.writerows(rows)


def loudness(recs, out):
    """Healthy against faulty RMS per speed code (both loads); ratio = quietest faulty / loudest healthy."""
    print("\n  RMS (m/s^2) per speed code, accelerometers 2 and 3: healthy (2 loads) vs every faulty recording (14)")
    print("  speed   a2 healthy      a2 faulty min..max   ratio   a3 healthy      a3 faulty min..max   ratio")
    k = STATS.index("rms")
    for sp in range(1, 9):
        line = f"  {sp}     "
        for a in (2, 3):
            c = list(ACCEL_COLS).index(a)
            h = [o[0][c, k] for o, r in zip(out, recs) if r["speed"] == sp and r["label"] == 0]
            f = [o[0][c, k] for o, r in zip(out, recs) if r["speed"] == sp and r["label"] == 1]
            line += f"  {min(h):5.3f}..{max(h):5.3f}   {min(f):6.3f}..{max(f):6.3f}   {min(f) / max(h):5.2f}x"
        print(line)


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--data", required=True, help="the dataset's top folder (quote it: the name has spaces and an en dash)")
    ap.add_argument("--jobs", type=int, default=8, help="files read in parallel (default 8)")
    a = ap.parse_args()
    recs = recordings(a.data)
    t = time.time()
    with ProcessPoolExecutor(a.jobs) as ex:
        out = list(ex.map(one, [r["path"] for r in recs], [r["speed"] for r in recs]))
    secs = time.time() - t
    sci = max(o[2] for o in out)
    win = max(check_windows(o[0], o[1]) for o in out)
    if sci > 1e-9 or win > 1e-9:
        raise SystemExit(f"Check failed: SciPy difference {sci:.2e}, window recombination {win:.2e}")

    prof = []
    for r, o in zip(recs, out):
        if isinstance(o[3], float):
            prof.append(["nominal", 0.0, 10.0, "", "", "", "", o[3]])
        else:
            ts, te, src, fit = spd.profile(r["speed"], *o[3])
            prof.append([src, ts, te, *fit, ""])

    FEATURES.mkdir(exist_ok=True)
    meta = lambda r: [r[k] for k in META]
    write(FEATURES / "recordings.csv", META + COLS,
          [meta(r) + [float(v) for v in o[0].ravel()] for r, o in zip(recs, out)])
    write(FEATURES / "windows.csv", META + ["window", "t0", "t1", "f_hz"] + COLS,
          [meta(r) + [w, w, w + 1, spd.window_hz(r["speed"], p[1], p[2], w, w + 1)]
           + [float(v) for v in o[1][w].ravel()]
           for r, o, p in zip(recs, out, prof) for w in range(WINDOWS)])
    write(FEATURES / "speed.csv", META + SPEED_COLS, [meta(r) + p for r, p in zip(recs, prof)])
    write(FEATURES / "tracks.csv", ["file", "t", "hz"],
          [[r["file"], float(tt), float(hz)] for r, o in zip(recs, out) if not isinstance(o[3], float)
           for tt, hz in zip(*o[3])])
    print(f"{len(recs)} recordings read once in {secs:.1f} s ({a.jobs} at a time), "
          f"{len(recs) * WINDOWS} windows of {FS} samples")
    print(f"  checks: std, skewness, kurtosis vs SciPy within {sci:.1e}; windows recombine to "
          f"their recording within {win:.1e}")
    print(f"  wrote recordings.csv, windows.csv, speed.csv and tracks.csv in {FEATURES}")
    fitted = [(r["file"], p) for r, p in zip(recs, prof) if p[0] == "fitted"]
    devs = sorted(p[6] for p in prof if p[6] != "")
    print(f"\n  ramp commands: {len(fitted)} of {len(devs)} ramp recordings use the fitted command "
          f"(more than {spd.TOLERANCE_HZ} Hz from the nominal ramp); largest distance among the others "
          f"{max(d for d in devs if d <= spd.TOLERANCE_HZ):.2f} Hz")
    for n, p in fitted:
        print(f"    {n:12s} ramp {p[1]:+.2f} s -> {p[2]:.2f} s (nominal 0 -> 10 s), {p[6]:.2f} Hz from nominal, "
              f"fit error {p[5]:.2f} Hz")
    loudness(recs, out)


if __name__ == "__main__":
    main()
