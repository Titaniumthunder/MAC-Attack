"""The Machine Guardian multi-task MLP (architecture only; NOT trained). A separate model: train.py's E0-E3 networks,
health.py's H1 and every file in weights/, export/ and results/ are not touched.

  python mtl_model.py               describe the architecture, run one INT8 inference on real B01/B03 inputs
  python mtl_model.py --rtl         also run it on the RTL (Vivado xsim, as rtl_check.py --sim vivado)

Architecture (8 -> 32 -> 16 -> 2, ReLU; the same trunk sizes as E3, so it fits the 8 x 8 systolic array as E3 does):
  inputs   the 8 values of mtl_inputs.py (one accelerometer: 6 RPM-corrected vibration z-values; the operating point;
           the temperature residual), already standardized per motor and clipped to +-16
  trunk    Linear(8, 32) + ReLU, Linear(32, 16) + ReLU             (shared by both outputs)
  heads    deterioration: Linear(16, 1) -> logit d;  p = sigmoid(d); "deteriorating" if p >= a threshold chosen on
                          validation bearings once labels exist
           health index:  Linear(16, 1) -> h;        HI = 100 % * sigmoid(h)
           On the accelerator both heads are ONE last layer of 2 columns (16 x 2); the chip returns the 2 raw sums,
           the ARM adds the biases and applies the two sigmoids.
  loss     multitask_loss(): BCE on the deterioration logit + w * MSE on HI / 100, each over the rows that HAVE that
           label (NaN = no label); a head with no labels in a batch contributes nothing.

The network is randomly initialized here. Its outputs mean nothing until it is trained on independent deterioration and
health labels (results/multitask/MULTITASK_ARCHITECTURE_REPORT.md section 7). predict() refuses an untrained network.

INT8 (export.py's scheme, unchanged): one input scale s_x = Z_CLIP / 127 (inputs are already z-values, no extra
standardizer); per-output-channel weight scales; hidden scales from the largest ReLU activation on calibration inputs;
bit-exact model mac.golden_mlp (ACC 22).
"""
import argparse, json, shutil, sys, tempfile
from pathlib import Path

import numpy as np
import torch
from torch import nn

from dataset import HERE, MAC_DIR
from export import build, quantize_inputs
from mtl_inputs import OUT, Z_CLIP, input_names

sys.path.insert(0, str(MAC_DIR))
from mac import golden_mlp, mlp_equation   # noqa: E402

N_IN, HIDDEN = 8, (32, 16)
HEADS = ("deterioration_logit", "health_raw")
P, ACC, FCLK = 8, 22, 214.286e6


class MultiTaskMLP(nn.Module):
    def __init__(self, n_in=N_IN, hidden=HIDDEN, seed=0):
        super().__init__()
        torch.manual_seed(seed)
        layers, n = [], n_in
        for h in hidden:
            layers += [nn.Linear(n, h), nn.ReLU()]
            n = h
        self.trunk = nn.Sequential(*layers)
        self.det_head = nn.Linear(n, 1)
        self.hi_head = nn.Linear(n, 1)
        self.register_buffer("trained", torch.tensor(False))

    def forward(self, x):
        z = self.trunk(x)
        return self.det_head(z)[:, 0], self.hi_head(z)[:, 0]

    def as_sequential(self):
        """The same function as one Sequential with a 2-column last layer (the form the accelerator runs)."""
        last = nn.Linear(self.det_head.in_features, 2)
        with torch.no_grad():
            last.weight.copy_(torch.cat([self.det_head.weight, self.hi_head.weight]))
            last.bias.copy_(torch.cat([self.det_head.bias, self.hi_head.bias]))
        return nn.Sequential(*self.trunk, last)


def n_params(net):
    return sum(p.numel() for p in net.parameters())


def outputs(d_logit, h_raw):
    """What the ARM reports from the two heads."""
    return {"deterioration_probability": torch.sigmoid(d_logit), "health_index_pct": 100.0 * torch.sigmoid(h_raw)}


def predict(net, x):
    if not bool(net.trained):
        raise RuntimeError("the multi-task MLP is untrained: its outputs are not deterioration or health estimates")
    with torch.no_grad():
        return outputs(*net(x))


def multitask_loss(d_logit, h_raw, y_det, y_hi, w_hi=1.0):
    """Masked two-task loss. y_det in {0, 1} or NaN; y_hi in [0, 100] % or NaN (no label). Returns (total, parts)."""
    md, mh = ~torch.isnan(y_det), ~torch.isnan(y_hi)
    zero = d_logit.sum() * 0.0
    l_det = nn.functional.binary_cross_entropy_with_logits(d_logit[md], y_det[md]) if md.any() else zero
    l_hi = nn.functional.mse_loss(torch.sigmoid(h_raw[mh]), y_hi[mh] / 100.0) if mh.any() else zero
    return l_det + w_hi * l_hi, {"det": float(l_det.detach()), "hi": float(l_hi.detach()), "n_det": int(md.sum()), "n_hi": int(mh.sum())}


def int8_model(net, X_calib):
    """INT8 layers (golden_mlp's format) from the network; X_calib: real (clipped) inputs for the hidden scales."""
    s_x = Z_CLIP / 127.0
    seq = net.as_sequential()
    layers, scales = build(seq, X_calib, s_x)
    return seq, layers, scales, s_x


def int8_forward(X, layers, scales, s_x):
    """Chip + ARM: raw sums C (M x 2) from the chip, plus the last layer's biases, as real values."""
    Xq = quantize_inputs(X, s_x)
    C, acts = golden_mlp(Xq, layers, acc=ACC)
    exact = Xq
    from mac import requantize
    for L in layers[:-1]:                        # the true sums must fit the 22-bit accumulator (no wrap)
        s = exact @ L["W"]
        assert np.abs(s).max() < 1 << (ACC - 1)
        exact = requantize(s, L["bias"][None, :], L["m0"][None, :], L["shift"][None, :], L["relu"])
    assert np.abs(exact @ layers[-1]["W"]).max() < 1 << (ACC - 1)
    last = scales[-1]
    real = (C + last["bias_last"][None, :]) * (last["s_in"] * last["s_w"])[None, :]
    return Xq, C, real


def cycles(M):
    Ks, Ns = [N_IN, *HIDDEN], [*HIDDEN, 2]
    return mlp_equation(P, M, Ks, Ns, pipe=2, mem_reg=2, hread=1, ppipe=2, lanes=8)


def describe(net):
    rows, n = [], N_IN
    for i, h in enumerate([*HIDDEN, 2]):
        rows.append({"layer": i, "in": n, "out": h, "weights": n * h, "biases": h,
                     "activation": "ReLU" if i < len(HIDDEN) else "none (ARM: sigmoid per head)",
                     "array_passes": -(-n // P) * -(-h // P)})
        n = h
    return {"inputs": input_names(), "sizes": [N_IN, *HIDDEN, 2], "heads": HEADS, "layers": rows,
            "params": n_params(net), "params_int8_bytes": sum(r["weights"] for r in rows),
            "bias_int32_bytes": 4 * sum(r["biases"] for r in rows),
            "cycles": {M: cycles(M)[3] for M in (1, 10, 64)}}


def diagram(path):
    """The architecture as a figure for the report."""
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt
    from matplotlib.patches import FancyBboxPatch
    fig, ax = plt.subplots(figsize=(10, 3.9))
    ax.set_xlim(0, 100), ax.set_ylim(0, 40), ax.axis("off")

    def box(x, y, w, h, text, fc, ec="#52514e", size=8):
        ax.add_patch(FancyBboxPatch((x, y), w, h, boxstyle="round,pad=0.4,rounding_size=1.2", fc=fc, ec=ec, lw=1))
        ax.text(x + w / 2, y + h / 2, text, ha="center", va="center", fontsize=size, color="#0b0b0b")

    def arrow(x0, y0, x1, y1):
        ax.annotate("", (x1, y1), (x0, y0), arrowprops=dict(arrowstyle="-|>", color="#52514e", lw=1))

    names = ["x1 z ln RMS", "x2 z ln peak", "x3 z kurtosis", "x4 z ln 1-5 kHz", "x5 z ln 5-20 kHz",
             "x6 z ln 20-64 kHz", "x7 RPM (operating point)", "x8 temperature residual"]
    for i, n in enumerate(names):
        fc = "#e8f1fb" if i < 6 else "#fdeee7" if i == 6 else "#e6f6ef"
        box(1, 35.5 - i * 4.6, 18, 3.2, n, fc, size=7.5)
        arrow(19.8, 37.1 - i * 4.6, 26, 20)
    ax.text(10, 39.6, "ARM: per-motor calibrated inputs", ha="center", fontsize=8, color="#52514e")
    box(26.5, 6, 12, 28, "Linear 8 x 32\n+ ReLU\n\n288 params\n4 array passes", "#f3f2ef")
    arrow(39.5, 20, 44, 20)
    box(44.5, 9, 12, 22, "Linear 32 x 16\n+ ReLU\n\n528 params\n8 array passes", "#f3f2ef")
    ax.text(41.5, 37, "shared trunk (8 x 8 systolic array, INT8)", ha="center", fontsize=8, color="#52514e")
    arrow(57.5, 22, 63, 28), arrow(57.5, 18, 63, 12)
    box(63.5, 24, 13, 8, "deterioration head\nLinear 16 x 1 (17)", "#e8f1fb")
    box(63.5, 8, 13, 8, "health-index head\nLinear 16 x 1 (17)", "#e6f6ef")
    ax.text(70, 3.2, "one 16 x 2 layer on the chip (2 passes)", ha="center", fontsize=7.5, color="#52514e")
    arrow(77.5, 28, 82, 28), arrow(77.5, 12, 82, 12)
    box(82.5, 24, 16, 8, "ARM: p = sigmoid(d)\ndeteriorating if p >= t", "#ffffff", size=7.2)
    box(82.5, 8, 16, 8, "ARM: health index\nHI = 100% x sigmoid(h)", "#ffffff", size=7.2)
    ax.text(90.5, 36, "UNTRAINED: no output is used", ha="center", fontsize=8, color="#eb6834", weight="bold")
    fig.savefig(path, dpi=160, bbox_inches="tight")
    plt.close(fig)


def load_inputs(exps=("B01", "B03")):
    import pandas as pd
    names = input_names()
    return {e: pd.read_csv(OUT / f"inputs_{e}.csv")[names].to_numpy(np.float64) for e in exps}


def rtl(layers, scales, batches):
    """Run the INT8 model on tb_mlp.sv (Vivado xsim) with rtl_check.py's settings and check every raw sum and counter."""
    import rtl_check
    root = Path(tempfile.mkdtemp(prefix="mg_mtl_rtl_"))
    try:
        sim = rtl_check.TempSimulator(root, "vivado")
        work = sim.build("tb_mlp", rtl_check.PARAMS)
        good, eq, cyc, _ = rtl_check.run(sim, work, layers, batches, int(scales[-1]["bias_last"][0]))
        return good, eq, cyc
    finally:
        shutil.rmtree(root, ignore_errors=True)


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--rtl", action="store_true", help="also run the INT8 model on the RTL (Vivado xsim)")
    ap.add_argument("--seed", type=int, default=0, help="initialization seed (random weights)")
    a = ap.parse_args()
    net = MultiTaskMLP(seed=a.seed).eval()
    info = describe(net)
    X = load_inputs()
    Xall = np.vstack(list(X.values()))
    seq, layers, scales, s_x = int8_model(net, Xall)
    with torch.no_grad():
        fp = seq(torch.tensor(Xall, dtype=torch.float32)).double().numpy()
    Xq, C, real = int8_forward(Xall, layers, scales, s_x)
    err = np.abs(real - fp)
    info["int8_check"] = {"rows": len(Xall), "s_x": s_x, "mean_abs_err": err.mean(axis=0).tolist(),
                          "max_abs_err": err.max(axis=0).tolist(), "fp32_range": [fp.min(axis=0).tolist(), fp.max(axis=0).tolist()],
                          "note": "random initialization: checks the arithmetic, not any prediction"}
    if a.rtl:
        n = len(Xq) // 64 * 64
        good, eq, cyc = rtl(layers, scales, [Xq[i:i + 64] for i in range(0, n, 64)])
        good1, eq1, cyc1 = rtl(layers, scales, [Xq[[i]] for i in range(10)])
        info["rtl"] = {"M64": {"pass": bool(good), "runs": n // 64, "cycles": cyc, "equation": eq[3]},
                       "M1": {"pass": bool(good1), "runs": 10, "cycles": cyc1, "equation": eq1[3]}}
    (OUT / "figures").mkdir(parents=True, exist_ok=True)
    diagram(OUT / "figures" / "mtl_architecture.png")
    (OUT / "architecture.json").write_text(json.dumps(info, indent=1) + "\n", encoding="utf-8")
    print(json.dumps(info, indent=1))


if __name__ == "__main__":
    main()
