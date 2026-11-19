"""The network in the form the chip runs: a chain of Linear + ReLU, both heads in the last layer.
Output columns 0-2: status logits (healthy, developing, faulty). Column 3: health logit (sigmoid -> 1 new, 0 failed)."""
import torch
from torch import nn

import config as c


def mlp(n_in=len(c.INPUTS), hidden=c.HIDDEN, seed=0):
    torch.manual_seed(seed)
    layers, n = [], n_in
    for h in hidden:
        layers += [nn.Linear(n, h), nn.ReLU()]
        n = h
    return nn.Sequential(*layers, nn.Linear(n, 4))


def build(cfg, seed=0):
    """The network a run trained: FP32 (net.mlp) or, for an --int4 run, the INT4 QMLP (int4.py)."""
    sizes = cfg.get("sizes", [len(c.INPUTS), *c.HIDDEN, 4])
    if cfg.get("int4"):
        import int4
        return int4.QMLP(sizes, seed=seed, hidden_levels=cfg.get("int4_hidden_levels", 8))
    return mlp(sizes[0], tuple(sizes[1:-1]), seed=seed)


def load(path, cfg):
    net = build(cfg)
    net.load_state_dict(torch.load(path, weights_only=True))
    return net.eval()


def hidden(net, x):
    """The last hidden layer (after ReLU) of either kind of network."""
    return net.hidden(x) if hasattr(net, "hidden") else net[:-1](x)


def losses(out, y, health):
    """Masked: a row trains only the head it has a label for. y: 0, 1, 2 or -1 (none); health: 0..1 or NaN (none)."""
    ms, mh = y >= 0, ~torch.isnan(health)
    zero = out.sum() * 0.0
    status = nn.functional.cross_entropy(out[ms, :3], y[ms]) if ms.any() else zero
    hl = nn.functional.mse_loss(torch.sigmoid(out[mh, 3]), health[mh]) if mh.any() else zero
    return status, hl
