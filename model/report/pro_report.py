"""A Markdown report as a formatted PDF: cover page, contents, styled tables and callouts, page numbers.

  from pro_report import build_pdf
  build_pdf(src_md, out_pdf, title, subtitle, meta)

Uses the repo's Markdown converter (make_paderborn_baseline_report.convert: headings, paragraphs, lists, tables, block
quotes, images, code) and prints with headless Chrome. The first '# ' heading of the Markdown is replaced by the cover.
Block quotes render as callout boxes; a quote that starts with **Key finding** or **Caution** gets that style.
"""
import html, re, shutil, subprocess, sys, tempfile
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from make_paderborn_baseline_report import convert   # noqa: E402

MAC_CHROME = Path("/Applications/Google Chrome.app/Contents/MacOS/Google Chrome")

CSS = """
@page { size: A4; margin: 17mm 15mm 18mm 15mm;
        @bottom-right { content: counter(page); font: 8pt 'Helvetica Neue', Arial, sans-serif; color: #6b7280; }
        @bottom-left { content: "Machine Guardian · MAC-Attack capstone"; font: 8pt 'Helvetica Neue', Arial, sans-serif; color: #9ca3af; } }
@page :first { margin: 0; @bottom-right { content: none; } @bottom-left { content: none; } }
:root { --navy: #1f3a5f; --blue: #2f7fbf; --ink: #111827; --muted: #6b7280; --line: #e5e7eb; --tint: #f3f6fa; }
* { box-sizing: border-box; }
body { font-family: 'Helvetica Neue', 'Segoe UI', Arial, sans-serif; color: var(--ink); font-size: 9.6pt; line-height: 1.5; margin: 0; }
.cover { height: 297mm; width: 210mm; position: relative; break-after: page; background: #ffffff; overflow: hidden; }
.cover .band { position: absolute; top: 0; left: 0; right: 0; height: 118mm; background: linear-gradient(135deg, #1f3a5f 0%, #2f5f8f 100%); }
.cover .chip { position: absolute; top: 22mm; left: 20mm; color: #cfe0f3; font-size: 10pt; letter-spacing: 2px; text-transform: uppercase; }
.cover h1.title { position: absolute; top: 46mm; left: 20mm; right: 20mm; color: #ffffff; font-size: 27pt; line-height: 1.15; margin: 0; font-weight: 700; letter-spacing: -0.4px; }
.cover .subtitle { position: absolute; top: 132mm; left: 20mm; right: 20mm; color: var(--navy); font-size: 13pt; line-height: 1.4; }
.cover .meta { position: absolute; bottom: 24mm; left: 20mm; right: 20mm; color: var(--muted); font-size: 9.5pt; line-height: 1.7; border-top: 1px solid var(--line); padding-top: 6mm; }
.cover .grid { position: absolute; top: 168mm; left: 20mm; right: 20mm; display: grid; grid-template-columns: repeat(3, 1fr); gap: 5mm; }
.cover .stat { border: 1px solid var(--line); border-radius: 3mm; padding: 4mm 5mm; }
.cover .stat b { display: block; font-size: 16pt; color: var(--navy); }
.cover .stat span { font-size: 8.4pt; color: var(--muted); }
.toc { break-after: page; padding-top: 4mm; }
.toc h2 { border: none; margin-top: 0; }
.toc ol { padding-left: 0; list-style: none; counter-reset: toc; }
.toc li { counter-increment: toc; padding: 2.2mm 0; border-bottom: 1px dotted #cbd5e1; font-size: 10.5pt; }
.toc li::before { content: counter(toc, decimal-leading-zero); color: var(--blue); font-weight: 700; display: inline-block; width: 10mm; }
h1 { font-size: 20pt; color: var(--navy); margin: 0 0 8px; }
h2 { font-size: 14pt; color: var(--navy); margin: 22px 0 8px; padding: 0 0 5px; border-bottom: 2px solid var(--navy); break-after: avoid; }
h3 { font-size: 11pt; color: #1f2937; margin: 14px 0 5px; break-after: avoid; }
h4 { font-size: 9.8pt; color: var(--blue); margin: 10px 0 4px; break-after: avoid; }
p { margin: 4px 0 8px; }
table { border-collapse: collapse; width: 100%; margin: 7px 0 12px; font-size: 8.4pt; break-inside: avoid; }
thead th { background: var(--navy); color: #ffffff; text-align: left; font-weight: 600; padding: 4px 6px; }
td { border-bottom: 1px solid var(--line); padding: 3.5px 6px; vertical-align: top; }
tbody tr:nth-child(even) td { background: #f8fafc; }
code { font-family: 'SF Mono', Menlo, Consolas, monospace; font-size: 8pt; background: #eef2f7; padding: 0 3px; border-radius: 3px; }
pre { background: #0f172a; color: #e2e8f0; padding: 8px 10px; border-radius: 4px; font-size: 7.8pt; white-space: pre-wrap; break-inside: avoid; }
pre code { background: none; color: inherit; padding: 0; }
blockquote { border-left: 4px solid var(--blue); background: var(--tint); margin: 10px 0; padding: 7px 12px; border-radius: 0 4px 4px 0; break-inside: avoid; }
blockquote.key { border-left-color: #2e8b57; background: #eef8f2; }
blockquote.caution { border-left-color: #d97706; background: #fdf6ea; }
img { width: 100%; margin: 8px 0 3px; break-inside: avoid; border-radius: 2px; }
ul, ol { margin: 4px 0 9px; padding-left: 20px; } li { margin: 2.5px 0; }
h2.pb { break-before: page; }
"""


def chrome():
    if MAC_CHROME.exists():
        return str(MAC_CHROME)
    from make_single_accel_report import browser
    return browser()


def cover(title, subtitle, meta, stats=()):
    cells = "".join(f'<div class="stat"><b>{html.escape(v)}</b><span>{html.escape(k)}</span></div>' for v, k in stats)
    return (f'<section class="cover"><div class="band"></div><div class="chip">Machine Guardian · MAC-Attack</div>'
            f'<h1 class="title">{html.escape(title)}</h1><div class="subtitle">{html.escape(subtitle)}</div>'
            f'{"<div class=grid>" + cells + "</div>" if cells else ""}'
            f'<div class="meta">{"<br>".join(html.escape(m) for m in meta)}</div></section>')


def build_pdf(src, out, title, subtitle, meta, stats=(), breaks=(), toc=True):
    md = Path(src).read_text(encoding="utf-8")
    md = re.sub(r"\A# .*\n", "", md, count=1)
    body = convert(md, Path(src).parent, breaks)
    body = re.sub(r"<blockquote><b>Key finding", '<blockquote class="key"><b>Key finding', body)
    body = re.sub(r"<blockquote><b>Caution", '<blockquote class="caution"><b>Caution', body)
    heads = [re.sub(r"^\d+\.\s*", "", h) for h in re.findall(r"<h2(?: class=\"pb\")?>(.*?)</h2>", body)]
    contents = ('<section class="toc"><h2>Contents</h2><ol>' + "".join(f"<li>{h}</li>" for h in heads)
                + "</ol></section>") if toc else ""
    page = (f'<!doctype html><html><head><meta charset="utf-8"><title>{html.escape(title)}</title><style>{CSS}</style>'
            f"</head><body>{cover(title, subtitle, meta, stats)}{contents}{body}</body></html>")
    tmp = Path(tempfile.mkdtemp(prefix="mg_pro_report_"))
    try:
        p = tmp / "report.html"
        p.write_text(page, encoding="utf-8")
        Path(out).parent.mkdir(parents=True, exist_ok=True)
        subprocess.run([chrome(), "--headless=new", "--disable-gpu", "--no-pdf-header-footer",
                        f"--user-data-dir={tmp / 'profile'}", f"--print-to-pdf={out}", p.as_uri()],
                       check=True, capture_output=True, timeout=180)
    finally:
        shutil.rmtree(tmp, ignore_errors=True)
    print(f"wrote {out} ({Path(out).stat().st_size // 1024} KB)")
