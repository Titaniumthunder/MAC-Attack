"""First experimental training run of the deterioration head, leave-one-bearing-out (prepared 2 Nov 2026; NOT run).

  python train_deterioration.py         refuses until supervised_prep.ready() is empty (data checked, labels unedited)
                                        -> results/supervised/run1/ (refuses to overwrite an existing run)

Design, fixed before any training (nothing below is chosen on a held-out bearing):
  data       supervised_prep.dataset(): 8 A42 inputs per operating measurement, x8 = 0 where the thermal calibration
             is invalid; labelled rows only (y_det 0 or 1); development bearings only (test bearings refused).
  folds      results/supervised/folds.json: each processed development bearing held out once, trained on the others.
  network    mtl_model.MultiTaskMLP, unchanged (8 -> 32 -> 16 -> 2). The health-index head is frozen (no gradient,
             not in the optimizer) and checked bit-identical after training; y_hi is NaN everywhere, so its loss term
             is zero. The "trained" flag stays False: predict() keeps refusing, because the health output is untrained.
  training   mtl_model.multitask_loss (masked BCE); Adam, lr 1e-3, no weight decay; STEPS = 2000 steps of BATCH = 64
             rows drawn half from each class (the classes are 354 : 15, so balance comes from sampling, not weights);
             x8 dropout: the temperature input is set to 0 for X8_DROPOUT = 50 % of training rows (as an uncalibrated
             unit sees it); seeds 0, 1, 2.
  decision   probability > THRESHOLD = 0.5, confirmed RUN = 3 in a row (the anomaly baseline's persistence); not tuned.
  scoring    supervised_prep.detector_metrics() on every operating measurement of the held-out bearing, next to the
             anomaly baseline (A|F128|speed and A|F42|speed) and the rig's stop rule (rear RMS > 6.5 g). B03, the only
             bearing whose end label was not placed by a vibration rule, is reported on its own.

What this run can show: whether the pipeline trains, whether the head separates documented-healthy from documented-damaged
rows on a bearing it has not seen, and how it compares with the detectors it must beat. What it cannot show: a detection
rate or delay (the onset is unknown; 15 positive rows from 3 bearings), or anything about the locked test set.
"""
import hashlib, json, os, time

import numpy as np
import pandas as pd
import torch

import anomaly_baseline as ab
import mtl_inputs as mi
import mtl_model as mm
import supervised_prep as sp
from paderborn import load

OUT = sp.OUT / "run1"
SEEDS = (0, 1, 2)
STEPS, BATCH, LR = 2000, 64, 1e-3
X8_DROPOUT = 0.5
THRESHOLD = 0.5
NAMES = mi.input_names(sp.PROFILE)
EVERY = 25                                # progress.json: one point per EVERY steps (display only; training unchanged)


def train_fold(X, y, seed, on_progress=None):
    """X: (n, 8) inputs, y: (n,) in {0, 1}. Returns the network (health head untouched) and the loss curve.
    on_progress(step, net, mean_loss) is called every EVERY steps for the live view; it must not change the network."""
    rng = np.random.default_rng(seed)
    net = mm.MultiTaskMLP(seed=seed)
    hi_before = [p.detach().clone() for p in net.hi_head.parameters()]
    for p in net.hi_head.parameters():
        p.requires_grad_(False)
    opt = torch.optim.Adam([p for p in net.parameters() if p.requires_grad], lr=LR)
    pos, neg = np.flatnonzero(y == 1), np.flatnonzero(y == 0)
    if not len(pos) or not len(neg):
        raise ValueError("a fold needs both classes in its training bearings")
    curve = []
    for step in range(1, STEPS + 1):
        idx = np.r_[rng.choice(pos, BATCH // 2), rng.choice(neg, BATCH // 2)]
        xb = X[idx].copy()
        xb[rng.random(len(idx)) < X8_DROPOUT, 7] = 0.0
        d_logit, h_raw = net(torch.tensor(xb, dtype=torch.float32))
        loss, parts = mm.multitask_loss(d_logit, h_raw, torch.tensor(y[idx], dtype=torch.float32),
                                        torch.full((len(idx),), float("nan")))
        opt.zero_grad()
        loss.backward()
        opt.step()
        curve.append(parts["det"])
        if on_progress is not None and step % EVERY == 0:
            on_progress(step, net, float(np.mean(curve[-EVERY:])))
    if not all(torch.equal(a, b) for a, b in zip(hi_before, net.hi_head.parameters())):
        raise RuntimeError("the health-index head changed during training")
    return net, curve


def probability(net, X):
    with torch.no_grad():
        return torch.sigmoid(net(torch.tensor(X, dtype=torch.float32))[0]).numpy()


class Progress:
    """Live training state in OUT/progress.json, read by training_dashboard.html (display only)."""

    def __init__(self, path, folds):
        self.path, self.t0 = path, time.time()
        self.doc = {"status": "training", "steps": STEPS, "every": EVERY, "threshold": THRESHOLD,
                    "folds": [f["held_out"] for f in folds], "seeds": list(SEEDS), "current": None,
                    "runs": {}, "heldout": {}, "elapsed_s": 0.0}
        self.write()

    def write(self):
        self.doc["elapsed_s"] = round(time.time() - self.t0, 2)
        tmp = self.path.with_suffix(".tmp")
        tmp.write_text(json.dumps(self.doc, default=float), encoding="utf-8")
        os.replace(tmp, self.path)

    def hook(self, e, s, Xho, yh):
        key = f"{e}/seed{s}"
        run = self.doc["runs"][key] = {"fold": e, "seed": s, "step": [], "loss": [], "p_healthy": [], "p_det": []}
        self.doc["current"] = key
        healthy, det = yh == 0, yh == 1

        def on_progress(step, net, loss):
            p = probability(net, Xho)
            run["step"].append(step)
            run["loss"].append(round(loss, 5))
            run["p_healthy"].append(round(float(p[healthy].mean()), 4))
            run["p_det"].append(round(float(p[det].mean()), 4))
            if step % (EVERY * 4) == 0 or step == STEPS:
                self.write()
        return on_progress

    def heldout(self, e, ids, yh, p_mean, metrics):
        self.doc["heldout"][e] = {"measurement_id": ids.tolist(), "y_det": [None if np.isnan(v) else int(v) for v in yh],
                                  "p_mean": np.round(p_mean, 4).tolist(), "metrics": metrics}
        self.write()


def figure(out, prog, data_folds):
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt
    folds = prog["folds"]
    fig, axs = plt.subplots(3, len(folds), figsize=(4.2 * len(folds), 9), squeeze=False)
    for j, e in enumerate(folds):
        for s in prog["seeds"]:
            r = prog["runs"][f"{e}/seed{s}"]
            axs[0, j].plot(r["step"], r["loss"], label=f"seed {s}")
            axs[1, j].plot(r["step"], r["p_healthy"], color="tab:blue", alpha=0.4 + 0.2 * s)
            axs[1, j].plot(r["step"], r["p_det"], color="tab:orange", alpha=0.4 + 0.2 * s)
        axs[0, j].set_title(f"held out {e}: training loss")
        axs[0, j].set_yscale("log")
        axs[0, j].legend(fontsize=8)
        axs[1, j].axhline(THRESHOLD, color="grey", linestyle="--", linewidth=0.8)
        axs[1, j].set_title(f"{e}: mean P(deteriorated)\nblue = healthy rows, orange = deteriorated rows", fontsize=9)
        axs[1, j].set_ylim(0, 1)
        axs[1, j].set_xlabel("step")
        h = prog["heldout"][e]
        ids, y, p = np.array(h["measurement_id"]), np.array([np.nan if v is None else v for v in h["y_det"]]), np.array(h["p_mean"])
        axs[2, j].plot(ids, p, ".", ms=2, color="lightgrey", label="unlabelled")
        axs[2, j].plot(ids[y == 0], p[y == 0], ".", ms=3, color="tab:blue", label="healthy (0)")
        axs[2, j].plot(ids[y == 1], p[y == 1], "o", ms=4, color="tab:orange", label="deteriorated (1)")
        axs[2, j].axhline(THRESHOLD, color="grey", linestyle="--", linewidth=0.8)
        axs[2, j].set_ylim(-0.02, 1.02)
        axs[2, j].set_title(f"{e}: P(deteriorated) over the run (seed mean)", fontsize=9)
        axs[2, j].set_xlabel("measurement id")
        axs[2, j].legend(fontsize=7, loc="upper left")
    fig.tight_layout()
    (out / "figures").mkdir(exist_ok=True)
    fig.savefig(out / "figures" / "training.png", dpi=140)
    plt.close(fig)


def main():
    sp.require_ready()                                   # B02/B04 checked, label table unedited, MLP unchanged
    if OUT.exists():
        raise SystemExit(f"{OUT} exists: a run is never overwritten (move it or name a new run)")
    folds = json.loads((sp.OUT / "folds.json").read_text(encoding="utf-8"))["folds"]
    data = {f["held_out"]: sp.dataset(f["held_out"])[0] for f in folds}
    OUT.mkdir(parents=True)
    prog = Progress(OUT / "progress.json", folds)
    res = {"design": {"seeds": SEEDS, "steps": STEPS, "batch": BATCH, "lr": LR, "x8_dropout": X8_DROPOUT,
                      "threshold": THRESHOLD, "run": ab.RUN, "profile": sp.PROFILE, "inputs": NAMES,
                      "label_table_sha256": json.loads((sp.OUT / "label_table.json").read_text())["sha256"],
                      "health_index_head": "frozen, untrained"}, "folds": {}}
    for f in folds:
        e, train = f["held_out"], f["train"]
        tr = pd.concat([data[b] for b in train], ignore_index=True)
        tr = tr[tr.y_det.notna()]
        X, y = tr[NAMES].to_numpy(np.float32), tr.y_det.to_numpy()
        ho = data[e]
        ts, ids, yh = ho.timestamp.reset_index(drop=True), ho.measurement_id.to_numpy(), ho.y_det.to_numpy()
        fold = {"train": train, "train_rows": {"healthy": int((y == 0).sum()), "deteriorated": int((y == 1).sum())},
                "seeds": {}}
        preds = pd.DataFrame({"measurement_id": ids, "timestamp": ts, "y_det": yh})
        Xho = ho[NAMES].to_numpy(np.float32)
        for s in SEEDS:
            net, curve = train_fold(X, y, s, prog.hook(e, s, Xho, yh))
            path = OUT / f"fold_{e}_seed{s}.pt"
            torch.save(net.state_dict(), path)
            p = probability(net, ho[NAMES].to_numpy(np.float32))
            preds[f"p_seed{s}"] = p
            fold["seeds"][s] = {"metrics": sp.detector_metrics(p, THRESHOLD, yh, ts, ids),
                                "final_train_loss": curve[-1],
                                "weights_sha256": hashlib.sha256(path.read_bytes()).hexdigest()}
        d = ab.prepare(load(e))
        fold["reference"] = {}
        for name, cfg in sp.DETECTORS.items():
            sc, tau, _ = sp.commissioned_alarm(d, cfg)
            fold["reference"][name] = sp.detector_metrics(sc, tau, yh, ts, ids, in_sample_start=True)
        fold["reference"][f"rig stop rule, rear RMS > {sp.RIG_LIMIT_G} g"] = sp.detector_metrics(
            d.accA_rms.to_numpy(), sp.RIG_LIMIT_G, yh, ts, ids)
        fold["end_label_placed_by"] = sp.META["experiments"][e]["description"]["threshold_criterion"]
        preds.to_csv(OUT / f"predictions_{e}.csv", index=False, float_format="%.6g")
        prog.heldout(e, ids, yh, preds[[f"p_seed{s}" for s in SEEDS]].mean(axis=1).to_numpy(),
                     {"seeds": {s: fold["seeds"][s]["metrics"] for s in SEEDS}, "reference": fold["reference"]})
        res["folds"][e] = fold
        m = [fold["seeds"][s]["metrics"] for s in SEEDS]
        print(f"{e} held out: start above {[x['start_above_fraction'] for x in m]}, "
              f"end alarmed {[x['end_alarmed_fraction'] for x in m]}")
    (OUT / "results.json").write_text(json.dumps(res, indent=1, default=str) + "\n", encoding="utf-8")
    figure(OUT, prog.doc, folds)
    prog.doc["status"], prog.doc["current"] = "done", None
    prog.write()
    print(f"done in {prog.doc['elapsed_s']} s -> {OUT}")


if __name__ == "__main__":
    main()
