"""Training Run 3 supplement (3 Nov 2026), added after the independent protocol review. Changes no Run 3 result.

  python run3_supplement.py   -> results/supervised/run3/supplement/supplement.json

  1. trivial baselines under Run 3's own metrics: "never alarm", and "latch an alarm at the first measurement after
     commissioning" (row 101): they show what the labelled-row metrics can and cannot distinguish
  2. bearing-level outcomes with exact (Clopper-Pearson) 95 % intervals: the bearing is the independent unit
  3. results split into the exploratory bearings (B02-B04, which Run 2 used to design the candidates) and the unbiased
     new bearings (B08, B09, B11, B12); and with/without B12 (descriptive only)
  4. the temperature input x8 on every end-stage row (the temperature-study confound)
  5. label integrity: the label table's digest recomputed, and every npz label array checked against the table's ids
  6. RTL of the final E and C seed-0 models on ALL labelled rows (735 rows, the 35 end-stage rows included), because
     the v1 RTL sampled a prefix of rows (the v2 hardware run samples a spread)
"""
import json, shutil, tempfile
from pathlib import Path

import numpy as np
import pandas as pd
from scipy.stats import beta

import labels as lb
import run3_hardware as hw
import train_deterioration_run2 as r2
import train_deterioration_run3 as r3

OUT = r3.OUT.parent / "supplement"
EXPL, NEWB = ("B02", "B03", "B04"), ("B08", "B09", "B11", "B12")


def cp(k, n, a=0.05):
    lo = 0.0 if k == 0 else float(beta.ppf(a / 2, k, n - k + 1))
    hi = 1.0 if k == n else float(beta.ppf(1 - a / 2, k + 1, n - k))
    return [round(lo, 3), round(hi, 3)]


def trivial(e, kind):
    d = r3.DATA[e]
    n = len(d["y"])
    above = np.zeros(n, bool) if kind == "never" else np.arange(n) >= 100
    m = r2.alarm_metrics(r2.latched(above) if kind != "never" else above, above, d["y"], d["ts_series"], d["ids"])
    return {"healthy_rows_alarmed": m["healthy_rows_alarmed"], "end_recall": m["end_recall"],
            "first_alarm_min_before_last_record": m["first_alarm_min_before_last_record"],
            "accuracy_labelled": m["labelled_rows_alarm"]["accuracy"], "alarm_state_changes": m["alarm_state_changes"]}


def rtl_labelled(cfg, path, seed):
    net = hw.load(path, seed)
    X = np.concatenate([r3.inputs(e, r3.CONFIGS[cfg])[~np.isnan(r3.DATA[e]["y"])] for e in r3.BEARINGS])
    Q = hw.quantize(net, cfg, r3.BEARINGS, X)
    Xq = Q["Xq"]
    import rtl_check
    root = Path(tempfile.mkdtemp(prefix="mg_run3_rtl_lab_"))
    try:
        sim = rtl_check.TempSimulator(root, "icarus")
        work = sim.build("tb_mlp", rtl_check.PARAMS)
        n = int(np.ceil(len(Xq) / 64)) * 64
        idx = np.r_[np.arange(len(Xq)), np.arange(n - len(Xq))]          # all rows; the last batch is topped up
        batches = [Xq[idx[i:i + 64]] for i in range(0, n, 64)]
        good, eq, cyc, _ = rtl_check.run(sim, work, Q["layers"], batches, int(Q["scales"][-1]["bias_last"][0]))
        return {"rows": int(len(Xq)), "end_stage_rows": 35, "batches": len(batches), "pass": bool(good), "cycles": sorted(cyc)}
    finally:
        shutil.rmtree(root, ignore_errors=True)


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    r3.load_data()
    R = json.loads((r3.OUT / "results.json").read_text())
    out = {"note": __doc__.strip()}
    # 1. trivial baselines
    out["trivial"] = {k: {e: trivial(e, k) for e in r3.BEARINGS} for k in ("never", "after_commissioning")}
    # 2./3. bearing-level outcomes
    T = pd.DataFrame([{"cfg": r["cfg"], "bearing": r["held_out"], "seed": r["seed"],
                       "latched_before_stop": r["metrics"]["latched"]["end_recall"] == 1.0,
                       "healthy_alarmed": r["metrics"]["latched"]["healthy_rows_alarmed"],
                       "first": r["metrics"]["latched"]["first_alarm_id"],
                       "minutes": r["metrics"]["latched"]["first_alarm_min_before_last_record"],
                       "unlatched_changes": r["metrics"]["unlatched"]["alarm_state_changes"]} for r in R["outer"]])
    det = {e: R["references"][e]["anomaly A|F42|speed"]["latched"] for e in r3.BEARINGS}
    sel = {o: R["nested"][o]["selected"] for o in r3.BEARINGS}
    groups = {"all 7": r3.BEARINGS, "exploratory B02-B04": EXPL, "unbiased new B08-B12": NEWB,
              "all except B12 (descriptive)": tuple(b for b in r3.BEARINGS if b != "B12")}
    bl = {}
    for gname, g in groups.items():
        row = {}
        for c in list(r3.CONFIGS) + ["nested"]:
            t = pd.concat([T[(T.cfg == sel[o]) & (T.bearing == o)] for o in g]) if c == "nested" else T[(T.cfg == c) & T.bearing.isin(g)]
            k = int(t.groupby("bearing").latched_before_stop.all().sum())          # identical across seeds here
            row[c] = {"bearings_latched_before_stop": f"{k}/{len(g)}", "ci95": cp(k, len(g)),
                      "seeds_agree_on_outcome": bool((t.groupby("bearing").latched_before_stop.nunique() == 1).all()),
                      "mean_unlatched_changes": round(float(t.unlatched_changes.mean()), 2)}
        kd = sum(det[e]["end_recall"] == 1.0 for e in g)
        row["anomaly A|F42|speed"] = {"bearings_latched_before_stop": f"{kd}/{len(g)}", "ci95": cp(kd, len(g))}
        kt = sum(out["trivial"]["after_commissioning"][e]["end_recall"] == 1.0 for e in g)
        row["trivial: latch after commissioning"] = {"bearings_latched_before_stop": f"{kt}/{len(g)}", "ci95": cp(kt, len(g))}
        bl[gname] = row
    out["bearing_level"] = bl
    # timing vs detector, per bearing (E, C)
    out["timing_vs_detector"] = {e: {"detector_first_id": det[e]["first_alarm_id"], "detector_minutes": det[e]["first_alarm_min_before_last_record"],
                                     **{c: {"first_ids": sorted(set(T[(T.cfg == c) & (T.bearing == e)]["first"].dropna().astype(int))),
                                            "lag_measurements_vs_detector": sorted(set((T[(T.cfg == c) & (T.bearing == e)]["first"] - det[e]["first_alarm_id"]).dropna().astype(int)))}
                                        for c in ("C_wd_slog", "E_wd_slog_noT", "B_wd")}} for e in r3.BEARINGS}
    # 4. x8 on the end-stage rows
    out["x8_end_stage"] = {e: {"x8_clipped": [round(float(v), 2) for v in r3.DATA[e]["X"][r3.DATA[e]["y"] == 1, 7]],
                               "x8_raw": [round(float(v), 1) for v in r3.DATA[e]["R"][r3.DATA[e]["y"] == 1, 7]],
                               "x8_healthy_all_zero": bool((r3.DATA[e]["X"][r3.DATA[e]["y"] == 0, 7] == 0).all())} for e in r3.BEARINGS}
    # 5. label integrity
    lt = json.loads((r3.PREP / "label_table_run3.json").read_text())
    ok = {"digest_recomputed_matches": lb.table_digest(lt["table"]) == lt["sha256"], "npz_labels_match_table": {}}
    for e in r3.BEARINGS:
        b, d = lt["table"]["bearings"][e], r3.DATA[e]
        s0, s1 = b["start"]["measurement_ids"]
        e0, e1 = b["end"]["measurement_ids"]
        exp = np.where((d["ids"] >= s0) & (d["ids"] <= s1), 0.0, np.where((d["ids"] >= e0) & (d["ids"] <= e1), 1.0, np.nan))
        ok["npz_labels_match_table"][e] = bool(np.array_equal(np.isnan(exp), np.isnan(d["y"])) and
                                               np.array_equal(exp[~np.isnan(exp)], d["y"][~np.isnan(d["y"])]))
    ok["npz_sha256"] = {e: __import__("hashlib").sha256((r3.PREP / f"inputs_{e}.npz").read_bytes()).hexdigest() for e in r3.BEARINGS}
    out["label_integrity"] = ok
    # 6. RTL on all labelled rows
    out["rtl_labelled_rows"] = {"E_wd_slog_noT final seed 0": rtl_labelled("E_wd_slog_noT", r3.OUT / "models" / "FINAL" / "E_wd_slog_noT_all7_seed0.pt", 0),
                                "C_wd_slog final seed 0": rtl_labelled("C_wd_slog", r3.OUT.parent / "train_alt_C" / "C_wd_slog_all7_seed0.pt", 0)}
    out["selection_margin"] = {"criteria_1_2_tied_for_all_candidates": len({tuple(v[:2]) for v in R["full_development_keys"].values()}) == 1,
                               "criterion_3_mean_unlatched_changes": {c: round(v[2], 3) for c, v in R["full_development_keys"].items()},
                               "nested_picks": sel}
    (OUT / "supplement.json").write_text(json.dumps(out, indent=1, default=str) + "\n", encoding="utf-8")
    print(json.dumps({k: out[k] for k in ("bearing_level", "label_integrity", "rtl_labelled_rows", "selection_margin")}, indent=1, default=str)[:6000])
    print({e: (v["x8_clipped"], v["x8_healthy_all_zero"]) for e, v in out["x8_end_stage"].items()})
    print({k: {e: (v["end_recall"], v["healthy_rows_alarmed"], v["accuracy_labelled"], v["first_alarm_min_before_last_record"]) for e, v in t.items()} for k, t in out["trivial"].items()})


if __name__ == "__main__":
    main()
