"""First experimental training run of the deterioration head, leave-one-bearing-out (prepared 2 Nov 2026; NOT run).

  python train_deterioration.py         refuses until supervised_prep.ready() is empty (labels reviewed and signed)
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
import hashlib, json

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


def train_fold(X, y, seed):
    """X: (n, 8) inputs, y: (n,) in {0, 1}. Returns the network (health head untouched) and the loss curve."""
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
    for _ in range(STEPS):
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
    if not all(torch.equal(a, b) for a, b in zip(hi_before, net.hi_head.parameters())):
        raise RuntimeError("the health-index head changed during training")
    return net, curve


def probability(net, X):
    with torch.no_grad():
        return torch.sigmoid(net(torch.tensor(X, dtype=torch.float32))[0]).numpy()


def main():
    sp.require_ready()                                   # labels reviewed and signed, B02/B04 checked, MLP unchanged
    if OUT.exists():
        raise SystemExit(f"{OUT} exists: a run is never overwritten (move it or name a new run)")
    folds = json.loads((sp.OUT / "folds.json").read_text(encoding="utf-8"))["folds"]
    data = {f["held_out"]: sp.dataset(f["held_out"])[0] for f in folds}
    OUT.mkdir(parents=True)
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
        for s in SEEDS:
            net, curve = train_fold(X, y, s)
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
        res["folds"][e] = fold
        m = [fold["seeds"][s]["metrics"] for s in SEEDS]
        print(f"{e} held out: start above {[x['start_above_fraction'] for x in m]}, "
              f"end alarmed {[x['end_alarmed_fraction'] for x in m]}")
    (OUT / "results.json").write_text(json.dumps(res, indent=1, default=str) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
