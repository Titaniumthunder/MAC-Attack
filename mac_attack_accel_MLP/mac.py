#!/usr/bin/env python3
"""MAC Attack accelerator: run the hardware simulation from one terminal command and
check every answer against NumPy.

  python mac.py multiply 16 16 16              16x16 times 16x16, random INT8 values
  python mac.py multiply 3 4 2 --a A.txt --b B.txt --show
  python mac.py compare 64 64 64               same matrices on 4x4, 8x8 and 16x16 arrays
  python mac.py test                           edge-case suite on several array sizes
  python mac.py saturate                       overflow versus saturation (16-bit accumulators)
  python mac.py postproc                       bias + requantize + ReLU unit
  python mac.py mlp                            on-chip MLP: whole models, every number checked
  python mac.py uart 8 8 8                     whole chip, driven over a simulated serial line
  python mac.py board 16 16 16 --port COM5     same, with the real Arty board (later)

Common options:  --P 16 (array size)   --sim vivado|icarus   --seed 1   --vivado-bin <folder>

Vivado: run from a terminal where Vivado's bin folder is on PATH (or pass --vivado-bin).
Icarus: install Icarus Verilog 12 or newer and make sure iverilog and vvp are on PATH.
"""
import argparse, glob, math, os, shutil, subprocess, sys, time
from pathlib import Path

import numpy as np

ROOT = Path(__file__).resolve().parent
RTL = ["rtl/delay_line.sv", "rtl/pe.sv", "rtl/systolic_array.sv", "rtl/mm_core.sv",
       "rtl/postproc.sv", "rtl/mlp_ctrl.sv", "rtl/uart_rx.sv", "rtl/uart_tx.sv", "rtl/host_if.sv",
       "rtl/chip_top.sv"]
TB = {"tb_mm": "tb/tb_mm.sv", "tb_postproc": "tb/tb_postproc.sv", "tb_chip": "tb/tb_chip.sv",
      "tb_mlp": "tb/tb_mlp.sv"}
MAXD = 64


# ------------------------------------------------------------------ simulators
def find_vivado(user_bin):
    exe = "xvlog.bat" if os.name == "nt" else "xvlog"
    if user_bin:
        return Path(user_bin) if (Path(user_bin) / exe).exists() else None
    hit = shutil.which("xvlog")
    if hit:
        return Path(hit).parent
    pats = ["C:/Xilinx/Vivado/*/bin", "C:/AMDDesignTools/*/Vivado/bin",
            "/tools/Xilinx/Vivado/*/bin", "/opt/Xilinx/Vivado/*/bin"]
    if os.environ.get("XILINX_VIVADO"):
        pats.insert(0, os.environ["XILINX_VIVADO"] + "/bin")
    for pat in pats:
        for d in sorted(glob.glob(pat), reverse=True):        # newest version first
            if (Path(d) / exe).exists():
                return Path(d)
    return None


class Simulator:
    """Compiles a testbench once per parameter set, then runs it as often as needed."""

    def __init__(self, kind, vivado_bin=None):
        self.vbin = None
        if kind in ("auto", "vivado"):
            self.vbin = find_vivado(vivado_bin)
            if self.vbin:
                kind = "vivado"
            elif kind == "vivado":
                sys.exit("Vivado not found. Open a terminal where Vivado's bin folder is on PATH "
                         "(run settings64.bat on Windows), or pass --vivado-bin <folder>.")
        if kind == "auto":
            if shutil.which("iverilog") and shutil.which("vvp"):
                kind = "icarus"
            else:
                sys.exit("No simulator found. Install Vivado or Icarus Verilog (iverilog, vvp).")
        self.kind = kind
        self.built = {}

    @property
    def name(self):
        return "Vivado simulator (xsim)" if self.kind == "vivado" else "Icarus Verilog"

    def _tool(self, name):
        if self.kind == "vivado":
            return str(self.vbin / (name + (".bat" if os.name == "nt" else "")))
        return name

    def _call(self, cmd, cwd, what):
        try:
            r = subprocess.run(cmd, cwd=cwd, capture_output=True, text=True)
        except OSError as e:
            sys.exit(f"Could not start {cmd[0]}: {e}")
        if r.returncode != 0:
            print((r.stdout + r.stderr)[-3000:])
            sys.exit(f"{what} failed (see the messages above).")
        return r.stdout

    def build(self, top, params):
        key = (top, tuple(sorted(params.items())))
        if key in self.built:
            return self.built[key]
        tag = "_".join(f"{k}{v}" for k, v in sorted(params.items()))
        work = ROOT / "run" / f"{self.kind}_{top}_{tag}"
        work.mkdir(parents=True, exist_ok=True)
        files = [str(ROOT / f) for f in RTL + [TB[top]]]
        if self.kind == "icarus":
            cmd = ["iverilog", "-g2012", "-s", top, "-o", "sim.vvp"]
            cmd += [f"-P{top}.{k}={v}" for k, v in params.items()] + files
            self._call(cmd, work, "Compiling")
        else:
            self._call([self._tool("xvlog"), "-sv"] + files, work, "Compiling (xvlog)")
            cmd = [self._tool("xelab"), top, "-s", "snap"]
            for k, v in params.items():
                cmd += ["-generic_top", f"{k}={v}"]
            self._call(cmd, work, "Elaborating (xelab)")
        self.built[key] = work
        return work

    def run(self, work, plusargs):
        if self.kind == "icarus":
            cmd = ["vvp", "-n", "sim.vvp"] + [f"+{k}={v}" for k, v in plusargs.items()]
        else:
            cmd = [self._tool("xsim"), "snap", "-R"]
            for k, v in plusargs.items():
                cmd += ["-testplusarg", f"{k}={v}"]
        out = self._call(cmd, work, "Simulation")
        if "ERROR" in out or "TB_DONE" not in out:
            print(out[-2000:])
            sys.exit("The simulation reported an error.")
        return out


# ------------------------------------------------------------------ helpers
def to_signed(v, bits):
    v = np.asarray(v, dtype=np.int64) & ((1 << bits) - 1)
    return np.where(v >= (1 << (bits - 1)), v - (1 << bits), v)


def write_hex(path, values, bits):
    digits = (bits + 3) // 4
    mask = (1 << bits) - 1
    Path(path).write_text("".join(f"{int(v) & mask:0{digits}x}\n" for v in np.ravel(values)))


def read_hex(path, bits):
    """Unknown values (x or z from the simulator) become a number no real result can equal."""
    vals = Path(path).read_text().split()
    if any(not all(ch in "0123456789abcdefABCDEF" for ch in v) for v in vals):
        good = [all(ch in "0123456789abcdefABCDEF" for ch in v) for v in vals]
        nums = to_signed([int(v, 16) if g else 0 for v, g in zip(vals, good)], bits)
        return np.where(good, nums, -(1 << 62))
    return to_signed([int(v, 16) for v in vals], bits)


def golden(A, B, P, acc, sat):
    """What the hardware must produce, bit for bit.
    Wrapping accumulators give the exact sum modulo 2^acc. Saturating accumulators clamp
    after every addition, in the same order as the hardware: down each column of a tile
    (row 0 first), then across tiles."""
    A, B = A.astype(np.int64), B.astype(np.int64)
    if not sat:
        return to_signed(A @ B, acc)
    lo, hi = -(1 << (acc - 1)), (1 << (acc - 1)) - 1
    M, K = A.shape
    C = None
    for kb in range(math.ceil(K / P)):
        s = np.zeros((M, B.shape[1]), dtype=np.int64)
        for k in range(kb * P, min(K, kb * P + P)):
            s = np.clip(s + np.outer(A[:, k], B[k, :]), lo, hi)
        C = s if C is None else np.clip(C + s, lo, hi)
    return C


def requantize(acc, bias, m0, shift, relu, obits=8):
    """What postproc.sv computes, bit for bit (NumPy arrays broadcast):
        y = clamp( ((acc + bias) * m0 + 2^(shift-1)) >> shift,  relu ? 0 : -2^(obits-1),  2^(obits-1) - 1 )
    Halves round up (toward +infinity): this is NOT PyTorch's or TFLite's rounding, so a
    quantized model must be exported and checked with this function. shift must be 1 .. 48,
    m0 0 .. 65535 (unsigned), bias a 32-bit integer."""
    acc, bias = np.asarray(acc, np.int64), np.asarray(bias, np.int64)
    m0, shift = np.asarray(m0, np.int64), np.asarray(shift, np.int64)
    if np.any((shift < 1) | (shift > 48)):
        raise ValueError("shift must be 1 .. 48")
    y = ((acc + bias) * m0 + np.left_shift(np.int64(1), shift - 1)) >> shift
    lo = np.where(np.asarray(relu, bool), 0, -(1 << (obits - 1)))
    return np.minimum(np.maximum(y, lo), (1 << (obits - 1)) - 1)


def scale_to_m0_shift(scale):
    """A real scale (for example S_in * S_w / S_out) as m0 / 2^shift, with m0 in 32768 .. 65535
    when the scale allows it (most precision). Returns (m0, shift) with shift in 1 .. 48."""
    scale = float(scale)
    if scale <= 0:
        return 0, 1
    shift = 15 - math.floor(math.log2(scale))          # puts scale * 2^shift in [2^15, 2^16)
    shift = min(max(shift, 1), 48)
    m0 = int(round(scale * (1 << shift)))
    if m0 > 65535:                                      # rounding up to 2^16: one bit less
        shift = max(shift - 1, 1)
        m0 = int(round(scale * (1 << shift)))
    return min(m0, 65535), shift


def golden_mlp(X, layers, acc=22, bits=8):
    """The on-chip MLP (rtl/mlp_ctrl.sv), bit for bit.
      X        M x K0 inputs (INT8)
      layers   list of dicts: W (K_l x N_l, INT8), bias, m0, shift (N_l values each), relu (bool)
               K_0 = X's columns, K_l = N_(l-1)
    For every layer but the last:  A <- requantize(A @ W_l, bias, m0, shift, relu)  (INT8)
    The last layer stops at the raw sums C = A @ W_last (what the result port returns); the ARM
    adds that layer's bias: logits = C + bias_last.
    Returns (C, acts): acts[l] = the INT8 input of layer l + 1 (what the writeback wrote into A)."""
    a = np.asarray(X, np.int64)
    acts = []
    for l, L in enumerate(layers):
        C = to_signed(a @ np.asarray(L["W"], np.int64), acc)   # exact for INT8 with ACC >= 2*8 + log2(K)
        if l == len(layers) - 1:
            return C, acts
        a = requantize(C, np.asarray(L["bias"])[None, :], np.asarray(L["m0"])[None, :],
                       np.asarray(L["shift"])[None, :], L["relu"], bits)
        acts.append(a)


def pp_stages(ppipe):
    """postproc.sv's latency for its PPIPE setting: 0 -> 3 stages, 1 -> 7, 2 -> 9 (for 250 MHz)."""
    return 3 if ppipe == 0 else 7 if ppipe == 1 else 9


def mlp_equation(P, M, Ks, Ns, pipe=2, mem_reg=2, hread=1, ppipe=2, lanes=None):
    """Counters after a model run: (passes, cycles in passes, core busy cycles, model cycles).
    Per layer: Np = ceil(K/P) * ceil(N/P) passes of M + 3P - 2 cycles, plus 3 + PIPE + MEM_REG
    busy cycles; mlp_ctrl adds 3 clocks per layer (set up, start, done) and, between layers, one
    clock per writeback step (M * ceil(N/P) * P/lanes) plus the drain (RL + PPD + 1)."""
    lanes = lanes or P
    S = P // lanes
    drain = (1 + hread) + pp_stages(ppipe)
    passes = cycles = total = model = 0
    for l, (K, N) in enumerate(zip(Ks, Ns)):
        npass = math.ceil(K / P) * math.ceil(N / P)
        t = npass * (M + 3 * P - 2) + 3 + pipe + mem_reg
        passes += npass
        cycles += npass * (M + 3 * P - 2)
        total += t
        model += t + 3
        if l < len(Ks) - 1:
            model += M * math.ceil(N / P) * S + drain + 1
    return passes, cycles, total, model


def make_data(kind, M, K, N, bits, rng):
    lo, hi = -(1 << (bits - 1)), (1 << (bits - 1)) - 1
    if kind == "random":
        return rng.integers(lo, hi + 1, (M, K)), rng.integers(lo, hi + 1, (K, N))
    if kind == "ones":
        return np.ones((M, K), int), np.ones((K, N), int)
    if kind == "max":
        return np.full((M, K), hi), np.full((K, N), hi)
    if kind == "min":
        return np.full((M, K), lo), np.full((K, N), lo)
    if kind == "identity":
        return rng.integers(lo, hi + 1, (M, K)), np.eye(K, N, dtype=int)
    if kind == "small":
        return rng.integers(-9, 10, (M, K)), rng.integers(-9, 10, (K, N))
    raise ValueError(kind)


def load_matrix(path):
    return np.loadtxt(path, dtype=np.int64, delimiter=None if path.endswith(".txt") else ",", ndmin=2)


def fmt(mat, maxr=8, maxc=8):
    r, c = mat.shape
    width = max(len(str(int(v))) for v in np.ravel(mat[:maxr, :maxc])) + 1
    lines = []
    for i in range(min(r, maxr)):
        row = "".join(f"{int(v):>{width}}" for v in mat[i, :maxc])
        lines.append("    " + row + ("  ..." if c > maxc else ""))
    if r > maxr:
        lines.append("    " + "...".rjust(width))
    return "\n".join(lines)


def equation(P, M, K, N):
    passes = math.ceil(K / P) * math.ceil(N / P)
    return passes, passes * (M + 3 * P - 2)


def check_dims(*d):
    for v in d:
        if not 1 <= v <= MAXD:
            sys.exit(f"Matrix sizes must be between 1 and {MAXD}.")


def run_mm(sim, P, A, B, bits=8, acc=32, sat=0):
    """Load A and B into the hardware model, run it, and return C plus the counters."""
    M, K = A.shape
    N = B.shape[1]
    work = sim.build("tb_mm", {"P": P, "BITS": bits, "ACC": acc, "SAT": int(sat)})
    write_hex(work / "A.hex", A, bits)
    write_hex(work / "B.hex", B, bits)
    for f in ("C.hex", "stats.txt"):
        (work / f).unlink(missing_ok=True)
    t0 = time.time()
    sim.run(work, {"M": M, "K": K, "N": N})
    C = read_hex(work / "C.hex", acc).reshape(M, N)
    passes, cycles, total = map(int, (work / "stats.txt").read_text().split())
    return C, passes, cycles, total, time.time() - t0


def ok(flag):
    return "PASS" if flag else "FAIL"


# ------------------------------------------------------------------ commands
def cmd_multiply(a, sim):
    rng = np.random.default_rng(a.seed)
    if a.a or a.b:
        if not (a.a and a.b):
            sys.exit("Give both --a and --b.")
        A, B = load_matrix(a.a), load_matrix(a.b)
        if A.shape[1] != B.shape[0]:
            sys.exit(f"A is {A.shape[0]}x{A.shape[1]} and B is {B.shape[0]}x{B.shape[1]}: "
                     "the columns of A must equal the rows of B.")
        lo, hi = -(1 << (a.bits - 1)), (1 << (a.bits - 1)) - 1
        if A.min() < lo or A.max() > hi or B.min() < lo or B.max() > hi:
            sys.exit(f"INT{a.bits} values must be between {lo} and {hi}.")
        M, K, N = A.shape[0], A.shape[1], B.shape[1]
        source = f"{a.a}, {a.b}"
    else:
        M, K, N = a.M, a.K, a.N
        A, B = make_data(a.data, M, K, N, a.bits, rng)
        source = f"{a.data} values, seed {a.seed}" if a.data in ("random", "identity", "small") else f"{a.data} values"
    check_dims(M, K, N)

    print(f"\nMAC Attack accelerator: {a.P}x{a.P} systolic array ({a.P*a.P} PEs), INT{a.bits}, "
          f"{a.acc}-bit accumulators{', saturating' if a.sat else ''}")
    print(f"A is {M}x{K}, B is {K}x{N} ({source})")
    print(f"Running the hardware model on {sim.name} ...", flush=True)
    C, passes, cycles, total, secs = run_mm(sim, a.P, A, B, a.bits, a.acc, a.sat)
    ref = golden(A, B, a.P, a.acc, a.sat)
    eq_passes, eq_cycles = equation(a.P, M, K, N)
    match = int((C == ref).sum())
    macs = M * K * N

    if a.show or (M <= 8 and N <= 8 and K <= 8):
        print("\nA =\n" + fmt(A) + "\n\nB =\n" + fmt(B))
        print("\nC from the hardware =\n" + fmt(C) + "\n\nC from NumPy =\n" + fmt(ref))
    print(f"\n  {ok(match == M*N)}  {match}/{M*N} results match NumPy")
    print(f"  {ok(passes == eq_passes)}  passes = {passes:<6} equation: ceil({K}/{a.P}) x ceil({N}/{a.P}) = {eq_passes}")
    print(f"  {ok(cycles == eq_cycles)}  cycles = {cycles:<6} equation: passes x (M + 3P - 2) = {eq_passes} x {M + 3*a.P - 2} = {eq_cycles}")
    print(f"        {macs:,} multiply-adds; the {a.P*a.P} PEs were busy {100*macs/(a.P*a.P*cycles):.1f}% of the time")
    print(f"        {cycles/100:.2f} microseconds at 100 MHz ({total} cycles including start and finish)")
    print(f"        simulation took {secs:.1f} s\n")
    return match == M * N and cycles == eq_cycles


def cmd_compare(a, sim):
    M, K, N = a.M, a.K, a.N
    check_dims(M, K, N)
    rng = np.random.default_rng(a.seed)
    A, B = make_data(a.data, M, K, N, 8, rng)
    ref = golden(A, B, 1, 32, 0)
    print(f"\nSame {M}x{K} times {K}x{N} multiply ({a.data} INT8, seed {a.seed}) on different array sizes, {sim.name}\n")
    print(f"  {'array':>7} {'PEs':>5} {'passes':>7} {'cycles':>8} {'equation':>9} {'correct':>8} {'PEs busy':>9} {'speedup':>8}")
    base = None
    allok = True
    for P in a.sizes:
        C, passes, cycles, total, secs = run_mm(sim, P, A, B)
        eqp, eqc = equation(P, M, K, N)
        good = bool((C == ref).all()) and cycles == eqc
        allok &= good
        base = base or cycles
        print(f"  {f'{P}x{P}':>7} {P*P:>5} {passes:>7} {cycles:>8} {eqc:>9} {ok(good):>8} "
              f"{100*M*K*N/(P*P*cycles):>8.1f}% {base/cycles:>7.1f}x", flush=True)
    print("\n  More PEs finish in fewer cycles, but each pass also spends 3P - 2 cycles loading weights,")
    print("  filling and draining. So the speedup is less than the increase in PEs, and the share of time")
    print("  the PEs do useful work drops. Where that trade stops paying off is the project's research question.\n")
    return allok


def cmd_test(a, sim):
    print(f"\nTest suite on {sim.name}: every result compared with NumPy, every cycle count with the equation\n")
    total = passed = 0
    for P in a.sizes:
        cases = [(1, 1, 1, "random"), (P, P, P, "random"), (min(2 * P, 64),) * 3 + ("random",),
                 (64, 64, 64, "random"), (37, 50, 23, "random"), (1, 64, 64, "random"),
                 (64, 1, 64, "random"), (64, 64, 1, "random"), (5, 7, 3, "random"),
                 (16, 16, 16, "min"), (16, 16, 16, "max"), (16, 16, 16, "identity")]
        if a.quick:
            cases = cases[:2] + [cases[4], cases[9]]
        rng = np.random.default_rng(a.seed)
        fails = []
        for M, K, N, kind in cases:
            A, B = make_data(kind, M, K, N, 8, rng)
            C, passes, cycles, _, _ = run_mm(sim, P, A, B)
            good = bool((C == golden(A, B, P, 32, 0)).all()) and cycles == equation(P, M, K, N)[1]
            total += 1
            passed += good
            if not good:
                fails.append(f"{M}x{K}x{N} {kind}")
        print(f"  {P}x{P} array: {len(cases) - len(fails)}/{len(cases)} passed" +
              (f"   FAILED: {', '.join(fails)}" if fails else ""), flush=True)
    print(f"\n  {ok(passed == total)}  {passed}/{total} tests passed\n")
    return passed == total


def cmd_saturate(a, sim):
    P, acc = 4, 16
    print(f"\nOverflow versus saturation: {P}x{P} array, INT8 inputs, {acc}-bit accumulators "
          f"(largest value {2**(acc-1)-1:,})\n")
    A = np.full((4, 8), -128)
    B = np.full((8, 4), -128)
    true = A.astype(np.int64) @ B
    Cw, *_ = run_mm(sim, P, A, B, 8, acc, 0)
    Cs, *_ = run_mm(sim, P, A, B, 8, acc, 1)
    print(f"  Every input is -128, K = 8: each output is 8 x (-128 x -128) = {int(true[0, 0]):,}")
    print(f"  True answer (NumPy, no limit)        {int(true[0, 0]):>8,}")
    print(f"  Hardware, wrapping accumulator       {int(Cw[0, 0]):>8,}   matches Python model: "
          f"{ok((Cw == golden(A, B, P, acc, 0)).all())}")
    print(f"  Hardware, saturating accumulator     {int(Cs[0, 0]):>8,}   matches Python model: "
          f"{ok((Cs == golden(A, B, P, acc, 1)).all())}")
    print("\n  Wrapping turns 131,072 into 0, a completely wrong answer. Saturating stops at the largest")
    print("  16-bit value. It is still wrong, but by the least possible amount, and never flips sign.\n")

    rng = np.random.default_rng(a.seed)
    A, B = make_data("random", 32, 32, 32, 8, rng)
    true = A.astype(np.int64) @ B
    Cw, *_ = run_mm(sim, P, A, B, 8, acc, 0)
    Cs, *_ = run_mm(sim, P, A, B, 8, acc, 1)
    over = int((np.abs(true) > 2**(acc - 1) - 1).sum())
    print(f"  Random 32x32x32 INT8: {over} of {true.size} true answers do not fit in {acc} bits.")
    print(f"    wrapping:   {int((Cw != true).sum())} wrong, worst error {int(np.abs(Cw - true).max()):,}; "
          f"hardware = Python model {ok((Cw == golden(A, B, P, acc, 0)).all())}")
    print(f"    saturating: {int((Cs != true).sum())} wrong, worst error {int(np.abs(Cs - true).max()):,}; "
          f"hardware = Python model {ok((Cs == golden(A, B, P, acc, 1)).all())}")
    hidden = int(((Cs != true) & (np.abs(true) <= 2**(acc - 1) - 1)).sum())
    print(f"  Saturation also broke {hidden} results whose final value fits in {acc} bits: a partial sum")
    print("  overflowed along the way and was clamped. Wrapping gets those right, because the overflows")
    print("  cancel out. So saturation bounds the error but depends on the order of the additions.")
    print(f"  With 32-bit accumulators none of these overflow (K x 128 x 128 is at most {64*16384:,} for K = 64).\n")
    return True


def cmd_postproc(a, sim):
    rng = np.random.default_rng(a.seed)
    m0, sh = 16384, 22                  # scale m0 / 2^sh = 1/256
    n = 400
    acc = rng.integers(-40000, 40000, n)
    bias = rng.integers(-2000, 2000, n)
    # edge cases: zero, exact halves (rounding ties), and values far outside the output range
    acc[:8] = [0, 128, 384, -128, -384, 1 << 30, -(1 << 30), 255]
    bias[:8] = 0
    work = sim.build("tb_postproc", {})
    write_hex(work / "pp_acc.hex", acc, 32)
    write_hex(work / "pp_bias.hex", bias, 32)
    print(f"\nPost-processing unit (bias + requantize + ReLU), {n} values, {sim.name}")
    print(f"  y = clamp( round( (acc + bias) x {m0} / 2^{sh} ), lo, 127 )      scale = 1/256\n")
    allok = True
    outs = {}
    for relu in (1, 0):
        sim.run(work, {"N": n, "M0": m0, "SH": sh, "RELU": relu})
        hw = read_hex(work / "pp_out.hex", 8)
        lo = 0 if relu else -128
        ref = np.clip(((acc + bias) * m0 + (1 << (sh - 1))) >> sh, lo, 127)
        good = len(hw) == n and bool((hw == ref).all())
        allok &= good
        outs[relu] = hw
        print(f"  {ok(good)}  ReLU {'on ' if relu else 'off'}: {int((hw == ref).sum()) if len(hw) == n else 0}/{n} outputs match Python")
    print(f"\n  {'acc + bias':>14} {'exact value':>12} {'ReLU off':>9} {'ReLU on':>8}")
    for i in range(10):
        exact = (acc[i] + bias[i]) * m0 / 2**sh
        print(f"  {int(acc[i] + bias[i]):>14,} {exact:>12.2f} {int(outs[0][i]):>9} {int(outs[1][i]):>8}")
    print("\n  Halves round up (0.5 -> 1, 1.5 -> 2, -0.5 -> 0, -1.5 -> -1). Results outside -128..127")
    print("  are clamped, and ReLU clamps negatives to 0. One result per clock; 3 pipeline stages.\n")

    # One scale per output channel (on-chip MLP): m0, shift and ReLU change on every clock,
    # for every pipeline (3 stages, 7, and 9 for 250 MHz). Full input ranges.
    n = 2000
    acc = rng.integers(-(1 << 21), 1 << 21, n)          # 22-bit accumulators (the ZedBoard core)
    bias = rng.integers(-(1 << 31), 1 << 31, n)
    bias[n // 2:] = rng.integers(-3000, 3000, n - n // 2)
    m0 = rng.integers(0, 1 << 16, n)
    sh = rng.integers(1, 49, n)
    relu = rng.integers(0, 2, n)
    m0[:4], sh[:4] = [0, 65535, 1, 32768], [1, 48, 22, 15]
    print("  One scale per channel: m0, shift and ReLU different on every clock, full input ranges")
    for ppipe in (0, 1, 2):
        work = sim.build("tb_postproc", {"ACC": 22, "PPIPE": ppipe})
        write_hex(work / "pp_acc.hex", acc, 32)
        write_hex(work / "pp_bias.hex", bias, 32)
        write_hex(work / "pp_m0.hex", m0, 16)
        write_hex(work / "pp_shift.hex", sh, 8)
        write_hex(work / "pp_relu.hex", relu, 4)
        sim.run(work, {"N": n, "PERCH": 1})
        hw = read_hex(work / "pp_out.hex", 8)
        ref = requantize(acc, bias, m0, sh, relu)
        good = len(hw) == n and bool((hw == ref).all())
        allok &= good
        print(f"  {ok(good)}  {pp_stages(ppipe)} pipeline stages: "
              f"{int((hw == ref).sum()) if len(hw) == n else 0}/{n} outputs match Python")
    print()
    return allok


def random_model(rng, M, K0, Ns, relus, kind="random"):
    """A random INT8 model with realistic scales: each layer's per-channel scale maps the
    largest |C + bias| seen on these inputs to about 127, so outputs spread over the INT8 range.
    kind "extreme" also puts in saturating scales, the largest m0, and the largest biases."""
    X = rng.integers(-128, 128, (M, K0))
    a = X.astype(np.int64)
    layers = []
    for l, N in enumerate(Ns):
        K = a.shape[1]
        W = rng.integers(-128, 128, (K, N))
        C = a @ W
        bias = rng.integers(-(1 << 14), 1 << 14, N)
        peak = np.maximum(np.abs(C + bias).max(axis=0), 1)
        m0, sh = np.zeros(N, np.int64), np.zeros(N, np.int64)
        for j in range(N):
            m0[j], sh[j] = scale_to_m0_shift(127.0 / peak[j] * rng.uniform(0.5, 2.0))
        if kind == "extreme" and N > 2:
            m0[0], sh[0] = 65535, 1                       # far too big: saturates
            bias[1] = (1 << 31) - 1 if rng.integers(2) else -(1 << 31)
            m0[2], sh[2] = 0, 48                          # zero scale: output 0
        L = {"W": W, "bias": bias, "m0": m0, "shift": sh, "relu": bool(relus[l])}
        layers.append(L)
        if l < len(Ns) - 1:
            a = requantize(C, bias[None, :], m0[None, :], sh[None, :], L["relu"])
    return X, layers


def cmd_mlp(a, sim):
    """On-chip MLP: random models through tb_mlp (mlp_ctrl), every output and counter checked."""
    rng = np.random.default_rng(a.seed)
    P, nl = a.P, 4
    lanes = a.lanes or P
    params = {"P": P, "ACC": 22, "MAXD": MAXD, "PIPE": 2, "MEM_REG": 2, "PE_PRIM": 0,
              "HREAD_REG": a.hread, "NL": nl, "PPL": lanes, "PPIPE": a.ppipe}
    work = sim.build("tb_mlp", params)
    # (title, M, K0, Ns, relus, kind): fixed edge cases first, then random models
    cases = [("Machine Guardian size 64-64-64-6",  8, 64, [64, 64, 6],     [1, 1, 0], "random"),
             ("one row, one block per layer",       1,  8, [8, 8],         [1, 0],    "random"),
             ("one value per layer, 4 layers",      1,  1, [1, 1, 1, 1],   [1, 1, 1, 0], "random"),
             ("largest: 64 rows, 4 layers of 64",  64, 64, [64, 64, 64, 64], [1, 1, 1, 0], "random"),
             ("sizes not multiples of P",          13, 37, [23, 11, 5],     [1, 1, 0], "random"),
             ("one layer (no writeback)",           5, 20, [9],             [0],       "random"),
             ("no ReLU between layers",             6, 16, [24, 16, 8],     [0, 0, 0], "random"),
             ("saturating scales, huge biases",     9, 30, [17, 12, 7],     [1, 0, 0], "extreme")]
    for t in range(a.cases):
        L = int(rng.integers(1, nl + 1))
        cases.append((f"random model {t + 1}", int(rng.choice([1, 2, 3, 7, 8, 16, 33, 64])),
                      int(rng.integers(1, MAXD + 1)), [int(rng.integers(1, MAXD + 1)) for _ in range(L)],
                      [int(rng.integers(2)) for _ in range(L)], "random" if rng.integers(3) else "extreme"))
    print(f"\nOn-chip MLP (mlp_ctrl) on a {P}x{P} array, {lanes} postproc lane{'s' if lanes > 1 else ''}, "
          f"{pp_stages(a.ppipe)}-stage postproc, C read latency {1 + a.hread}, {sim.name}")
    print("  Every model runs twice with new inputs and the same weights; the last layer's raw sums,")
    print("  the last layer's INT8 inputs (A buffer) and all four counters are compared with Python.\n")
    allok = True
    for title, M, K0, Ns, relus, kind in cases:
        X0, layers = random_model(rng, M, K0, Ns, relus, kind)
        X1 = rng.integers(-128, 128, (M, K0))
        Ks = [K0] + Ns[:-1]
        for l, Ld in enumerate(layers):
            write_hex(work / f"W{l}.hex", Ld["W"], 8)
            write_hex(work / f"Bias{l}.hex", Ld["bias"], 32)
            write_hex(work / f"Scl{l}.hex", (Ld["shift"] << 16) | Ld["m0"], 24)
        write_hex(work / "X0.hex", X0, 8)
        write_hex(work / "X1.hex", X1, 8)
        for r in range(2):
            for f in (f"C{r}.hex", f"A{r}.hex", f"stats{r}.txt"):
                (work / f).unlink(missing_ok=True)
        plus = {"M": M, "K0": K0, "L": len(Ns), "RELU": sum(b << l for l, b in enumerate(relus)), "RUNS": 2}
        plus.update({f"N{l}": n for l, n in enumerate(Ns)})
        sim.run(work, plus)
        eq = mlp_equation(P, M, Ks, Ns, hread=a.hread, ppipe=a.ppipe, lanes=lanes)
        good = True
        for r, X in enumerate((X0, X1)):
            C, acts = golden_mlp(X, layers)
            hwC = read_hex(work / f"C{r}.hex", 22).reshape(M, Ns[-1])
            good &= bool((hwC == C).all())
            if len(Ns) > 1:
                hwA = read_hex(work / f"A{r}.hex", 8).reshape(M, Ks[-1])
                good &= bool((hwA == acts[-1]).all())
            got = tuple(int(v) for v in (work / f"stats{r}.txt").read_text().split())
            good &= got == eq
        allok &= good
        shape = "-".join(str(v) for v in [K0] + Ns)
        print(f"  {ok(good)}  {title:<36} M {M:2d}  {shape:<15}  model {got[3]:6d} cycles (eq {eq[3]:6d}), "
              f"array {got[1]:6d} (eq {eq[1]:6d})")
    print(f"\n  {ok(allok)}  {len(cases)} models\n")
    return allok


def uart_steps(A, B):
    """The laptop's side of the conversation: (bytes to send, reply bytes to wait for)."""
    M, K = A.shape
    N = B.shape[1]
    return [(b"I", 7), (b"D" + bytes([M, K, N]), 1),
            (b"A" + bytes(int(v) & 0xFF for v in A.ravel()), 1),
            (b"B" + bytes(int(v) & 0xFF for v in B.ravel()), 1),
            (b"G", 13), (b"C", 4 * M * N)]


def report_uart(got, A, B, P, label, secs):
    M, K = A.shape
    N = B.shape[1]
    ident, acks, stats, cbytes = got[:7], got[7:10], got[10:23], got[23:]
    u32 = lambda b: int.from_bytes(bytes(b), "little")
    passes, cycles, total = u32(stats[1:5]), u32(stats[5:9]), u32(stats[9:13])
    C = to_signed([u32(cbytes[i:i + 4]) for i in range(0, len(cbytes), 4)], 32).reshape(M, N)
    ref = golden(A, B, P, 32, 0)
    eqp, eqc = equation(P, M, K, N)
    rows = [("'I'  (identify)", f"'{bytes(ident[:3]).decode(errors='replace')}'  P={ident[3]} BITS={ident[4]} ACC={ident[5]} MAXD={ident[6]}"),
            (f"'D' {M} {K} {N}  (sizes)", f"'{chr(acks[0])}'"),
            (f"'A' + {M*K} bytes", f"'{chr(acks[1])}'"),
            (f"'B' + {K*N} bytes", f"'{chr(acks[2])}'"),
            ("'G'  (run)", f"'{chr(stats[0])}'  passes={passes} cycles={cycles} total={total}"),
            ("'C'  (read result)", f"{len(cbytes)} bytes = {M*N} results")]
    print(f"\n  {'laptop sends':<26} {label} replies")
    for left, right in rows:
        print(f"  {left:<26} {right}")
    good = bool((C == ref).all()) and cycles == eqc and passes == eqp
    print(f"\n  {ok(good)}  {int((C == ref).sum())}/{M*N} results match NumPy; cycles {cycles}, equation {eqc}")
    print(f"  (took {secs:.1f} s)\n")
    return good


def cmd_uart(a, sim):
    M, K, N = a.M, a.K, a.N
    check_dims(M, K, N)
    A, B = make_data(a.data, M, K, N, 8, np.random.default_rng(a.seed))
    script, expect = [], 0
    for data, nreply in uart_steps(A, B):
        script.extend(data)
        expect += nreply
        script.append(0x4000_0000 | expect)
    script.append(0xC000_0000)
    work = sim.build("tb_chip", {"P": a.P, "CLKS_PER_BIT": 4})
    (work / "uart_script.hex").write_text("".join(f"{w:08x}\n" for w in script))
    (work / "uart_out.hex").unlink(missing_ok=True)
    print(f"\nWhole chip over a serial line: laptop <-> UART <-> host interface <-> {a.P}x{a.P} matrix core")
    print(f"Sending {M}x{K} and {K}x{N} INT8 matrices on {sim.name} (serial line sped up for simulation) ...", flush=True)
    t0 = time.time()
    sim.run(work, {})
    got = [int(x, 16) for x in (work / "uart_out.hex").read_text().split()]
    if len(got) != expect:
        sys.exit(f"Expected {expect} reply bytes, got {len(got)}.")
    return report_uart(got, A, B, a.P, "chip", time.time() - t0)


def cmd_board(a):
    """Same conversation as 'uart', but with the real Arty board over USB."""
    try:
        import serial
    except ImportError:
        sys.exit("The board command needs pyserial: pip install pyserial")
    M, K, N = a.M, a.K, a.N
    check_dims(M, K, N)
    A, B = make_data(a.data, M, K, N, 8, np.random.default_rng(a.seed))
    print(f"\nArty board on {a.port}: sending {M}x{K} and {K}x{N} INT8 matrices at 115200 baud ...", flush=True)
    t0 = time.time()
    got = []
    with serial.Serial(a.port, 115200, timeout=5) as port:
        port.reset_input_buffer()
        for data, nreply in uart_steps(A, B):
            port.write(data)
            reply = port.read(nreply)
            if len(reply) != nreply:
                sys.exit(f"The board sent {len(reply)} of {nreply} expected bytes after '{chr(data[0])}'. "
                         "Check the port, press RESET, and make sure the bitstream is loaded.")
            got += list(reply)
    P = got[3]
    return report_uart(got, A, B, P, "board", time.time() - t0)


# ------------------------------------------------------------------ main
def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)

    def common(p):
        p.add_argument("--sim", choices=("auto", "vivado", "icarus"), default="auto")
        p.add_argument("--vivado-bin", help="folder that contains xvlog, xelab and xsim")
        p.add_argument("--seed", type=int, default=1)

    p = sub.add_parser("multiply", help="multiply two matrices on the hardware model")
    p.add_argument("M", type=int, nargs="?", default=16)
    p.add_argument("K", type=int, nargs="?", default=16)
    p.add_argument("N", type=int, nargs="?", default=16)
    p.add_argument("--P", type=int, default=16, help="array size (default 16)")
    p.add_argument("--data", default="random", choices=("random", "small", "ones", "identity", "max", "min"))
    p.add_argument("--a", help="file with matrix A (spaces or commas)")
    p.add_argument("--b", help="file with matrix B")
    p.add_argument("--bits", type=int, default=8, choices=(4, 8))
    p.add_argument("--acc", type=int, default=32)
    p.add_argument("--sat", action="store_true", help="saturating accumulators")
    p.add_argument("--show", action="store_true", help="print the matrices")
    common(p)

    p = sub.add_parser("compare", help="same multiply on several array sizes")
    for d in "MKN":
        p.add_argument(d, type=int, nargs="?", default=64)
    p.add_argument("--sizes", type=int, nargs="+", default=[4, 8, 16])
    p.add_argument("--data", default="random", choices=("random", "small", "ones", "max", "min"))
    common(p)

    p = sub.add_parser("test", help="edge-case suite on several array sizes")
    p.add_argument("--sizes", type=int, nargs="+", default=[2, 3, 4, 8, 16])
    p.add_argument("--quick", action="store_true", help="4 cases per size instead of 12")
    common(p)

    p = sub.add_parser("saturate", help="overflow versus saturating accumulators")
    common(p)

    p = sub.add_parser("postproc", help="bias + requantize + ReLU unit")
    common(p)

    p = sub.add_parser("mlp", help="on-chip MLP: random whole models, every number checked")
    p.add_argument("--P", type=int, default=8, help="array size (default 8, as on the ZedBoard)")
    p.add_argument("--cases", type=int, default=12, help="random models after the fixed cases")
    p.add_argument("--lanes", type=int, default=0, help="postproc lanes (default P); must divide P")
    p.add_argument("--ppipe", type=int, default=2, choices=(0, 1, 2), help="postproc stages: 0 = 3, 1 = 7, 2 = 9 (default, as on the ZedBoard)")
    p.add_argument("--hread", type=int, default=1, choices=(0, 1), help="HREAD_REG (C read latency 1 + this)")
    common(p)

    p = sub.add_parser("uart", help="whole chip over a simulated serial line")
    for d in "MKN":
        p.add_argument(d, type=int, nargs="?", default=8)
    p.add_argument("--P", type=int, default=16)
    p.add_argument("--data", default="random", choices=("random", "small", "ones", "max", "min"))
    common(p)

    p = sub.add_parser("board", help="same as uart, but with the real Arty board (needs pyserial)")
    for d in "MKN":
        p.add_argument(d, type=int, nargs="?", default=16)
    p.add_argument("--port", required=True, help="serial port, e.g. COM5 or /dev/ttyUSB1")
    p.add_argument("--data", default="random", choices=("random", "small", "ones", "max", "min"))
    p.add_argument("--seed", type=int, default=1)

    a = ap.parse_args()
    if a.cmd == "board":
        sys.exit(0 if cmd_board(a) else 1)
    if getattr(a, "P", 2) < 2 or any(s < 2 for s in getattr(a, "sizes", [])):
        sys.exit("The array size P must be 2 or more.")
    sim = Simulator(a.sim, a.vivado_bin)
    good = {"multiply": cmd_multiply, "compare": cmd_compare, "test": cmd_test,
            "saturate": cmd_saturate, "postproc": cmd_postproc, "uart": cmd_uart, "mlp": cmd_mlp}[a.cmd](a, sim)
    sys.exit(0 if good else 1)


if __name__ == "__main__":
    main()
