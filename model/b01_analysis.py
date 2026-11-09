"""Paderborn B01: trends, operating-condition normalization and change detection on results/B01/B01_processed.csv.

  python b01_analysis.py          (after b01_preprocess.py)

Normalization (fixed before looking at the residuals): for each vibration feature y, on the random-condition
measurements before the change point candidate search (the reference: every non-warm-up measurement with id < REF_END),
fit  ln y = b0 + b1 ln(measured speed) + b2 measured static load + b3 peak dynamic load  (least squares), and express
every measurement as z = (ln y - fit) / sigma_ref. A change is "sustained" at the first measurement from which at least
RUN consecutive measurements have z > Z. Temperature is NOT in the model: its effect is tested separately (warm-up and
the restarts), because temperature itself rises with damage. REF_END is the first id after which nothing is used for
fitting; it was set from the raw high-frequency band (the jump at M0208) and the results are reported with that caveat.

Writes results/B01/analysis.json and results/B01/figures/*.png. No label, failure time or health value is written.
"""
import json
from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import matplotlib.dates as mdates
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

HERE = Path(__file__).resolve().parent
OUT = HERE / "results" / "B01"
REF_END = 208           # reference = operating measurements with id < 208
Z, RUN = 3.0, 3
FEATS = ["rms", "peak", "band_20k_64k", "band_5k_20k", "band_1k_5k", "band_10_1k", "kurt", "crest"]
LOG_END = pd.Timestamp("2021-10-19 09:13")

# reference palette (dataviz skill), light mode
BLUE, ORANGE, AQUA, YELLOW, VIOLET = "#2a78d6", "#eb6834", "#1baf7a", "#eda100", "#6250d6"
INK2, MUTED, GRID = "#52514e", "#8a8984", "#e4e3df"
plt.rcParams.update({"font.family": "DejaVu Sans", "font.size": 9, "axes.edgecolor": MUTED, "axes.labelcolor": INK2,
                     "xtick.color": INK2, "ytick.color": INK2, "axes.spines.top": False, "axes.spines.right": False,
                     "axes.grid": True, "grid.color": GRID, "grid.linewidth": 0.6, "axes.axisbelow": True,
                     "legend.frameon": False, "figure.facecolor": "white"})


def design(d):
    return np.column_stack([np.ones(len(d)), np.log(d["speed_rpm"]), d["stat_N"] / 1000, d["peakDyn_N"] / 1000])


def normalize(d, ref):
    out = {}
    X, Xr = design(d), design(d[ref])
    for ch in "AC":
        for f in FEATS:
            y = np.log(d[f"acc{ch}_{f}"].to_numpy())
            b, *_ = np.linalg.lstsq(Xr, y[ref], rcond=None)
            r = y - X @ b
            s = r[ref].std()
            ss = ((y[ref] - y[ref].mean()) ** 2).sum()
            out[f"{ch}_{f}"] = {"coef": b.tolist(), "sigma": float(s), "r2_ref": float(1 - (r[ref] ** 2).sum() / ss),
                                "z": r / s}
    return out


def first_sustained(z, ids, start_mask):
    above = z > Z
    for i in range(len(z) - RUN + 1):
        if start_mask[i] and above[i:i + RUN].all():
            return int(ids[i])
    return None


def shade(ax, d):
    for s, g in d.groupby("segment"):
        ax.axvspan(g.timestamp.iloc[0], g.timestamp.iloc[-1], color=["#f6f5f2", "#ffffff"][s % 2], zorder=0)
    ax.axvline(LOG_END, color=MUTED, linewidth=0.8, linestyle=":")


def timefmt(ax):
    ax.xaxis.set_major_formatter(mdates.DateFormatter("%H:%M"))


def figures(d, norm, onset_ts):
    fd = OUT / "figures"
    fd.mkdir(exist_ok=True)
    t = d["timestamp"]
    seg_label = {1: "Segment 1\n(log: 08:45-09:13)", 2: "Seg. 2", 3: "Segment 3 (not in the log)"}

    # 1. overview
    fig, axs = plt.subplots(4, 1, figsize=(9, 9.5), sharex=True)
    ax = axs[0]
    shade(ax, d)
    ax.plot(t, d["accA_rms"], ".", ms=4, color=BLUE, label="rear (A)")
    ax.plot(t, d["accC_rms"], ".", ms=4, color=ORANGE, label="front (C)")
    ax.set_yscale("log")
    ax.set_ylabel("Vibration RMS (g)")
    ax.legend(loc="lower left", bbox_to_anchor=(0, 1.0), ncol=2)
    for s, g in d.groupby("segment"):
        ax.text(g.timestamp.iloc[0], ax.get_ylim()[1] * 0.9, " " + seg_label[s], va="top", fontsize=7.5, color=INK2)
    ax = axs[1]
    shade(ax, d)
    ax.plot(t, d["T1_C"], ".", ms=3.5, color=BLUE, label="T1")
    ax.plot(t, d["T2_C"], ".", ms=3.5, color=ORANGE, label="T2")
    ax.plot(t, d["Troom_C"], ".", ms=3.5, color=AQUA, label="room")
    ax.set_ylabel("Temperature (°C)")
    ax.legend(loc="upper left", ncol=3)
    ax = axs[2]
    shade(ax, d)
    ax.plot(t, d["setSpeed_rpm"], "x", ms=4, color=MUTED, label="set")
    ax.plot(t, d["speed_rpm"], ".", ms=4, color=BLUE, label="measured")
    ax.axhspan(2400, 3000, color=BLUE, alpha=0.06, zorder=0)
    ax.set_ylabel("Speed (rpm)")
    ax.legend(loc="lower right", ncol=2)
    ax = axs[3]
    shade(ax, d)
    ax.plot(t, d["stat_N"], ".", ms=4, color=BLUE, label="static (measured)")
    ax.plot(t, d["peakDyn_N"], ".", ms=4, color=ORANGE, label="dynamic amplitude (peak)")
    ax.plot(t, d["combined_set_N"], "_", ms=5, color=MUTED, label="combined (set)")
    ax.set_ylabel("Load (N)")
    ax.legend(loc="lower right", ncol=3, fontsize=8)
    for ax in axs:
        ax.axvline(onset_ts, color=INK2, linewidth=0.9, linestyle="--")
    axs[0].text(onset_ts, axs[0].get_ylim()[0] * 1.3, " M0208", fontsize=7.5, color=INK2)
    timefmt(axs[3])
    axs[3].set_xlabel("19 Oct 2021 (shading: segments; dotted: log end 09:13; dashed: vibration change at M0208)")
    fig.tight_layout()
    fig.savefig(fd / "B01_overview.png", dpi=170)
    plt.close(fig)

    # 2. vibration detail: bands, kurtosis, crest, by measurement id (stops collapsed)
    fig, axs = plt.subplots(3, 1, figsize=(9, 7), sharex=True)
    i = d["measurement_id"]
    for f, col, lab in (("band_10_1k", BLUE, "10 Hz-1 kHz"), ("band_1k_5k", AQUA, "1-5 kHz"),
                        ("band_5k_20k", YELLOW, "5-20 kHz"), ("band_20k_64k", ORANGE, "20-64 kHz")):
        axs[0].plot(i, d[f"accA_{f}"], ".", ms=3.5, color=col, label=lab)
    axs[0].set_yscale("log")
    axs[0].set_ylabel("Rear (A) band RMS (g)")
    axs[0].legend(loc="upper left", ncol=4, fontsize=8)
    axs[1].plot(i, d["accA_kurt"], ".", ms=3.5, color=BLUE, label="rear (A)")
    axs[1].plot(i, d["accC_kurt"], ".", ms=3.5, color=ORANGE, label="front (C)")
    axs[1].axhline(3, color=MUTED, linewidth=0.8, linestyle=":")
    axs[1].set_ylabel("Kurtosis")
    axs[1].legend(loc="upper left", ncol=2)
    axs[2].plot(i, d["accA_crest"], ".", ms=3.5, color=BLUE, label="rear (A)")
    axs[2].plot(i, d["accC_crest"], ".", ms=3.5, color=ORANGE, label="front (C)")
    axs[2].set_ylabel("Crest factor")
    axs[2].legend(loc="upper left", ncol=2)
    for ax in axs:
        for b in (106, 134):
            ax.axvline(b - 0.5, color=MUTED, linewidth=0.8, linestyle=":")
        ax.axvline(51.5, color=MUTED, linewidth=0.8, linestyle="-.")
        ax.axvline(REF_END - 0.5, color=INK2, linewidth=0.9, linestyle="--")
    axs[2].set_xlabel("Measurement id (dash-dot: end of warm-up; dotted: stops; dashed: M0208)")
    fig.tight_layout()
    fig.savefig(fd / "B01_vibration_features.png", dpi=170)
    plt.close(fig)

    # 3. normalized residuals
    fig, axs = plt.subplots(2, 1, figsize=(9, 5.2), sharex=True)
    op = ~d["warmup"]
    for ax, f, lab in ((axs[0], "rms", "RMS"), (axs[1], "band_20k_64k", "20-64 kHz band")):
        for ch, col, nm in (("A", BLUE, "rear (A)"), ("C", ORANGE, "front (C)")):
            ax.plot(i[op], norm[f"{ch}_{f}"]["z"][op], ".", ms=3.5, color=col, label=nm)
        ax.axhspan(-Z, Z, color=MUTED, alpha=0.12, zorder=0)
        ax.axvline(REF_END - 0.5, color=INK2, linewidth=0.9, linestyle="--")
        for b in (106, 134):
            ax.axvline(b - 0.5, color=MUTED, linewidth=0.8, linestyle=":")
        ax.set_ylabel(f"{lab}: z vs speed/load fit")
        ax.legend(loc="upper left", ncol=2)
        ax.set_yscale("symlog", linthresh=5)
    axs[1].set_xlabel("Measurement id (grey band: ±3 sigma of the pre-M0208 reference; operating measurements only)")
    fig.tight_layout()
    fig.savefig(fd / "B01_normalized_residuals.png", dpi=170)
    plt.close(fig)

    # 4. vibration against speed, before and after
    fig, axs = plt.subplots(1, 2, figsize=(9, 3.4))
    pre = op & (i < REF_END)
    post = op & (i >= REF_END)
    for ax, f, lab in ((axs[0], "accA_rms", "Rear RMS (g)"), (axs[1], "accA_band_20k_64k", "Rear 20-64 kHz (g)")):
        ax.plot(d["speed_rpm"][pre], d[f][pre], ".", ms=4, color=BLUE, label="before M0208")
        ax.plot(d["speed_rpm"][post], d[f][post], ".", ms=4, color=ORANGE, label="from M0208")
        ax.set_yscale("log")
        ax.set_xlabel("Measured speed (rpm)")
        ax.set_ylabel(lab)
    axs[0].legend(loc="upper left")
    fig.tight_layout()
    fig.savefig(fd / "B01_vibration_vs_speed.png", dpi=170)
    plt.close(fig)

    # 5. warm-up / temperature effect before the change
    fig, ax = plt.subplots(figsize=(9, 3.2))
    for s, col in ((1, BLUE), (2, AQUA), (3, ORANGE)):
        k = op & (d["segment"] == s) & (i < REF_END)
        ax.plot(d["T1_C"][k], norm["A_rms"]["z"][k], ".", ms=4, color=col, label=f"segment {s}")
    ax.set_xlabel("T1 (°C)")
    ax.set_ylabel("Rear RMS z (speed/load removed)")
    ax.legend(loc="upper left", ncol=3)
    ax.set_title("Before M0208 only: does the bearing temperature explain the vibration?", fontsize=9, color=INK2)
    fig.tight_layout()
    fig.savefig(fd / "B01_temperature_effect.png", dpi=170)
    plt.close(fig)


def main():
    d = pd.read_csv(OUT / "B01_processed.csv", parse_dates=["timestamp"])
    ids = d["measurement_id"].to_numpy()
    op = (~d["warmup"]).to_numpy()
    ref = op & (ids < REF_END)
    norm = normalize(d, ref)
    res = {"reference": {"ids": f"operating, id < {REF_END}", "n": int(ref.sum())}, "rule": f"z > {Z} for {RUN} in a row",
           "features": {}}
    for k, v in norm.items():
        z = v["z"]
        res["features"][k] = {"r2_ref": v["r2_ref"], "sigma": v["sigma"], "coef": v["coef"],
                              "first_sustained_id": first_sustained(z, ids, op),
                              "ref_exceed_3": int((np.abs(z[ref]) > Z).sum()),
                              "median_z_after": float(np.median(z[op & (ids >= REF_END)])),
                              "median_z_last20": float(np.median(z[-20:]))}
    # before the change: drift over operating order, temperature and segment effects (rear RMS and HF band)
    pre = {}
    for k in ("A_rms", "A_band_20k_64k", "C_rms", "C_band_20k_64k", "A_kurt"):
        z = norm[k]["z"]
        x = np.arange(len(z))[ref]
        slope = np.polyfit(x, z[ref], 1)[0]
        pre[k] = {"drift_z_per_100_meas": float(slope * 100),
                  "corr_with_T1": float(np.corrcoef(z[ref], d["T1_C"][ref])[0, 1]),
                  "mean_z_by_segment": {int(s): float(z[ref & (d["segment"] == s).to_numpy()].mean()) for s in (1, 2, 3)}}
    res["before_change"] = pre
    # conditions just before / after M0208 (are they different?)
    w = 30
    b = op & (ids >= REF_END - w) & (ids < REF_END)
    a = op & (ids >= REF_END) & (ids < REF_END + w)
    res["conditions_30_before_vs_after"] = {c: [float(d[c][b].mean()), float(d[c][a].mean())]
                                            for c in ("speed_rpm", "stat_N", "peakDyn_N", "T1_C", "T2_C")}
    res["raw_ratio_last20_vs_ref"] = {f"acc{ch}_{f}": float(d[f"acc{ch}_{f}"][-20:].median() / d[f"acc{ch}_{f}"][ref].median())
                                      for ch in "AC" for f in ("rms", "peak", "band_20k_64k", "band_10_1k")}
    # warm-up rows: vibration level and temperature (another speed, so not comparable to the operating rows)
    wu = d["warmup"]
    res["warmup"] = {"n": int(wu.sum()), "T1": [float(d["T1_C"][wu].iloc[0]), float(d["T1_C"][wu].iloc[-1])],
                     "accA_rms_first_last": [float(d["accA_rms"][wu].iloc[0]), float(d["accA_rms"][wu].iloc[-1])],
                     "accA_rms_trend_pct": float(100 * (np.polyfit(np.arange(wu.sum()), np.log(d["accA_rms"][wu]), 1)[0] * wu.sum()))}
    onset_ts = d.loc[d["measurement_id"] == REF_END, "timestamp"].iloc[0]
    res["M0208_timestamp"] = str(onset_ts)
    res["operating_minutes_before_M0208"] = float(d.loc[op & (ids < REF_END), "gap_before_s"].fillna(0).clip(upper=60).sum() / 60)
    figures(d, norm, onset_ts)
    (OUT / "analysis.json").write_text(json.dumps(res, indent=1) + "\n", encoding="utf-8")
    print(json.dumps(res, indent=1))


if __name__ == "__main__":
    main()
