"""Diagrams for the Run 3 report and the updated development report (inside model/):

  python report/run3_diagrams.py   -> results/supervised/run3/analysis/figures/diagram_*.png
"""
import sys
from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

sys.path.insert(0, str(Path(__file__).resolve().parent))
from dev_report_figures import box, arrow, NAVY, BLUE, LBLUE, ORANGE, GREEN, GREY, INK, RED   # noqa: E402

FIG = Path(__file__).resolve().parent.parent / "results" / "supervised" / "run3" / "analysis" / "figures"
B = ("B02", "B03", "B04", "B08", "B09", "B11", "B12")


def save(fig, name):
    FIG.mkdir(parents=True, exist_ok=True)
    fig.savefig(FIG / name, dpi=170, bbox_inches="tight")
    plt.close(fig)


def nested():
    fig, ax = plt.subplots(figsize=(11, 4.3))
    ax.set_xlim(0, 110), ax.set_ylim(0, 43), ax.axis("off")
    ax.text(55, 41.5, "Nested leave-one-bearing-out (one of the 7 outer folds shown: B08 held out)", ha="center",
            fontsize=9, weight="bold", color=NAVY)
    for j, b in enumerate(B):
        held = b == "B08"
        box(ax, 2 + j * 9, 33, 7.5, 4.5, b, fc=ORANGE if held else LBLUE, ec=ORANGE if held else NAVY, size=8,
            color="white" if held else INK, r=0.4, pad=0.15)
    ax.text(67, 35.2, "outer fold: B08 is held out completely", fontsize=7.8, va="center")
    inner = [b for b in B if b != "B08"]
    for r, v in enumerate(inner):
        y = 27 - r * 3.6
        for j, b in enumerate(inner):
            val = b == v
            box(ax, 2 + j * 9, y, 7.5, 2.6, b, fc=GREEN if val else "#f3f4f6", ec=GREEN if val else GREY, size=6.8,
                color="white" if val else INK, r=0.3, pad=0.1)
    ax.text(57, 27.8 - 9, "6 inner folds: train on 5 (grey),\nvalidate on 1 (green), for each of\nthe 5 candidates x 5 seeds = 150 trainings",
            fontsize=7.6, va="center")
    box(ax, 82, 15, 26, 12, "choose the candidate with the\nbest inner score (healthy alarms,\nend-stage recall, stability,\nlog-loss): uses no B08 data", fc="white", size=7.3, r=0.6, pad=0.2)
    arrow(ax, 95, 15, 95, 9)
    box(ax, 82, 2, 26, 6.5, "train it on all 6, score\nevery measurement of B08", fc=LBLUE, size=7.3, r=0.6, pad=0.2)
    save(fig, "diagram_nested_lobo.png")


def timeline():
    ev = [("16-24 Oct", "8x8 INT8 array: 250 MHz\nmatrix multiply; 214 MHz\non-chip MLP (board tests)", GREEN),
          ("27-28 Oct", "Ottawa motor model:\nE0-E3, single-accel.,\nINT8, RTL check", BLUE),
          ("1-2 Nov", "Paderborn redesign:\nB01-B04, anomaly detector,\nMTL design, labels, split", BLUE),
          ("3 Nov", "Runs 1-2: 3 bearings,\nlatched alarm, calibration,\nINT8 + RTL of trained net", BLUE),
          ("3 Nov", "B08, B09, B11, B12 added;\nRun 3: 7 bearings, nested\nLOBO, 5 candidates", ORANGE),
          ("3 Nov", "Run 3 hardware: dead-\nneuron INT8 fix, 15 RTL\nsimulations pass", GREEN)]
    fig, ax = plt.subplots(figsize=(12, 2.9))
    ax.set_xlim(-0.6, len(ev) - 0.4), ax.set_ylim(-0.4, 2.4), ax.axis("off")
    ax.plot([-0.5, len(ev) - 0.5], [0.4, 0.4], color=NAVY, lw=2)
    for i, (d, t, c) in enumerate(ev):
        ax.scatter([i], [0.4], s=60, color=c, zorder=3, edgecolor="white", linewidth=1.5)
        ax.text(i, 0.1, d, ha="center", va="top", fontsize=7.5, weight="bold", color=NAVY)
        ax.plot([i, i], [0.4, 0.75], color=c, lw=1.2)
        box(ax, i - 0.45, 0.8, 0.9, 1.4, t, fc="white", ec=c, size=6.6, r=0.06, pad=0.02)
    save(fig, "diagram_timeline_v2.png")


def why_b12():
    """Per bearing: the largest of the six vibration z-inputs (raw, before the clip) on the healthy and end-stage labels."""
    import numpy as np
    import pandas as pd
    prep = FIG.parent.parent / "prep"
    vib = ["raw_z_ln_lr_rms", "raw_z_ln_lr_peak", "raw_z_lr_kurt", "raw_z_ln_band_1k_5k", "raw_z_ln_band_5k_20k", "raw_z_lr_crest"]
    fig, ax = plt.subplots(figsize=(9.5, 3.3))
    for i, b in enumerate(B):
        d = pd.read_csv(prep / f"dataset_{b}.csv")
        m = d[vib].abs().max(axis=1)
        h, e = m[d.y_det == 0], m[d.y_det == 1]
        ax.plot([h.min(), h.max()], [i, i], color=BLUE, lw=6, alpha=0.35, solid_capstyle="butt")
        ax.scatter(e, [i] * len(e), color=RED if b == "B12" else ORANGE, s=22, zorder=3)
    ax.axvline(16, color=GREY, lw=0.8, ls="--")
    ax.text(16.3, 6.35, "input clip (+16)", fontsize=7, color=GREY)
    ax.set_yticks(range(len(B)), B), ax.invert_yaxis()
    ax.set_xscale("symlog", linthresh=10)
    ax.set_xlabel("largest of the six vibration z-inputs per measurement (raw, unclipped; symlog scale)")
    ax.set_title("Healthy labels (blue band: min-max) vs end-stage labels (dots): B12's end stage barely leaves the healthy range",
                 fontsize=8.5, weight="bold")
    for s_ in ("top", "right"):
        ax.spines[s_].set_visible(False)
    save(fig, "diagram_why_b12.png")


if __name__ == "__main__":
    nested(), timeline(), why_b12()
    print("diagrams in", FIG)
