"""Rebuilds the report (HTML and PDF) from the saved results. Nothing is trained or recomputed here.

  model/.venv/bin/python modelV2/report.py        ->  modelV2/report/report.html and report.pdf
"""
import html, json, os

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from matplotlib.patches import FancyBboxPatch
from reportlab.lib import colors
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import getSampleStyleSheet
from reportlab.platypus import Image, Paragraph, SimpleDocTemplate, Spacer, Table

import config as c
import page
import pipeline as F
import anomaly_baseline as ab                      # model/: colours

FIGS = c.REPORT / "figs"
LEVELS = "Normal, Anomaly, Warning, Failing"


def save(fig, name):
    path = c.writable(FIGS / name)
    fig.savefig(path, dpi=140)
    plt.close(fig)
    return path


def boxes(labels, name, colours=None, size=(11, 1.6)):
    """A left-to-right chain of boxes with arrows."""
    fig, ax = plt.subplots(figsize=size)
    for i, text in enumerate(labels):
        ax.add_patch(FancyBboxPatch((i * 1.25, 0), 1, 1, boxstyle="round,pad=0.03", fc=(colours or {}).get(i, "#eef3fb"),
                                    ec=ab.INK2))
        ax.text(i * 1.25 + 0.5, 0.5, text, ha="center", va="center", fontsize=8)
        if i:
            ax.annotate("", (i * 1.25 - 0.03, 0.5), (i * 1.25 - 0.22, 0.5), arrowprops={"arrowstyle": "->", "color": ab.INK2})
    ax.set_xlim(-0.1, len(labels) * 1.25)
    ax.set_ylim(-0.15, 1.15)
    ax.axis("off")
    fig.tight_layout()
    return save(fig, name)


def split_figure(folds):
    groups = [("Paderborn, training and validation\n(each held out once)", [f["pad"] for f in folds], ab.BLUE),
              ("Paderborn, locked test", c.PAD_LOCKED, "#b3261e"),
              ("Ottawa, version B training and\nvalidation (held out in turn)", [str(n) for n in c.OTT_DEV], ab.ORANGE),
              ("Ottawa, locked test", [str(n) for n in c.OTT_LOCKED], "#b3261e")]
    fig, ax = plt.subplots(figsize=(11, 2.6))
    for r, (label, items, col) in enumerate(groups):
        ax.text(-0.2, -r, label, ha="right", va="center", fontsize=8)
        for i, b in enumerate(items):
            ax.add_patch(FancyBboxPatch((i * 0.62, -r - 0.32), 0.55, 0.64, boxstyle="round,pad=0.02", fc=col, alpha=0.75, ec="none"))
            ax.text(i * 0.62 + 0.275, -r, b, ha="center", va="center", fontsize=8, color="white")
    ax.set_xlim(-4.2, 10.2)
    ax.set_ylim(-len(groups) + 0.4, 0.6)
    ax.axis("off")
    fig.tight_layout()
    return save(fig, "split.png")


def feature_figure(rows):
    b = rows["bearing"][rows["ds"] == 0][0]
    m = rows["bearing"] == b
    fig, axs = plt.subplots(2, 1, figsize=(11, 5), sharex=True)
    for j, n in enumerate(F.NAMES):
        axs[0].plot(rows["minutes"][m], F.slog(rows["Z"][m][:, j]), linewidth=0.7, label=n)
    axs[0].legend(ncol=7, fontsize=7)
    axs[0].set_ylabel("z-feature (after slog)")
    axs[1].semilogy(rows["minutes"][m], rows["s"][m] / rows["tau"][m], ".", ms=2, color=ab.MUTED)
    axs[1].axhline(1, color=ab.ORANGE, linewidth=1)
    axs[1].axvline(rows["minutes"][m][np.argmax(rows["post"][m])], color=ab.AQUA, linestyle="--")
    axs[1].set_ylabel("detector score / threshold")
    axs[1].set_xlabel(f"{b}: operating minutes (dashed: the detector's sustained onset)")
    fig.tight_layout()
    return save(fig, "features.png")


def confusion_figure(conf, name):
    fig, ax = plt.subplots(figsize=(4.2, 3.4))
    ax.imshow(conf, cmap="Blues")
    for i in range(3):
        for j in range(3):
            ax.text(j, i, conf[i][j], ha="center", va="center")
    ax.set_xticks(range(3), ["healthy", "developing", "faulty"])
    ax.set_yticks(range(3), ["healthy", "developing", "faulty"])
    ax.set_xlabel("network says")
    ax.set_ylabel("Ottawa stage")
    ax.grid(False)
    fig.tight_layout()
    return save(fig, name)


def build():
    """The report as a list of ("h1" | "h2" | "p" | "img" | "table", content)."""
    rows = dict(np.load(c.DATA / "rows.npz"))
    summary = json.loads((c.DATA / "summary.json").read_text())
    folds = json.loads((c.DATA / "folds.json").read_text())
    pre = json.loads((c.PRECHECKS / "prechecks.json").read_text())
    comp = json.loads((c.REPORT / "comparison.json").read_text()) if (c.REPORT / "comparison.json").exists() else {}
    runs = [d for d in sorted(c.RUNS.iterdir()) if d.name in comp     # evaluated against the current data
            and not json.loads((d / "config.json").read_text())["quick"]] if c.RUNS.exists() else []
    temp = summary["ottawa_temperature"]
    sizes = [len(c.INPUTS), *c.HIDDEN, 4]
    weights = sum(a * b for a, b in zip(sizes, sizes[1:]))
    pad, ott = rows["ds"] == 0, rows["ds"] == 1
    D = [("h1", "Machine Guardian modelV2: bearing status and health on the MAC accelerator"),
         ("p", "A vibration sensor on a motor bearing is measured for 1.6 s at a time. A host processor turns each measurement "
               "into 13 numbers that say how far the bearing has moved from its own healthy start. A small neural network on "
               "the chip (the INT8 systolic-array MLP accelerator) turns those numbers into a status (healthy, developing or faulty) and a "
               f"health value. The host combines them into one of four levels ({LEVELS}) and a health percentage."),
         ("img", boxes(["accelerometer\nrpm sensor\ntemperature", "42 kHz, 15 kHz\nlow-pass, 1.6 s", "7 features", "z-features vs\nown healthy\nbaseline",
                        f"chip: MLP\n{' - '.join(map(str, sizes))}\nINT8", "status ladder\nhealth %", "status, health %\n+ temperature\nwarning (host)"],
                       "system.png", {4: "#fde8dc"})),
         ("h2", "1. Data"),
         ("table", [["dataset", "role", "bearings", "recordings", "rows / windows", "sample rate", "resampled"],
                    ["Paderborn run-to-failure", "trains both heads; validation", len(folds), int(pad.sum()), int(pad.sum()), "128 or 64 kHz", "to 42 kHz"],
                    ["Ottawa UORED-VAFCLS", "trains the status head in version B only; validation", len(c.OTT_DEV), 3 * len(c.OTT_DEV), int(ott.sum()), "42 kHz", "no"]]),
         ("p", "Both datasets go through the same signal chain: the offset is removed, the signal is resampled to 42 kHz with an "
               "anti-aliasing filter where needed, and low-passed at 15 kHz. A Paderborn row is one 1.6-s measurement taken "
               "every 12 to 23 s until the bearing fails. An Ottawa recording is 10 s long and is cut into 1.6-s windows with "
               "50 % overlap; each bearing has one healthy, one developing and one faulty recording. The Ottawa files also "
               f"have a temperature-difference column (median by stage {temp['median_by_stage']}); it is not used, and it is "
               f"corrupt in {len(temp['corrupt_recordings'])} recordings ({', '.join(temp['corrupt_recordings'])})."),
         ("table", [["Paderborn bearing", "rows", "healthy (label)", "faulty (label)", "unlabelled", "baseline starts at row",
                     "onset, min before end"]]
          + [[b, i["rows"], int(((rows["bearing"] == b) & (rows["y"] == 0)).sum()), int(((rows["bearing"] == b) & (rows["y"] == 2)).sum()),
              int(((rows["bearing"] == b) & (rows["y"] == -1)).sum()), i["reference_start"], f"{i['onset_min_before_end']:.0f}"]
             for b, i in summary["paderborn"].items()]),
         ("p", "Healthy = the 100 baseline measurements and the 50 after them. Faulty = the last 20 measurements before the "
               "documented stop; these are the labels every result is scored on. "
               + ("For training only, every measurement after the detector's sustained onset is also labelled faulty, so the "
                  "network learns moderate, sustained damage as well as the end stage. " if c.FAULTY_FROM_ONSET else
                  "Everything between is unlabelled for the status head. ") + "Ottawa windows: "
               + ", ".join(f"{int((ott & (rows['y'] == k)).sum())} {n}" for k, n in enumerate(["healthy", "developing", "faulty"])) + "."
               + (f" MISSING raw data, not in this report: {summary['missing']}." if summary["missing"] else "")),
         ("h2", "2. Training, validation and test split"),
         ("img", split_figure(folds)),
         ("p", "The bearing is the unit: all rows of a bearing are in the same set. Validation is leave-one-bearing-out: each "
               "Paderborn development bearing is held out once and scored by networks that never saw it. The locked bearings "
               "are not loaded by any script until a model is frozen, and are then tested once. Version A trains on Paderborn "
               "only. Version B also trains the status head on the Ottawa development bearings, held out in the same folds."),
         ("h2", "3. Features and network inputs"),
         ("table", [["feature (per 1.6-s window)", "formula"], ["rms", "ln of the root-mean-square"], ["peak", "ln of the largest |x|"],
                    ["kurt", "mean((x - mean)^4) / rms^4"], ["crest", "peak / rms"], ["band_10_1k", "ln RMS of the 10 Hz - 1 kHz band (FFT)"],
                    ["band_1k_5k", "ln RMS of the 1 - 5 kHz band"], ["band_5k_15k", "ln RMS of the 5 - 15 kHz band"]]),
         ("p", "Baseline: on a bearing's first 100 measurements each feature is fitted as b0 + b1 ln(rpm) (the rpm term only if "
               "the speed varied), with spread sigma. A step inside those 100 measurements restarts the baseline after the step. "
               "z = (feature - fit) / sigma. The detector score is s = sqrt(mean(z^2)); its threshold tau is the 99th percentile "
               f"of s on the baseline. The {len(c.INPUTS)} network inputs are: the 7 z-features; 3 ln(s); the mean of z over the "
               "last 4 measurements for rms, band_1k_5k, band_5k_15k and kurt; and 4 ln(rpm / 2000). Each goes through "
               "slog(v) = sign(v) ln(1 + |v|). There is no time, row-number or temperature input. An Ottawa bearing has no "
               "100-measurement start: its baseline is the 5 windows in the first 5 s of its healthy recording, with no rpm "
               "term, and the 4 windows in the last 5 s are its healthy examples. So short a baseline under-estimates the "
               f"spread, so sigma is never allowed below a fixed floor per feature {dict(zip(F.NAMES, c.SIGMA_FLOOR))} "
               "(the smallest baseline sigma seen on the Paderborn development bearings, which it therefore leaves unchanged)."),
         ("img", feature_figure(rows)),
         ("h2", "4. Model"),
         ("img", boxes([f"{sizes[0]} inputs\nINT8", f"Linear {sizes[0]}x{sizes[1]}\nReLU", f"Linear {sizes[1]}x{sizes[2]}\nReLU",
                        f"Linear {sizes[2]}x4\n(both heads)", "3 status logits\n1 health logit"], "architecture.png", size=(9, 1.5))),
         ("p", f"{weights} weights and {sum(sizes[1:])} biases. On the chip: INT8 weights with one scale per output channel, INT32 "
               f"biases, one input scale ({c.S_X:.5f} per step), ReLU, and a per-channel multiply-and-shift between layers. The last "
               "layer returns raw sums; the host adds its bias and scale. 'Developing' is labelled only in Ottawa, so only "
               "version B can learn it; Ottawa never trains the health head."),
         ("p", f"Host logic, per measurement. Normal: detector score at or below its threshold. Anomaly: score above the "
               f"threshold on this measurement; clears itself. Warning: score above the threshold {c.WARN_N} measurements in a "
               f"row; clears after {c.WARN_CLEAR} quiet ones. Failing: the network says 'faulty' {c.FAIL_N} measurements in a "
               f"row; stays on. Health %: 100 x sigmoid(health logit), median of the last {c.HIST} measurements, shown as a running "
               "minimum so it never rises. Temperature (separate, not a network input): on when the housing temperature is more "
               f"than {c.TEMP_RISE_C:.0f} C above its own median over the previous {c.TEMP_WINDOW} measurements, 3 in a row; the "
               f"first {c.TEMP_SETTLE_MIN} minutes after a start or stop are ignored."),
         ("table", [["bearing", "temperature rule on before onset (rows / rows)", "first on, min before the end"]]
          + [[b, f"{t['rows_on_before_onset']}/{t['rows_before_onset']}",
              "never" if t["first_on_min_before_end"] is None else f"{t['first_on_min_before_end']:.0f}"]
             for b, t in comp.get("temperature", {}).items()]),
         ("h2", "5. Training loop"),
         ("p", f"1. A batch of {c.BATCH} rows is drawn: half with a status label (every dataset-and-class group equally likely), half with a "
               "health target (before and after onset equally likely). 2. Each row's history length is drawn from 1 to 4. "
               "3. Loss = cross-entropy over the 3 status logits on the status half + mean squared error between "
               "sigmoid(health logit) and the health target on the health half; each half trains only its own head, so the "
               "health head is trained identically in versions A and B. Validation losses are class-balanced the same way. "
               f"4. Adam, learning rate {c.LR} falling to 0 on a cosine, weight decay {c.WD}, {c.STEPS} steps, no early "
               f"stopping. 5. Repeated for every held-out bearing and seeds {list(c.SEEDS)}, plus one network per seed on all "
               "development bearings (the exported one). Health target = severity of the detector score (median of the last 4 "
               f"measurements): 100 % at a score of {c.HEALTH_FULL_AT} or less, which healthy operation stays below, falling "
               f"with the logarithm of the score to 0 % at {c.HEALTH_ZERO_AT:.0f}, a typical end-stage score.")]
    D += [("h2", "6. Training curves and results")]
    if not runs:
        D += [("p", "No finished training run yet. Run train.py, evaluate.py and hardware.py, then this script again.")]
    if runs:
        r3, med3 = comp["run3"], lambda v: np.median([x for x in v if x is not None] or [np.nan])
        D += [("p", "Run 3 (the old model/ network, 8-32-16-2, its own validation folds and inputs) on the same bearings:"),
              ("table", [["held-out bearing", "end caught (seeds)", "healthy rows alarmed / possible", "alarm, min before onset"]]
               + [[b, f"{r['end_caught_seeds']}/{r['seeds']}", f"{r['healthy_rows_alarmed']}/{r['healthy_rows']}",
                   f"{med3(r['alarm_min_before_onset']):.0f}"] for b, r in r3.items()]),
              ("p", "Run 3 has no health error: its health head was never trained.")]
    if len(runs) > 1:
        D += [("p", "All runs overlaid (mean over folds and seeds):"),
              ("img", save(page.curves({r.name: pd.read_csv(r / "history.csv") for r in runs}), "curves_all.png"))]
    for run in runs:
        ev, cfg = comp[run.name], json.loads((run / "config.json").read_text())
        dev = lambda k: np.nanmean([e["p_developing"][k] if e["p_developing"][k] is not None else np.nan
                                    for e in sum(ev["paderborn"].values(), [])])
        hw = json.loads((run / "hardware.json").read_text())["summary"] if (run / "hardware.json").exists() else None
        fig = page.curves({run.name: pd.read_csv(run / "history.csv")})
        P = ev["paderborn"]
        med = lambda b, k: np.median([e[k] for e in P[b] if e[k] is not None] or [np.nan])
        D += [("h2", f"Run {run.name} (trained on {cfg['data']}, history {cfg['history']})"), ("img", save(fig, f"curves_{run.name}.png")),
              ("table", [["held-out bearing", "end caught (seeds)", "healthy rows alarmed / possible", "Failing, min before onset",
                          "health error before onset, %", "after onset, %"]]
               + [[b, f"{sum(e['end_caught'] for e in P[b])}/{len(P[b])}",
                   f"{sum(e['healthy_rows_alarmed'] for e in P[b])}/{sum(e['healthy_rows'] for e in P[b])}",
                   f"{med(b, 'failing_min_before_onset'):.0f}", f"{med(b, 'health_mae_before_onset'):.1f}",
                   f"{med(b, 'health_mae_after_onset'):.1f}"] for b in P]),
              ("p", "Negative minutes mean Failing came after the detector's sustained onset; 'nan' means it never came."),
              ("img", run / "timelines.png"),
              ("p", f"P(developing) on held-out Paderborn bearings: {dev('healthy_rows'):.3f} on healthy rows, "
                    f"{dev('onset_to_failing'):.3f} between onset and Failing, {dev('after_failing'):.3f} after Failing; before "
                    f"onset {dev('before_onset_rpm_1700_1900'):.3f} at 1700-1900 rpm (Ottawa's speed) against "
                    f"{dev('before_onset_other_rpm'):.3f} at other speeds. It should be near 0 on healthy rows, rise after onset, "
                    "and not depend on the speed. Hidden-layer dataset probe AUC: "
                    f"{max(ev['hidden_layer_dataset_probe_auc'].values()):.2f} (0.5 = the network cannot tell the datasets apart)."),
              ("p", "Ottawa held-out bearings, seed 0: "
                    + (f"stage accuracy {ev['ottawa'][0]['accuracy']:.2f}" if cfg["data"].endswith("ottawa") else
                       f"healthy windows called healthy {ev['ottawa'][0]['healthy_called_healthy']:.2f}, damaged windows called "
                       f"faulty {ev['ottawa'][0]['damaged_called_faulty']:.2f} (this version has no 'developing' examples, so "
                       "a stage accuracy would be capped by construction)")
                    + f"; health % by stage {np.round(ev['ottawa'][0]['health_pct_by_stage'], 0).tolist()}; "
                    f"it falls healthy > developing > faulty on {ev['ottawa'][0]['bearings_health_falls_0_1_2']} of "
                    f"{ev['ottawa'][0]['bearings']} bearings."),
              ("img", confusion_figure(ev["ottawa"][0]["confusion_true_rows_pred_cols"], f"confusion_{run.name}.png")),
              ("p", f"INT8 vs FP32: {hw['status_decisions_changed_pct']:.3f} % of status decisions change, health differs by at most "
                    f"{hw['health_max_diff_pct']:.2f} % points, Failing row identical: {hw['failing_row_identical']}. RTL bit-exact: "
                    f"{hw['rtl_bit_exact']}." if hw else "INT8 and RTL: not run yet (hardware.py).")]
    if (c.REPORT / "locked_results.json").exists():
        L = json.loads((c.REPORT / "locked_results.json").read_text())
        D += [("h2", "Locked test (run once, frozen model)"),
              ("table", [["locked bearing", "end caught", "healthy rows alarmed / possible", "Failing, min before end",
                          "health error before onset, %", "after onset, %"]]
               + [[b, "yes" if e["end_caught"] else "no", f"{e['healthy_rows_alarmed']}/{e['healthy_rows']}",
                   "never" if e["failing_min_before_end"] is None else f"{e['failing_min_before_end']:.0f}",
                   f"{e['health_mae_before_onset']:.1f}", f"{e['health_mae_after_onset']:.1f}"] for b, e in L["paderborn"].items()]),
              ("p", f"Locked Ottawa bearings: stage accuracy {L['ottawa']['accuracy']:.2f}, healthy called healthy "
                    f"{L['ottawa']['healthy_called_healthy']:.2f}, damaged called faulty {L['ottawa']['damaged_called_faulty']:.2f}, "
                    f"health % by stage {np.round(L['ottawa']['health_pct_by_stage'], 0).tolist()}."),
              ("img", confusion_figure(L["ottawa"]["confusion_true_rows_pred_cols"], "confusion_locked.png"))]
    D += [("h2", "7. Pre-checks on Ottawa"),
          ("p", "Three checks were run before any training, and all three failed. Version B trains on Ottawa anyway, beside "
                "version A, so the two can be compared; its 'developing' output should be trusted only if the checks in "
                "section 6 hold.")]
    for (name, r), img in zip(pre.items(), ["check1_stages.png", "check2_overlap.png", "check3_high_band.png"]):
        D += [("p", f"{name}: {'PASS' if r['pass'] else 'FAIL'}"), ("img", c.PRECHECKS / img)]
    D += [("h2", "8. Limits"),
          ("p", f"Only {len(folds)} Paderborn bearings carry the training; every number here has wide uncertainty until the locked "
                "test. Health % is a severity scale of the vibration now, not a countdown to failure: it levels off when the "
                "vibration does, and a bearing whose end stage is close to its baseline (B12) stays near 100 %. After B12's baseline restart its end stage is only "
                f"{summary['paderborn'].get('B12', {}).get('end_score_over_tau', float('nan')):.1f} x its detector threshold "
                f"(lowest of the other bearings: {min(v['end_score_over_tau'] for b, v in summary['paderborn'].items() if b != 'B12'):.0f} x), "
                "so B12 is the hardest bearing to catch. The temperature rule's limit was set on these same bearings, and temperature "
                "only rises at the very end on some of them, so it is a backstop for fast overheating, not an early warning. "
                "Version A cannot report 'developing'; version B learns it "
                "from Ottawa only, where stage and recording differences are mixed. Ottawa "
                "recordings differ from each other in ways that are not damage (offset and level change between recordings), so "
                "Ottawa results are indicative only. The status ladder's settings are host-side and "
                "were not tuned. The model has not run on the board.")]
    return D


def main():
    D = build()
    tag = {"h1": "h1", "h2": "h2", "p": "p"}
    body = []
    for kind, v in D:
        if kind in tag:
            body.append(f"<{tag[kind]}>{html.escape(v)}</{tag[kind]}>")
        elif kind == "img":
            body.append(f"<img src='{os.path.relpath(v, c.REPORT)}' style='max-width:100%'>")
        else:
            body.append(pd.DataFrame(v[1:], columns=v[0]).to_html(index=False, border=0))
    (c.REPORT / "report.html").write_text("<html><body style='font-family:sans-serif;max-width:1000px;margin:auto'>"
                                          + "\n".join(body) + "</body></html>")
    st, flow, W = getSampleStyleSheet(), [], A4[0] - 80
    for kind, v in D:
        if kind in tag:
            flow.append(Paragraph(html.escape(v), st["Title" if kind == "h1" else "Heading2" if kind == "h2" else "BodyText"]))
        elif kind == "img":
            w, h = plt.imread(v).shape[1::-1]
            flow.append(Image(str(v), W, W * h / w))
        else:
            cells = [[Paragraph(html.escape(str(x)), st["BodyText"]) for x in r] for r in v]
            flow.append(Table(cells, colWidths=[W / len(v[0])] * len(v[0]), style=[("GRID", (0, 0), (-1, -1), 0.3, colors.grey),
                                                                                  ("BACKGROUND", (0, 0), (-1, 0), colors.whitesmoke)]))
        flow.append(Spacer(1, 6))
    SimpleDocTemplate(str(c.REPORT / "report.pdf"), pagesize=A4, leftMargin=40, rightMargin=40).build(flow)
    print(f"{c.REPORT / 'report.html'}\n{c.REPORT / 'report.pdf'}")


if __name__ == "__main__":
    main()
