"""Training run 2 of the deterioration head: a latched alarm, the comparison with run 1 and the anomaly detector, the
probability-calibration investigation, and an INT8 / RTL check of the trained networks (3 Nov 2026).

  python train_deterioration_run2.py          -> results/supervised/run2/   (refuses to overwrite an existing run;
                                                 run 1 is only read, and checked unchanged at the end)

What changes from run 1, and what does not:
  network     unchanged: mtl_model.MultiTaskMLP, 8 -> 32 -> 16 -> 2 (850 parameters). The health-index head stays frozen
              and untrained (no severity labels); predict() keeps refusing.
  training    unchanged: train_deterioration.train_fold with run 1's settings and seeds. The networks are retrained into
              run2/ and their SHA-256 compared with run 1's, so run 2's raw probabilities are run 1's (checked, not assumed).
  data        the same development bearings B02, B03, B04 (leave one bearing out). The locked test bearings B06, B07, B13
              and B17 are never loaded (splits.assert_development).
  alarm       NEW: latched. The alarm turns on at the first measurement that completes RUN = 3 consecutive
              probabilities above THRESHOLD = 0.5 and then stays on (no reset; a real unit would need a maintenance
              reset). Run 1's rule (on while the last 3 are above, off otherwise) is scored next to it. The raw
              probability output is not changed.
  compared    run 1's alarm, run 2's latched alarm, the anomaly detector (anomaly_baseline, per-bearing commissioned:
              A|F128|speed, the prototype, and A|F42|speed), scored both as run 1 scored it and latched (its own
              "persistent" rule), and the rig's stop rule (rear RMS > 6.5 g).
  calibration DIAGNOSTIC ONLY (nothing is selected on the held-out bearings): logits, input distances, single-feature
              separability, weight growth, reliability on the labelled rows, the balanced-sampling prior shift, and
              the same training with early stopping, weight decay or label smoothing.
  x8 check    every trained network also scored with the temperature input set to 0 on every held-out row: x8 is 0 by
              construction until the bearing's thermal calibration ends, i.e. on every healthy label, and non-zero on
              every damaged label, so it separates the labels for a reason that is not physical.
  int8        each trained network quantized with mtl_model.int8_model (export.py's scheme) and run through the
              bit-exact golden model; one network (B03 held out, seed 0) also on the RTL (tb_mlp.sv, Icarus).

None of this measures the probability of a physical failure: the labels are 15 end-of-test rows and 300 commissioning
rows, and the onset of damage is unknown.
"""
import hashlib, json, shutil, tempfile, time
from pathlib import Path

import numpy as np
import pandas as pd
import torch

import anomaly_baseline as ab
import mtl_model as mm
import splits
import supervised_prep as sp
import train_deterioration as td
from paderborn import load

RUN1, OUT = sp.OUT / "run1", sp.OUT / "run2"
LOCKED = ("B06", "B07", "B13", "B17")
NAMES, SEEDS, THR = td.NAMES, td.SEEDS, td.THRESHOLD
CHECKPOINTS = (25, 50, 100, 250, 500, 1000, 2000)
VARIANTS = {"run 1 settings (2,000 steps)": {},
            "weight decay 1e-3": {"weight_decay": 1e-3},
            "weight decay 1e-2": {"weight_decay": 1e-2},
            "weight decay 1e-1": {"weight_decay": 1e-1},
            "label smoothing 0.05": {"smooth": 0.05}}


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()



def tree_digest(folder):
    return {p.name: sha(p) for p in sorted(Path(folder).rglob("*")) if p.is_file()}


# ---------------------------------------------------------------- alarms and metrics

def unlatched(above):
    return sp.confirmed(np.asarray(above, bool))


def latched(above):
    return np.logical_or.accumulate(sp.confirmed(np.asarray(above, bool)))


def counts(pred, y):
    """Row-level confusion on the labelled rows (y 0/1; NaN rows ignored)."""
    lab = ~np.isnan(y)
    p, t = np.asarray(pred, bool)[lab], y[lab] == 1
    tp, fp, tn, fn = int((p & t).sum()), int((p & ~t).sum()), int((~p & ~t).sum()), int((~p & t).sum())
    prec = tp / (tp + fp) if tp + fp else None
    rec = tp / (tp + fn) if tp + fn else None
    f1 = 2 * prec * rec / (prec + rec) if prec and rec else (0.0 if prec == 0 or rec == 0 else None)
    return {"tp": tp, "fp": fp, "tn": tn, "fn": fn, "accuracy": (tp + tn) / max(1, lab.sum()),
            "precision": prec, "recall": rec, "f1": f1}


def alarm_metrics(state, above, y, ts, ids):
    state, above = np.asarray(state, bool), np.asarray(above, bool)
    start, end, mid = y == 0, y == 1, np.isnan(y)
    first = int(np.flatnonzero(state)[0]) if state.any() else None
    s0 = state[start]
    return {"first_alarm_id": int(ids[first]) if first is not None else None,
            "first_alarm_time": str(ts.iloc[first]) if first is not None else None,
            "first_alarm_min_before_last_record": round((ts.iloc[-1] - ts.iloc[first]).total_seconds() / 60, 2)
            if first is not None else None,
            "alarm_state_changes": int(state[0]) + int(np.abs(np.diff(state.astype(int))).sum()),
            "healthy_rows": int(start.sum()),
            "healthy_rows_above_threshold": int(above[start].sum()),
            "healthy_rows_alarmed": int(s0.sum()),
            "healthy_alarm_episodes": int((s0 & ~np.r_[False, s0[:-1]]).sum()),
            "end_rows": int(end.sum()),
            "end_recall": float(state[end].mean()),
            "middle_alarmed_fraction": float(state[mid].mean()),
            "labelled_rows_alarm": counts(state, y),
            "labelled_rows_raw_threshold": counts(above, y)}


# ---------------------------------------------------------------- training (identical to run 1) with diagnostics

def variant_fold(X, y, seed, weight_decay=0.0, smooth=0.0, steps=td.STEPS):
    """train_deterioration.train_fold's loop with optional L2 weight decay (Adam) or label smoothing. With the defaults it
    must give run 1's network bit for bit (checked in main)."""
    rng = np.random.default_rng(seed)
    net = mm.MultiTaskMLP(seed=seed)
    hi0 = [p.detach().clone() for p in net.hi_head.parameters()]
    for p in net.hi_head.parameters():
        p.requires_grad_(False)
    opt = torch.optim.Adam([p for p in net.parameters() if p.requires_grad], lr=td.LR, weight_decay=weight_decay)
    pos, neg = np.flatnonzero(y == 1), np.flatnonzero(y == 0)
    for _ in range(steps):
        idx = np.r_[rng.choice(pos, td.BATCH // 2), rng.choice(neg, td.BATCH // 2)]
        xb = X[idx].copy()
        xb[rng.random(len(idx)) < td.X8_DROPOUT, 7] = 0.0
        d_logit, h_raw = net(torch.tensor(xb, dtype=torch.float32))
        yb = torch.tensor(y[idx], dtype=torch.float32)
        if smooth:
            yb = yb * (1 - 2 * smooth) + smooth
        loss, _ = mm.multitask_loss(d_logit, h_raw, yb, torch.full((len(idx),), float("nan")))
        opt.zero_grad()
        loss.backward()
        opt.step()
    assert all(torch.equal(a, b) for a, b in zip(hi0, net.hi_head.parameters())), "health head changed"
    return net


def logits(net, X):
    with torch.no_grad():
        return net(torch.tensor(X, dtype=torch.float32))[0].double().numpy()


def weight_norm(net):
    return float(torch.sqrt(sum((p.detach() ** 2).sum() for n, p in net.named_parameters() if not n.startswith("hi_head"))))


def prob_summary(p, y):
    lab = ~np.isnan(y)
    pl, yl = np.clip(p[lab], 1e-12, 1 - 1e-12), y[lab]
    mid = p[np.isnan(y)]
    return {"max_p_healthy": float(p[y == 0].max()), "min_p_damaged": float(p[y == 1].min()),
            "labelled_separated": bool(p[y == 1].min() > p[y == 0].max()),
            "brier_labelled": float(((pl - yl) ** 2).mean()),
            "logloss_labelled": float(-(yl * np.log(pl) + (1 - yl) * np.log(1 - pl)).mean()),
            "middle_fraction_between_0.05_0.95": float(((mid > 0.05) & (mid < 0.95)).mean()),
            "middle_fraction_above_0.5": float((mid > 0.5).mean())}


def ece(p, y, bins=10):
    lab = ~np.isnan(y)
    p, y = p[lab], y[lab]
    edges = np.linspace(0, 1, bins + 1)
    k = np.clip(np.digitize(p, edges[1:-1]), 0, bins - 1)
    rows, e = [], 0.0
    for b in range(bins):
        m = k == b
        if m.any():
            rows.append({"bin": [float(edges[b]), float(edges[b + 1])], "n": int(m.sum()), "mean_p": float(p[m].mean()),
                         "frac_damaged": float(y[m].mean())})
            e += m.mean() * abs(p[m].mean() - y[m].mean())
    return float(e), rows


# ---------------------------------------------------------------- INT8 and RTL

def int8_check(net, X_calib, X_eval, y):
    seq, layers, scales, s_x = mm.int8_model(net.eval(), X_calib)
    with torch.no_grad():
        fp = seq(torch.tensor(X_eval, dtype=torch.float32)).double().numpy()[:, 0]
    Xq, C, real = mm.int8_forward(X_eval, layers, scales, s_x)
    d = real[:, 0]
    p_fp, p_q = 1 / (1 + np.exp(-fp)), 1 / (1 + np.exp(-d))
    return {"rows": len(X_eval), "logit_mean_abs_err": float(np.abs(d - fp).mean()),
            "logit_max_abs_err": float(np.abs(d - fp).max()),
            "prob_max_abs_err": float(np.abs(p_q - p_fp).max()),
            "decisions_changed": int(((p_q > THR) != (p_fp > THR)).sum()),
            "decisions_changed_on_labelled_rows": int((((p_q > THR) != (p_fp > THR)) & ~np.isnan(y)).sum()),
            "inputs_clipped_at_127": int((np.abs(Xq) == 127).any(axis=1).sum())}, (layers, scales, Xq), p_q


def rtl_check_one(layers, scales, Xq):
    import rtl_check
    root = Path(tempfile.mkdtemp(prefix="mg_run2_rtl_"))
    try:
        sim = rtl_check.TempSimulator(root, "icarus")
        work = sim.build("tb_mlp", rtl_check.PARAMS)
        n = len(Xq) // 64 * 64
        good, eq, cyc, _ = rtl_check.run(sim, work, layers, [Xq[i:i + 64] for i in range(0, n, 64)],
                                         int(scales[-1]["bias_last"][0]))
        good1, eq1, cyc1, _ = rtl_check.run(sim, work, layers, [Xq[[i]] for i in range(10)],
                                            int(scales[-1]["bias_last"][0]))
        return {"simulator": "Icarus Verilog", "M64": {"pass": bool(good), "batches": n // 64, "cycles": cyc},
                "M1": {"pass": bool(good1), "batches": 10, "cycles": cyc1}}
    finally:
        shutil.rmtree(root, ignore_errors=True)


# ---------------------------------------------------------------- main

def main():
    sp.require_ready()
    if OUT.exists():
        raise SystemExit(f"{OUT} exists: a run is never overwritten (move it or name a new run)")
    run1_before = tree_digest(RUN1)
    run1 = json.loads((RUN1 / "results.json").read_text(encoding="utf-8"))
    folds = json.loads((sp.OUT / "folds.json").read_text(encoding="utf-8"))["folds"]
    bearings = [f["held_out"] for f in folds]
    splits.assert_development(bearings)
    assert not set(bearings) & set(LOCKED)
    OUT.mkdir(parents=True)
    t0 = time.time()
    data = {e: sp.dataset(e)[0] for e in bearings}
    res = {"design": {"what": "run 1's networks retrained; latched alarm; calibration diagnostics; INT8/RTL check",
                      "seeds": SEEDS, "steps": td.STEPS, "batch": td.BATCH, "lr": td.LR, "x8_dropout": td.X8_DROPOUT,
                      "threshold": THR, "run": ab.RUN, "inputs": NAMES, "architecture": [8, 32, 16, 2],
                      "params": mm.n_params(mm.MultiTaskMLP()), "health_index_head": "frozen, untrained",
                      "locked_test_bearings_not_loaded": LOCKED,
                      "label_table_sha256": run1["design"]["label_table_sha256"]},
           "folds": {}, "calibration": {}, "int8": {}}
    diag_rows, ckpt_rows, variant_rows, all_preds = [], [], [], []
    for f in folds:
        e, train = f["held_out"], f["train"]
        tr = pd.concat([data[b] for b in train], ignore_index=True)
        tr = tr[tr.y_det.notna()]
        X, y = tr[NAMES].to_numpy(np.float32), tr.y_det.to_numpy()
        ho = data[e]
        Xho, yh = ho[NAMES].to_numpy(np.float32), ho.y_det.to_numpy()
        ts, ids = ho.timestamp.reset_index(drop=True), ho.measurement_id.to_numpy()
        preds = pd.DataFrame({"measurement_id": ids, "timestamp": ts, "y_det": yh})
        fold = {"train": train, "train_rows": {"healthy": int((y == 0).sum()), "deteriorated": int((y == 1).sum())},
                "seeds": {}, "reference": {}}
        for s in SEEDS:
            curve = []

            def hook(step, net, loss):
                if step in CHECKPOINTS:
                    lg = logits(net, Xho)
                    p = 1 / (1 + np.exp(-lg))
                    ckpt_rows.append({"held_out": e, "seed": s, "step": step, "train_loss": loss,
                                      "weight_norm": weight_norm(net),
                                      "mean_abs_logit_healthy": float(np.abs(lg[yh == 0]).mean()),
                                      "mean_abs_logit_damaged": float(np.abs(lg[yh == 1]).mean()),
                                      "mean_abs_logit_middle": float(np.abs(lg[np.isnan(yh)]).mean()),
                                      **prob_summary(p, yh),
                                      "unlatched_state_changes": alarm_metrics(unlatched(p > THR), p > THR, yh, ts, ids)["alarm_state_changes"],
                                      "latched_first_alarm_id": alarm_metrics(latched(p > THR), p > THR, yh, ts, ids)["first_alarm_id"]})
            net, curve = td.train_fold(X, y, s, hook)
            path = OUT / f"fold_{e}_seed{s}.pt"
            torch.save(net.state_dict(), path)
            same = sha(path) == run1["folds"][e]["seeds"][str(s)]["weights_sha256"]
            again = variant_fold(X, y, s)
            assert all(torch.equal(a, b) for a, b in zip(net.state_dict().values(), again.state_dict().values())), \
                "variant_fold does not reproduce train_fold"
            lg = logits(net, Xho)
            p = 1 / (1 + np.exp(-lg))
            r1 = pd.read_csv(RUN1 / f"predictions_{e}.csv")[f"p_seed{s}"].to_numpy()
            preds[f"p_seed{s}"], preds[f"logit_seed{s}"] = p, lg
            above = p > THR
            fold["seeds"][s] = {"weights_sha256": sha(path), "weights_identical_to_run1": bool(same),
                                "max_abs_prob_diff_vs_run1_csv": float(np.abs(p - r1).max()),
                                "final_train_loss": curve[-1],
                                "run1_alarm": alarm_metrics(unlatched(above), above, yh, ts, ids),
                                "run2_latched_alarm": alarm_metrics(latched(above), above, yh, ts, ids)}
            preds[f"alarm_run1_seed{s}"], preds[f"alarm_run2_seed{s}"] = unlatched(above), latched(above)
            # x8 ablation: the same network with the temperature input at 0 ("not calibrated") on every row
            Xz = Xho.copy()
            Xz[:, 7] = 0.0
            pz = 1 / (1 + np.exp(-logits(net, Xz)))
            fold["seeds"][s]["x8_zeroed"] = {**prob_summary(pz, yh),
                                             "run2_latched_alarm": alarm_metrics(latched(pz > THR), pz > THR, yh, ts, ids),
                                             "run1_alarm_state_changes": alarm_metrics(unlatched(pz > THR), pz > THR, yh, ts, ids)["alarm_state_changes"]}
            preds[f"p_x8zero_seed{s}"] = pz
            # INT8 golden model on every held-out row; calibration of the hidden scales on the fold's training rows
            Xcal = pd.concat([data[b] for b in train])[NAMES].to_numpy(np.float64)
            q, (layers, scales, Xq), p_q = int8_check(net, Xcal, Xho.astype(np.float64), yh)
            q["latched_first_alarm_id_int8"] = alarm_metrics(latched(p_q > THR), p_q > THR, yh, ts, ids)["first_alarm_id"]
            res["int8"][f"{e}/seed{s}"] = q
            if e == "B03" and s == 0:
                res["int8"]["rtl_B03_seed0"] = rtl_check_one(layers, scales, Xq)
            diag_rows.append({"held_out": e, "seed": s, "weight_norm_final": weight_norm(net)})
        d = ab.prepare(load(e))
        assert (d.measurement_id.to_numpy() == ids).all()
        for name, cfg in sp.DETECTORS.items():
            sc, tau, native = sp.commissioned_alarm(d, cfg)
            above = sc > tau
            lat = alarm_metrics(latched(above), above, yh, ts, ids)
            fold["reference"][name] = {"run1_rule": alarm_metrics(unlatched(above), above, yh, ts, ids),
                                       "latched": lat, "native_persistent_alarm_id": native,
                                       "latched_matches_native": lat["first_alarm_id"] == native}
            preds[f"baseline_score_{cfg[1]}"], preds[f"baseline_tau_{cfg[1]}"] = sc, tau
        rms = d.accA_rms.to_numpy()
        fold["reference"][f"rig stop rule, rear RMS > {sp.RIG_LIMIT_G} g"] = {
            "run1_rule": alarm_metrics(unlatched(rms > sp.RIG_LIMIT_G), rms > sp.RIG_LIMIT_G, yh, ts, ids),
            "latched": alarm_metrics(latched(rms > sp.RIG_LIMIT_G), rms > sp.RIG_LIMIT_G, yh, ts, ids)}
        preds["rear_rms_g"] = rms
        fold["end_label_placed_by"] = sp.META["experiments"][e]["description"]["threshold_criterion"]
        # input-space diagnostics: how far the damaged rows are from the healthy reference, one input at a time
        h, dmg = ho[yh == 0][NAMES], ho[yh == 1][NAMES]
        fold["inputs"] = {n: {"healthy_median": float(h[n].median()), "healthy_min": float(h[n].min()),
                              "healthy_max": float(h[n].max()), "damaged_median": float(dmg[n].median()),
                              "damaged_min": float(dmg[n].min()), "damaged_max": float(dmg[n].max()),
                              "separates_alone": bool(dmg[n].min() > h[n].max() or dmg[n].max() < h[n].min())}
                          for n in NAMES}
        fold["rows_with_an_input_clipped"] = int(ho.clipped.sum())
        preds.to_csv(OUT / f"predictions_{e}.csv", index=False, float_format="%.6g")
        all_preds.append(preds.assign(held_out=e))
        # the same training with regularization (diagnostic only)
        for vname, kw in VARIANTS.items():
            for s in SEEDS:
                net = variant_fold(X, y, s, **kw)
                lg = logits(net, Xho)
                p = 1 / (1 + np.exp(-lg))
                lat = alarm_metrics(latched(p > THR), p > THR, yh, ts, ids)
                variant_rows.append({"variant": vname, "held_out": e, "seed": s, **prob_summary(p, yh),
                                     "mean_abs_logit_middle": float(np.abs(lg[np.isnan(yh)]).mean()),
                                     "weight_norm": weight_norm(net),
                                     "unlatched_state_changes": alarm_metrics(unlatched(p > THR), p > THR, yh, ts, ids)["alarm_state_changes"],
                                     "latched_first_alarm_id": lat["first_alarm_id"], "latched_end_recall": lat["end_recall"],
                                     "latched_healthy_rows_alarmed": lat["healthy_rows_alarmed"]})
        res["folds"][e] = fold
        print(f"{e}: weights identical to run 1 {[fold['seeds'][s]['weights_identical_to_run1'] for s in SEEDS]}, "
              f"latched first alarm {[fold['seeds'][s]['run2_latched_alarm']['first_alarm_id'] for s in SEEDS]}")
    # pooled reliability over the held-out labelled rows (each row once per seed)
    P = pd.concat(all_preds, ignore_index=True)
    pool_p = np.concatenate([P[f"p_seed{s}"].to_numpy() for s in SEEDS])
    pool_y = np.concatenate([P.y_det.to_numpy() for _ in SEEDS])
    e_val, bins = ece(pool_p, pool_y)
    prior = (sum(f["train_rows"]["deteriorated"] for f in res["folds"].values())
             / sum(sum(f["train_rows"].values()) for f in res["folds"].values()))
    res["calibration"] = {"pooled_labelled_rows": int((~np.isnan(pool_y)).sum()), "ece_10_bins": e_val,
                          "reliability_bins": bins, **prob_summary(pool_p, pool_y),
                          "share_of_all_heldout_probabilities_below_1e-3_or_above_0.999":
                              float(((pool_p < 1e-3) | (pool_p > 0.999)).mean()),
                          "balanced_sampling_prior": {"training_batch_positive_share": 0.5,
                                                      "labelled_training_positive_share": prior,
                                                      "logit_offset_to_labelled_prior": float(np.log(prior / (1 - prior)))},
                          "weight_norm_final": diag_rows}
    pd.DataFrame(ckpt_rows).to_csv(OUT / "checkpoints.csv", index=False, float_format="%.6g")
    pd.DataFrame(variant_rows).to_csv(OUT / "variants.csv", index=False, float_format="%.6g")
    res["elapsed_s"] = round(time.time() - t0, 1)
    res["run1_unchanged"] = tree_digest(RUN1) == run1_before
    (OUT / "results.json").write_text(json.dumps(res, indent=1, default=str) + "\n", encoding="utf-8")
    print(f"done in {res['elapsed_s']} s; run 1 unchanged: {res['run1_unchanged']} -> {OUT}")


if __name__ == "__main__":
    main()
