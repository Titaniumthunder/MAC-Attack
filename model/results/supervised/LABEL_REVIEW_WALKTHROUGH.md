# Label review walkthrough: the 15 items in label_review.TEMPLATE.json

*2 November 2026. For the reviewer and the independent checker. Nothing here signs anything off: every item's
`confirmed` stays empty until a person sets it. The label table under review is `label_table.json`, SHA-256
4eff40d8…, with the wording of items 2 and 15 revised on 2 November and the labels unchanged.*

## Sources

- **Description:**
  - O. K. Aimiyekagbon, "Run-to-failure data set of ball bearings subjected to time-varying load and speed
    conditions", v2, 25 March 2024, 9 pages. Zenodo record 10.5281/zenodo.10805042, file
    `LDM_UPB_Run-to-failure_data_set_of_ball_bearings.pdf`.
  - Pages cited: p.2 (introduction); p.4 (Table 2 and the stop criteria); p.7 (CSV columns); p.8–9 (Table 3).
- **Logs:** `newdata/B0x/B0x_log.pdf`. Page 1 gives the acquisition and operating parameters, page 2 the experiment
  log.
- **Our data:** `results/paderborn/B0x/checks.json` and the processed CSVs. These were used only to cross-check the
  documents. No label was taken from them.

**What the documents establish (and what they do not):**

- **Description p.2:** "No defect was initiated in the bearings before the experiments."
- **Description p.4:** an experiment ends when at least one of two criteria is exceeded:
  - housing vibration T_vibration "within [6, 10] g";
  - temperature T_temperature, 110 °C.

  B01 had no criterion pre-set, and B05 was deliberately interrupted.
- **Description p.8, Table 3:** the criterion that ended each test, and the defect type "discovered after
  dismantling the test bearing".
- **Not in any document:**
  - the dismantling date;
  - the damage size;
  - any inspection before the end;
  - the exact vibration limit for each bearing;
  - which accelerometer the limit used.

## Items for all bearings

### 1. Defect types after dismantling

- **What you confirm:** B01 IR, OR, B; B02 IR; B03 IR; B04 IR, B.
- **Source:** description p.8, Table 3, "Defect" column.
- **Check:** I read Table 3 for this walkthrough, and all four rows match `paderborn_experiments.json` and the label
  table. Durations and file counts also match: B01 2 h/377, B02 6 h/1116, B03 3 h/614, B04 6 h/1114.
- **Uncertainty:** the table gives the type of damage, not its size. It doesn't say when the bearing was dismantled.
- **Recommendation:** keep.

### 2. Assumptions A1–A4 and provisional end-stage labels (wording revised 2 November)

- **What you confirm:** the four assumptions behind the labels are acceptable.
  - **Provisional proxies:** the final five measurements of B02, B03 and B04 are provisional end-stage proxy labels,
    not a verified deteriorated state.
  - **Onset unknown:** the exact damage onset is unknown.
  - **Stop is not proof:** the rig stopping at its threshold does not by itself prove that the bearing defect caused
    the stop.
  - **A1, provisional end-stage proxy:** the damage was present in the last 5 measurements. This is assumed, not
    verified.
  - **A2, assumption:** the bearing defect caused the stop.
  - **A3:** the deteriorated label is not an onset time.
  - **A4:** the bearing was healthy during its start rows.
- **Source:**
  - A4 rests on description p.2 and the logs' "Begin with a new bearing" (p.2).
  - A1 and A2 have no direct document. They follow from Table 3 (damage found after the test), not from any statement
    about timing.
  - A3 is a rule we impose on ourselves.
- **Uncertainty:** A1 is the weakest. The documents don't say how long after the stop the bearing was dismantled, or
  whether anything happened in between. The last 5 measurements cover about 1.1–1.25 minutes before the stop, so the
  assumption is short-range, which keeps the risk small.
- **Recommendation:** keep the label ranges. Call the deteriorated labels provisional end-stage proxy labels in every
  result, and name A1 and A2 as the main uncertainties.

### 3. START_N = 100, END_N = 5, start window cut at a logged stop

- **What you confirm:** the counts and the cut rule.
- **Source:** `labels.py`. The counts were fixed on 2 November before B02 or B04 were opened. The cut rule was added
  at review (your B01 decision).
- **Uncertainty:**
  - The counts are design choices, not evidence.
  - END_N = 3, 10 and 20 are to be checked for sensitivity within the development set only.
  - END_N = 20 would reach about 5 minutes back. For B02 that is still above 6.5 g territory, while B03 there sits
    before its temperature crossing.
- **Recommendation:** keep.

### 4. The B02 and B04 end labels sit where a vibration stop rule fired

- **What you confirm:** you accept this, on the condition that every trained head is compared with the rule itself.
- **Source:**
  - Description p.4 (T_vibration within [6, 10] g) and p.8 (B02 and B04 both "T_vibration").
  - B02_log p.2: "RMS value of the accelerometer exceeded a value of 0.65 V four times". 0.65 V × 10 g/V (log p.1)
    is 6.5 g, inside the [6, 10] g range.
  - B04_log p.2: "exceeded the specified limit", with no value given.
- **Our data:**
  - In B02, the rear sensor A crosses 6.5 g exactly twice before the 13:32 pause (M0920, M0921). The front sensor C
    never reaches 6.5 g in either bearing, so the rig's rule almost certainly used A.
  - Of the last 5 measurements, 4 are above 6.5 g in both B02 (4.92, 7.16, 7.46, 6.57, 6.94 g) and B04 (3.17, 6.98,
    8.72, 8.21, 6.81 g).
  - B04 never exceeds 8.72 g, so if our RMS matched the rig's, its limit would be between 6 and 8.7 g. The logs don't
    say which.
- **Why it matters:** the damage at the end is confirmed independently, by dismantling. Where the labels sit,
  however, was decided by a vibration threshold on our own input sensor. A network trained on these labels can score
  well just by learning "rear RMS high = deteriorated", which is the stop rule, not a damage model.
- **Safeguards already in place:**
  - `baseline_comparison.json` scores the rule "rear RMS above 6.5 g" as a reference detector. It catches 40% of the
    end rows on B02 and B04, and 0% on B03.
  - B03 ended on temperature, not vibration. Its end labels are the only ones whose position was not chosen by
    vibration, so B03 is reported separately as the clean case.
- **Recommendation:** keep the labels. A trained head counts as useful only if it beats the rig rule and the anomaly
  detector on the held-out bearing, and especially on B03.

## B01

### 5. End label withheld

- **What you confirm:** B01 gets no deteriorated label.
- **Source:**
  - Description p.4: "for experiment B01 no criteria was pre-set". p.8: Table 3 lists B01's criterion as "-".
  - B01_log p.2, 09:13: "The experiment successfully completes because the temperature threshold value was
    exceeded!"
  - Our data: 272 measurements continue after 09:13, until 10:59.
- **Uncertainty:** the documents contradict each other: no criterion pre-set, yet a temperature threshold was
  exceeded. The 1 h 46 min of data after the "completion" is undocumented. The bearing was dismantled with IR, OR and
  B damage (Table 3), but nothing says when.
- **Recommendation:** keep it withheld.

### 6. B01 healthy labels: dropped (your decision after this walkthrough, 2 November)

- **What you confirm (now):** B01 has no healthy labels. The analysis below led to that decision; it originally
  reviewed the 54 operating measurements before the 09:13 log entry.
- **Source:**
  - B01_log p.2, 08:45: "The new bearing was installed the day before. It operated for a maximum of 15 minutes."
    Followed by a 10-minute warm-up.
  - B01_log p.2, 09:13: the "completes" entry.
  - Description p.2: no defect initiated.
- **New finding while preparing this walkthrough:**
  - The housing temperature T1 rises from 32.8 °C to 113.6 °C across these 54 rows.
  - T1 first reaches 110 °C at 09:12:49.
  - The last three "healthy" rows, M0103–M0105, are at or above the 110 °C stop temperature. This matches the log's
    09:13 "temperature threshold value was exceeded".
  - Rear vibration stays normal (median 1.2 g).
- **Uncertainties:**
  - **Prior running:** "It operated for a maximum of 15 minutes" the day before means the bearing was not unused. It
    does not contradict "no defect initiated", but the start is not a first run.
  - **Abnormal heating:** a new bearing reaching the failure temperature about 16 minutes after its warm-up is not
    normal operation. B02, B03 and B04 took hours to reach 66–110 °C. Whatever caused it (lubrication, fit,
    preload), the documents don't say. So "healthy" for these rows means "no bearing damage documented", not "normal
    condition".
  - **Masked temperature input:** B01's temperature input is masked (its thermal calibration fails the validity
    rule), so the network would only see normal vibration labelled as healthy.
- **Options:**
  - keep all 54, as decided;
  - cut to M0052–M0102, the rows below 110 °C;
  - drop B01's healthy labels.
- **Recommendation:** drop B01's healthy labels. A bearing that reaches the documented failure temperature within
  these rows isn't a defensible example of a healthy motor. Removing them costs 54 of 354 healthy rows. If you want to
  keep B01, cut to M0052–M0102 at the least.

## B02

### 7. Healthy labels M0052–M0151

- **Source:** B02_log p.2, 08:59: "Begin with a new bearing", then a 10-minute warm-up. Description p.2.
- **Our data:** the warm-up is 51 rows (M0001–M0051), so the healthy rows start at the first operating measurement.
  They cover about 30 minutes at test conditions. Rear RMS is about 1 g, T1 is still rising, and the thermal
  calibration is valid.
- **Uncertainty:** A4 only. Nothing points against it.
- **Recommendation:** keep.

### 8. Deteriorated labels M1112–M1116 (14:35:29–14:36:36)

- **Source:** B02_log p.2, 14:36: "successfully completed because the RMS value of the accelerometer exceeded a value
  of 0.65 V four times". Description p.4 and p.8: T_vibration; defect IR.
- **Our data:** the last record is 36 s after 14:36, with nothing after the logged stop. 4 of the 5 rows are above
  6.5 g.
- **Uncertainty:** A1. Item 4 also applies: the position comes from the vibration rule.
- **Recommendation:** keep.

### 9. The 13:32 pause is not a label

- **Source:** B02_log p.2, 13:32: "stopped because the RMS value … exceeded a value of 0.65 V twice. To account for
  possible outliers, the test was continued …".
- **Our data:** a 4 min 42 s gap (13:32:36 to 13:37:18), and exactly two rows above 6.5 g before it.
- **Reasoning:** the bearing was not dismantled at 13:32, so no document says it was damaged then. Its RMS had jumped
  from about 1 g to about 5 g at about 13:15, but that is a measurement, not evidence.
- **Recommendation:** keep it masked. Do not use 13:32 as a label or an onset time.

### 10. Crossing count: 13 in our data, 4 in the log

- **Source:** B02_log p.2, 14:36 ("four times"). Our processed rear RMS.
- **Reasoning:** our RMS is computed over each stored 1.6-s window. The rig's monitoring RMS window and its counting
  rule are not documented, and it may also count crossings it did not store. No label depends on this count.
- **Recommendation:** acknowledge it; no change.

## B03

### 11. Healthy labels M0001–M0100

- **Source:**
  - B03_log p.2, 15:10: "Begin with a new bearing", with a 10-minute warm-up described.
  - Description p.2.
- **Our data:** the first record is at 15:10:43, and no rows are at warm-up settings. Either the warm-up was not
  stored, or it ran under other settings. The healthy rows are therefore the first 100 at test conditions (about 31
  minutes). The thermal calibration is valid.
- **Uncertainty:** the missing warm-up is undocumented. It doesn't affect the healthy status.
- **Recommendation:** keep.

### 12. Deteriorated labels M0610–M0614 (18:22:25–18:23:40)

- **Source:**
  - B03_log p.2, 18:23: "automatically stopped because the bearing housing temperature exceeded the specified limits
    of 110°C".
  - Description p.4 and p.8: T_temperature; defect IR.
- **Our data:** T1 first goes above 110 °C at M0612 (18:23:02). The labelled rows straddle that crossing, and the
  last record (118.2 °C) is 40 s after 18:23.
- **Uncertainty:** A1. T1 reads up to 8 °C above the limit, probably from sensor lag or a different control sensor;
  it doesn't affect the label. This is the one end label whose position was not chosen by vibration.
- **Recommendation:** keep.

## B04

### 13. Healthy labels M0051–M0150

- **Source:** B04_log p.2, 12:45: "Begin with a new bearing", with a 10-minute warm-up. Description p.2.
- **Our data:** the warm-up is 50 rows. The healthy rows are about 30 minutes at test conditions, and the thermal
  calibration is valid.
- **Note:** at 13:45 the log records that, with the bearing above 60 °C, the higher-temperature parameter set was
  selected. B04_log p.1 calls it T_high, and its ranges are the ones already in use, so nothing changed. The healthy
  rows end at 13:26, before that.
- **Recommendation:** keep.

### 14. Deteriorated labels M1110–M1114 (18:25:44–18:26:58)

- **Source:**
  - B04_log p.2, 18:26: "successfully completed because the RMS values of an accelerometer exceeded the specified
    limit". The value is not stated.
  - Description p.4 (limit within [6, 10] g) and p.8 (T_vibration; defect IR, B).
- **Our data:** the last record is 58 s after 18:26, and 4 of the 5 rows are above 6.5 g.
- **Uncertainty:** the limit's value is unknown, and A1 applies. Item 4 also applies.
- **B04's baseline alarm:** the anomaly baseline alarms 3.5 hours earlier (M0442), with unchanged operating ranges.
  Damage probably started long before the stop, and this is why the end label must not be read as an onset.
- **Recommendation:** keep.

### 15. B04 speed and dynamic load: suspected logging or scaling discrepancy (wording revised 2 November)

- **What you confirm:** the readings are documented as a suspected logging or scaling discrepancy. It is supported
  by our vibration analysis and not confirmed by the dataset authors. The data stay as recorded.
- **Source:**
  - Description p.7: `meanAbs_speed` is "the mean absolute value of the measured shaft rotating speed". No scale
    factor is mentioned.
  - B04_log p.1 gives the set ranges.
  - Neither document mentions the problem.
- **Our data:**
  - In every row, measured speed / set speed = 0.498–0.500 and peak dynamic load / set = about 0.52. B02 and B03 read
    1.00 and about 1.06.
  - In 14 vibration files spread across B04 (M0001, the warm-up, to M1114), the shaft-frequency line stands at the
    set speed: 40 to 326 times the background. At the recorded speed there is only background (0.1 to 2.7 times).
  - This supports, but does not prove, that the shaft ran at the set speed and the two columns were logged at half
    scale.
- **What depends on it:**
  - **Nothing in the labels:** labelling doesn't read the speed.
  - **The model inputs are identical** with the speed doubled (a test checks this).
  - **Only the per-bearing thermal coefficient changes** (35.0 against 17.5 °C per 1000 rpm).
  - **A future rule:** any cross-bearing use of raw speed or load must first multiply B04's columns by 2.
- **Uncertainty:** the explanation is ours, from the spectrum, and not confirmed by the dataset authors. Its cause is
  undocumented.
- **Recommendation:** document it as a suspected discrepancy, keep the data as recorded, and optionally ask the
  authors (O. K. Aimiyekagbon, LDM Paderborn) to confirm.

## Summary of recommendations

| Item | Recommendation |
|---|---|
| 1, 3, 7, 8, 11, 12, 13, 14 | keep |
| 2 | keep; the deteriorated labels are provisional end-stage proxies, the onset is unknown, and the stop does not prove the cause |
| 4 | keep, provided every trained head is compared with the rig rule and B03 is reported on its own |
| 5 | keep withheld |
| 6 | **changed:** B01's healthy labels dropped; B01 now has no labels and is in no fold |
| 9, 10 | no label; acknowledge |
| 15 | document as a suspected logging or scaling discrepancy (not confirmed by the authors); data as recorded |

**Signing off:** copy the template to `label_review.json` and set every `confirmed` to true. The reviewer fills in
`checked_by` and `date`, and a second person fills in `independent_check_by` and `independent_check_date`.
`supervised_prep.ready()` and `train_deterioration.py` refuse until all of this is in place for the current table.

**Update after this walkthrough:** item 6 was decided as recommended. B01's healthy labels are dropped. The label
table, its hash, the template, the figure and the report are regenerated, and the template's B01 item describes the
decision.