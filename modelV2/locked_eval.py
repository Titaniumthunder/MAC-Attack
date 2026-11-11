"""The one-time test of the frozen model on the locked bearings (Paderborn B06, B07, B13, B17; Ottawa 4, 7, 15, 19).
Runs the INT8 model, as the chip would. Refuses to run twice.

  model/.venv/bin/python modelV2/locked_eval.py

Needs each locked Paderborn bearing's raw folder in modelV2/rawdata/paderborn/, or its feature table already built in
modelV2/data/ (paderborn_<B>.csv). Their last 20 measurements are taken as the end
stage (their logs are not transcribed, so model/labels.py's documented-stop rule cannot be applied).
"""
import json

import numpy as np

import config as c
import evaluate
import freeze
import hardware
import pipeline as F
import prep


def main():
    if not c.FROZEN.exists():
        raise SystemExit("no frozen model: run freeze.py first")
    out = c.REPORT / "locked_results.json"
    if out.exists():
        raise SystemExit(f"the locked test was already run: {out}")
    missing = [b for b in c.PAD_LOCKED if not ((c.PADERBORN_RAW / b).exists() or (c.DATA / f"paderborn_{b}.csv").exists())]
    if missing:
        raise SystemExit(f"data of {missing} is missing: put each bearing's raw folder in {c.PADERBORN_RAW}/ (nothing was tested)")
    frozen = json.loads(c.FROZEN.read_text())
    folder = c.EXPORT / frozen["export"]
    if freeze.digest(folder) != frozen["sha256"]:
        raise SystemExit("the exported model changed after it was frozen")
    layers, last, quant = hardware.load_export(folder)
    hist = quant["history"]
    floor = np.array(list(quant["sigma_floor"].values()))     # from the frozen export, not from data/ (which can be rebuilt)
    run = lambda r: hardware.int8(F.network_inputs(r["Z"], r["s"], r["rpm"], r["M"], np.full(len(r["y"]), hist)), layers, last)
    res = {"frozen": frozen, "paderborn": {}}
    for b in c.PAD_LOCKED:
        r, info = prep.paderborn_rows(b, prep.paderborn_table(b), floor, end_labels=False)
        e = evaluate.paderborn_eval(r, run(r))
        del e["_series"]
        res["paderborn"][b] = {**e, "baseline": info}
    ott = prep.ottawa_table(c.OTT_LOCKED)
    parts = [prep.ottawa_rows(n, t.reset_index(drop=True), floor) for n, t in ott.groupby("bearing")]
    r = {k: np.concatenate([p[k] for p in parts]) for k in parts[0]}
    res["ottawa"] = evaluate.ottawa_eval(r, run(r))
    c.writable(out).write_text(json.dumps(res, indent=1) + "\n")
    print(json.dumps(res, indent=1))


if __name__ == "__main__":
    main()
