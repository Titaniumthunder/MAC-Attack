"""The drive frequency during each 1-s window (E2 needs f per window).

The speed code gives the nominal command: constant, or a linear ramp from a to b over the 10 s. The spectrograms show
that most ramp recordings follow it, but some do not: the drive ramped faster and then held, or the recording started
in the middle of the ramp. So for each ramp recording:
  1. track()       follows the shaft-rotation line (1x) in the spectrogram of accelerometers 2 and 3;
  2. fit_command() fits a ramp-and-hold command to it: a until t_start, linear to b at t_end, then b. Only the two
                   times are fitted; the levels a and b stay the speed code's values;
  3. if that command leaves the nominal ramp by more than TOLERANCE_HZ anywhere in the 10 s, the recording uses it;
     otherwise it uses the nominal ramp.
Constant speed codes always use the nominal frequency.

The measured 1x frequency itself is never an input: it includes the motor's slip, and the one healthy motor runs
slightly faster than most faulty recordings at each constant speed, and at 60 Hz faster than every one (59.8 against
at most 59.23 Hz), so it would identify the motor.
Fixing the levels at the commanded values, and using the fitted timing only where the drive clearly did not follow the
nominal ramp, keeps the slip out of f.
"""
import numpy as np
from scipy.ndimage import maximum_filter1d, median_filter
from scipy.signal import spectrogram

from dataset import FS, SECONDS, SPEED_HZ

SEG, HOP = 0.5, 0.05              # spectrogram segment and hop (s); bins of 0.5 Hz after 4x zero padding
F_LO, F_HI, F_STEP = 10.0, 66.0, 0.25   # candidate 1x frequencies (Hz)
HARMONICS = 3                     # the 1x line scored with its 2x and 3x lines
MAX_STEP = 0.5                    # largest change of the 1x line from one hop to the next (Hz), i.e. 10 Hz/s
TOLERANCE_HZ = 4.0                # a fitted command further than this from the nominal ramp replaces it


def track(x):
    """The 1x line of one recording: (times, Hz), one value per hop. x: (samples, channels), accelerometers 2 and 3.
    Each channel's log spectrogram minus its running median over +-4 Hz shows the lines; a candidate f0 scores the sum
    over both channels of its first HARMONICS harmonics, and the best path (Viterbi, at most MAX_STEP per hop) is kept."""
    n = int(SEG * FS)
    lines = 0.0
    for c in range(x.shape[1]):
        f, t, S = spectrogram(x[:, c] - x[:, c].mean(), fs=FS, nperseg=n, noverlap=n - int(HOP * FS), nfft=4 * n)
        keep = f <= HARMONICS * F_HI + 10.0
        f, L = f[keep], np.log(S[keep] + 1e-30)
        lines = lines + np.maximum(L - median_filter(L, size=(int(8 / (f[1] - f[0])) + 1, 1), mode="nearest"), 0.0)
    df = f[1] - f[0]
    # allow one bin (0.5 Hz) either side of each harmonic's nearest bin. With ties going to the lower candidate, the
    # track reads 0 to 0.25 Hz low (found 27 Oct; left as is: E2 and E3 were run with these tracks)
    near = maximum_filter1d(lines, size=3, axis=0)
    grid = np.arange(F_LO, F_HI + F_STEP / 2, F_STEP)
    score = sum(near[np.rint(k * grid / df).astype(int)] for k in range(1, HARMONICS + 1))   # (grid, times)
    w = int(round(MAX_STEP / F_STEP))
    best, back = score[:, 0].copy(), np.zeros(score.shape, dtype=int)
    for j in range(1, score.shape[1]):
        pad = np.pad(best, w, constant_values=-np.inf)
        cand = np.stack([pad[i:i + len(best)] for i in range(2 * w + 1)])    # cand[i, s] = best[s + i - w]
        i = cand.argmax(axis=0)
        back[:, j] = np.arange(len(best)) + i - w
        best = cand[i, np.arange(len(best))] + score[:, j]
    path = [int(best.argmax())]
    for j in range(score.shape[1] - 1, 0, -1):
        path.append(back[path[-1], j])
    return t, grid[path[::-1]]


def steady_hz(x, hz):
    """Measured 1x frequency of a constant-speed recording: the peak of its 10-s spectrum (accelerometers 2 and 3
    together) within 10% of the commanded hz. Only for the log (it shows the slip); never an input."""
    s = x - x.mean(axis=0)
    P = (np.abs(np.fft.rfft(s * np.hanning(len(s))[:, None], axis=0)) ** 2).sum(axis=1)
    f = np.fft.rfftfreq(len(s), 1 / FS)
    k = np.where((f >= 0.9 * hz) & (f <= 1.1 * hz))[0]
    i = k[np.argmax(P[k])]
    y0, y1, y2 = np.log(P[i - 1:i + 2])
    return float(f[i] + 0.5 * (y0 - y2) / (y0 - 2 * y1 + y2) * (f[1] - f[0]))


def command(speed, t_start, t_end, t):
    """Ramp-and-hold command at times t: a until t_start, linear to b at t_end, then b (a, b from the speed code)."""
    a, b = SPEED_HZ[speed]
    return a + (b - a) * np.clip((np.asarray(t, dtype=float) - t_start) / (t_end - t_start), 0.0, 1.0)


def fit_command(speed, t, hz):
    """The ramp start and end times (s) that bring the command closest to the tracked line (least absolute error,
    on a 0.05-s grid; the ramp may have started before the recording or end after it). Returns t_start, t_end,
    the mean absolute error (Hz) and the largest distance of the fitted command from the nominal ramp in 0..10 s."""
    starts = np.round(np.arange(-200, 201) * 0.05, 2)          # -10 .. 10 s
    best = (np.inf, 0.0, float(SECONDS))
    for ts in starts:
        ends = np.round(ts + np.arange(20, int(round((25.0 - ts) / 0.05)) + 1) * 0.05, 2)   # ts + 1 .. 25 s
        err = np.abs(command(speed, ts, ends[:, None], t[None, :]) - hz[None, :]).mean(axis=1)
        i = int(err.argmin())
        if err[i] < best[0]:
            best = (float(err[i]), float(ts), float(ends[i]))
    fine = np.linspace(0.0, SECONDS, 1001)
    dev = float(np.abs(command(speed, best[1], best[2], fine) - command(speed, 0.0, SECONDS, fine)).max())
    return best[1], best[2], best[0], dev


def profile(speed, t, hz):
    """The command used for f: (t_start, t_end, source, fit) with source 'nominal' or 'fitted'."""
    a, b = SPEED_HZ[speed]
    if a == b:
        return 0.0, float(SECONDS), "nominal", None
    fit = fit_command(speed, t, hz)
    if fit[3] > TOLERANCE_HZ:
        return fit[0], fit[1], "fitted", fit
    return 0.0, float(SECONDS), "nominal", fit


def window_hz(speed, t_start, t_end, t0, t1):
    """Mean of the command over [t0, t1) seconds (midpoint rule on 10,000 points; exact for a constant or a line)."""
    n = 10_000
    return float(command(speed, t_start, t_end, t0 + (np.arange(n) + 0.5) * (t1 - t0) / n).mean())
