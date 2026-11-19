"""modelV3 in INT4 for Tiny-TPU Version 1: one INT4 x INT4 processing element (CLEAR / MAC / READ, signed 16-bit sum),
the host does everything else. The professor's Version 1 host flow, extended from 2 layers to any number:

  inputs   x = pipeline.network_inputs(...)          the same 13 slog values as the INT8 model
           u = (x - MU) / SD                         per input, MU / SD from the training rows
           a = q4(u / S_A[0])
  layer l  acc[j] = sum_i a[i] * W[l][j][i]          on the PE, exact: |acc| <= 49 * K <= 32767 for K <= 668
           z[j]   = acc[j] * S_A[l] * S_W[l][j] + B[l][j]      host, double precision, in this order
           hidden layer: a = clip(rint(max(z, 0) / S_A[l + 1]), 0, HMAX) - HSHIFT
           last layer:   z = the 4 outputs (status logits healthy / developing / faulty, health logit)
  q4(v) = clip(rint(v), -7, 7), rint rounding halves to even (numpy rint, C rint, torch.round).

W: signed INT4 in [-7, 7], one scale per output neuron, S_W[l][j] = max_i |w[l][j][i]| / 7 (the host multiplies per
neuron anyway, so this costs nothing). S_A: one activation scale per layer, learned during training (LSQ).

Hidden activations are never negative (ReLU). With HMAX = 7, HSHIFT = 0 (8 levels, the default and the professor's
contract) they use only 0..7. With HMAX = 15, HSHIFT = 8 (16 levels, --hidden-levels 16) they use the PE's full
-8..7: the host adds CORR[l][j] = HSHIFT * sum_i W[l][j][i] to each sum of layers 1.. (acc + CORR is exact), and
|acc| <= 56 * K stays far inside 16 bits.

QMLP trains with this flow as fake quantization (straight-through rounding), so the network learns the INT4 grid;
forward_int() is the integer flow itself and is the reference every board program is checked against.
"""
import numpy as np
import torch
from torch import nn

import config as c

QMAX = 7                                            # symmetric INT4, as the Version 1 contract (-8 is never sent)
ACC_MIN, ACC_MAX = -(1 << 15), (1 << 15) - 1        # the PE's signed 16-bit accumulator


def q4(v):
    return np.clip(np.rint(v), -QMAX, QMAX)


def _round(x):
    """round() forward (halves to even, as rint), identity backward."""
    return x + (torch.round(x) - x).detach()


def fq_weight(w):
    """Per-output-neuron symmetric INT4 fake quantization. The scale follows the weights (no gradient through it)."""
    s = (w.detach().abs().amax(1, keepdim=True) / QMAX).clamp_min(1e-12)
    return torch.clamp(_round(w / s), -QMAX, QMAX) * s


def fq_act(x, log_s, lo=-QMAX, hi=QMAX):
    """INT4 fake quantization to [lo, hi] steps with a learned scale (LSQ, gradient scaled by 1 / sqrt(features * hi))."""
    g = 1.0 / np.sqrt(x.shape[-1] * hi)
    s = torch.exp(log_s)
    s = (s - s * g).detach() + s * g
    return torch.clamp(_round(x / s), lo, hi) * s


class QMLP(nn.Module):
    """The modelV3 network (Linear + ReLU chain, both heads in the last layer) with the INT4 flow built in.
    quant = 0: plain FP32 (the warm-up phase of training); quant = 1: INT4 fake quantization."""

    def __init__(self, sizes, seed=0, hidden_levels=8):
        super().__init__()
        assert hidden_levels in (8, 16)
        self.hmax = hidden_levels - 1               # hidden INT4 steps 0..hmax, sent as 0..hmax - hshift
        self.hshift = 0 if hidden_levels == 8 else 8
        torch.manual_seed(seed)                     # the same initial weights as net.mlp() with this seed
        self.layers = nn.ModuleList(nn.Linear(a, b) for a, b in zip(sizes, sizes[1:]))
        self.log_sa = nn.Parameter(torch.zeros(len(self.layers)))
        self.register_buffer("mu", torch.zeros(sizes[0]))
        self.register_buffer("sd", torch.ones(sizes[0]))
        self.register_buffer("quant", torch.tensor(0))

    @property
    def sizes(self):
        return [self.layers[0].in_features] + [L.out_features for L in self.layers]

    @torch.no_grad()
    def standardize(self, X):
        """MU / SD of the inputs, from training rows only."""
        X = torch.as_tensor(X, dtype=torch.float32)
        self.mu.copy_(X.mean(0))
        self.sd.copy_(X.std(0).clamp_min(1e-3))

    def _run(self, x, upto=None):
        a = (x - self.mu) / self.sd
        for l, L in enumerate(self.layers):
            if l:
                a = torch.relu(a)
            if l == upto:
                return a
            if self.quant:
                q = fq_act(a, self.log_sa[l]) if l == 0 else fq_act(a, self.log_sa[l], 0, self.hmax)
                a = q @ fq_weight(L.weight).T + L.bias
            else:
                a = L(a)
        return a

    def forward(self, x):
        return self._run(x)

    def hidden(self, x):
        """The last hidden layer (after ReLU), as net[:-1](x) of the FP32 model."""
        return self._run(x, upto=len(self.layers) - 1)

    @torch.no_grad()
    def calibrate(self, X, pct=c.CALIB_PCT):
        """Activation scales from data: the pct percentile of each layer's non-zero |input| maps to 7. Run once, on
        training rows, when quantization switches on; training then moves the scales (they are parameters)."""
        a = (torch.as_tensor(X, dtype=torch.float32) - self.mu) / self.sd
        for l, L in enumerate(self.layers):
            if l:
                a = torch.relu(a)
            v = a.abs().flatten()
            v = v[v > 0]
            top = float(np.percentile(v.numpy(), pct)) if len(v) else 1.0
            self.log_sa[l] = float(np.log(max(top, 1e-6) / (QMAX if l == 0 else self.hmax)))
            a = L(a)

    @classmethod
    def from_fp32(cls, net, X_calib):
        """Post-training INT4 of an FP32 net.mlp() model: the same weights, MU / SD and scales from X_calib."""
        lin = [m for m in net if isinstance(m, nn.Linear)]
        q = cls([lin[0].in_features] + [m.out_features for m in lin])
        q.standardize(X_calib)
        with torch.no_grad():
            for d, s in zip(q.layers, lin):
                d.weight.copy_(s.weight)
                d.bias.copy_(s.bias)
            # the FP32 net takes x, QMLP's first layer takes u = (x - MU) / SD: W x + b = (W SD) u + (b + W MU)
            q.layers[0].bias.add_(lin[0].weight @ q.mu)
            q.layers[0].weight.mul_(q.sd)
        q.calibrate(X_calib)
        q.quant.fill_(1)
        return q.eval()


def integer_model(net):
    """The integer model the host and the PE run, from a QMLP (quant on): float64 scales, INT4 weights."""
    assert int(net.quant) == 1, "quantization is off: train with --int4 (or use QMLP.from_fp32)"
    sa = np.exp(net.log_sa.detach().double().numpy())
    layers = []
    for L in net.layers:
        w = L.weight.detach().double().numpy()
        sw = np.maximum(np.abs(w).max(1) / QMAX, 1e-12)
        W = q4(w / sw[:, None]).astype(np.int64)
        assert 8 * QMAX * W.shape[1] <= ACC_MAX, "a layer this wide could overflow the 16-bit sum"
        corr = net.hshift * W.sum(1) if layers else np.zeros(len(W), np.int64)
        layers.append({"W": W, "s_w": sw, "b": L.bias.detach().double().numpy(), "corr": corr.astype(np.int64)})
    return {"sizes": net.sizes, "mu": net.mu.double().numpy(), "sd": net.sd.double().numpy(), "s_a": sa,
            "hmax": net.hmax, "hshift": net.hshift, "layers": layers}


def forward_int(X, m):
    """The integer flow (module docstring) on rows X: (INT4 inputs, [PE sums per layer], outputs). float64 throughout,
    each operation in the order the C and MicroPython hosts use, so their results match to the last bit."""
    X = np.asarray(X, dtype=np.float64)
    a0 = q4(((X - m["mu"]) / m["sd"]) / m["s_a"][0]).astype(np.int64)
    return (a0, *forward_from_a0(a0, m))


def forward_from_a0(a0, m, inputs=None):
    """forward_int from the INT4 inputs on: ([PE sums per layer], outputs). inputs: a list that receives each layer's
    INT4 operands (what the PE is sent)."""
    a, sums = a0, []
    for l, L in enumerate(m["layers"]):
        if inputs is not None:
            inputs.append(a)
        acc = a @ L["W"].T
        assert acc.min() >= ACC_MIN and acc.max() <= ACC_MAX and a.min() >= -8 and a.max() <= 7
        sums.append(acc)
        z = (acc + L["corr"]) * m["s_a"][l] * L["s_w"] + L["b"]
        if l + 1 < len(m["layers"]):
            a = (np.clip(np.rint(np.maximum(z, 0.0) / m["s_a"][l + 1]), 0, m["hmax"]) - m["hshift"]).astype(np.int64)
    return sums, z


def pe_neuron(a, w):
    """tiny_tpu_pe.v, command by command: CLEAR, one MAC per input, READ -> (16-bit signed sum, sticky overflow)."""
    acc, ovf = 0, 0
    for x, y in zip(a, w):
        assert -8 <= x <= 7 and -8 <= y <= 7
        s = acc + int(x) * int(y)                   # the RTL's 17-bit sum
        ovf |= not (ACC_MIN <= s <= ACC_MAX)
        acc = (s + (1 << 15)) % (1 << 16) - (1 << 15)     # it keeps the low 16 bits
    return acc, ovf
