"""The Run 2 comparison report and the ML development report as PDFs (inside model/; run run2_figures.py and
dev_report_figures.py first):

  python report/make_run2_reports.py
    -> docs/Model/09_Training_run2.pdf
       docs/Model/superseded/Development_history_v1_Ottawa_to_Run2.pdf
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from pro_report import build_pdf   # noqa: E402

HERE = Path(__file__).resolve().parent.parent
DOCS = HERE.parent / "docs" / "Model"


def main():
    build_pdf(HERE / "results" / "supervised" / "run2" / "TRAINING_RUN2_REPORT.md", DOCS / "09_Training_run2.pdf",
              "Training Run 2: Latched Alarm, Comparison and Calibration",
              "Deterioration head of the 8 → 32 → 16 → 2 multi-task MLP, Paderborn bearings B02–B04, "
              "leave-one-bearing-out",
              ["Prepared with Claude Code · 3 November 2026",
               "Source: model/results/supervised/run2/ · script model/train_deterioration_run2.py",
               "The output is a deterioration score, not a validated probability of physical failure."],
              stats=[("1", "alarm-state change per bearing (latched; was up to 47)"),
                     ("0 / 300", "healthy-reference rows alarmed"),
                     ("1.78 µs", "per inference, trained network on the RTL")],
              breaks=(4, 7, 8, 9))
    build_pdf(DOCS / "superseded" / "Development_history_v1_Ottawa_to_Run2.md",
              DOCS / "superseded" / "Development_history_v1_Ottawa_to_Run2.pdf",
              "Machine Guardian — ML Model Development and Training Results",
              "From the original Ottawa motor model, through the redesign on Paderborn run-to-failure bearing data, "
              "to Training Run 2",
              ["MAC-Attack senior capstone · Machine Guardian",
               "Prepared with Claude Code · 3 November 2026",
               "Sources: the project repository (code, docs/log.md, earlier reports, saved results)"],
              stats=[("850", "parameters: 8 → 32 → 16 → 2 multi-task MLP"),
                     ("9", "trained networks, leave-one-bearing-out (Runs 1–2)"),
                     ("8 × 8", "INT8 systolic array on the ZedBoard FPGA")],
              breaks=(2, 3, 4, 6, 7, 9, 10))


if __name__ == "__main__":
    main()
