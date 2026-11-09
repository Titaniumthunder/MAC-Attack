"""Run 3 report and the updated ML development report (v2), Markdown + PDF (inside model/; run run3_figures.py,
run3_tables.py and run3_diagrams.py first):

  python report/make_run3_reports.py
    -> docs/Multitask_MLP_reports/Machine_Guardian_Training_Run3_Report.md / .pdf
       docs/Multitask_MLP_reports/Machine_Guardian_ML_Development_and_Training_Results_v2.md / .pdf  (the original v1
       report is not touched)
The Run 3 Markdown is composed from results/supervised/run3/TRAINING_RUN3_REPORT.template.md and the generated
analysis/tables.md ({{T_NAME}} placeholders), so every table number comes from the saved results.
"""
import re, shutil, sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from pro_report import build_pdf   # noqa: E402

HERE = Path(__file__).resolve().parent.parent
RUN3 = HERE / "results" / "supervised" / "run3"
DOCS = HERE.parent / "docs" / "Multitask_MLP_reports"


def compose():
    tables = (RUN3 / "analysis" / "tables.md").read_text(encoding="utf-8")
    parts = dict(re.findall(r"<!-- (T_[A-Z0-9_]+) -->\n(.*?)(?=\n<!-- T_|\Z)", tables, flags=re.S))
    text = (RUN3 / "TRAINING_RUN3_REPORT.template.md").read_text(encoding="utf-8")
    for k, v in parts.items():
        text = text.replace("{{" + k + "}}", v.strip())
    left = re.findall(r"\{\{T_[A-Z0-9_]+\}\}", text)
    if left:
        raise SystemExit(f"unfilled placeholders: {left}")
    return text


def main():
    md = compose()
    out_md = DOCS / "Machine_Guardian_Training_Run3_Report.md"
    out_md.write_text(md, encoding="utf-8")
    shutil.copyfile(out_md, RUN3 / "TRAINING_RUN3_REPORT.md")
    build_pdf(out_md, DOCS / "Machine_Guardian_Training_Run3_Report.pdf",
              "Machine Guardian — Training Run 3 and Expanded Dataset Evaluation",
              "Seven Paderborn development bearings (four new), nested leave-one-bearing-out validation, five training "
              "configurations, INT8 and RTL verification of the trained 8 → 32 → 16 → 2 multi-task MLP",
              ["MAC-Attack senior capstone · Machine Guardian",
               "Prepared with Claude Code · 3 November 2026",
               "Source: model/results/supervised/run3/ (prep, train, hardware, supplement, analysis)",
               "The output is a deterioration score, not a validated probability of physical failure."],
              stats=[("7", "development bearings, 4 new (B08, B09, B11, B12)"),
                     ("6 of 7", "bearings alarmed before the stop (B12 missed)"),
                     ("1.78 µs", "per inference, trained network on the RTL")],
              breaks=(2, 4, 5, 7, 9, 10, 11, 12, 14, 15, 16, 17))
    v2 = DOCS / "Machine_Guardian_ML_Development_and_Training_Results_v2.md"
    if v2.exists():
        build_pdf(v2, DOCS / "Machine_Guardian_ML_Development_and_Training_Results_v2.pdf",
                  "Machine Guardian — ML Model Development and Training Results",
                  "Version 2: from the original Ottawa motor model, through the Paderborn redesign, to Training Run 3 on "
                  "seven development bearings",
                  ["MAC-Attack senior capstone · Machine Guardian",
                   "Version 2 · prepared with Claude Code · 3 November 2026 (version 1, covering Runs 1-2, is kept unchanged)",
                   "Sources: the project repository (code, docs/log.md, earlier reports, saved results)"],
                  stats=[("850", "parameters: 8 → 32 → 16 → 2 multi-task MLP"),
                         ("7", "labelled development bearings (Run 3)"),
                         ("8 × 8", "INT8 systolic array on the ZedBoard FPGA")],
                  breaks=(2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12))


if __name__ == "__main__":
    main()
