"""Evidence-anchored deterioration labels for the Paderborn development bearings (no invented labels).

  python labels.py              every processed development bearing -> results/supervised/labels_<EXP>.csv,
                                label_table.json

Rule (fixed 2 Nov 2026, before B02 or B04 was downloaded; DATASET_VALIDATION_REPORT.md section 9):
  start   the first START_N = 100 operating (non-warm-up) measurements          -> y_det = 0 (healthy)
  end     the last END_N = 5 operating measurements of the recording             -> y_det = 1 (deteriorated)
          only when the end is a documented stop (END_RULE below)
  middle  everything else                                                         -> y_det = NaN (masked, no label)
  withheld  no start label for a bearing whose start is not a documented healthy condition (START_WITHHELD below)
  health  y_hi = NaN everywhere: no bearing has a measured severity, so the health-index head gets no label at all
The labels use only the documents (dataset description Table 3, the experiment's log) and the order, timestamps and
warm-up flags of the measurements. No vibration or temperature value is read: nothing here can be a pseudo-label.
Bearings in the locked test set are refused (splits.assert_development).

What the evidence is, and what it is not (written into label_table.json for every bearing):
  E1  new bearing at the start: "no defect was initiated" (description); the first 100 measurements are its first
      ~30 min under test load, hours before the stop.
  E2  damaged at the end: the defect type found when the bearing was dismantled after the test (description Table 3).
  A1  PROVISIONAL END-STAGE PROXY: the last END_N measurements (~1 min before the stop) are labelled 1 as a proxy for
      the end-of-test state of a bearing found damaged after dismantling. That the damage was already present in those
      measurements is assumed, not verified: the dismantling date and any change after the stop are not documented.
  A2  ASSUMPTION: the bearing defect caused the stop. The rig stopping at its vibration or temperature threshold does not
      by itself prove this.
  A3  NOT an onset time: the exact damage onset is unknown and lies anywhere in the masked middle; the end label marks
      the documented end stage, not where damage began. No result may be reported as a detection delay from it.
  A4  ASSUMPTION: the bearing stayed healthy throughout the first START_N measurements (supported by E1, not measured).
"""
import hashlib, json
from pathlib import Path

import numpy as np
import pandas as pd

import splits
from paderborn import HERE, META, load

OUT = HERE / "results" / "supervised"
START_N, END_N = 100, 5
# Start labels withheld, decided in the label review (2 Nov 2026; label review walkthrough item 6). B01: the housing
# temperature T1 reached the 110 degC stop temperature (description p.4) 16 min after the warm-up, at 09:12:49 (log 09:13:
# "temperature threshold value was exceeded"), the test restarted twice after that, and the bearing had already run for up
# to 15 min the day before (log 08:45). Its start is not a documented healthy condition, so B01 gets no label at all.
START_WITHHELD = {"B01": "housing temperature reached the 110 degC stop temperature 16 min after warm-up (log 09:13); "
                         "restarted twice afterwards; ran up to 15 min the day before (log 08:45): not a documented "
                         "healthy start (label review, 2 Nov 2026)"}
SENSITIVITY_END_N = (3, 10, 20)          # checked only within the development set, never to choose
END_TOLERANCE_S = 120                    # the last measurement must be within this of the logged stop
DESCRIPTION = "Paderborn LDM run-to-failure data set description, Zenodo 10.5281/zenodo.10805042, Table 3"
EVIDENCE = {
    "E1": "new bearing at the start; no defect initiated (dataset description)",
    "E2": "defect type after dismantling (dataset description, Table 3)",
    "A1": "PROVISIONAL END-STAGE PROXY: the last END_N measurements stand for the end-of-test state; that the damage "
          "found at dismantling was already present then is assumed, not verified",
    "A2": "ASSUMPTION: the bearing defect caused the stop; the rig stopping at its threshold does not by itself prove "
          "this",
    "A3": "NOT an onset time: the exact damage onset is unknown (masked middle); the end label marks the documented end "
          "stage, not when damage began",
    "A4": "ASSUMPTION: healthy throughout the first START_N measurements (supported by E1, not measured)",
}


def end_rule(exp, checks):
    """Whether the recording ends at a documented stop. Returns (eligible, reasons it is not)."""
    m = META["experiments"][exp]
    why = []
    crit = m["description"]["threshold_criterion"]
    if crit not in ("vibration", "temperature"):
        why.append(f"no stop criterion pre-set (description: {crit})")
    if m.get("note") and "interrupted" in m["note"]:
        why.append("experiment interrupted")
    if not m.get("log_end"):
        why.append("log not transcribed: the stop time is not documented here")
    elif checks.get("records_after_log_end", 0) or abs(checks.get("last_record_vs_log_end_s") or 1e9) > END_TOLERANCE_S:
        why.append(f"recording does not end at the logged stop ({checks.get('records_after_log_end')} records after it, "
                   f"last record {checks.get('last_record_vs_log_end_s')} s from it)")
    return not why, why


def label(exp, full=None, checks=None, end_n=END_N):
    """Per operating measurement: y_det (0, 1 or NaN), y_hi (NaN), the label's source."""
    splits.assert_development([exp])
    full = load(exp) if full is None else full
    checks = checks if checks is not None else json.loads((HERE / "results" / "paderborn" / exp / "checks.json").read_text())
    d = full.loc[~full.warmup.to_numpy(), ["measurement_id", "timestamp", "segment"]].reset_index(drop=True)
    if len(d) < START_N + end_n:
        raise ValueError(f"{exp}: {len(d)} operating measurements, too few for {START_N} + {end_n}")
    y = np.full(len(d), np.nan)
    src = np.array([""] * len(d), dtype=object)
    withheld = START_WITHHELD.get(exp)
    start = np.arange(len(d)) < (0 if withheld else START_N)
    y[start], src[start] = 0.0, "start: E1, A4"
    ok, why = end_rule(exp, checks)
    end = d.iloc[-end_n:]
    if ok and end.segment.nunique() > 1:
        ok, why = False, ["the last END_N measurements span a stop"]
    if ok:
        y[-end_n:], src[-end_n:] = 1.0, "end: E2, A1, A2, A3"
    out = d.assign(y_det=y, y_hi=np.nan, label_source=np.where(src == "", "masked: no evidence", src))
    m = META["experiments"][exp]
    info = {"experiment": exp, "operating_measurements": len(d),
            "start": ({"label": None, "withheld_because": [withheld]} if withheld else
                      {"label": 0, "n": START_N, "measurement_ids": [int(d.measurement_id[0]), int(d.measurement_id[START_N - 1])],
                       "until": str(d.timestamp[START_N - 1]), "evidence": ["E1", "A4"]}),
            "end": ({"label": 1, "n": end_n, "measurement_ids": [int(end.measurement_id.iloc[0]), int(end.measurement_id.iloc[-1])],
                     "from": str(end.timestamp.iloc[0]), "to": str(end.timestamp.iloc[-1]),
                     "minutes_covered": float((end.timestamp.iloc[-1] - end.timestamp.iloc[0]).total_seconds() / 60),
                     "evidence": ["E2", "A1", "A2", "A3"], "defect_after_dismantling": m["description"]["defect_after_dismantling"],
                     "stop": m.get("stop_reason"), "log_end": m.get("log_end")}
                    if ok else {"label": None, "withheld_because": why}),
            "masked": int(np.isnan(y).sum()), "health_index_labels": 0,
            "sources": [DESCRIPTION] + ([f"{exp} log (paderborn_experiments.json)"] if m.get("log") else [])}
    return out, info


def table_digest(table):
    return hashlib.sha256(json.dumps(table, sort_keys=True).encode()).hexdigest()


def available():
    """Processed development bearings (the test bearings are never listed)."""
    dev = splits.development()
    return [e for e in dev if (HERE / "results" / "paderborn" / e / f"{e}_processed.csv").exists()]


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    table = {"rule": {"start_n": START_N, "start_withheld": START_WITHHELD, "end_n": END_N, "end_tolerance_s": END_TOLERANCE_S,
                      "sensitivity_end_n": list(SENSITIVITY_END_N), "health_index": "no labels (no measured severity)"},
             "evidence": EVIDENCE, "bearings": {}}
    for e in available():
        out, info = label(e)
        out.to_csv(OUT / f"labels_{e}.csv", index=False)
        table["bearings"][e] = info
        end = info["end"]
        st = info["start"]
        print(f"{e}: " + (f"{st['n']} start (0) M{st['measurement_ids'][0]:04d}-M{st['measurement_ids'][1]:04d}, "
                          if st["label"] == 0 else "start withheld, ")
              + (f"{end['n']} end (1) M{end['measurement_ids'][0]:04d}-M{end['measurement_ids'][1]:04d}"
                                              if end["label"] else f"end withheld: {'; '.join(end['withheld_because'])}")
              + f", {info['masked']} masked")
    doc = {"table": table, "sha256": table_digest(table)}
    (OUT / "label_table.json").write_text(json.dumps(doc, indent=1) + "\n", encoding="utf-8")
    print(f"label_table.json sha256 {doc['sha256'][:16]}...  (not reviewed: see supervised_prep.py, label_review.json)")


if __name__ == "__main__":
    main()
