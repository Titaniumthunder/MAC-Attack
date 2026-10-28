"""Train and evaluate one Machine Guardian experiment from the cached features (the dataset is not needed).

  python train.py E0          James's baseline rebuilt: 8 statistics of accelerometers 2 and 3 per recording
  python train.py E1          the same without the means, ln of the 4 amplitudes, plus ln(commanded frequency)
  python train.py E2          E1 on 1-s windows (f = the window's drive command); recording score = mean of 10 logits
  python train.py E3          E2 plus accelerometer 1 (22 inputs)

Writes
  weights/<E>/seed<s>.pt      PyTorch state_dict per seed (torch.load(..., weights_only=True))
  weights/<E>/model.json      inputs, layer sizes, standardizer, pos_weight, threshold and stopping epoch per seed
  results/<E>/metrics.json    every metric for train, val and test, every seed
  results/<E>/scores.csv      every recording's score (logit) and decision, every seed
  results/<E>/report.md       the tables that go into docs/log.md

Rules (Alex's spec of 27 Oct, the same as James's):
  MLP K -> 32 -> 16 -> 1, ReLU, no dropout; Adam lr 1e-3, betas (0.9, 0.999), eps 1e-8, weight decay 0;
  batch 64; at most 100 epochs; early stop with patience 15 on the weighted validation BCE (improvement
  > 1e-5), keeping the best epoch's weights; BCEWithLogitsLoss with pos_weight = train healthy / train faulty;
  standardizer fitted on train only; seeds 42, 43, 44 (42 is the reported run); deterministic, on the CPU.
  Threshold: the lowest cut on the validation scores that maximizes validation F1 with validation
  recall >= 0.8 (faulty if score >= cut). Positive class = faulty. A recording's score is its logit, or the
  mean of its windows' logits when an experiment uses windows.
Details that fix every bit (27 Oct):
  standardizer = the train rows' mean and population std (ddof 0) in float64, from the float64 inputs (after the
  logarithms), std <= 1e-12 -> 1; (X - mean) / std in float64, then cast to float32 (scikit-learn's StandardScaler);
  batch order: a new torch.Generator().manual_seed(seed); each epoch one torch.randperm(n_train) over the train rows
  in table order, cut into consecutive batches of 64 (no DataLoader);
  the validation loss: one pass over all validation rows (recordings for E0/E1, windows for E2/E3: not comparable
  across the two); the scores: one float32 forward pass over all rows; a recording's score = the float64 mean of its
  float32 window logits; history[i] = [train-set and validation weighted BCE after epoch i].
"""
import argparse, copy, csv, json, math, time
from collections import Counter
from pathlib import Path

import numpy as np
import torch
from sklearn.metrics import roc_auc_score
from torch import nn

from dataset import FEATURES, HERE, SPEED_HZ, commanded_hz
from features import COLS, META, STATS

SEEDS = (42, 43, 44)
HIDDEN = (32, 16)
LR, BETAS, EPS, WEIGHT_DECAY = 1e-3, (0.9, 0.999), 1e-8, 0.0
BATCH, EPOCHS, PATIENCE, MIN_DELTA = 64, 100, 15, 1e-5
MIN_RECALL = 0.8
SPLITS = ("train", "val", "test")
JAMES = {"faults_found": 18, "faulty": 28, "false_alarms": 0, "healthy": 4, "roc_auc": 0.875}   # seed 42, test;
# from Alex's spec (27 Oct); James's report and script are not in the repo


def e0_inputs(rows):
    names = [f"a{a}_{s}" for a in (2, 3) for s in STATS]
    return np.array([[r[n] for n in names] for r in rows]), names


LOG_STATS = ("std", "rms", "absmax", "p2p")


def log_inputs(rows, f, accels=(2, 3)):
    """Per accelerometer (in the order given): ln of std, RMS, max|x|, peak-to-peak, then crest, skewness, kurtosis;
    last ln(f), f in Hz. The means are dropped."""
    stats = [s for s in STATS if s != "mean"]
    names = [f"a{a}_{'log_' if s in LOG_STATS else ''}{s}" for a in accels for s in stats] + ["log_f"]
    raw = np.array([[r[f"a{a}_{s}"] for a in accels for s in stats] for r in rows])
    amp = np.array([s in LOG_STATS for a in accels for s in stats])
    if (raw[:, amp] <= 0).any():
        raise SystemExit("an amplitude is <= 0, its logarithm is undefined")
    return np.column_stack([np.where(amp, np.log(np.where(amp, raw, 1.0)), raw), np.log(f)]), names


def e1_inputs(rows):
    """f = the nominal commanded frequency of the recording (a ramp's mean over the 10 s)."""
    return log_inputs(rows, np.array([commanded_hz(r["speed"]) for r in rows]))


def e2_inputs(rows):
    """Per 1-s window; f = the drive command's mean over the window (features.py, speed.py)."""
    return log_inputs(rows, np.array([r["f_hz"] for r in rows]))


def e3_inputs(rows):
    """E2 with accelerometer 1 added (accelerometers 1, 2, 3, then ln f)."""
    return log_inputs(rows, np.array([r["f_hz"] for r in rows]), accels=(1, 2, 3))


# Each experiment is fixed once it has been run and its test result seen; new ideas are new experiments.
EXPERIMENTS = {
    "E0": {"title": "James's baseline rebuilt", "table": "recordings", "inputs": e0_inputs},
    "E1": {"title": "log amplitudes and log f", "table": "recordings", "inputs": e1_inputs},
    "E2": {"title": "E1 on 1-s windows", "table": "windows", "inputs": e2_inputs},
    "E3": {"title": "E2 plus accelerometer 1", "table": "windows", "inputs": e3_inputs},
}


def load(table):
    with open(FEATURES / f"{table}.csv", newline="") as f:
        rows = list(csv.DictReader(f))
    for r in rows:
        for k in ("label", "speed", "load", "window"):
            if k in r:
                r[k] = int(r[k])
        for k in COLS + ["t0", "t1", "f_hz"]:
            if k in r:
                r[k] = float(r[k])
    return rows


def mlp(k):
    layers, n = [], k
    for h in HIDDEN:
        layers += [nn.Linear(n, h), nn.ReLU()]
        n = h
    return nn.Sequential(*layers, nn.Linear(n, 1))


def train(Xtr, ytr, Xva, yva, seed, pos_weight):
    """One training run. Returns the network with the best epoch's weights, and its history."""
    torch.manual_seed(seed)                                   # the initial weights
    net = mlp(Xtr.shape[1])
    opt = torch.optim.Adam(net.parameters(), lr=LR, betas=BETAS, eps=EPS, weight_decay=WEIGHT_DECAY)
    loss_fn = nn.BCEWithLogitsLoss(pos_weight=torch.tensor([pos_weight], dtype=torch.float32))
    order = torch.Generator().manual_seed(seed)              # the batch order
    best, best_state, best_epoch, wait, hist = math.inf, None, 0, 0, []
    for epoch in range(1, EPOCHS + 1):
        net.train()
        for idx in torch.randperm(len(Xtr), generator=order).split(BATCH):
            opt.zero_grad()
            loss_fn(net(Xtr[idx])[:, 0], ytr[idx]).backward()
            opt.step()
        net.eval()
        with torch.no_grad():
            tl, vl = loss_fn(net(Xtr)[:, 0], ytr).item(), loss_fn(net(Xva)[:, 0], yva).item()
        hist.append([tl, vl])
        if vl < best - MIN_DELTA:
            best, best_epoch, wait, best_state = vl, epoch, 0, copy.deepcopy(net.state_dict())
        else:
            wait += 1
            if wait >= PATIENCE:
                break
    net.load_state_dict(best_state)
    return net, {"best_epoch": best_epoch, "epochs_run": epoch, "best_val_loss": best, "history": hist}


def pick_cut(score, y):
    """The lowest cut that maximizes F1 with recall >= MIN_RECALL (faulty if score >= cut)."""
    best_f1, best_cut = -1.0, None
    for cut in np.unique(score):                              # ascending, so ties keep the lowest
        pred = score >= cut
        tp, fp, fn = int((pred & (y == 1)).sum()), int((pred & (y == 0)).sum()), int((~pred & (y == 1)).sum())
        if tp / (tp + fn) >= MIN_RECALL and 2 * tp / (2 * tp + fp + fn) > best_f1:
            best_f1, best_cut = 2 * tp / (2 * tp + fp + fn), float(cut)
    return best_cut


def metrics(score, y, cut, recs):
    pred = score >= cut
    tp, fp = int((pred & (y == 1)).sum()), int((pred & (y == 0)).sum())
    fn, tn = int((~pred & (y == 1)).sum()), int((~pred & (y == 0)).sum())
    missed = [r for r, p, t in zip(recs, pred, y) if t == 1 and not p]
    alarms = [r for r, p, t in zip(recs, pred, y) if t == 0 and p]
    return {"accuracy": (tp + tn) / len(y), "precision": tp / (tp + fp) if tp + fp else 0.0,
            "recall": tp / (tp + fn), "f1": 2 * tp / (2 * tp + fp + fn), "roc_auc": float(roc_auc_score(y, score)),
            "confusion": [[tn, fp], [fn, tp]],
            "missed": [r["file"] for r in missed], "false_alarms": [r["file"] for r in alarms],
            "missed_by_speed": dict(sorted(Counter(r["speed"] for r in missed).items())),
            "missed_by_class": dict(sorted(Counter(r["cls"] for r in missed).items())),
            "false_alarms_by_speed": dict(sorted(Counter(r["speed"] for r in alarms).items()))}


def recording_scores(rows, logits):
    """Recordings in first-seen order, and each one's score: the mean of its rows' logits."""
    files, groups = {}, {}
    for r, z in zip(rows, logits):
        files.setdefault(r["file"], {k: r[k] for k in META})
        groups.setdefault(r["file"], []).append(float(z))
    recs = list(files.values())
    return recs, np.array([np.mean(groups[r["file"]]) for r in recs])


def report(name, exp, info, runs, recs):
    """results/<E>/report.md: the tables for the log."""
    f3 = lambda v: f"{v:.3f}"
    L = [f"# {name}: {exp['title']}", "",
         f"Inputs ({len(info['inputs'])}): {', '.join(info['inputs'])}", "",
         f"Train {info['n']['train']}, val {info['n']['val']}, test {info['n']['test']} "
         f"({exp['table']}); pos_weight = {info['pos_weight']:.6f}. Positive class = faulty.", "",
         "## Every seed (threshold from validation)", "",
         "| Seed | Split | Accuracy | Precision | Recall | F1 | ROC-AUC | [[TN,FP],[FN,TP]] | t (cut) | Best / last epoch |",
         "|---|---|---|---|---|---|---|---|---|---|"]
    for s, run in runs.items():
        for sp in SPLITS:
            m = run["metrics"][sp]
            L.append(f"| {s} | {sp} | {f3(m['accuracy'])} | {f3(m['precision'])} | {f3(m['recall'])} | "
                     f"{f3(m['f1'])} | {f3(m['roc_auc'])} | {m['confusion']} | "
                     f"{run['t']:.4f} ({run['cut']:+.4f}) | {run['best_epoch']} / {run['epochs_run']} |")
    m = runs[SEEDS[0]]["metrics"]["test"]
    L += ["", f"## Seed {SEEDS[0]} (the reported run) against James's report (test)", "",
          "| | Faults found | False alarms | ROC-AUC |", "|---|---|---|---|",
          f"| James | {JAMES['faults_found']}/{JAMES['faulty']} | {JAMES['false_alarms']}/{JAMES['healthy']} | {JAMES['roc_auc']:.3f} |",
          f"| {name} | {m['confusion'][1][1]}/{sum(m['confusion'][1])} | {m['confusion'][0][1]}/{sum(m['confusion'][0])} | {m['roc_auc']:.3f} |"]
    test = [runs[s]["metrics"]["test"] for s in runs]
    L += ["", "## Test, mean and spread over the seeds", "", "| | Accuracy | Precision | Recall | F1 | ROC-AUC |",
          "|---|---|---|---|---|---|",
          "| mean ± std | " + " | ".join(f"{np.mean([t[k] for t in test]):.3f} ± {np.std([t[k] for t in test]):.3f}"
                                     for k in ("accuracy", "precision", "recall", "f1", "roc_auc")) + " |"]
    for sp in ("test", "val"):
        part = [r for r in recs if r["split"] == sp]
        speeds = sorted({r["speed"] for r in part})
        classes = sorted({r["cls"] for r in part if r["label"] == 1})
        L += ["", f"## Missed faults by speed code ({sp}; missed / faulty recordings at that speed)", "",
              "| Seed | " + " | ".join(f"{c} ({SPEED_HZ[c][0]}->{SPEED_HZ[c][1]} Hz)" for c in speeds) + " | False alarms by speed |",
              "|---|" + "---|" * len(speeds) + "---|"]
        for s, run in runs.items():
            mm = run["metrics"][sp]
            L.append(f"| {s} | " + " | ".join(
                f"{mm['missed_by_speed'].get(c, 0)}/{sum(1 for r in part if r['speed'] == c and r['label'] == 1)}"
                for c in speeds) + " | " + (", ".join(f"{c}: {n}" for c, n in mm["false_alarms_by_speed"].items()) or "none") + " |")
        L += ["", f"## Missed faults by fault class ({sp}; missed / recordings of that class)", "",
              "| Seed | " + " | ".join(classes) + " |", "|---|" + "---|" * len(classes)]
        for s, run in runs.items():
            mm = run["metrics"][sp]
            L.append(f"| {s} | " + " | ".join(
                f"{mm['missed_by_class'].get(c, 0)}/{sum(1 for r in part if r['cls'] == c)}" for c in classes) + " |")
    L += ["", "## Missed recordings (test)", ""]
    for s, run in runs.items():
        L.append(f"- seed {s}: " + (", ".join(run["metrics"]["test"]["missed"]) or "none")
                 + ("; false alarms: " + ", ".join(run["metrics"]["test"]["false_alarms"])
                    if run["metrics"]["test"]["false_alarms"] else ""))
    return "\n".join(L) + "\n"


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("experiment", choices=sorted(EXPERIMENTS))
    ap.add_argument("--out", type=Path, default=HERE, help="folder for weights/ and results/ (default model/)")
    a = ap.parse_args()
    torch.use_deterministic_algorithms(True)
    torch.set_num_threads(1)
    name, exp = a.experiment, EXPERIMENTS[a.experiment]
    t_start = time.time()

    rows = load(exp["table"])
    X, inputs = exp["inputs"](rows)
    y = np.array([r["label"] for r in rows])
    part = {sp: np.array([r["split"] == sp for r in rows]) for sp in SPLITS}
    mean, std = X[part["train"]].mean(axis=0), X[part["train"]].std(axis=0)
    std = np.where(std > 1e-12, std, 1.0)
    Xs = torch.tensor((X - mean) / std, dtype=torch.float32)
    yt = torch.tensor(y, dtype=torch.float32)
    pos_weight = float((y[part["train"]] == 0).sum() / (y[part["train"]] == 1).sum())

    wdir, rdir = a.out / "weights" / name, a.out / "results" / name
    wdir.mkdir(parents=True, exist_ok=True)
    rdir.mkdir(parents=True, exist_ok=True)
    runs, scores = {}, {}
    for seed in SEEDS:
        tr, va = part["train"], part["val"]
        net, hist = train(Xs[tr], yt[tr], Xs[va], yt[va], seed, pos_weight)
        with torch.no_grad():
            logits = net(Xs)[:, 0].double().numpy()
        recs, score = recording_scores(rows, logits)
        ry = np.array([r["label"] for r in recs])
        rp = {sp: np.array([r["split"] == sp for r in recs]) for sp in SPLITS}
        cut = pick_cut(score[rp["val"]], ry[rp["val"]])
        runs[seed] = {"cut": cut, "t": 1.0 / (1.0 + math.exp(-cut)), **hist,
                      "metrics": {sp: metrics(score[rp[sp]], ry[rp[sp]], cut,
                                              [r for r, k in zip(recs, rp[sp]) if k]) for sp in SPLITS}}
        scores[seed] = score
        torch.save(net.state_dict(), wdir / f"seed{seed}.pt")

    info = {"experiment": name, "title": exp["title"], "table": exp["table"], "inputs": inputs,
            "sizes": [len(inputs), *HIDDEN, 1], "relu": [1] * len(HIDDEN) + [0],
            "score": "logit" if exp["table"] == "recordings" else "mean of the recording's window logits",
            "scaler": {"mean": mean.tolist(), "std": std.tolist()}, "pos_weight": pos_weight,
            "n": {sp: int(part[sp].sum()) for sp in SPLITS}, "reported_seed": SEEDS[0],
            "seeds": {str(s): {k: r[k] for k in ("cut", "t", "best_epoch", "epochs_run", "best_val_loss")}
                      for s, r in runs.items()}}
    (wdir / "model.json").write_text(json.dumps(info, indent=1) + "\n")
    (rdir / "metrics.json").write_text(json.dumps({str(s): r for s, r in runs.items()}, indent=1) + "\n")
    with open(rdir / "scores.csv", "w", newline="") as f:
        w = csv.writer(f, lineterminator="\n")
        w.writerow(META + [f"{k}_s{s}" for s in SEEDS for k in ("score", "faulty")])
        for i, r in enumerate(recs):
            w.writerow([r[k] for k in META] + [v for s in SEEDS for v in (scores[s][i], int(scores[s][i] >= runs[s]["cut"]))])
    (rdir / "report.md").write_text(report(name, exp, info, runs, recs))

    print(f"{name}: {exp['title']}, {len(inputs)} inputs, {info['n']} rows, {time.time() - t_start:.1f} s")
    for s, r in runs.items():
        m = r["metrics"]["test"]
        print(f"  seed {s}: test faults found {m['confusion'][1][1]}/{sum(m['confusion'][1])}, false alarms "
              f"{m['confusion'][0][1]}/{sum(m['confusion'][0])}, ROC-AUC {m['roc_auc']:.3f}, F1 {m['f1']:.3f} "
              f"(t {r['t']:.4f}, best epoch {r['best_epoch']} of {r['epochs_run']}); missed by speed {m['missed_by_speed']}")
    print(f"  wrote {wdir} and {rdir}")


if __name__ == "__main__":
    main()
