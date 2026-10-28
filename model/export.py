"""Export the proposed model to INT8 for the on-chip MLP and check it in Python (bit-exact model: mac.py's golden_mlp).

  python export.py                    E3, seed 42 (the proposed model; Alex to confirm, docs/log.md section 12)

Quantization (Alex's spec of 27 Oct; the open details marked):
  inputs   x_std = (x - mean) / std (the training standardizer); q_x = clip(round_half_away(x_std / s_x), -127, 127).
           s_x is one scale for all inputs (the hardware has one input scale per layer). Two candidates, chosen on
           validation before the test result is looked at [proposed]: max |x_std| over the train windows / 127, or
           its 99.9th percentile / 127 (clips the rare kurtosis and crest outliers); the one with the smaller mean
           |INT8 logit - FP32 logit| over the validation windows (the max on a tie).
  weights  per output channel: s_w[j] = max_k |W[k, j]| / 127, W_q = round_half_away(W / s_w) (|W_q| <= 127).
  hidden   s_h = the largest activation (after ReLU) over the train windows / 127 [proposed];
           bias = round_half_away(b / (s_in * s_w)); (m0, shift) = scale_to_m0_shift(s_in * s_w / s_h);
           requantize() rounds halves up, as postproc.sv.
  last     the chip returns the raw sums C; the ARM adds bias_last = round_half_away(b / (s_h * s_w)):
           logit_int = C + bias_last (real logit ~ s_h * s_w * logit_int).
           T_int = ceil(ln(t / (1 - t)) / (s_h * s_w)) with ln(t / (1 - t)) = the FP32 cut on the validation scores;
           a recording (the last 10 s) is faulty if the sum of its 10 window logits >= 10 * T_int.

Writes export/<E>/: W<l>.hex, Bias<l>.hex, Scl<l>.hex (mac.write_hex, the files tb_mlp.sv reads; the last layer's bias
and scale are zero: the chip does not use them), mg_model.h (C header: everything the ARM needs, with the health
index of output 2), vectors/ (test vectors), quant.json and report.md.
"""
import argparse, csv, json, math, sys

import numpy as np
import torch

from dataset import HERE, MAC_DIR, WINDOWS
from train import EXPERIMENTS, SPLITS, load, metrics, mlp, recording_scores

sys.path.insert(0, str(MAC_DIR))
from mac import golden_mlp, mlp_equation, requantize, scale_to_m0_shift, write_hex   # noqa: E402

ACC = 22
FCLK = 214.286e6          # the on-chip MLP build's clock (22 Oct)


def round_half_away(x):
    """Round to the nearest integer, halves away from zero (C's round()). Not floor(|x| + 0.5), which rounds
    0.49999999999999994 up (the sum rounds to 1.0)."""
    x = np.asarray(x, dtype=np.float64)
    a = np.abs(x)
    r = np.floor(a)
    return np.sign(x) * (r + (a - r >= 0.5))


def quantize_inputs(Xs, s_x):
    return np.clip(round_half_away(Xs / s_x), -127, 127).astype(np.int64)


def build(net, Xs_train, s_x):
    """The INT8 layers (golden_mlp's format) and the scales, from the FP32 net."""
    lin = [m for m in net if isinstance(m, torch.nn.Linear)]
    Ws = [m.weight.detach().double().numpy().T for m in lin]      # K x N
    bs = [m.bias.detach().double().numpy() for m in lin]
    # FP32 activations on the train windows (calibration of s_h)
    acts, a = [], torch.tensor(Xs_train, dtype=torch.float32)
    with torch.no_grad():
        for m in list(net)[:-1]:
            a = m(a)
            if isinstance(m, torch.nn.ReLU):
                acts.append(a.double().numpy())
    layers, s_in, scales = [], s_x, []
    for l, (W, b) in enumerate(zip(Ws, bs)):
        s_w = np.abs(W).max(axis=0) / 127.0
        s_w = np.where(s_w > 0, s_w, 1.0)
        Wq = round_half_away(W / s_w).astype(np.int64)
        bias = round_half_away(b / (s_in * s_w)).astype(np.int64)
        if l < len(Ws) - 1:
            s_out = float(acts[l].max()) / 127.0
            ms = [scale_to_m0_shift(s_in * s_w[j] / s_out) for j in range(len(b))]
            layers.append({"W": Wq, "bias": bias, "m0": np.array([m for m, _ in ms]),
                           "shift": np.array([s for _, s in ms]), "relu": True})
            scales.append({"s_in": s_in, "s_w": s_w, "s_out": s_out})
            s_in = s_out
        else:
            layers.append({"W": Wq, "bias": np.zeros_like(bias), "m0": np.zeros_like(bias),
                           "shift": np.ones_like(bias), "relu": False})
            scales.append({"s_in": s_in, "s_w": s_w, "bias_last": bias})
    return layers, scales


def int8_logits(Xq, layers, scales):
    C, _ = golden_mlp(Xq, layers, acc=ACC)
    exact = Xq
    for L in layers[:-1]:          # the true sums must fit the 22-bit accumulator (no wrap)
        s = exact @ L["W"]
        assert np.abs(s).max() < 1 << (ACC - 1)
        exact = requantize(s, L["bias"][None, :], L["m0"][None, :], L["shift"][None, :], L["relu"])
    assert np.abs(exact @ layers[-1]["W"]).max() < 1 << (ACC - 1)
    return C[:, 0], C[:, 0] + int(scales[-1]["bias_last"][0])


def c_array(ctype, name, vals, per_line=16):
    vals = [str(int(v)) for v in np.ravel(vals)]
    lines = [", ".join(vals[i:i + per_line]) for i in range(0, len(vals), per_line)]
    return f"static const {ctype} {name}[{len(vals)}] = {{\n    " + ",\n    ".join(lines) + "\n};\n"


def f_array(name, vals):
    vals = [repr(float(v)) + "f" for v in np.ravel(vals)]
    lines = [", ".join(vals[i:i + 6]) for i in range(0, len(vals), 6)]
    return f"static const float {name}[{len(vals)}] = {{\n    " + ",\n    ".join(lines) + "\n};\n"


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--experiment", default="E3")
    ap.add_argument("--seed", type=int, default=42)
    a = ap.parse_args()
    name, seed = a.experiment, a.seed
    exp = EXPERIMENTS[name]
    info = json.loads((HERE / "weights" / name / "model.json").read_text())
    if exp["table"] != "windows":
        raise SystemExit("export.py handles window experiments (the recording score is the mean of 10 window logits)")
    rows = load("windows")
    X, inputs = exp["inputs"](rows)
    assert inputs == info["inputs"]
    mean, std = np.array(info["scaler"]["mean"]), np.array(info["scaler"]["std"])
    Xs = (X - mean) / std
    part = {sp: np.array([r["split"] == sp for r in rows]) for sp in SPLITS}
    net = mlp(len(inputs))
    net.load_state_dict(torch.load(HERE / "weights" / name / f"seed{seed}.pt", weights_only=True))
    net.eval()
    with torch.no_grad():
        fp32 = net(torch.tensor(Xs, dtype=torch.float32))[:, 0].double().numpy()
    cut = info["seeds"][str(seed)]["cut"]
    recs, fscore = recording_scores(rows, fp32)

    # the FP32 path must give train.py's saved scores exactly
    with open(HERE / "results" / name / "scores.csv", newline="") as f:
        saved = {r["file"]: float(r[f"score_s{seed}"]) for r in csv.DictReader(f)}
    assert all(saved[r["file"]] == s for r, s in zip(recs, fscore)), "FP32 scores differ from train.py's"

    # input scale: two candidates, chosen on validation
    absx = np.abs(Xs[part["train"]])
    cands = {"max": float(absx.max()) / 127.0, "p99.9": float(np.percentile(absx, 99.9)) / 127.0}
    trial = {}
    for k, s_x in cands.items():
        layers, scales = build(net, Xs[part["train"]], s_x)
        _, li = int8_logits(quantize_inputs(Xs, s_x), layers, scales)
        lscale = scales[-1]["s_in"] * float(scales[-1]["s_w"][0])
        trial[k] = float(np.abs(li[part["val"]] * lscale - fp32[part["val"]]).mean())
    pick = min(cands, key=lambda k: (trial[k], k != "max"))
    s_x = cands[pick]
    layers, scales = build(net, Xs[part["train"]], s_x)
    Xq = quantize_inputs(Xs, s_x)
    C, logit_int = int8_logits(Xq, layers, scales)
    s_h, s_wl = scales[-1]["s_in"], float(scales[-1]["s_w"][0])
    lscale = s_h * s_wl
    bias_last = int(scales[-1]["bias_last"][0])
    T_int = math.ceil(cut / lscale)

    # recordings: the sum of 10 window logits against 10 * T_int
    sums = {}
    for r, v in zip(rows, logit_int):
        sums.setdefault(r["file"], []).append(int(v))
    assert all(len(v) == WINDOWS for v in sums.values())
    isum = np.array([sum(sums[r["file"]]) for r in recs])
    ry = np.array([r["label"] for r in recs])
    rp = {sp: np.array([r["split"] == sp for r in recs]) for sp in SPLITS}
    res = {}
    for sp in SPLITS:
        sel = [r for r, k in zip(recs, rp[sp]) if k]
        res[sp] = {"fp32": metrics(fscore[rp[sp]], ry[rp[sp]], cut, sel),
                   "int8": metrics(isum[rp[sp]].astype(float), ry[rp[sp]], float(10 * T_int), sel),
                   "changed": [r["file"] for r, f_, i_ in zip(sel, fscore[rp[sp]] >= cut, isum[rp[sp]] >= 10 * T_int)
                               if f_ != i_]}
    werr = np.abs(logit_int * lscale - fp32)

    out = HERE / "export" / name
    (out / "vectors").mkdir(parents=True, exist_ok=True)
    for l, L in enumerate(layers):
        write_hex(out / f"W{l}.hex", L["W"], 8)
        write_hex(out / f"Bias{l}.hex", L["bias"], 32)
        write_hex(out / f"Scl{l}.hex", (np.asarray(L["shift"]) << 16) | np.asarray(L["m0"]), 24)

    health = json.loads((HERE / "weights" / "H1" / "health.json").read_text())
    quant = {"experiment": name, "seed": seed, "inputs": inputs, "sizes": info["sizes"],
             "s_x": s_x, "s_x_candidates": cands, "s_x_val_mae": trial, "s_x_choice": pick,
             "layers": [{"s_in": sc["s_in"], "s_w": sc["s_w"].tolist(), **({"s_out": sc["s_out"]} if "s_out" in sc else {}),
                         "bias": L["bias"].tolist(), "m0": np.asarray(L["m0"]).tolist(),
                         "shift": np.asarray(L["shift"]).tolist(), "relu": L["relu"]}
                        for L, sc in zip(layers, scales)],
             "bias_last": bias_last, "logit_scale": lscale, "cut": cut, "t": info["seeds"][str(seed)]["t"],
             "T_int": T_int, "rule": "faulty if sum of the last 10 window logit_int >= 10 * T_int"}
    (out / "quant.json").write_text(json.dumps(quant, indent=1) + "\n")
    (out / "mg_model.h").write_text(header(name, seed, inputs, mean, std, s_x, layers, bias_last, lscale, cut,
                                           T_int, health))
    write_vectors(out / "vectors", rows, recs, X, Xq, C, logit_int, fp32, isum, T_int, cut, fscore, part)
    (out / "report.md").write_text(report(name, seed, quant, res, werr, part, layers))

    print(f"{name} seed {seed} exported to {out}")
    print(f"  s_x {pick} = {s_x:.6g} (validation mean |logit error|: " +
          ", ".join(f"{k} {v:.4f}" for k, v in trial.items()) + ")")
    print(f"  bias_last {bias_last}, logit scale {lscale:.6g}, cut {cut:.4f} -> T_int {T_int}")
    for sp in SPLITS:
        f_, i_ = res[sp]["fp32"], res[sp]["int8"]
        print(f"  {sp}: FP32 {f_['confusion']} -> INT8 {i_['confusion']}, ROC-AUC {f_['roc_auc']:.3f} -> "
              f"{i_['roc_auc']:.3f}, decisions changed {len(res[sp]['changed'])} {res[sp]['changed']}")
    print(f"  window logits: INT8 x scale vs FP32, mean |error| {werr.mean():.4f}, max {werr.max():.4f}")


def header(name, seed, inputs, mean, std, s_x, layers, bias_last, lscale, cut, T_int, health):
    K = [L["W"].shape[0] for L in layers]
    N = [L["W"].shape[1] for L in layers]
    H = [f"/* Machine Guardian model {name} (seed {seed}), INT8 for the on-chip MLP. Generated by model/export.py: do not edit.",
         " *",
         " * Once a second, for the last 1-s window (42,000 samples of accelerometers 1, 2, 3 and the drive frequency f):",
         " *   1. x[k], k = 0 .. 21, in this order: per accelerometer 1, 2, 3: ln(std), ln(RMS), ln(max|x|), ln(peak-to-peak),",
         " *      crest = max|x| / RMS, skewness m3 / std^3, kurtosis m4 / std^4 (population moments); then ln(f), f in Hz",
         " *      (the frequency the drive is commanded to during the window, as the drive reports it; never a shaft-speed",
         " *      sensor such as a tachometer: that reading includes the slip, which differs between motors).",
         " *   2. q[k] = clamp(round((x[k] - MG_MEAN[k]) / MG_STD[k] / MG_SX), -127, 127)   (INT8, one row of A; C's round(),",
         " *      halves away from zero, not floor(v + 0.5f); check against vectors/test_windows.csv)",
         " *   3. the chip runs the 3 layers (weights, biases, {shift, m0} below; ReLU after layers 0 and 1) and returns",
         " *      C, the last layer's raw sum; logit = C + MG_BIAS_LAST (real logit ~ MG_LOGIT_SCALE * logit).",
         " *   4. output 1: keep the last 10 logits; the motor is faulty if their sum >= 10 * MG_T_INT.",
         " *   5. output 2 (health index, on the ARM): per window d = sqrt(mean_j z_j^2) over the first 21 x (no ln f),",
         " *      z_j = (x[j] - MG_HI_ALPHA[j] - MG_HI_BETA[j] * ln f) / MG_HI_SIGMA[j]; D = mean of the last 10 d;",
         " *      HI = 100% * clamp((MG_HI_D0 - D) / (MG_HI_D0 - MG_HI_D100), 0, 1). It is a distance from the one healthy",
         " *      motor at that speed, not a remaining capability. Not reliable below about 22 Hz: on validation windows it",
         " *      is inverted at 16.5 Hz and uninformative at 19.5 Hz, and at 15 Hz (test) healthy recordings score 0%.",
         " * Weights: K x N, row-major (W[k * N + n]), the order of the W<l>.hex files for tb_mlp.sv.",
         " * Inputs: " + ", ".join(inputs),
         " */",
         "#ifndef MG_MODEL_H", "#define MG_MODEL_H", "#include <stdint.h>", "",
         f"#define MG_INPUTS {K[0]}", f"#define MG_LAYERS {len(layers)}", f"#define MG_WINDOWS 10", "",
         c_array("int", "MG_K", K), c_array("int", "MG_N", N), c_array("int", "MG_RELU", [int(L["relu"]) for L in layers]),
         f_array("MG_MEAN", mean), f_array("MG_STD", std),
         f"static const float MG_SX = {repr(float(s_x))}f;", ""]
    for l, L in enumerate(layers):
        H.append(c_array("int8_t", f"MG_W{l}", L["W"]))
        if l < len(layers) - 1:
            H.append(c_array("int32_t", f"MG_BIAS{l}", L["bias"]))
            H.append(c_array("uint16_t", f"MG_M0_{l}", L["m0"]))
            H.append(c_array("uint8_t", f"MG_SHIFT{l}", L["shift"]))
    H += [f"#define MG_BIAS_LAST ({bias_last})",
          f"#define MG_T_INT ({T_int})",
          f"static const float MG_LOGIT_SCALE = {repr(float(lscale))}f;",
          f"static const float MG_CUT = {repr(float(cut))}f;   /* FP32 logit threshold (validation) */", "",
          f_array("MG_HI_ALPHA", health["alpha"]), f_array("MG_HI_BETA", health["beta"]),
          f_array("MG_HI_SIGMA", health["sigma"]),
          f"static const float MG_HI_D100 = {repr(float(health['d_100']))}f;",
          f"static const float MG_HI_D0 = {repr(float(health['d_0']))}f;", "", "#endif", ""]
    return "\n".join(H)


def write_vectors(out, rows, recs, X, Xq, C, logit_int, fp32, isum, T_int, cut, fscore, part):
    """Test vectors (test split): every window's inputs, INT8 row, raw sum and logit; every recording's decision."""
    names = [f"x{k}" for k in range(X.shape[1])]
    with open(out / "test_windows.csv", "w", newline="") as f:
        w = csv.writer(f, lineterminator="\n")
        w.writerow(["file", "window", "label", "f_hz"] + names + [f"q{k}" for k in range(X.shape[1])]
                   + ["C", "logit_int", "logit_fp32"])
        for i in np.where(part["test"])[0]:
            r = rows[i]
            w.writerow([r["file"], r["window"], r["label"], r["f_hz"]] + [float(v) for v in X[i]]
                       + [int(v) for v in Xq[i]] + [int(C[i]), int(logit_int[i]), float(fp32[i])])
    with open(out / "test_recordings.csv", "w", newline="") as f:
        w = csv.writer(f, lineterminator="\n")
        w.writerow(["file", "cls", "label", "speed", "load", "sum_logit_int", "ten_T_int", "faulty_int8",
                    "score_fp32", "faulty_fp32"])
        for r, s, fs in zip(recs, isum, fscore):
            if r["split"] == "test":
                w.writerow([r["file"], r["cls"], r["label"], r["speed"], r["load"], int(s), 10 * T_int,
                            int(s >= 10 * T_int), float(fs), int(fs >= cut)])


def report(name, seed, quant, res, werr, part, layers):
    L = [f"# {name} (seed {seed}) in INT8", "",
         f"Input scale s_x = {quant['s_x']:.6g} ({quant['s_x_choice']}; validation mean |logit error| "
         + ", ".join(f"{k} {v:.4f}" for k, v in quant["s_x_val_mae"].items()) + ")", "",
         f"Hidden scales s_h: " + ", ".join(f"{l['s_out']:.6g}" for l in quant["layers"] if "s_out" in l)
         + f"; bias_last {quant['bias_last']}; logit scale {quant['logit_scale']:.6g}; FP32 cut {quant['cut']:.4f} "
         f"-> T_int {quant['T_int']} ({quant['rule']})", "",
         "| Layer | K x N | W_q range | bias range | m0 range | shift range |", "|---|---|---|---|---|---|"]
    for l, (Ld, q) in enumerate(zip(layers, quant["layers"])):
        L.append(f"| {l} | {Ld['W'].shape[0]} x {Ld['W'].shape[1]} | {Ld['W'].min()} .. {Ld['W'].max()} | "
                 + (f"{min(q['bias'])} .. {max(q['bias'])} | {min(q['m0'])} .. {max(q['m0'])} | "
                    f"{min(q['shift'])} .. {max(q['shift'])} |" if l < len(layers) - 1
                    else f"(ARM: {quant['bias_last']}) | - | - |"))
    L += ["", "## FP32 against INT8 (recordings; INT8: sum of 10 window logits >= 10 T_int)", "",
          "| Split | FP32 [[TN,FP],[FN,TP]] | INT8 | FP32 ROC-AUC | INT8 ROC-AUC | INT8 accuracy / precision / recall / F1 | Decisions changed |",
          "|---|---|---|---|---|---|---|"]
    for sp in SPLITS:
        f_, i_ = res[sp]["fp32"], res[sp]["int8"]
        L.append(f"| {sp} | {f_['confusion']} | {i_['confusion']} | {f_['roc_auc']:.3f} | {i_['roc_auc']:.3f} | "
                 f"{i_['accuracy']:.3f} / {i_['precision']:.3f} / {i_['recall']:.3f} / {i_['f1']:.3f} | "
                 f"{len(res[sp]['changed'])}{' (' + ', '.join(res[sp]['changed']) + ')' if res[sp]['changed'] else ''} |")
    L += ["", f"Window logits, |INT8 x logit scale - FP32|: mean {werr.mean():.4f}, max {werr.max():.4f} "
          f"(test: mean {werr[part['test']].mean():.4f}, max {werr[part['test']].max():.4f}).", "",
          "Missed test recordings (INT8): " + (", ".join(res["test"]["int8"]["missed"]) or "none")
          + "; false alarms: " + (", ".join(res["test"]["int8"]["false_alarms"]) or "none"), ""]
    L += ["## On the chip (mlp_equation, P = 8, ZedBoard settings, 214.286 MHz)", "",
          "| Rows M | Passes | Model cycles | Time | Array use |", "|---|---|---|---|---|"]
    K = [Ld["W"].shape[0] for Ld in layers]
    N = [Ld["W"].shape[1] for Ld in layers]
    for M in (1, 10):
        p, cyc, busy, model = mlp_equation(8, M, K, N)
        macs = M * sum(k * n for k, n in zip(K, N))
        L.append(f"| {M} | {p} | {model} | {model / FCLK * 1e6:.2f} us | {macs / (64 * model) * 100:.1f}% |")
    return "\n".join(L) + "\n"


if __name__ == "__main__":
    main()
