"""docs/Model/12_Run3_model_summary.md as a PDF: docs/Model/12_Run3_model_summary.pdf (summary of the Run 3 model).

  python report/make_run3_summary_report.py     (inside model/)

The Markdown is written by hand from model/results/supervised/run3/ and docs/Model/10_Training_run3.md.
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from pro_report import build_pdf   # noqa: E402

HERE = Path(__file__).resolve().parent.parent
DOCS = HERE.parent / "docs" / "Model"


def main():
    build_pdf(DOCS / "12_Run3_model_summary.md", DOCS / "12_Run3_model_summary.pdf",
              "Machine Guardian — Run 3 Model Summary",
              "The bearing-deterioration multi-task MLP selected in Training Run 3: data, inputs, parameters, training, "
              "outputs, results and hardware",
              ["MAC-Attack senior capstone · Machine Guardian",
               "Configuration E, trained on 7 Paderborn development bearings · 9 November 2026",
               "Source: model/results/supervised/run3/ and docs/Model/10_Training_run3.md",
               "The output is a deterioration score, not a validated probability of physical failure."],
              stats=[("850", "parameters: 8 → 32 → 16 → 2"),
                     ("6 of 7", "held-out bearings alarmed before the stop"),
                     ("1.78 µs", "per measurement on the 8 × 8 array (RTL simulation)")],
              breaks=(2, 3, 5, 6, 8, 9, 10))
    print(f"wrote {DOCS / '12_Run3_model_summary.pdf'}")


if __name__ == "__main__":
    main()
