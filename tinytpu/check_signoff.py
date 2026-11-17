"""Prints the signoff checks of a Tiny Tapeout / LibreLane run, including the electrical ones that the
GitHub summary page does not show (max slew, max capacitance, max fanout).

Where to find metrics.csv:
  - GitHub Actions (gds workflow): download the "GDS_logs" artifact, then runs/wokwi/final/metrics.csv
  - Local run (tt_tool.py --harden): runs/wokwi/final/metrics.csv in the project folder

Usage:  python check_signoff.py path/to/metrics.csv        (or the folder that holds it, or a runs/ folder)
Clean means every count below is 0 and both slacks are >= 0.
"""
import csv
import sys
from pathlib import Path

CHECKS = [
    ("design__max_slew_violation__count", "Max slew (transition) violations"),
    ("design__max_cap_violation__count", "Max capacitance violations"),
    ("design__max_fanout_violation__count", "Max fanout violations"),
    ("timing__setup_vio__count", "Setup timing violations"),
    ("timing__hold_vio__count", "Hold timing violations"),
    ("route__drc_errors", "Routing DRC errors"),
    ("magic__drc_error__count", "Magic DRC errors"),
    ("design__lvs_error__count", "LVS errors"),
    ("antenna__violating__nets", "Antenna violating nets"),
]
SLACKS = [("timing__setup__ws", "Worst setup slack (ns)"), ("timing__hold__ws", "Worst hold slack (ns)")]


def find(arg):
    p = Path(arg)
    if p.is_file():
        return p
    for cand in (p / "metrics.csv", p / "final" / "metrics.csv", p / "wokwi" / "final" / "metrics.csv",
                 p / "runs" / "wokwi" / "final" / "metrics.csv"):
        if cand.is_file():
            return cand
    sys.exit(f"no metrics.csv found at {arg}")


def value(metrics, key, worst):
    """The design-wide value, or the worst over the per-corner values if only those exist."""
    if key in metrics:
        return float(metrics[key])
    vals = [float(v) for k, v in metrics.items() if k.startswith(key + "__corner:")]
    return worst(vals) if vals else None


path = find(sys.argv[1] if len(sys.argv) > 1 else ".")
with open(path) as fh:
    metrics = {row[0]: row[1] for row in csv.reader(fh) if len(row) >= 2}

clean = True
print(f"{path}\n")
for key, name in CHECKS:
    v = value(metrics, key, max)
    if v is None:
        print(f"  ??    {name}: not in metrics")
        continue
    ok = v == 0
    clean &= ok
    print(f"  {'ok  ' if ok else 'FAIL'}  {name}: {v:g}")
for key, name in SLACKS:
    v = value(metrics, key, min)
    if v is None:
        print(f"  ??    {name}: not in metrics")
        continue
    ok = v >= 0
    clean &= ok
    print(f"  {'ok  ' if ok else 'FAIL'}  {name}: {v:+.3f}")
print("\nCLEAN: every electrical, timing and physical check passes" if clean else
      "\nNOT CLEAN: see the FAIL lines above")
sys.exit(0 if clean else 1)
