"""Self-contained HTML pages (plot embedded, optional auto-refresh) and the training-curve figure shared by
train.py (live.html, compare.html) and report.py."""
import base64, io

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

PANELS = [("status loss", ["train_status"], ["val_status_pad", "val_status_ott"]), ("health loss", ["train_health"], ["val_health"]),
          ("validation metrics", ["val_acc_pad", "val_acc_ott"], ["val_mae"])]
TITLES = {"train_status": "train", "train_health": "train", "val_status_pad": "validation, Paderborn", "val_status_ott": "validation, Ottawa (version B only)", "val_health": "validation",
          "val_acc_pad": "status accuracy, Paderborn (held out)", "val_acc_ott": "status accuracy, Ottawa (held out)",
          "val_mae": "health error, % points"}


def curves(runs):
    """runs: {name: history table}. Train on the left, validation on the right, same scale. Validation losses are
    class-balanced like the training batches, so a gap that opens between the two as training goes on is overfitting.
    One colour per run; with a single run the faint lines are its folds and seeds."""
    fig, axs = plt.subplots(len(PANELS), 2, figsize=(11, 8.5))
    for (label, left, right), row in zip(PANELS, axs):
        for ax, cols in zip(row, (left, right)):
            for i, (name, h) in enumerate(runs.items()):
                h = h[h.fold != "final"]
                for col, ls in zip(cols, ("-", "--")):
                    if len(runs) == 1:
                        for _, g in h.groupby(["fold", "seed"]):
                            ax.plot(g.step, g[col], ls, color=f"C{i}", alpha=0.15, linewidth=0.8)
                    ax.plot(h.groupby("step")[col].mean(), ls, color=f"C{i}", linewidth=1.8,
                            label=TITLES[col] if len(runs) == 1 else f"{name}: {TITLES[col]}")
            ax.set_title(label + ("" if label.startswith("validation") else ": train" if cols is left else ": validation"),
                         fontsize=9, loc="left")
            ax.legend(fontsize=7)
            ax.grid(True, color="#e4e3df")
            ax.set_xlabel("step")
        if not label.startswith("validation"):
            lim = min(a.get_ylim()[0] for a in row), max(a.get_ylim()[1] for a in row)
            for a in row:
                a.set_ylim(lim)
    fig.tight_layout()
    return fig


def html(title, fig, refresh=False, extra=""):
    buf = io.BytesIO()
    fig.savefig(buf, format="png", dpi=110)
    plt.close(fig)
    return (f"<html><head>{'<meta http-equiv=refresh content=5>' if refresh else ''}<title>{title}</title></head>"
            f"<body style='font-family:sans-serif;max-width:1150px;margin:auto'><h2>{title}</h2>"
            f"<img src='data:image/png;base64,{base64.b64encode(buf.getvalue()).decode()}' style='max-width:100%'>{extra}"
            f"</body></html>")


def write_atomic(path, text):
    """A browser refreshing the page never sees a half-written file."""
    tmp = path.with_suffix(".tmp")
    tmp.write_text(text)
    tmp.replace(path)
