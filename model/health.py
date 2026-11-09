"""Output 2: the health index H1, 0-100%, of the last 10 s (Alex, 27 Oct: 100% = inside the healthy motor's range at
that speed, 0% = a typical faulty recording).

  python health.py            (from the cached features; the dataset is not needed)
  python health.py --accels 1 --name H1_single_accel_a1     the same method on one accelerometer (7 statistics)

How far the motor's vibration is from the healthy motor's at the same speed:
  1. Healthy reference, from the 80 healthy train windows only: for each of the 21 window statistics x_j (E3's inputs
     without ln f: ln std, ln RMS, ln max|x|, ln peak-to-peak, crest, skewness, kurtosis of accelerometers 1, 2, 3),
     a line in ln f (least squares) and the spread of the healthy windows around it (sigma_j, population).
  2. Window distance d = sqrt(mean_j z_j^2), z_j = (x_j - alpha_j - beta_j ln f) / sigma_j.
  3. Recording distance D = the mean of its 10 window distances (on the board: the last 10 s).
  4. Anchors, from train only: D_100 = the largest D of the 8 healthy train recordings, each measured with a reference
     fitted without its speed code (so it is an unseen speed, like val and test); D_0 = the median D of the 56 faulty
     train recordings.
  5. HI = 100% * clip((D_0 - D) / (D_0 - D_100), 0, 1): 100% inside the healthy range, 0% as far out as a typical fault.
It is a distance from one healthy motor, not a remaining capability (the data has no wear levels).

Writes weights/H1/health.json (reference and anchors, for the ARM) and results/H1/health.csv, report.md.
"""
import argparse, csv, json
from pathlib import Path

import numpy as np
from sklearn.metrics import roc_auc_score

from dataset import HERE, SPEED_HZ
from train import SPLITS, load, log_inputs

ACCELS = (1, 2, 3)


def statistics(rows, accels=ACCELS):
    """The 7 window statistics of each given accelerometer (E3's inputs without ln f) and ln f. Statistics of later
    sensors (temperature, measured RPM) would be appended to X here: reference(), window_d() and anchors() work on
    any number of columns."""
    X, names = log_inputs(rows, np.array([r["f_hz"] for r in rows]), accels=accels)
    return X[:, :-1], X[:, -1], names[:-1]


def reference(X, lf):
    """Per statistic: alpha, beta of x = alpha + beta ln f (least squares) and sigma (RMS of the residuals)."""
    A = np.column_stack([np.ones_like(lf), lf])
    coef, *_ = np.linalg.lstsq(A, X, rcond=None)
    sigma = np.sqrt(((X - A @ coef) ** 2).mean(axis=0))
    return {"alpha": coef[0], "beta": coef[1], "sigma": np.where(sigma > 1e-12, sigma, 1.0)}


def window_d(X, lf, ref):
    z = (X - ref["alpha"] - ref["beta"] * lf[:, None]) / ref["sigma"]
    return np.sqrt((z ** 2).mean(axis=1))


def recording_D(rows, d):
    out = {}
    for r, v in zip(rows, d):
        out.setdefault(r["file"], []).append(float(v))
    return {f: float(np.mean(v)) for f, v in out.items()}


def hi(D, d0, d100):
    return 100.0 * np.clip((d0 - np.asarray(D)) / (d0 - d100), 0.0, 1.0)


def anchors(rows, X, lf):
    """D_100 (leave-one-speed-code-out over the healthy train recordings) and D_0 (median faulty train D)."""
    tr = np.array([r["split"] == "train" for r in rows])
    healthy = tr & np.array([r["label"] == 0 for r in rows])
    speeds = sorted({r["speed"] for r, h in zip(rows, healthy) if h})
    loso = {}
    for sp in speeds:
        fit = healthy & np.array([r["speed"] != sp for r in rows])
        held = healthy & np.array([r["speed"] == sp for r in rows])
        ref = reference(X[fit], lf[fit])
        loso.update(recording_D([r for r, k in zip(rows, held) if k], window_d(X[held], lf[held], ref)))
    full = reference(X[healthy], lf[healthy])
    D = recording_D(rows, window_d(X, lf, full))
    faulty_train = [D[r["file"]] for r in rows if r["split"] == "train" and r["label"] == 1 and r["window"] == 0]
    return full, D, loso, max(loso.values()), float(np.median(faulty_train))


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--out", type=Path, default=HERE, help="folder for weights/ and results/ (default model/)")
    ap.add_argument("--train-only", action="store_true", help="print the train anchors only (nothing written)")
    ap.add_argument("--accels", type=int, nargs="+", default=list(ACCELS), help="accelerometers (default 1 2 3)")
    ap.add_argument("--name", default="H1", help="folder name under weights/ and results/ (default H1)")
    a = ap.parse_args()
    rows = load("windows")
    X, lf, names = statistics(rows, tuple(a.accels))
    ref, D, loso, d100, d0 = anchors(rows, X, lf)
    recs = [r for r in rows if r["window"] == 0]
    if a.train_only:
        print(f"D_100 = {d100:.4f} (leave-one-speed-out healthy train: "
              + ", ".join(f"{f[:-4]} {v:.3f}" for f, v in sorted(loso.items())) + f"), D_0 = {d0:.4f}")
        tr = [r for r in recs if r["split"] == "train"]
        for y in (0, 1):
            v = [D[r["file"]] for r in tr if r["label"] == y]
            print(f"  train {'healthy' if y == 0 else 'faulty'} D (reference includes healthy train): "
                  f"{min(v):.3f} .. {np.median(v):.3f} .. {max(v):.3f}")
        return
    if d0 <= d100:
        raise SystemExit(f"D_0 = {d0:.4f} is not above D_100 = {d100:.4f}: the index cannot separate them")

    score = {f: hi(v, d0, d100) for f, v in D.items()}
    wdir, rdir = a.out / "weights" / a.name, a.out / "results" / a.name
    wdir.mkdir(parents=True, exist_ok=True)
    rdir.mkdir(parents=True, exist_ok=True)
    info = {"name": a.name, "statistics": names, "f": "f_hz, the window's drive command (as E2, E3)",
            "alpha": ref["alpha"].tolist(), "beta": ref["beta"].tolist(), "sigma": ref["sigma"].tolist(),
            "d_100": d100, "d_0": d0, "loso_healthy_D": loso,
            "formula": "d = sqrt(mean_j ((x_j - alpha_j - beta_j ln f) / sigma_j)^2); D = mean of 10 window d; "
                       "HI = 100 * clip((d_0 - D) / (d_0 - d_100), 0, 1)"}
    (wdir / "health.json").write_text(json.dumps(info, indent=1) + "\n", encoding="utf-8")
    with open(rdir / "health.csv", "w", newline="") as f:
        w = csv.writer(f, lineterminator="\n")
        w.writerow(["file", "cls", "label", "speed", "load", "split", "D", "HI"])
        for r in recs:
            w.writerow([r[k] for k in ("file", "cls", "label", "speed", "load", "split")]
                       + [D[r["file"]], float(score[r["file"]])])
    (rdir / "report.md").write_text(report(recs, D, score, d100, d0, loso, a.name), encoding="utf-8")
    print(f"{a.name}: D_100 = {d100:.4f}, D_0 = {d0:.4f}")
    for sp in SPLITS:
        part = [r for r in recs if r["split"] == sp]
        h = [score[r["file"]] for r in part if r["label"] == 0]
        f_ = [score[r["file"]] for r in part if r["label"] == 1]
        print(f"  {sp}: healthy HI {min(h):.0f}..{max(h):.0f}%, faulty HI median {np.median(f_):.0f}% "
              f"(max {max(f_):.0f}%), ROC-AUC of D {roc_auc_score([r['label'] for r in part], [D[r['file']] for r in part]):.3f}")
    print(f"  wrote {wdir} and {rdir}")


def report(recs, D, score, d100, d0, loso, name="H1"):
    L = [f"# {name}: health index (output 2)", "",
         f"D_100 = {d100:.4f} (largest leave-one-speed-out D of the healthy train recordings), "
         f"D_0 = {d0:.4f} (median D of the faulty train recordings). HI = 100% * clip((D_0 - D) / (D_0 - D_100), 0, 1).",
         "", "Leave-one-speed-out D of the healthy train recordings: "
         + ", ".join(f"{f[:-4]} {v:.3f}" for f, v in sorted(loso.items())), "",
         "## Per split", "",
         "| Split | Healthy HI (each) | Healthy at 100% | Faulty HI min / median / max | Faulty <= 50% | Faulty at 0% | ROC-AUC of D |",
         "|---|---|---|---|---|---|---|"]
    for sp in SPLITS:
        part = [r for r in recs if r["split"] == sp]
        h = [score[r["file"]] for r in part if r["label"] == 0]
        f = np.array([score[r["file"]] for r in part if r["label"] == 1])
        auc = roc_auc_score([r["label"] for r in part], [D[r["file"]] for r in part])
        L.append(f"| {sp} | {', '.join(f'{v:.0f}' for v in h)} | {sum(v >= 100 for v in h)}/{len(h)} | "
                 f"{f.min():.0f} / {np.median(f):.0f} / {f.max():.0f} | {int((f <= 50).sum())}/{len(f)} | "
                 f"{int((f <= 0).sum())}/{len(f)} | {auc:.3f} |")
    L += ["", "## Per speed code (HI %; healthy: both loads; faulty: min / median / max of 14)", "",
          "| Speed code | Split | Healthy | Faulty | Healthy D | Faulty D min |", "|---|---|---|---|---|---|"]
    for c in range(1, 9):
        part = [r for r in recs if r["speed"] == c]
        h = [score[r["file"]] for r in part if r["label"] == 0]
        f = np.array([score[r["file"]] for r in part if r["label"] == 1])
        L.append(f"| {c} ({SPEED_HZ[c][0]}->{SPEED_HZ[c][1]} Hz) | {part[0]['split']} | "
                 f"{', '.join(f'{v:.0f}' for v in h)} | {f.min():.0f} / {np.median(f):.0f} / {f.max():.0f} | "
                 f"{', '.join(f'{D[r['file']]:.2f}' for r in part if r['label'] == 0)} | "
                 f"{min(D[r['file']] for r in part if r['label'] == 1):.2f} |")
    L += ["", "## Per fault class (HI %, min / median / max over its 16 recordings; val and test only: 8)", "",
          "| Class | All | Val + test |", "|---|---|---|"]
    for c in sorted({r["cls"] for r in recs}):
        v = np.array([score[r["file"]] for r in recs if r["cls"] == c])
        u = np.array([score[r["file"]] for r in recs if r["cls"] == c and r["split"] != "train"])
        L.append(f"| {c} | {v.min():.0f} / {np.median(v):.0f} / {v.max():.0f} | {u.min():.0f} / {np.median(u):.0f} / {u.max():.0f} |")
    return "\n".join(L) + "\n"


if __name__ == "__main__":
    main()
