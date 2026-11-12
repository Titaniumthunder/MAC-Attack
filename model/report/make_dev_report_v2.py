"""Version 2 of the ML development report: version 1 (Runs 1-2) updated with Training Run 3. Version 1 is not touched.

  python report/make_dev_report_v2.py   -> docs/Model/11_Development_history_Ottawa_to_Run3.md
  (then report/make_run3_reports.py builds its PDF)

Every replacement is asserted to match exactly once in version 1; the Run 3 section's tables are taken from the
generated results/supervised/run3/analysis/tables.md.
"""
import re
from pathlib import Path

HERE = Path(__file__).resolve().parent.parent
DOCS = HERE.parent / "docs" / "Model"
V1 = DOCS / "superseded" / "Development_history_v1_Ottawa_to_Run2.md"   # one folder deeper than V2
V2 = DOCS / "11_Development_history_Ottawa_to_Run3.md"
TABLES = (HERE / "results" / "supervised" / "run3" / "analysis" / "tables.md").read_text(encoding="utf-8")
T = dict(re.findall(r"<!-- (T_[A-Z0-9_]+) -->\n(.*?)(?=\n<!-- T_|\Z)", TABLES, flags=re.S))
F3 = "../../model/results/supervised/run3/analysis/figures"

RUN3 = f"""## 8. Training Run 3 Results (expanded dataset)

Run 3 added four development bearings (**B08, B09, B11, B12**: 6,360 files, CRC-verified, all four logs transcribed) to
B02–B04. That gives **7 labelled bearings**, 9,003 operating measurements, 700 healthy-reference and 35 provisional
end-stage labels. Full details are in `Machine_Guardian_Training_Run3_Report.pdf`.

### 8.1 What was run

- **Five candidates**, all with the unchanged 8 → 32 → 16 → 2 network:
  - A: Run 1–2 settings;
  - B: weight decay 0.01 (the pre-declared primary);
  - C: B with log-compressed inputs instead of the ±16 clip;
  - D: B without the temperature input;
  - E: C and D together.
- **Nested leave-one-bearing-out:** each bearing held out in turn, the candidate chosen on the other six by inner
  leave-one-out, 5 seeds; 1,225 trainings in all.
- **The selection rule** was fixed before training: healthy alarms, end-stage recall, stability, then log-loss.
- **Exploratory and unbiased folds.** Weight decay, the log inputs and the no-temperature option were all designed from
  Run 2's held-out results on B02–B04, so those three folds are exploratory. **B08, B09, B11 and B12 give the unbiased
  estimate.**
- **Health head and test set:** the Motor Health Index head stayed frozen, and B06, B07, B13 and B17 were never
  loaded.

![Nested leave-one-bearing-out]({F3}/diagram_nested_lobo.png)

### 8.2 Results

- **Selected configuration: E** (weight decay 0.01, log-compressed inputs, temperature fed as 0). Its margin over C
  (the same with temperature) is 2 alarm transitions in 35 runs, so C and E are indistinguishable. Both were exported.
- **Healthy-reference false alarms:** 0. **End stage latched before the stop:** 6 of 7 bearings. **B12 is missed** by
  every candidate.
- **Stability:** the raw score's unlatched alarm-state changes fall from 30.3 (A) to 2.8 (E) per run on average.
- **Over-confidence:** scores below 0.001 or above 0.999 fall from 88.9 % (A) to 0.8 % (E).

{T['T_BEARINGLEVEL'].strip()}

Row-level metrics of the latched alarm on the labelled held-out rows are the same for every candidate: accuracy 0.9932,
precision 1.0000, recall 0.8571, F1 0.9231. (The raw score > 0.5 differs: for E 0.9924 / 0.9804 / 0.8571 / 0.9146,
with 3 raw scores above 0.5 on one B11 healthy row that never latched.) A trivial rule that latches an alarm right
after commissioning scores 1.0 on all of them, so these numbers say little.

### 8.3 Alarm timing against the anomaly detector

{T['T_LAG'].strip()}

The selected network **never warns earlier than the anomaly detector** (A, F42, speed):
- **B02, B03, B04, B11:** 2–12 measurements after it, essentially the same event.
- **B08:** 602 measurements (about 3.5 h) later.
- **B09:** 15–19 measurements later.
- **B12:** no alarm at all.

C's 4-measurement lead on B09 and B's leads on B09 and B11 come from the temperature input (on B11 before its T1 sensor
fault): with x8 = 0 they disappear.

![Latched alarms of E and the references]({F3}/alarm_timeline_E_wd_slog_noT_run3.png)

### 8.4 Why B12 is missed

B12's end-stage rows reach a largest vibration z-input of only 2.5–3.2, inside its own healthy range. On every other
bearing they reach 18–51. Two causes were found in the data review:
1. B12's stop was probably triggered by the **front** accelerometer, which the model does not use (8.5 g against 4.9 g
   on the rear).
2. An undocumented vibration step at **M0061**, inside the commissioning window, inflates its reference spread.

The network learned from extreme end-stage labels that only extreme deviation means damage. The anomaly detector, whose
threshold comes from the healthy reference, still alarms 40.8 min before the end.

![B12]({F3}/diagram_why_b12.png)

### 8.5 Input clipping and the temperature input

- **The ±16 clip hides gradual deterioration.** On B04 the raw ln-RMS keeps rising from 16 to about 39 while the network
  sees 16 (Spearman 0.83 among the clipped rows).
- **Log compression keeps that information,** and gave the largest stability gain (mean flicker 15.5 → 2.9).
- **The temperature study is inconclusive:**
  - x8 is 0 on every healthy label by construction;
  - B08's x8 is masked;
  - B11's T1 sensor fails, so its end-stage x8 is −60 σ;
  - removing x8 leaves healthy alarms and recall unchanged and makes no consistent difference to stability (D 20.7
    against B 15.5 changes; E 2.8 against C 2.9), but with x8 = 0 B's B11 alarms move 15–124 measurements later and
    C's B09 alarm 23 later.

### 8.6 Hardware

- **A real export bug, found and fixed.** Weight decay pushes dead neurons' weights to about 1e-35, which made their
  INT32 biases overflow in 31 of 175 models. It changed no INT8 decision (dead neurons output 0 either way), but the
  biases would not fit the hardware's 32-bit register. Fixed on the export path by zeroing negligible weights: the
  FP32 output changes by exactly 0.
- **INT8:** E changes 13 of 45,015 decisions (0.03 %).
- **RTL:** 16 trained networks, plus all 735 labelled rows of the final E and C models, pass bit-exact. 382 cycles =
  1.78 µs per measurement. Simulation only.

"""

REPS = [
    ("""bearing data, to Training Run 2. Prepared with Claude Code, 3 November 2026, from the project's code, logs, earlier
reports and saved experiment results. Every number below is taken from a file in the repository; the main sources are
listed in section 13.""",
     """bearing data, to Training Run 3. **Version 2** (3 November 2026): adds Training Run 3 on seven development bearings;
version 1, covering Runs 1–2, is kept unchanged. Prepared with Claude Code from the project's code, logs, earlier
reports and saved experiment results. Every number below is taken from a file in the repository; the main sources are
listed in section 14."""),
    ("""- **Training Runs 1 and 2.** The deterioration head was trained by leave-one-bearing-out validation (9 networks). Run 2
  added a latched alarm, a calibration study, and an INT8 + RTL check of the **trained** networks.""",
     """- **Training Runs 1 and 2.** The deterioration head was trained by leave-one-bearing-out validation (9 networks). Run 2
  added a latched alarm, a calibration study, and an INT8 + RTL check of the **trained** networks.
- **Training Run 3.**
  - Four more bearings processed (B08, B09, B11, B12), giving 7 labelled bearings.
  - Five configurations compared with nested leave-one-bearing-out validation; log-compressed inputs and weight decay
    selected, with the temperature input fed as 0 (configuration E). C, the same with temperature, was chosen on 4 of
    7 nested folds, trails E by only 2 alarm transitions in 35 runs, and was exported as the alternative.
  - An INT8 export bug fixed; 16 trained networks verified bit-exact on the RTL."""),
    ("""| Paderborn data pipeline and checks (B01–B04) | done for 4 of 17 bearings |
| Anomaly detector (reference) | done; alarms on all three labelled bearings |
| Multi-task MLP, deterioration head | trained (Runs 1–2) on 3 bearings; perfect on the labelled rows, but **not yet better than the anomaly detector** |""",
     """| Paderborn data pipeline and checks | done for 8 of 17 bearings (B01–B04, B08, B09, B11, B12) |
| Anomaly detector (reference) | done; alarms on all seven labelled bearings |
| Multi-task MLP, deterioration head | trained (Runs 1–3), 7 bearings in Run 3; latched before the stop on 6 of 7; **not better than the anomaly detector** (never earlier, misses B12) |"""),
    ("""| Trained MLP in INT8 / on the RTL | done in simulation (Run 2); **not yet on the board** |""",
     """| Trained MLP in INT8 / on the RTL | done in simulation (Runs 2–3; 16 trained networks bit-exact); **not yet on the board** |"""),
    ("""> **Key finding:** the trained network separates documented-healthy from documented-worn-out measurements perfectly on
> bearings it has never seen. With Run 2's latched alarm it raises one steady alarm per bearing. But the simpler anomaly
> detector reaches the same result and alarms a few minutes earlier on every bearing, so the network has not yet
> earned its place.""",
     """> **Key finding:** on seven bearings (Run 3), the trained network raises one steady, latched alarm on 6 of 7, with no
> healthy-reference false alarms. Log-compressed inputs and weight decay make it far steadier than in Runs 1–2. But the
> simpler, label-free anomaly detector alarms at the same time or earlier on every bearing and also catches B12, so the
> network has not yet earned its place."""),
    ("""![Project timeline](../../model/results/supervised/run2/figures/dev_timeline.png)""",
     f"""![Project timeline]({F3}/diagram_timeline_v2.png)"""),
    ("""| 3 Nov | Training Run 2 | latched alarm, calibration study, INT8 + RTL check of trained networks |""",
     """| 3 Nov | Training Run 2 | latched alarm, calibration study, INT8 + RTL check of trained networks |
| 3 Nov | New bearings | B08, B09, B11, B12 extracted, verified, logs transcribed, processed |
| 3 Nov | Training Run 3 | 7 bearings, nested leave-one-bearing-out, 5 candidates; INT8 dead-neuron fix; 16 RTL simulations |"""),
    ("""| Data | one motor, separate fault recordings | 17 bearings run from new to failure (4 processed) |""",
     """| Data | one motor, separate fault recordings | 17 bearings run from new to failure (8 processed, 7 labelled) |"""),
    ("""**The four processed bearings:**""", """**The eight processed bearings** (B08, B09, B11 and B12 added for Run 3):"""),
    ("""![Rear-accelerometer RMS and labels of the four processed bearings](../../model/results/supervised/figures/labels_overview.png)""",
     f"""![Rear-accelerometer RMS and labels of the seven labelled bearings (Run 3)]({F3}/dataset_overview_run3.png)"""),
    ("""| B04 | 1,114 | 50 | 1,064 | 1 | 17 Nov 2021, 12:45–18:27 | vibration limit | inner race, ball |""",
     """| B04 | 1,114 | 50 | 1,064 | 1 | 17 Nov 2021, 12:45–18:27 | vibration limit | inner race, ball |
| B08 | 1,827 | 50 | 1,777 | 2 | 4–5 Feb 2022, 14:43–01:21 | temperature limit | inner race, ball |
| B09 | 1,813 | 50 | 1,763 | 1 | 18–19 Feb 2022, 15:52–04:00 | accelerometer limit | outer race, ball |
| B11 | 1,953 | 0 (no warm-up) | 1,953 | 1 | 17 Aug 2022, 09:27–18:17 | accelerometer limit | inner race, outer race, ball |
| B12 | 767 | 0 (no warm-up) | 767 | 1 | 24 Aug 2022, 08:49–11:22 | accelerometer limit | inner race, ball |

B08 and B09 are sampled at 128 kHz and B11 and B12 at 64 kHz, all under Gaussian random load. Notable data-quality
findings, all documented and none repaired:
- an undocumented vibration step inside B12's commissioning window;
- a failing T1 sensor on B11;
- B09's recording starting 4 h after its logged start, and its dynamic load exceeding the logged range;
- on B11 and B12, stops that the rear accelerometer barely registered."""),
    ("""| B04 | M0051–M0150 | M1110–M1114 | 959 |

That makes 300 healthy, 15 end-stage and 2,428 unlabelled operating rows on B02–B04.""",
     """| B04 | M0051–M0150 | M1110–M1114 | 959 |
| B08 | M0051–M0150 | M1823–M1827 | 1,672 |
| B09 | M0051–M0150 | M1809–M1813 | 1,658 |
| B11 | M0001–M0100 | M1949–M1953 | 1,848 |
| B12 | M0001–M0100 | M0763–M0767 | 662 |

That makes 700 healthy, 35 end-stage and 8,268 unlabelled operating rows on the seven bearings (300, 15 and 2,428 on
B02–B04 in Runs 1–2). The rule is unchanged, and the Run 3 label table reproduces the Runs 1–2 table exactly for
B01–B04."""),
    ("""- The other 13 bearings are for development. Only 3 of them (B02–B04) currently have labels.""",
     """- The other 13 bearings are for development. Seven of them now have labels (B02–B04, B08, B09, B11, B12). The
  constant-speed regime of B17 is still not covered by any development bearing."""),
    ("""There are only three labelled bearings, so each is held out once. The network trains on the other two and is scored on
**every** measurement of the held-out bearing. Each fold is trained with three random seeds, giving 9 networks per
run. A result therefore always comes from a bearing the network has never seen.""",
     """In Runs 1–2 there were only three labelled bearings, so each was held out once: the network trained on the other two
and was scored on **every** measurement of the held-out bearing, with three random seeds (9 networks per run). In Run 3
each of the seven bearings is held out in turn, trained on the other six with five seeds. The training configuration is
chosen by an inner leave-one-out over those six (nested leave-one-bearing-out, section 8). A result therefore always
comes from a bearing the network has never seen."""),
    ("""The input should still be redesigned (section 11).""", """The input should still be redesigned (section 12)."""),
    ("""- **Outlook:** the weight-decay diagnostic suggests the MLP can match the detector's timing, but that has to be shown
  on new bearings.""",
     """- **Outlook:** the weight-decay diagnostic suggested the MLP could match the detector's timing. Run 3 tested this on
  seven bearings, four of them new: it comes close on five (B02–B04, B09, B11) but is never earlier, is 602
  measurements later on B08, and misses B12 (section 8)."""),
    ("""| **Multi-task MLP, trained (Run 2)** | RTL (Icarus Verilog), 576 + 10 measurements | **PASS**, bit-exact; 1,642 cycles per 64, 382 cycles per measurement |""",
     """| **Multi-task MLP, trained (Run 2)** | RTL (Icarus Verilog), 576 + 10 measurements | **PASS**, bit-exact; 1,642 cycles per 64, 382 cycles per measurement |
| **Multi-task MLP, trained (Run 3)** | RTL (Icarus Verilog): 16 networks (final E and C, 14 held-out models), plus all 735 labelled rows of the final E and C | **PASS**, bit-exact; 1,642 / 382 cycles; exported to `export/MTL_run3_v2/` (E) and `export/MTL_run3_v2_C/` (C) |"""),
    ("""2. **Re-export INT8 from the frozen model** and rerun `rtl_check` on it.""",
     """2. **Re-export INT8 from the frozen model** and rerun `rtl_check` on it. Run 3's export already does this for the
   candidates, with the dead-neuron fix; `export.py` itself should adopt the fix and an INT32 bias check."""),
    ("""- **Small training set.** Three labelled bearings, 300 healthy and **15 end-stage** rows, all from one operating regime
  (128 kHz, sinusoidal load). Three of the four locked test bearings come from regimes the model has never seen.""",
     """- **Small training set.** Seven labelled bearings (Run 3), 700 healthy and **35 end-stage** rows, from three of the four
  operating regimes. The bearing is the independent unit: 6 of 7 latched has a 95 % interval of 0.42–1.00. The
  constant-speed regime of locked test bearing B17 is not covered.
- **The learned boundary is extreme.** Every end-stage label is a worn-out state, so the network waits for large
  deviations; it misses B12 and is never earlier than the anomaly detector."""),
    ("""1. **Process more development bearings.** Priority 1 takes the labelled bearings from 3 to 7 and the end-stage rows
   from 15 to 35, and covers two of the three regimes the model has not seen:
   - **B08:** Gaussian load, temperature-stopped.
   - **B09:** Gaussian load, first outer-race defect.
   - **B11** and **B12:** 64 kHz, variable speed.
   - Next come B10, then B14 and B15 (constant speed, large).
2. **Declare Run 3 before running it:**
   - weight decay 0.01 and the latched alarm;
   - the threshold chosen on validation bearings only;
   - nested leave-one-out over the 7 bearings;
   - compared with the anomaly detector on first-alarm time.""",
     """1. **Done in Run 3:** B08, B09, B11 and B12 were processed, and a nested leave-one-out over the 7 bearings was run.
   **Next bearings:** B10, then B14 and B15 (the constant-speed regime of B17). B05 (interrupted) and B16 (no stop
   criterion) were both found damaged at dismantling, so only their commissioning rows could serve as reference data.
2. **Run 4 should combine the two detectors** rather than ask the network to find early damage alone. For example, use
   the anomaly detector's per-bearing threshold as a gate or input, or score the MLP relative to its own commissioning.
   Choose the threshold on inner folds. Add a vibration commissioning-validity check (it would have flagged B12), and
   settle which accelerometer triggered the stops."""),
    ("""3. **Fix the temperature input**, so "not calibrated" is a separate flag rather than the value 0.""",
     """3. **Fix the temperature input**, so "not calibrated" is a separate flag rather than the value 0, with a T1/T2
   consistency check (B11's T1 failure); or keep it disabled, as in candidate E."""),
    ("""- **Run 2's latched alarm:** removes the flicker (from up to 47 state changes to 1) without moving the first alarm.""",
     """- **Run 2's latched alarm:** removes the flicker (from up to 47 state changes to 1) without moving the first alarm.
- **Run 3 on seven bearings:**
  - log-compressed inputs and weight decay make the raw score steady (mean flicker 30.3 → 2.8) and far less
    over-confident;
  - the end stage is latched before the stop on 6 of 7 bearings, with no healthy-reference false alarms;
  - first alarms 2–12 measurements after the anomaly detector's on four bearings."""),
    ("""- **Beat the baseline:** the network does **not** yet beat the label-free anomaly detector, which alarms earlier on
  every bearing.
- **More data:** process more bearings so a model can be chosen on validation data and tested fairly.""",
     """- **Beat the baseline:** the network does **not** yet beat the label-free anomaly detector. On seven bearings it is
  never earlier, and it misses B12, whose end stage barely departs from its commissioning on the rear sensor.
- **More data and better labels:** the constant-speed regime, a commissioning-validity check, and labels or methods that
  teach intermediate stages."""),
    ("""| Run 2 | `model/train_deterioration_run2.py`, `model/results/supervised/run2/` (`TRAINING_RUN2_REPORT.md`, `results.json`, `checkpoints.csv`, `variants.csv`) |""",
     """| Run 2 | `model/train_deterioration_run2.py`, `model/results/supervised/run2/` (`TRAINING_RUN2_REPORT.md`, `results.json`, `checkpoints.csv`, `variants.csv`) |
| New bearings and Run 3 | `model/extract_paderborn_zips.py`, `model/run3_prep.py`, `model/train_deterioration_run3.py`, `model/run3_hardware.py`, `model/run3_final_c.py`, `model/run3_supplement.py`, `model/run3_b12_diagnostic.py`, `model/results/supervised/run3/`, `docs/Model/10_Training_run3.pdf` |"""),
    ("""- **Inputs:** quantized with one scale, 16/127 per step, so ±16 maps to ±127.""",
     """- **Inputs:** quantized with one scale. For the clipped models (Runs 1–2; Run 3's A, B and D) the step is 16/127, so
  ±16 maps to ±127. The exported Run 3 models E and C are not clipped: the ARM first log-compresses each input,
  x = sign(z) · ln(1 + min(|z|, 10⁴)), and the step is ln(10001)/127 ≈ 0.0725."""),
    ("""at those measurements, and they were not reviewed. For two of the three labelled bearings, they sit where the rig's
  vibration stop rule fired.""",
     """at those measurements, and they were not reviewed. For five of the seven labelled bearings (B02, B04, B09, B11, B12)
  the test was ended by the rig's vibration limit."""),
    ("""- **On unseen bearings:** the trained deterioration head separates documented-healthy from end-stage measurements
  perfectly, with zero false alarms on 300 healthy-reference rows and 100 % end-stage recall.""",
     """- **Runs 1–2 on unseen bearings (B02–B04):** the trained deterioration head separates documented-healthy from end-stage
  measurements perfectly, with zero false alarms on 300 healthy-reference rows and 100 % end-stage recall. Run 3's
  seven bearings break this: the end stage is latched on 6 of 7, because every candidate misses B12."""),
    ("""- **Hardware fit:** the trained network survives INT8 with no labelled decision changed, and runs bit-exact on the RTL
  in 1.78 µs.""",
     """- **Hardware fit:** on held-out bearings, Run 3's model E changes 13 of 45,015 decisions in INT8 (3 on labelled rows,
  no latched alarm state changed; Run 2 changed none on labelled rows). The trained networks run bit-exact on the RTL
  in 1.78 µs."""),
]


def renumber(text):
    """Sections 8-13 of version 1 become 9-14 (Run 3 is inserted as section 8)."""
    def h(m):
        n = int(m.group(2))
        return f"{m.group(1)}{n + 1 if n >= 8 else n}{m.group(3)}"
    return re.sub(r"^(#{2,3} )(\d+)(\.)", h, text, flags=re.M)


def main():
    v1 = V1.read_text(encoding="utf-8").replace("](../../../model/", "](../../model/")   # links as seen from V2's folder
    s = v1
    for a, b in REPS:
        assert s.count(a) == 1, a[:80]
        s = s.replace(a, b)
    cut = s.index("## 8. Run 1 vs. Run 2 Comparison")
    s = s[:cut] + "@@RUN3@@\n" + renumber(s[cut:])
    s = s.replace("## 9. Run 1 vs. Run 2 Comparison", "## 9. Run 1 vs. Run 2 Comparison (Run 3: section 8)")
    s = s.replace("@@RUN3@@\n", RUN3)
    s = s.replace("# Machine Guardian — ML Model Development and Training Results\n",
                  "# Machine Guardian — ML Model Development and Training Results (version 2)\n", 1)
    V2.write_text(s, encoding="utf-8")
    assert V1.read_text(encoding="utf-8").replace("](../../../model/", "](../../model/") == v1
    print(f"wrote {V2}; sections:", re.findall(r"^## (\d+)\.", s, flags=re.M))


if __name__ == "__main__":
    main()
