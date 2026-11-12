"""The label review packet and the review-step report as PDFs:
docs/Model/supporting_label_review/07a_Label_review_packet.pdf (one review item per page), 07b_Review_step_report.pdf,
07c_Wording_revision_report.pdf, 07d_Label_review_instructions.pdf and 07e_Review_instructions_report.pdf.

  python report/make_review_docs.py     (inside model/)

Same Markdown converter and headless-Chrome printing as make_paderborn_baseline_report.py.
"""
import shutil, subprocess, sys, tempfile
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from make_paderborn_baseline_report import CSS, browser, convert   # noqa: E402

HERE = Path(__file__).resolve().parent.parent
DOCS = HERE.parent / "docs" / "Model" / "supporting_label_review"
SUP = HERE / "results" / "supervised"
# (source, output, title, the ## sections that start a new page)
JOBS = [(SUP / "LABEL_REVIEW_PACKET.md", DOCS / "07a_Label_review_packet.pdf", "Label review packet", tuple(range(1, 16))),
        (SUP / "REVIEW_STEP_REPORT.md", DOCS / "07b_Review_step_report.pdf", "Review step report", (3, 4)),
        (SUP / "WORDING_REVISION_REPORT.md", DOCS / "07c_Wording_revision_report.pdf", "Wording revision report", (4,)),
        (SUP / "LABEL_REVIEW_INSTRUCTIONS.md", DOCS / "07d_Label_review_instructions.pdf", "Label review instructions", (5, 7)),
        (SUP / "REVIEW_INSTRUCTIONS_REPORT.md", DOCS / "07e_Review_instructions_report.pdf", "Review instructions report", (3,))]


def build(src, out, title, breaks):
    body = convert(src.read_text(encoding="utf-8"), src.parent, breaks)
    page_html = (f'<!doctype html><html><head><meta charset="utf-8"><title>{title}</title>'
                 f"<style>{CSS}</style></head><body>{body}</body></html>")
    tmp = Path(tempfile.mkdtemp(prefix="mg_review_docs_"))
    try:
        page = tmp / "report.html"
        page.write_text(page_html, encoding="utf-8")
        subprocess.run([browser(), "--headless=new", "--disable-gpu", "--no-pdf-header-footer",
                        f"--user-data-dir={tmp / 'profile'}", f"--print-to-pdf={out}", page.as_uri()],
                       check=True, capture_output=True, timeout=120)
    finally:
        shutil.rmtree(tmp, ignore_errors=True)
    print(f"wrote {out} ({out.stat().st_size // 1024} KB)")


def main():
    DOCS.mkdir(parents=True, exist_ok=True)
    for job in JOBS:
        build(*job)


if __name__ == "__main__":
    main()
