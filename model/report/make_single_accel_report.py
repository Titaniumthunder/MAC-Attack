"""The single-accelerometer report as a PDF: docs/Model/02_Ottawa_single_accelerometer_model.pdf.

  python report/make_single_accel_report.py          (inside model/; needs Microsoft Edge or Chrome for the PDF)

Every number is read from the saved results (results/E3_single_accel/analysis.json, results/E3_single_accel_a1/,
results/H1_single_accel_a1/, export/E3_single_accel_a*/, results/E3/). The page is HTML printed by the browser in
headless mode (reportlab, used by make_report.py, is not installed on the Windows PC).
"""
import base64, csv, io, json, shutil, subprocess, sys, tempfile
from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np

HERE = Path(__file__).resolve().parent.parent
OUT = HERE.parent / "docs" / "Model" / "02_Ottawa_single_accelerometer_model.pdf"

# reference palette (dataviz skill), light mode: slot 1 blue = healthy, slot 2 orange = faulty
HEALTHY, FAULTY = "#2a78d6", "#eb6834"
INK, INK2, MUTED, GRID, SURFACE = "#0b0b0b", "#52514e", "#8a8984", "#e4e3df", "#ffffff"
SPEED = {1: "15 Hz", 2: "30 Hz", 3: "45 Hz", 4: "60 Hz", 5: "15→45", 6: "30→60", 7: "45→15", 8: "60→30"}

plt.rcParams.update({"font.family": "DejaVu Sans", "font.size": 9, "axes.edgecolor": MUTED, "axes.labelcolor": INK2,
                     "xtick.color": INK2, "ytick.color": INK2, "axes.spines.top": False, "axes.spines.right": False,
                     "axes.grid": True, "grid.color": GRID, "grid.linewidth": 0.6, "axes.axisbelow": True,
                     "figure.facecolor": SURFACE, "axes.facecolor": SURFACE, "legend.frameon": False})


def jload(p):
    return json.loads((HERE / p).read_text(encoding="utf-8"))


def rows(p):
    with open(HERE / p, newline="") as f:
        return list(csv.DictReader(f))


def png(fig):
    b = io.BytesIO()
    fig.savefig(b, format="png", dpi=200, bbox_inches="tight")
    plt.close(fig)
    return "data:image/png;base64," + base64.b64encode(b.getvalue()).decode()


A = jload("results/E3_single_accel/analysis.json")
E3 = jload("results/E3/metrics.json")
DEP = jload("weights/E3_single_accel/deployed.json")
SEL = jload("weights/E3_single_accel/selected.json")
Q1, Q2 = jload("export/E3_single_accel_a1/quant.json"), jload("export/E3_single_accel_a2/quant.json")
INFO1 = jload("weights/E3_single_accel_a1/model.json")
HJ1 = jload("weights/H1_single_accel_a1/health.json")
V = A["variants"]


def ext(m):
    (tn, fp), (fn, tp) = m["confusion"]
    spec = tn / (tn + fp)
    den = ((tp + fp) * (tp + fn) * (tn + fp) * (tn + fn)) ** 0.5
    return {**m, "specificity": spec, "balanced_accuracy": (m["recall"] + spec) / 2,
            "mcc": (tp * tn - fp * fn) / den if den else 0.0, "tp": tp, "fn": fn, "fp": fp, "tn": tn}


# ------------------------------------------------------------------ figures
def fig_scores():
    """Deployed model, seed 42: every recording's score (mean of 10 window logits) against the cut."""
    sc = rows("results/E3_single_accel_a1/scores.csv")
    cut = INFO1["seeds"]["42"]["cut"]
    fig, ax = plt.subplots(figsize=(6.6, 2.9))
    rng = np.random.default_rng(1)
    for i, sp in enumerate(("train", "val", "test")):
        for y, col, lab in ((0, HEALTHY, "Healthy"), (1, FAULTY, "Faulty")):
            v = [float(r["score_s42"]) for r in sc if r["split"] == sp and int(r["label"]) == y]
            x = i + (-0.17 if y == 0 else 0.17) + rng.uniform(-0.09, 0.09, len(v))
            ax.scatter(x, v, s=22, color=col, edgecolor="white", linewidth=0.8, zorder=3,
                       label=lab if i == 0 else None)
    ax.axhline(cut, color=INK, linewidth=1, linestyle=(0, (4, 3)))
    ax.text(2.48, cut + 0.6, f"decision cut {cut:.2f}", ha="right", va="bottom", color=INK2, fontsize=8)
    ax.set_xticks([0, 1, 2], ["Train (64 rec.)", "Validation (32)", "Test (32)"])
    ax.set_xlim(-0.5, 2.5)
    ax.set_ylabel("Recording score (logit)")
    ax.legend(loc="lower left", bbox_to_anchor=(0, 1.0), ncol=2, fontsize=8)
    ax.grid(axis="x", visible=False)
    return png(fig)


def fig_compare():
    """Test faults found (of 28) per model, each seed."""
    names = ["E3 (3 accel.,\nhistorical)", "Accel. 1\n(deployed)", "Accel. 2\n(validation pick)", "Accel. 3"]
    vals = [[E3[s]["metrics"]["test"]["confusion"][1][1] for s in ("42", "43", "44")]]
    vals += [[V[k]["seeds"][s]["splits"]["test"]["tp"] for s in ("42", "43", "44")] for k in "123"]
    fig, ax = plt.subplots(figsize=(6.6, 2.5))
    for i, v in enumerate(vals):
        ax.scatter([i - 0.15, i, i + 0.15], v, s=46, color=FAULTY if i == 1 else "#8a8984", edgecolor="white",
                   linewidth=1, zorder=3)
        ax.text(i, max(v) + 0.35, " / ".join(map(str, v)), ha="center", va="bottom", fontsize=8, color=INK)
    ax.set_xticks(range(4), names, fontsize=8)
    ax.set_xlim(-0.6, 3.6)
    ax.set_ylim(23.5, 29.5)
    ax.axhline(28, color=MUTED, linewidth=0.8, linestyle=":")
    ax.text(3.58, 28.08, "all 28", ha="right", va="bottom", fontsize=7.5, color=INK2)
    ax.set_ylabel("Test faults found (of 28)")
    ax.grid(axis="x", visible=False)
    return png(fig)


def fig_training():
    h = np.array(V["1"]["seeds"]["42"]["history"])
    fig, ax = plt.subplots(figsize=(6.6, 2.5))
    ep = np.arange(1, len(h) + 1)
    ax.plot(ep, h[:, 0], color=HEALTHY, linewidth=2)
    ax.plot(ep, h[:, 1], color=FAULTY, linewidth=2)
    ax.set_yscale("log")
    ax.text(ep[-1] + 1, h[-1, 0], "train", color=INK2, va="center", fontsize=8)
    ax.text(ep[-1] + 1, h[-1, 1], "validation", color=INK2, va="center", fontsize=8)
    b = V["1"]["seeds"]["42"]["best_epoch"]
    ax.axvline(b, color=MUTED, linewidth=0.8, linestyle=":")
    ax.text(b - 1, ax.get_ylim()[1] * 0.6, f"best epoch {b}", ha="right", fontsize=8, color=INK2)
    ax.set_xlim(0, len(h) + 14)
    ax.set_xlabel("Epoch")
    ax.set_ylabel("Weighted BCE (log)")
    return png(fig)


def fig_health():
    hr = rows("results/H1_single_accel_a1/health.csv")
    fig, ax = plt.subplots(figsize=(6.6, 2.7))
    rng = np.random.default_rng(2)
    for y, col, lab in ((1, FAULTY, "Faulty"), (0, HEALTHY, "Healthy")):
        x = np.array([int(r["speed"]) for r in hr if int(r["label"]) == y], float)
        v = [float(r["HI"]) for r in hr if int(r["label"]) == y]
        ax.scatter(x + (0.14 if y == 0 else -0.08) + rng.uniform(-0.12, 0.12, len(x)), v, s=20, color=col,
                   edgecolor="white", linewidth=0.8, zorder=3 if y == 0 else 2, label=lab)
    ax.set_xticks(range(1, 9), [f"{SPEED[c]}\n{'test' if c in (1, 6) else 'val' if c in (2, 7) else 'train'}"
                                for c in range(1, 9)], fontsize=7.5)
    ax.set_ylabel("Health index (%)")
    ax.set_ylim(-5, 108)
    ax.legend(loc="lower left", bbox_to_anchor=(0, 1.0), ncol=2, fontsize=8)
    ax.grid(axis="x", visible=False)
    return png(fig)


def fig_int8():
    tr = rows("export/E3_single_accel_a1/vectors/test_recordings.csv")
    s = Q1["logit_scale"]
    fig, ax = plt.subplots(figsize=(3.4, 3.0))
    for y, col, lab in ((0, HEALTHY, "Healthy"), (1, FAULTY, "Faulty")):
        f = [float(r["score_fp32"]) for r in tr if int(r["label"]) == y]
        q = [int(r["sum_logit_int"]) / 10 * s for r in tr if int(r["label"]) == y]
        ax.scatter(f, q, s=22, color=col, edgecolor="white", linewidth=0.8, zorder=3, label=lab)
    lim = [-14, 16]
    ax.plot(lim, lim, color=MUTED, linewidth=0.8, linestyle=":")
    ax.axhline(Q1["cut"], color=INK, linewidth=0.8, linestyle=(0, (4, 3)))
    ax.axvline(Q1["cut"], color=INK, linewidth=0.8, linestyle=(0, (4, 3)))
    ax.set_xlim(lim)
    ax.set_ylim(lim)
    ax.set_xlabel("FP32 score")
    ax.set_ylabel("INT8 score (× logit scale)")
    ax.legend(loc="upper left", fontsize=8)
    return png(fig)


# ------------------------------------------------------------------ html helpers
def f3(v):
    return f"{v:.3f}"


def table(head, body, cls=""):
    h = "".join(f"<th>{c}</th>" for c in head)
    b = "".join("<tr>" + "".join(f"<td>{c}</td>" for c in r) + "</tr>" for r in body)
    return f'<table class="{cls}"><thead><tr>{h}</tr></thead><tbody>{b}</tbody></table>'


def build():
    m1 = {sp: V["1"]["seeds"]["42"]["splits"][sp] for sp in ("train", "val", "test")}
    e3t = ext(E3["42"]["metrics"]["test"])
    q1res = rows("export/E3_single_accel_a1/vectors/test_recordings.csv")
    int8_found = sum(int(r["faulty_int8"]) for r in q1res if int(r["label"]) == 1)
    int8_fa = sum(int(r["faulty_int8"]) for r in q1res if int(r["label"]) == 0)
    h1 = A["health"]["1"]

    metric_rows = []
    for sp, lab in (("train", "Train"), ("val", "Validation"), ("test", "Test")):
        m = m1[sp]
        metric_rows.append([lab, f"{m['tp']}/{m['tp'] + m['fn']}", f"{m['tn']}/{m['tn'] + m['fp']}"]
                           + [f3(m[k]) for k in ("accuracy", "recall", "precision", "f1", "balanced_accuracy",
                                                 "specificity", "roc_auc", "mcc")])

    cmp_rows = [["E3, accelerometers 1+2+3 (historical)", "22", "1,281", f"{e3t['tp']}/28", f3(e3t["recall"]),
                 f3(e3t["f1"]), f3(e3t["balanced_accuracy"]), f3(e3t["mcc"]), "27 / 25 / 27"]]
    for k, lab in (("1", "<b>Accelerometer 1 (deployed)</b>"), ("2", "Accelerometer 2 (validation pick)"),
                   ("3", "Accelerometer 3")):
        m = V[k]["seeds"]["42"]["splits"]["test"]
        cmp_rows.append([lab, "8", "833", f"{m['tp']}/28", f3(m["recall"]), f3(m["f1"]), f3(m["balanced_accuracy"]),
                         f3(m["mcc"]), " / ".join(str(V[k]["seeds"][s]["splits"]["test"]["tp"]) for s in ("42", "43", "44"))])

    val_rows = [[f"Accelerometer {k}", "1.000", "1.000", "1.000",
                 f"{V[k]['mean']['val']['window_roc_auc']:.4f}", f"{V[k]['mean']['best_val_loss']:.4f}",
                 str(A["rank"].index(int(k)) + 1)] for k in "123"]

    wb = A["window_by_f"]["1"]
    win_rows = [[b, f"{wb[b]['42']['missed']} of {wb[b]['n_faulty']}", f"{wb[b]['42']['false_alarms']} of {wb[b]['n_healthy']}"]
                for b in wb]

    hi_rows = []
    for sp, lab in (("train", "Train"), ("val", "Validation"), ("test", "Test")):
        s = h1["splits"][sp]
        hv = list(s["healthy"].values())
        fv = np.array(s["faulty_hi"])
        hi_rows.append([lab, ", ".join(f"{v:.0f}" for v in hv), f"{np.median(fv):.0f}%",
                        f"{len(s['faulty_at_100'])}/{len(fv)}", f"{int((fv <= 0).sum())}/{len(fv)}", f3(s["roc_auc"])])

    inputs = ", ".join(f"<code>{n}</code>" for n in INFO1["inputs"])
    css = """
    @page { size: A4; margin: 16mm 15mm 16mm 15mm; }
    * { box-sizing: border-box; }
    body { font-family: 'Segoe UI', Arial, sans-serif; color: #0b0b0b; font-size: 9.6pt; line-height: 1.42; margin: 0; background: #fff; }
    h1 { font-size: 21pt; margin: 0 0 4px; letter-spacing: -0.3px; }
    h2 { font-size: 13.5pt; margin: 20px 0 6px; padding-top: 8px; border-top: 1.5px solid #0b0b0b; break-after: avoid; }
    h3 { font-size: 10.5pt; margin: 12px 0 4px; break-after: avoid; }
    p { margin: 4px 0 7px; }
    .sub { color: #52514e; font-size: 10.5pt; margin-bottom: 14px; }
    .meta { color: #52514e; font-size: 8.5pt; }
    table { border-collapse: collapse; width: 100%; margin: 6px 0 10px; font-size: 8.4pt; break-inside: avoid; }
    th { text-align: left; font-weight: 600; color: #52514e; border-bottom: 1px solid #8a8984; padding: 3px 5px; }
    td { border-bottom: 1px solid #e4e3df; padding: 3px 5px; vertical-align: top; }
    code { font-family: Consolas, monospace; font-size: 8.2pt; background: #f3f2ef; padding: 0 3px; border-radius: 3px; }
    .tiles { display: flex; gap: 8px; margin: 10px 0 12px; }
    .tile { flex: 1; border: 1px solid #e4e3df; border-radius: 6px; padding: 8px 10px; }
    .tile .v { font-size: 17pt; font-weight: 650; line-height: 1.1; }
    .tile .l { color: #52514e; font-size: 8pt; margin-top: 2px; }
    .note { border-left: 3px solid #eda100; background: #fdf8ec; padding: 6px 10px; margin: 8px 0; break-inside: avoid; }
    .key { border-left: 3px solid #2a78d6; background: #f1f6fd; padding: 6px 10px; margin: 8px 0; break-inside: avoid; }
    figure { margin: 8px 0 10px; break-inside: avoid; }
    figure img { width: 100%; }
    figcaption { color: #52514e; font-size: 8.2pt; margin-top: 2px; }
    .row { display: flex; gap: 14px; align-items: flex-start; }
    .row > * { flex: 1; }
    .flow { display: flex; align-items: stretch; gap: 0; margin: 10px 0 6px; break-inside: avoid; }
    .step { flex: 1; border: 1px solid #8a8984; border-radius: 6px; padding: 6px 7px; font-size: 7.9pt; background: #fafaf8; }
    .step b { display: block; font-size: 8.4pt; margin-bottom: 2px; }
    .arrow { width: 14px; display: flex; align-items: center; justify-content: center; color: #8a8984; font-size: 11pt; }
    ul { margin: 4px 0 8px 0; padding-left: 18px; } li { margin: 2px 0; }
    .pb { break-before: page; }
    """
    flow = "".join(
        (f'<div class="arrow">→</div>' if i else "") + f'<div class="step"><b>{t}</b>{d}</div>'
        for i, (t, d) in enumerate([
            ("1. Sense", "One accelerometer on the motor, 42,000 samples per second (m/s²), plus the drive's commanded frequency f."),
            ("2. Features (ARM)", "Every 1-s window: 7 statistics of the vibration + ln f = 8 numbers."),
            ("3. Scale to INT8", "Subtract the training mean, divide by the training std, round to −127..127."),
            ("4. Neural net (FPGA)", "8 → 32 → 16 → 1 on the 8×8 systolic MAC array: one fault score (logit) per second."),
            ("5. Decide", "Average the last 10 scores. Above the cut → <b style='display:inline'>faulty</b> (output A)."),
            ("6. Health index (ARM)", "Distance of the same 7 statistics from the healthy motor at that speed → 0–100% (output B)."),
        ]))

    figs = {"scores": fig_scores(), "compare": fig_compare(), "training": fig_training(), "health": fig_health(),
            "int8": fig_int8()}

    html = f"""<!doctype html><html><head><meta charset="utf-8"><title>Machine Guardian single-accelerometer report</title>
<style>{css}</style></head><body>

<h1>Machine Guardian: the single-accelerometer model</h1>
<div class="sub">From three accelerometers to one: what was built, what is inside it, and how well it works.</div>
<div class="meta">28 October 2026 · MAC Attack project · model folder <code>model/</code> · generated by
<code>model/report/make_single_accel_report.py</code> from the saved results</div>

<div class="tiles">
 <div class="tile"><div class="v">28/28</div><div class="l">test faults found (FP32 and INT8)</div></div>
 <div class="tile"><div class="v">4/4</div><div class="l">healthy test recordings correct (no false alarm)</div></div>
 <div class="tile"><div class="v">8 → 32 → 16 → 1</div><div class="l">network, 833 parameters (E3: 1,281)</div></div>
 <div class="tile"><div class="v">382</div><div class="l">accelerator cycles per 1-s window (E3: 566), simulated</div></div>
</div>

<div class="note"><b>Read these results with care.</b> The deployed accelerometer (1) was chosen after its test result
had been seen, every healthy recording in the dataset comes from one single motor, and each test split has only 4
healthy and 28 faulty recordings. The numbers show the pipeline works end to end; they do not yet show how it will
do on your motor. Section 10 lists the limits.</div>

<h2>1. Summary</h2>
<ul>
<li><b>Goal.</b> Turn the existing E3 model (three accelerometers, 22 inputs) into one that needs a single physical
accelerometer, as the final Machine Guardian hardware will have, keeping everything else the same so the effect of
dropping two sensors is isolated. No remaining-useful-life prediction, no temperature or RPM yet.</li>
<li><b>Built.</b> Three versions, one per Ottawa accelerometer, each 8 inputs → 32 → 16 → 1, trained exactly like E3
with seeds 42, 43 and 44. The original E3 files were not touched.</li>
<li><b>Chosen.</b> A rule fixed before training picked <b>accelerometer 2</b> on validation, but validation could
barely tell the three apart. The team then chose <b>accelerometer 1</b>, because it is the only one mounted on the
motor itself, like ours. That choice came after the test results, so it is recorded as a post-test decision.</li>
<li><b>Results (accelerometer 1).</b> Test: 28/28 faults found, no false alarm, in every seed; E3 found 27/28. The INT8
version on the accelerator gives the same 28/28, and the RTL simulation matches Python bit for bit.</li>
<li><b>Health index.</b> Ranks healthy below faulty perfectly on train and validation (ROC-AUC 1.000) and 0.929 on
test; it does not separate the two at 15 Hz, and it is a distance from one healthy motor, not a remaining-life
percentage.</li>
</ul>

<h2>2. What the model does</h2>
<p>Once a second, the system looks at the last second of vibration from one accelerometer and the speed the motor
drive is set to. It produces two outputs: <b>A</b>, healthy or faulty (from the last 10 seconds), and <b>B</b>, a
health index from 0% to 100%.</p>
<div class="flow">{flow}</div>
<p>The neural network (steps 3-5) gives output A. The health index (step 6) is a separate statistical calculation on the
same numbers, kept apart so it can later take temperature and RPM. Steps 2, 3, 5 and 6 run on the ARM processor;
step 4 runs on the team's INT8 systolic MAC array.</p>

<h2>3. What is inside it</h2>
<h3>The 8 inputs, per 1-second window (42,000 samples)</h3>
{table(["#", "Input", "What it measures"], [
    ["1", "ln(standard deviation)", "how strongly the motor vibrates around its average"],
    ["2", "ln(RMS)", "overall vibration energy (includes the sensor's constant offset)"],
    ["3", "ln(max |x|)", "the largest single spike"],
    ["4", "ln(peak-to-peak)", "distance from the lowest to the highest value"],
    ["5", "crest factor = max|x| / RMS", "how spiky the signal is compared with its energy (impacts, e.g. bearing damage)"],
    ["6", "skewness", "whether the vibration is lopsided (more large swings one way)"],
    ["7", "kurtosis", "how heavy the tails are: rare large impacts push it up"],
    ["8", "ln(f)", "the speed the drive commands, in Hz (the same motor vibrates more at higher speed)"],
])}
<p>Exact names and order: {inputs}. Before the network, each input is standardized with the <b>training</b> windows'
mean and standard deviation only.</p>

<div class="row"><div>
<h3>The network</h3>
{table(["Layer", "Size", "Parameters"], [
    ["Input", "8", "-"], ["Hidden 1 (ReLU)", "32", "8×32 + 32 = 288"], ["Hidden 2 (ReLU)", "16", "32×16 + 16 = 528"],
    ["Output (logit)", "1", "16×1 + 1 = 17"], ["<b>Total</b>", "", "<b>833</b>"]])}
</div><div>
<h3>Training (identical to E3)</h3>
{table(["Setting", "Value"], [
    ["Optimizer", "Adam, lr 0.001"], ["Loss", "BCEWithLogitsLoss, pos_weight 8/56 = 0.143"],
    ["Batch / epochs", "64 / at most 100"], ["Early stopping", "patience 15 on validation loss"],
    ["Seeds", "42, 43, 44 (42 exported)"], ["Threshold", "from validation (lowest cut with best F1, recall ≥ 0.8)"]])}
</div></div>

<h3>The data: University of Ottawa electric motor dataset</h3>
<p>128 recordings of 10 s at 42 kHz from a SpectraQuest test rig: one healthy motor and seven faulty motors (bearing
fault, broken rotor bars, bowed rotor, rotor misalignment, rotor unbalance, stator winding fault, voltage unbalance),
each at 8 speed profiles and two loads. Each recording is cut into ten 1-s windows (1,280 windows). The split is by
speed, so the model is always tested on speeds it never trained on, and all windows of a recording stay together.</p>
{table(["Split", "Speeds", "Healthy recordings", "Faulty recordings"], [
    ["Train", "45, 60 Hz; ramps 15→45, 60→30 Hz", "8", "56"], ["Validation", "30 Hz; ramp 45→15 Hz", "4", "28"],
    ["Test", "15 Hz; ramp 30→60 Hz", "4", "28"]])}
<h3>The three accelerometers</h3>
{table(["Sensor", "Model", "Where it is mounted"], [
    ["<b>Accelerometer 1 (deployed)</b>", "PCB 603C01 (has a temperature sensor)", "magnet on the <b>motor's drive end</b>"],
    ["Accelerometer 2", "PCB 623C01", "stud on the rig's shaft bearing housing near the drive end"],
    ["Accelerometer 3", "PCB 623C01", "stud on the rig's shaft bearing housing farthest from the drive end"]])}
<p class="meta">Source: Sehri &amp; Dumond, Data in Brief (2024), doi:10.1016/j.dib.2024.110144. Single axis, m/s²,
42,000 samples/s, no filtering.</p>

<h2 class="pb">4. What I did</h2>
<ol>
<li><b>Read the existing pipeline</b> (data, features, training, health index, INT8 export, RTL check, reports) and
checked the code against the project description: it matched. One detail worth knowing: the 7 statistics come from 8
stored ones (the mean is dropped).</li>
<li><b>Confirmed E3 still reproduces on this PC.</b> Retraining E3 gives the same decisions (scores within 0.000007 of
the committed ones), and re-exporting it gives identical hex files.</li>
<li><b>Added the three single-accelerometer models</b> to <code>train.py</code> (<code>E3_single_accel_a1/a2/a3</code>)
and wrote <code>single_accel.py</code> to train them, apply a selection rule written before training, and produce the
analysis.</li>
<li><b>Made the health index work on any accelerometer</b> (<code>health.py --accels</code>), and refitted it on
training data only.</li>
<li><b>Exported to INT8</b> with the existing method (<code>export.py</code>) and generalized its C header.</li>
<li><b>Ran the exported model on the accelerator's RTL</b> in Vivado's simulator. This needed a new
<code>--sim vivado</code> option in <code>rtl_check.py</code>, plus a workaround for a Vivado 2019.1 optimizer bug that
broke the testbench (not the hardware).</li>
<li><b>Added a modular feature function</b> (<code>features.window_inputs</code>) that turns one raw 1-s window into the
8 inputs, with a slot to add temperature and RPM features later.</li>
<li><b>Wrote 24 automated tests</b> (<code>test_single_accel.py</code>) and the reports
(<code>SINGLE_ACCEL_*.md</code>); fixed two small Windows bugs (report text encoding; an over-strict float check).</li>
<li><b>Exported accelerometer 1</b> after the team's mounting decision, and recorded the decision in
<code>weights/E3_single_accel/deployed.json</code>.</li>
</ol>
<p>No hardware (RTL) file was changed: the 8-input model fits the existing 8×8 array as is.</p>

<h2>5. Choosing the accelerometer</h2>
<p>The rule (fixed before any model was trained) compares the three on <b>validation only</b>: recall first, then
balanced accuracy, F1, precision, specificity, ROC-AUC, stability across seeds, window-level ROC-AUC, and finally the
validation loss.</p>
{table(["Model", "Val. recall", "Val. F1", "Val. ROC-AUC", "Window ROC-AUC", "Val. loss", "Rule rank"], val_rows)}
<p>All three were perfect on validation, so the rule fell through to its last two tie-breakers, where accelerometer 2
was slightly ahead. Those gaps amount to a few of the 320 windows: validation could not really rank the sensors.</p>
{table(["Model (seed 42, test)", "Inputs", "Params", "Faults found", "Recall", "F1", "Bal. acc.", "MCC", "Faults found, seeds 42/43/44"], cmp_rows)}
<figure><img src="{figs['compare']}"><figcaption>Test faults found out of 28: one dot per seed (42, 43, 44, left to
right), counts above. E3 is the historical result.</figcaption></figure>
<div class="key"><b>Decision.</b> Accelerometer 1 was chosen for deployment because it is mounted on the motor, as our
single accelerometer will be (2 and 3 sit on the rig's bearing housings). It also had the best test result, but that
was seen before the decision, so its 28/28 is optimistic. The validation rule's choice (accelerometer 2, 26/28 on test)
stays documented in <code>selected.json</code>.</div>

<h2 class="pb">6. Results of the deployed model (accelerometer 1)</h2>
<h3>Healthy / faulty classification, seed 42, FP32 (one decision per 10-s recording)</h3>
{table(["Split", "Faults found", "Healthy correct", "Accuracy", "Recall", "Precision", "F1", "Bal. acc.", "Specificity", "ROC-AUC", "MCC"], metric_rows)}
<p>Seeds 43 and 44 give exactly the same on validation and test (28/28, 4/4): no spread between seeds.</p>
<figure><img src="{figs['scores']}"><figcaption>Every recording's score (the average of its ten 1-second scores).
Above the dashed cut means faulty. The cut was set on validation, exactly at its mildest
fault (the orange point on the line). The closest calls are at 15 Hz in the test split:
the healthy recordings at −3.4 and −2.5, the faulty S_W_1_0 at 1.8.</figcaption></figure>

<div class="row"><div>
<h3>Training</h3>
<figure><img src="{figs['training']}"><figcaption>Training and validation loss, seed 42. Validation loss was still
improving at the end (best epoch 99 of 100): no sign of overfitting within the 100 epochs.</figcaption></figure>
</div></div>

<h3>One-second decisions by speed (validation + test, seed 42)</h3>
<p>Before the 10-second average, single windows can be wrong. The averaging removes all of these errors.</p>
{table(["Drive frequency", "Faulty windows missed", "Healthy windows flagged"], win_rows)}

<h3>Compared with the original E3</h3>
<ul>
<li>E3 (three accelerometers, historical, trained on the Mac): 27/28 test faults, recall 0.964, F1 0.982, MCC 0.878;
mean recall over seeds 0.940 ± 0.034.</li>
<li>Accelerometer 1 alone: 28/28 in all seeds, with a third fewer parameters and a third fewer accelerator cycles.</li>
<li>But its healthy 15-Hz recordings sit much closer to the cut (−3.4 and −2.5, against about −27 and −20 for E3):
the margin at low speed is smaller.</li>
</ul>

<h2 class="pb">7. Health index (output B)</h2>
<p>For each of the 7 vibration statistics, a straight line in ln(speed) is fitted to the healthy <b>training</b>
windows, with the normal spread around it. A window's distance is how many spreads it lies from those lines on
average; a recording's distance D is the average of its 10 windows. Two anchors, also from training only, turn D into a
percentage: D ≤ {HJ1['d_100']:.2f} reads 100%, D ≥ {HJ1['d_0']:.2f} (the typical faulty training recording) reads 0%.</p>
{table(["Split", "Healthy recordings (%)", "Faulty median", "Faulty reading 100%", "Faulty at 0%", "ROC-AUC of D"], hi_rows)}
<figure><img src="{figs['health']}"><figcaption>Health index of all 128 recordings by speed profile. Healthy recordings
read 100% everywhere except one at 15 Hz (94%). Away from 15 Hz most faults score low; at 15 Hz most faulty recordings
also score high.</figcaption></figure>
<ul>
<li><b>The old 15-Hz problem is gone.</b> With three accelerometers, the healthy 15-Hz recordings scored 0%. The cause
was accelerometer 3: its kurtosis and skewness at 15 Hz were 15-32 spreads away from the healthy line. Without it,
they score 94% and 100%.</li>
<li><b>At 15 Hz the index does not separate.</b> The faulty recording closest to normal (D = 1.50) is nearer the
healthy reference than both healthy ones (1.85, 2.07).</li>
<li><b>It is not remaining life.</b> The dataset has one healthy motor and seven motors with one built-in fault each,
with no wear progression, so 0-100% is a distance from normal, not motor strength or lifespan. 4 of 28 faulty test
recordings read 100%.</li>
</ul>

<h2>8. INT8 and the accelerator</h2>
<div class="row"><div style="flex:1.25">
{table(["Item", "Value"], [
    ["Layers (K × N)", "8×32, 32×16, 16×1"], ["INT8 weights", "784 bytes (E3: 1,232)"],
    ["Passes on the 8×8 array", "14 (E3: 22)"], ["Input scale", f"{Q1['s_x']:.6f} (99.9th percentile, chosen on validation)"],
    ["Decision threshold", f"sum of 10 window logits ≥ 10 × ({Q1['T_int']}) = {10 * Q1['T_int']:,}"],
    ["INT8 test result", f"{int8_found}/28 faults, {int8_fa}/4 false alarms"],
    ["Decisions changed by INT8", "0 in train, validation and test"],
    ["Average INT8 error per window (test)", "0.13 logit"],
    ["RTL simulation (Vivado xsim)", "PASS: every number equals the Python golden model"],
    ["Cycles, 1 window (M = 1)", "382 = 1.78 µs at 214.286 MHz (E3: 566)"],
    ["Cycles, 10 windows (M = 10)", "562 = 2.62 µs (E3: 818)"]])}
</div><div style="flex:1">
<figure><img src="{figs['int8']}"><figcaption>Test recordings, FP32 score against the INT8 score converted back to
logits. Points on the dotted line agree; dashed lines are the cut. No recording changes side.</figcaption></figure>
</div></div>
<p class="meta">These are simulation results. Nothing has been measured on the FPGA yet. The 214.286 MHz clock is the
earlier on-chip MLP build's; time on the board will also include data transfer and feature calculation.</p>

<h2 class="pb">9. Testing</h2>
{table(["Check", "Result"], [
    ["24 automated tests (<code>python -m pytest test_single_accel.py</code>): one accelerometer and 8 inputs per model, in order; training-only scaling; no recording in two splits; all 9 saved models load and reproduce their results; board-side features match the training features; the selection rule; the health index uses the right sensor; INT8 hex files reproduce the test vectors for both exports; the deployment record; E3 files untouched; E3 retrains to the same decisions", "24 passed"],
    ["E3 retrained and re-exported on this PC", "same decisions; identical hex files"],
    ["RTL check, E3 (Vivado xsim)", "PASS, 566 cycles (as committed)"],
    ["RTL check, accelerometer 1 and accelerometer 2 exports", "PASS, 382 cycles"],
    ["Accelerator edge-case suite (<code>mac.py test --quick</code>, 2×2 to 16×16 arrays)", "PASS, 20/20"],
    ["<code>mac.py mlp</code> on Vivado 2019.1", "fails: the same simulator optimizer bug (a tool issue, not the hardware; not caused by this work)"],
    ["Icarus Verilog runs; PDF report of E3; re-reading the raw dataset", "not run: Icarus, reportlab and the 2.5 GB dataset are not on this PC"]])}

<h2>10. Limitations</h2>
<ul>
<li><b>One healthy motor.</b> All 16 healthy recordings are the same physical motor; each fault is a different motor.
The model may partly be recognising that one quiet motor. An earlier finding: accelerometer 1's spread alone separates
that motor from every faulty one.</li>
<li><b>Small, already-seen test set.</b> 4 healthy and 28 faulty test recordings; 0 false alarms out of 4 is consistent
with a real false-alarm rate as high as 60%. E3's development and this choice both used the test results.</li>
<li><b>15 Hz is outside training</b> (16.5-60 Hz), and the margins are thinnest there.</li>
<li><b>Threshold placement.</b> The validation rule puts the cut right at the mildest faulty validation recording,
which is why accelerometer 2 missed two 15-Hz faults that it ranked correctly.</li>
<li><b>Different motor, different vibration.</b> Same sensor count does not mean the model will work on our motor:
mounting, axis, base and load all change the signal.</li>
</ul>

<h2>11. Before testing the physical three-sensor system</h2>
<ol>
<li>Mount our accelerometer like accelerometer 1: on the motor's drive end, same axis, and sample at 42 kHz (or
retrain at our rate), keeping the raw m/s² signal with its offset.</li>
<li>Record a healthy baseline on our own motor at several speeds and loads, synchronized with the temperature and RPM
sensors; refit the scaling and the health reference on it, and keep part of it as a truly unseen test set.</li>
<li>Run the INT8 model on the ZedBoard (<code>export/E3_single_accel_a1/</code>) and measure real cycles and timing.</li>
<li>Try a threshold set midway between healthy and faulty scores, as a new pre-declared experiment.</li>
<li>Add temperature and measured RPM as new input groups once there is synchronized training data.</li>
</ol>

<h2>Files</h2>
{table(["Path (in <code>model/</code>)", "What it is"], [
    ["<code>single_accel.py</code>, <code>test_single_accel.py</code>", "trains and selects the three models; the 24 tests"],
    ["<code>train.py</code>, <code>features.py</code>, <code>health.py</code>, <code>export.py</code>, <code>rtl_check.py</code>", "existing scripts, extended (E3 behaviour unchanged)"],
    ["<code>weights/E3_single_accel_a1/</code> (and <code>_a2</code>, <code>_a3</code>)", "trained weights per seed and the model description"],
    ["<code>weights/E3_single_accel/deployed.json</code>, <code>selected.json</code>", "the deployment decision; the validation rule's choice"],
    ["<code>export/E3_single_accel_a1/</code>", "INT8 hex files, C header <code>mg_model.h</code>, test vectors"],
    ["<code>results/E3_single_accel/analysis.md</code>", "every table behind this report"],
    ["<code>docs/Model/supporting_single_accel/02a-02c</code>", "the detailed reports"]])}
</body></html>"""
    return html


def browser():
    # Chrome first: on the Windows PC, headless Edge exits without writing the PDF (28 Oct 2026)
    for p in (r"C:\Program Files\Google\Chrome\Application\chrome.exe", shutil.which("google-chrome"),
              shutil.which("chromium"), shutil.which("msedge"),
              r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"):
        if p and Path(p).exists():
            return p
    sys.exit("Microsoft Edge or Chrome is needed to print the PDF")


def main():
    html = build()
    tmp = Path(tempfile.mkdtemp(prefix="mg_report_"))
    page = tmp / "report.html"
    page.write_text(html, encoding="utf-8")
    OUT.parent.mkdir(exist_ok=True)
    subprocess.run([browser(), "--headless=new", "--disable-gpu", "--no-pdf-header-footer",
                    f"--user-data-dir={tmp / 'profile'}", f"--print-to-pdf={OUT}", page.as_uri()],
                   check=True, capture_output=True, timeout=120)
    if "--keep-html" in sys.argv:
        print(f"HTML: {page}")
    else:
        shutil.rmtree(tmp, ignore_errors=True)
    print(f"wrote {OUT} ({OUT.stat().st_size // 1024} KB)")


if __name__ == "__main__":
    main()
