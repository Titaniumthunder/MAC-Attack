"""results/paderborn/PADERBORN_BASELINE_REPORT.md as a PDF: docs/Model/04_Paderborn_anomaly_detector_baseline.pdf.

  python report/make_paderborn_baseline_report.py     (inside model/)

The Markdown is the single source: a small converter below handles what the report uses (headings, paragraphs, bullet
and numbered lists, tables, block quotes, images, code blocks, **bold**, `code`, *italic*), images are embedded, and
the page is printed by headless Chrome or Edge as the other reports.
"""
import base64, html, re, shutil, subprocess, sys, tempfile
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from make_single_accel_report import browser   # noqa: E402

HERE = Path(__file__).resolve().parent.parent
SRC = HERE / "results" / "paderborn" / "PADERBORN_BASELINE_REPORT.md"
OUT = HERE.parent / "docs" / "Model" / "04_Paderborn_anomaly_detector_baseline.pdf"

CSS = """
@page { size: A4; margin: 15mm 14mm; }
body { font-family: 'Segoe UI', Arial, sans-serif; color: #0b0b0b; font-size: 9.5pt; line-height: 1.42; margin: 0; }
h1 { font-size: 19pt; margin: 0 0 8px; letter-spacing: -0.3px; }
h2 { font-size: 13pt; margin: 18px 0 6px; padding-top: 7px; border-top: 1.5px solid #0b0b0b; break-after: avoid; }
h3 { font-size: 10.5pt; margin: 12px 0 4px; break-after: avoid; }
p { margin: 4px 0 7px; }
table { border-collapse: collapse; width: 100%; margin: 6px 0 10px; font-size: 8.3pt; break-inside: avoid; }
th { text-align: left; font-weight: 600; color: #52514e; border-bottom: 1px solid #8a8984; padding: 3px 5px; }
td { border-bottom: 1px solid #e4e3df; padding: 3px 5px; vertical-align: top; }
code { font-family: Consolas, monospace; font-size: 8.1pt; background: #f3f2ef; padding: 0 3px; border-radius: 3px; }
pre { background: #f3f2ef; padding: 6px 8px; border-radius: 4px; font-size: 8pt; white-space: pre-wrap; break-inside: avoid; }
pre code { background: none; padding: 0; }
blockquote { border-left: 3px solid #eda100; background: #fdf8ec; margin: 8px 0; padding: 5px 10px; break-inside: avoid; }
img { width: 100%; margin: 6px 0 2px; break-inside: avoid; }
ul, ol { margin: 4px 0 8px; padding-left: 20px; } li { margin: 2px 0; }
li > ul, li > ol { margin: 2px 0; }
h2.pb { break-before: page; }
"""


def inline(t, base):
    out, pos = [], 0
    for m in re.finditer(r"`([^`]+)`", t):
        out.append(fmt(t[pos:m.start()]))
        out.append(f"<code>{html.escape(m.group(1))}</code>")
        pos = m.end()
    out.append(fmt(t[pos:]))
    return "".join(out)


def fmt(t):
    t = html.escape(t, quote=False)
    t = re.sub(r"\*\*(.+?)\*\*", r"<b>\1</b>", t)
    t = re.sub(r"(?<![\w*])\*(?!\s)(.+?)(?<!\s)\*(?![\w*])", r"<i>\1</i>", t)
    t = re.sub(r"\^(\d+\.?\d*)", r"<sup>\1</sup>", t)
    return t


def image(line, base):
    m = re.match(r"!\[(.*?)\]\((.+?)\)", line.strip())
    data = base64.b64encode((base / m.group(2)).read_bytes()).decode()
    return f'<img alt="{html.escape(m.group(1))}" src="data:image/png;base64,{data}">'


def lists(lines, base):
    """Nested bullet/numbered lists from indented lines (2 or 3 spaces per level)."""
    html_out, stack = [], []
    for ln in lines:
        ind = len(ln) - len(ln.lstrip())
        s = ln.strip()
        m = re.match(r"(\d+)\.\s+(.*)", s)
        kind, text = ("ol", m.group(2)) if m else ("ul", s[2:])
        if stack and ind > stack[-1][1]:
            html_out.append(f"<{kind}>")
            stack.append((kind, ind))
        else:
            while stack and ind < stack[-1][1]:
                html_out.append(f"</li></{stack.pop()[0]}>")
            if stack:
                html_out.append("</li>")
            else:
                html_out.append(f"<{kind}>")
                stack.append((kind, ind))
        html_out.append(f"<li>{inline(text, base)}")
    while stack:
        html_out.append(f"</li></{stack.pop()[0]}>")
    return "".join(html_out)


def convert(md, base, breaks=(4, 6, 7)):
    """breaks: the numbers of the ## sections that start a new page."""
    lines = md.splitlines()
    out, i, h2 = [], 0, 0
    while i < len(lines):
        ln = lines[i]
        s = ln.strip()
        if not s:
            i += 1
        elif s.startswith("```"):
            j = i + 1
            while not lines[j].strip().startswith("```"):
                j += 1
            out.append("<pre><code>" + html.escape("\n".join(lines[i + 1:j])) + "</code></pre>")
            i = j + 1
        elif s.startswith("#"):
            n = len(s) - len(s.lstrip("#"))
            cls = ""
            if n == 2:
                h2 += 1
                cls = ' class="pb"' if h2 in breaks else ""
            out.append(f"<h{n}{cls}>{inline(s[n:].strip(), base)}</h{n}>")
            i += 1
        elif s.startswith("!["):
            out.append(image(s, base))
            i += 1
        elif s.startswith(">"):
            j, buf = i, []
            while j < len(lines) and lines[j].strip().startswith(">"):
                buf.append(lines[j].strip()[1:].strip())
                j += 1
            out.append(f"<blockquote>{inline(' '.join(buf), base)}</blockquote>")
            i = j
        elif s.startswith("|"):
            j, rows = i, []
            while j < len(lines) and lines[j].strip().startswith("|"):
                rows.append([c.strip() for c in lines[j].strip().strip("|").split("|")])
                j += 1
            head, body = rows[0], [r for r in rows[2:]]
            t = "<table><thead><tr>" + "".join(f"<th>{inline(c, base)}</th>" for c in head) + "</tr></thead><tbody>"
            t += "".join("<tr>" + "".join(f"<td>{inline(c, base)}</td>" for c in r) + "</tr>" for r in body)
            out.append(t + "</tbody></table>")
            i = j
        elif re.match(r"(- |\d+\.\s)", s):
            j, buf = i, []
            while j < len(lines) and lines[j].strip() and not lines[j].strip().startswith(("|", "#", "!", ">", "```")):
                cur = lines[j]
                if re.match(r"\s*(- |\d+\.\s)", cur):
                    buf.append(cur)
                else:
                    buf[-1] += " " + cur.strip()       # continuation of the previous item
                j += 1
            out.append(lists(buf, base))
            i = j
        else:
            j, buf = i, []
            while j < len(lines) and lines[j].strip() and not re.match(r"\s*(#|\||!\[|>|- |\d+\.\s|```)", lines[j]):
                buf.append(lines[j].strip())
                j += 1
            out.append(f"<p>{inline(' '.join(buf), base)}</p>")
            i = j
    return "\n".join(out)


def main():
    body = convert(SRC.read_text(encoding="utf-8"), SRC.parent)
    page_html = (f'<!doctype html><html><head><meta charset="utf-8"><title>Paderborn baseline report</title>'
                 f"<style>{CSS}</style></head><body>{body}</body></html>")
    tmp = Path(tempfile.mkdtemp(prefix="mg_pb_report_"))
    page = tmp / "report.html"
    page.write_text(page_html, encoding="utf-8")
    OUT.parent.mkdir(exist_ok=True)
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
