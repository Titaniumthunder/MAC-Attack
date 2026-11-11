"""Validation results of every run, per held-out bearing, with run 3 beside them. Validation folds only.

  model/.venv/bin/python modelV2/evaluate.py

Writes runs/<run>/eval.json and timelines.png, and report/comparison.json.
"""
import json

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import torch
from sklearn.metrics import roc_auc_score

import config as c
import net as N
import pipeline as F
import precheck
import anomaly_baseline as ab                      # model/

RUN3 = c.MODEL / "results/supervised/run3/train/results.json"


def softmax(o):
    e = np.exp(o - o.max(axis=1, keepdims=True))
    return e / e.sum(axis=1, keepdims=True)


def paderborn_eval(r, out):
    """r: the rows of one bearing; out: its 4 network outputs per row."""
    level, shown = F.status(r["s"], r["tau"][0], out[:, :3].argmax(1), out[:, 3])
    failing, n = level == 3, len(level)
    first = int(np.argmax(failing)) if failing.any() else None
    onset = int(np.argmax(r["post"]))
    err = np.abs(100 / (1 + np.exp(-out[:, 3])) - 100 * r["health"])
    p_dev, pre = softmax(out[:, :3])[:, 1], np.arange(n) < onset
    near = np.abs(r["rpm"] - 1800) < 100            # Ottawa's speed: "developing" must not just mean "about 1800 rpm"
    mins = r["minutes"]
    return {"end_caught": bool(failing[r["y"] == 2].any()), "healthy_rows_alarmed": int(failing[r["y"] == 0].sum()),
            "healthy_rows": int((r["y"] == 0).sum()),
            "failing_row": first, "onset_row": onset, "detector_first_alarm_row": ab.first_persistent(r["s"], r["tau"][0], c.REF_N),
            "failing_min_before_onset": float(mins[onset] - mins[first]) if first is not None else None,
            "failing_min_before_end": float(mins[-1] - mins[first]) if first is not None else None,
            "health_mae_before_onset": float(err[pre].mean()), "health_mae_after_onset": float(err[~pre].mean()),
            "p_developing": {"healthy_rows": float(p_dev[r["y"] == 0].mean()),
                             "onset_to_failing": float(p_dev[onset:first].mean()) if first is None or first > onset else None,
                             "after_failing": float(p_dev[first:].mean()) if first is not None else None,
                             "before_onset_rpm_1700_1900": float(p_dev[pre & near].mean()) if (pre & near).any() else None,
                             "before_onset_other_rpm": float(p_dev[pre & ~near].mean())},
            "_series": {"level": level, "shown": shown, "p_dev": p_dev, "p_faulty": softmax(out[:, :3])[:, 2]}}


def ottawa_eval(rows, out):
    """Held-out Ottawa windows: stage confusion matrix, and the health head (never trained on Ottawa) by stage.
    Version A has no "developing" examples, so for it read the two coarser numbers, not the accuracy."""
    m = rows["ds"] == 1
    y, pred, h = rows["y"][m], out[m, :3].argmax(1), 100 / (1 + np.exp(-out[m, 3]))
    conf = [[int(((y == i) & (pred == j)).sum()) for j in range(3)] for i in range(3)]
    by = {b: [float(h[(rows["bearing"][m] == b) & (y == k)].mean()) for k in range(3)] for b in np.unique(rows["bearing"][m])}
    return {"accuracy": float((y == pred).mean()), "healthy_called_healthy": float((pred[y == 0] == 0).mean()), "damaged_called_faulty": float((pred[y > 0] == 2).mean()),
            "confusion_true_rows_pred_cols": conf,
            "health_pct_by_stage": [float(h[y == k].mean()) for k in range(3)],
            "bearings_health_falls_0_1_2": sum(v[0] > v[1] > v[2] for v in by.values()), "bearings": len(by)}


def hidden_probe(run, rows, folds, hist):
    """Can the dataset be told from a network's last hidden layer on healthy rows? One network at a time (each fold's,
    seed 0): the probes are fitted on the bearings it trained with and scored on its held-out bearings. Mean AUC over
    folds. (Pooling the folds' activations would let a probe key on which network made a row.)"""
    m = ((rows["ds"] == 0) & (rows["k"] >= c.REF_N) & (rows["k"] < c.REF_N + c.HOLD_N)) | ((rows["ds"] == 1) & (rows["y"] == 0))
    X = torch.tensor(F.network_inputs(rows["Z"][m], rows["s"][m], rows["rpm"][m], rows["M"][m], np.full(m.sum(), hist)))
    ds, aucs = rows["ds"][m], []
    for f in folds:
        net = N.mlp()
        net.load_state_dict(torch.load(run / "models" / f"{f['pad']}_seed0.pt", weights_only=True))
        with torch.no_grad():
            H = net[:-1](X).numpy()
        held = np.isin(rows["bearing"][m], [f["pad"], *f["ott"]])
        aucs.append({k: roc_auc_score(ds[held], p.fit(H[~held], ds[~held]).predict_proba(H[held])[:, 1])
                     for k, p in precheck.probes().items()})
    return {k: float(np.mean([a[k] for a in aucs])) for k in aucs[0]}


def timelines(run, rows, per_bearing):
    fig, axs = plt.subplots(len(per_bearing), 3, figsize=(13, 2.1 * len(per_bearing)), squeeze=False)
    for (b, res), row in zip(per_bearing.items(), axs):
        r, s = {k: v[rows["bearing"] == b] for k, v in rows.items()}, res["_series"]
        t = r["minutes"]
        row[0].plot(t, 100 * r["health"], color=ab.MUTED, label="target")
        row[0].plot(t, s["shown"], color=ab.BLUE, label="health % shown")
        row[1].plot(t, s["p_dev"], color=ab.ORANGE, label="P(developing)")
        row[1].plot(t, s["p_faulty"], color="#b3261e", label="P(faulty)")
        row[2].semilogy(t, r["s"] / r["tau"], ".", ms=2, color=ab.MUTED, label="detector score / threshold")
        ax2 = row[2].twinx()
        ax2.step(t, s["level"], color=ab.INK2, linewidth=1)
        ax2.set_yticks(range(4), ["Normal", "Anomaly", "Warning", "Failing"], fontsize=7)
        for ax in row:
            ax.axvline(t[res["onset_row"]], color=ab.AQUA, linestyle="--", linewidth=1)
            ax.legend(fontsize=7, loc="center left")
        row[0].set_ylabel(b)
    axs[-1, 1].set_xlabel("operating minutes (dashed: detector's sustained onset); seed 0, bearing held out")
    fig.tight_layout()
    fig.savefig(run / "timelines.png", dpi=120)
    plt.close(fig)


def run3(rows):
    """Run 3's selected model on the same held-out bearings (its own outer folds), from model/'s saved results."""
    d = json.loads(RUN3.read_text())
    out = {}
    for b in np.unique(rows["bearing"][rows["ds"] == 0]):
        seeds = [o["metrics"]["latched"] for o in d["outer"] if o["cfg"] == d["final_cfg"] and o["held_out"] == b]
        r = {k: v[rows["bearing"] == b] for k, v in rows.items()}
        onset, lead = int(np.argmax(r["post"])), []
        for m in seeds:
            hit = np.flatnonzero(r["mid"] == m["first_alarm_id"]) if m["first_alarm_id"] else []
            lead.append(float(r["minutes"][onset] - r["minutes"][hit[0]]) if len(hit) else None)
        out[b] = {"end_caught_seeds": sum(m["end_recall"] > 0 for m in seeds), "seeds": len(seeds),
                  "healthy_rows_alarmed": sum(m["healthy_rows_alarmed"] for m in seeds),
                  "healthy_rows": sum(m["healthy_rows"] for m in seeds), "alarm_min_before_onset": lead,
                  "health_mae": "not available: run 3's health head was never trained"}
    return out


def temperature():
    """The host temperature rule on each development bearing (it does not depend on the network)."""
    out = {}
    for b, i in json.loads((c.DATA / "summary.json").read_text())["paderborn"].items():
        t = pd.read_csv(c.DATA / f"paderborn_{b}.csv", parse_dates=["timestamp"])
        d = t[~t.warmup].iloc[i["reference_start"]:].reset_index(drop=True)
        hot = F.temperature_warning(d.timestamp, d.T1_C)
        out[b] = {"rows_on_before_onset": int(hot[:i["onset_row"]].sum()), "rows_before_onset": i["onset_row"],
                  "first_on_min_before_end": float(d.operating_min.iloc[-1] - d.operating_min[hot].iloc[0]) if hot.any() else None}
    return out


def main():
    rows = dict(np.load(c.DATA / "rows.npz"))
    folds = json.loads((c.DATA / "folds.json").read_text())
    comparison = {"run3": run3(rows), "temperature": temperature()}
    for run in sorted(d for d in c.RUNS.iterdir() if (d / "val_outputs.npz").exists()):
        cfg = json.loads((run / "config.json").read_text())
        if c.stale(cfg, run.name):
            continue
        v = np.load(run / "val_outputs.npz")
        res = {"paderborn": {}, "ottawa": []}
        for i, seed in enumerate(v["seeds"]):
            for b in [f["pad"] for f in folds]:
                m = rows["bearing"] == b
                e = paderborn_eval({k: a[m] for k, a in rows.items()}, v["out"][i][m])
                res["paderborn"].setdefault(b, []).append(e)
            res["ottawa"].append(ottawa_eval(rows, v["out"][i]))
        timelines(run, rows, {b: e[0] for b, e in res["paderborn"].items()})
        for e in sum(res["paderborn"].values(), []):
            del e["_series"]
        res["hidden_layer_dataset_probe_auc"] = hidden_probe(run, rows, folds, max(cfg["history"], 1))
        (run / "eval.json").write_text(json.dumps(res, indent=1) + "\n")
        comparison[run.name] = res
        P = sum(res["paderborn"].values(), [])
        late = sum(e["failing_min_before_onset"] is None or e["failing_min_before_onset"] < 0 for e in P)
        print(f"{run.name}: end stages caught {sum(e['end_caught'] for e in P)}/{len(P)} (bearing x seed), healthy rows alarmed "
              f"{sum(e['healthy_rows_alarmed'] for e in P)}/{sum(e['healthy_rows'] for e in P)}, later than onset or never {late}/{len(P)}, health MAE before/after "
              f"onset {np.mean([e['health_mae_before_onset'] for e in P]):.1f}/{np.mean([e['health_mae_after_onset'] for e in P]):.1f} %, "
              f"Ottawa stage accuracy {np.mean([o['accuracy'] for o in res['ottawa']]):.2f}, healthy called healthy {np.mean([o['healthy_called_healthy'] for o in res['ottawa']]):.2f}, damaged called faulty "
              f"{np.mean([o['damaged_called_faulty'] for o in res['ottawa']]):.2f}, Ottawa health % by stage "
              f"{np.round(np.mean([o['health_pct_by_stage'] for o in res['ottawa']], axis=0), 0)}, hidden probe AUC "
              f"{max(res['hidden_layer_dataset_probe_auc'].values()):.2f}, P(developing) on healthy rows "
              f"{np.mean([e['p_developing']['healthy_rows'] for e in P]):.3f}, onset to Failing "
              f"{np.mean([e['p_developing']['onset_to_failing'] for e in P if e['p_developing']['onset_to_failing'] is not None] or [np.nan]):.3f}")
    c.writable(c.REPORT / "comparison.json").write_text(json.dumps(comparison, indent=1) + "\n")
    print("temperature rule:", {b: (t["rows_on_before_onset"], None if t["first_on_min_before_end"] is None else
                                    round(t["first_on_min_before_end"])) for b, t in comparison["temperature"].items()},
          "(rows on before onset, first on: minutes before the end)")
    r3 = comparison["run3"]
    print(f"run 3: end stages caught {sum(r['end_caught_seeds'] for r in r3.values())}/{sum(r['seeds'] for r in r3.values())}, "
          f"healthy rows alarmed {sum(r['healthy_rows_alarmed'] for r in r3.values())}/{sum(r['healthy_rows'] for r in r3.values())}")


if __name__ == "__main__":
    main()
