"""Extract downloaded Paderborn experiment archives into model/newdata/<EXP>/ (the layout paderborn.py reads), verifying
every member, and write a manifest per experiment (added 3 Nov 2026 for B08, B09, B11, B12).

  python extract_paderborn_zips.py --meta-only <zip> ...   logs and CSVs only (fast)
  python extract_paderborn_zips.py <zip> ...               everything (refuses to overwrite an existing file)

Zenodo archives are named <EXP>.zip, or <EXP>_part1.zip, <EXP>_part2.zip for a split experiment. Each member is
<top>/<EXP>_log.pdf, <top>/<EXP>_meanTemperatures.csv, <top>/<EXP>_operatingConditions.csv or
<top>/vibrationData/data_<EXP>_M<id>.mat, with <top> = <EXP> or <EXP>_partN. Parts are merged into one folder.
Python's zipfile is used because the macOS unzip/bsdtar cannot read ZIP64 archives over 4 GB (B08.zip).
Checks: member paths (no absolute paths, no '..', only the four expected kinds of file), CRC-32 of every member
(zipfile raises on a mismatch while streaming), the written size, and a SHA-256 of every written file.
Nothing is renamed, repaired or skipped silently: an unexpected member stops the extraction.
Manifest: results/paderborn/<EXP>/extraction_manifest.json (one entry per file: name, bytes, crc32, sha256, archive).
"""
import argparse, hashlib, json, re, sys, zipfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
NEWDATA = HERE / "newdata"
RESULTS = HERE / "results" / "paderborn"
CHUNK = 1 << 22


def plan(zpath):
    m = re.fullmatch(r"(B\d{2})(?:_part(\d))?\.zip", zpath.name)
    if not m:
        raise SystemExit(f"{zpath.name}: not <EXP>.zip or <EXP>_partN.zip")
    exp = m.group(1)
    top = zpath.stem
    ok = re.compile(rf"^{top}/(?:({exp}_log\.pdf|{exp}_meanTemperatures\.csv|{exp}_operatingConditions\.csv)"
                    rf"|vibrationData/(data_{exp}_M\d{{4,5}}\.mat)|vibrationData/)$")
    return exp, top, ok


def extract(zpath, meta_only):
    exp, top, ok = plan(zpath)
    dest = NEWDATA / exp
    out = []
    with zipfile.ZipFile(zpath) as z:
        infos = z.infolist()
        for i in infos:
            n = i.filename
            if n.startswith("/") or ".." in Path(n).parts or not ok.match(n):
                raise SystemExit(f"{zpath.name}: unexpected member {n!r}; nothing more extracted")
        for i in infos:
            if i.is_dir():
                continue
            rel = i.filename[len(top) + 1:]
            if meta_only and rel.endswith(".mat"):
                continue
            target = dest / rel
            if target.exists():
                if target.stat().st_size == i.file_size:
                    continue                                   # already extracted by an earlier run (verified then)
                raise SystemExit(f"{target} exists with a different size: not overwritten")
            target.parent.mkdir(parents=True, exist_ok=True)
            h, size = hashlib.sha256(), 0
            tmp = target.with_suffix(target.suffix + ".part")
            with z.open(i) as src, open(tmp, "wb") as dst:          # zipfile checks the CRC-32 at the end of the stream
                while chunk := src.read(CHUNK):
                    h.update(chunk)
                    dst.write(chunk)
                    size += len(chunk)
            if size != i.file_size:
                tmp.unlink()
                raise SystemExit(f"{i.filename}: wrote {size} bytes, archive says {i.file_size}")
            tmp.rename(target)
            out.append({"file": rel, "bytes": size, "crc32": f"{i.CRC:08x}", "sha256": h.hexdigest(), "archive": zpath.name})
    return exp, out, len([i for i in infos if not i.is_dir()])


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("zips", nargs="+", type=Path)
    ap.add_argument("--meta-only", action="store_true")
    a = ap.parse_args()
    for zp in a.zips:
        exp, entries, members = extract(zp, a.meta_only)
        man = RESULTS / exp / "extraction_manifest.json"
        man.parent.mkdir(parents=True, exist_ok=True)
        doc = json.loads(man.read_text()) if man.exists() else {"experiment": exp, "archives": {}, "files": []}
        doc["archives"][zp.name] = {"members_excluding_folders": members, "bytes": zp.stat().st_size}
        have = {f["file"] for f in doc["files"]}
        doc["files"] += [e for e in entries if e["file"] not in have]
        doc["files"].sort(key=lambda f: f["file"])
        man.write_text(json.dumps(doc, indent=0) + "\n", encoding="utf-8")
        print(f"{zp.name} -> {NEWDATA / exp}: {len(entries)} files written, {members} members in the archive")
        sys.stdout.flush()


if __name__ == "__main__":
    main()
