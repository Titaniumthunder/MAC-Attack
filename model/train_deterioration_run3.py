"""Training Run 3 of the deterioration head: seven development bearings, nested leave-one-bearing-out (3 Nov 2026).

  python run3_prep.py                       first (results/supervised/run3/prep/)
  python train_deterioration_run3.py        -> results/supervised/run3/train/, export/MTL_run3/   (refuses to overwrite)

DESIGN (fixed here, written to train/DESIGN.json before any network is trained):
  bearings     B02, B03, B04 (Runs 1-2) and B08, B09, B11, B12 (new), 100 healthy-reference + 5 provisional end-stage
               labels each (labels.py rule, unchanged). B01 excluded (no labels). B06, B07, B13, B17 (locked test) never
               loaded: splits.assert_development on every bearing list.
  network      mtl_model.MultiTaskMLP, unchanged 8 -> 32 -> 16 -> 2 (850 parameters); the health-index head frozen
               (no gradient, not in the optimizer, checked bit-identical after every training); y_hi has no labels.
  training     Run 1-2's loop (train_deterioration.train_fold): Adam lr 1e-3, 2,000 steps of 64 rows (half per class),
               temperature-input dropout 50 %, seeds 0-4. Labelled rows of the training bearings only.
  candidates   A_run12        Run 1-2 settings (weight decay 0, inputs clipped at +-16, temperature input used)
               B_wd           A + weight decay 0.01 (Adam L2)          PRE-DECLARED PRIMARY (suggested by Run 2, which
                                                                        saw B02-B04: exploratory for those 3 bearings)
               C_wd_slog      B with log-compressed inputs instead of the +-16 clip: x = sign(z) ln(1 + min(|z|, 1e4))
                              (clipping study; the ARM computes the transform, so the hardware is unchanged)
               D_wd_noT       B with the temperature input x8 = 0 on every row (temperature-shortcut study)
               E_wd_slog_noT  C + D
  decision     score p = sigmoid(logit) > 0.5 (fixed, not tuned), alarm after 3 consecutive, LATCHED (Run 2); the raw score
               is kept next to the alarm in every predictions file.
  protocols    P1 primary: B_wd, 7-fold leave-one-bearing-out (train on 6, score every measurement of the 7th), 5 seeds.
               P2 nested selection: for each outer bearing o, inner leave-one-out over the other 6 (train on 5, validate
               on 1) for every candidate and seed; the candidate is chosen by SELECTION (below) on the inner folds only,
               then scored on o (the outer model is the P3 model of that candidate: same data, same seeds). This is the
               unbiased estimate of "choose among A-E, then deploy".
               P3 every candidate, 7-fold (for transparency; used only by the final full-development selection).
               FINAL the candidate chosen by SELECTION over the 7-fold results, trained on all 7 bearings (5 seeds):
               the deployment candidate (no held-out data left; not frozen; the test set stays locked).
  SELECTION    lexicographic on the mean over validation folds x seeds: (1) fewest healthy-reference rows alarmed
               (latched), (2) highest end-stage recall (latched), (3) fewest alarm-state changes of the UNLATCHED alarm
               (stability, label-free), (4) lowest log-loss on the labelled rows. Alarm timing is never used to select
               (the onset is unknown).
  leakage      no measurement of a validation or held-out bearing is used to fit the network, the INT8 calibration, a
               threshold or a hyperparameter of its fold. Inputs are normalised per bearing on that bearing's own first
               100 operating measurements (as a deployed unit commissions itself); nothing is fitted across bearings.
  hardware     every outer and final model: INT8 (export.build, s_x = clip/127, hidden scales from the training bearings'
               rows) through the bit-exact golden model on every row; the final models exported as hex files
               (export/MTL_run3/); RTL simulation (tb_mlp.sv, Icarus) of the final seed-0 model and of one outer model
               per bearing. Simulation only: nothing here ran on the ZedBoard.
"""
import hashlib, json, multiprocessing as mp, shutil, sys, tempfile, time
from concurrent.futures import ProcessPoolExecutor
from pathlib import Path

import numpy as np
import pandas as pd
import torch

import mtl_model as mm
import splits
import supervised_prep as sp
import train_deterioration as td
import train_deterioration_run2 as r2
from export import build, c_array
from mac import write_hex

PREP = sp.OUT / "run3" / "prep"
OUT = sp.OUT / "run3" / "train"
EXPORT = sp.HERE / "export" / "MTL_run3"
BEARINGS = ("B02", "B03", "B04", "B08", "B09", "B11", "B12")
NEW = ("B08", "B09", "B11", "B12")
LOCKED = ("B06", "B07", "B13", "B17")
SEEDS = (0, 1, 2, 3, 4)
STEPS, BATCH, LR, X8_DROPOUT, THR, EVERY = td.STEPS, td.BATCH, td.LR, td.X8_DROPOUT, td.THRESHOLD, 25
ZCAP = 1e4
CONFIGS = {"A_run12": {"wd": 0.0, "transform": "clip16", "x8": True},
           "B_wd": {"wd": 0.01, "transform": "clip16", "x8": True},
           "C_wd_slog": {"wd": 0.01, "transform": "slog", "x8": True},
           "D_wd_noT": {"wd": 0.01, "transform": "clip16", "x8": False},
           "E_wd_slog_noT": {"wd": 0.01, "transform": "slog", "x8": False}}
PRIMARY = "B_wd"
S_X = {"clip16": 16.0 / 127.0, "slog": float(np.log1p(ZCAP)) / 127.0}
DATA = {}


# ---------------------------------------------------------------- data

def load_data():
    for e in BEARINGS:
        z = np.load(PREP / f"inputs_{e}.npz")
        DATA[e] = {k: z[k] for k in z.files}
        DATA[e]["ts_series"] = pd.Series(pd.to_datetime(DATA[e]["ts"]))


def init_worker():
    torch.set_num_threads(1)
    load_data()


def inputs(e, cfg):
    d = DATA[e]
    X = d["X"].copy() if cfg["transform"] == "clip16" else np.sign(d["R"]) * np.log1p(np.minimum(np.abs(d["R"]), ZCAP))
    if not cfg["x8"]:
        X[:, 7] = 0.0
    return X


def train_set(train, cfg):
    X = np.concatenate([inputs(b, cfg)[~np.isnan(DATA[b]["y"])] for b in train]).astype(np.float32)
    y = np.concatenate([DATA[b]["y"][~np.isnan(DATA[b]["y"])] for b in train])
    return X, y


# ---------------------------------------------------------------- training

def fit(cfg, train, seed, val=None):
    """train_deterioration.train_fold's loop (bit-identical for A_run12) with Adam weight decay; optional curves on a
    held-out bearing (reporting only: nothing is chosen from them)."""
    splits.assert_development(train)
    assert val is None or val not in train
    X, y = train_set(train, CONFIGS[cfg])
    rng = np.random.default_rng(seed)
    net = mm.MultiTaskMLP(seed=seed)
    hi0 = [p.detach().clone() for p in net.hi_head.parameters()]
    for p in net.hi_head.parameters():
        p.requires_grad_(False)
    opt = torch.optim.Adam([p for p in net.parameters() if p.requires_grad], lr=LR, weight_decay=CONFIGS[cfg]["wd"])
    pos, neg = np.flatnonzero(y == 1), np.flatnonzero(y == 0)
    curve, losses = [], []
    if val is not None:
        Xv = inputs(val, CONFIGS[cfg]).astype(np.float32)
        yv = DATA[val]["y"]
        lab = ~np.isnan(yv)
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
        losses.append(parts["det"])
        if val is not None and step % EVERY == 0:
            lg = logits(net, Xv)
            p = np.clip(1 / (1 + np.exp(-lg[lab])), 1e-12, 1 - 1e-12)
            t = yv[lab]
            curve.append({"step": step, "train_loss": float(np.mean(losses[-EVERY:])),
                          "val_loss_labelled": float(-(t * np.log(p) + (1 - t) * np.log(1 - p)).mean()),
                          "val_mean_abs_logit_all": float(np.abs(lg).mean())})
    if not all(torch.equal(a, b) for a, b in zip(hi0, net.hi_head.parameters())):
        raise RuntimeError("the health-index head changed during training")
    return net, curve, float(np.mean(losses[-EVERY:]))


def logits(net, X):
    with torch.no_grad():
        return net(torch.tensor(np.asarray(X, np.float32)))[0].double().numpy()


def evaluate(p, e):
    d = DATA[e]
    above = p > THR
    return {"latched": r2.alarm_metrics(r2.latched(above), above, d["y"], d["ts_series"], d["ids"]),
            "unlatched": r2.alarm_metrics(r2.unlatched(above), above, d["y"], d["ts_series"], d["ids"]),
            "prob": r2.prob_summary(p, d["y"]),
            "share_mid_between_0.05_0.95": float(((p > 0.05) & (p < 0.95))[np.isnan(d["y"])].mean())}


def int8(net, cfg, train, e):
    """INT8 through the bit-exact golden model on every row of bearing e; hidden scales from the training rows only."""
    c = CONFIGS[cfg]
    s_x = S_X[c["transform"]]
    Xcal = np.concatenate([inputs(b, c) for b in train])
    seq = net.eval().as_sequential()
    layers, scales = build(seq, Xcal, s_x)
    X = inputs(e, c)
    with torch.no_grad():
        fp = seq(torch.tensor(X, dtype=torch.float32)).double().numpy()[:, 0]
    Xq, C, real = mm.int8_forward(X, layers, scales, s_x)
    q = real[:, 0]
    pf, pq = 1 / (1 + np.exp(-fp)), 1 / (1 + np.exp(-q))
    y = DATA[e]["y"]
    lab = ~np.isnan(y)
    ch = (pq > THR) != (pf > THR)
    lf, lq = r2.latched(pf > THR), r2.latched(pq > THR)
    return {"rows": len(X), "logit_mean_abs_err": float(np.abs(q - fp).mean()), "logit_max_abs_err": float(np.abs(q - fp).max()),
            "prob_max_abs_err": float(np.abs(pq - pf).max()), "decisions_changed": int(ch.sum()),
            "decisions_changed_labelled": int((ch & lab).sum()),
            "latched_first_alarm_fp32": int(DATA[e]["ids"][np.argmax(lf)]) if lf.any() else None,
            "latched_first_alarm_int8": int(DATA[e]["ids"][np.argmax(lq)]) if lq.any() else None,
            "latched_states_differ": int((lf != lq).sum()),
            "inputs_at_int8_rail": int((np.abs(Xq) == 127).any(axis=1).sum())}, pq, (layers, scales, Xq, s_x)


# ---------------------------------------------------------------- tasks (run in worker processes)

def task_outer(args):
    cfg, train, held, seed, save = args
    net, curve, last = fit(cfg, train, seed, val=held)
    lg = logits(net, inputs(held, CONFIGS[cfg]))
    p = 1 / (1 + np.exp(-lg))
    res = {"cfg": cfg, "held_out": held, "seed": seed, "train": list(train), "final_train_loss": last, "curve": curve,
           "metrics": evaluate(p, held)}
    q, pq, _ = int8(net, cfg, train, held)
    res["int8"] = q
    if CONFIGS[cfg]["x8"]:
        Xz = inputs(held, CONFIGS[cfg])
        Xz[:, 7] = 0.0
        res["x8_zeroed"] = evaluate(1 / (1 + np.exp(-logits(net, Xz))), held)
    Path(save).parent.mkdir(parents=True, exist_ok=True)
    torch.save(net.state_dict(), save)
    res["weights_sha256"] = hashlib.sha256(Path(save).read_bytes()).hexdigest()
    res["p"], res["logit"], res["p_int8"] = p.tolist(), lg.tolist(), pq.tolist()
    return res


def task_inner(args):
    cfg, train, val, seed, outer = args
    net, _, _ = fit(cfg, train, seed)
    p = 1 / (1 + np.exp(-logits(net, inputs(val, CONFIGS[cfg]))))
    m = evaluate(p, val)
    return {"cfg": cfg, "outer": outer, "validation": val, "seed": seed,
            "healthy_alarmed": m["latched"]["healthy_rows_alarmed"], "end_recall": m["latched"]["end_recall"],
            "unlatched_changes": m["unlatched"]["alarm_state_changes"], "logloss": m["prob"]["logloss_labelled"]}


def task_final(args):
    cfg, seed, save = args
    net, _, last = fit(cfg, BEARINGS, seed)
    Path(save).parent.mkdir(parents=True, exist_ok=True)
    torch.save(net.state_dict(), save)
    out = {"cfg": cfg, "seed": seed, "final_train_loss": last,
           "weights_sha256": hashlib.sha256(Path(save).read_bytes()).hexdigest(), "int8_all_bearings": {}}
    for e in BEARINGS:          # in-sample for every bearing: INT8 agreement only, not a performance estimate
        out["int8_all_bearings"][e] = int8(net, cfg, BEARINGS, e)[0]
    return out


def rank_key(rows):
    """SELECTION: lexicographic on the means (see the docstring)."""
    r = pd.DataFrame(rows)
    return (float(r.healthy_alarmed.mean()), -float(r.end_recall.mean()), float(r.unlatched_changes.mean()),
            float(r.logloss.mean()))


# ---------------------------------------------------------------- hardware

def export_final(net, cfg, seed, folder):
    c = CONFIGS[cfg]
    s_x = S_X[c["transform"]]
    Xcal = np.concatenate([inputs(b, c) for b in BEARINGS])
    seq = net.eval().as_sequential()
    layers, scales = build(seq, Xcal, s_x)
    folder.mkdir(parents=True)
    for l, L in enumerate(layers):
        write_hex(folder / f"W{l}.hex", L["W"], 8)
        write_hex(folder / f"Bias{l}.hex", L["bias"], 32)
        write_hex(folder / f"Scl{l}.hex", (np.asarray(L["shift"]) << 16) | np.asarray(L["m0"]), 24)
    bias_last = [int(v) for v in scales[-1]["bias_last"]]
    quant = {"model": f"MTL run 3, {cfg}, seed {seed}, trained on {list(BEARINGS)}", "inputs": td.NAMES,
             "input_transform": c["transform"], "x8_used": c["x8"], "s_x": s_x, "z_cap_for_slog": ZCAP,
             "sizes": [8, 32, 16, 2], "heads": ["deterioration_logit (trained)", "health_raw (UNTRAINED, frozen: do not use)"],
             "layers": [{"s_in": sc["s_in"], "s_w": np.asarray(sc["s_w"]).tolist(), **({"s_out": sc["s_out"]} if "s_out" in sc else {}),
                         "bias": L["bias"].tolist(), "m0": np.asarray(L["m0"]).tolist(), "shift": np.asarray(L["shift"]).tolist(),
                         "relu": L["relu"]} for L, sc in zip(layers, scales)],
             "bias_last": bias_last, "logit_scale_det": float(scales[-1]["s_in"] * np.asarray(scales[-1]["s_w"])[0]),
             "decision": "p = sigmoid((C[0] + bias_last[0]) * logit_scale_det) > 0.5, three in a row, then latched",
             "accumulator_bits": mm.ACC}
    (folder / "quant.json").write_text(json.dumps(quant, indent=1) + "\n", encoding="utf-8")
    hdr = ["/* Machine Guardian multi-task MLP, training run 3 (" + cfg + f", seed {seed}). Generated by train_deterioration_run3.py.",
           " * 8 -> 32 -> 16 -> 2, INT8 weights (K x N row-major), INT32 biases, per-channel (m0, shift) requantization.",
           " * Head 0 = deterioration logit (trained). Head 1 = health index (UNTRAINED, frozen: never report it). */",
           "#pragma once", "#include <stdint.h>", f"#define MTL_S_X {s_x!r}f", f"#define MTL_BIAS_LAST_DET {bias_last[0]}",
           f"#define MTL_LOGIT_SCALE_DET {quant['logit_scale_det']!r}f", f"#define MTL_INPUT_TRANSFORM_{c['transform'].upper()} 1"]
    for l, L in enumerate(layers):
        hdr += [c_array("int8_t", f"MTL_W{l}", L["W"]), c_array("int32_t", f"MTL_B{l}", L["bias"])]
        if L["relu"]:
            hdr += [c_array("int32_t", f"MTL_M0_{l}", L["m0"]), c_array("int8_t", f"MTL_SHIFT_{l}", L["shift"])]
    (folder / "mtl_run3.h").write_text("\n".join(hdr) + "\n", encoding="utf-8")
    rows = np.concatenate([np.flatnonzero(~np.isnan(DATA[e]["y"])) for e in BEARINGS[:1]])
    X = np.concatenate([inputs(e, c) for e in BEARINGS])
    sel = np.linspace(0, len(X) - 1, 64).astype(int)
    Xq, C, real = mm.int8_forward(X[sel], layers, scales, s_x)
    write_hex(folder / "vectors_X.hex", Xq, 8)
    write_hex(folder / "vectors_C.hex", C, 22)
    return layers, scales, s_x


def rtl(layers, scales, Xq, n_batches):
    import rtl_check
    root = Path(tempfile.mkdtemp(prefix="mg_run3_rtl_"))
    try:
        sim = rtl_check.TempSimulator(root, "icarus")
        work = sim.build("tb_mlp", rtl_check.PARAMS)
        n = min(len(Xq) // 64, n_batches) * 64
        step = max(1, len(Xq) // n)
        pick = Xq[::step][:n]
        g64, _, c64, _ = rtl_check.run(sim, work, layers, [pick[i:i + 64] for i in range(0, n, 64)], int(scales[-1]["bias_last"][0]))
        g1, _, c1, _ = rtl_check.run(sim, work, layers, [Xq[[i]] for i in range(10)], int(scales[-1]["bias_last"][0]))
        return {"simulator": "Icarus Verilog (tb_mlp.sv, rtl_check.PARAMS)", "M64": {"pass": bool(g64), "batches": n // 64,
                "cycles": sorted(c64)}, "M1": {"pass": bool(g1), "batches": 10, "cycles": sorted(c1)},
                "latency_us_at_214.286MHz": {"M64": sorted(c64)[0] / 214.286, "M1": sorted(c1)[0] / 214.286}}
    finally:
        shutil.rmtree(root, ignore_errors=True)


# ---------------------------------------------------------------- main

def main(jobs=8):
    if OUT.exists() or EXPORT.exists():
        raise SystemExit(f"{OUT} or {EXPORT} exists: a run is never overwritten")
    splits.assert_development(BEARINGS)
    assert set(LOCKED) == set(splits.load()["test"].values()) and not set(BEARINGS) & set(LOCKED)
    lt = json.loads((PREP / "label_table_run3.json").read_text())
    assert lt["sha256"] and lt["provenance"]["b02_b04_part_reproduces_run12_table"]
    load_data()
    OUT.mkdir(parents=True)
    t0 = time.time()
    design = {"configs": CONFIGS, "primary": PRIMARY, "seeds": SEEDS, "steps": STEPS, "batch": BATCH, "lr": LR,
              "x8_dropout": X8_DROPOUT, "threshold": THR, "persistence": 3, "alarm": "latched", "zcap_slog": ZCAP,
              "s_x": S_X, "bearings": BEARINGS, "new_bearings": NEW, "locked_test_never_loaded": LOCKED,
              "label_table_sha256": lt["sha256"], "selection": "lexicographic means: healthy rows alarmed (min), "
              "end-stage recall (max), unlatched alarm-state changes (min), labelled log-loss (min)",
              "architecture": [8, 32, 16, 2], "params": mm.n_params(mm.MultiTaskMLP()),
              "script_sha256": hashlib.sha256(Path(__file__).read_bytes()).hexdigest(), "docstring": __doc__}
    (OUT / "DESIGN.json").write_text(json.dumps(design, indent=1) + "\n", encoding="utf-8")
    # reproduction check: A_run12 on Run 1's folds gives Run 1's networks bit for bit
    r1 = json.loads((sp.OUT / "run1" / "results.json").read_text())
    repro = {}
    for held, train in (("B02", ("B03", "B04")), ("B03", ("B02", "B04")), ("B04", ("B02", "B03"))):
        net, _, _ = fit("A_run12", train, 0)
        ref = torch.load(sp.OUT / "run1" / f"fold_{held}_seed0.pt", weights_only=True)
        repro[held] = all(torch.equal(a, ref[k]) for k, a in net.state_dict().items())
    print("Run 1 reproduced bit for bit:", repro)
    ctx = mp.get_context("spawn")
    with ProcessPoolExecutor(jobs, mp_context=ctx, initializer=init_worker) as ex:
        outer_args = [(c, tuple(b for b in BEARINGS if b != o), o, s, str(OUT / "models" / c / f"fold_{o}_seed{s}.pt"))
                      for c in CONFIGS for o in BEARINGS for s in SEEDS]
        inner_args = [(c, tuple(b for b in BEARINGS if b not in (o, v)), v, s, o)
                      for o in BEARINGS for v in BEARINGS if v != o for c in CONFIGS for s in SEEDS]
        outer = list(ex.map(task_outer, outer_args))
        print(f"outer: {len(outer)} trainings, {time.time() - t0:.0f} s")
        inner = list(ex.map(task_inner, inner_args, chunksize=8))
        print(f"inner: {len(inner)} trainings, {time.time() - t0:.0f} s")
    for a, r in zip(outer_args, outer):
        assert r["held_out"] not in r["train"] and len(r["train"]) == 6
    inner_df = pd.DataFrame(inner)
    inner_df.to_csv(OUT / "inner_folds.csv", index=False, float_format="%.6g")
    # P2: nested selection per outer bearing
    nested = {}
    for o in BEARINGS:
        sub = inner_df[inner_df.outer == o]
        keys = {c: rank_key(sub[sub.cfg == c].to_dict("records")) for c in CONFIGS}
        nested[o] = {"keys": keys, "selected": min(keys, key=keys.get)}
    # full-development selection (for the final model): the same rule on the 7-fold outer results
    out_df = pd.DataFrame([{"cfg": r["cfg"], "held_out": r["held_out"], "seed": r["seed"],
                            "healthy_alarmed": r["metrics"]["latched"]["healthy_rows_alarmed"],
                            "end_recall": r["metrics"]["latched"]["end_recall"],
                            "unlatched_changes": r["metrics"]["unlatched"]["alarm_state_changes"],
                            "logloss": r["metrics"]["prob"]["logloss_labelled"]} for r in outer])
    full_keys = {c: rank_key(out_df[out_df.cfg == c].to_dict("records")) for c in CONFIGS}
    final_cfg = min(full_keys, key=full_keys.get)
    print("nested selections:", {o: v["selected"] for o, v in nested.items()}, "| full-development selection:", final_cfg)
    # predictions files (raw score, logits, both alarms, INT8 score) for every candidate and bearing
    for c in CONFIGS:
        for o in BEARINGS:
            d = DATA[o]
            df = pd.DataFrame({"measurement_id": d["ids"], "timestamp": d["ts_series"], "y_det": d["y"]})
            for r in [r for r in outer if r["cfg"] == c and r["held_out"] == o]:
                s, p = r["seed"], np.array(r["p"])
                df[f"p_seed{s}"], df[f"logit_seed{s}"], df[f"p_int8_seed{s}"] = p, r["logit"], r["p_int8"]
                df[f"alarm_latched_seed{s}"] = r2.latched(p > THR).astype(int)
                df[f"alarm_unlatched_seed{s}"] = r2.unlatched(p > THR).astype(int)
            (OUT / "predictions" / c).mkdir(parents=True, exist_ok=True)
            df.to_csv(OUT / "predictions" / c / f"predictions_{o}.csv", index=False, float_format="%.6g")
    curves = pd.DataFrame([dict(cfg=r["cfg"], held_out=r["held_out"], seed=r["seed"], **pt) for r in outer for pt in r["curve"]])
    curves.to_csv(OUT / "curves.csv", index=False, float_format="%.6g")
    # references on every bearing: anomaly detector (latched = its own persistent rule) and the rig's 6.5 g rule
    refs = {}
    for e in BEARINGS:
        d = DATA[e]
        refs[e] = {}
        for k in ("F42", "F128"):
            s, tau = d[f"score_{k}"], float(d[f"tau_{k}"])
            if np.isfinite(s).all() and np.isfinite(tau):
                above = s > tau
                refs[e][f"anomaly A|{k}|speed"] = {"latched": r2.alarm_metrics(r2.latched(above), above, d["y"], d["ts_series"], d["ids"]),
                                                   "unlatched": r2.alarm_metrics(r2.unlatched(above), above, d["y"], d["ts_series"], d["ids"])}
            else:
                refs[e][f"anomaly A|{k}|speed"] = None
        above = d["rms"] > sp.RIG_LIMIT_G
        refs[e]["rig rule rear RMS > 6.5 g"] = {"latched": r2.alarm_metrics(r2.latched(above), above, d["y"], d["ts_series"], d["ids"]),
                                                "unlatched": r2.alarm_metrics(r2.unlatched(above), above, d["y"], d["ts_series"], d["ids"])}
    # FINAL models (deployment candidate) and hardware
    with ProcessPoolExecutor(5, mp_context=ctx, initializer=init_worker) as ex:
        final = list(ex.map(task_final, [(final_cfg, s, str(OUT / "models" / "FINAL" / f"{final_cfg}_all7_seed{s}.pt")) for s in SEEDS]))
    net = mm.MultiTaskMLP(seed=0)
    net.load_state_dict(torch.load(OUT / "models" / "FINAL" / f"{final_cfg}_all7_seed0.pt", weights_only=True))
    layers, scales, s_x = export_final(net, final_cfg, 0, EXPORT / "seed0")
    Xall = np.concatenate([inputs(e, CONFIGS[final_cfg]) for e in BEARINGS])
    Xq_all = mm.int8_forward(Xall, layers, scales, s_x)[0]
    hw = {"final_seed0": rtl(layers, scales, Xq_all, 24), "outer_seed0": {}}
    for o in BEARINGS:
        c = nested[o]["selected"]
        net = mm.MultiTaskMLP(seed=0)
        net.load_state_dict(torch.load(OUT / "models" / c / f"fold_{o}_seed0.pt", weights_only=True))
        _, _, (L, S, Xq, _) = int8(net, c, tuple(b for b in BEARINGS if b != o), o)
        hw["outer_seed0"][o] = dict(rtl(L, S, Xq, 9), cfg=c)
    print("RTL:", {k: (v["M64"]["pass"], v["M1"]["pass"]) for k, v in [("final", hw["final_seed0"])] + list(hw["outer_seed0"].items())})
    res = {"design": design, "run1_reproduced": repro, "outer": [{k: v for k, v in r.items() if k not in ("p", "logit", "p_int8")}
                                                                  for r in outer],
           "nested": nested, "full_development_keys": full_keys, "final_cfg": final_cfg, "final": final,
           "references": refs, "rtl": hw, "elapsed_s": round(time.time() - t0, 1)}
    (OUT / "results.json").write_text(json.dumps(res, indent=1, default=str) + "\n", encoding="utf-8")
    print(f"done in {res['elapsed_s']} s -> {OUT}")


if __name__ == "__main__":
    main()
