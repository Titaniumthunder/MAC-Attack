# Label review packet: 15 items, one per page

2 November 2026. For the reviewer and an independent second checker. Each page shows one item from
`label_review.TEMPLATE.json`:

- what you confirm;
- the current label;
- the wording of the original documents, quoted with the page;
- what our data show (a cross-check only, never the source of a label);
- the assumptions;
- the recommendation.

**Nothing in this packet is approved.** Every `confirmed` field is empty.

**Under review:** `results/supervised/label_table.json`, SHA-256 4eff40d85f35e35d… (labels unchanged; wording of items 2 and 15 revised 2 November)

**Original documents (open them at the cited page):**

| Short name | Document | Where | SHA-256 (first 16) |
|---|---|---|---|
| Description | O. K. Aimiyekagbon, "Run-to-failure data set of ball bearings subjected to time-varying load and speed conditions", v2, 25 March 2024, 9 pages (CC BY 4.0) | Zenodo 10.5281/zenodo.10805042, file `LDM_UPB_Run-to-failure_data_set_of_ball_bearings.pdf` | 949c855fa0cc6d2b |
| B01 log | Experiment B01 log, 2 pages | `model/newdata/B01/B01_log.pdf` | 4a5445c8ac9f9249 |
| B02 log | Experiment B02 log, 2 pages | `model/newdata/B02/B02_log.pdf` | 5beffbeebd5ffa1f |
| B03 log | Experiment B03 log, 2 pages | `model/newdata/B03/B03_log.pdf` | caa9c543658ff374 |
| B04 log | Experiment B04 log, 2 pages | `model/newdata/B04/B04_log.pdf` | 84ea2506dbeaaa14 |

All four logs were written by Lennart Viemann and supervised by O. K. Aimiyekagbon (log p.2).

**How to use this packet:**

1. **Reviewer:** read each page against the original document. Tick confirm, or change, and add a comment.
2. **Second checker:** do the same independently, without seeing the reviewer's ticks.
3. **Disagreements:** settle them before sign-off. If any label changes, I regenerate the table; its hash changes and
   this packet is reissued.
4. **Sign-off:** record it in `results/supervised/label_review.json`, a copy of the template with every `confirmed`
   set to true. The reviewer fills in `checked_by` and `date`; the second checker fills in `independent_check_by` and
   `independent_check_date`.
5. **Readiness check:** `python supervised_prep.py` must print "ready" before any training.

## Item 1 (all bearings): defect types after dismantling

**What you confirm:**

| Bearing | Defect type |
|---|---|
| B01 | IR, OR, B |
| B02 | IR |
| B03 | IR |
| B04 | IR, B |

IR means inner race, OR outer race, B rolling element. The types are transcribed in `paderborn_experiments.json` and
`label_table.json`.

**Original documentation:**

> Description p.8: "… the relevant threshold criterion for the end of an experiment and the defect type discovered
> after dismantling the test bearing."

> Description p.8, Table 3 "Data Set Characteristics". Rows: Experiment / Approx. Duration / No. of Files / Threshold
> Criterion / Defect. B01: 2 h, 377, "-", IR, OR, B. B02: 6 h, 1116, Tvibration, IR. B03: 3 h, 614, Ttemperature,
> IR. B04: 6 h, 1114, Tvibration, IR, B.

> Description p.8, under the table: "IR denotes inner race defect(s), OR denotes outer race defect(s) and B denotes
> rolling element defect(s)."

**Our data:** the file counts 377, 1116, 614 and 1114 equal our `.mat` counts and CSV rows (`checks.json`).

**Assumptions and uncertainty:**

- **Missing details:** Table 3 gives the type of damage only. It gives no size and no dismantling date.
- **Spelling:** "Tvibration" and "Ttemperature" are written as subscripted T in the PDF.

**Recommendation:** keep.

| | Confirm | Change | Comment |
|---|---|---|---|
| Reviewer | ☐ | ☐ | |
| Second checker | ☐ | ☐ | |

## Item 2 (all bearings): assumptions A1–A4 and provisional end-stage labels

**What you confirm:** the four assumptions recorded in `label_table.json` are acceptable, with this reading of the
deteriorated labels:

> **The final five measurements of B02, B03 and B04 are provisional end-stage proxy labels.** They stand for the
> end-of-test state of a bearing that was found damaged after dismantling (description Table 3). They are not a
> verified deteriorated state at those measurements. **The exact damage onset is unknown.** **The rig stopping at its
> vibration or temperature threshold does not by itself prove that the bearing defect caused the stop.**

- **A1, provisional end-stage proxy:** the last 5 measurements (about 1 minute) stand for the end-of-test state. That
  the damage found at dismantling was already present then is assumed, not verified.
- **A2, assumption:** the bearing defect caused the stop. The rig stopping at its threshold does not by itself prove
  this.
- **A3, not an onset time:** the exact damage onset is unknown. The deteriorated label marks the documented end stage,
  not when the damage began.
- **A4:** the bearing was healthy during its healthy-labelled rows.

**Original documentation:**

> Description p.2: "No defect was initiated in the bearings before the experiments."

> B02 log p.2, 08:59; B03 log p.2, 15:10; B04 log p.2, 12:45: "Begin with a new bearing."

> Description p.4: "A bearing fails and consequently an experiment ends, when at least one of two predetermined failure
> threshold criteria is exceeded."

**What the documents do not say:**
- when the bearing was dismantled;
- whether the rig ran again between the stop and the dismantling;
- the size of the damage;
- whether any inspection took place before the end.

**Assumptions and uncertainty:**

- **A4** rests on "no defect was initiated" and "new bearing".
- **A1 and A2** have no direct document. The description says a bearing "fails" when a criterion is exceeded, and
  Table 3 gives the damage found afterwards. Neither shows that the defect caused the stop, or that the damage existed
  in the final measurements.
- **A1 is the weakest assumption.** It covers only about 1.1–1.25 minutes before each stop.
- **A3** is a rule we impose on ourselves, so no document is needed.

**Recommendation:** keep the label ranges. Call the deteriorated labels "provisional end-stage proxy labels" in every
result, with A1 and A2 named as the main uncertainties.

| | Confirm | Change | Comment |
|---|---|---|---|
| Reviewer | ☐ | ☐ | |
| Second checker | ☐ | ☐ | |

## Item 3 (all bearings): label counts, and B01 withheld

**What you confirm:**

- **Counts:** 100 healthy rows at the start and 5 deteriorated rows at the end of each eligible bearing (`labels.py`,
  fixed 2 November before B02 and B04 were opened).
- **B01:** its healthy labels are withheld (review decision, 2 November; item 6).

**Original documentation:** none. These are design choices, not evidence. The 100 matches the anomaly baseline's
commissioning period (about 30 minutes).

**Our data:**

| Bearing | Healthy rows | Healthy period | Deteriorated rows |
|---|---|---|---|
| B02 | M0052–M0151 | 09:09:44–09:39:51 | 5 |
| B03 | M0001–M0100 | 15:10:43–15:42:10 | 5 |
| B04 | M0051–M0150 | 12:55:27–13:26:01 | 5 |
| B01 | none | – | none |

**Assumptions and uncertainty:**

- The counts are not evidence.
- The deteriorated-label count is to be checked for sensitivity at 3, 10 and 20 rows, within the development set
  only, and never used to choose a model.

**Recommendation:** keep.

| | Confirm | Change | Comment |
|---|---|---|---|
| Reviewer | ☐ | ☐ | |
| Second checker | ☐ | ☐ | |

## Item 4 (B02, B04): end labels placed by a vibration stop rule

**What you confirm:** the B02 and B04 deteriorated labels are accepted. They sit where the rig's vibration limit
fired, on the same rear accelerometer the model uses, under two conditions:

- every trained head is compared with that rule;
- B03, the temperature stop, is reported separately.

**Original documentation:**

> Description p.4: "The threshold criteria is based on the bearing housing vibration Tvibration and temperature
> Ttemperature measurements. For the provided experiments, Tvibration lies within [6, 10] g …"

> Description p.8, Table 3: B02 "Tvibration", B04 "Tvibration".

> B02 log p.1: "Conversion Factor 10 g/V". p.2, 14:36: "The test was successfully completed because the RMS value of
> the accelerometer exceeded a value of 0.65 V four times."

> B04 log p.2, 18:26: "The test was successfully completed because the RMS values of an accelerometer exceeded the
> specified limit!"

> Description p.3: "Three one-directional accelerometers … measure the vibration of the bearing via its housing.
> However, two (A and C) of the three accelerometer measurements … are provided in this data set …"

**What the documents do not say:**
- which accelerometer the stop rule watched;
- the RMS window it used;
- B04's limit value.

**Our data:**

- **B02's limit:** 0.65 V × 10 g/V = 6.5 g, inside the [6, 10] g range.
- **Rear sensor A in B02:** it is above 6.5 g at exactly the two measurements before the 13:32 pause (M0920, M0921).
- **Front sensor C:** never reaches 6.5 g in either bearing.
- **Last 5 rows above 6.5 g:** 4 of 5 in B02 (4.92, 7.16, 7.46, 6.57, 6.94 g) and 4 of 5 in B04 (3.17, 6.98, 8.72,
  8.21, 6.81 g).
- **The rig rule as a detector** (rear RMS above 6.5 g, 3 in a row) catches 40% of the deteriorated rows on B02 and
  B04, and 0% on B03.

**Assumptions and uncertainty:**

- That the rule used sensor A is an inference from our data; no document says so.
- A network trained on these labels can do well simply by learning the stop rule.

**Recommendation:** keep, with both conditions.

| | Confirm | Change | Comment |
|---|---|---|---|
| Reviewer | ☐ | ☐ | |
| Second checker | ☐ | ☐ | |

## Item 5 (B01): end label withheld

**What you confirm:** B01 gets no deteriorated label.

**Original documentation:**

> Description p.4: "However, for experiment B01 no criteria was pre-set …"

> Description p.8, Table 3: B01, Threshold Criterion "-", Defect "IR, OR, B".

> B01 log p.2, 09:13: "The experiment successfully completes because the temperature threshold value was exceeded!"

**Our data:**

- **Recording continues past the log:** 272 operating measurements were recorded after 09:13, up to 10:59. That is
  106.5 minutes after the log's last entry, in two further segments.
- **Not covered by the rule:** our end-label rule requires the recording to end within 2 minutes of a documented stop,
  so B01 does not qualify.

**Assumptions and uncertainty:**

- The description and the log contradict each other about whether a criterion existed.
- What happened after 09:13, and when the bearing was dismantled, is undocumented.

**Recommendation:** keep it withheld.

| | Confirm | Change | Comment |
|---|---|---|---|
| Reviewer | ☐ | ☐ | |
| Second checker | ☐ | ☐ | |

## Item 6 (B01): no healthy labels (decided 2 November)

**What you confirm:** B01 has no healthy labels, so it has no labels at all and is in no training fold.

**Original documentation:**

> B01 log p.2, 08:45: "The new bearing was installed the day before. It operated for a maximum of 15 minutes."
> Followed by the 10-minute warm-up.

> B01 log p.2, 09:13: "The experiment successfully completes because the temperature threshold value was exceeded!"

> Description p.4: "Ttemperature is 110 °C."

**Our data:**

- **Timing:** the warm-up runs 08:46:54–08:56:51 and operation starts at 08:57:10.
- **Temperature:** across the first 54 operating rows (M0052–M0105), T1 rises from 32.8 to 113.6 °C. It first reaches
  110 °C at 09:12:49, about 16 minutes after warm-up.
- **Restarts:** the recording restarts at 09:32 and 09:43.
- **Vibration:** rear RMS stays at about 1.2 g (median).
- **Comparison:** B03 took about 3 hours to reach 110 °C; B02 and B04 peaked at 74 and 66 °C after 5–6 hours.

**Assumptions and uncertainty:**

- **Cause:** the documents don't explain the fast heating (lubrication, fit or preload).
- **Prior running:** "operated for a maximum of 15 minutes" means the bearing had run before this test.
- **Why the labels were dropped:** a bearing at the documented failure temperature is not a defensible example of a
  healthy start. Dropping B01 costs no deteriorated rows and 54 healthy rows.

**Recommendation:** keep the decision (B01 has no labels).

| | Confirm | Change | Comment |
|---|---|---|---|
| Reviewer | ☐ | ☐ | |
| Second checker | ☐ | ☐ | |

## Item 7 (B02): healthy labels M0052–M0151

**What you confirm:** B02's first 100 operating measurements, 09:09:44–09:39:51, are labelled healthy (0).

**Original documentation:**

> B02 log p.2, 25-10-2021 8:59: "Begin with a new bearing. Warm-up phase: 10 Minutes, n=750rpm, Fstatic = 2500N, no
> dynamic load. After the warm-up phase, the test runs with set values for rotation speed, static load and dynamic
> load."

> Description p.2: "No defect was initiated in the bearings before the experiments."

**Our data:**

- **Warm-up:** M0001–M0051 at 750 rpm and 2500 N, excluded from the labels.
- **Healthy rows:** about 30 minutes at test conditions, with rear RMS of about 1 g.
- **Temperature:** T1 is still rising, and the thermal calibration is valid.

**Assumptions and uncertainty:** A4 only. Nothing points against it.

**Recommendation:** keep.

| | Confirm | Change | Comment |
|---|---|---|---|
| Reviewer | ☐ | ☐ | |
| Second checker | ☐ | ☐ | |

## Item 8 (B02): deteriorated labels M1112–M1116

**What you confirm:** B02's last 5 measurements, 14:35:29–14:36:36, are labelled deteriorated (1).

**Original documentation:**

> B02 log p.2, 25-10-2021 14:36: "The test was successfully completed because the RMS value of the accelerometer
> exceeded a value of 0.65 V four times."

> Description p.8, Table 3: B02, Tvibration, Defect "IR".

> Description p.4: "Tvibration lies within [6, 10] g."

**Our data:**

- **End of recording:** the last record is 36 s after 14:36, with no record after the logged stop.
- **Coverage:** the 5 rows span 1.1 minutes, all in segment 2 (after the 13:32 pause).
- **Vibration:** 4 of the 5 rows are above 6.5 g.

**Assumptions and uncertainty:**

- **A1, provisional end-stage proxy:** these rows stand for the end-of-test state; damage in them is assumed, not
  verified. A2: the stop does not by itself prove the defect caused it.
- **Item 4:** the position of these labels comes from the vibration rule.

**Recommendation:** keep.

| | Confirm | Change | Comment |
|---|---|---|---|
| Reviewer | ☐ | ☐ | |
| Second checker | ☐ | ☐ | |

## Item 9 (B02): the 13:32 pause is not a label

**What you confirm:** the 13:32 stop is not used as a label or an onset time. The measurements around it stay
unlabelled.

**Original documentation:**

> B02 log p.2, 25-10-2021 13:32: "The test was stopped because the RMS value of an accelerometer exceeded a value of
> 0.65V twice. To account for possible outliers, the test was continued, where the threshold is allowed to be crossed
> 4 times."

**Our data:**

- **Pause:** a gap from 13:32:36 to 13:37:18 (4 min 42 s).
- **Crossings:** exactly two rows above 6.5 g before it, M0920 and M0921.
- **Vibration level:** rear RMS rose from about 1 g to about 5 g at about 13:15.

**Assumptions and uncertainty:**

- The bearing was not dismantled at 13:32, so there is no evidence of its condition then.
- The rise at about 13:15 is a measurement, not a label.

**Recommendation:** keep it unlabelled.

| | Confirm | Change | Comment |
|---|---|---|---|
| Reviewer | ☐ | ☐ | |
| Second checker | ☐ | ☐ | |

## Item 10 (B02): crossing count, 13 in our data and 4 in the log

**What you confirm:** the difference is acknowledged, and no label depends on it.

**Original documentation:**

> B02 log p.2, 14:36: "… exceeded a value of 0.65 V four times."

**Our data:** after the restart (M0922 onward), our 1.6-s RMS is above 6.5 g in 13 measurements.

**Assumptions and uncertainty:**

- **Not documented:** the rig's own RMS window, its counting rule, and whether it measured between our stored windows.
- **Most likely cause:** our RMS and the rig's monitoring RMS are computed differently.

**Recommendation:** acknowledge; no change.

| | Confirm | Change | Comment |
|---|---|---|---|
| Reviewer | ☐ | ☐ | |
| Second checker | ☐ | ☐ | |

## Item 11 (B03): healthy labels M0001–M0100

**What you confirm:** B03's first 100 measurements, 15:10:43–15:42:10, are labelled healthy (0).

**Original documentation:**

> B03 log p.2, 05-11-2021 15:10: "Begin with a new bearing. Warm-up phase: 10 Minutes, n=750rpm, Fstatic = 2500N, no
> dynamic load. After the warm-up phase, the test runs with set values for rotation speed, static load and dynamic
> load."

> Description p.2: "No defect was initiated in the bearings before the experiments."

**Our data:**

- **No warm-up rows:** the first record is at 15:10:43, and no row is at 750 rpm. The warm-up the log describes is
  not in the recording.
- **Healthy rows:** about 31 minutes at test conditions, with rear RMS of about 1 g.
- **Temperature:** the thermal calibration is valid.

**Assumptions and uncertainty:** the missing warm-up is undocumented. It does not bear on whether the bearing was
healthy.

**Recommendation:** keep.

| | Confirm | Change | Comment |
|---|---|---|---|
| Reviewer | ☐ | ☐ | |
| Second checker | ☐ | ☐ | |

## Item 12 (B03): deteriorated labels M0610–M0614

**What you confirm:** B03's last 5 measurements, 18:22:25–18:23:40, are labelled deteriorated (1).

**Original documentation:**

> B03 log p.2, 05-11-2021 18:23: "The test was automatically stopped because the bearing housing temperature exceeded
> the specified limits of 110°C!"

> Description p.8, Table 3: B03, Ttemperature, Defect "IR". Description p.4: "Ttemperature is 110 °C."

**Our data:**

- **Temperature crossing:** T1 first goes above 110 °C at M0612 (18:23:02), inside the labelled rows. Three rows are
  above 110 °C.
- **End of recording:** the last record is 40 s after 18:23, at 118.2 °C.
- **Vibration:** rear RMS stays below 6.5 g in all 5 labelled rows (4.6–5.6 g).

**Assumptions and uncertainty:**

- **A1, provisional end-stage proxy:** these rows stand for the end-of-test state; damage in them is assumed, not
  verified. A2: the stop does not by itself prove the defect caused it.
- **Overshoot:** T1 reads 8 °C above the limit, probably from sensor lag or a different control sensor.
- **Why this bearing matters:** it is the only deteriorated label whose position was not chosen by vibration.

**Recommendation:** keep.

| | Confirm | Change | Comment |
|---|---|---|---|
| Reviewer | ☐ | ☐ | |
| Second checker | ☐ | ☐ | |

## Item 13 (B04): healthy labels M0051–M0150

**What you confirm:** B04's first 100 operating measurements, 12:55:27–13:26:01, are labelled healthy (0).

**Original documentation:**

> B04 log p.2, 17-11-2021 12:45: "Begin with a new bearing. Warm-up phase: 10 Minutes, n=750rpm, Fstatic = 2500N, no
> dynamic load …"

> B04 log p.2, 13:45: "Since the bearing temperature was above 60°C, the parameters for the higher operating
> temperature were selected!"

> B04 log p.1: "… the bearing temperature is queried after 60 minutes of operation. If this exceeds 60°C, the set
> intervals of the parameters remain."

> Description p.2: "No defect was initiated in the bearings before the experiments."

**Our data:**

- **Warm-up:** M0001–M0050, excluded from the labels.
- **Healthy rows:** about 31 minutes, ending at 13:26, before the 13:45 parameter decision.
- **Set ranges:** they match the higher-temperature set (T_high) throughout (`checks.json`).
- **Temperature:** the thermal calibration is valid.

**Assumptions and uncertainty:** A4 only.

**Recommendation:** keep.

| | Confirm | Change | Comment |
|---|---|---|---|
| Reviewer | ☐ | ☐ | |
| Second checker | ☐ | ☐ | |

## Item 14 (B04): deteriorated labels M1110–M1114

**What you confirm:** B04's last 5 measurements, 18:25:44–18:26:58, are labelled deteriorated (1).

**Original documentation:**

> B04 log p.2, 17-11-2021 18:26: "The test was successfully completed because the RMS values of an accelerometer
> exceeded the specified limit!"

> Description p.8, Table 3: B04, Tvibration, Defect "IR, B". Description p.4: "Tvibration lies within [6, 10] g."

**Our data:**

- **End of recording:** the last record is 58 s after 18:26.
- **Vibration:** 4 of the 5 rows are above 6.5 g, and the largest rear RMS in the whole run is 8.72 g.
- **Earlier alarm:** the anomaly baseline alarms 3.5 hours earlier (M0442), with unchanged operating ranges.

**Assumptions and uncertainty:**

- **A1, provisional end-stage proxy:** these rows stand for the end-of-test state; damage in them is assumed, not
  verified. A2: the stop does not by itself prove the defect caused it.
- **Limit value:** unknown. If our RMS matched the rig's, it would lie between 6 and 8.7 g.
- **Item 4:** the position of these labels comes from the vibration rule.
- **Not an onset:** the early alarm shows why the deteriorated label must not be read as the start of the damage.

**Recommendation:** keep.

| | Confirm | Change | Comment |
|---|---|---|---|
| Reviewer | ☐ | ☐ | |
| Second checker | ☐ | ☐ | |

## Item 15 (B04): suspected logging or scaling discrepancy in speed and dynamic load

**What you confirm:** B04's speed and dynamic-load readings are documented as follows:

> **This is a suspected logging or scaling discrepancy, supported by our vibration analysis. It is not confirmed by the
> dataset authors.** In every B04 row, the recorded measured speed is 0.498–0.500 times the set speed, and the peak
> dynamic load is about 0.52 times the set value. The static load is normal. Our vibration analysis supports, but does
> not prove, that the shaft ran at the set speed and that these two columns were logged at half scale. Neither the
> dataset description nor the B04 log mentions it. The data are kept as recorded.

**Original documentation:**

> Description p.7: "meanAbs_speed / rpm is the mean absolute value of the measured shaft rotating speed." Also:
> "peak_dynLoad / N is the maximum value of the measured dynamic load".

> B04 log p.1: shaft rotational speed "Thigh [1500, 3000] rpm"; amplitude of the dynamic load "Thigh [500 1500] N".

Neither document mentions a scale factor, a fault or a correction.

**Our data (the supporting evidence):**

- **Ratios:** in all 1,114 rows, measured speed / set speed = 0.498–0.500 and peak dynamic load / set = 0.49–0.53
  (median 0.52). B02 and B03 read 1.00 and about 1.06.
- **Spectrum:** in 14 vibration files spread from M0001 to M1114, the shaft-rotation line sits at the set speed, 40 to
  326 times the background. At the recorded speed there is only background (0.1 to 2.7 times).
- **No effect on the model inputs:** they are identical with the speed doubled (a test checks this).
- **No effect on the labels:** labelling never reads the speed.

**Assumptions and uncertainty:**

- **Not confirmed:** half-scale logging is our interpretation of the spectrum, not a documented fact. Its cause
  (a logging scale factor, a sensor setting, or something else) is not documented and cannot be established from the
  files we have.
- **Recorded as a suspicion:** the registry's note for B04 (`paderborn_experiments.json`) now uses the same wording.
- **Future cross-bearing use:** raw speed or load must first multiply B04's two columns by 2, and it must say that the
  correction rests on this suspected discrepancy.

**Recommendation:** accept the documentation as a suspected discrepancy, keep the data as recorded, and optionally ask
the authors (O. K. Aimiyekagbon, LDM, Paderborn University) to confirm.

| | Confirm | Change | Comment |
|---|---|---|---|
| Reviewer | ☐ | ☐ | |
| Second checker | ☐ | ☐ | |
