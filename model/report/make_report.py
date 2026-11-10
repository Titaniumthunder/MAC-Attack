"""The Machine Guardian model report (PDF): the whole system from the data to the chip, with every result.

  python report/make_report.py          (from model/; reads the saved results, writes docs/ and report/figures/)

Every number in the tables and charts is read from the saved files (features/, weights/, results/, export/) when the
report is built, so the PDF cannot drift from them. Writes docs/Model/01_Ottawa_three_accelerometer_model_E0-E3.pdf (repo top folder) and the charts in
report/figures/.
"""
import csv, json, math, sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
MODEL = HERE.parent
sys.path.insert(0, str(MODEL))
sys.dont_write_bytecode = True

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
import torch
from reportlab.graphics.shapes import Drawing, Line, Polygon, Rect, String
from reportlab import rl_config
from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER
from reportlab.lib.pagesizes import letter
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import inch
from reportlab.lib.utils import ImageReader
from reportlab.platypus import (CondPageBreak, Image, KeepTogether, PageBreak, Paragraph, SimpleDocTemplate, Spacer, Table,
                                TableStyle)
from scipy.stats import beta
from sklearn.metrics import roc_auc_score

from dataset import MAC_DIR, SPEED_HZ
from export import quantize_inputs
from train import EXPERIMENTS, load, mlp

sys.path.insert(0, str(MAC_DIR))
from mac import golden_mlp, mlp_equation, read_hex   # noqa: E402

rl_config.invariant = 1          # the same PDF bytes on every build
FIG = HERE / "figures"
OUT = MODEL.parent / "docs" / "Model" / "01_Ottawa_three_accelerometer_model_E0-E3.pdf"   # docs/Model/, step 01
SEEDS = ("42", "43", "44")
EXPS = ("E0", "E1", "E2", "E3")
FCLK = 214.286e6

# chart colors (validated categorical slots 1 and 2) and ink
BLUE, ORANGE = "#2a78d6", "#eb6834"
INK, INK2, GRID = "#0b0b0b", "#52514e", "#e4e3df"
plt.rcParams.update({"font.family": "sans-serif", "font.sans-serif": ["Helvetica", "Arial", "DejaVu Sans"],
                     "font.size": 9, "axes.edgecolor": GRID, "axes.labelcolor": INK2,
                     "xtick.color": INK2, "ytick.color": INK2, "axes.spines.top": False, "axes.spines.right": False,
                     "axes.grid": True, "grid.color": GRID, "grid.linewidth": 0.6, "axes.axisbelow": True,
                     "legend.frameon": False, "savefig.dpi": 200, "savefig.bbox": "tight"})


# ------------------------------------------------------------------ data
def jload(p):
    return json.loads((MODEL / p).read_text())


def cload(p):
    with open(MODEL / p, newline="") as f:
        return list(csv.DictReader(f))


def clopper(k, n):
    lo = 0.0 if k == 0 else beta.ppf(0.025, k, n - k + 1)
    hi = 1.0 if k == n else beta.ppf(0.975, k + 1, n - k)
    return lo, hi


def rates(tn, fp, fn, tp):
    rec, spec = tp / (tp + fn), tn / (tn + fp)
    den = math.sqrt((tp + fp) * (tp + fn) * (tn + fp) * (tn + fn))
    return {"acc": (tp + tn) / (tn + fp + fn + tp), "bal": (rec + spec) / 2,
            "prec": tp / (tp + fp) if tp + fp else 0.0, "rec": rec, "spec": spec,
            "f1": 2 * tp / (2 * tp + fp + fn), "mcc": (tp * tn - fp * fn) / den if den else 0.0}


def gather():
    D = {"metrics": {E: jload(f"results/{E}/metrics.json") for E in EXPS},
         "model": {E: jload(f"weights/{E}/model.json") for E in EXPS},
         "scores": {E: cload(f"results/{E}/scores.csv") for E in EXPS},
         "recordings": cload("features/recordings.csv"), "speed": cload("features/speed.csv"),
         "health": cload("results/H1/health.csv"), "hjson": jload("weights/H1/health.json"),
         "quant": jload("export/E3/quant.json")}
    R = {}
    for E in EXPS:
        R[E] = {}
        for s in SEEDS:
            R[E][s] = {}
            for sp in ("train", "val", "test"):
                mm = D["metrics"][E][s]["metrics"][sp]
                (tn, fp), (fn, tp) = mm["confusion"]
                r = rates(tn, fp, fn, tp)
                r.update(auc=mm["roc_auc"], conf=mm["confusion"], missed=mm["missed"], fa=mm["false_alarms"],
                         missed_by_speed=mm["missed_by_speed"])
                rows = [x for x in D["scores"][E] if x["split"] == sp]
                for c in sorted({x["speed"] for x in rows}):
                    rr = [x for x in rows if x["speed"] == c and x["label"] == "1"]
                    r[f"rec_{c}"] = sum(int(x[f"faulty_s{s}"]) for x in rr) / len(rr)
                R[E][s][sp] = r
    D["R"] = R
    D["rec_loss"] = rec_val_loss(D)
    D["speed_k"] = decision_speed()
    D["int8"] = int8_check(D["quant"])
    D["h1win"] = h1_windows(D)
    return D


def rec_val_loss(D):
    """The validation loss on one scale for every experiment: weighted BCE (pos_weight 8/56) of the 32 validation
    recording scores (E0 and E1's own early-stopping loss; E2 and E3 stop on the per-window loss instead)."""
    pw, out = 8 / 56, {}
    for E in EXPS:
        for s in SEEDS:
            v = [(float(x[f"score_s{s}"]), int(x["label"])) for x in D["scores"][E] if x["split"] == "val"]
            out[(E, s)] = float(np.mean([pw * y * np.logaddexp(0, -z) + (1 - y) * np.logaddexp(0, z) for z, y in v]))
    return out


def h1_windows(D):
    """The health index's window distance along the validation 45->15 Hz ramps: healthy d, faulty median d and the
    window ROC-AUC at each window frequency."""
    from health import statistics, window_d
    rows = load("windows")
    X, lf, _ = statistics(rows)
    d = window_d(X, lf, {k: np.array(D["hjson"][k]) for k in ("alpha", "beta", "sigma")})
    val = [i for i, r in enumerate(rows) if r["split"] == "val" and r["speed"] == 7]
    out = []
    for f in sorted({rows[i]["f_hz"] for i in val}):
        idx = [i for i in val if rows[i]["f_hz"] == f]
        out.append((f, [float(d[i]) for i in idx if rows[i]["label"] == 0],
                    float(np.median([d[i] for i in idx if rows[i]["label"] == 1])),
                    roc_auc_score([rows[i]["label"] for i in idx], d[idx])))
    return out


def window_logits(E, s, rows):
    info = jload(f"weights/{E}/model.json")
    X, names = EXPERIMENTS[E]["inputs"](rows)
    Xs = (X - np.array(info["scaler"]["mean"])) / np.array(info["scaler"]["std"])
    net = mlp(len(names))
    net.load_state_dict(torch.load(MODEL / "weights" / E / f"seed{s}.pt", weights_only=True))
    net.eval()
    with torch.no_grad():
        return net(torch.tensor(Xs, dtype=torch.float32))[:, 0].double().numpy(), info["seeds"][s]["cut"], Xs


def decision_speed():
    """E2, E3: every block of k consecutive windows of every test recording, mean logit against the seed's cut."""
    rows = load("windows")
    out = {}
    for E in ("E2", "E3"):
        for s in SEEDS:
            z, cut, _ = window_logits(E, s, rows)
            rec = {}
            for r, v in zip(rows, z):
                if r["split"] == "test":
                    rec.setdefault(r["file"], [None] * 10)[r["window"]] = (v, r["label"])
            for k in (1, 2, 3, 5, 10):
                tn = fp = fn = tp = 0
                y, sc = [], []
                for ws in rec.values():
                    for st in range(10 - k + 1):
                        m, lab = float(np.mean([b[0] for b in ws[st:st + k]])), ws[st][1]
                        y.append(lab)
                        sc.append(m)
                        if lab:
                            tp, fn = tp + (m >= cut), fn + (m < cut)
                        else:
                            fp, tn = fp + (m >= cut), tn + (m < cut)
                r = rates(tn, fp, fn, tp)
                r.update(auc=roc_auc_score(y, sc), n=len(y), nf=tp + fn, nh=tn + fp)
                out[(E, s, k)] = r
    return out


def int8_check(q):
    """FP32 against INT8 per split for the exported E3 seed 42, from the exported hex files."""
    rows = load("windows")
    z, cut, Xs = window_logits("E3", "42", rows)
    sz = q["sizes"]
    layers = []
    for l in range(len(sz) - 1):
        scl = read_hex(MODEL / "export" / "E3" / f"Scl{l}.hex", 24) & 0xFFFFFF
        layers.append({"W": read_hex(MODEL / "export" / "E3" / f"W{l}.hex", 8).reshape(sz[l], sz[l + 1]),
                       "bias": read_hex(MODEL / "export" / "E3" / f"Bias{l}.hex", 32), "m0": scl & 0xFFFF,
                       "shift": scl >> 16, "relu": q["layers"][l]["relu"]})
    C = golden_mlp(quantize_inputs(Xs, q["s_x"]), layers)[0][:, 0]
    li = C + q["bias_last"]
    out = {}
    for sp in ("train", "val", "test"):
        f, i, y = {}, {}, {}
        for r, a, b in zip(rows, z, li):
            if r["split"] == sp:
                f.setdefault(r["file"], []).append(a)
                i.setdefault(r["file"], []).append(int(b))
                y[r["file"]] = r["label"]
        fs = {k: float(np.mean(v)) for k, v in f.items()}
        isum = {k: sum(v) for k, v in i.items()}
        res = {}
        for name, sc, c in (("fp32", fs, cut), ("int8", isum, 10 * q["T_int"])):
            tn = sum(1 for k in y if y[k] == 0 and sc[k] < c)
            fp = sum(1 for k in y if y[k] == 0 and sc[k] >= c)
            fn = sum(1 for k in y if y[k] == 1 and sc[k] < c)
            tp = sum(1 for k in y if y[k] == 1 and sc[k] >= c)
            res[name] = {**rates(tn, fp, fn, tp), "conf": [[tn, fp], [fn, tp]],
                         "auc": roc_auc_score([y[k] for k in y], [sc[k] for k in y])}
        res["changed"] = sum(1 for k in y if (fs[k] >= cut) != (isum[k] >= 10 * q["T_int"]))
        out[sp] = res
    err = np.abs(li * q["logit_scale"] - z)
    test = np.array([r["split"] == "test" for r in rows])
    out["err_mean"], out["err_max"] = float(err.mean()), float(err.max())
    out["err_test"] = float(err[test].mean())
    real = li * q["logit_scale"]
    out["healthy"] = {}
    for f in ("H_H_1_0.csv", "H_H_1_1.csv", "H_H_7_0.csv", "H_H_7_1.csv"):
        idx = [i for i, r in enumerate(rows) if r["file"] == f]
        out["healthy"][f] = (float(z[idx].mean()), float(real[idx].mean()), float(real[idx].max()))
    out["healthy_windows_over"] = [(r["file"], r["window"], float(real[i]), float(z[i])) for i, r in enumerate(rows)
                                   if r["label"] == 0 and real[i] >= cut]
    out["cut"] = cut
    return out


# ------------------------------------------------------------------ figures
def save(fig, name):
    FIG.mkdir(parents=True, exist_ok=True)
    fig.savefig(FIG / name, facecolor="white")
    plt.close(fig)
    return FIG / name


def fig_scores(D):
    """E3 seed 42: every test and validation recording's score, healthy against faulty, with the cut."""
    sc = [x for x in D["scores"]["E3"] if x["split"] in ("val", "test")]
    cut = D["model"]["E3"]["seeds"]["42"]["cut"]
    groups = [("val", "2"), ("val", "7"), ("test", "1"), ("test", "6")]
    fig, ax = plt.subplots(figsize=(7.2, 3.2))
    rng = np.random.default_rng(0)
    for gi, (sp, c) in enumerate(groups):
        for lab, color, name in ((0, BLUE, "healthy"), (1, ORANGE, "faulty")):
            v = [float(x["score_s42"]) for x in sc if x["split"] == sp and x["speed"] == c and int(x["label"]) == lab]
            xs = gi + (-0.12 if lab == 0 else 0.12) + rng.uniform(-0.06, 0.06, len(v))
            ax.scatter(xs, v, s=22, color=color, edgecolor="white", linewidth=0.8, zorder=3,
                       label=name if gi == 0 else None)
    miss = [x for x in sc if x["split"] == "test" and x["label"] == "1" and x["faulty_s42"] == "0"]
    for x in miss:
        ax.annotate(f"missed: {x['file'][:-4]}", (2.12, float(x["score_s42"])), xytext=(1.3, -5),
                    fontsize=8, color=INK2, arrowprops={"arrowstyle": "-", "color": INK2, "lw": 0.6})
    ax.axhline(cut, color=INK, lw=1)
    ax.text(3.45, cut + 0.6, f"cut = {cut:.2f}", fontsize=8, color=INK, ha="right")
    ax.set_xticks(range(4), [f"{sp}, code {c}\n({SPEED_HZ[int(c)][0]}->{SPEED_HZ[int(c)][1]} Hz)"
                             if SPEED_HZ[int(c)][0] != SPEED_HZ[int(c)][1] else f"{sp}, code {c}\n({SPEED_HZ[int(c)][0]} Hz)"
                             for sp, c in groups])
    ax.set_ylabel("recording score (mean logit of 10 windows)")
    ax.legend(loc="lower right", fontsize=8)
    return save(fig, "scores_E3.png")


def fig_seeds(D):
    """Balanced accuracy, MCC and recall at 15 Hz on test, per model; one dot per seed, a line at the mean."""
    R = D["R"]
    panels = [("bal", "Balanced accuracy", 0.5, "always 'faulty' = 0.5"), ("mcc", "MCC", 0.0, "guessing = 0"),
              ("rec_1", "Faults caught at 15 Hz", None, None)]
    fig, axes = plt.subplots(1, 3, figsize=(7.4, 2.7), sharey=False)
    for ax, (k, title, base, blabel) in zip(axes, panels):
        for i, E in enumerate(EXPS):
            v = [R[E][s]["test"][k] for s in SEEDS]
            ax.scatter([i - 0.13, i, i + 0.13], v, s=24, color=BLUE, edgecolor="white", linewidth=0.8, zorder=3)
            ax.plot([i - 0.22, i + 0.22], [np.mean(v)] * 2, color=INK, lw=1.4, zorder=4)
        if base is not None:
            ax.axhline(base, color=INK2, lw=0.8)
            ax.text(-0.35, base - 0.02, blabel, fontsize=7, color=INK2, ha="left", va="top")
        ax.set_xticks(range(4), EXPS)
        ax.set_ylim({"bal": 0.4, "mcc": -0.15}.get(k, -0.05), 1.05)
        ax.set_title(title, fontsize=9, color=INK, loc="left")
    fig.text(0.0, -0.04, "Test split. Each dot is one seed (left to right: 42, 43, 44); black line = mean of the three.",
             fontsize=8, color=INK2)
    fig.tight_layout()
    return save(fig, "seeds_test.png")


def fig_speed(D):
    """Faults caught against seconds of data (E2, E3, seed 42); no false alarm at any k for these runs."""
    ks = (1, 2, 3, 5, 10)
    fig, ax = plt.subplots(figsize=(5.6, 2.6))
    for E, color in (("E3", BLUE), ("E2", ORANGE)):
        v = [D["speed_k"][(E, "42", k)]["rec"] for k in ks]
        ax.plot(ks, v, color=color, lw=2, marker="o", ms=5, mec="white", label=E)
        ax.text(10.3, v[-1], f"{E}  {v[-1]:.3f}", color=INK, fontsize=8, va="center")
    ax.set_xticks(ks)
    ax.set_xlim(0.5, 12.2)
    ax.set_ylim(0.8, 1.0)
    ax.set_xlabel("seconds of data used (consecutive 1-s windows averaged)")
    ax.set_ylabel("share of faulty blocks caught")
    ax.legend(loc="lower left", fontsize=8)
    return save(fig, "decision_speed.png")


def fig_training(D):
    h = np.array(D["metrics"]["E3"]["42"]["history"])
    best = D["metrics"]["E3"]["42"]["best_epoch"]
    fig, ax = plt.subplots(figsize=(5.6, 2.6))
    ep = np.arange(1, len(h) + 1)
    ax.plot(ep, h[:, 0], color=BLUE, lw=2, label="train loss")
    ax.plot(ep, h[:, 1], color=ORANGE, lw=2, label="validation loss")
    ax.axvline(best, color=INK2, lw=0.8)
    ax.text(best - 1.5, 3e-4, f"best epoch {best}", fontsize=8, color=INK2, ha="right")
    ax.set_yscale("log")
    ax.set_xlabel("epoch")
    ax.set_ylabel("weighted BCE (log scale)")
    ax.legend(loc="lower left", fontsize=8)
    return save(fig, "training_E3_s42.png")


def fig_health(D):
    hc = D["health"]
    fig, ax = plt.subplots(figsize=(7.2, 2.9))
    rng = np.random.default_rng(1)
    for c in range(1, 9):
        for lab, color, name in ((0, BLUE, "healthy"), (1, ORANGE, "faulty")):
            v = [float(x["HI"]) for x in hc if int(x["speed"]) == c and int(x["label"]) == lab]
            xs = c + (-0.15 if lab == 0 else 0.15) + rng.uniform(-0.07, 0.07, len(v))
            ax.scatter(xs, v, s=18, color=color, edgecolor="white", linewidth=0.7, zorder=3,
                       label=name if c == 1 else None)
    split = {c: next(x["split"] for x in hc if int(x["speed"]) == c) for c in range(1, 9)}
    ax.set_xticks(range(1, 9), [f"code {c}\n{SPEED_HZ[c][0]}" + (f"->{SPEED_HZ[c][1]}" if SPEED_HZ[c][0] != SPEED_HZ[c][1]
                                                                   else "") + f"\n{split[c]}" for c in range(1, 9)],
                  fontsize=7.5)
    ax.set_xlabel("speed code, drive frequency (Hz), split")
    ax.set_ylabel("health index (%)")
    ax.set_ylim(-5, 105)
    ax.legend(loc="lower center", fontsize=8, ncol=2, bbox_to_anchor=(0.5, 1.0))
    return save(fig, "health_index.png")


def pipeline():
    """The system, end to end, as a vector drawing."""
    W, H = 468, 262
    d = Drawing(W, H)
    box = colors.HexColor("#f2f1ee")
    edge = colors.HexColor("#8a897f")
    accent = colors.HexColor(BLUE)
    out_fill, out_edge = colors.HexColor("#fdece4"), colors.HexColor(ORANGE)

    def node(x, y, w, h, lines, fill=box, stroke=edge):
        d.add(Rect(x, y, w, h, rx=4, ry=4, fillColor=fill, strokeColor=stroke, strokeWidth=0.8))
        n = len(lines)
        for i, t in enumerate(lines):
            d.add(String(x + w / 2, y + h / 2 + (n - 1) * 5.5 - i * 11 - 3, t, textAnchor="middle",
                         fontName="Helvetica-Bold" if i == 0 else "Helvetica", fontSize=7.6,
                         fillColor=colors.HexColor(INK)))

    def line(x1, y1, x2, y2):
        d.add(Line(x1, y1, x2, y2, strokeColor=edge, strokeWidth=1))

    def arrow(x1, y1, x2, y2):
        line(x1, y1, x2, y2)
        ang = math.atan2(y2 - y1, x2 - x1)
        a, b = ang + 2.6, ang - 2.6
        d.add(Polygon([x2, y2, x2 + 6 * math.cos(a), y2 + 6 * math.sin(a), x2 + 6 * math.cos(b), y2 + 6 * math.sin(b)],
                      fillColor=edge, strokeColor=edge, strokeWidth=0.5))

    y1, h1 = 170, 56
    node(0, y1, 100, h1, ["Motor", "3 accelerometers,", "42,000 samples/s"])
    node(122, y1, 100, h1, ["1-s window", "42,000 x 3 samples", "(every second)"])
    node(244, y1, 100, h1, ["21 statistics", "std, RMS, max, p2p,", "crest, skew, kurtosis"])
    node(366, y1, 102, h1, ["Scale to INT8", "21 statistics + ln f:", "22 values, -127..127"])
    node(366, y1 + 68, 102, 22, ["drive frequency f (Hz)"])
    arrow(100, y1 + h1 / 2, 122, y1 + h1 / 2)
    arrow(222, y1 + h1 / 2, 244, y1 + h1 / 2)
    arrow(344, y1 + h1 / 2, 366, y1 + h1 / 2)
    arrow(417, y1 + 68, 417, y1 + h1)
    y2 = 82
    node(366, y2, 102, 62, ["On-chip MLP (TPU)", "22 -> 32 -> 16 -> 1", "INT8, 566 cycles", "= 2.64 us"],
         fill=colors.HexColor("#e6effa"), stroke=accent)
    node(244, y2, 100, 62, ["Threshold (ARM)", "logit = C + bias_last;", "sum of the last", "10 logits"])
    node(122, y2, 100, 62, ["Output 1", "faulty if the sum", ">= 10 x T_int", "= 17,680"], fill=out_fill, stroke=out_edge)
    arrow(417, y1, 417, y2 + 62)
    arrow(366, y2 + 31, 344, y2 + 31)
    arrow(244, y2 + 31, 222, y2 + 31)
    y3 = 0
    node(122, y3, 100, 62, ["Health index (ARM)", "distance from the", "healthy motor at f,", "mean of the last 10 s"])
    node(244, y3, 100, 62, ["Output 2", "health index", "0-100%"], fill=out_fill, stroke=out_edge)
    # statistics (and f) -> health index, around the left of the outputs so no arrow is crossed
    line(268, y1, 268, y1 - 12)
    line(268, y1 - 12, 111, y1 - 12)
    line(111, y1 - 12, 111, y3 + 31)
    arrow(111, y3 + 31, 122, y3 + 31)
    arrow(222, y3 + 31, 244, y3 + 31)
    return d


# ------------------------------------------------------------------ PDF pieces
SS = getSampleStyleSheet()
BODY = ParagraphStyle("body", parent=SS["BodyText"], fontName="Helvetica", fontSize=9.6, leading=13.4,
                      textColor=colors.HexColor(INK), spaceAfter=5)
SMALL = ParagraphStyle("small", parent=BODY, fontSize=8.2, leading=10.6, spaceAfter=0)
CAP = ParagraphStyle("cap", parent=BODY, fontSize=8.2, leading=10.8, textColor=colors.HexColor(INK2), spaceAfter=10)
H1 = ParagraphStyle("h1", parent=SS["Heading1"], fontName="Helvetica-Bold", fontSize=15, leading=19,
                    textColor=colors.HexColor(INK), spaceBefore=4, spaceAfter=8)
H2 = ParagraphStyle("h2", parent=SS["Heading2"], fontName="Helvetica-Bold", fontSize=11.2, leading=14.5,
                    textColor=colors.HexColor(INK), spaceBefore=8, spaceAfter=4)
BUL = ParagraphStyle("bul", parent=BODY, leftIndent=12, bulletIndent=2, spaceAfter=3)
TITLE = ParagraphStyle("title", parent=BODY, fontName="Helvetica-Bold", fontSize=26, leading=31, spaceAfter=10)
SUB = ParagraphStyle("sub", parent=BODY, fontSize=13, leading=17, textColor=colors.HexColor(INK2))
TILE_N = ParagraphStyle("tn", parent=BODY, fontName="Helvetica-Bold", fontSize=19, leading=22, alignment=TA_CENTER)
TILE_L = ParagraphStyle("tl", parent=BODY, fontSize=8, leading=10, alignment=TA_CENTER,
                        textColor=colors.HexColor(INK2))


def P(t, st=BODY):
    return Paragraph(t, st)


def bullets(items):
    return [Paragraph(t, BUL, bulletText="•") for t in items]


def table(rows, widths, head=1, align_right_from=1, small=True, zebra=False):
    st = SMALL
    hst = ParagraphStyle("th", parent=SMALL, fontName="Helvetica-Bold")
    data = [[c if not isinstance(c, str) else Paragraph(c, hst if i < head else st) for c in r]
            for i, r in enumerate(rows)]
    t = Table(data, colWidths=widths, repeatRows=head)
    style = [("VALIGN", (0, 0), (-1, -1), "TOP"), ("TOPPADDING", (0, 0), (-1, -1), 2.5),
             ("BOTTOMPADDING", (0, 0), (-1, -1), 2.5), ("LEFTPADDING", (0, 0), (-1, -1), 4),
             ("RIGHTPADDING", (0, 0), (-1, -1), 4),
             ("LINEBELOW", (0, head - 1), (-1, head - 1), 0.8, colors.HexColor("#8a897f")),
             ("LINEBELOW", (0, head), (-1, -1), 0.3, colors.HexColor(GRID)),
             ("BACKGROUND", (0, 0), (-1, head - 1), colors.HexColor("#f2f1ee"))]
    t.setStyle(TableStyle(style))
    return t


def figure(path, width, caption):
    iw, ih = ImageReader(str(path)).getSize()
    return KeepTogether([Image(str(path), width=width, height=width * ih / iw), Spacer(1, 3), P(caption, CAP)])


def f3(v):
    return f"{v:.3f}"


def footer(c, doc):
    c.saveState()
    c.setFont("Helvetica", 7.5)
    c.setFillColor(colors.HexColor(INK2))
    c.drawString(0.9 * inch, 0.55 * inch, "Machine Guardian model report - MAC Attack - 27 Oct 2026")
    c.drawRightString(letter[0] - 0.9 * inch, 0.55 * inch, f"page {doc.page}")
    c.restoreState()


# ------------------------------------------------------------------ the report
def hz(c):
    a, b = SPEED_HZ[c]
    return f"{a} Hz" if a == b else f"{a}->{b} Hz"


def build(D):
    R, q, I8 = D["R"], D["quant"], D["int8"]
    e3 = R["E3"]["42"]["test"]
    cut3 = D["model"]["E3"]["seeds"]["42"]["cut"]
    t3 = D["model"]["E3"]["seeds"]["42"]["t"]
    eq1, eq10, eq64 = (mlp_equation(8, M, [22, 32, 16], [32, 16, 1]) for M in (1, 10, 64))
    eqE2 = [mlp_equation(8, M, [15, 32, 16], [32, 16, 1])[3] for M in (1, 10)]
    nweights = 22 * 32 + 32 * 16 + 16
    m3 = {k: (np.mean([R["E3"][s]["test"][k] for s in SEEDS]), np.std([R["E3"][s]["test"][k] for s in SEEDS]))
          for k in ("bal", "mcc", "rec")}
    found3 = [R["E3"][s]["test"]["conf"][1][1] for s in SEEDS]
    hc = D["health"]
    hauc = {sp: roc_auc_score([int(x["label"]) for x in hc if x["split"] == sp],
                              [float(x["D"]) for x in hc if x["split"] == sp]) for sp in ("val", "test")}
    h11 = I8["healthy"]
    over = I8["healthy_windows_over"]
    S = []

    # ---- title page
    S += [Spacer(1, 1.0 * inch), P("Machine Guardian", TITLE),
          P("A motor-fault model for the MAC Attack INT8 accelerator", SUB), Spacer(1, 6),
          P("The whole system from start to finish: the data, the features, training, the experiments, how well the "
            "model works, the INT8 conversion and the check on the chip's RTL.", BODY), Spacer(1, 16)]
    tiles = [(f"{e3['conf'][1][1]} / 28", "faulty test recordings found"),
             (f"{e3['conf'][0][1]} / 4", "false alarms on healthy test recordings"),
             (f3(e3["bal"]), "balanced accuracy (test)"),
             (f3(e3["auc"]), "ROC-AUC (test)"),
             (f"{eq1[3] / FCLK * 1e6:.2f} us", "on the chip per 1-s window"),
             (str(I8["test"]["changed"] + I8["val"]["changed"] + I8["train"]["changed"]),
              "10-s decisions changed by INT8")]
    trow = [[[P(n, TILE_N), P(l, TILE_L)] for n, l in tiles[i:i + 3]] for i in (0, 3)]
    tt = Table(trow, colWidths=[2.2 * inch] * 3, rowHeights=[0.95 * inch] * 2)
    tt.setStyle(TableStyle([("BOX", (0, 0), (-1, -1), 0.4, colors.HexColor(GRID)),
                            ("INNERGRID", (0, 0), (-1, -1), 0.4, colors.HexColor(GRID)),
                            ("VALIGN", (0, 0), (-1, -1), "MIDDLE")]))
    S += [tt, Spacer(1, 6),
          P(f"Model E3, seed 42, on the test split (speed codes not used in training). Over the three training seeds: "
            f"{min(found3)} to {max(found3)} of 28 found, no false alarm, balanced accuracy {m3['bal'][0]:.3f} "
            f"± {m3['bal'][1]:.3f}. These are development results: the test split also guided which experiment "
            "came next (section 7).", CAP), Spacer(1, 8),
          P("Status, 27 October 2026: the model and its INT8 export are complete and checked bit for bit on the RTL in "
            "simulation; the choice of E3 is <b>proposed, for Alex to confirm</b>; not yet run on the board. Branch "
            "<font face='Courier'>alex/machine-guardian-model</font>.", BODY), Spacer(1, 10),
          P("MAC Attack capstone team. Prepared with Claude (Anthropic) from the team's spec. The model results, tables "
            "and charts are read from the saved result files when the report is built (<font face='Courier'>"
            "model/report/make_report.py</font>); the RTL, board and independent-check facts are quoted from "
            "<font face='Courier'>docs/log.md</font> section 12.", CAP), PageBreak()]

    # ---- 1 summary
    S += [P("1. Summary", H1),
          P("<b>What it does.</b> Machine Guardian listens to an electric motor through vibration sensors and says "
            "whether the motor is healthy or faulty. Once a second it takes the last second of vibration from three "
            "accelerometers, reduces it to 22 numbers, and runs a small neural network on the team's INT8 "
            "systolic-array accelerator (the TPU). The ARM processor adds up the last 10 answers, so the decision "
            "always covers the last 10 seconds (output 1). A second output, the health index, says how far the "
            "vibration is from the healthy motor's at the same speed, from 0 to 100% (output 2)."),
          P("<b>How well it works.</b> On the test recordings (speed codes not used in training), the proposed model "
            f"(E3, seed 42) found <b>{e3['conf'][1][1]} of the 28 faulty recordings</b> and raised <b>no false "
            f"alarm</b> on the 4 healthy ones: accuracy {f3(e3['acc'])}, balanced accuracy {f3(e3['bal'])}, "
            f"precision {f3(e3['prec'])}, recall {f3(e3['rec'])}, F1 {f3(e3['f1'])}, MCC {f3(e3['mcc'])}, ROC-AUC "
            f"{f3(e3['auc'])}. All three training seeds raise no false alarm and find {min(found3)} to {max(found3)} "
            f"of 28 (balanced accuracy {m3['bal'][0]:.3f} ± {m3['bal'][1]:.3f}, MCC {m3['mcc'][0]:.3f} ± "
            f"{m3['mcc'][1]:.3f}). James's baseline, rebuilt as E0, found 18 of 28. The INT8 version changes no "
            "10-second decision, and the accelerator's RTL produces every logit bit for bit."),
          P(f"<b>Output 2</b> works where the healthy reference has data: on the 30->60 Hz test ramp both healthy "
            f"recordings score 100% and the faulty median is 0%, and the validation ROC-AUC is {hauc['val']:.3f}. At "
            f"15 Hz it fails (both healthy test recordings score 0%; test ROC-AUC {hauc['test']:.3f})."),
          P("<b>How far to trust it.</b>"), *bullets([
              "The dataset has only one healthy motor, and on accelerometers 1 and 2 it is quieter than every faulty "
              "recording at every speed. The model may partly be recognizing that motor rather than the fault, and "
              "accelerometer 1, the sensor E3 adds, carries the same signal.",
              "The test split was not only used at the end: E3 was run because E2 missed test faults, and the rule "
              "that picked E3 over E2 was set after both test results were known. The three-seed mean is the less "
              "optimistic figure.",
              "The test set has only 4 healthy recordings, so a false-alarm rate as high as 60% cannot be ruled out. "
              "Every mistake is at 15 Hz, the one test speed below every training window.",
              f"In INT8 the healthy 15-Hz recordings sit much closer to the threshold than in FP32 "
              f"({h11['H_H_1_0.csv'][1]:.1f} and {h11['H_H_1_1.csv'][1]:.1f} instead of {h11['H_H_1_0.csv'][0]:.1f} "
              f"and {h11['H_H_1_1.csv'][0]:.1f}; the cut is {cut3:.2f}).",
          ]),
          P("<b>Where each part is.</b> Section 2 walks through the system. Sections 3-6 cover the data, the "
            "features, the drive frequency and training. Section 7 covers the four experiments and the choice of "
            "E3. Section 8 has every quality measure. Sections 9-11 cover the health index, the INT8 conversion and "
            "the chip. Section 12 lists the independent checks, section 13 the limits."), PageBreak()]

    # ---- 2 system
    S += [P("2. The system from start to finish", H1), pipeline(), Spacer(1, 4),
          P("Figure 1. Machine Guardian, once a second. The blue box runs on the accelerator; the grey boxes after the "
            "sensors run on the ARM processor; the orange boxes are the two outputs.", CAP)]
    S += bullets([
        "<b>Sense.</b> Three accelerometers on the motor, sampled at 42,000 samples per second, and the frequency "
        "f the motor drive is set to (from the drive, not measured).",
        "<b>Window.</b> Every second, the last 1 s of samples (42,000 per sensor).",
        "<b>Describe.</b> 7 statistics per accelerometer: the logarithm of the standard deviation, RMS, largest "
        "absolute value and peak-to-peak, then crest factor, skewness and kurtosis. With ln(f) that is 22 inputs.",
        "<b>Scale.</b> Each input is standardized with the training data's mean and spread, divided by one input "
        f"scale s_x = {q['s_x']:.6g} and rounded to an integer from -127 to 127: one row of INT8 values.",
        "<b>Run on the chip.</b> The accelerator runs the three layers (22 -> 32 -> 16 -> 1, ReLU between them, "
        f"{nweights:,} INT8 weights) in {eq1[3]} clock cycles, {eq1[3] / FCLK * 1e6:.2f} us at 214.286 MHz, and "
        "returns the last layer's raw integer sum C.",
        f"<b>Decide (output 1).</b> The ARM adds the last bias ({q['bias_last']}) to get an integer logit. One "
        f"integer step is worth {q['logit_scale']:.6g} of a real logit, so the trained threshold, cut = "
        f"{cut3:.4f}, becomes T_int = {q['T_int']:,} integer steps. The ARM keeps the last 10 logits and calls "
        f"the motor faulty when their sum reaches 10 x T_int = {10 * q['T_int']:,}.",
        "<b>Health index (output 2).</b> From the same statistics and f, the ARM measures how far each window is "
        "from the healthy motor at that speed and averages the last 10 seconds into a 0-100% index (section 9; "
        "not reliable at low speed).",
    ])
    S += [PageBreak()]

    # ---- 3 data
    rec = D["recordings"]
    split_rows = [["Split", "Speed codes (drive frequency)", "Healthy", "Faulty", "1-s windows"]]
    for sp, codes in (("train", (3, 4, 5, 8)), ("val", (2, 7)), ("test", (1, 6))):
        rr = [x for x in rec if x["split"] == sp]
        split_rows.append([sp, ", ".join(f"{c} ({hz(c)})" for c in codes), str(sum(x["label"] == "0" for x in rr)),
                           str(sum(x["label"] == "1" for x in rr)), str(10 * len(rr))])
    loud = [["Speed code", "Accel. 1 (std)", "Accel. 2 (RMS)", "Accel. 3 (RMS)"]]
    for c in range(1, 9):
        line = [f"{c} ({hz(c)})"]
        for a, st in ((1, "std"), (2, "rms"), (3, "rms")):
            h = [float(x[f"a{a}_{st}"]) for x in rec if int(x["speed"]) == c and x["label"] == "0"]
            f_ = [float(x[f"a{a}_{st}"]) for x in rec if int(x["speed"]) == c and x["label"] == "1"]
            line.append(f"<b>{min(f_) / max(h):.2f}x</b> ({min(h):.2f}-{max(h):.2f} vs {min(f_):.2f}-{max(f_):.2f})")
        loud.append(line)
    S += [P("3. The data", H1),
          P("The model is trained on the <b>University of Ottawa electric motor dataset</b> (vibration). It has 128 "
            "recordings of 10 s each at 42 kHz, with three accelerometers, a microphone and a temperature sensor. "
            "Only the accelerometers are used. There are 8 classes of 16 recordings each: one healthy motor "
            "(<font face='Courier'>H_H</font>) and 7 fault classes, named by the dataset's codes (<font "
            "face='Courier'>B_R, F_B, K_A, R_M, R_U, S_W, V_U</font>); the model only learns healthy against "
            "faulty. Every class is recorded at 8 speed settings and 2 loads. File names are class_speedcode_load: "
            "<font face='Courier'>H_H_5_0</font> is the healthy motor at speed code 5, unloaded. Speed codes 1-4 "
            "are constant (15, 30, 45, 60 Hz); codes 5-8 ramp over the 10 s (15->45, 30->60, 45->15, 60->30 Hz). "
            "Label 0 = healthy, 1 = faulty; the positive class is faulty."),
          P("The split is fixed by speed code, as in James's earlier work on this dataset (his baseline model, "
            "rebuilt here as E0). No test speed code is used in training. For the window models E2 and E3, which "
            "take each window's drive frequency as an input, only 15 Hz lies outside the training range of 16.5-60 "
            "Hz: the 30->60 Hz test ramp covers the same frequencies as the 60->30 Hz training ramp. All windows of "
            "a recording stay in its recording's split; the standardizer and the class weight come from the "
            "training split only."),
          table(split_rows, [0.6 * inch, 3.0 * inch, 0.7 * inch, 0.7 * inch, 0.9 * inch]), Spacer(1, 8),
          P("<b>A warning built into the data: the healthy motor is quieter.</b> On accelerometers 1 and 2 the one "
            "healthy motor is quieter than every faulty recording at every speed (ratio above 1x); on accelerometer "
            "3 the ranges overlap at speed codes 4 and 8. A model can therefore separate the classes by recognizing "
            "this motor, not the fault. Ratio = quietest faulty recording / loudest healthy one (healthy range vs "
            "faulty range, m/s<super>2</super>, both loads). Accelerometer 1 carries a constant offset of about 5 "
            "m/s<super>2</super>, so its spread (std) is the comparable measure."),
          table(loud, [1.1 * inch, 1.85 * inch, 1.85 * inch, 1.85 * inch]), PageBreak()]

    # ---- 4 features
    S += [P("4. Features", H1),
          P("Each CSV file is read once. For every 10-s recording and every 1-s window (42,000 samples), "
            "<font face='Courier'>features.py</font> computes 8 statistics per accelerometer in float64: mean, "
            "standard deviation, RMS, largest absolute value (max|x|), peak-to-peak, crest = max|x| / RMS, skewness "
            "m3/std<super>3</super> and kurtosis m4/std<super>4</super>. They are checked against SciPy (within 6e-16) "
            "and the windows add back up to their recording (within 7e-12)."),
          table([["Experiment", "Rows", "Inputs", "Sensors"],
                 ["E0 (James's baseline)", "10-s recordings", "16: the 8 statistics as they are", "accel. 2, 3"],
                 ["E1", "10-s recordings", "15: ln of std, RMS, max|x|, p2p; crest, skew, kurtosis; ln(f), f = the "
                                           "nominal speed", "accel. 2, 3"],
                 ["E2", "1-s windows", "15: as E1, with f = the window's drive frequency", "accel. 2, 3"],
                 ["E3 (proposed)", "1-s windows", "22: as E2, for all three accelerometers", "accel. 1, 2, 3"]],
                [1.3 * inch, 1.1 * inch, 3.2 * inch, 0.9 * inch]), Spacer(1, 6),
          P("Why logarithms: vibration amplitude grows roughly as a power of speed, which becomes a straight line in "
            "ln(f), something a ReLU network can continue past the training speeds. Why windows: 10 times as many "
            "examples, each with one speed, and the board can decide once a second."), Spacer(1, 16)]

    # ---- 5 drive frequency
    sp_rows = [x for x in D["speed"] if x["profile"] == "fitted"]
    fit_tab = [["Recording", "Split", "Fitted ramp", "Largest distance from nominal", "10-s mean f (nominal)"]]
    for x in sorted(sp_rows, key=lambda r: (int(r["speed"]), r["file"])):
        c = int(x["speed"])
        a, b = SPEED_HZ[c]
        ts, te = float(x["t_start"]), float(x["t_end"])
        tt_ = np.linspace(0, 10, 100001)
        cmd = a + (b - a) * np.clip((tt_ - ts) / (te - ts), 0, 1)
        fit_tab.append([x["file"][:-4], x["split"], f"{ts:+.2f} s -> {te:.2f} s", f"{float(x['fit_dev_hz']):.2f} Hz",
                        f"{cmd.mean():.1f} Hz ({(a + b) / 2:.0f})"])
    slip = [["Speed code", "Healthy motor (2)", "Faulty (14)", "Faulty at or above the slowest healthy"]]
    for c in (1, 2, 3, 4):
        h = [float(x["measured_1x_hz"]) for x in D["speed"] if int(x["speed"]) == c and x["label"] == "0"]
        f_ = [float(x["measured_1x_hz"]) for x in D["speed"] if int(x["speed"]) == c and x["label"] == "1"]
        hr = f"{min(h):.2f} Hz" if f"{min(h):.2f}" == f"{max(h):.2f}" else f"{min(h):.2f}-{max(h):.2f} Hz"
        slip.append([f"{c} ({hz(c)})", hr, f"{min(f_):.2f}-{max(f_):.2f} Hz", str(sum(v >= min(h) for v in f_))])
    others = [float(x["fit_dev_hz"]) for x in D["speed"] if x["profile"] == "nominal" and x["fit_dev_hz"]]
    S += [CondPageBreak(6.2 * inch), P("5. The drive frequency f and the ramp check", H1),
          P("E2 and E3 need the drive frequency of every 1-s window. For the four ramp codes the spec assumed a "
            "straight ramp over the 10 s, so it asked for a check first: a spectrogram of "
            "<font face='Courier'>H_H_5_0.csv</font>. <font face='Courier'>speed.py</font> follows the shaft-rotation "
            "line (1x) of every ramp recording and fits a ramp-and-hold command to it: the code's start frequency, "
            "a straight ramp, then the end frequency. Only the start and end times are fitted."),
          figure(MODEL / "results" / "ramps" / "ramps.png", 5.7 * inch,
                 "Figure 2. Top: H_H_5_0 (accelerometers 2 and 3) with the tracked 1x line and the nominal ramp - "
                 "it is linear. Bottom: the 1x line of all 64 ramp recordings, coloured by speed code; thick lines "
                 "are the 7 that did not follow the nominal ramp (named in the table below)."),
          P(f"<b>Result.</b> {64 - len(sp_rows)} of the 64 ramp recordings have a fitted command within "
            f"{max(others):.2f} Hz of the nominal ramp at every moment of the 10 s (one of them, R_M_7_0, turns back "
            f"up in its last second; its last window keeps the nominal value, about 3 Hz low; accepted). "
            f"{len(sp_rows)} do not: the drive ramped faster and held, or the recording started in the middle of the "
            "ramp. Those 7 use their fitted command; every other recording keeps the nominal value. A negative start "
            "time means the ramp began before the recording."),
          table(fit_tab, [1.0 * inch, 0.6 * inch, 1.4 * inch, 1.8 * inch, 1.5 * inch]), Spacer(1, 8),
          KeepTogether([
              P("<b>Why not just measure the shaft speed?</b> The measured speed includes the motor's slip, and the "
                "healthy motor turns slightly faster than most faulty recordings. At 60 Hz it is faster than every "
                "one, so the measured speed alone would identify the healthy motor. f therefore always uses the "
                "commanded levels; on the board it comes from the drive, never from a shaft-speed sensor."),
              table(slip, [1.2 * inch, 1.5 * inch, 1.5 * inch, 2.2 * inch])]), Spacer(1, 14)]

    # ---- 6 training
    capped = sum(1 for E in EXPS for s in SEEDS if D["model"][E]["seeds"][s]["epochs_run"] == 100)
    S += [CondPageBreak(4.2 * inch), P("6. Training", H1),
          table([["Setting", "Value"],
                 ["Network", "MLP, inputs -> 32 -> 16 -> 1, ReLU, no dropout (the chip allows at most 64 per layer)"],
                 ["Loss", "BCEWithLogitsLoss, pos_weight = train healthy / train faulty = 8/56 (80/560 windows)"],
                 ["Optimizer", "Adam, learning rate 1e-3, betas (0.9, 0.999), eps 1e-8, no weight decay"],
                 ["Batches", "64 rows; batch order from torch.randperm with a generator seeded like the model"],
                 ["Stopping", "at most 100 epochs; stop after 15 epochs without a validation-loss improvement "
                              "> 1e-5; keep the best epoch's weights"],
                 ["Seeds", "42, 43, 44 (42 is the reported and exported run); deterministic on the CPU"],
                 ["Recording score", "the logit (E0, E1) or the mean of its 10 window logits (E2, E3)"],
                 ["Threshold", "the lowest cut among the validation scores that maximizes validation F1 with "
                               "validation recall >= 0.8; faulty if score >= cut"]],
                [1.3 * inch, 5.2 * inch]), Spacer(1, 8),
          figure(fig_training(D), 5.0 * inch,
                 f"Figure 3. E3 seed 42: training and validation loss per epoch. The best validation loss is at "
                 f"epoch {D['metrics']['E3']['42']['best_epoch']} of 100; those weights are kept. Its threshold is "
                 f"cut = {cut3:.4f} (as a probability, t = sigmoid(cut) = {t3:.4f})."),
          P(f"{capped} of the 12 runs (E0-E3, three seeds each) reached the 100-epoch limit, most with their best "
            "epoch near the end, so the validation loss was still falling slowly; the spec sets the limit and "
            "longer runs were not tried. Every run is reproducible: the same command gives byte-identical weights "
            "and results. An independent trainer written from the spec reproduced every weight of E1-E3 once four "
            "details the spec left unstated were supplied (now in <font face='Courier'>train.py</font>'s "
            "docstring)."), PageBreak()]

    # ---- 7 experiments
    exp_tab = [["Experiment", "Seed", "Test faults found", "False alarms", "Test ROC-AUC",
                "Val. loss (per recording)", "Best / last epoch"]]
    for E in EXPS:
        for s in SEEDS:
            r, mj = R[E][s]["test"], D["model"][E]["seeds"][s]
            exp_tab.append([E if s == "42" else "", s, f"{r['conf'][1][1]} / 28", f"{r['conf'][0][1]} / 4",
                            f3(r["auc"]), f"{D['rec_loss'][(E, s)]:.4f}", f"{mj['best_epoch']} / {mj['epochs_run']}"])
    rl = {E: [D["rec_loss"][(E, s)] for s in SEEDS] for E in EXPS}
    S += [P("7. The experiments and the choice of model", H1),
          P("Four experiments, each defined before it was run and never changed after its test result was seen. "
            "E0 rebuilds James's baseline; E1 adds speed; E2 moves to 1-s windows; E3 adds accelerometer 1. "
            "E3 was run because E2 seed 42 still missed 4 test faults (none on validation), as the spec asks."),
          table(exp_tab, [0.85 * inch, 0.45 * inch, 1.05 * inch, 0.85 * inch, 0.85 * inch, 1.2 * inch, 1.05 * inch]),
          P("Validation loss on one common scale: the weighted BCE of the 32 validation recording scores. "
            "(E2 and E3 stop training on the per-window loss, which is not comparable with E0 and E1's.)", CAP),
          P("<b>E0</b> reproduces James's result exactly (18/28, 0/4, ROC-AUC 0.875). <b>E1</b> does not fix 15 Hz "
            "(15/28). <b>E2</b> finds 24/28, but its seed 43 stopped early and is poor. <b>E3</b>: every seed "
            "ranks every test recording correctly and raises no false alarm, finding "
            f"{', '.join(str(v) for v in found3)} of 28."),
          P("<b>Why E3, stated plainly.</b> On validation all of E1, E2 and E3 are perfect (F1 and ROC-AUC 1 in every "
            "seed), so only the validation loss is left. On the common scale above, E1 is the worst in every view "
            f"(mean {np.mean(rl['E1']):.3f}). Between E2 and E3 the rule written before E1 (seed 42 and the mean of "
            f"the three seeds) disagrees with itself: seed 42 alone prefers E2 ({rl['E2'][0]:.4f} against "
            f"{rl['E3'][0]:.4f}), the mean prefers E3 ({np.mean(rl['E3']):.4f} against {np.mean(rl['E2']):.4f}, "
            "because E2's seed 43 is poor). Ranking the mean and the worst seed first was decided after the E2 and "
            "E3 test results had been seen, so the test result may have influenced it. The reason to prefer E3 that "
            "does not use test is its stability: every seed gives nearly the same model. E2 seed 42 (15 inputs, two "
            "sensors) is the alternative under the seed-42 rule. The choice is <b>proposed, for Alex to "
            "confirm</b>."), PageBreak()]

    # ---- 8 how good
    hdr = ["Seed 42, test", "Accuracy", "Balanced", "Precision", "Recall", "Specificity", "F1", "MCC", "ROC-AUC"]
    base = rates(0, 4, 0, 28)
    qt = [hdr, ["Always 'faulty' (no model)", f3(base["acc"]), f3(base["bal"]), f3(base["prec"]), f3(base["rec"]),
                f3(base["spec"]), f3(base["f1"]), "0", "-"]]
    for E in EXPS:
        r = R[E]["42"]["test"]
        qt.append([E] + [f3(r[k]) for k in ("acc", "bal", "prec", "rec", "spec", "f1", "mcc", "auc")])
    ms = [["Model", "Balanced acc.", "Recall", "Specificity", "MCC", "ROC-AUC", "Caught at 15 Hz (42 / 43 / 44)"]]
    for E in EXPS:
        v = lambda k: [R[E][s]["test"][k] for s in SEEDS]
        ms.append([E] + [f"{np.mean(v(k)):.3f} ± {np.std(v(k)):.3f}" for k in ("bal", "rec", "spec", "mcc", "auc")]
                  + [" / ".join(f"{x:.2f}" for x in v("rec_1"))])
    ci = [["Seed 42", "Recall (faults caught)", "95% interval", "False-alarm rate", "95% interval"]]
    for E in EXPS:
        r = R[E]["42"]["test"]
        tp, fp = r["conf"][1][1], r["conf"][0][1]
        lo, hi = clopper(tp, 28)
        flo, fhi = clopper(fp, 4)
        ci.append([E, f"{tp} / 28 = {tp / 28:.3f}", f"{lo:.2f} - {hi:.2f}", f"{fp} / 4", f"{flo:.2f} - {fhi:.2f}"])
    S += [P("8. How good is the model?", H1),
          P("<b>Reading the measures.</b> <i>Recall</i> = share of faulty recordings caught. <i>Specificity</i> = "
            "share of healthy recordings cleared. <i>Precision</i> = share of 'faulty' calls that were right. "
            "<i>Balanced accuracy</i> = the average of recall and specificity. <i>MCC</i> (Matthews correlation) "
            "runs from -1 to 1, 0 for guessing. <i>ROC-AUC</i> = the chance a random faulty recording scores higher "
            "than a random healthy one (ranking, independent of the threshold). The test set is 28 faulty and 4 "
            "healthy recordings, so a model that calls everything faulty already scores 0.875 accuracy and 0.933 "
            "F1. <b>Balanced accuracy and MCC are the fair measures here.</b>"),
          table(qt, [1.12 * inch] + [0.69 * inch] * 8), Spacer(1, 4),
          P("E0 and E1 have lower accuracy than calling everything faulty. E3 is clearly above that rule on every "
            "measure except recall, which the rule gets by definition.", CAP),
          table(ms, [0.55 * inch] + [1.0 * inch] * 5 + [1.15 * inch]),
          Spacer(1, 4),
          P("Test, mean ± population standard deviation over the seeds 42, 43, 44. By balanced accuracy and MCC, "
            "seed 42 is the best or tied-best seed in every experiment, so its single-seed numbers are the "
            "optimistic end.", CAP),
          figure(fig_seeds(D), 6.6 * inch,
                 "Figure 4. Every seed of every model on test. E3's three seeds sit together near the top; E2 "
                 "depends on the seed."), PageBreak()]
    miss = [x for x in D["scores"]["E3"] if x["split"] == "test" and x["label"] == "1" and x["faulty_s42"] == "0"]
    hmax = max(float(x["score_s42"]) for x in D["scores"]["E3"] if x["split"] == "test" and x["label"] == "0")
    S += [P("Where the mistakes are", H2),
          P("Every model catches all 14 faulty recordings at speed code 6 (30->60 Hz), in every seed. Every mistake "
            "is at speed code 1 (15 Hz), below every training window's speed (16.5 Hz and up; E1's 10-s speeds start "
            "at 30 Hz, and E0 has no speed input). The test therefore mostly measures how well each model handles "
            f"an unseen low speed. E3 seed 42 misses one recording, {', '.join(x['file'][:-4] for x in miss)}."),
          figure(fig_scores(D), 6.6 * inch,
                 "Figure 5. E3 seed 42 in FP32: the score of every validation and test recording (mean logit of its "
                 "10 windows) against the threshold. Above the line = called faulty. The healthy and faulty "
                 f"recordings are fully separated (ROC-AUC 1.000); the one miss scores "
                 f"{float(miss[0]['score_s42']):.2f}, {cut3 - float(miss[0]['score_s42']):.1f} below the cut but far "
                 f"above every healthy recording (highest {hmax:.1f}). In INT8 the two healthy 15-Hz recordings move "
                 f"up to {h11['H_H_1_0.csv'][1]:.1f} and {h11['H_H_1_1.csv'][1]:.1f} (section 10)."),
          P("How sure can we be?", H2),
          P("With so few test recordings, the measured rates come with wide uncertainty (95% Clopper-Pearson "
            "intervals). E3's fault detection is reasonably pinned down; the false-alarm rate is not: 0 false "
            "alarms in 4 healthy recordings is consistent with a true rate anywhere from 0 to 60%."),
          table(ci, [0.8 * inch, 1.5 * inch, 1.1 * inch, 1.2 * inch, 1.1 * inch]), Spacer(1, 6),
          P("Validation (all 1.000 for E1-E3) is not independent evidence: the threshold is set at the lowest "
            "faulty validation score, so validation recall is 1 by construction, and early stopping used the "
            "validation loss. And the test split itself steered the experiments (section 7), so these test numbers "
            "are development results, not a final hold-out.", BODY), PageBreak()]
    sk = [["Seconds of data", "E3 s42 recall", "E3 s43", "E3 s44", "E2 s42 recall", "E2 s43", "E2 s44",
           "Faulty / healthy blocks"]]
    for k in (1, 2, 3, 5, 10):
        sk.append([str(k)] + [f3(D["speed_k"][(E, s, k)]["rec"]) for E in ("E3", "E2") for s in SEEDS]
                  + [f"{D['speed_k'][('E3', '42', k)]['nf']} / {D['speed_k'][('E3', '42', k)]['nh']}"])
    spec_note = ", ".join(f"{E} s{s} {min(D['speed_k'][(E, s, k)]['spec'] for k in (1, 2, 3, 5, 10)):.2f}"
                          for E in ("E3", "E2") for s in SEEDS)
    S += [P("How quickly it can decide", H2),
          P("The board decides from the last 10 s, but the model is already useful sooner. For every block of k "
            "consecutive 1-s windows of every test recording, the mean logit was compared with the same threshold "
            "(FP32). For E3, a single second already catches about 95% of the faulty blocks with no false alarm; "
            "averaging 10 s adds little. The blocks overlap and come from the same 32 recordings, so they are not "
            "independent samples. In INT8, E3 seed 42 gives the same recall except at 2 s (0.956 instead of "
            "0.948), still with no false alarm."),
          figure(fig_speed(D), 5.0 * inch, "Figure 6. Share of faulty test blocks caught against seconds of data, "
                                           "seed 42 (FP32). Neither model raised a false alarm at any block length."),
          table(sk, [0.85 * inch, 0.85 * inch, 0.6 * inch, 0.6 * inch, 0.85 * inch, 0.6 * inch, 0.6 * inch,
                     1.0 * inch]),
          P(f"Recall = share of the faulty blocks caught. Lowest specificity over the block lengths: {spec_note}.",
            CAP), PageBreak()]

    # ---- 9 health index
    hrows = [["Split", "Healthy recordings (HI)", "Faulty HI min / median / max", "Faulty at or below 50%",
              "ROC-AUC of the distance"]]
    for sp in ("train", "val", "test"):
        part = [x for x in hc if x["split"] == sp]
        h = [float(x["HI"]) for x in part if x["label"] == "0"]
        f_ = np.array([float(x["HI"]) for x in part if x["label"] == "1"])
        hrows.append([sp, ", ".join(f"{v:.0f}%" for v in h), f"{f_.min():.0f} / {np.median(f_):.0f} / {f_.max():.0f}%",
                      f"{int((f_ <= 50).sum())} / {len(f_)}",
                      f3(roc_auc_score([int(x["label"]) for x in part], [float(x["D"]) for x in part]))])
    hj = D["hjson"]
    hw = [["Window frequency (val, 45->15 Hz ramps)", "Healthy windows' distance d", "Faulty median d",
           "Window ROC-AUC"]]
    for f, hd, fm, auc in D["h1win"]:
        hw.append([f"{f:.1f} Hz", ", ".join(f"{v:.2f}" for v in hd), f"{fm:.2f}", f3(auc)])
    S += [P("9. Output 2: the health index", H1),
          P("The professor asked for a second output: the motor's quality from 0 to 100%. The dataset has no wear "
            "levels (one healthy motor, each fault at a single severity), so '50% = half its capability' can be "
            "neither trained nor tested. The team chose a <b>health index</b> instead: 100% = inside the healthy "
            "motor's range at that speed, 0% = as far out as a typical faulty recording. It is a distance from the "
            "one healthy motor, not a remaining capability."),
          P("<b>How it is computed</b> (no training, no seeds). For each of the 21 window statistics, a straight "
            "line in ln(f) is fitted to the 80 healthy training windows, with the healthy spread around it. A "
            "window's distance d is the root-mean-square of its 21 standardized deviations; D is the mean of the "
            f"last 10 windows. The anchors come from training only: D_100 = {hj['d_100']:.3f} (the largest healthy "
            f"distance, each measured at a speed left out of the fit) and D_0 = {hj['d_0']:.3f} (the median faulty "
            "distance). HI = 100% x clip((D_0 - D) / (D_0 - D_100), 0, 1)."),
          table(hrows, [0.6 * inch, 1.9 * inch, 1.6 * inch, 1.1 * inch, 1.1 * inch]), Spacer(1, 6),
          figure(fig_health(D), 6.6 * inch,
                 "Figure 7. Health index of every recording by speed code. Many recordings sit exactly at 0% or 100% "
                 "and overlap (the table above gives the counts). At 30 Hz and above the healthy motor sits at or "
                 "near 100% and most faults far below; at 15 Hz (test) both healthy recordings score 0%."),
          P("<b>Where it works and where it does not.</b> Where the healthy reference is dense it works: at speed "
            "code 6 (test) both healthy recordings score 100% and the faulty median is 0%. Along the validation "
            "45->15 Hz ramps (table below) it is correct from 22.5 Hz up, uninformative at 19.5 Hz and inverted at "
            "16.5 Hz; at 15 Hz (test) both healthy recordings score 0%. Some faulty recordings also score 100% (3 in "
            "validation, 3 in test), so a 100% does not prove a healthy motor. Proposed, not yet decided: show no "
            "reading below a speed chosen on these validation windows (around 22 Hz), as a new experiment."),
          table(hw, [2.3 * inch, 1.9 * inch, 1.2 * inch, 1.1 * inch]),
          P("Healthy distances above D_0 (3.80) give 0%; the healthy reference below 30 Hz rests on 2 training "
            "windows per frequency.", CAP), PageBreak()]

    # ---- 10 INT8
    L0, L1 = q["layers"][0], q["layers"][1]
    i8 = [["Split", "FP32 [[TN,FP],[FN,TP]]", "INT8 [[TN,FP],[FN,TP]]", "ROC-AUC FP32 / INT8", "Decisions changed"]]
    for sp in ("train", "val", "test"):
        i8.append([sp, str(I8[sp]["fp32"]["conf"]), str(I8[sp]["int8"]["conf"]),
                   f"{I8[sp]['fp32']['auc']:.3f} / {I8[sp]['int8']['auc']:.3f}", str(I8[sp]["changed"])])
    hm = [["Healthy recording", "FP32 score", "INT8 score", "Highest INT8 window"]]
    for f in ("H_H_1_0.csv", "H_H_1_1.csv", "H_H_7_0.csv", "H_H_7_1.csv"):
        a, b, c = h11[f]
        hm.append([f[:-4], f"{a:.2f}", f"{b:.2f}", f"{c:.2f}"])
    ov = "; ".join(f"{f[:-4]} window {w}: {v:.2f} (FP32 {z:.2f})" for f, w, v, z in over) or "none"
    S += [P("10. INT8: from the trained network to integers", H1),
          P("The accelerator works in 8-bit integers. <font face='Courier'>export.py</font> converts E3 seed 42 with "
            "the hardware's own rounding (checked against <font face='Courier'>mac.py</font>'s bit-exact model, "
            "<font face='Courier'>golden_mlp</font>). s_h,1 and s_h,2 are the two hidden layers' activation scales; "
            "s_w is a weight column's scale; m0 (a 16-bit multiplier) and shift (a right shift) are the integers that "
            "apply a real rescale on the chip, m0 / 2<super>shift</super>."),
          table([["Step", "Rule", "Value"],
                 ["Inputs", "q = clip(round(x_std / s_x), -127, 127), one scale for all 22 inputs; s_x = the 99.9th "
                            "percentile of the train inputs / 127 (chosen on validation over the maximum)",
                  f"s_x = {q['s_x']:.6g}"],
                 ["Weights", "per output channel: s_w = max|W| / 127, W_q = round(W / s_w)", "-127 .. 127"],
                 ["Hidden layers", "bias = round(b / (s_in x s_w)); m0 / 2^shift = s_in x s_w / s_h; the accelerator "
                                   "rounds halves up",
                  f"s_h,1 = {L0['s_out']:.4g}, s_h,2 = {L1['s_out']:.4g}"],
                 ["Last layer", "the chip returns the raw sum C; the ARM adds bias_last; one integer step = "
                                "s_h,2 x s_w,last of a real logit",
                  f"bias_last = {q['bias_last']}, step = {q['logit_scale']:.6g}"],
                 ["Threshold", "T_int = ceil(cut / (s_h,2 x s_w,last)); faulty if the sum of the last 10 logits "
                               ">= 10 T_int", f"T_int = {q['T_int']}"]],
                [0.95 * inch, 4.0 * inch, 1.55 * inch]), Spacer(1, 8),
          table(i8, [0.6 * inch, 1.6 * inch, 1.6 * inch, 1.4 * inch, 1.2 * inch]), Spacer(1, 6),
          P(f"<b>INT8 changes no 10-second decision in any split</b>: the test result stays {e3['conf'][1][1]}/28 "
            f"found, 0/4 false alarms, ROC-AUC 1.000. Window logits move by {I8['err_mean']:.2f} on average over all "
            f"windows ({I8['err_test']:.2f} on test). The largest changes, up to {I8['err_max']:.0f}, are in healthy "
            "windows whose kurtosis is far beyond the input clip at 6 standard deviations: FP32 extrapolates those "
            "to very negative scores, INT8 clips them, so <b>in INT8 these healthy recordings sit much closer to "
            "the threshold</b>:"),
          table(hm, [1.6 * inch, 1.2 * inch, 1.2 * inch, 1.6 * inch]), Spacer(1, 4),
          P(f"Scores are mean logits in real units against the cut {cut3:.2f}. Healthy windows at or above the cut in "
            f"INT8: {ov}; one second alone would raise an alarm there, the 10-s decision stays healthy. Every "
            "sum fits the accelerator's 22-bit accumulator.", CAP), PageBreak()]

    # ---- 11 chip
    S += [P("11. On the chip", H1),
          table([["Rows per run", "Passes", "Model cycles", "Time at 214.286 MHz", "Array use"],
                 ["1 (one 1-s window, once a second)", str(eq1[0]), f"{eq1[3]}", f"{eq1[3] / FCLK * 1e6:.2f} us",
                  f"{1232 / (64 * eq1[3]) * 100:.1f}%"],
                 ["10 (the last 10 windows at once)", str(eq10[0]), f"{eq10[3]}", f"{eq10[3] / FCLK * 1e6:.2f} us",
                  f"{12320 / (64 * eq10[3]) * 100:.1f}%"]],
                [2.4 * inch, 0.7 * inch, 1.0 * inch, 1.4 * inch, 1.0 * inch]), Spacer(1, 4),
          P("A pass streams one 8 x 8 block of a layer's weights through the 8 x 8 array: 3 x 4 + 4 x 2 + 2 x 1 = 22 "
            "for this model, whatever the number of rows; extra rows only lengthen each pass, which is why 10 rows "
            "cost 252 cycles more than 1. The cycle counts come from <font face='Courier'>mlp_equation</font>, the "
            "cycle formula in <font face='Courier'>mac.py</font>, which the RTL's counters match. Array use = "
            f"multiply-adds / (64 PEs x model cycles). For comparison, E2's 15 inputs take {eqE2[0]} and {eqE2[1]} "
            f"cycles. Weights: {nweights:,} bytes in the accelerator's weight slots.", CAP),
          P("<b>RTL check: every logit bit for bit.</b> <font face='Courier'>rtl_check.py</font> runs the exported "
            "hex files through the accelerator's RTL (<font face='Courier'>tb/tb_mlp.sv</font>, Icarus Verilog 13.0, "
            "the ZedBoard parameters) and compares every raw sum, the last layer's INT8 inputs and the cycle "
            "counters with Python. All three runs pass (27 Oct, from docs/log.md):"),
          table([["Run", "Result"],
                 ["All 1,280 windows, 64 rows per model run (20 runs)", f"PASS, {eq64[3]:,} cycles per run (= equation)"],
                 ["Each of the 32 test recordings as one 10-row run", f"PASS, {eq10[3]} cycles (= equation)"],
                 ["One recording's 10 windows one at a time", f"PASS, {eq1[3]} cycles (= equation)"],
                 ["Decisions from the RTL's logits", "identical in all three runs; equal to the exported test vectors"]],
                [3.5 * inch, 3.0 * inch]), Spacer(1, 6),
          P("Not done yet: the model has not run on the board. The on-chip MLP itself passed its board tests (30/30) "
            "at 214.286 MHz on 24 Oct; running this trained model there is the next step.", BODY), PageBreak()]

    # ---- 12 verification, 13 limits
    S += [P("12. Independent checks", H1),
          P("Every part was rebuilt by checkers that wrote their own code from the written definitions; a second "
            "agent then tried to refute every defect they reported. None of their findings changed a result."),
          *bullets([
              "<b>Ramps.</b> Two other trackers find the same 7 recordings; fitted times agree within 0.07 s; every "
              "window frequency equals the exact integral of its command.",
              "<b>Training.</b> A trainer written from the spec reproduces every weight, threshold, loss, score and "
              "metric of E1, E2 and E3 bit for bit, all seeds, once four details the spec left unstated (now in "
              "<font face='Courier'>train.py</font>'s docstring) were supplied.",
              "<b>Health index.</b> An own implementation agrees to within 4e-15.",
              "<b>INT8 and RTL.</b> Own quantization equal to every hex file, header value and test vector; the C "
              "header compiles without a warning; the RTL check fails on deliberate errors (it is not vacuous); "
              "the accelerator's stock regression passes on Icarus 13.",
              "<b>This report.</b> Its numbers were recomputed twice by independent agents (the model comparison, "
              "then an audit of this PDF) with no mismatch; a reader's review led to the clarifications in this "
              "version.",
          ]),
          P("Defects found and fixed along the way: the model choice had been called 'validation only' (corrected "
            "in section 7); the health index had been described as working 'from 16.5 Hz up'; a rounding edge case "
            "in the export (no exported value was affected); and several wording and number errors in the log."),
          P("13. Limits and next steps", H1),
          *bullets([
              "<b>One healthy motor.</b> On accelerometers 1 and 2 it is quieter than every faulty recording, and it "
              "turns slightly faster than most of them (all of them at 60 Hz). The model may partly recognize this "
              "motor rather than the fault, and accelerometer 1 is what E3 adds. A recording of a second healthy "
              "motor, or of the same motor before and after a fault, is the only way to tell.",
              "<b>Development test set.</b> The test split guided E3's creation and the choice of model, so 27/28 "
              "is optimistic; the three-seed mean is the fairer figure. A new hold-out set would give a clean number.",
              "<b>Few healthy test recordings.</b> 0 false alarms in 4 means the false-alarm rate is only known to be "
              "below about 60%. More healthy recordings would tighten this most.",
              "<b>Low speed.</b> All misses are at 15 Hz, below every training window; the health index fails there, "
              "and in INT8 the healthy 15-Hz recordings sit closer to the threshold.",
              "<b>Threshold.</b> The rule puts the cut at the edge of the faulty validation scores; a cut in the "
              "middle of the gap would catch more 15-Hz faults, but choosing it now would use the test result.",
              "<b>Next.</b> Alex to confirm E3; run the exported model on the ZedBoard and compare the board's "
              "INT8 rows and logits with <font face='Courier'>export/E3/vectors/</font>; merge Alex_edit's 24 Oct "
              "log into this branch.",
          ]), PageBreak()]

    # ---- appendix
    full = [["Exp.", "Seed", "Split", "Acc.", "Bal.", "Prec.", "Recall", "Spec.", "F1", "MCC", "AUC", "Confusion"]]
    for E in EXPS:
        for s in SEEDS:
            for sp in ("val", "test"):
                r = R[E][s][sp]
                full.append([E, s, sp] + [f3(r[k]) for k in ("acc", "bal", "prec", "rec", "spec", "f1", "mcc", "auc")]
                            + [str(r["conf"])])
    S += [P("Appendix A. Every seed, validation and test", H1),
          table(full, [0.4 * inch, 0.45 * inch, 0.42 * inch] + [0.47 * inch] * 8 + [1.05 * inch]), Spacer(1, 4),
          P("Confusion matrices are [[TN, FP], [FN, TP]] with faulty as the positive class (validation: 4 healthy, "
            "28 faulty; test: 4 healthy, 28 faulty).", CAP),
          P("Appendix B. Files and commands", H1),
          table([["Path (in model/)", "What it is"],
                 ["features.py, speed.py", "statistics of every recording and window; the drive frequency per window"],
                 ["train.py E0 ... E3", "trains seeds 42, 43, 44; weights/ and results/ per experiment"],
                 ["health.py", "the health index (output 2): weights/H1, results/H1"],
                 ["export.py", "INT8 export of E3 seed 42: export/E3 (hex files, mg_model.h, test vectors)"],
                 ["rtl_check.py", "runs export/E3 on the RTL with Icarus Verilog and checks every number"],
                 ["report/make_report.py", "this report"],
                 ["README.md", "setup and the commands to run everything yourself"],
                 ["export/E3/mg_model.h", "everything the board's C program needs, with the steps"],
                 ["../docs/log.md, section 12", "every decision and result, in order, with the reasons"]],
                [2.1 * inch, 4.4 * inch])]
    return S


def main():
    D = gather()
    doc = SimpleDocTemplate(str(OUT), pagesize=letter, leftMargin=0.9 * inch, rightMargin=0.9 * inch,
                            topMargin=0.8 * inch, bottomMargin=0.85 * inch, title="Machine Guardian model report",
                            author="MAC Attack capstone team", subject="Motor-fault model for the INT8 accelerator")
    doc.build(build(D), onFirstPage=footer, onLaterPages=footer)
    print(f"wrote {OUT} and {FIG}")


if __name__ == "__main__":
    main()
