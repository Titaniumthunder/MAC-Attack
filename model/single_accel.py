"""E3 with one physical accelerometer: train the three variants, pick one on validation, analyse it.

  python single_accel.py              train E3_single_accel_a1, _a2, _a3 (train.py's rules, seeds 42, 43, 44), select
                                      one accelerometer on validation, write the analysis
  python single_accel.py --no-train   the selection and analysis from the saved weights and results only

Each variant = E3 with only accelerometer k: its 7 statistics (ln std, ln RMS, ln max|x|, ln peak-to-peak, crest,
skewness, kurtosis) and ln f, 8 inputs -> 32 -> 16 -> 1 (ReLU), on the 1-s windows; everything else as E3
(train.py: split, train-only standardizer, pos_weight, Adam, early stopping, validation cut, 10-window mean).

Selection rule (fixed 28 Oct 2026, written before any single-accelerometer model was trained; validation only):
  per variant, the mean over the three seeds of the validation recording metrics, compared in this order (higher is
  better, a difference under 1e-9 is a tie and moves to the next key):
    1. recall   2. balanced accuracy   3. F1   4. precision   5. specificity   6. ROC-AUC
    7. the worst seed's recall (stability)   8. window-level validation ROC-AUC (320 windows, finer than 32 recordings)
    9. lower mean best validation loss (weighted BCE of the validation windows)
  The validation cut is chosen on the same validation scores, so validation recall is optimistic by construction;
  the order only ranks the variants. The test split is evaluated for every variant (the comparison table asks for
  it) but never enters the rule. The exported seed is 42, as for E3, fixed in advance.

Writes
  weights/E3_single_accel/selected.json      the selected experiment, accelerometer and seed (read by --selected)
  results/E3_single_accel/analysis.json      every number the reports use
  results/E3_single_accel/analysis.md        the tables
"""
import argparse, json, math
from pathlib import Path

import numpy as np
import torch
from sklearn.metrics import roc_auc_score

import health as hl
from dataset import HERE, SPEED_HZ
from train import EXPERIMENTS, SEEDS, SPLITS, load, mlp, recording_scores, run

ACCELS = (1, 2, 3)
NAME = "E3_single_accel"
EXP = {k: f"{NAME}_a{k}" for k in ACCELS}
EXPORT_SEED = 42
KEYS = ("recall", "balanced_accuracy", "f1", "precision", "specificity", "roc_auc")


def extra(m):
    """Specificity, balanced accuracy and MCC from a train.metrics() confusion [[TN, FP], [FN, TP]]."""
    (tn, fp), (fn, tp) = m["confusion"]
    spec = tn / (tn + fp)
    den = math.sqrt((tp + fp) * (tp + fn) * (tn + fp) * (tn + fn))
    return {**m, "specificity": spec, "balanced_accuracy": (m["recall"] + spec) / 2,
            "mcc": (tp * tn - fp * fn) / den if den else 0.0, "fn": fn, "fp": fp, "tp": tp, "tn": tn}


def logits(name, seed, rows):
    """Every window's FP32 logit from the saved weights (as export.py)."""
    info = json.loads((HERE / "weights" / name / "model.json").read_text())
    X, inputs = EXPERIMENTS[name]["inputs"](rows)
    assert inputs == info["inputs"]
    Xs = (X - np.array(info["scaler"]["mean"])) / np.array(info["scaler"]["std"])
    net = mlp(len(inputs))
    net.load_state_dict(torch.load(HERE / "weights" / name / f"seed{seed}.pt", weights_only=True))
    net.eval()
    with torch.no_grad():
        return net(torch.tensor(Xs, dtype=torch.float32))[:, 0].double().numpy(), info


def summarize(name, rows):
    """Per seed: the recording metrics with the extras, window-level metrics, losses. Plus mean and std."""
    runs = json.loads((HERE / "results" / name / "metrics.json").read_text())
    y = np.array([r["label"] for r in rows])
    out = {"seeds": {}, "mean": {}, "std": {}}
    for s in SEEDS:
        run_ = runs[str(s)]
        z, info = logits(name, s, rows)
        recs, score = recording_scores(rows, z)
        d = {"cut": run_["cut"], "best_epoch": run_["best_epoch"], "epochs_run": run_["epochs_run"],
             "best_val_loss": run_["best_val_loss"],
             "train_loss_at_best": run_["history"][run_["best_epoch"] - 1][0],
             "final_train_loss": run_["history"][-1][0], "final_val_loss": run_["history"][-1][1],
             "history": run_["history"], "splits": {}, "windows": {}}
        for sp in SPLITS:
            d["splits"][sp] = extra(run_["metrics"][sp])
            k = np.array([r["split"] == sp for r in rows])
            pred = z[k] >= run_["cut"]
            wy = y[k]
            tp, fn = int((pred & (wy == 1)).sum()), int((~pred & (wy == 1)).sum())
            tn, fp = int((~pred & (wy == 0)).sum()), int((pred & (wy == 0)).sum())
            d["windows"][sp] = {"roc_auc": float(roc_auc_score(wy, z[k])), "recall": tp / (tp + fn),
                                "specificity": tn / (tn + fp), "confusion": [[tn, fp], [fn, tp]]}
        d["scores"] = {r["file"]: float(v) for r, v in zip(recs, score)}
        d["window_logits"] = z
        out["seeds"][s] = d
    for sp in SPLITS:
        vals = {k: [out["seeds"][s]["splits"][sp][k] for s in SEEDS]
                for k in ("accuracy", "precision", "recall", "f1", "balanced_accuracy", "specificity", "roc_auc", "mcc")}
        vals["window_roc_auc"] = [out["seeds"][s]["windows"][sp]["roc_auc"] for s in SEEDS]
        out["mean"][sp] = {k: float(np.mean(v)) for k, v in vals.items()}
        out["std"][sp] = {k: float(np.std(v)) for k, v in vals.items()}
    out["mean"]["best_val_loss"] = float(np.mean([out["seeds"][s]["best_val_loss"] for s in SEEDS]))
    out["std"]["best_val_loss"] = float(np.std([out["seeds"][s]["best_val_loss"] for s in SEEDS]))
    out["worst_val_recall"] = min(out["seeds"][s]["splits"]["val"]["recall"] for s in SEEDS)
    out["sizes"] = json.loads((HERE / "weights" / name / "model.json").read_text())["sizes"]
    return out


def selection_key(v):
    """The fixed rule (module docstring): a tuple compared left to right, larger is better."""
    m = v["mean"]["val"]
    return tuple(round(x, 9) for x in [*(m[k] for k in KEYS), v["worst_val_recall"], m["window_roc_auc"],
                                       -v["mean"]["best_val_loss"]])


def params(sizes):
    return sum(a * b + b for a, b in zip(sizes[:-1], sizes[1:]))


def per_speed(rows, v, split):
    """Missed faults / false alarms per speed code, per seed (recordings), and window errors per speed code."""
    files = {r["file"]: r for r in rows if r["window"] == 0 and r["split"] == split}
    res = {}
    for c in sorted({r["speed"] for r in files.values()}):
        part = [f for f, r in files.items() if r["speed"] == c]
        row = {}
        for s in SEEDS:
            sc, cut = v["seeds"][s]["scores"], v["seeds"][s]["cut"]
            row[s] = {"missed": sum(1 for f in part if files[f]["label"] == 1 and sc[f] < cut),
                      "faulty": sum(1 for f in part if files[f]["label"] == 1),
                      "false_alarms": sum(1 for f in part if files[f]["label"] == 0 and sc[f] >= cut),
                      "healthy": sum(1 for f in part if files[f]["label"] == 0),
                      "healthy_scores": [sc[f] for f in part if files[f]["label"] == 0],
                      "min_faulty_score": min(sc[f] for f in part if files[f]["label"] == 1)}
        res[c] = row
    return res


def per_class(rows, v, split):
    files = {r["file"]: r for r in rows if r["window"] == 0 and r["split"] == split and r["label"] == 1}
    res = {}
    for c in sorted({r["cls"] for r in files.values()}):
        part = [f for f, r in files.items() if r["cls"] == c]
        res[c] = {s: sum(1 for f in part if v["seeds"][s]["scores"][f] < v["seeds"][s]["cut"]) for s in SEEDS}
        res[c]["n"] = len(part)
    return res


def window_by_f(rows, v, splits=("val", "test")):
    """Window error rates at the seed's recording cut, by drive frequency band (val and test windows)."""
    bands = [(14, 20), (20, 30), (30, 40), (40, 50), (50, 61)]
    f = np.array([r["f_hz"] for r in rows])
    y = np.array([r["label"] for r in rows])
    k = np.array([r["split"] in splits for r in rows])
    out = {}
    for lo, hi in bands:
        sel = k & (f >= lo) & (f < hi)
        if not sel.any():
            continue
        row = {"n_faulty": int((sel & (y == 1)).sum()), "n_healthy": int((sel & (y == 0)).sum())}
        for s in SEEDS:
            pred = v["seeds"][s]["window_logits"] >= v["seeds"][s]["cut"]
            row[s] = {"missed": int((sel & (y == 1) & ~pred).sum()), "false_alarms": int((sel & (y == 0) & pred).sum())}
        out[f"{lo}-{hi} Hz"] = row
    return out


def health_all(rows):
    """The H1 method on each single accelerometer (train-fitted, as health.py), with the per-statistic z of the
    low-speed healthy recordings (the 15-Hz 0% problem)."""
    out = {}
    recs = [r for r in rows if r["window"] == 0]
    for k in ACCELS:
        X, lf, names = hl.statistics(rows, (k,))
        ref, D, loso, d100, d0 = hl.anchors(rows, X, lf)
        score = {f: float(hl.hi(v, d0, d100)) for f, v in D.items()}
        z = (X - ref["alpha"] - ref["beta"] * lf[:, None]) / ref["sigma"]
        res = {"d_100": d100, "d_0": d0, "splits": {}, "speeds": {}}
        for sp in SPLITS:
            part = [r for r in recs if r["split"] == sp]
            yy = [r["label"] for r in part]
            res["splits"][sp] = {
                "roc_auc": float(roc_auc_score(yy, [D[r["file"]] for r in part])),
                "healthy": {r["file"]: score[r["file"]] for r in part if r["label"] == 0},
                "faulty_hi": [score[r["file"]] for r in part if r["label"] == 1],
                "faulty_at_100": [r["file"] for r in part if r["label"] == 1 and score[r["file"]] >= 100]}
        for c in range(1, 9):
            part = [r for r in recs if r["speed"] == c]
            res["speeds"][c] = {"healthy": [score[r["file"]] for r in part if r["label"] == 0],
                                "healthy_D": [D[r["file"]] for r in part if r["label"] == 0],
                                "faulty": [score[r["file"]] for r in part if r["label"] == 1]}
        low = {}
        for fname in ("H_H_1_0.csv", "H_H_1_1.csv", "H_H_7_0.csv", "H_H_7_1.csv"):
            sel = np.array([r["file"] == fname for r in rows])
            low[fname] = dict(zip(names, z[sel].mean(axis=0).round(2).tolist()))
        res["low_speed_healthy_mean_z"] = low
        res["D"] = D
        res["score"] = score
        out[k] = res
    return out


def fmt(m, k):
    return f"{m[k]:.3f}"


def write_md(analysis, path):
    v_all, sel = analysis["variants"], analysis["selected"]
    L = [f"# {NAME}: three single-accelerometer variants (generated by single_accel.py)", "",
         "Validation numbers decide; test numbers are reported for every variant but were not used to choose.", "",
         "## Validation (recordings, mean ± std over seeds 42, 43, 44)", "",
         "| Variant | Recall | Balanced acc. | F1 | Precision | Specificity | ROC-AUC | Worst-seed recall | "
         "Window ROC-AUC | Best val loss | Rank |", "|---|---|---|---|---|---|---|---|---|---|---|"]
    for k in ACCELS:
        v = v_all[str(k)]
        m, sd = v["mean"]["val"], v["std"]["val"]
        L.append(f"| a{k} | " + " | ".join(f"{m[x]:.3f} ± {sd[x]:.3f}" for x in KEYS)
                 + f" | {v['worst_val_recall']:.3f} | {m['window_roc_auc']:.4f} ± {sd['window_roc_auc']:.4f} | "
                 f"{v['mean']['best_val_loss']:.4f} ± {v['std']['best_val_loss']:.4f} | {analysis['rank'].index(k) + 1} |")
    L += ["", f"**Selected: accelerometer {sel['accel']} ({sel['experiment']})**, seed {sel['seed']} exported.", ""]
    for sp in SPLITS:
        L += [f"## Every seed, {sp}", "",
              "| Variant | Seed | Acc. | Prec. | Recall | F1 | Bal. acc. | Spec. | ROC-AUC | MCC | [[TN,FP],[FN,TP]] | "
              "Faults found | Window ROC-AUC |", "|---|---|---|---|---|---|---|---|---|---|---|---|---|"]
        for k in ACCELS:
            for s in SEEDS:
                m = v_all[str(k)]["seeds"][str(s)]["splits"][sp]
                w = v_all[str(k)]["seeds"][str(s)]["windows"][sp]
                L.append(f"| a{k} | {s} | " + " | ".join(fmt(m, x) for x in (
                    "accuracy", "precision", "recall", "f1", "balanced_accuracy", "specificity", "roc_auc", "mcc"))
                         + f" | {m['confusion']} | {m['tp']}/{m['tp'] + m['fn']} | {w['roc_auc']:.4f} |")
            mm, sd = v_all[str(k)]["mean"][sp], v_all[str(k)]["std"][sp]
            L.append(f"| a{k} | mean ± std | " + " | ".join(f"{mm[x]:.3f} ± {sd[x]:.3f}" for x in (
                "accuracy", "precision", "recall", "f1", "balanced_accuracy", "specificity", "roc_auc", "mcc"))
                     + f" | | | {mm['window_roc_auc']:.4f} |")
        L.append("")
    L += ["## Losses (weighted BCE; windows)", "",
          "| Variant | Seed | Best / last epoch | Train loss at best | Val loss at best | Final train | Final val |",
          "|---|---|---|---|---|---|---|"]
    for k in ACCELS:
        for s in SEEDS:
            d = v_all[str(k)]["seeds"][str(s)]
            L.append(f"| a{k} | {s} | {d['best_epoch']} / {d['epochs_run']} | {d['train_loss_at_best']:.4f} | "
                     f"{d['best_val_loss']:.4f} | {d['final_train_loss']:.4f} | {d['final_val_loss']:.4f} |")
    for sp in ("val", "test"):
        L += ["", f"## Recordings by speed code ({sp}): missed faults / false alarms per seed 42, 43, 44", "",
              "| Variant | " + " | ".join(f"{c} ({SPEED_HZ[int(c)][0]}->{SPEED_HZ[int(c)][1]} Hz)"
                                       for c in analysis["per_speed"]["1"][sp]) + " |",
              "|---|" + "---|" * len(analysis["per_speed"]["1"][sp])]
        for k in ACCELS:
            ps = analysis["per_speed"][str(k)][sp]
            L.append(f"| a{k} | " + " | ".join(
                " ".join(f"{ps[c][str(s)]['missed']}/{ps[c][str(s)]['faulty']}"
                         + (f"+{ps[c][str(s)]['false_alarms']}FA" if ps[c][str(s)]['false_alarms'] else "")
                         for s in SEEDS) for c in ps) + " |")
        L += ["", f"## Missed faults by class ({sp}; seeds 42, 43, 44, of n)", "",
              "| Variant | " + " | ".join(analysis["per_class"]["1"][sp]) + " |",
              "|---|" + "---|" * len(analysis["per_class"]["1"][sp])]
        for k in ACCELS:
            pc = analysis["per_class"][str(k)][sp]
            L.append(f"| a{k} | " + " | ".join(" ".join(str(pc[c][str(s)]) for s in SEEDS) + f" of {pc[c]['n']}"
                                               for c in pc) + " |")
    L += ["", "## Windows by drive frequency (val + test; errors at the recording cut; seeds 42, 43, 44)", "",
          "| Variant | " + " | ".join(analysis["window_by_f"]["1"]) + " |",
          "|---|" + "---|" * len(analysis["window_by_f"]["1"])]
    for k in ACCELS:
        wb = analysis["window_by_f"][str(k)]
        L.append(f"| a{k} | " + " | ".join(
            "missed " + "/".join(str(wb[b][str(s)]["missed"]) for s in SEEDS) + f" of {wb[b]['n_faulty']}; FA "
            + "/".join(str(wb[b][str(s)]["false_alarms"]) for s in SEEDS) + f" of {wb[b]['n_healthy']}" for b in wb) + " |")
    L += ["", "## Health index (H1 method) on each single accelerometer", "",
          "| Accel | D_100 | D_0 | ROC-AUC of D train / val / test | Healthy HI val | Healthy HI test | "
          "Faulty HI median val / test | Faulty at 100% val / test |", "|---|---|---|---|---|---|---|---|"]
    for k in ACCELS:
        h = analysis["health"][str(k)]
        sp = h["splits"]
        L.append(f"| a{k} | {h['d_100']:.3f} | {h['d_0']:.3f} | "
                 + " / ".join(f"{sp[s]['roc_auc']:.3f}" for s in SPLITS) + " | "
                 + ", ".join(f"{f[:-4]} {v:.0f}" for f, v in sp["val"]["healthy"].items()) + " | "
                 + ", ".join(f"{f[:-4]} {v:.0f}" for f, v in sp["test"]["healthy"].items()) + " | "
                 + f"{np.median(sp['val']['faulty_hi']):.0f} / {np.median(sp['test']['faulty_hi']):.0f} | "
                 + f"{len(sp['val']['faulty_at_100'])}/28 / {len(sp['test']['faulty_at_100'])}/28 |")
    L += ["", "## Health index per speed code (HI %: healthy recordings; faulty min / median / max)", "",
          "| Speed code | " + " | ".join(f"a{k} healthy | a{k} faulty" for k in ACCELS) + " |",
          "|---|" + "---|" * (2 * len(ACCELS))]
    for c in range(1, 9):
        cells = []
        for k in ACCELS:
            s_ = analysis["health"][str(k)]["speeds"][str(c)]
            cells += [", ".join(f"{v:.0f}" for v in s_["healthy"]),
                      f"{min(s_['faulty']):.0f} / {np.median(s_['faulty']):.0f} / {max(s_['faulty']):.0f}"]
        L.append(f"| {c} ({SPEED_HZ[c][0]}->{SPEED_HZ[c][1]} Hz) | " + " | ".join(cells) + " |")
    L += ["", "## Low-speed healthy recordings: mean z per statistic (distance from the healthy reference line)", ""]
    for k in ACCELS:
        low = analysis["health"][str(k)]["low_speed_healthy_mean_z"]
        names = list(next(iter(low.values())))
        L += [f"a{k}:", "", "| Recording | " + " | ".join(n.split('_', 1)[1] for n in names) + " |",
              "|---|" + "---|" * len(names)]
        for f, zz in low.items():
            L.append(f"| {f[:-4]} | " + " | ".join(f"{zz[n]:+.2f}" for n in names) + " |")
        L.append("")
    path.write_text("\n".join(L) + "\n", encoding="utf-8")


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--no-train", action="store_true", help="use the saved weights and results")
    a = ap.parse_args()
    if not a.no_train:
        for k in ACCELS:
            run(EXP[k])
    rows = load("windows")
    variants = {k: summarize(EXP[k], rows) for k in ACCELS}
    rank = sorted(ACCELS, key=lambda k: selection_key(variants[k]), reverse=True)
    best = rank[0]
    sel = {"experiment": EXP[best], "accel": best, "seed": EXPORT_SEED, "health": f"H1_single_accel_a{best}",
           "rule": "single_accel.py docstring (validation only)",
           "keys": {str(k): list(selection_key(variants[k])) for k in ACCELS}}
    analysis = {"selected": sel, "rank": rank,
                "variants": {str(k): {kk: vv for kk, vv in v.items() if kk != "seeds"}
                             | {"seeds": {str(s): {kk: vv for kk, vv in d.items() if kk != "window_logits"}
                                          for s, d in v["seeds"].items()},
                                "params": params(v["sizes"])} for k, v in variants.items()},
                "per_speed": {str(k): {sp: {str(c): {str(s): d for s, d in row.items()}
                                            for c, row in per_speed(rows, variants[k], sp).items()}
                                       for sp in ("val", "test")} for k in ACCELS},
                "per_class": {str(k): {sp: {c: {str(s): n for s, n in row.items()}
                                            for c, row in per_class(rows, variants[k], sp).items()}
                                       for sp in ("val", "test")} for k in ACCELS},
                "window_by_f": {str(k): {b: {str(s): d for s, d in row.items()}
                                         for b, row in window_by_f(rows, variants[k]).items()} for k in ACCELS},
                "health": {str(k): {kk: ({str(c): d for c, d in vv.items()} if kk == "speeds" else vv)
                                    for kk, vv in h.items()} for k, h in health_all(rows).items()}}
    wdir, rdir = HERE / "weights" / NAME, HERE / "results" / NAME
    wdir.mkdir(parents=True, exist_ok=True)
    rdir.mkdir(parents=True, exist_ok=True)
    (wdir / "selected.json").write_text(json.dumps(sel, indent=1) + "\n", encoding="utf-8")
    (rdir / "analysis.json").write_text(json.dumps(analysis, indent=1) + "\n", encoding="utf-8")
    write_md(analysis, rdir / "analysis.md")
    print(f"validation rank: " + ", ".join(f"a{k} {selection_key(variants[k])}" for k in rank))
    print(f"selected accelerometer {best} ({EXP[best]}); wrote {wdir / 'selected.json'} and {rdir}")


if __name__ == "__main__":
    main()
