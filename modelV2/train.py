"""Train one version of the model: A on Paderborn only, B on Paderborn + Ottawa. Every call makes a new folder
modelV2/runs/<date-time>_<name>/ and never touches an older one. Open that folder's live.html in a browser while it
runs; runs/compare.html overlays all runs afterwards.

  model/.venv/bin/python modelV2/train.py --data paderborn --name A --quick     a dry run of a few seconds
  model/.venv/bin/python modelV2/train.py --data paderborn --name A
  model/.venv/bin/python modelV2/train.py --data paderborn+ottawa --name B
  model/.venv/bin/python modelV2/train.py --data paderborn+ottawa --name B_nohist --history 0

One model per (held-out bearing, seed), all trained in step so the curves are fold averages, plus one model per seed on
every development bearing (the one that is exported). Paderborn trains both heads (healthy / faulty, and health).
In version B, Ottawa's stage labels also train the status head (healthy / developing / faulty); never the health head.
Held-out Ottawa bearings are scored in both versions.
"""
import argparse, hashlib, json, subprocess, time
from datetime import datetime

import numpy as np
import pandas as pd
import torch

import config as c
import net as N
import page
import pipeline as F


def compare():
    """runs/compare.html: every finished run's mean curves and final validation metrics. No locked data."""
    runs, rows = {}, []
    for d in sorted(p for p in c.RUNS.iterdir() if (p / "results.json").exists()):
        cfg = json.loads((d / "config.json").read_text())
        name = d.name + (" (quick dry run)" if cfg["quick"] else "") \
            + (" (older data: not comparable)" if cfg.get("rows_sha256") != c.rows_sha256() else "")
        runs[name] = pd.read_csv(d / "history.csv")
        rows.append({"run": name, **json.loads((d / "results.json").read_text())["validation"]})
    table = "<h3>Final validation metrics (mean over folds and seeds)</h3>" + pd.DataFrame(rows).to_html(
        index=False, float_format="%.4f", border=0)
    page.write_atomic(c.RUNS / "compare.html", page.html("modelV2 runs: validation folds only", page.curves(runs), extra=table))


class Job:
    """One network: trained on every bearing except the fold's held-out ones (fold None: on all of them)."""

    def __init__(self, fold, seed, rows, hist, ottawa, y_train):
        self.fold, self.seed, self.hist = fold, seed, hist
        self.val = np.isin(rows["bearing"], [fold["pad"], *fold["ott"]] if fold else [])
        train = ~self.val & ((rows["ds"] == 0) | ottawa)
        self.ottawa = ottawa
        pools = [np.flatnonzero(train & (rows["ds"] == d) & (y_train == y)) for d in (0, 1) for y in (0, 1, 2)]
        self.status_pools = [p for p in pools if len(p)]
        self.health_pools = [np.flatnonzero(train & (rows["ds"] == 0) & (rows["post"] == p)) for p in (False, True)]
        self.rng = np.random.default_rng(seed)
        self.net = N.mlp(seed=seed)
        self.opt = torch.optim.Adam(self.net.parameters(), lr=c.LR, weight_decay=c.WD)
        self.sum = np.zeros(2)

    def batch(self):
        """First half: status rows, balanced over dataset and class. Second half: Paderborn health rows, balanced
        before / after onset. A random history length per row, so the network cannot rely on a full history."""
        half = c.BATCH // 2
        pools = [self.status_pools[i] for i in self.rng.integers(len(self.status_pools), size=half)] \
            + [self.health_pools[i] for i in self.rng.integers(2, size=half)]
        return np.array([p[self.rng.integers(len(p))] for p in pools]), self.rng.integers(1, self.hist + 1, size=c.BATCH)


def balanced(values, groups):
    """Mean of the per-group means: a validation loss weighted like a training batch (every group equally likely)."""
    return float(torch.stack([values[groups == g].mean() for g in groups.unique()]).mean())


def validate(job, X, y, health, ds, post):
    """Losses and metrics on the fold's held-out bearings. Ottawa's loss only if the network trains on Ottawa."""
    with torch.no_grad():
        out = job.net(X[job.val])
    yv, hv, d = y[job.val], health[job.val], ds[job.val]
    pad, ott, mh = (d == 0) & (yv >= 0), d == 1, ~torch.isnan(hv)
    ce = torch.nn.functional.cross_entropy(out[:, :3], yv.clamp(min=0), reduction="none")
    err = (torch.sigmoid(out[:, 3]) - hv)[mh]
    acc = lambda m: float((out[m, :3].argmax(1) == yv[m]).float().mean())
    return {"val_status_pad": balanced(ce[pad], yv[pad]), "val_status_ott": balanced(ce[ott], yv[ott]) if job.ottawa else np.nan,
            "val_acc_pad": acc(pad), "val_acc_ott": acc(ott), "val_health": balanced(err ** 2, post[job.val][mh]),
            "val_mae": float(100 * err.abs().mean())}, out.numpy()


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--data", required=True, choices=("paderborn", "paderborn+ottawa"))
    ap.add_argument("--name", required=True)
    ap.add_argument("--history", type=int, default=c.HIST, choices=range(c.HIST + 1), help="rows of history (0: none)")
    ap.add_argument("--quick", action="store_true", help="dry run: one seed, few steps")
    a = ap.parse_args()
    missing = json.loads((c.DATA / "summary.json").read_text())["missing"]
    if missing and not a.quick:
        raise SystemExit(f"raw data of {missing} is missing: add it, run prep.py, then train (or use --quick)")
    rows = dict(np.load(c.DATA / "rows.npz"))
    folds = json.loads((c.DATA / "folds.json").read_text())
    steps, seeds, every = (c.QUICK_STEPS, (0,), 25) if a.quick else (c.STEPS, c.SEEDS, 100)
    hist = max(a.history, 1)
    out = c.RUNS / f"{datetime.now():%Y%m%d-%H%M%S}_{a.name}"
    out.mkdir(parents=True)                         # fails if it exists: a run is never overwritten
    (out / "models").mkdir()
    commit = subprocess.run(["git", "rev-parse", "HEAD"], capture_output=True, text=True, cwd=c.REPO).stdout.strip()
    code = hashlib.sha256()                         # the commit alone misses uncommitted code
    for p in sorted(c.HERE.glob("*.py")):
        code.update(p.name.encode() + p.read_bytes())
    cfg = {"name": a.name, "data": a.data, "history": a.history, "quick": a.quick,
           "steps": steps, "seeds": list(seeds), "batch": c.BATCH, "lr": c.LR, "lr_schedule": "cosine to 0",
           "weight_decay": c.WD, "optimizer": "Adam", "sizes": [len(c.INPUTS), *c.HIDDEN, 4], "inputs": c.INPUTS,
           "s_x": c.S_X, "folds": folds,
           "faulty_training_label": "rows after the detector's sustained onset" if c.FAULTY_FROM_ONSET else f"last {c.END_N} rows",
           "health_target": f"severity: 100 % at score <= {c.HEALTH_FULL_AT}, 0 % at {c.HEALTH_ZERO_AT}", "git_commit": commit, "code_sha256": code.hexdigest(), "rows_sha256": c.rows_sha256(),
           "loss": "cross-entropy (status rows) + MSE on sigmoid (health rows), each masked to its labelled rows"}
    (out / "config.json").write_text(json.dumps(cfg, indent=1) + "\n")

    torch.set_num_threads(1)
    n = len(rows["y"])
    Xh = [torch.tensor(F.network_inputs(rows["Z"], rows["s"], rows["rpm"], rows["M"], np.full(n, h)))
          for h in range(1, hist + 1)]              # the inputs for every history length
    y, health, ds = torch.tensor(rows["y"]), torch.tensor(rows["health"], dtype=torch.float32), torch.tensor(rows["ds"])
    post = torch.tensor(rows["post"])               # after the detector's sustained onset
    y_train = np.where(rows["post"] & c.FAULTY_FROM_ONSET, 2, rows["y"])     # training labels of the status head
    yt = torch.tensor(y_train)
    ottawa = a.data.endswith("ottawa")
    jobs = [Job(f, s, rows, hist, ottawa, y_train) for f in [*folds, None] for s in seeds]
    history, val_out, t0 = [], np.full((len(seeds), n, 4), np.nan, np.float32), time.time()
    for step in range(steps + 1):                   # step 0: the untrained networks, so every curve has a start
        lr = 0.5 * c.LR * (1 + np.cos(np.pi * max(step - 1, 0) / max(steps, 1)))
        for j in jobs if step else []:
            idx, h = j.batch()
            x = torch.stack([Xh[k - 1][i] for i, k in zip(idx, h)])
            yb, hb = yt[idx], health[idx]           # copies
            yb[c.BATCH // 2:], hb[:c.BATCH // 2] = -1, float("nan")     # each half of the batch trains only its own head
            ls, lh = N.losses(j.net(x), yb, hb)
            for g in j.opt.param_groups:
                g["lr"] = lr
            j.opt.zero_grad()
            (ls + lh).backward()
            j.opt.step()
            j.sum += [ls.item(), lh.item()]
        if step % every == 0 or step == steps:
            for j in jobs:
                done = step % every or every
                rec = {"step": step, "lr": lr, "fold": j.fold["pad"] if j.fold else "final", "seed": j.seed,
                       "train_status": j.sum[0] / done if step else np.nan, "train_health": j.sum[1] / done if step else np.nan}
                j.sum[:] = 0
                if j.fold:
                    res, o = validate(j, Xh[-1], y, health, ds, post)
                    rec.update(res)
                    val_out[seeds.index(j.seed), j.val] = o
                history.append(rec)
            h = pd.DataFrame(history)
            h.to_csv(out / "history.csv", index=False)
            page.write_atomic(out / "live.html", page.html(f"{out.name}: step {step} of {steps}, learning rate {lr:.2e}, "
                                                           f"{time.time() - t0:.0f} s", page.curves({a.name: h}), refresh=step < steps))
            now = h[(h.step == step) & (h.fold != "final")]
            print(f"step {step}/{steps}  status loss train {now.train_status.mean():.4f} val {now.val_status_pad.mean():.4f}  "
                  f"health loss train {now.train_health.mean():.4f} val {now.val_health.mean():.4f}  "
                  f"health error {now.val_mae.mean():.1f} %", flush=True)
    for j in jobs:
        torch.save(j.net.state_dict(), out / "models" / f"{j.fold['pad'] if j.fold else 'final'}_seed{j.seed}.pt")
    np.savez(out / "val_outputs.npz", out=val_out, seeds=np.array(seeds))
    (out / "results.json").write_text(json.dumps({"validation": now[[k for k in now if k.startswith("val_")]].mean().to_dict(),
                                                  "elapsed_s": time.time() - t0}, indent=1) + "\n")
    compare()
    print(f"done: {out}\ncompare: {c.RUNS / 'compare.html'}")


if __name__ == "__main__":
    main()
