"""Figures for the Run 2 comparison report and the ML development report, from results/supervised/run1 and run2 only.

  python report/run2_figures.py      (inside model/; after train_deterioration_run2.py) -> results/supervised/run2/figures/
"""
import json, sys
from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

HERE = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(HERE))
RUN1, RUN2 = HERE / "results" / "supervised" / "run1", HERE / "results" / "supervised" / "run2"
FIG = RUN2 / "figures"
BEARINGS, SEEDS = ("B02", "B03", "B04"), (0, 1, 2)
NAVY, BLUE, ORANGE, GREEN, RED, PURPLE, GREY = "#1f3a5f", "#2f7fbf", "#e07b28", "#2e8b57", "#c0392b", "#7b4fa8", "#9a9a94"
plt.rcParams.update({"font.family": "DejaVu Sans", "font.size": 9, "axes.spines.top": False, "axes.spines.right": False,
                     "axes.titleweight": "bold", "axes.titlesize": 9.5, "axes.grid": True, "grid.color": "#e6e6e2",
                     "grid.linewidth": 0.7, "axes.axisbelow": True})
R2 = json.loads((RUN2 / "results.json").read_text())
BASE = "baseline A|F128|speed (prototype)"
RIG = "rig stop rule, rear RMS > 6.5 g"


def save(fig, name):
    FIG.mkdir(parents=True, exist_ok=True)
    fig.savefig(FIG / name, dpi=150, bbox_inches="tight")
    plt.close(fig)


def runs(mask):
    m = np.r_[False, np.asarray(mask, bool), False].astype(int)
    d = np.diff(m)
    a, b = np.flatnonzero(d == 1), np.flatnonzero(d == -1)
    return list(zip(a, b - a))


def latched(above, run=3):
    above = np.asarray(above, bool)
    c = np.convolve(above.astype(int), np.ones(run, int))[:len(above)] == run
    c[:run - 1] = False
    return np.logical_or.accumulate(c)


def alarm_timeline():
    fig, axs = plt.subplots(3, 1, figsize=(10, 9.2))
    for ax, e in zip(axs, BEARINGS):
        p = pd.read_csv(RUN2 / f"predictions_{e}.csv")
        ids, y = p.measurement_id.to_numpy(), p.y_det.to_numpy()
        rows = []
        for s in SEEDS:
            rows.append((f"MLP seed {s}: run 1 rule", p[f"alarm_run1_seed{s}"].astype(bool).to_numpy(), PURPLE, 0.55))
        for s in SEEDS:
            rows.append((f"MLP seed {s}: run 2 latched", p[f"alarm_run2_seed{s}"].astype(bool).to_numpy(), NAVY, 1.0))
        rows.append(("anomaly detector (prototype)", latched(p.baseline_score_F128 > p.baseline_tau_F128), GREEN, 1.0))
        rows.append(("rig stop rule (> 6.5 g)", latched(p.rear_rms_g > 6.5), RED, 1.0))
        w = np.median(np.diff(ids))
        for val, col in ((0, BLUE), (1, ORANGE)):
            for a, n in runs(y == val):
                ax.axvspan(ids[a] - w / 2, ids[a + n - 1] + w / 2, color=col, alpha=0.16, lw=0)
        for k, (name, st, col, al) in enumerate(rows):
            ax.broken_barh([(ids[a] - w / 2, n * w) for a, n in runs(st)], (k - 0.36, 0.72), color=col, alpha=al)
        ax.set_yticks(range(len(rows)))
        ax.set_yticklabels([r[0] for r in rows], fontsize=7.5)
        ax.set_ylim(len(rows) - 0.5, -0.5)
        ax.set_xlim(ids[0] - w, ids[-1] + w)
        ax.grid(axis="y", visible=False)
        ax.set_title(f"{e} held out (blue band: healthy labels; orange band at the right edge: end-stage labels)")
    axs[-1].set_xlabel("measurement id")
    fig.tight_layout()
    save(fig, "alarm_timeline_run2.png")


def metric_bars():
    labels = ["Run 1 rule (MLP)", "Run 2 latched (MLP)", "Anomaly detector", "Rig stop rule"]
    cols = [PURPLE, NAVY, GREEN, RED]
    fig, axs = plt.subplots(1, 2, figsize=(10, 3.4))
    x = np.arange(len(BEARINGS))
    for j, (key, title) in enumerate((("alarm_state_changes", "Alarm-state changes over the run (fewer = steadier)"),
                                      ("first_alarm_min_before_last_record", "First alarm: minutes before the last record"))):
        ax = axs[j]
        for i, lab in enumerate(labels):
            vals, err = [], []
            for e in BEARINGS:
                f = R2["folds"][e]
                if i < 2:
                    v = [f["seeds"][str(s)]["run1_alarm" if i == 0 else "run2_latched_alarm"][key] for s in SEEDS]
                else:
                    v = [f["reference"][BASE if i == 2 else RIG]["latched"][key]]
                v = [np.nan if a is None else a for a in v]
                vals.append(np.nanmean(v) if not np.all(np.isnan(v)) else 0)
                err.append((np.nanmax(v) - np.nanmin(v)) / 2 if len(v) > 1 and not np.all(np.isnan(v)) else 0)
            ax.bar(x + (i - 1.5) * 0.2, vals, 0.2, yerr=err, color=cols[i], label=lab, capsize=2, error_kw={"lw": 0.8})
            for xi, v, er in zip(x + (i - 1.5) * 0.2, vals, err):
                ax.text(xi, v + er + 0.6, f"{v:.0f}", ha="center", va="bottom", fontsize=6.5)
        ax.set_xticks(x, BEARINGS)
        ax.set_title(title)
    axs[0].legend(fontsize=7, frameon=False)
    axs[1].text(1.3, 35, "rig rule never\nfires on B03", fontsize=6.5, color=RED, ha="center")
    fig.tight_layout()
    save(fig, "alarm_metrics_run2.png")


def calibration():
    P = pd.concat([pd.read_csv(RUN2 / f"predictions_{e}.csv").assign(held_out=e) for e in BEARINGS], ignore_index=True)
    fig, axs = plt.subplots(2, 2, figsize=(10, 7))
    ax = axs[0, 0]
    lg = np.concatenate([P[f"logit_seed{s}"] for s in SEEDS])
    y = np.concatenate([P.y_det for _ in SEEDS])
    bins = np.linspace(-40, 40, 81)
    for m, col, lab in ((np.isnan(y), GREY, "unlabelled middle rows"), (y == 0, BLUE, "healthy labels"),
                        (y == 1, ORANGE, "end-stage labels")):
        ax.hist(np.clip(lg[m], -40, 40), bins, color=col, alpha=0.75, label=lab)
    for v in (-6.9, 6.9):
        ax.axvline(v, color="k", lw=0.7, ls=":")
    ax.text(0, ax.get_ylim()[1] * 0.92, "p between 0.001\nand 0.999", ha="center", fontsize=7)
    ax.set_yscale("log")
    ax.set_xlabel("deterioration logit (held-out rows, 3 seeds)")
    ax.set_title("Most outputs sit far beyond p = 0.001 / 0.999")
    ax.legend(fontsize=7, frameon=False, loc="upper left")
    ax = axs[0, 1]
    ck = pd.read_csv(RUN2 / "checkpoints.csv").groupby("step").mean(numeric_only=True)
    ax.plot(ck.index, ck.mean_abs_logit_middle, "o-", color=GREY, label="mean |logit|, middle rows")
    ax.plot(ck.index, ck.mean_abs_logit_damaged, "o-", color=ORANGE, label="mean |logit|, end-stage rows")
    ax.plot(ck.index, ck.mean_abs_logit_healthy, "o-", color=BLUE, label="mean |logit|, healthy rows")
    ax.plot(ck.index, ck.weight_norm, "s--", color=NAVY, label="weight norm (trunk + head)")
    ax.set_xscale("log")
    ax.set_xlabel("training step")
    ax.set_title("Logits and weights keep growing with training")
    ax.legend(fontsize=7, frameon=False)
    ax2 = ax.twinx()
    ax2.plot(ck.index, ck.unlatched_state_changes, "^-", color=PURPLE, alpha=0.7)
    ax2.set_ylabel("run 1 rule: alarm-state changes", color=PURPLE, fontsize=8)
    ax2.spines["right"].set_visible(True)
    ax2.grid(False)
    ax = axs[1, 0]
    for e, mk in zip(BEARINGS, "os^"):
        d = P[(P.held_out == e)]
        ax.scatter(d.z_ln_lr_rms if "z_ln_lr_rms" in d else None, d.p_seed0, s=4, alpha=0.5, marker=mk, label=e)
    ax.set_xlabel("z ln RMS (input x1)")
    ax.set_ylabel("P(deteriorated), seed 0")
    ax.set_title("A sharp step: the output switches within a narrow input range")
    ax.legend(fontsize=7, frameon=False)
    ax = axs[1, 1]
    rel = R2["calibration"]["reliability_bins"]
    ax.plot([0, 1], [0, 1], color=GREY, lw=0.8, ls="--")
    for b in rel:
        ax.scatter(b["mean_p"], b["frac_damaged"], s=20 + b["n"] / 3, color=NAVY)
        ax.annotate(f"{b['n']} rows", (b["mean_p"], b["frac_damaged"]), textcoords="offset points",
                    xytext=(8, -12 if b["mean_p"] > 0.5 else 8), fontsize=7)
    ax.set_xlim(-0.05, 1.05), ax.set_ylim(-0.05, 1.05)
    ax.set_xlabel("mean predicted probability (bin)")
    ax.set_ylabel("share of end-stage labels")
    ax.set_title(f"Labelled rows only: 8 of 10 bins are empty (ECE {R2['calibration']['ece_10_bins']:.5f})")
    fig.tight_layout()
    save(fig, "calibration_run2.png")


def add_inputs_to_predictions():
    """Scatter needs x1; the predictions file has no inputs, so read them from the supervised datasets."""
    for e in BEARINGS:
        p = pd.read_csv(RUN2 / f"predictions_{e}.csv")
        if "z_ln_lr_rms" not in p:
            d = pd.read_csv(HERE / "results" / "supervised" / f"dataset_{e}.csv")[["measurement_id", "z_ln_lr_rms"]]
            yield e, p.merge(d, on="measurement_id", how="left")
        else:
            yield e, p


def inputs_figure():
    names = ["z_ln_lr_rms", "z_ln_lr_peak", "z_lr_kurt", "z_ln_band_1k_5k", "z_ln_band_5k_20k", "z_lr_crest", "rpm_z", "temp_resid_z"]
    short = ["x1 ln RMS", "x2 ln peak", "x3 kurtosis", "x4 ln 1-5 kHz", "x5 ln 5-20 kHz", "x6 crest", "x7 RPM", "x8 temp. resid."]
    fig, axs = plt.subplots(1, 3, figsize=(10, 3.3), sharey=True)
    for ax, e in zip(axs, BEARINGS):
        d = pd.read_csv(HERE / "results" / "supervised" / f"dataset_{e}.csv")
        for j, n in enumerate(names):
            for val, col, dx in ((0, BLUE, -0.15), (1, ORANGE, 0.15)):
                v = d[d.y_det == val][n].to_numpy()
                ax.scatter(np.full(len(v), j + dx) + np.random.default_rng(j).normal(0, 0.03, len(v)), v, s=4, color=col, alpha=0.6)
        ax.axhline(16, color=RED, lw=0.8, ls="--")
        ax.set_xticks(range(8), short, rotation=60, ha="right", fontsize=7)
        ax.set_title(e, fontsize=9)
    axs[0].set_ylabel("input value (z, clipped at +-16)")
    axs[0].text(7.4, 16.6, "clip +16", color=RED, fontsize=7, ha="right")
    fig.suptitle("The eight inputs on the labelled rows (blue: healthy labels, orange: end-stage labels)", fontsize=9)
    fig.tight_layout()
    save(fig, "inputs_run2.png")


def variants_figure():
    v = pd.read_csv(RUN2 / "variants.csv")
    order = ["run 1 settings (2,000 steps)", "weight decay 1e-3", "weight decay 1e-2", "weight decay 1e-1", "label smoothing 0.05"]
    g = v.groupby("variant").mean(numeric_only=True).loc[order]
    fig, axs = plt.subplots(1, 3, figsize=(10, 3.2))
    lab = ["run 1\nsettings", "WD\n1e-3", "WD\n1e-2", "WD\n1e-1", "label\nsmooth 0.05"]
    cols = [NAVY, BLUE, BLUE, BLUE, PURPLE]
    for ax, col, title in zip(axs, ("unlatched_state_changes", "mean_abs_logit_middle", "max_p_healthy"),
                              ("Run 1 rule: alarm-state changes", "Mean |logit| on middle rows", "Highest P on a healthy row")):
        ax.bar(range(5), g[col], color=cols)
        for i, val in enumerate(g[col]):
            ax.text(i, val, f"{val:.3g}", ha="center", va="bottom", fontsize=7)
        ax.set_xticks(range(5), lab, fontsize=7)
        ax.set_title(title)
    axs[2].axhline(0.5, color=RED, lw=0.8, ls="--")
    axs[2].text(4.4, 0.47, "threshold", color=RED, fontsize=7, ha="right", va="top")
    fig.suptitle("Diagnostic retrainings (mean over 3 held-out bearings x 3 seeds; not used to pick a model)", fontsize=9)
    fig.tight_layout()
    save(fig, "variants_run2.png")


def int8_figure():
    fig, ax = plt.subplots(figsize=(10, 2.6))
    rows = [(k, v) for k, v in R2["int8"].items() if "rtl" not in k]
    ax.bar(range(len(rows)), [v["decisions_changed"] for _, v in rows], color=NAVY)
    for i, (_, v) in enumerate(rows):
        ax.text(i, v["decisions_changed"], f"{v['decisions_changed']}/{v['rows']}", ha="center", va="bottom", fontsize=6.5)
    ax.set_xticks(range(len(rows)), [k.replace("/seed", " seed ") for k, _ in rows], fontsize=7)
    ax.set_ylim(0, 6.5)
    for s in ("top", "right"):
        ax.spines[s].set_visible(False)
    ax.set_ylabel("rows whose decision changed")
    ax.set_title("INT8 vs FP32: decisions changed (none on labelled rows)")
    fig.tight_layout()
    save(fig, "int8_run2.png")


def confusion_figure():
    """Row-level confusion matrices on the labelled held-out rows (3 bearings x 3 seeds pooled), per detector."""
    dets = [("MLP raw (p > 0.5)", lambda f, s: f["seeds"][str(s)]["run1_alarm"]["labelled_rows_raw_threshold"]),
            ("MLP run 1 rule", lambda f, s: f["seeds"][str(s)]["run1_alarm"]["labelled_rows_alarm"]),
            ("MLP run 2 latched", lambda f, s: f["seeds"][str(s)]["run2_latched_alarm"]["labelled_rows_alarm"]),
            ("Anomaly detector (latched)", lambda f, s: f["reference"][BASE]["latched"]["labelled_rows_alarm"]),
            ("Rig stop rule (latched)", lambda f, s: f["reference"][RIG]["latched"]["labelled_rows_alarm"])]
    fig, axs = plt.subplots(1, len(dets), figsize=(11, 2.6))
    for ax, (name, get) in zip(axs, dets):
        tot = {"tp": 0, "fp": 0, "tn": 0, "fn": 0}
        for e in BEARINGS:
            f = R2["folds"][e]
            for s in (SEEDS if name.startswith("MLP") else (0,)):
                c = get(f, s)
                for k in tot:
                    tot[k] += c[k]
        m = np.array([[tot["tn"], tot["fp"]], [tot["fn"], tot["tp"]]])
        ax.imshow(m > 0, cmap="Blues", vmin=0, vmax=2)
        for (i, j), val in np.ndenumerate(m):
            ax.text(j, i, str(val), ha="center", va="center", fontsize=10, weight="bold", color=NAVY if val else GREY)
        ax.set_xticks([0, 1], ["pred.\nhealthy", "pred.\nend-stage"], fontsize=7)
        ax.set_yticks([0, 1], ["healthy", "end-stage"], fontsize=7)
        ax.grid(False)
        ax.set_title(name, fontsize=8)
    fig.suptitle("Confusion matrices, labelled held-out rows (MLP: 3 bearings x 3 seeds = 945 rows; others: 315 rows)", fontsize=9)
    fig.tight_layout()
    save(fig, "confusion_run2.png")


def main():
    for e, p in add_inputs_to_predictions():
        pass
    alarm_timeline()
    metric_bars()
    # the calibration scatter reads x1 from the dataset files
    global pd_read
    calibration_with_inputs()
    inputs_figure()
    variants_figure()
    int8_figure()
    confusion_figure()
    print(f"figures in {FIG}")


def calibration_with_inputs():
    orig = pd.read_csv

    def read(path, *a, **k):
        df = orig(path, *a, **k)
        name = Path(str(path)).name
        if name.startswith("predictions_") and Path(str(path)).parent == RUN2:
            e = name[len("predictions_"):-4]
            d = orig(HERE / "results" / "supervised" / f"dataset_{e}.csv")[["measurement_id", "z_ln_lr_rms"]]
            df = df.merge(d, on="measurement_id", how="left")
        return df
    pd.read_csv = read
    try:
        calibration()
    finally:
        pd.read_csv = orig


if __name__ == "__main__":
    main()
