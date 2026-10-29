"""Run the exported model on the RTL (tb/tb_mlp.sv, as mac.py's `mlp` command does) and check every number.

  python rtl_check.py                 E3; Icarus Verilog 12 or newer (iverilog, vvp on PATH)
  python rtl_check.py --experiment E3_single_accel_a1 --sim vivado      another export, on Vivado's xsim

Three runs of the same compiled testbench (the ZedBoard settings: P 8, ACC 22, PIPE 2, MEM_REG 2, HREAD_REG 1,
8 postproc lanes, 9-stage postproc; weights loaded once per run of the testbench):
  all      all 1,280 windows, 64 rows per model run (20 runs)
  M = 10   each test recording's 10 windows as one model run (32 runs): the board's last-10-s batch
  M = 1    the 10 windows of the first test recording one at a time (10 runs): the once-a-second case
Every raw sum C, every INT8 input of the last layer (the A buffer) and the four counters must equal golden_mlp()
and mlp_equation(); the logits (C + bias_last) and the recording decisions follow from C.
The testbench runs in a temporary folder (mac.py would put it in mac_attack_accel_MLP/run/, which git does not ignore).
"""
import argparse, csv, json, shutil, sys, tempfile, time
from pathlib import Path

import numpy as np

from dataset import HERE, MAC_DIR
from export import quantize_inputs
from train import EXPERIMENTS, load

sys.path.insert(0, str(MAC_DIR))
import mac                                      # noqa: E402
from mac import golden_mlp, mlp_equation, read_hex, write_hex   # noqa: E402

PARAMS = {"P": 8, "ACC": 22, "MAXD": 64, "PIPE": 2, "MEM_REG": 2, "PE_PRIM": 0, "HREAD_REG": 1, "NL": 4,
          "PPL": 8, "PPIPE": 2}


class TempSimulator(mac.Simulator):
    """mac.Simulator with the work folder somewhere else (its build() is otherwise the same).
    kind: "icarus", "vivado" (xsim) or "auto" (Vivado if found, as mac.py, else Icarus)."""

    def __init__(self, root, kind="icarus"):
        super().__init__(kind)
        self.root = Path(root)

    def build(self, top, params):
        work = self.root / f"{self.kind}_{top}"
        work.mkdir(parents=True, exist_ok=True)
        files = [str(mac.ROOT / f) for f in mac.RTL + [mac.TB[top]]]
        if self.kind == "icarus":
            cmd = ["iverilog", "-g2012", "-s", top, "-o", "sim.vvp"]
            cmd += [f"-P{top}.{k}={v}" for k, v in params.items()] + files
            self._call(cmd, work, "Compiling")
        else:
            self._call([self._tool("xvlog"), "-sv"] + files, work, "Compiling (xvlog)")
            # -O0: Vivado 2019.1's default -O2 miscompiles tb_mlp.sv (NN[l] = N<l> leaves the default 8, so the
            # testbench loads 8 x 8 layers; seen 28 Oct 2026). The RTL is the same either way.
            cmd = [self._tool("xelab"), top, "-O0", "-s", "snap"]
            for k, v in params.items():
                cmd += ["-generic_top", f"{k}={v}"]
            self._call(cmd, work, "Elaborating (xelab)")
        return work


def run(sim, work, layers, batches, bias_last):
    """One testbench run: every batch is one model run. Returns (all ok, model cycles per run, logits)."""
    Ks = [L["W"].shape[0] for L in layers]
    Ns = [L["W"].shape[1] for L in layers]
    for f in work.glob("*.hex"):
        f.unlink()
    for f in work.glob("stats*.txt"):
        f.unlink()
    for l, L in enumerate(layers):
        write_hex(work / f"W{l}.hex", L["W"], 8)
        write_hex(work / f"Bias{l}.hex", L["bias"], 32)
        write_hex(work / f"Scl{l}.hex", (np.asarray(L["shift"]) << 16) | np.asarray(L["m0"]), 24)
    for r, X in enumerate(batches):
        write_hex(work / f"X{r}.hex", X, 8)
    M = len(batches[0])
    assert all(len(b) == M for b in batches)
    plus = {"M": M, "K0": Ks[0], "L": len(layers), "RUNS": len(batches),
            "RELU": sum(int(L["relu"]) << l for l, L in enumerate(layers))}
    plus.update({f"N{l}": n for l, n in enumerate(Ns)})
    sim.run(work, plus)
    eq = mlp_equation(PARAMS["P"], M, Ks, Ns, pipe=PARAMS["PIPE"], mem_reg=PARAMS["MEM_REG"],
                      hread=PARAMS["HREAD_REG"], ppipe=PARAMS["PPIPE"], lanes=PARAMS["PPL"])
    good, cycles, logits = True, set(), []
    for r, X in enumerate(batches):
        C, acts = golden_mlp(X, layers)
        hwC = read_hex(work / f"C{r}.hex", PARAMS["ACC"]).reshape(M, Ns[-1])
        hwA = read_hex(work / f"A{r}.hex", 8).reshape(M, Ks[-1])
        got = tuple(int(v) for v in (work / f"stats{r}.txt").read_text().split())
        good &= bool((hwC == C).all()) and bool((hwA == acts[-1]).all()) and got == eq
        cycles.add(got[3])
        logits.append(hwC[:, 0] + bias_last)
    return good, eq, sorted(cycles), np.concatenate(logits)


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--experiment", default="E3")
    ap.add_argument("--keep", action="store_true", help="keep the simulation folder")
    ap.add_argument("--sim", choices=("icarus", "vivado", "auto"), default="icarus",
                    help="simulator (default icarus; vivado = xsim, found as mac.py finds it)")
    a = ap.parse_args()
    if a.sim == "icarus" and not (shutil.which("iverilog") and shutil.which("vvp")):
        raise SystemExit("Icarus Verilog not found (iverilog, vvp). macOS: brew install icarus-verilog; "
                         "or --sim vivado")
    out = HERE / "export" / a.experiment
    q = json.loads((out / "quant.json").read_text())
    info = json.loads((HERE / "weights" / a.experiment / "model.json").read_text())
    rows = load("windows")
    X, inputs = EXPERIMENTS[a.experiment]["inputs"](rows)
    assert inputs == q["inputs"]
    Xq = quantize_inputs((X - np.array(info["scaler"]["mean"])) / np.array(info["scaler"]["std"]), q["s_x"])
    # the layers from the exported hex files (what the board would load), not from Python objects
    sizes = q["sizes"]
    layers = []
    for l in range(len(sizes) - 1):
        W = read_hex(out / f"W{l}.hex", 8).reshape(sizes[l], sizes[l + 1])
        scl = read_hex(out / f"Scl{l}.hex", 24) & 0xFFFFFF
        layers.append({"W": W, "bias": read_hex(out / f"Bias{l}.hex", 32), "m0": scl & 0xFFFF,
                       "shift": scl >> 16, "relu": q["layers"][l]["relu"]})
    root = Path(tempfile.mkdtemp(prefix="mg_rtl_check_"))
    sim = TempSimulator(root, a.sim)
    t0 = time.time()
    work = sim.build("tb_mlp", PARAMS)
    print(f"RTL check of {a.experiment} (seed {q['seed']}) with {sim.name}, {PARAMS}; folder {work}")
    allok = True

    n = len(Xq)
    good, eq, cyc, logit_all = run(sim, work, layers, [Xq[i:i + 64] for i in range(0, n, 64)], q["bias_last"])
    allok &= good
    print(f"  {mac.ok(good)}  all {n} windows, M = 64 x {n // 64} runs: C, A buffer and counters = Python "
          f"(model {cyc} cycles, equation {eq[3]})")

    test = [i for i, r in enumerate(rows) if r["split"] == "test"]
    files = list(dict.fromkeys(rows[i]["file"] for i in test))
    idx = {f: [i for i in test if rows[i]["file"] == f] for f in files}
    good, eq, cyc, logit10 = run(sim, work, layers, [Xq[idx[f]] for f in files], q["bias_last"])
    allok &= good
    print(f"  {mac.ok(good)}  M = 10: the {len(files)} test recordings, one model run each "
          f"(model {cyc} cycles = {cyc[0] / 214.286:.2f} us at 214.286 MHz; equation {eq[3]})")

    first = idx[files[0]]
    good, eq, cyc, logit1 = run(sim, work, layers, [Xq[[i]] for i in first], q["bias_last"])
    allok &= good
    print(f"  {mac.ok(good)}  M = 1: {files[0]}'s 10 windows one at a time "
          f"(model {cyc} cycles = {cyc[0] / 214.286:.2f} us; equation {eq[3]})")

    # the decisions from the RTL's logits against the exported test vectors
    with open(out / "vectors" / "test_recordings.csv", newline="") as f:
        vec = {r["file"]: r for r in csv.DictReader(f)}
    same = logit10.reshape(len(files), 10)
    dec_ok = all(int(s.sum()) == int(vec[f]["sum_logit_int"]) and int(s.sum() >= 10 * q["T_int"]) == int(vec[f]["faulty_int8"])
                 for f, s in zip(files, same))
    dec_ok &= bool((logit1 == logit_all[first]).all()) and bool((logit10 == logit_all[test]).all())
    allok &= dec_ok
    faulty = sum(int(s.sum() >= 10 * q["T_int"]) for s in same)
    print(f"  {mac.ok(dec_ok)}  logits identical in the three runs; every test recording's sum and decision equal the "
          f"exported vectors ({faulty} of {len(files)} called faulty)")
    print(f"\n  {mac.ok(allok)}  {time.time() - t0:.0f} s")
    if a.keep:
        print(f"  kept {root}")
    else:
        shutil.rmtree(root)
    sys.exit(0 if allok else 1)


if __name__ == "__main__":
    main()
