"""Training Run 3 analysis tables and figures (inside model/; after run3_prep.py and train_deterioration_run3.py):

  python report/run3_figures.py   -> results/supervised/run3/analysis/ (analysis.json, figures/*.png)

Everything is computed from results/supervised/run3/prep/ and train/ (and Run 1-2's results for the comparison).
"""
import json, sys
from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from scipy.stats import spearmanr

HERE = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(HERE))
RUN3 = HERE / "results" / "supervised" / "run3"
PREP, TRAIN, AN = RUN3 / "prep", RUN3 / "train", RUN3 / "analysis"
FIG = AN / "figures"
BEARINGS = ("B02", "B03", "B04", "B08", "B09", "B11", "B12")
NEW = ("B08", "B09", "B11", "B12")
SEEDS = (0, 1, 2, 3, 4)
NAMES = ["z_ln_lr_rms", "z_ln_lr_peak", "z_lr_kurt", "z_ln_band_1k_5k", "z_ln_band_5k_20k", "z_lr_crest", "rpm_z", "temp_resid_z"]
SHORT = ["x1 ln RMS", "x2 ln peak", "x3 kurtosis", "x4 ln 1-5 kHz", "x5 ln 5-20 kHz", "x6 crest", "x7 RPM", "x8 temp."]
CFGS = ["A_run12", "B_wd", "C_wd_slog", "D_wd_noT", "E_wd_slog_noT"]
CLAB = {"A_run12": "A: Run 1-2 settings", "B_wd": "B: weight decay 0.01", "C_wd_slog": "C: B + log inputs",
        "D_wd_noT": "D: B, no temperature", "E_wd_slog_noT": "E: C + D"}
NAVY, BLUE, LBLUE, ORANGE, GREEN, RED, PURPLE, GREY = "#1f3a5f", "#2f7fbf", "#e8f1fb", "#e07b28", "#2e8b57", "#c0392b", "#7b4fa8", "#9a9a94"
CCOL = {"A_run12": GREY, "B_wd": NAVY, "C_wd_slog": BLUE, "D_wd_noT": PURPLE, "E_wd_slog_noT": ORANGE}
plt.rcParams.update({"font.family": "DejaVu Sans", "font.size": 9, "axes.spines.top": False, "axes.spines.right": False,
                     "axes.titleweight": "bold", "axes.titlesize": 9.5, "axes.grid": True, "grid.color": "#e6e6e2",
                     "grid.linewidth": 0.7, "axes.axisbelow": True})


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


def ds(e):
    return pd.read_csv(PREP / f"dataset_{e}.csv", parse_dates=["timestamp"])


# ---------------------------------------------------------------- dataset

def dataset_overview():
    fig, axs = plt.subplots(len(BEARINGS), 1, figsize=(10, 1.75 * len(BEARINGS)))
    for ax, e in zip(axs, BEARINGS):
        d = ds(e)
        t = (d.timestamp - d.timestamp.iloc[0]).dt.total_seconds() / 3600
        ax.plot(t, d.rear_rms_g, ".", ms=1.5, color=GREY)
        for v, c in ((0, GREEN), (1, ORANGE)):
            k = d.y_det == v
            ax.plot(t[k], d.rear_rms_g[k], ".", ms=3.5, color=c)
        ax.axhline(6.5, color=RED, lw=0.7, ls="--")
        ax.set_yscale("log")
        ax.set_ylabel(f"{e}\nrear RMS (g)", fontsize=8)
        ax.text(0.995, 0.08, f"{len(d)} operating measurements" + ("  (new)" if e in NEW else ""),
                transform=ax.transAxes, ha="right", fontsize=7, color=NAVY if e in NEW else GREY)
    axs[-1].set_xlabel("hours since the first operating measurement (green: healthy labels; orange: end-stage labels; "
                       "red dashed: 6.5 g)")
    fig.tight_layout()
    save(fig, "dataset_overview_run3.png")


def clipping():
    """How much the +-16 clip hides: raw z beyond the clip, per bearing and input, and whether it keeps rising."""
    out = {}
    fig, axs = plt.subplots(len(BEARINGS), 1, figsize=(10, 1.7 * len(BEARINGS)), sharex=False)
    for ax, e in zip(axs, BEARINGS):
        d = ds(e)
        out[e] = {}
        for n in NAMES[:6]:
            r = d[f"raw_{n}"].to_numpy()
            over = np.abs(r) > 16
            mid = d.y_det.isna().to_numpy()
            k = np.flatnonzero(over)
            rho = float(spearmanr(np.arange(len(k)), r[k]).statistic) if len(k) > 10 else None
            out[e][n] = {"rows_clipped": int(over.sum()), "share_clipped": float(over.mean()),
                         "share_middle_clipped": float(over[mid].mean()), "max_abs_raw": float(np.nanmax(np.abs(r))),
                         "end_stage_median_raw": float(np.median(r[d.y_det == 1])),
                         "spearman_raw_vs_order_among_clipped": rho,
                         "first_clipped_id": int(d.measurement_id.iloc[k[0]]) if len(k) else None}
        t = (d.timestamp - d.timestamp.iloc[0]).dt.total_seconds() / 3600
        ax.plot(t, d.raw_z_ln_lr_rms, ".", ms=1.5, color=NAVY, label="x1 raw (unclipped)")
        ax.plot(t, d.z_ln_lr_rms, ".", ms=1.0, color=ORANGE, alpha=0.5, label="x1 as the network sees it (clip +-16)")
        ax.axhline(16, color=RED, lw=0.7, ls="--")
        ax.set_yscale("symlog", linthresh=4)
        ax.set_ylabel(e, fontsize=8)
        ax.text(0.995, 0.08, f"{out[e]['z_ln_lr_rms']['share_clipped']:.0%} of rows clipped; raw max "
                f"{out[e]['z_ln_lr_rms']['max_abs_raw']:.0f}", transform=ax.transAxes, ha="right", fontsize=7)
    axs[0].legend(fontsize=7, loc="upper left", frameon=False)
    axs[-1].set_xlabel("hours since the first operating measurement (symlog scale; red dashed: the +16 clip)")
    fig.tight_layout()
    save(fig, "clipping_run3.png")
    return out


# ---------------------------------------------------------------- results

def load_results():
    return json.loads((TRAIN / "results.json").read_text())


def outer_table(R):
    rows = []
    for r in R["outer"]:
        m = r["metrics"]
        L, U = m["latched"], m["unlatched"]
        rows.append({"cfg": r["cfg"], "bearing": r["held_out"], "seed": r["seed"],
                     "first_id": L["first_alarm_id"], "first_time": L["first_alarm_time"],
                     "min_before_end": L["first_alarm_min_before_last_record"],
                     "changes_latched": L["alarm_state_changes"], "changes_unlatched": U["alarm_state_changes"],
                     "healthy_above": L["healthy_rows_above_threshold"], "healthy_alarmed": L["healthy_rows_alarmed"],
                     "end_recall": L["end_recall"], "middle_alarmed": L["middle_alarmed_fraction"],
                     "tp": L["labelled_rows_alarm"]["tp"], "fp": L["labelled_rows_alarm"]["fp"],
                     "tn": L["labelled_rows_alarm"]["tn"], "fn": L["labelled_rows_alarm"]["fn"],
                     "raw_tp": L["labelled_rows_raw_threshold"]["tp"], "raw_fp": L["labelled_rows_raw_threshold"]["fp"],
                     "raw_tn": L["labelled_rows_raw_threshold"]["tn"], "raw_fn": L["labelled_rows_raw_threshold"]["fn"],
                     "max_p_healthy": m["prob"]["max_p_healthy"], "min_p_damaged": m["prob"]["min_p_damaged"],
                     "logloss": m["prob"]["logloss_labelled"], "brier": m["prob"]["brier_labelled"],
                     "mid_between": m["share_mid_between_0.05_0.95"], "mid_above": m["prob"]["middle_fraction_above_0.5"],
                     "final_train_loss": r["final_train_loss"],
                     "int8_changed": r["int8"]["decisions_changed"], "int8_changed_lab": r["int8"]["decisions_changed_labelled"],
                     "int8_first_same": r["int8"]["latched_first_alarm_fp32"] == r["int8"]["latched_first_alarm_int8"],
                     "int8_rows": r["int8"]["rows"], "int8_logit_mae": r["int8"]["logit_mean_abs_err"],
                     "int8_logit_max": r["int8"]["logit_max_abs_err"], "int8_rail_rows": r["int8"]["inputs_at_int8_rail"],
                     "x8zero_first": (r.get("x8_zeroed") or {}).get("latched", {}).get("first_alarm_id"),
                     "x8zero_sep": (r.get("x8_zeroed") or {}).get("prob", {}).get("labelled_separated")})
    T = pd.DataFrame(rows).drop(columns=["int8_changed", "int8_changed_lab", "int8_first_same", "int8_rows", "int8_logit_mae",
                                        "int8_logit_max", "int8_rail_rows"])
    hw = pd.read_csv(RUN3 / "hardware" / "int8_outer.csv").rename(columns={"held_out": "bearing"})
    hw = hw.assign(int8_changed=hw.decisions_changed, int8_changed_lab=hw.decisions_changed_labelled,
                   int8_first_same=hw.latched_first_alarm_fp32.fillna(-1) == hw.latched_first_alarm_int8.fillna(-1),
                   int8_rows=hw.rows, int8_logit_mae=hw.logit_mean_abs_err, int8_logit_max=hw.logit_max_abs_err,
                   int8_rail_rows=hw.rows_at_int8_input_rail)
    keep = ["cfg", "bearing", "seed", "int8_changed", "int8_changed_lab", "int8_first_same", "int8_rows", "int8_logit_mae",
            "int8_logit_max", "int8_rail_rows", "latched_states_differ"]
    return T.merge(hw[keep], on=["cfg", "bearing", "seed"], how="left")   # INT8 from hardware v2 (dead-neuron fix)


def pooled_scores(T):
    out = {}
    for c in CFGS:
        t = T[T.cfg == c]
        for kind, (tp, fp, tn, fn) in (("alarm", ("tp", "fp", "tn", "fn")), ("raw", ("raw_tp", "raw_fp", "raw_tn", "raw_fn"))):
            TP, FP, TN, FN = (int(t[k].sum()) for k in (tp, fp, tn, fn))
            P = TP / (TP + FP) if TP + FP else float("nan")
            Rc = TP / (TP + FN) if TP + FN else float("nan")
            out[(c, kind)] = {"tp": TP, "fp": FP, "tn": TN, "fn": FN, "accuracy": (TP + TN) / (TP + FP + TN + FN),
                              "precision": P, "recall": Rc, "f1": 2 * P * Rc / (P + Rc) if P + Rc else float("nan")}
    return out


def ref_rows(R):
    rows = []
    for e, refs in R["references"].items():
        for name, v in refs.items():
            if v is None:
                rows.append({"bearing": e, "detector": name, "available": False})
                continue
            L = v["latched"]
            rows.append({"bearing": e, "detector": name, "available": True, "first_id": L["first_alarm_id"],
                         "first_time": L["first_alarm_time"], "min_before_end": L["first_alarm_min_before_last_record"],
                         "changes": L["alarm_state_changes"], "changes_unlatched": v["unlatched"]["alarm_state_changes"],
                         "healthy_above": L["healthy_rows_above_threshold"], "healthy_alarmed": L["healthy_rows_alarmed"],
                         "end_recall": L["end_recall"], "middle_alarmed": L["middle_alarmed_fraction"],
                         "tp": L["labelled_rows_alarm"]["tp"], "fp": L["labelled_rows_alarm"]["fp"],
                         "tn": L["labelled_rows_alarm"]["tn"], "fn": L["labelled_rows_alarm"]["fn"]})
    return pd.DataFrame(rows)


def fig_curves():
    c = pd.read_csv(TRAIN / "curves.csv")
    fig, axs = plt.subplots(1, 3, figsize=(11, 3.2))
    for cfg in CFGS:
        g = c[c.cfg == cfg].groupby("step").mean(numeric_only=True)
        axs[0].plot(g.index, g.train_loss, color=CCOL[cfg], label=CLAB[cfg])
        axs[1].plot(g.index, g.val_loss_labelled, color=CCOL[cfg])
        axs[2].plot(g.index, g.val_mean_abs_logit_all, color=CCOL[cfg])
    for ax, t in zip(axs, ("Training loss (mean, 7 folds x 5 seeds)", "Validation loss on the held-out bearing's\nlabelled rows (reporting only)",
                           "Mean |logit| on every held-out row")):
        ax.set_title(t, fontsize=8.5)
        ax.set_xlabel("step")
    axs[0].set_yscale("log"), axs[1].set_yscale("log")
    axs[0].legend(fontsize=6.5, frameon=False)
    fig.tight_layout()
    save(fig, "learning_curves_run3.png")
    fig, axs = plt.subplots(1, len(BEARINGS), figsize=(13, 2.5), sharey=True)
    for ax, e in zip(axs, BEARINGS):
        for cfg in ("A_run12", "B_wd"):
            g = c[(c.cfg == cfg) & (c.held_out == e)].groupby("step").mean(numeric_only=True)
            ax.plot(g.index, g.val_loss_labelled, color=CCOL[cfg], label=CLAB[cfg])
        ax.set_yscale("log"), ax.set_title(e, fontsize=8.5), ax.set_xlabel("step", fontsize=7)
    axs[0].set_ylabel("validation loss (labelled)", fontsize=7.5)
    axs[0].legend(fontsize=6, frameon=False)
    fig.tight_layout()
    save(fig, "validation_loss_per_bearing_run3.png")


def fig_timeline(R, cfg_show):
    fig, axs = plt.subplots(len(BEARINGS), 1, figsize=(10.5, 1.95 * len(BEARINGS)))
    for ax, e in zip(axs, BEARINGS):
        p = pd.read_csv(TRAIN / "predictions" / cfg_show / f"predictions_{e}.csv")
        d = ds(e)
        ids, y = p.measurement_id.to_numpy(), p.y_det.to_numpy()
        rows = [(f"MLP {cfg_show} seed {s}", p[f"alarm_latched_seed{s}"].astype(bool).to_numpy(), NAVY) for s in SEEDS]
        rows.append(("anomaly A|F42|speed", latched(d.score_F42 > d.tau_F42), GREEN))
        if np.isfinite(d.score_F128).all():
            rows.append(("anomaly A|F128|speed", latched(d.score_F128 > d.tau_F128), "#6aa84f"))
        rows.append(("rig rule (> 6.5 g)", latched(d.rear_rms_g > 6.5), RED))
        w = np.median(np.diff(ids))
        for v, c in ((0, BLUE), (1, ORANGE)):
            for a, n in runs(y == v):
                ax.axvspan(ids[a] - w / 2, ids[a + n - 1] + w / 2, color=c, alpha=0.16, lw=0)
        for k, (name, st, col) in enumerate(rows):
            ax.broken_barh([(ids[a] - w / 2, n * w) for a, n in runs(st)], (k - 0.36, 0.72), color=col)
        ax.set_yticks(range(len(rows)), [r[0] for r in rows], fontsize=6.3)
        ax.set_ylim(len(rows) - 0.5, -0.5), ax.set_xlim(ids[0] - w, ids[-1] + w), ax.grid(axis="y", visible=False)
        ax.set_title(f"{e}{' (new)' if e in NEW else ''}: latched alarms", fontsize=8.5)
    axs[-1].set_xlabel("measurement id (blue band: healthy labels; orange band: end-stage labels)")
    fig.tight_layout()
    save(fig, f"alarm_timeline_{cfg_show}_run3.png")


def fig_scores(cfg_show):
    fig, axs = plt.subplots(2, 4, figsize=(11, 4.6))
    for ax, e in zip(axs.ravel(), BEARINGS):
        p = pd.read_csv(TRAIN / "predictions" / cfg_show / f"predictions_{e}.csv")
        pm = p[[f"p_seed{s}" for s in SEEDS]].mean(axis=1)
        y = p.y_det
        ax.plot(p.measurement_id[y.isna()], pm[y.isna()], ".", ms=1.5, color=GREY)
        ax.plot(p.measurement_id[y == 0], pm[y == 0], ".", ms=2.5, color=BLUE)
        ax.plot(p.measurement_id[y == 1], pm[y == 1], "o", ms=3, color=ORANGE)
        ax.axhline(0.5, color=RED, lw=0.7, ls="--")
        ax.set_ylim(-0.03, 1.03), ax.set_title(e, fontsize=8.5)
    ax = axs.ravel()[-1]
    allp = np.concatenate([pd.read_csv(TRAIN / "predictions" / cfg_show / f"predictions_{e}.csv")[[f"p_seed{s}" for s in SEEDS]].to_numpy().ravel()
                           for e in BEARINGS])
    ax.hist(np.clip(np.log10(np.clip(allp, 1e-12, 1)), -12, 0), 48, color=NAVY)
    ax.set_title("all held-out scores: log10 p", fontsize=8.5), ax.set_yscale("log")
    fig.suptitle(f"Raw deterioration score on each held-out bearing ({CLAB[cfg_show]}, seed mean; grey: unlabelled)", fontsize=9)
    fig.tight_layout()
    save(fig, f"scores_{cfg_show}_run3.png")


def fig_compare(T, REF):
    fig, axs = plt.subplots(1, 2, figsize=(11, 3.6))
    x = np.arange(len(BEARINGS))
    for i, cfg in enumerate(CFGS):
        g = T[T.cfg == cfg].groupby("bearing").min_before_end
        mean = np.nan_to_num([g.get_group(e).mean() for e in BEARINGS])
        lo = np.nan_to_num([g.get_group(e).min() for e in BEARINGS])
        hi = np.nan_to_num([g.get_group(e).max() for e in BEARINGS])
        axs[0].bar(x + (i - 2.5) * 0.13, mean, 0.13, color=CCOL[cfg], label=CLAB[cfg],
                   yerr=[np.maximum(mean - lo, 0), np.maximum(hi - mean, 0)], error_kw={"lw": 0.6}, capsize=1.5)
    axs[0].text(6 - 0.15, 12, "MLP:\nno alarm", fontsize=6.5, color=RED, ha="center")
    f42 = [REF[(REF.bearing == e) & (REF.detector == "anomaly A|F42|speed")].min_before_end.iloc[0] for e in BEARINGS]
    axs[0].bar(x + 3.5 * 0.13, f42, 0.13, color=GREEN, label="anomaly A|F42|speed")
    axs[0].set_xticks(x, BEARINGS), axs[0].set_yscale("log")
    axs[0].set_title("First alarm: minutes before the last record (log scale; not a lead time to failure)", fontsize=8.5)
    axs[0].legend(fontsize=6.3, frameon=False, ncol=2)
    for i, cfg in enumerate(CFGS):
        g = T[T.cfg == cfg].groupby("bearing").changes_unlatched.mean()
        axs[1].bar(x + (i - 2) * 0.15, [g[e] for e in BEARINGS], 0.15, color=CCOL[cfg])
    axs[1].set_xticks(x, BEARINGS)
    axs[1].set_title("Alarm-state changes WITHOUT the latch (stability of the raw score)", fontsize=8.5)
    fig.tight_layout()
    save(fig, "compare_candidates_run3.png")


def fig_confusion(P):
    fig, axs = plt.subplots(1, 5, figsize=(12, 2.6))
    for ax, cfg in zip(axs, CFGS):
        s = P[(cfg, "alarm")]
        m = np.array([[s["tn"], s["fp"]], [s["fn"], s["tp"]]])
        ax.imshow(m > 0, cmap="Blues", vmin=0, vmax=2)
        for (i, j), v in np.ndenumerate(m):
            ax.text(j, i, str(v), ha="center", va="center", fontsize=10, weight="bold", color=NAVY if v else GREY)
        ax.set_xticks([0, 1], ["pred.\nhealthy", "pred.\nend-stage"], fontsize=7), ax.set_yticks([0, 1], ["healthy", "end-stage"], fontsize=7)
        ax.grid(False), ax.set_title(CLAB[cfg], fontsize=7.8)
    fig.suptitle("Latched alarm on the labelled held-out rows, 7 bearings x 5 seeds = 3,675 rows per candidate", fontsize=9)
    fig.tight_layout()
    save(fig, "confusion_run3.png")


def fig_int8(T):
    fig, ax = plt.subplots(figsize=(10, 2.9))
    x = np.arange(len(BEARINGS))
    for i, c in enumerate(CFGS):
        g = T[T.cfg == c].groupby("bearing")
        share = [100 * g.get_group(e).int8_changed.sum() / g.get_group(e).int8_rows.sum() for e in BEARINGS]
        ax.bar(x + (i - 2) * 0.16, share, 0.16, color=CCOL[c], label=CLAB[c])
    ax.set_xticks(x, BEARINGS)
    ax.set_ylabel("% of rows whose decision changed")
    ax.set_title("INT8 vs FP32 on every held-out row (5 seeds pooled; hardware v2). Labelled rows changed: "
                 + ", ".join(f"{c.split('_')[0]} {int(T[T.cfg == c].int8_changed_lab.sum())}" for c in CFGS), fontsize=8.5)
    ax.legend(fontsize=6.5, frameon=False, ncol=3)
    fig.tight_layout()
    save(fig, "int8_run3.png")


def fig_runs(T, REF):
    """Run 1 / Run 2 / Run 3 on B02-B04 (the only bearings Runs 1-2 saw), latched first alarm and unlatched changes."""
    r2 = json.loads((HERE / "results" / "supervised" / "run2" / "results.json").read_text())
    fig, axs = plt.subplots(1, 2, figsize=(10.5, 3.2))
    x = np.arange(3)
    groups = [("Run 1/2 (2 training bearings)", NAVY + "55",
               lambda e, k: [r2["folds"][e]["seeds"][str(s)]["run2_latched_alarm" if k == "min" else "run1_alarm"]
                             ["first_alarm_min_before_last_record" if k == "min" else "alarm_state_changes"] for s in (0, 1, 2)]),
              ("Run 3 A: same settings, 6 training bearings", GREY,
               lambda e, k: T[(T.cfg == "A_run12") & (T.bearing == e)]["min_before_end" if k == "min" else "changes_unlatched"].tolist()),
              ("Run 3 E: selected", ORANGE,
               lambda e, k: T[(T.cfg == "E_wd_slog_noT") & (T.bearing == e)]["min_before_end" if k == "min" else "changes_unlatched"].tolist())]
    for j, k in enumerate(("min", "chg")):
        for i, (lab, col, get) in enumerate(groups):
            v = [np.mean(get(e, k)) for e in ("B02", "B03", "B04")]
            axs[j].bar(x + (i - 1.5) * 0.2, v, 0.2, color=col, label=lab)
        if k == "min":
            f42 = [REF[(REF.bearing == e) & (REF.detector == "anomaly A|F42|speed")].min_before_end.iloc[0] for e in ("B02", "B03", "B04")]
            axs[j].bar(x + 1.5 * 0.2, f42, 0.2, color=GREEN, label="anomaly A|F42|speed")
        axs[j].set_xticks(x, ["B02", "B03", "B04"])
    axs[0].set_title("Latched first alarm, minutes before the last record", fontsize=8.5)
    axs[1].set_title("Alarm-state changes without the latch", fontsize=8.5)
    axs[0].legend(fontsize=6.3, frameon=False)
    fig.tight_layout()
    save(fig, "runs_compare_run3.png")


def main():
    AN.mkdir(parents=True, exist_ok=True)
    dataset_overview()
    clip = clipping()
    R = load_results()
    T = outer_table(R)
    REF = ref_rows(R)
    P = pooled_scores(T)
    T.to_csv(AN / "outer_metrics.csv", index=False, float_format="%.6g")
    REF.to_csv(AN / "reference_metrics.csv", index=False, float_format="%.6g")
    fig_curves()
    for c in sorted({R["final_cfg"], "B_wd"}):
        fig_timeline(R, c)
        fig_scores(c)
    fig_compare(T, REF)
    fig_confusion(P)
    fig_int8(T)
    fig_runs(T, REF)
    out = {"clipping": clip, "pooled_scores": {f"{c}|{k}": v for (c, k), v in P.items()}}
    (AN / "analysis.json").write_text(json.dumps(out, indent=1, default=str) + "\n", encoding="utf-8")
    print(f"analysis in {AN}")


if __name__ == "__main__":
    main()
