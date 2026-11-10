"""Diagrams for the ML development report (docs/Model/11_Development_history_Ottawa_to_Run3.pdf).

  python report/dev_report_figures.py     (inside model/) -> results/supervised/run2/figures/dev_*.png

Every number drawn here is copied from the saved results or the project log (sources in ML_DEVELOPMENT_REPORT.md).
"""
import json
from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch

HERE = Path(__file__).resolve().parent.parent
FIG = HERE / "results" / "supervised" / "run2" / "figures"
NAVY, BLUE, LBLUE, ORANGE, GREEN, GREY, INK, RED = "#1f3a5f", "#2f7fbf", "#e8f1fb", "#e07b28", "#2e8b57", "#9a9a94", "#111827", "#c0392b"
plt.rcParams.update({"font.family": "DejaVu Sans", "font.size": 9})


def box(ax, x, y, w, h, text, fc=LBLUE, ec=NAVY, size=8, color=INK, weight="normal", r=0.9, pad=0.25):
    ax.add_patch(FancyBboxPatch((x, y), w, h, boxstyle=f"round,pad={pad},rounding_size={r}", fc=fc, ec=ec, lw=1.1))
    ax.text(x + w / 2, y + h / 2, text, ha="center", va="center", fontsize=size, color=color, weight=weight, linespacing=1.35)


def arrow(ax, x0, y0, x1, y1, color=NAVY):
    ax.annotate("", (x1, y1), (x0, y0), arrowprops=dict(arrowstyle="-|>", color=color, lw=1.2, shrinkA=0, shrinkB=0))


def save(fig, name):
    FIG.mkdir(parents=True, exist_ok=True)
    fig.savefig(FIG / name, dpi=170, bbox_inches="tight")
    plt.close(fig)


def timeline():
    ev = [("16-19 Oct", "8x8 INT8 systolic array\non the ZedBoard: 24/24\nboard tests at 250 MHz", "hw"),
          ("20 Oct", "Professor approves a\nmulti-task MLP on\nvibration, temp., RPM", "plan"),
          ("21-24 Oct", "On-chip MLP engine;\n214.286 MHz build;\n30/30 board tests", "hw"),
          ("27 Oct", "Ottawa motor model\nE0-E3, health index H1,\nINT8 export, RTL check", "ml"),
          ("28 Oct", "Single-accelerometer\nOttawa models\n(8-32-16-1);\naccelerometer 1 deployed", "ml"),
          ("1 Nov", "Redesign on Paderborn\nrun-to-failure data:\nB01, anomaly detector,\nmulti-task design", "ml"),
          ("2 Nov", "Dataset validation,\nlocked split, labels,\nB02 + B04 processed", "ml"),
          ("3 Nov", "Training Run 1 and\nRun 2 (latched alarm,\ncalibration, INT8 + RTL)", "ml")]
    col = {"hw": GREEN, "plan": ORANGE, "ml": BLUE}
    fig, ax = plt.subplots(figsize=(12.5, 3.7))
    ax.set_xlim(-0.6, len(ev) - 0.4), ax.set_ylim(-2.2, 2.75), ax.axis("off")
    ax.plot([-0.5, len(ev) - 0.5], [0, 0], color=NAVY, lw=2)
    for i, (d, t, k) in enumerate(ev):
        up = i % 2 == 0
        ax.plot([i, i], [0, 0.55 if up else -0.55], color=col[k], lw=1.2)
        ax.scatter([i], [0], s=60, color=col[k], zorder=3, edgecolor="white", linewidth=1.5)
        ax.text(i, -0.22 if up else 0.22, d, ha="center", va="top" if up else "bottom", fontsize=7.5, weight="bold", color=NAVY)
        box(ax, i - 0.46, 0.6 if up else -2.05, 0.92, 1.45, t, fc="white", ec=col[k], size=6.4, r=0.06, pad=0.02)
    for k, lab, x in (("hw", "hardware", 0.0), ("plan", "plan", 1.3), ("ml", "machine learning", 2.4)):
        ax.scatter([x], [2.6], s=30, color=col[k]), ax.text(x + 0.1, 2.6, lab, va="center", fontsize=7.5)
    save(fig, "dev_timeline.png")


def pipeline():
    fig, ax = plt.subplots(figsize=(11, 3.1))
    ax.set_xlim(0, 110), ax.set_ylim(0, 30), ax.axis("off")
    steps = [(1, "Sensors\nrear accelerometer\nhousing temp.\nshaft speed", "#ffffff"),
             (19.5, "ARM (Zynq PS)\n1.6-s measurement\n-> 6 vibration\nfeatures, RPM,\ntemp. model", LBLUE),
             (38, "Per-motor\nnormalisation\nz vs. own first 100\nmeasurements,\nclip +-16", LBLUE),
             (56.5, "FPGA (Zynq PL)\nINT8 MLP on the\n8x8 systolic array\n8-32-16-2", "#e6f6ef"),
             (75, "ARM\nadd biases,\nsigmoid ->\ndeterioration score", LBLUE),
             (93.5, "Alarm logic\n3 in a row > 0.5,\nthen latched\n(Run 2)", "#fdeee7")]
    for x, t, fc in steps:
        box(ax, x, 7, 15, 16, t, fc=fc, size=7.2)
    for (x, _, _), (x2, _, _) in zip(steps[:-1], steps[1:]):
        arrow(ax, x + 15.4, 15, x2 - 0.4, 15)
    ax.text(64.75, 3.0, "INT8 in, raw 22-bit sums out (one AXI4-Lite transaction set per batch)", ha="center", fontsize=7, color=GREY)
    ax.text(55, 28, "Machine Guardian inference path (planned deployment; the trained MLP has run in simulation, not yet on the board)",
            ha="center", fontsize=8, color=NAVY, weight="bold")
    save(fig, "dev_pipeline.png")


def architecture():
    fig, ax = plt.subplots(figsize=(11, 4.4))
    ax.set_xlim(0, 100), ax.set_ylim(0, 44), ax.axis("off")
    names = [("x1  z ln RMS", LBLUE), ("x2  z ln peak", LBLUE), ("x3  z kurtosis", LBLUE), ("x4  z ln 1-5 kHz band", LBLUE),
             ("x5  z ln 5-20 kHz band", LBLUE), ("x6  z crest factor", LBLUE), ("x7  RPM (operating point)", "#fdeee7"),
             ("x8  temperature residual", "#e6f6ef")]
    for i, (n, fc) in enumerate(names):
        box(ax, 0.5, 38.5 - i * 4.9, 19, 3.3, n, fc=fc, size=7.4)
        arrow(ax, 20.2, 40.1 - i * 4.9, 26, 22)
    ax.text(10, 43.3, "8 inputs (A42 profile, rear accelerometer)", ha="center", fontsize=7.8, color=NAVY, weight="bold")
    box(ax, 26.5, 7, 12.5, 30, "Dense 8 x 32\n+ ReLU\n\n256 weights\n32 biases\n= 288", fc="#f3f4f6", size=7.8)
    arrow(ax, 39.6, 22, 44, 22)
    box(ax, 44.5, 10, 12.5, 24, "Dense 32 x 16\n+ ReLU\n\n512 weights\n16 biases\n= 528", fc="#f3f4f6", size=7.8)
    ax.text(41.75, 39.5, "shared trunk", ha="center", fontsize=8, color=NAVY, weight="bold")
    arrow(ax, 57.6, 24, 63, 30), arrow(ax, 57.6, 20, 63, 13)
    box(ax, 63.5, 26, 15, 8.5, "Deterioration head\nDense 16 x 1 (17)\nTRAINED (Runs 1-2)", fc=LBLUE, size=7.6)
    box(ax, 63.5, 8.5, 15, 8.5, "Health-index head\nDense 16 x 1 (17)\nFROZEN, untrained", fc="#f3f4f6", ec=GREY, size=7.6, color="#4b5563")
    arrow(ax, 79.2, 30.25, 83, 30.25), arrow(ax, 79.2, 12.75, 83, 12.75, color=GREY)
    box(ax, 83.5, 26, 15.5, 8.5, "p = sigmoid(d)\nscore in 0..1\nalarm if 3 x > 0.5", fc="white", size=7.4)
    box(ax, 83.5, 8.5, 15.5, 8.5, "HI = 100 % x sigmoid(h)\nnot used until severity\nlabels exist", fc="white", ec=GREY, size=7.1, color="#4b5563")
    ax.text(50, 1.8, "850 parameters = 288 + 528 + 17 + 17   |   on the chip both heads are one 16 x 2 layer   |   14 passes of the 8 x 8 array",
            ha="center", fontsize=7.6, color=NAVY)
    save(fig, "dev_architecture.png")


def lobo():
    fig, ax = plt.subplots(figsize=(9, 2.6))
    ax.set_xlim(0, 90), ax.set_ylim(0, 26), ax.axis("off")
    folds = [("B02", ("B03", "B04")), ("B03", ("B02", "B04")), ("B04", ("B02", "B03"))]
    for r, (ho, tr) in enumerate(folds):
        y = 19 - r * 7.5
        ax.text(1, y + 2.4, f"Fold {r + 1}", fontsize=8, weight="bold", color=NAVY, va="center")
        for j, b in enumerate(("B02", "B03", "B04")):
            held = b == ho
            box(ax, 12 + j * 13, y, 11, 4.8, f"{b}\n{'held out (test)' if held else 'train'}",
                fc=ORANGE if held else LBLUE, ec=ORANGE if held else NAVY, size=7.4, color="white" if held else INK)
        ax.text(52, y + 2.4, f"train on {tr[0]} + {tr[1]}: 200 healthy + 10 end-stage rows\nscore every measurement of {ho}",
                fontsize=7.4, va="center")
    ax.text(45, 25.3, "Leave-one-bearing-out, x 3 seeds = 9 trained networks.  Locked test bearings B06, B07, B13, B17: never loaded.",
            ha="center", fontsize=7.6, color=NAVY)
    save(fig, "dev_lobo.png")


def ottawa():
    exps = ["E0", "E1", "E2", "E3", "E3 single\naccel. a1"]
    found = [18, 15, 24, 27, 28]
    auc = [0.875, 0.929, 1.000, 1.000, 1.000]
    fig, ax = plt.subplots(figsize=(7.5, 2.9))
    b = ax.bar(range(5), found, color=[GREY, GREY, BLUE, NAVY, GREEN])
    for i, (f, a) in enumerate(zip(found, auc)):
        ax.text(i, f + 0.4, f"{f}/28\nAUC {a:.3f}", ha="center", fontsize=7.3)
    ax.axhline(28, color=RED, lw=0.8, ls="--")
    ax.set_ylim(0, 33), ax.set_xticks(range(5), exps, fontsize=8)
    ax.set_ylabel("test faults found (of 28)")
    ax.set_title("Ottawa motor dataset, test split, seed 42 (0 of 4 false alarms in every case)", fontsize=9, weight="bold")
    for s in ("top", "right"):
        ax.spines[s].set_visible(False)
    save(fig, "dev_ottawa.png")


def main():
    timeline(), pipeline(), architecture(), lobo(), ottawa()
    print(f"diagrams in {FIG}")


if __name__ == "__main__":
    main()
