"""Material for the manual label review (run labels.py and supervised_prep.py first).

  python label_review.py   -> results/supervised/figures/labels_overview.png, label_review.TEMPLATE.json

The template lists every item a person must confirm against the documents, bound to the current label_table.json by its
SHA-256. To sign off: copy it to label_review.json, set every "confirmed" to true (or edit the label table and rerun),
fill in "checked_by" and "date". supervised_prep.ready() accepts only a sign-off of the current table.
"""
import json

import matplotlib
matplotlib.use("Agg")
import matplotlib.dates as mdates
import matplotlib.pyplot as plt
import pandas as pd

import anomaly_baseline as ab
import labels as lb
import supervised_prep as sp
from paderborn import META, load

ITEMS = [
    ("all", "Defect types after dismantling (B01 IR, OR, B; B02 IR; B03 IR; B04 IR, B) match Table 3 of the official dataset description (Zenodo 10.5281/zenodo.10805042); they were transcribed, not read from a local file", 'Dataset description v2 (Aimiyekagbon, 25 Mar 2024, Zenodo 10.5281/zenodo.10805042) p.8 Table 3, Defect column'),
    ("all", "Assumptions A1-A4 in label_table.json are acceptable. The final five measurements of B02, B03 and B04 are PROVISIONAL END-STAGE PROXY LABELS: they stand for the end-of-test state of a bearing found damaged after dismantling (description Table 3), not a verified deteriorated state at those measurements. The exact damage onset is unknown (A3). The rig stopping at its vibration or temperature threshold does not by itself prove that the bearing defect caused the stop (A2 is an assumption). The healthy labels rest on 'no defect was initiated' and 'Begin with a new bearing' (A4)", "Dataset description v2 (Aimiyekagbon, 25 Mar 2024, Zenodo 10.5281/zenodo.10805042) p.2 'No defect was initiated'; p.8 Table 3; logs p.2; A1-A3 have no document (dismantling time not given anywhere)"),
    ("all", "START_N = 100 and END_N = 5 (fixed 2 Nov 2026 before B02/B04 were seen) are kept; B01's start labels withheld", 'labels.py (rule fixed 2 Nov 2026); label review decision 2 Nov 2026 (B01 withheld)'),
    ("all", "The end labels of B02 and B04 sit where the rig's vibration stop rule fired on the same rear accelerometer the model uses: accepted, provided every trained head is compared with that rule (it is in baseline_comparison.json)", 'Dataset description v2 (Aimiyekagbon, 25 Mar 2024, Zenodo 10.5281/zenodo.10805042) p.4 T_vibration in [6, 10] g; p.8 Table 3 B02, B04 = T_vibration; B02_log.pdf p.2 (0.65 V); B04_log.pdf p.2'),
    ("B01", "End label withheld (no stop criterion pre-set; recording continues 272 measurements past the logged stop)", "Dataset description v2 (Aimiyekagbon, 25 Mar 2024, Zenodo 10.5281/zenodo.10805042) p.4 'for experiment B01 no criteria was pre-set'; p.8 Table 3 B01 '-'; B01_log.pdf p.2 (09:13 entry); checks.json"),
    ("B01", "No healthy labels (decided 2 Nov 2026, walkthrough item 6): T1 reached the 110 degC stop temperature 16 min after warm-up (09:12:49; log 09:13), the test restarted twice afterwards, and the bearing had run up to 15 min the day before. With the end label also withheld, B01 has no label and is left out of the folds", "B01_log.pdf p.2 (08:45 and 09:13 entries); description p.4 (110 degC); processed T1 (first at or above 110 degC 09:12:49)"),
    ("B02", "Start M0052-M0151 healthy: log 08:59 'Begin with a new bearing'", "B02_log.pdf p.2 (08:59 'Begin with a new bearing'); Dataset description v2 (Aimiyekagbon, 25 Mar 2024, Zenodo 10.5281/zenodo.10805042) p.2"),
    ("B02", "End M1112-M1116 (14:35:29-14:36:36) deteriorated: log 14:36 stop, RMS above 0.65 V four times; recording ends 36 s after the logged stop", 'B02_log.pdf p.2 (14:36 entry); Dataset description v2 (Aimiyekagbon, 25 Mar 2024, Zenodo 10.5281/zenodo.10805042) p.4, p.8; checks.json last record 36 s after 14:36'),
    ("B02", "The 13:32 stop (vibration limit crossed twice, M0920-M0921 above 6.5 g in our data) was NOT a dismantling: the test continued, so M0921 and its neighbours stay masked", 'B02_log.pdf p.2 (13:32 entry); checks.json stop 13:32:36-13:37:18'),
    ("B02", "Our 1.6-s RMS is above 6.5 g in 13 measurements after the restart while the log counts four crossings: the rig's RMS window differs from ours; no label depends on this count", "B02_log.pdf p.2 (14:36 'four times'); processed rear RMS"),
    ("B03", "Start M0001-M0100 healthy (B03's warm-up is not in the recording, so the first 100 are at test conditions)", "B03_log.pdf p.2 (15:10 'Begin with a new bearing', warm-up described); Dataset description v2 (Aimiyekagbon, 25 Mar 2024, Zenodo 10.5281/zenodo.10805042) p.2; first record 15:10:43, no warm-up rows"),
    ("B03", "End M0610-M0614 (18:22:25-18:23:40) deteriorated: log 18:23 automatic stop, housing temperature above 110 degC", 'B03_log.pdf p.2 (18:23 entry, 110 degC); Dataset description v2 (Aimiyekagbon, 25 Mar 2024, Zenodo 10.5281/zenodo.10805042) p.4, p.8; T1 first above 110 degC at M0612 18:23:02'),
    ("B04", "Start M0051-M0150 healthy: log 12:45 'Begin with a new bearing'", "B04_log.pdf p.2 (12:45 'Begin with a new bearing'); Dataset description v2 (Aimiyekagbon, 25 Mar 2024, Zenodo 10.5281/zenodo.10805042) p.2"),
    ("B04", "End M1110-M1114 (18:25:44-18:26:58) deteriorated: log 18:26 stop, RMS above the specified limit (value not stated)", 'B04_log.pdf p.2 (18:26 entry, limit value not stated); Dataset description v2 (Aimiyekagbon, 25 Mar 2024, Zenodo 10.5281/zenodo.10805042) p.4 ([6, 10] g), p.8'),
    ("B04", "SUSPECTED logging/scaling discrepancy, NOT confirmed by the dataset authors: B04's recorded measured speed is 0.498-0.500 x and its peak dynamic load about 0.52 x the set values in every row (static load normal). Our vibration analysis supports, but does not prove, that the shaft ran at the set speed and these two columns were logged at half scale: in 14 files from M0001 to M1114 the shaft-frequency line sits at the set speed, with only background at the recorded speed. Neither the description nor the B04 log mentions it. Data kept as recorded; labels never use speed; the 8 inputs are identical with the speed doubled", 'Dataset description v2 (Aimiyekagbon, 25 Mar 2024, Zenodo 10.5281/zenodo.10805042) p.7 (meanAbs_speed = measured speed, no scale note); B04_log.pdf p.1 (T_high ranges); vibration spectrum (14 files, M0001-M1114)'),
]


def figure(bearings):
    fig, axs = plt.subplots(len(bearings), 1, figsize=(9, 2.3 * len(bearings)))
    for ax, e in zip(axs, bearings):
        d = ab.prepare(load(e))
        y, info = lb.label(e)
        ax.plot(d.timestamp, d.accA_rms, ".", ms=2.5, color=ab.MUTED, label="masked (no label)")
        for val, col, lab in ((0, ab.AQUA, "start: healthy (0)"), (1, ab.ORANGE, "end: deteriorated (1)")):
            k = (y.y_det == val).to_numpy()
            ax.plot(d.timestamp[k], d.accA_rms[k], ".", ms=4, color=col, label=lab)
        ax.axhline(sp.RIG_LIMIT_G, color=ab.INK2, linestyle="--", linewidth=0.8)
        for t, _ in (META["experiments"][e].get("log") or [])[1:]:
            ax.axvline(pd.Timestamp(t), color=ab.INK2, linestyle=":", linewidth=0.9)
        ax.set_yscale("log")
        ax.set_ylabel(f"{e}: rear RMS (g)")
        ax.xaxis.set_major_formatter(mdates.DateFormatter("%H:%M"))
        if info["end"]["label"] is None:
            ax.text(0.99, 0.06, "no labels (start and end withheld)" if info["start"]["label"] is None
                    else "end label withheld", transform=ax.transAxes, ha="right", fontsize=8, color=ab.INK2)
    axs[0].legend(loc="lower left", bbox_to_anchor=(0, 1.0), ncol=3, fontsize=8)
    axs[-1].set_xlabel("Time (dotted: log entries after the start; dashed: 6.5 g, the B02 log's vibration limit)")
    fig.tight_layout()
    (lb.OUT / "figures").mkdir(exist_ok=True)
    fig.savefig(lb.OUT / "figures" / "labels_overview.png", dpi=150)
    plt.close(fig)


def main():
    doc = json.loads((lb.OUT / "label_table.json").read_text(encoding="utf-8"))
    figure(list(doc["table"]["bearings"]))
    tpl = {"label_table_sha256": doc["sha256"], "checked_by": None, "date": None,
           "independent_check_by": None, "independent_check_date": None,
           "items": [{"bearing": b, "check": c, "source": sr, "confirmed": None, "comment": ""} for b, c, sr in ITEMS]}
    (lb.OUT / "label_review.TEMPLATE.json").write_text(json.dumps(tpl, indent=1) + "\n", encoding="utf-8")
    print(f"{len(ITEMS)} items to confirm; label_table sha256 {doc['sha256'][:16]}...")


if __name__ == "__main__":
    main()
