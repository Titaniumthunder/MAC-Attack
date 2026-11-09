"""Markdown tables for the Run 3 report, generated from the saved results (so no number is typed by hand).

  python report/run3_tables.py   -> results/supervised/run3/analysis/tables.md
"""
import json, sys
from pathlib import Path

import numpy as np
import pandas as pd

sys.path.insert(0, str(Path(__file__).resolve().parent))
import run3_figures as f   # noqa: E402

R = f.load_results()
T = f.outer_table(R)
REF = f.ref_rows(R)
A = json.loads((f.AN / "analysis.json").read_text())
Q = json.loads((f.PREP / "data_quality.json").read_text())
LT = json.loads((f.PREP / "label_table_run3.json").read_text())
HW = json.loads((f.RUN3 / "hardware" / "hardware.json").read_text())
FIN = pd.read_csv(f.RUN3 / "hardware" / "int8_final_in_sample.csv")
R2 = json.loads((f.HERE / "results" / "supervised" / "run2" / "results.json").read_text())
SEL = {o: R["nested"][o]["selected"] for o in f.BEARINGS}
out = []


def rng(v, fmt="{:.0f}"):
    v = [x for x in v if x is not None and not (isinstance(x, float) and np.isnan(x))]
    if not v:
        return "never"
    lo, hi = min(v), max(v)
    return fmt.format(lo) if lo == hi else f"{fmt.format(lo)}–{fmt.format(hi)}"


def table(head, rows):
    out.append("| " + " | ".join(head) + " |")
    out.append("|" + "---|" * len(head))
    out.extend("| " + " | ".join(str(c) for c in r) + " |" for r in rows)
    out.append("")


def mlp_row(name, t):
    times = sorted({str(x)[11:19] for x in t.first_time if isinstance(x, str)})
    return [name, rng(t.first_id.tolist()), (times[0] if len(times) == 1 else f"{times[0]}–{times[-1]}") if times else "–",
            rng(t.min_before_end.tolist(), "{:.1f}"), rng(t.changes_latched.tolist()), rng(t.changes_unlatched.tolist()),
            f"{int(t.healthy_above.sum())} / {int(t.healthy_alarmed.sum())}", f"{100 * t.end_recall.mean():.0f} %",
            f"{100 * t.middle_alarmed.mean():.1f} %"]


def ref_row(name, r):
    if r is None or not r["available"]:
        return [name, "not available (no 20–64 kHz band at 64 kHz)", "–", "–", "–", "–", "–", "–", "–"]
    return [name, "never" if pd.isna(r["first_id"]) else int(r["first_id"]), "–" if not isinstance(r["first_time"], str) else r["first_time"][11:19],
            "–" if pd.isna(r["min_before_end"]) else f"{r['min_before_end']:.1f}", int(r["changes"]), int(r["changes_unlatched"]),
            f"{int(r['healthy_above'])} / {int(r['healthy_alarmed'])}", f"{100 * r['end_recall']:.0f} %", f"{100 * r['middle_alarmed']:.1f} %"]


# ---------------------------------------------------------------- dataset
out.append("<!-- T_DATASET -->")
rows = []
for e in f.BEARINGS:
    q = Q[e]
    b = LT["table"]["bearings"][e]
    first, last = pd.Timestamp(q["first_record"]), pd.Timestamp(q["last_record"])
    rows.append([e + (" (new)" if e in f.NEW else ""), f"{int(q['fs_hz'][0] / 1000)} kHz", sum(s["n"] for s in q["segments"].values()),
                 q["warmup_rows"], q["operating_measurements"], len(q["segments"]), f"{(last - first).total_seconds() / 3600:.1f} h",
                 f"M{b['start']['measurement_ids'][0]:04d}–M{b['start']['measurement_ids'][1]:04d}",
                 f"M{b['end']['measurement_ids'][0]:04d}–M{b['end']['measurement_ids'][1]:04d}", b["masked"],
                 "masked (x8 = 0)" if q["temp_input_masked"] else ("valid (V1–V3), but T1 sensor fault from M0979" if e == "B11" else "valid"),
                 q["rows_with_an_input_clipped"]])
table(["Bearing", "Sampling", "Files", "Warm-up rows", "Operating rows", "Segments", "Recorded span", "Healthy (0)",
       "End-stage (1)", "Unlabelled", "Temperature input", "Rows with an input clipped at ±16"], rows)

# ---------------------------------------------------------------- per bearing
for e in f.BEARINGS:
    out.append(f"<!-- T_BEARING_{e} -->")
    rows = [mlp_row("MLP E (selected), latched", T[(T.cfg == "E_wd_slog_noT") & (T.bearing == e)]),
            mlp_row(f"MLP nested choice ({SEL[e].split('_')[0]}), latched", T[(T.cfg == SEL[e]) & (T.bearing == e)]),
            mlp_row("MLP B (primary, weight decay), latched", T[(T.cfg == "B_wd") & (T.bearing == e)]),
            mlp_row("MLP A (Run 1–2 settings), latched", T[(T.cfg == "A_run12") & (T.bearing == e)])]
    for name in ("anomaly A|F42|speed", "anomaly A|F128|speed", "rig rule rear RMS > 6.5 g"):
        r = REF[(REF.bearing == e) & (REF.detector == name)]
        rows.append(ref_row(name.replace("rig rule rear RMS > 6.5 g", "B02's 6.5 g limit on the rear sensor, latched").replace("anomaly", "Anomaly detector"),
                            None if r.empty else r.iloc[0]))
    table(["Detector", "First alarm (id)", "Clock time", "Min. before last record", "Changes (latched)",
           "Changes (unlatched)", "Healthy rows above / alarmed", "End-stage recall", "Unlabelled rows alarmed"], rows)

# ---------------------------------------------------------------- pooled scores
out.append("<!-- T_SCORES -->")
rows = []
for c in f.CFGS:
    for kind, lab in (("alarm", "latched alarm"), ("raw", "raw score > 0.5")):
        s = A["pooled_scores"][f"{c}|{kind}"]
        rows.append([f"{f.CLAB[c]}", lab, f"{s['accuracy']:.4f}", f"{s['precision']:.4f}", f"{s['recall']:.4f}", f"{s['f1']:.4f}",
                     f"{s['tn']} / {s['fp']} / {s['fn']} / {s['tp']}"])
N = pd.concat([T[(T.cfg == c) & (T.bearing == o)] for o, c in SEL.items()])
TP, FP, TN, FN = (int(N[k].sum()) for k in ("tp", "fp", "tn", "fn"))
P, Rc = TP / (TP + FP), TP / (TP + FN)
rows.append(["Nested selection (unbiased)", "latched alarm", f"{(TP + TN) / (TP + FP + TN + FN):.4f}", f"{P:.4f}", f"{Rc:.4f}",
             f"{2 * P * Rc / (P + Rc):.4f}", f"{TN} / {FP} / {FN} / {TP}"])
for name in ("anomaly A|F42|speed",):
    r = REF[REF.detector == name]
    TP, FP, TN, FN = (int(r[k].sum()) for k in ("tp", "fp", "tn", "fn"))
    P, Rc = TP / (TP + FP), TP / (TP + FN)
    rows.append(["Anomaly detector A|F42|speed (7 bearings, 1 run)", "latched alarm", f"{(TP + TN) / (TP + FP + TN + FN):.4f}",
                 f"{P:.4f}", f"{Rc:.4f}", f"{2 * P * Rc / (P + Rc):.4f}", f"{TN} / {FP} / {FN} / {TP}"])
r = REF[REF.detector == "rig rule rear RMS > 6.5 g"]
TP, FP, TN, FN = (int(r[k].sum()) for k in ("tp", "fp", "tn", "fn"))
P, Rc = (TP / (TP + FP) if TP + FP else float("nan")), TP / (TP + FN)
rows.append(["B02's 6.5 g limit on the rear sensor", "latched alarm", f"{(TP + TN) / (TP + FP + TN + FN):.4f}", f"{P:.4f}", f"{Rc:.4f}",
             f"{2 * P * Rc / (P + Rc):.4f}", f"{TN} / {FP} / {FN} / {TP}"])
table(["Model", "Decision", "Accuracy", "Precision", "Recall", "F1", "TN / FP / FN / TP"], rows)

# ---------------------------------------------------------------- candidates
out.append("<!-- T_CANDIDATES -->")
rows = []
for c in f.CFGS:
    t = T[T.cfg == c]
    k = R["full_development_keys"][c]
    allp = np.concatenate([pd.read_csv(f.TRAIN / "predictions" / c / f"predictions_{e}.csv")[[f"p_seed{s}" for s in f.SEEDS]].to_numpy().ravel()
                           for e in f.BEARINGS])
    rows.append([f.CLAB[c], int(t.healthy_alarmed.sum()), f"{100 * t.end_recall.mean():.1f} %", f"{t.changes_unlatched.mean():.1f}",
                 f"{k[3]:.4f}", f"{t.max_p_healthy.max():.3f}", f"{100 * ((allp < 1e-3) | (allp > 0.999)).mean():.1f} %",
                 f"{100 * t.mid_between.mean():.1f} %", f"{t.final_train_loss.mean():.4f}",
                 sum(1 for o in f.BEARINGS if SEL[o] == c)])
table(["Candidate", "Healthy rows alarmed (35 runs)", "End-stage recall", "Unlatched changes (mean)", "Labelled log-loss",
       "Highest score on a healthy row", "Scores < 0.001 or > 0.999", "Unlabelled scores in 0.05–0.95", "Final training loss",
       "Chosen by nested selection (of 7 folds)"], rows)

# ---------------------------------------------------------------- nested
out.append("<!-- T_NESTED -->")
rows = []
for o in f.BEARINGS:
    ks = R["nested"][o]["keys"]
    s = SEL[o]
    rows.append([o, s, f"{ks[s][0]:.0f}", f"{-ks[s][1]:.3f}", f"{ks[s][2]:.2f}", f"{ks[s][3]:.4f}",
                 ", ".join(f"{c.split('_')[0]} {ks[c][2]:.1f}" for c in f.CFGS)])
table(["Outer (held-out) bearing", "Chosen on the 6 inner folds", "Inner healthy rows alarmed", "Inner end-stage recall",
       "Inner unlatched changes", "Inner log-loss", "Inner unlatched changes, every candidate"], rows)

# ---------------------------------------------------------------- INT8
out.append("<!-- T_INT8 -->")
hw = pd.read_csv(f.RUN3 / "hardware" / "int8_outer.csv")
rows = []
for c in f.CFGS:
    t = hw[hw.cfg == c]
    rows.append([f.CLAB[c], len(t), int(t.rows.sum()), int(t.decisions_changed.sum()), f"{100 * t.decisions_changed.sum() / t.rows.sum():.3f} %",
                 int(t.decisions_changed_labelled.sum()), int((t.latched_first_alarm_fp32.fillna(-1) == t.latched_first_alarm_int8.fillna(-1)).sum()),
                 f"{t.logit_mean_abs_err.mean():.3f}", f"{t.logit_max_abs_err.max():.2f}", int((t.weights_zeroed > 0).sum())])
rows.append(["Final E models (all 7 bearings, in-sample)", FIN.seed.nunique(), int(FIN.rows.sum()), int(FIN.decisions_changed.sum()),
             f"{100 * FIN.decisions_changed.sum() / FIN.rows.sum():.3f} %", int(FIN.decisions_changed_labelled.sum()),
             f"{int((FIN.latched_first_alarm_fp32.fillna(-1) == FIN.latched_first_alarm_int8.fillna(-1)).sum())} of {len(FIN)} bearing runs",
             f"{FIN.logit_mean_abs_err.mean():.3f}", f"{FIN.logit_max_abs_err.max():.2f}", int((FIN.groupby('seed').weights_zeroed.max() > 0).sum())])
table(["Models", "Networks", "Rows", "Decisions changed", "Share", "On labelled rows", "Latched first alarm identical",
       "Mean abs. logit error", "Max abs. logit error", "Networks with dead weights zeroed"], rows)
out.append("<!-- T_RTL -->")
rows = [["Final E, seed 0 (all 7 bearings)", HW["rtl"]["final_seed0"]["M64"]["batches"], HW["rtl"]["final_seed0"]["M64"]["cycles"][0],
         "PASS" if HW["rtl"]["final_seed0"]["M64"]["pass"] else "FAIL", HW["rtl"]["final_seed0"]["M1"]["cycles"][0],
         "PASS" if HW["rtl"]["final_seed0"]["M1"]["pass"] else "FAIL"]]
for k, v in HW["rtl"]["outer_seed0"].items():
    rows.append([f"Outer {k} (seed 0)", v["M64"]["batches"], v["M64"]["cycles"][0], "PASS" if v["M64"]["pass"] else "FAIL",
                 v["M1"]["cycles"][0], "PASS" if v["M1"]["pass"] else "FAIL"])
table(["Network", "Batches of 64", "Cycles per 64", "M = 64", "Cycles per 1", "M = 1"], rows)

# ---------------------------------------------------------------- runs
out.append("<!-- T_RUNS -->")
rows = []
for e in ("B02", "B03", "B04"):
    r1 = [R2["folds"][e]["seeds"][str(s)]["run1_alarm"] for s in (0, 1, 2)]
    l2 = [R2["folds"][e]["seeds"][str(s)]["run2_latched_alarm"] for s in (0, 1, 2)]
    a3, e3 = T[(T.cfg == "A_run12") & (T.bearing == e)], T[(T.cfg == "E_wd_slog_noT") & (T.bearing == e)]
    f42 = REF[(REF.bearing == e) & (REF.detector == "anomaly A|F42|speed")].iloc[0]
    rows.append([e, f"{rng([x['first_alarm_min_before_last_record'] for x in r1], '{:.1f}')} / {rng([x['alarm_state_changes'] for x in r1])}",
                 f"{rng([x['first_alarm_min_before_last_record'] for x in l2], '{:.1f}')} / {rng([x['alarm_state_changes'] for x in l2])}",
                 f"{rng(a3.min_before_end.tolist(), '{:.1f}')} / {rng(a3.changes_unlatched.tolist())}",
                 f"{rng(e3.min_before_end.tolist(), '{:.1f}')} / {rng(e3.changes_unlatched.tolist())}",
                 f"{f42['min_before_end']:.1f} / {int(f42['changes_unlatched'])}"])
table(["Bearing", "Run 1 (unlatched rule; 2 training bearings, 3 seeds)", "Run 2 (latched; same networks)",
       "Run 3 A (Run 1–2 settings, 6 training bearings, 5 seeds; unlatched changes)", "Run 3 E (selected; unlatched changes)",
       "Anomaly detector A|F42|speed"], rows)

# ---------------------------------------------------------------- review supplement
SUP = json.loads((f.RUN3 / "supplement" / "supplement.json").read_text())
out.append("<!-- T_BEARINGLEVEL -->")
rows = []
for g in ("all 7", "exploratory B02-B04", "unbiased new B08-B12", "all except B12 (descriptive)"):
    b = SUP["bearing_level"][g]
    rows.append([g.replace("B02-B04", "(B02–B04)").replace("B08-B12", "(B08, B09, B11, B12)")] +
                [f"{b[c]['bearings_latched_before_stop']} ({b[c]['ci95'][0]:.2f}–{b[c]['ci95'][1]:.2f})"
                 for c in ("E_wd_slog_noT", "C_wd_slog", "B_wd", "A_run12", "nested", "anomaly A|F42|speed", "trivial: latch after commissioning")])
table(["Bearings", "E (selected)", "C", "B (primary)", "A (Run 1–2 settings)", "Nested selection", "Anomaly detector", "Trivial rule: latch right after commissioning"], rows)
out.append("<!-- T_TRIVIAL -->")
tr = SUP["trivial"]
rows = [["Never alarm", "0 of 7", "0", f"{np.mean([v['accuracy_labelled'] for v in tr['never'].values()]):.4f}", "–"],
        ["Latch an alarm at the first measurement after commissioning (row 101)", "7 of 7", "0",
         f"{np.mean([v['accuracy_labelled'] for v in tr['after_commissioning'].values()]):.4f}",
         f"{min(v['first_alarm_min_before_last_record'] for v in tr['after_commissioning'].values()):.0f}–{max(v['first_alarm_min_before_last_record'] for v in tr['after_commissioning'].values()):.0f}"]]
table(["Trivial rule (no learning, no data)", "End stage latched before the stop", "Healthy rows alarmed", "Accuracy on labelled rows", "First alarm, min before last record"], rows)
out.append("<!-- T_LAG -->")
rows = []
for e in f.BEARINGS:
    t = SUP["timing_vs_detector"][e]
    fmt = lambda v: "never" if not v["lag_measurements_vs_detector"] else ", ".join(f"{x:+d}" for x in v["lag_measurements_vs_detector"])
    rows.append([e, t["detector_first_id"], f"{t['detector_minutes']:.1f}", fmt(t["E_wd_slog_noT"]), fmt(t["C_wd_slog"]), fmt(t["B_wd"])])
table(["Bearing", "Anomaly detector first alarm (id)", "Detector, min before last record", "E: lag (measurements; + = later)",
       "C: lag", "B: lag"], rows)
out.append("<!-- T_X8 -->")
rows = [[e, ", ".join(f"{v:.1f}" for v in SUP["x8_end_stage"][e]["x8_raw"]), ", ".join(f"{v:.1f}" for v in SUP["x8_end_stage"][e]["x8_clipped"]),
         "yes" if SUP["x8_end_stage"][e]["x8_healthy_all_zero"] else "no"] for e in f.BEARINGS]
table(["Bearing", "x8 on the 5 end-stage rows (raw)", "x8 as the clip16 network sees it", "x8 = 0 on all 100 healthy rows"], rows)
text = "\n".join(out) + "\n"
for a, b in (("A|F42|speed", "(A, F42, speed)"), ("A|F128|speed", "(A, F128, speed)")):
    text = text.replace(a, b)
(f.AN / "tables.md").write_text(text, encoding="utf-8")
print(f"wrote {f.AN / 'tables.md'}")
