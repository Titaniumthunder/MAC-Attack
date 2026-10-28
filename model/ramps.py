"""The ramp check before E2: are the speed ramps linear over the 10 s?

  python ramps.py --data "<folder>/University of Ottawa Electric Motor Dataset – Vibr"

Draws results/ramps/ramps.png: the spectrogram of H_H_5_0.csv (accelerometers 2 and 3) with its tracked 1x line and
the nominal command, and the tracked 1x line of every ramp recording (features/tracks.csv), with the 7 that use a
fitted command (features/speed.csv) drawn thick. Reads only H_H_5_0.csv from the dataset.
"""
import argparse, csv
from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
from scipy.signal import spectrogram

import speed as spd
from dataset import FEATURES, FS, HERE, SPEED_HZ
from features import read


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--data", required=True, help="the dataset's top folder (quote it)")
    a = ap.parse_args()
    with open(FEATURES / "speed.csv", newline="") as f:
        prof = {r["file"]: r for r in csv.DictReader(f)}
    tracks = {}
    with open(FEATURES / "tracks.csv", newline="") as f:
        for r in csv.DictReader(f):
            tracks.setdefault(r["file"], ([], []))
            tracks[r["file"]][0].append(float(r["t"]))
            tracks[r["file"]][1].append(float(r["hz"]))

    x = read(Path(a.data) / "2_CSV_Data_Files" / "1_Unloaded_Condition" / "H_H_5_0.csv")
    tt = np.linspace(0, 10, 401)
    plt.rcParams.update({"font.size": 8, "axes.titlesize": 8.5})
    fig = plt.figure(figsize=(8, 5.6))
    for i, a_ in enumerate((2, 3)):
        ax = fig.add_subplot(2, 2, i + 1)
        s = x[:, a_ - 1] - x[:, a_ - 1].mean()
        f, t, S = spectrogram(s, fs=FS, nperseg=FS // 2, noverlap=FS // 2 - FS // 20, nfft=2 * FS)
        k = f <= 140
        ax.pcolormesh(t, f[k], 10 * np.log10(S[k] + 1e-20), shading="auto", cmap="magma")
        ax.plot(*tracks["H_H_5_0.csv"], color="cyan", lw=1.5, label="tracked 1x line")
        ax.plot(tt, spd.command(5, 0.0, 10.0, tt), "w--", lw=1.2, label="nominal ramp 15 -> 45 Hz")
        ax.set(title=f"H_H_5_0, accelerometer {a_}: spectrogram (dB)", xlabel="time (s)", ylabel="Hz")
        leg = ax.legend(loc="upper left", fontsize=7, facecolor="#333333", edgecolor="none", framealpha=0.9)
        for txt in leg.get_texts():
            txt.set_color("white")
    ax = fig.add_subplot(2, 1, 2)
    for code, color in zip((5, 6, 7, 8), ("C0", "C1", "C2", "C3")):
        ax.plot(tt, spd.command(code, 0.0, 10.0, tt), "k--", lw=0.8)
        for n, (t, hz) in tracks.items():
            if int(prof[n]["speed"]) != code:
                continue
            fitted = prof[n]["profile"] == "fitted"
            ax.plot(t, hz, color=color, lw=1.8 if fitted else 0.6, alpha=1.0 if fitted else 0.35)
        ax.plot([], [], color=color, lw=1.8,
                label=f"code {code} ({SPEED_HZ[code][0]} -> {SPEED_HZ[code][1]} Hz)")
    ax.plot([], [], "k--", lw=0.8, label="nominal ramps")
    ax.set(title="All 64 ramp recordings: tracked 1x line (thick: the 7 with a fitted command)",
           xlabel="time (s)", ylabel="Hz", xlim=(0, 10))
    ax.legend(loc="center left", bbox_to_anchor=(1.01, 0.5), fontsize=7.5, frameon=False)
    fig.tight_layout()
    out = HERE / "results" / "ramps"
    out.mkdir(parents=True, exist_ok=True)
    fig.savefig(out / "ramps.png", dpi=180)
    print(f"wrote {out / 'ramps.png'}")


if __name__ == "__main__":
    main()
