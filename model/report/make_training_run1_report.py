"""results/supervised/run1/TRAINING_RUN1_REPORT.md as a PDF: docs/Multitask_MLP_reports/Training_run1_report.pdf.

  python report/make_training_run1_report.py     (inside model/; run train_deterioration.py first; --keep-html prints the page)

Also draws results/supervised/run1/figures/alarm_timeline.png (the confirmed alarm state of every detector over each
held-out bearing) and dashboard.png (a headless-Chrome screenshot of training_dashboard.html after the run).
Same Markdown converter and headless-Chrome printing as make_paderborn_baseline_report.py.
"""
import functools, http.server, shutil, subprocess, sys, tempfile, threading
from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

HERE = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(Path(__file__).resolve().parent))
sys.path.insert(0, str(HERE))
from make_paderborn_baseline_report import CSS, convert   # noqa: E402
import anomaly_baseline as ab                              # noqa: E402
import supervised_prep as sp                               # noqa: E402
from paderborn import load                                 # noqa: E402

RUN = HERE / "results" / "supervised" / "run1"
SRC = RUN / "TRAINING_RUN1_REPORT.md"
OUT = HERE.parent / "docs" / "Multitask_MLP_reports" / "Training_run1_report.pdf"
FIG = RUN / "figures"
BREAKS = (6,)
MAC_CHROME = Path("/Applications/Google Chrome.app/Contents/MacOS/Google Chrome")


def chrome():
    if MAC_CHROME.exists():
        return str(MAC_CHROME)
    from make_single_accel_report import browser
    return browser()


def runs(mask):
    """Contiguous True runs of a boolean array as (start index, length) pairs."""
    m = np.r_[False, np.asarray(mask, bool), False].astype(int)
    d = np.diff(m)
    a, b = np.flatnonzero(d == 1), np.flatnonzero(d == -1)
    return list(zip(a, b - a))


def alarm_timeline():
    bearings = ("B02", "B03", "B04")
    fig, axs = plt.subplots(len(bearings), 1, figsize=(10, 2.5 * len(bearings)))
    for ax, e in zip(axs, bearings):
        p = pd.read_csv(RUN / f"predictions_{e}.csv")
        d = ab.prepare(load(e))
        ids, y = p.measurement_id.to_numpy(), p.y_det.to_numpy()
        assert (d.measurement_id.to_numpy() == ids).all()
        rows = [(f"MLP seed {s}", sp.confirmed(p[f"p_seed{s}"].to_numpy() > 0.5), "tab:purple") for s in (0, 1, 2)]
        for name, cfg in sp.DETECTORS.items():
            sc, tau, _ = sp.commissioned_alarm(d, cfg)
            rows.append((name.replace(" (prototype)", "\n(prototype)"), sp.confirmed(sc > tau), "tab:green"))
        rows.append(("rig stop rule\n(rear RMS > 6.5 g)", sp.confirmed(d.accA_rms.to_numpy() > sp.RIG_LIMIT_G), "tab:red"))
        width = np.median(np.diff(ids))
        for val, col in ((0, "tab:blue"), (1, "tab:orange")):
            for a, n in runs(y == val):
                ax.axvspan(ids[a] - width / 2, ids[a + n - 1] + width / 2, color=col, alpha=0.18, lw=0)
        for k, (name, conf, col) in enumerate(rows):
            ax.broken_barh([(ids[a] - width / 2, n * width) for a, n in runs(conf)], (k - 0.35, 0.7), color=col)
        ax.set_yticks(range(len(rows)))
        ax.set_yticklabels([r[0] for r in rows], fontsize=7)
        ax.set_ylim(len(rows) - 0.5, -0.5)
        ax.set_xlim(ids[0] - width, ids[-1] + width)
        ax.set_title(f"{e} held out: confirmed alarm (3 in a row above threshold). "
                     "Blue band = healthy labels, orange band = deteriorated labels", fontsize=9)
    axs[-1].set_xlabel("measurement id")
    fig.tight_layout()
    fig.savefig(FIG / "alarm_timeline.png", dpi=140)
    plt.close(fig)


def dashboard_screenshot(tmp):
    """Serve model/ on a free local port and screenshot the finished dashboard."""
    class Quiet(http.server.SimpleHTTPRequestHandler):
        def log_message(self, *a):
            pass
    handler = functools.partial(Quiet, directory=str(HERE))
    srv = http.server.ThreadingHTTPServer(("127.0.0.1", 0), handler)
    threading.Thread(target=srv.serve_forever, daemon=True).start()
    try:
        url = f"http://127.0.0.1:{srv.server_address[1]}/training_dashboard.html?theme=light"
        subprocess.run([chrome(), "--headless=new", "--disable-gpu", "--hide-scrollbars", f"--user-data-dir={tmp / 'shot'}",
                        "--window-size=1240,1560", "--virtual-time-budget=8000", f"--screenshot={FIG / 'dashboard.png'}", url],
                       check=True, capture_output=True, timeout=120)
    finally:
        srv.shutdown()


def main():
    FIG.mkdir(parents=True, exist_ok=True)
    tmp = Path(tempfile.mkdtemp(prefix="mg_run1_report_"))
    alarm_timeline()
    dashboard_screenshot(tmp)
    body = convert(SRC.read_text(encoding="utf-8"), SRC.parent, BREAKS)
    page_html = (f'<!doctype html><html><head><meta charset="utf-8"><title>Training run 1 report</title>'
                 f"<style>{CSS}</style></head><body>{body}</body></html>")
    page = tmp / "report.html"
    page.write_text(page_html, encoding="utf-8")
    OUT.parent.mkdir(parents=True, exist_ok=True)
    subprocess.run([chrome(), "--headless=new", "--disable-gpu", "--no-pdf-header-footer",
                    f"--user-data-dir={tmp / 'profile'}", f"--print-to-pdf={OUT}", page.as_uri()],
                   check=True, capture_output=True, timeout=120)
    if "--keep-html" in sys.argv:
        print(f"HTML: {page}")
    else:
        shutil.rmtree(tmp, ignore_errors=True)
    print(f"wrote {OUT} ({OUT.stat().st_size // 1024} KB)")


if __name__ == "__main__":
    main()
