"""Tiny-TPU RSCL model (INT4 8-4-2) -> the MAC Attack accelerator's interface (mac_attack_accel_MLP_TinyTPU).

Reads the professor's INT4 package and golden vectors (tinytpu/model/src/pipeline.py outputs) and writes:
  * tinytpu_model.h         the C header for the ARM test apps: MAC_model_TinyTPU (MAC Attack accelerator) and,
                            the same file, tinytpu/fpga_zed_v2/sw/ and tinytpu/fpga_zed/sw/tinytpu_model.h
                            (Tiny-TPU V2 and V1, tinytpu_model_test.c)
  * tinytpu_vectors_pkg.sv  the same data as a SystemVerilog package for the Vivado testbench tb_tinytpu.sv

The model runs on the accelerator in two ways, both checked by the testbench and the ARM app:

  Host mode (the professor's contract, 'rscl-int4-host-postprocess-v1'): the array does each layer's
    multiply-adds as a plain multiply (C = A x B); the host dequantizes, adds the float bias, applies ReLU
    and requantizes to INT4 between layers. Every sum must equal the golden 'expected_acc' values.

  On-chip mode: the whole model in one run of the on-chip MLP (mlp_ctrl). The float step between the
    layers becomes integers: y = clamp(((acc + B0) * m0 + 2^(shift-1)) >> shift, 0, 127) with
    B0 = round(b0 / (s_a0 s_w0)) and m0 / 2^shift = s_a0 s_w0 / s_a1. Two known differences from the
    contract: the bias is rounded to a whole accumulator step, and the hardware clamps hidden values at
    127, not at 7. The script checks how many rows that changes (none of the 12 golden rows).

Inputs are INT4 values in [-7, 7] in INT8 bytes; weights the same. The 12 golden rows come first; 52 more
rows of random INT4 inputs (fixed seed) follow, so the test also covers the faulty class and hidden values
above 7. Expected values for those rows come from the same contract (host mode) and the integer path
(on-chip mode), computed here.

Usage (from the repo root):
  python tinytpu/mac_mlp/export_mac_mlp.py
  python tinytpu/mac_mlp/export_mac_mlp.py --package path/int4_package.json --vectors path/golden_vectors.json
"""
import argparse
import json
from pathlib import Path

import numpy as np

ROOT = Path(__file__).resolve().parents[2]
PROJ = ROOT / "mac_attack_accel_MLP_TinyTPU" / "zed"
DEF_PKG = ROOT / "tinytpu" / "chip" / "test" / "int4_package.json"
DEF_VEC = ROOT / "tinytpu" / "chip" / "test" / "golden_vectors.json"
DEF_H = PROJ / "mac_zed_project" / "mac_zed.sdk" / "MAC_model_TinyTPU" / "src" / "tinytpu_model.h"
DEF_SV = PROJ / "tinytpu_vectors_pkg.sv"
DEF_H_V2 = ROOT / "tinytpu" / "fpga_zed_v2" / "sw" / "tinytpu_model.h"     # the same header for the Tiny-TPU V2 board app
DEF_H_V1 = ROOT / "tinytpu" / "fpga_zed" / "sw" / "tinytpu_model.h"        # and for the Tiny-TPU V1 board app
ROWS, EXTRA_SEED = 64, 20261116


def quant4(a, scale):
    """pipeline.py quant4: round to nearest, ties to even, clamp to [-7, 7]."""
    return np.clip(np.rint(np.asarray(a, dtype=np.float64) / scale), -7, 7).astype(np.int64)


def contract(x4, p):
    """The professor's infer_int4 from already-quantized inputs: layer-0 sums, hidden INT4, layer-1 sums, logits."""
    sa0, sa1 = p["activation_scales"]
    sw0, sw1 = p["weight_scales"]
    w0, w1 = np.array(p["weights"][0]), np.array(p["weights"][1])      # N x K, as pipeline.py stores them
    b0, b1 = p["biases"]
    acc0 = [int(sum(int(a) * int(w) for a, w in zip(x4, row))) for row in w0]
    h = [max(s * sa0 * sw0 + b0[j], 0.0) for j, s in enumerate(acc0)]   # same order of operations as pipeline.py
    h4 = quant4(h, sa1)
    acc1 = [int(sum(int(a) * int(w) for a, w in zip(h4, row))) for row in w1]
    logits = [s * sa1 * sw1 + b1[j] for j, s in enumerate(acc1)]
    for s in acc0 + acc1:
        assert -32768 <= s <= 32767, "INT16 accumulator overflow in the contract"
    return acc0, [int(v) for v in h4], acc1, logits


def chip_scale(p):
    """Layer 0's integer bias and (m0, shift) for postproc.sv: m0 in [2^15, 2^16), shift 1..48."""
    sa0, sa1 = p["activation_scales"]
    sw0, _ = p["weight_scales"]
    r = sa0 * sw0 / sa1
    bias = [int(round(b / (sa0 * sw0))) for b in p["biases"][0]]
    sh = 1
    while sh < 48 and round(r * 2 ** sh) < 32768:
        sh += 1
    m0 = int(round(r * 2 ** sh))
    assert 32768 <= m0 <= 65535 and 1 <= sh <= 48, (m0, sh)
    return bias, m0, sh


def chip(x4, p, bias, m0, sh):
    """The on-chip MLP, bit for bit (rtl/postproc.sv with ReLU, then the last layer's raw sums)."""
    w0, w1 = np.array(p["weights"][0]), np.array(p["weights"][1])
    acc0 = [int(sum(int(a) * int(w) for a, w in zip(x4, row))) for row in w0]
    h = [min(max(((s + bias[j]) * m0 + (1 << (sh - 1))) >> sh, 0), 127) for j, s in enumerate(acc0)]
    acc1 = [int(sum(int(a) * int(w) for a, w in zip(h, row))) for row in w1]
    return h, acc1


def logits_of(acc1, p):
    sa1, sw1, b1 = p["activation_scales"][1], p["weight_scales"][1], p["biases"][1]
    return [s * sa1 * sw1 + b1[j] for j, s in enumerate(acc1)]


def build(pkg_path, vec_path):
    p = json.loads(Path(pkg_path).read_text())
    g = json.loads(Path(vec_path).read_text())
    assert p["format"] == "rscl-int4-host-postprocess-v1" and p["model"] == [8, 4, 2], (p["format"], p["model"])
    sa0 = p["activation_scales"][0]
    rows = [quant4(v["input_features_normalized"], sa0) for v in g]
    true_cls = [int(v["true_class"]) for v in g]
    rng = np.random.default_rng(EXTRA_SEED)
    while len(rows) < ROWS:
        rows.append(rng.integers(-7, 8, size=8))
        true_cls.append(-1)
    bias, m0, sh = chip_scale(p)
    d = {"x": [], "acc0": [], "h": [], "acc1": [], "cls": [], "logit": [], "hc": [], "acc1c": [], "clsc": []}
    for i, x in enumerate(rows):
        acc0, h4, acc1, lg = contract(x, p)
        if i < len(g):                                 # the golden file must agree with this re-run of the contract
            exp = [c["expected_acc"] for c in g[i]["commands"] if c["op"] == "READ"]
            assert exp == acc0 + acc1, (i, exp, acc0 + acc1)
            assert int(np.argmax(lg)) == g[i]["expected_class"], i
            assert np.allclose(lg, g[i]["expected_logits"], rtol=0, atol=1e-12), (i, lg, g[i]["expected_logits"])
        hc, acc1c = chip(x, p, bias, m0, sh)
        d["x"].append([int(v) for v in x]); d["acc0"].append(acc0); d["h"].append(h4); d["acc1"].append(acc1)
        d["cls"].append(int(np.argmax(lg))); d["logit"].append(lg)
        d["hc"].append(hc); d["acc1c"].append(acc1c); d["clsc"].append(int(np.argmax(logits_of(acc1c, p))))
    diff_rows = [i for i in range(ROWS) if d["hc"][i] != d["h"][i]]
    assert not [i for i in diff_rows if i < len(g)], "on-chip integer path differs from the contract on a golden row"
    return p, g, d, bias, m0, sh, true_cls, diff_rows


def c_arr(ctype, name, vals, per_line=16):
    flat = [str(v) for v in np.asarray(vals).ravel().tolist()]
    lines = [", ".join(flat[i:i + per_line]) for i in range(0, len(flat), per_line)]
    return f"static const {ctype} {name}[{len(flat)}] = {{\n    " + ",\n    ".join(lines) + "\n};\n"


def c_dbl(name, vals):
    return f"static const double {name}[{len(vals)}] = {{" + ", ".join(repr(float(v)) for v in vals) + "};\n"


def write_c(path, p, g, d, bias, m0, sh, true_cls, diff_rows, src):
    sa0, sa1 = p["activation_scales"]
    sw0, sw1 = p["weight_scales"]
    w0t = np.array(p["weights"][0]).T                  # K x N, the order LOAD_DATA streams B in
    w1t = np.array(p["weights"][1]).T
    out = [
        f"/* Tiny-TPU RSCL model (INT4 8 -> 4 -> 2) for the MAC Attack accelerator, generated by",
        f" * tinytpu/mac_mlp/export_mac_mlp.py from {src}. Do not edit: rerun the script.",
        f" * Labels: 0 = {p['labels'][0]}, 1 = {p['labels'][1]}. Rows 0-{len(g) - 1}: the golden vectors; rows {len(g)}-{ROWS - 1}:",
        f" * random INT4 inputs (seed {EXTRA_SEED}). Rows where the on-chip integer path differs from the contract",
        f" * (hidden value above 7, which the chip does not clamp): {diff_rows if diff_rows else 'none'}. */",
        "#pragma once", "#include <stdint.h>", "",
        f"#define MT_ROWS   {ROWS}", f"#define MT_GOLDEN {len(g)}", "#define MT_K0 8", "#define MT_N0 4", "#define MT_N1 2", "",
        "/* Host mode (the professor's contract): h = ReLU(acc0 * S_A0 * S_W0 + B0F); h4 = clamp(rint_even(h / S_A1), -7, 7);",
        " * logit = acc1 * S_A1 * S_W1 + B1F. Double precision, in this order, as pipeline.py does it. */",
        f"#define MT_S_A0 {sa0!r}", f"#define MT_S_A1 {sa1!r}", f"#define MT_S_W0 {sw0!r}", f"#define MT_S_W1 {sw1!r}",
        c_dbl("MT_B0F", p["biases"][0]), c_dbl("MT_B1F", p["biases"][1]),
        "/* Weights K x N, row order (LOAD_DATA order for B) */",
        c_arr("int8_t", "MT_W0", w0t, 4), c_arr("int8_t", "MT_W1", w1t, 2),
        "/* On-chip mode, layer 0's postproc: y = clamp(((acc + MT_BIAS0[j]) * MT_M0 + 2^(MT_SHIFT-1)) >> MT_SHIFT, 0, 127) */",
        c_arr("int32_t", "MT_BIAS0", bias), f"#define MT_M0    {m0}u", f"#define MT_SHIFT {sh}u", "",
        "/* Test rows: INT4 inputs, then what each mode must give */",
        c_arr("int8_t", "MT_X", d["x"], 8),
        "/* host mode: layer-0 sums, hidden INT4, layer-1 sums, class (golden rows: equal to golden_vectors.json) */",
        c_arr("int32_t", "MT_ACC0", d["acc0"], 8), c_arr("int8_t", "MT_H", d["h"], 8),
        c_arr("int32_t", "MT_ACC1", d["acc1"], 8), c_arr("int8_t", "MT_CLS", d["cls"], 16),
        "/* logits x 1e6, rounded, for printing only */",
        c_arr("int32_t", "MT_LOGIT_U", [[int(round(v * 1e6)) for v in r] for r in d["logit"]], 8),
        "/* on-chip mode: the last layer's raw sums and the class the host makes of them */",
        c_arr("int32_t", "MT_ACC1C", d["acc1c"], 8), c_arr("int8_t", "MT_CLSC", d["clsc"], 16),
        "/* true class of the golden rows (-1 for the random rows) */",
        c_arr("int8_t", "MT_TRUE", true_cls, 16),
    ]
    Path(path).parent.mkdir(parents=True, exist_ok=True)
    Path(path).write_text("\n".join(out))


def sv_arr(name, vals, width=32):
    flat = [int(v) for v in np.asarray(vals).ravel().tolist()]
    body = ", ".join(str(v) for v in flat)
    return f"    localparam int {name} [{len(flat)}] = '{{{body}}};"


def write_sv(path, p, g, d, bias, m0, sh, diff_rows, src):
    sa1, sw1 = p["activation_scales"][1], p["weight_scales"][1]
    w0t = np.array(p["weights"][0]).T
    w1t = np.array(p["weights"][1]).T
    out = [
        "// Tiny-TPU RSCL model (INT4 8-4-2) and its test rows, for tb_tinytpu.sv.",
        f"// Generated by tinytpu/mac_mlp/export_mac_mlp.py from {src}. Do not edit: rerun the script.",
        "// Arrays are flat, row order: X[r*8+k], W0[k*4+j] (K x N), ACC0[r*4+j], H[r*4+j], ACC1[r*2+j] ...",
        "package tinytpu_vectors_pkg;",
        f"    localparam int ROWS = {ROWS}, GOLDEN = {len(g)}, K0 = 8, N0 = 4, N1 = 2;",
        f"    localparam int M0 = {m0}, SHIFT = {sh};",
        f"    localparam int CHIP_DIFF_ROWS = {len(diff_rows)};   // rows where hidden > 7 (the chip does not clamp at 7)",
        f"    localparam real S_A1 = {sa1!r}, S_W1 = {sw1!r};",
        f"    localparam real B1F [2] = '{{{p['biases'][1][0]!r}, {p['biases'][1][1]!r}}};",
        sv_arr("W0", w0t), sv_arr("W1", w1t), sv_arr("BIAS0", bias),
        sv_arr("X", d["x"]), sv_arr("ACC0", d["acc0"]), sv_arr("H", d["h"]), sv_arr("ACC1", d["acc1"]),
        sv_arr("CLS", d["cls"]), sv_arr("ACC1C", d["acc1c"]), sv_arr("CLSC", d["clsc"]),
        "endpackage",
        "",
    ]
    Path(path).write_text("\n".join(out))


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--package", default=str(DEF_PKG))
    ap.add_argument("--vectors", default=str(DEF_VEC))
    ap.add_argument("--out-h", default=str(DEF_H))
    ap.add_argument("--out-sv", default=str(DEF_SV))
    ap.add_argument("--out-h-v2", default=str(DEF_H_V2), help="second copy of the header (Tiny-TPU V2 board app)")
    ap.add_argument("--out-h-v1", default=str(DEF_H_V1), help="third copy of the header (Tiny-TPU V1 board app)")
    a = ap.parse_args()
    p, g, d, bias, m0, sh, true_cls, diff_rows = build(a.package, a.vectors)
    src = Path(a.package).resolve().relative_to(ROOT).as_posix() if Path(a.package).resolve().is_relative_to(ROOT) else a.package
    write_c(a.out_h, p, g, d, bias, m0, sh, true_cls, diff_rows, src)
    write_c(a.out_h_v2, p, g, d, bias, m0, sh, true_cls, diff_rows, src)
    write_c(a.out_h_v1, p, g, d, bias, m0, sh, true_cls, diff_rows, src)
    write_sv(a.out_sv, p, g, d, bias, m0, sh, diff_rows, src)
    print(f"golden rows: {len(g)} (all re-computed sums, logits and classes match golden_vectors.json)")
    print(f"layer 0 on chip: bias {bias}, m0 {m0}, shift {sh}  (scale {m0 / 2 ** sh:.9f})")
    print(f"rows where the on-chip path differs from the contract: {len(diff_rows)} {diff_rows}")
    print(f"classes, host mode: {sum(d['cls'])} x {p['labels'][1]}, {ROWS - sum(d['cls'])} x {p['labels'][0]}; "
          f"on-chip class differs on {sum(a != b for a, b in zip(d['cls'], d['clsc']))} rows")
    print(f"wrote {a.out_h}\nwrote {a.out_h_v2}\nwrote {a.out_h_v1}\nwrote {a.out_sv}")


if __name__ == "__main__":
    main()
