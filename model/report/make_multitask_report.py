"""results/multitask/MULTITASK_ARCHITECTURE_REPORT.md as a PDF: docs/Multitask_MLP_reports/Multitask_architecture_report.pdf.

  python report/make_multitask_report.py     (inside model/; --keep-html prints the intermediate page)

Same Markdown converter and headless-Chrome printing as make_paderborn_baseline_report.py.
"""
import shutil, subprocess, sys, tempfile
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from make_paderborn_baseline_report import CSS, browser, convert   # noqa: E402

HERE = Path(__file__).resolve().parent.parent
SRC = HERE / "results" / "multitask" / "MULTITASK_ARCHITECTURE_REPORT.md"
OUT = HERE.parent / "docs" / "Multitask_MLP_reports" / "Multitask_architecture_report.pdf"
BREAKS = (4, 5, 8)


def main():
    body = convert(SRC.read_text(encoding="utf-8"), SRC.parent, BREAKS)
    page_html = (f'<!doctype html><html><head><meta charset="utf-8"><title>Multi-task architecture report</title>'
                 f"<style>{CSS}</style></head><body>{body}</body></html>")
    tmp = Path(tempfile.mkdtemp(prefix="mg_mtl_report_"))
    page = tmp / "report.html"
    page.write_text(page_html, encoding="utf-8")
    OUT.parent.mkdir(parents=True, exist_ok=True)
    subprocess.run([browser(), "--headless=new", "--disable-gpu", "--no-pdf-header-footer",
                    f"--user-data-dir={tmp / 'profile'}", f"--print-to-pdf={OUT}", page.as_uri()],
                   check=True, capture_output=True, timeout=120)
    if "--keep-html" in sys.argv:
        print(f"HTML: {page}")
    else:
        shutil.rmtree(tmp, ignore_errors=True)
    print(f"wrote {OUT} ({OUT.stat().st_size // 1024} KB)")


if __name__ == "__main__":
    main()
