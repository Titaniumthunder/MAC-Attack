"""Freeze one run's exported model (seed 0). Writes modelV2/frozen.json once; only then do the locked bearings open.

  model/.venv/bin/python modelV2/freeze.py --run modelV2/runs/<folder>
"""
import argparse, hashlib, json
from datetime import datetime
from pathlib import Path

import config as c


def digest(folder):
    h = hashlib.sha256()
    for p in sorted(Path(folder).iterdir()):
        if p.is_file() and not p.name.startswith("."):      # not .DS_Store; the model files are all text
            h.update(p.name.encode() + p.read_bytes().replace(b"\r\n", b"\n"))
    return h.hexdigest()


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--run", type=Path, required=True)
    run = ap.parse_args().run.resolve()
    if c.FROZEN.exists():
        raise SystemExit(f"already frozen: {c.FROZEN.read_text()}")
    folder = c.EXPORT / run.name / "seed0"
    if not (run / "hardware.json").exists() or not folder.exists():
        raise SystemExit("run hardware.py on this run first: the frozen model is its INT8 export")
    if json.loads((run / "config.json").read_text())["quick"]:
        raise SystemExit("this is a --quick dry run: freeze a full run")
    if not json.loads((run / "hardware.json").read_text())["summary"]["rtl_bit_exact"]:
        raise SystemExit("this run's RTL check did not pass (hardware.json): not frozen")
    doc = {"run": run.name, "export": f"{run.name}/seed0", "sha256": digest(folder),
           "frozen_at": f"{datetime.now():%Y-%m-%d %H:%M:%S}"}
    c.FROZEN.write_text(json.dumps(doc, indent=1) + "\n")
    print(f"frozen: {doc}\nnext: model/.venv/bin/python modelV2/locked_eval.py")


if __name__ == "__main__":
    main()
