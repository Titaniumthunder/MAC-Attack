"""The three checks to pass before any training. Writes modelV2/prechecks/ (PNG plots, prechecks.html, prechecks.json).

  model/.venv/bin/python modelV2/precheck.py

1. Ottawa stages: does "developing" separate from healthy by more than one healthy recording differs from another?
2. Healthy rows, Paderborn vs Ottawa: do the z-features overlap, and can a classifier tell the datasets apart?
3. Ottawa above 10 kHz: signal or noise?
Development bearings only.
"""
import json

import matplotlib.pyplot as plt
import numpy as np
import scipy.io as sio
from scipy import signal
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import roc_auc_score
from sklearn.model_selection import GroupKFold, cross_val_predict
from sklearn.neural_network import MLPClassifier
from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import StandardScaler

import config as c
import pipeline as F
import prep
import anomaly_baseline as ab                      # model/

STAGE_COLOR = {0: ab.BLUE, 1: ab.ORANGE, 2: "#b3261e"}
STAGE_NAME = {0: "healthy", 1: "developing", 2: "faulty"}
# Bearing model per the dataset description as I remember it (not in the files): 1-10 FAFNIR 203KD, 11-20 NSK 6203ZZ.
SAME_MODEL = [range(1, 11), range(11, 21)]


def probes():
    return {"logistic": make_pipeline(StandardScaler(), LogisticRegression(max_iter=2000, class_weight="balanced")),
            "mlp": make_pipeline(StandardScaler(), MLPClassifier((16,), max_iter=2000, random_state=0))}


def dataset_auc(X, ds, groups):
    """Can the dataset be told from these rows? Bearing-grouped cross-validation; the larger AUC of two probes."""
    cv = GroupKFold(min(5, len(set(groups[ds == 0])), len(set(groups[ds == 1]))))
    return {k: float(roc_auc_score(ds, cross_val_predict(p, X, ds, groups=groups, cv=cv, method="predict_proba")[:, 1]))
            for k, p in probes().items()}


def check_stages(ott, floor):
    base = {n: F.baseline(t[t.role == "baseline"], floor) for n, t in ott.groupby("bearing")}
    score = lambda rows, n: ab.score(rows, base[n])[0]
    fig, ax = plt.subplots(figsize=(11, 4.2))
    res, x = {}, 0
    for group in SAME_MODEL:
        ns = [n for n in base if n in group]
        cross = {n: [float(np.median(score(ott[(ott.bearing == n) & (ott.role == "healthy")], o))) for o in ns if o != n]
                 for n in ns}
        yard = float(np.percentile(sum(cross.values(), []), 95))
        ax.hlines(yard, x - 0.5, x + len(ns) - 0.5, color=ab.MUTED, linestyle="--", linewidth=1)
        for n in ns:
            t = ott[ott.bearing == n]
            st = {k: score(t[(t.stage == k) & (t.role != "baseline") & (t.role != "skip")], n) for k in (0, 1, 2)}
            ax.vlines(x - 0.25, min(cross[n]), max(cross[n]), color=ab.MUTED, linewidth=3)
            for k, v in st.items():
                ax.plot(np.full(len(v), x + 0.12 * k), v, ".", ms=4, color=STAGE_COLOR[k])
            m1, m2 = float(np.median(st[1])), float(np.median(st[2]))
            res[int(n)] = {"type": c.OTT_TYPE[n], "healthy_own": float(np.median(st[0])), "healthy_cross_max": max(cross[n]),
                           "yardstick": yard, "stage1": m1, "stage2": m2, "stage1_above_yardstick": m1 > yard,
                           "stage2_above_stage1": m2 > m1}
            x += 1
    ax.set_yscale("log")
    ax.set_xticks(range(len(res)), [f"{n}\n{r['type']}" for n, r in res.items()])
    ax.set_ylabel("detector score (own baseline)")
    ax.set_title("Ottawa: score by stage per bearing. Blue healthy, orange developing, red faulty; grey bar: this bearing's "
                 "healthy windows\nscored against other healthy bearings' baselines; dashed: 95th percentile of that spread",
                 fontsize=9, loc="left")
    fig.tight_layout()
    fig.savefig(c.writable(c.PRECHECKS / "check1_stages.png"), dpi=150)
    n1, n2 = sum(r["stage1_above_yardstick"] for r in res.values()), sum(r["stage2_above_stage1"] for r in res.values())
    need = int(np.ceil(0.75 * len(res)))
    return {"pass": n1 >= need and n2 >= need, "stage1_above_yardstick": n1, "stage2_above_stage1": n2, "bearings": len(res),
            "needed": need, "per_bearing": res}


def check_overlap(rows):
    """Healthy rows not used to fit the baseline: Paderborn hold rows and Ottawa's last-5-s windows."""
    pad = (rows["ds"] == 0) & (rows["k"] >= c.REF_N) & (rows["k"] < c.REF_N + c.HOLD_N)
    ott = (rows["ds"] == 1) & (rows["y"] == 0)
    V = np.column_stack([rows["Z"], np.log(rows["s"])])
    names = F.NAMES + ["ln score"]
    fig, ax = plt.subplots(figsize=(11, 3.8))
    res = {}
    for j, n in enumerate(names):
        lo, hi = np.percentile(V[pad, j], [5, 95])
        med = float(np.median(V[ott, j]))
        res[n] = {"paderborn_5_95": [float(lo), float(hi)], "ottawa_median": med, "inside": bool(lo <= med <= hi)}
        for off, m, col in ((-0.18, pad, ab.BLUE), (0.18, ott, ab.ORANGE)):
            ax.boxplot(V[m, j], positions=[j + off], widths=0.3, showfliers=False, patch_artist=True,
                       boxprops={"facecolor": col, "alpha": 0.6}, medianprops={"color": "k"})
    ax.set_xticks(range(len(names)), names)
    ax.set_ylabel("z (healthy rows)")
    ax.set_title("Healthy rows outside the baseline fit: Paderborn (blue) vs Ottawa (orange)", fontsize=9, loc="left")
    fig.tight_layout()
    fig.savefig(c.writable(c.PRECHECKS / "check2_overlap.png"), dpi=150)
    m = pad | ott
    X = F.network_inputs(rows["Z"][m], rows["s"][m], rows["rpm"][m], rows["M"][m], np.full(m.sum(), c.HIST))
    auc = dataset_auc(X, rows["ds"][m], rows["bearing"][m])
    auc_no_rpm = dataset_auc(X[:, :-1], rows["ds"][m], rows["bearing"][m])
    return {"pass": all(r["inside"] for r in res.values()) and max(auc.values()) <= 0.8, "features": res,
            "probe_auc": auc, "probe_auc_without_rpm": auc_no_rpm, "rows": {"paderborn": int(pad.sum()), "ottawa": int(ott.sum())}}


def check_high_band():
    """Raw (not low-passed) Ottawa spectra: is 10-15 kHz above the 15-21 kHz floor, and does it rise with the stage?"""
    psd = {k: [] for k in (0, 1, 2)}
    for n in c.OTT_DEV:
        for k in psd:
            p = prep.ottawa_file(n, k)
            x = sio.loadmat(p)[p.stem][:, 0]
            f, P = signal.welch(x - x.mean(), c.FS, nperseg=8192)
            psd[k].append(P)
    psd = {k: np.array(v) for k, v in psd.items()}
    band = lambda P, lo, hi: P[:, (f >= lo) & (f < hi)].mean(axis=1)
    above_floor = float(np.median(band(psd[0], 10e3, 15e3) / band(psd[0], 15e3, 21e3)))
    rise = {k: float(np.median(band(psd[k], 10e3, 15e3) / band(psd[0], 10e3, 15e3))) for k in (1, 2)}
    fig, ax = plt.subplots(figsize=(11, 3.8))
    for k, P in psd.items():
        ax.semilogy(f / 1e3, np.median(P, axis=0), color=STAGE_COLOR[k], label=STAGE_NAME[k])
    ax.axvspan(10, 15, color=ab.MUTED, alpha=0.15)
    ax.axvline(15, color=ab.INK2, linestyle="--", linewidth=1)
    ax.set_xlabel("kHz (shaded: 10-15 kHz; dashed: the 15 kHz cap)")
    ax.set_ylabel("PSD, median over bearings")
    ax.legend()
    fig.tight_layout()
    fig.savefig(c.writable(c.PRECHECKS / "check3_high_band.png"), dpi=150)
    return {"pass": above_floor >= 4 and rise[2] >= 2, "level_10_15k_over_15_21k_healthy": above_floor,
            "power_10_15k_vs_healthy": {"developing": rise[1], "faulty": rise[2]},
            "rule": "healthy 10-15 kHz level at least 4x (6 dB) the 15-21 kHz level, and faulty at least 2x (3 dB) healthy"}


def main():
    rows = dict(np.load(c.DATA / "rows.npz"))
    floor = np.array(list(json.loads((c.DATA / "summary.json").read_text())["sigma_floor"].values()))
    res = {"1 Ottawa stages vs recording-to-recording spread": check_stages(prep.ottawa_table(), floor),
           "2 Healthy rows, Paderborn vs Ottawa": check_overlap(rows),
           "3 Ottawa signal above 10 kHz": check_high_band()}
    c.writable(c.PRECHECKS / "prechecks.json").write_text(json.dumps(res, indent=1) + "\n")
    imgs = ["check1_stages.png", "check2_overlap.png", "check3_high_band.png"]
    html = "".join(f"<h2>{k}: {'PASS' if r['pass'] else 'FAIL'}</h2><img src='{i}' style='max-width:100%'>"
                   f"<pre>{json.dumps({a: b for a, b in r.items() if a != 'per_bearing'}, indent=1)}</pre>"
                   for (k, r), i in zip(res.items(), imgs))
    (c.PRECHECKS / "prechecks.html").write_text(f"<html><body style='font-family:sans-serif;max-width:1100px;margin:auto'>"
                                                f"<h1>modelV2 pre-checks</h1>{html}</body></html>")
    for k, r in res.items():
        print(f"{'PASS' if r['pass'] else 'FAIL'}  {k}")
    print(f"plots: {c.PRECHECKS / 'prechecks.html'}")


if __name__ == "__main__":
    main()
