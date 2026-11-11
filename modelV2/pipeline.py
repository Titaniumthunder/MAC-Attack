"""The host-side pipeline, the same code for Paderborn, Ottawa and live input:
signal chain -> window features -> per-bearing baseline (z-features, detector score) -> network inputs -> status ladder.
Tables use model/anomaly_baseline.py's column convention (accA_<feature>, ln_speed) so its fit() and score() are reused."""
import numpy as np
import pandas as pd
from scipy import signal

import config as c
import anomaly_baseline as ab                      # model/

ab.FSETS["V2"] = c.FEATURES                         # in memory only
NAMES = [n for n, _ in c.FEATURES]
LP = signal.butter(8, c.CUTOFF, fs=c.FS, output="sos")
RESAMPLE = {128000: (21, 64), 64000: (21, 32), 42000: None}


def to_42k(x, fs):
    """DC removed, resampled to 42 kHz (anti-alias FIR), zero-phase low-pass at 15 kHz."""
    x = x - x.mean()
    if RESAMPLE[fs]:
        x = signal.resample_poly(x, *RESAMPLE[fs])
    return signal.sosfiltfilt(LP, x)


def window_features(x):
    """One 1.6-s window of to_42k()'s output."""
    d = x - x.mean()
    rms, peak = np.sqrt((d * d).mean()), np.abs(d).max()
    out = {"rms": rms, "peak": peak, "kurt": (d ** 4).mean() / rms ** 4, "crest": peak / rms}
    spec, f = np.abs(np.fft.rfft(d)) ** 2, np.fft.rfftfreq(len(d), 1 / c.FS)
    for name, (lo, hi) in c.BANDS.items():
        out[name] = np.sqrt(2 * spec[(f >= lo) & (f < hi)].sum()) / len(d)
    return {f"accA_{k}": v for k, v in out.items()}


# ---------- baseline ----------

def baseline(ref, floor=None):
    """The detector fitted on a bearing's healthy reference rows. The ln-rpm term only if the speed varied.
    floor: smallest sigma allowed per feature (a short reference under-estimates the spread)."""
    m = ab.fit(ref, "A", "V2", "speed" if ref.ln_speed.std() > 0.02 else "none")
    if floor is not None:
        m["sigma"] = np.maximum(m["sigma"], floor)
        m["tau"] = float(np.percentile(ab.score(ref, m)[0], ab.Q))
    return m


def commission(d):
    """Where the 100-row healthy reference starts. A step inside it (mean shift of the RMS or 1-5 kHz residual larger
    than STEP_D within-sigma) restarts the reference at the step. Returns (start or None if too few rows, [D per try])."""
    start, Ds = 0, []
    while len(d) >= start + c.REF_N:
        ref = d.iloc[start:start + c.REF_N]
        Z = ab.score(ref, baseline(ref))[1]
        D, k = max((abs(r[k:].mean() - r[:k].mean()) / np.sqrt((r[:k].var() * k + r[k:].var() * (len(r) - k)) / len(r)), k)
                   for r in (Z[:, NAMES.index("rms")], Z[:, NAMES.index("band_1k_5k")]) for k in range(20, 81))
        Ds.append(float(D))
        if D <= c.STEP_D:
            return start, Ds
        start += k
    return None, Ds


# ---------- network inputs ----------

def slog(v):
    return np.sign(v) * np.log1p(np.minimum(np.abs(v), 1e4))


def history(Z):
    """M[i, h-1]: mean of the HIST_FEATURES z over the last h rows of one sequence (rows available only), h = 1..HIST."""
    H = pd.DataFrame(Z[:, [NAMES.index(n) for n in c.HIST_FEATURES]])
    return np.stack([H.rolling(h, min_periods=1).mean().to_numpy() for h in range(1, c.HIST + 1)], axis=1)


def network_inputs(Z, s, rpm, M, h):
    """h: history length per row, 1..HIST (1 = this window only)."""
    m = M[np.arange(len(Z)), np.asarray(h) - 1]
    raw = np.column_stack([Z, 3 * np.log(np.maximum(s, 1e-6)), m, 4 * np.log(np.asarray(rpm) / 2000)])
    return slog(raw).astype(np.float32)


# ---------- targets ----------

def sustained_onset(s, tau, start):
    """First row from `start` that is above tau and after which every 20-row window is at least 80 % above tau."""
    above, n = s > tau, len(s)
    frac = np.array([above[min(k, n - 20):min(k, n - 20) + 20].mean() for k in range(n)])
    ok = (np.minimum.accumulate(frac[::-1])[::-1] >= 0.8) & above & (np.arange(n) >= start)
    return int(np.argmax(ok)) if ok.any() else None


def health_target(s):
    """Health as severity, 1 (healthy) to 0 (end-stage level): how far the detector score is above its healthy level
    now. The score is the median of the last HIST rows, so one odd row does not count. Not a countdown to failure."""
    m = pd.Series(s).rolling(c.HIST, min_periods=1).median().to_numpy()
    return np.clip(1 - np.log(m / c.HEALTH_FULL_AT) / np.log(c.HEALTH_ZERO_AT / c.HEALTH_FULL_AT), 0, 1)


# ---------- host status ----------

def status(s, tau, cls, health_logit):
    """Per row: level (0 Normal, 1 Anomaly, 2 Warning, 3 Failing, latched) and the displayed health % (never rises)."""
    above, level = s > tau, np.zeros(len(s), int)
    run = quiet = fault = 0
    warn = fail = False
    for k in range(len(s)):
        run, quiet = (run + 1, 0) if above[k] else (0, quiet + 1)
        warn = True if run >= c.WARN_N else False if quiet >= c.WARN_CLEAR else warn
        fault = fault + 1 if cls[k] == 2 else 0
        fail = fail or fault >= c.FAIL_N
        level[k] = 3 if fail else 2 if warn else 1 if above[k] else 0
    health = pd.Series(100 / (1 + np.exp(-np.asarray(health_logit, float))))
    return level, np.minimum.accumulate(health.rolling(c.HIST, min_periods=1).median().to_numpy())    # one odd row does not count


def temperature_warning(time, temp):
    """The separate temperature rule (never a network input). On: temp is more than TEMP_RISE_C above its own median
    over the previous TEMP_WINDOW measurements, 3 measurements in a row. The first TEMP_SETTLE_MIN minutes after a start
    or a stop are normal warm-up and are ignored. time: timestamps in order; temp: housing temperature in deg C."""
    time, temp = pd.Series(time).reset_index(drop=True), pd.Series(temp, dtype=float).reset_index(drop=True)
    segment = (time.diff().dt.total_seconds() > 60).cumsum()
    settled = (time - time.groupby(segment).transform("first")).dt.total_seconds() >= 60 * c.TEMP_SETTLE_MIN
    rise = temp - temp.shift(1).rolling(c.TEMP_WINDOW, min_periods=20).median()
    hot = ((rise > c.TEMP_RISE_C) & settled).to_numpy()
    return np.array([k >= 2 and hot[k - 2:k + 1].all() for k in range(len(hot))])
