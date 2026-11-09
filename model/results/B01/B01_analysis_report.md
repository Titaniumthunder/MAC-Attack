# Paderborn experiment B01: preprocessing and analysis

1 Nov 2026. Data: `model/newdata/B01/` (read-only). Code: `model/b01_preprocess.py` (features, merge, checks),
`model/b01_analysis.py` (normalization, change detection, figures). Outputs in this folder: `B01_processed.csv`,
`checks.json`, `analysis.json`, `figures/`. The Ottawa model and its files were not touched; no network was trained.

Every number below comes from those two scripts. **No deterioration label, failure time or health percentage is
written to any file.** Where this report says "change at M0208", that is an analysis finding, not a label.

## 1. Summary

- **The files are complete and consistent with each other.** All 377 measurements (`data_B01_M0001.mat` to `M0377`)
  are present and readable, with 2 channels × 204,800 samples at 128 kHz (1.6 s) and no missing or non-finite values.
  Both CSVs have 377 rows with identical, strictly increasing timestamps. Measurement k matches CSV row k, which I
  verified rather than assumed (section 4).
- **This is not one uninterrupted run.** The log says the experiment ended at 09:13 because the temperature threshold
  was exceeded. The CSVs agree up to 09:13:24 (record 105, T1 = 113.6 °C), but then continue: after a **19-minute
  stop**, the bearing (cooled to 51 °C) was restarted **without the warm-up phase** and ran until 10:59:32, with another
  2.3-minute stop at 09:40. **272 of the 377 measurements (72%) are not covered by the log.**
- **There is one clear, abrupt vibration change at M0208 (10:06:24).**
  - Every amplitude and band feature on both accelerometers moves from inside to far outside its speed/load-corrected
    normal range, and stays there.
  - Speed, load and temperature did not change at that moment.
  - The change point does not depend on how the reference period is chosen.
  - Nothing in the 156 measurements before it shows a gradual drift.
- **The run ends in a second escalation.** From about M0360 (10:54) vibration rises again (RMS up to 14 g; over the last
  20 measurements RMS is 8.5× rear and 13× front the reference median, and the 20–64 kHz band about 15–16×), kurtosis rises above 3.5 from M0367, and T1 jumps from 113 °C to 122.6 °C. The data stop at 10:59:32
  with no recorded reason.
- **Labels and a health index are not well supported.** B01 can support a *change-detection* target (normal before
  M0208, changed after) for this one run, but not a validated deterioration label. Nothing documents what happened to
  the bearing, the onset comes from the data itself, and it is a single bearing. A meaningful 0–100% health index is
  **not** supported: there is no ground-truth condition, no failure point, and only three observed regimes. **More
  Paderborn experiments are needed before training** (section 9).

## 2. Dataset structure

```
B01/
  B01_log.pdf                       2 pages: acquisition parameters and the experiment log
  B01_meanTemperatures.csv          377 rows: Time, Mean Abs. Temp. T1 / °C, T2 / °C, Mean Room Temp. / °C
  B01_operatingConditions.csv       377 rows: Time, setDynLoad / N, peak_dynLoad / N, setStatLoad / N,
                                    meanAbs_statLoad / N, setSpeed / rpm, meanAbs_speed / rpm
  vibrationData/data_B01_M0001.mat … data_B01_M0377.mat   (1.1 GB)
     accHorizRear_A, accHorizFrontal_C   204,800 × 1, volts (10 g/V)
     measTime                            0 … 1.5999922 s (128 kHz)
```

From the log (read in the PDF viewer, because its numbers are in a font the text extractor could not decode):
- Sampling: 128 kHz for 1.6 s, then a pause of about 12 s; 10 g/V; gain 0 dB.
- History: a new bearing was installed the day before and ran at most 15 minutes. The warm-up phase was 10 min at
  750 rpm and 2500 N static load, with no dynamic load.
- Operating ranges, drawn at random before each measurement: speed 2400–3000 rpm; static load 3300–3800 N; dynamic
  amplitude 500–1400 N at 2 Hz; combined load 4300–4900 N.
- Log entries: 19-10-2021 8:45 start; 9:13 "The experiment successfully completes because the temperature threshold
  value was exceeded!"

The `.mat` files carry no clock time (they were exported on 20 Feb 2023), and the CSVs carry no measurement id.

## 3. Processing (`B01_processed.csv`, 377 rows × 47 columns, in time order)

- **Vibration**, per channel (A = rear, C = front, both horizontal), converted to g (× 10). Per 1.6-s measurement:
  - mean, std, RMS, peak = max |x|, peak-to-peak, crest = peak / RMS, skewness, kurtosis (Pearson);
  - RMS in four bands from the FFT of the mean-removed signal: 10 Hz–1 kHz, 1–5 kHz, 5–20 kHz, 20–64 kHz.
- **Conditions and temperatures**, as recorded:
  - set and measured speed, set and measured static load, set and peak dynamic load;
  - T1, T2 and room temperature.
- **Derived columns** (facts, not judgements):
  - `segment` (1–3, split at stops longer than 60 s), `gap_before_s`, `t_in_segment_s`;
  - `warmup` (750 rpm / 2500 N / no dynamic load), `after_log_end` (after 09:13);
  - `combined_set_N`, `speed_error_rpm`, `stat_error_N`;
  - flags: `flag_setSpeed_out_of_log_range`, `flag_speed_not_reached`, `flag_static_load_off_150N`.

## 4. Integrity checks (`checks.json`)

| Check | Result |
|---|---|
| Files M0001–M0377, contiguous, no extras | yes (377 / 377) |
| Samples per file, sampling rate | 204,800 in every file; 128,000 Hz |
| Non-finite values | none |
| CSV rows; the two CSVs' timestamps identical | 377; identical |
| Timestamps increasing, duplicates | strictly increasing; 0 duplicates |
| Interval between records | 11–26 s during operation (median 18 s); log: about 12 s pause + 1.6 s |
| **Id ↔ row alignment, test 1** | The warm-up ends after row 51. Vibration log-RMS jumps by **2.00** between M0051 and M0052; the largest step between warm-up measurements is 0.045. |
| **Id ↔ row alignment, test 2** | Speed is re-drawn before each measurement. The change in log-RMS of file k+lag correlates with the change in log-speed of row k: **r = +0.24 at lag 0**, and \|r\| ≤ 0.11 at lags −3…+3. |

Both tests place the files on the rows by id with no offset.

## 5. Timeline and the log discrepancy

| Segment | Ids | Time | Records | Start → end T1 | Notes |
|---|---|---|---|---|---|
| 1 | M0001–M0105 | 08:46:54–09:13:24 | 105 (51 warm-up) | 21.4 → 113.6 °C | Matches the log, which ends 09:13 on the temperature threshold. |
| (stop) | | 09:13:24–09:32:31 | | | **19 min 7 s**: T1 falls to 51.1 °C |
| 2 | M0106–M0133 | 09:32:31–09:40:50 | 28 | 51.1 → 89.1 °C | Restarted at operating conditions; **no warm-up**. |
| (stop) | | 09:40:50–09:43:08 | | | 2 min 18 s: T1 89.1 → 82.1 °C |
| 3 | M0134–M0377 | 09:43:08–10:59:32 | 244 | 82.1 → 119.0 °C (max 122.6) | Not in the log; T1 plateaus at about 110–114 °C and stays above segment 1's stopping temperature for over an hour. |

What we can and cannot say about this:
- The 09:13 stop is the logged temperature-threshold stop.
- After it, the same file sequence continues with the same acquisition and the same random-condition protocol.
  Nothing in the data marks a new bearing: vibration in segment 2 matches the end of segment 1 (figure
  `B01_normalized_residuals.png`).
- **Likely, but not documented:** the run was resumed on the same bearing, possibly with a raised or disabled
  threshold, since T1 then stayed above 113.6 °C for long periods. Why it stopped at 10:59:32 is not recorded.
- **Treat B01 as three operating segments of one bearing with unknown interventions between them.** Ask the dataset
  authors before relying on the continuation.

## 6. Operating-condition consistency

- **Speed setpoints out of the logged range:** 33 rows, all in segment 1 (M0052–M0104), with setpoints up to
  3552 rpm. In 32 of them the drive did not reach the setpoint and the measured speed sat at about 3003 rpm, the
  apparent limit. Segments 2 and 3 stay within 2400–3000 rpm. Use the measured speed, never the setpoint.
- **Combined set load:** always within 4300–4900 N, but **exactly 4300 N in 172 of 326 operating rows**, and 4900 N in
  19. The draws were evidently clipped to the range limits, so the loads are not uniformly spread.
- **Static load:** the measured value differs from the setpoint by a median of 70 N; 48 rows are off by more than
  150 N (maximum 552 N).
- The dynamic peak is on average 30 N above its setpoint.
- **Warm-up:** 51 measurements at 750 rpm, where vibration is about 8× lower than in operation and the temperature
  rises from 21 to 32 °C. Not comparable with the operating rows.

## 7. Deterioration analysis

**Method** (`b01_analysis.py`; the normalization was fixed before looking at the residuals):
- For each vibration feature, fit ln y = b0 + b1 ln(measured speed) + b2 static load + b3 peak dynamic load on the
  operating measurements before M0208 (156 measurements).
- Express every measurement as z = residual / σ of that reference.
- A sustained change is the first measurement starting 3 consecutive z > 3.
- Temperature is deliberately **not** in the model: it rises with operation (warm-up) and probably with damage, so
  it is examined separately.

Speed and load explain part of the vibration: R² is 0.73 (rear) and 0.74 (front) for the 20–64 kHz band, 0.26 / 0.45
for RMS, and 0.70 / 0.88 for 10 Hz–1 kHz. The high-frequency band scales as about speed².

**The change at M0208** (`figures/B01_overview.png`, `B01_vibration_features.png`, `B01_normalized_residuals.png`):

| Feature (rear A / front C) | First sustained z > 3 | Median z after | Pre-M0208 \|z\| > 3 |
|---|---|---|---|
| RMS | **M0208** / **M0208** | 11.5 / 9.0 | 2 / 3 (single spikes M0063–M0066) |
| Peak | M0208 / M0208 | 13.8 / 13.7 | 2 / 2 |
| 20–64 kHz band | **M0208** / **M0208** | 33.8 / 32.0 | **0 / 0** |
| 5–20 kHz band | M0208 / M0208 | 10.6 / 23.2 | 3 / 0 |
| 1–5 kHz band | M0208 / M0208 | 22.4 / 11.0 | 1 / 2 |
| 10 Hz–1 kHz band | M0208 / M0208 | 10.9 / 12.8 | 5 / 4 |
| Kurtosis | M0208 / M0212 | 1.4 / 1.7 (last 20: 9.2 / 5.6) | 2 / 5 |
| Crest | M0218 / M0212 | 0.7 / 3.1 | 2 / 1 |

- **The change is abrupt.** The 20–64 kHz band goes 0.05 g → 0.09 (M0208) → 0.22 (M0209) → about 0.8 g (from M0216),
  about 16× the reference median. RMS goes from about 1 to 4–5 g within two measurements.
- **It is not caused by the operating conditions.** Means over the 30 measurements before and after M0208:

  | | Before | After |
  |---|---|---|
  | Speed (rpm) | 2778 | 2699 |
  | Static load (N) | 3528 | 3573 |
  | Dynamic peak (N) | 928 | 892 |
  | T1 (°C) | 112.8 | 111.4 |

  The z-scores already remove speed and load, and `B01_vibration_vs_speed.png` shows the after-change points far
  above the before-change cloud at every speed.
- **It is robust.** With the reference ending at M0120, M0150, M0180 or M0200 instead of M0208, every feature still
  detects M0208 first. The 20–64 kHz band never exceeds 3σ on M0052–M0207.
- **No precursor.** Before M0208 the residual drift is −0.007σ (rear 20–64 kHz) and −0.56σ (rear RMS) per 100
  measurements, i.e. no upward trend. After 49.8 operating minutes, the change appears within one 18-s interval.
- **Both channels change together,** which fits a change in the bearing rather than a single sensor or cable fault.
- **The final escalation** comes after about 45 minutes in a raised but stable state (about M0216–M0359). RMS rises
  again from M0359 (10:53), kurtosis is sustained above 3.5 from M0367 (10:56:08), and T1 jumps from 113 to 122.6 °C
  at 10:57. Kurtosis 5–6 at the end points to strongly impulsive vibration. The recording stops at 10:59:32 without an
  explanation.

**Warm-up, restarts and temperature** (`B01_temperature_effect.png`):
- In the 750 rpm warm-up, vibration RMS stays flat (+5% over 10 min) while T1 rises from 21 to 32 °C.
- Before M0208, the rear RMS residual correlates −0.40 with T1: it is slightly *lower* when hotter. That is partly a
  segment effect (mean z: segment 1 +0.15, segment 2 +0.53, segment 3 −0.31), small compared with the change at
  M0208.
- Right after the cold restart (segment 2, T1 ≈ 51–60 °C), the 20–64 kHz residual is about −1.6σ (lower). This is a
  measurable restart/temperature effect, but it stays inside ±3σ.
- **Temperature is mostly an operating-history signal here.** T1 is driven by warm-up and stops (21 → 114 °C within
  segment 1; 51 → 110 °C after the restart) and plateaus at about 110 °C under steady random operation. It *decreases*
  slightly after M0208 and rises only in the final escalation. Using T1 as a deterioration input without modelling
  the warm-up would confuse "recently started" with "healthy" and "running long" with "worn".
- **Measured RPM is an operating condition, not a condition indicator.** It is set at random by the test bench. Its
  role is to normalize the vibration (as in the fit above).

**Isolated events:** M0063–M0066 (09:00–09:01, segment 1) show short RMS spikes on both channels (rear up to 3.4 g).
M0063 has an unusually low crest factor (2.5). They do not persist, and the 20–64 kHz band does not react. Their cause
is unknown (possibly a transient of the bench). They are flagged here, not removed.

## 8. Does B01 support reliable deterioration labels and a meaningful Motor Health Index?

**Deterioration detection: partly.**
- **For:** there is a sharp, reproducible, condition-independent change at M0208 on both sensors. A detector trained to
  separate "like the early reference" from "unlike it" has a clear target in this run.
- **Against:**
  1. There is no ground truth. The log does not say what happened to the bearing (no inspection, no damage
     description), and it does not cover the period in which the change occurs.
  2. The onset comes from the same vibration features a model would learn. Using it as a label and then "detecting"
     it with those features is circular, and would overstate performance.
  3. There is one bearing, one change. The detection threshold and the timing can't be validated on a second case.
  4. There is no precursor, so this run cannot teach *early* detection of deterioration that begins gradually; it shows
     an abrupt event.
  5. The interventions between segments are undocumented.
- **What can be done honestly:** use B01 as one *unsupervised change-detection* case (reference = early operation),
  report the change at M0208 as an observation, and do not train on "healthy/faulty" labels derived from it.

**Motor Health Index (0–100%): not supported.**
- There is no condition measure to calibrate against: no wear measurements, no damage size, no defined failure point.
  The end of recording is not documented as a failure.
- The data show three regimes, not a continuum: reference (M0052–M0207), raised and stable (about M0208–M0359), and
  escalating (M0360–M0377). Any mapping of these to percentages, and especially a smooth decline, would be invented.
- What *is* supported: a normalized distance from the early-operation reference (the z-scores here, comparable to the
  Ottawa H1 index). It can be shown as "within normal range / abnormal / strongly abnormal". It is **not** remaining
  life or strength.

**Consequences for our hardware:**
- The most sensitive feature here is the **20–64 kHz** band. It can only be measured with a sample rate of at least
  128 kHz. At the Ottawa pipeline's 42 kHz, that band is lost.
- The 5–20 kHz band (z ≈ 10–23 after M0208) and RMS would still have shown the change, with less margin.
- Our sensor's sample rate and bandwidth need to be chosen with this in mind.

## 9. Do we need more Paderborn experiments before training the new model?

**Yes.** B01 is a well-recorded single case, but it is not enough to train or validate a multi-task model:

1. **More run-to-failure experiments** of the same series (B02, B03, …) under the same randomized protocol. They would
   show whether the change is always abrupt or sometimes gradual, how it varies between bearings, and whether
   temperature leads or lags vibration. Several bearings are needed for any held-out evaluation.
2. **Documentation from the Paderborn team** (LDM) about B01:
   - what happened at 09:13–09:32 and 09:40–09:43;
   - whether segments 2–3 are the same bearing, and why it stopped at 10:59;
   - the post-test inspection (damage type and size).

   Without this, the end state cannot be called a failure.
3. **Healthy-only runs** under the same randomized speeds and loads, long enough to cover warm-up, restarts and
   thermal plateaus. These are needed to estimate the false-alarm rate, which B01 (156 reference measurements, one
   bearing) cannot.
4. **If a health index is still wanted,** experiments with measured intermediate damage states (inspections between
   stages, or seeded defects of increasing size), so a scale can be anchored to something physical.
5. Keep the vibration sample rate at 128 kHz (or at least above 40 kHz with the 5–20 kHz band) in our own recordings,
   synchronized with temperature and measured RPM.

## 10. Reproduce

```
python b01_preprocess.py      # reads model/newdata/B01 (or --data <folder>); writes B01_processed.csv, checks.json (about 15 s)
python b01_analysis.py        # writes analysis.json and figures/
```

| Figure | Shows |
|---|---|
| `figures/B01_overview.png` | Vibration RMS (both channels), T1/T2/room temperature, set and measured speed, loads against clock time, with segments, the log end (09:13) and M0208 |
| `figures/B01_vibration_features.png` | Band RMS (rear), kurtosis and crest of both channels by measurement id |
| `figures/B01_normalized_residuals.png` | RMS and 20–64 kHz z-scores after removing speed and load, with the ±3σ reference band |
| `figures/B01_vibration_vs_speed.png` | Rear RMS and 20–64 kHz band against measured speed, before and from M0208 |
| `figures/B01_temperature_effect.png` | Pre-M0208 RMS residual against T1, by segment (warm-up and restart effects) |

Note: `model/newdata/` (1.1 GB of `.mat` files) is not covered by `.gitignore`. It should not be committed.
