"""Training Run 3, hardware verification v2 (3 Nov 2026): INT8 and RTL of every trained Run 3 network, with the dead-neuron
fix. Reads results/supervised/run3/train/ (unchanged); writes results/supervised/run3/hardware/ and export/MTL_run3_v2/.

  python run3_hardware.py

Why v2: weight decay drives the weights of some dead hidden neurons to ~1e-35. export.build then gives that output
channel a weight scale of ~1e-37 and its bias quantizes to ~1e24, which overflows INT64 in the cast and cannot be stored
in the hardware's 32-bit bias (31 of 175 outer models and 1 of 5 final models in train/results.json). v1's INT8 numbers
for those models are therefore invalid. The fix, applied only on the export path (export.py and the trained weights are
unchanged): before quantizing, every weight with |w| < 1e-6 x the largest |w| of its layer is set to 0; export.build
already gives an all-zero column the scale 1. The FP32 effect of this is measured on every row (max |logit change|) and
every INT32 bias is asserted to fit 32 bits.

Checks per network: FP32 vs INT8 (bit-exact golden model, 22-bit accumulator) on every row of its held-out bearing (outer
models) or of all 7 bearings (final models, in-sample); decisions changed, labelled decisions changed, latched first alarm.
RTL (tb_mlp.sv, Icarus Verilog): the final seed-0 model and, per bearing, the seed-0 outer model of the primary B_wd and of
the nested selection. Simulation only; nothing ran on the ZedBoard.
"""
import json, shutil, tempfile

import numpy as np
import pandas as pd
import torch

import mtl_model as mm
import train_deterioration_run3 as r3
from export import build, c_array
from mac import write_hex

HW = r3.OUT.parent / "hardware"
EXPORT2 = r3.HERE if hasattr(r3, "HERE") else None
EXPORT2 = r3.EXPORT.parent / "MTL_run3_v2"
REL_EPS = 1e-6
FCLK_MHZ = 214.286


def load(path, seed):
    net = mm.MultiTaskMLP(seed=seed)
    net.load_state_dict(torch.load(path, weights_only=True))
    return net.eval()


def sanitized(net):
    seq = net.as_sequential()
    zeroed = 0
    with torch.no_grad():
        for m in seq:
            if isinstance(m, torch.nn.Linear):
                tiny = m.weight.abs() < REL_EPS * m.weight.abs().max()
                zeroed += int(tiny.sum())
                m.weight[tiny] = 0.0
    return seq, zeroed


def quantize(net, cfg, calib_bearings, X):
    c = r3.CONFIGS[cfg]
    s_x = r3.S_X[c["transform"]]
    seq0 = net.as_sequential()
    seq, zeroed = sanitized(net)
    Xcal = np.concatenate([r3.inputs(b, c) for b in calib_bearings])
    layers, scales = build(seq, Xcal, s_x)
    for L in layers:
        assert np.abs(L["bias"]).max() < 2 ** 31, "INT32 bias out of range"
    with torch.no_grad():
        t = torch.tensor(X, dtype=torch.float32)
        fp, fp_s = seq0(t).double().numpy()[:, 0], seq(t).double().numpy()[:, 0]
    Xq, C, real = mm.int8_forward(X, layers, scales, s_x)
    return {"layers": layers, "scales": scales, "s_x": s_x, "Xq": Xq, "fp": fp, "q": real[:, 0],
            "zeroed": zeroed, "fp_change_from_zeroing": float(np.abs(fp_s - fp).max())}


def compare(Q, e):
    y = r3.DATA[e]["y"]
    pf, pq = 1 / (1 + np.exp(-Q["fp"])), 1 / (1 + np.exp(-Q["q"]))
    ch = (pq > r3.THR) != (pf > r3.THR)
    lf, lq = r3.r2.latched(pf > r3.THR), r3.r2.latched(pq > r3.THR)
    ids = r3.DATA[e]["ids"]
    return {"rows": len(pf), "weights_zeroed": Q["zeroed"], "fp32_max_logit_change_from_zeroing": Q["fp_change_from_zeroing"],
            "logit_mean_abs_err": float(np.abs(Q["q"] - Q["fp"]).mean()), "logit_max_abs_err": float(np.abs(Q["q"] - Q["fp"]).max()),
            "prob_max_abs_err": float(np.abs(pq - pf).max()), "decisions_changed": int(ch.sum()),
            "decisions_changed_labelled": int((ch & ~np.isnan(y)).sum()),
            "latched_first_alarm_fp32": int(ids[np.argmax(lf)]) if lf.any() else None,
            "latched_first_alarm_int8": int(ids[np.argmax(lq)]) if lq.any() else None,
            "latched_states_differ": int((lf != lq).sum()), "rows_at_int8_input_rail": int((np.abs(Q["Xq"]) == 127).any(axis=1).sum())}


def export(Q, cfg, seed, folder):
    c = r3.CONFIGS[cfg]
    layers, scales = Q["layers"], Q["scales"]
    folder.mkdir(parents=True)
    for l, L in enumerate(layers):
        write_hex(folder / f"W{l}.hex", L["W"], 8)
        write_hex(folder / f"Bias{l}.hex", L["bias"], 32)
        write_hex(folder / f"Scl{l}.hex", (np.asarray(L["shift"]) << 16) | np.asarray(L["m0"]), 24)
    bias_last = [int(v) for v in scales[-1]["bias_last"]]
    lscale = float(scales[-1]["s_in"] * np.asarray(scales[-1]["s_w"])[0])
    quant = {"model": f"Machine Guardian MTL, training run 3, {cfg}, seed {seed}, trained on all 7 development bearings",
             "inputs": r3.td.NAMES, "input_transform": c["transform"],
             "transform_definition": "x = sign(z) * ln(1 + min(|z|, 1e4)) for every input" if c["transform"] == "slog" else "x = clip(z, -16, 16)",
             "x8_used": c["x8"], "x8_note": None if c["x8"] else "x8 (temperature residual) is fed as 0 on every row",
             "s_x": Q["s_x"], "sizes": [8, 32, 16, 2],
             "heads": ["deterioration_logit (trained)", "health_raw (UNTRAINED, frozen: never report)"],
             "dead_weights_zeroed_before_quantization": Q["zeroed"],
             "layers": [{"s_in": sc["s_in"], "s_w": np.asarray(sc["s_w"]).tolist(), **({"s_out": sc["s_out"]} if "s_out" in sc else {}),
                         "bias": L["bias"].tolist(), "m0": np.asarray(L["m0"]).tolist(), "shift": np.asarray(L["shift"]).tolist(),
                         "relu": L["relu"]} for L, sc in zip(layers, scales)],
             "bias_last": bias_last, "logit_scale_det": lscale,
             "decision": "p = sigmoid((C[0] + bias_last[0]) * logit_scale_det); alarm after 3 consecutive p > 0.5, then latched",
             "accumulator_bits": mm.ACC, "array": "8 x 8 systolic, tb_mlp.sv / mac_attack_accel_MLP"}
    (folder / "quant.json").write_text(json.dumps(quant, indent=1) + "\n", encoding="utf-8")
    hdr = [f"/* Machine Guardian multi-task MLP, training run 3 ({cfg}, seed {seed}); generated by run3_hardware.py.",
           " * 8 -> 32 -> 16 -> 2. INT8 weights K x N row-major, INT32 biases, per-channel (m0, shift) requantization.",
           " * Output column 0 = deterioration logit (trained). Column 1 = health index: UNTRAINED, never report it. */",
           "#pragma once", "#include <stdint.h>", f"#define MTL_S_X {Q['s_x']!r}f", f"#define MTL_BIAS_LAST_DET {bias_last[0]}",
           f"#define MTL_LOGIT_SCALE_DET {lscale!r}f", f"#define MTL_INPUT_{c['transform'].upper()} 1",
           f"#define MTL_USE_TEMPERATURE {int(c['x8'])}"]
    for l, L in enumerate(layers):
        hdr += [c_array("int8_t", f"MTL_W{l}", L["W"]), c_array("int32_t", f"MTL_B{l}", L["bias"])]
        if L["relu"]:
            hdr += [c_array("int32_t", f"MTL_M0_{l}", L["m0"]), c_array("int8_t", f"MTL_SHIFT_{l}", L["shift"])]
    (folder / "mtl_run3.h").write_text("\n".join(hdr) + "\n", encoding="utf-8")
    sel = np.linspace(0, len(Q["Xq"]) - 1, 64).astype(int)
    write_hex(folder / "vectors_X.hex", Q["Xq"][sel], 8)
    C, _ = r3.golden(Q["Xq"][sel], layers) if hasattr(r3, "golden") else __import__("mac").golden_mlp(Q["Xq"][sel], layers)
    write_hex(folder / "vectors_C.hex", C, 22)


def rtl(Q, n_batches):
    import rtl_check
    root = Path_tmp()
    try:
        sim = rtl_check.TempSimulator(root, "icarus")
        work = sim.build("tb_mlp", rtl_check.PARAMS)
        Xq = Q["Xq"]
        n = min(len(Xq) // 64, n_batches) * 64
        pick = Xq[np.linspace(0, len(Xq) - 1, n).astype(int)]
        bl = int(Q["scales"][-1]["bias_last"][0])
        g64, eq64, c64, _ = rtl_check.run(sim, work, Q["layers"], [pick[i:i + 64] for i in range(0, n, 64)], bl)
        g1, eq1, c1, _ = rtl_check.run(sim, work, Q["layers"], [Xq[[i]] for i in np.linspace(0, len(Xq) - 1, 10).astype(int)], bl)
        return {"simulator": "Icarus Verilog, tb_mlp.sv, rtl_check.PARAMS (P = 8, ACC = 22)",
                "M64": {"pass": bool(g64), "batches": n // 64, "cycles": sorted(c64), "equation_cycles": eq64[3]},
                "M1": {"pass": bool(g1), "batches": 10, "cycles": sorted(c1), "equation_cycles": eq1[3]},
                "latency_us_at_214.286MHz": {"M64_per_batch": sorted(c64)[0] / FCLK_MHZ, "M1": sorted(c1)[0] / FCLK_MHZ}}
    finally:
        shutil.rmtree(root, ignore_errors=True)


def Path_tmp():
    from pathlib import Path
    return Path(tempfile.mkdtemp(prefix="mg_run3_rtl2_"))


def main():
    if HW.exists() or EXPORT2.exists():
        raise SystemExit(f"{HW} or {EXPORT2} exists: not overwritten")
    r3.load_data()
    R = json.loads((r3.OUT / "results.json").read_text())
    HW.mkdir(parents=True)
    rows, keep = [], {}
    for cfg in r3.CONFIGS:
        for o in r3.BEARINGS:
            train = [b for b in r3.BEARINGS if b != o]
            for s in r3.SEEDS:
                Q = quantize(load(r3.OUT / "models" / cfg / f"fold_{o}_seed{s}.pt", s), cfg, train, r3.inputs(o, r3.CONFIGS[cfg]))
                rows.append({"cfg": cfg, "held_out": o, "seed": s, **compare(Q, o)})
                if s == 0 and (cfg == r3.PRIMARY or cfg == R["nested"][o]["selected"]):
                    keep[(cfg, o)] = Q
    outer = pd.DataFrame(rows)
    outer.to_csv(HW / "int8_outer.csv", index=False, float_format="%.6g")
    fcfg = R["final_cfg"]
    final_rows, Qf = [], {}
    Xall = np.concatenate([r3.inputs(e, r3.CONFIGS[fcfg]) for e in r3.BEARINGS])
    for s in r3.SEEDS:
        net = load(r3.OUT / "models" / "FINAL" / f"{fcfg}_all7_seed{s}.pt", s)
        for e in r3.BEARINGS:
            Q = quantize(net, fcfg, r3.BEARINGS, r3.inputs(e, r3.CONFIGS[fcfg]))
            final_rows.append({"cfg": fcfg, "seed": s, "bearing": e, **compare(Q, e)})
        Qf[s] = quantize(net, fcfg, r3.BEARINGS, Xall)
        export(Qf[s], fcfg, s, EXPORT2 / f"seed{s}")
    pd.DataFrame(final_rows).to_csv(HW / "int8_final_in_sample.csv", index=False, float_format="%.6g")
    hw = {"final_seed0": rtl(Qf[0], 24), "outer_seed0": {}}
    for (cfg, o), Q in keep.items():
        hw["outer_seed0"][f"{cfg}/{o}"] = rtl(Q, 9)
    summary = {"fix": __doc__.split("Why v2:")[1].split("Checks per network")[0].strip(),
               "outer_models": len(outer), "outer_decisions_changed_total": int(outer.decisions_changed.sum()),
               "outer_rows_total": int(outer.rows.sum()), "outer_labelled_decisions_changed": int(outer.decisions_changed_labelled.sum()),
               "outer_latched_first_alarm_same": int((outer.latched_first_alarm_fp32.fillna(-1) == outer.latched_first_alarm_int8.fillna(-1)).sum()),
               "outer_max_fp32_change_from_zeroing": float(outer.fp32_max_logit_change_from_zeroing.max()),
               "outer_models_with_zeroed_weights": int((outer.weights_zeroed > 0).sum()),
               "per_cfg": outer.groupby("cfg")[["decisions_changed", "decisions_changed_labelled", "latched_states_differ"]].sum().to_dict(),
               "rtl": hw, "all_rtl_pass": all(v["M64"]["pass"] and v["M1"]["pass"] for v in [hw["final_seed0"], *hw["outer_seed0"].values()]),
               "exported": str(EXPORT2), "final_cfg": fcfg,
               "v1_note": "results/supervised/run3/train/results.json 'int8' entries and export/MTL_run3/ are v1 (before the fix); "
                          "use this folder's numbers"}
    (HW / "hardware.json").write_text(json.dumps(summary, indent=1, default=str) + "\n", encoding="utf-8")
    print(json.dumps({k: v for k, v in summary.items() if k not in ("rtl", "fix")}, indent=1, default=str))
    print("RTL all pass:", summary["all_rtl_pass"], {k: (v["M64"]["cycles"], v["M1"]["cycles"]) for k, v in [("final", hw["final_seed0"])]})


if __name__ == "__main__":
    main()
