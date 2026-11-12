# Machine Guardian: E3 with one accelerometer (`E3_single_accel`)

28 Oct 2026. Every number below was measured by the commands in section 10, unless it is marked **historical** (E3's
committed results of 27 Oct). Generated tables: `results/E3_single_accel/analysis.md`; short comparison:
`02b_Single_accel_comparison.md`; INT8 and RTL: `02c_Single_accel_hardware_report.md`.

## 0. Deployment decision (28 Oct, after this report's first version)

**The team chose accelerometer 1 (`E3_single_accel_a1`, seed 42) as the deployed vibration model**, for its mounting:
it is the only accelerometer on the motor, as ours will be. This is a **post-test decision**: it was taken after the
test results of all three variants (section 4) had been seen, and it overrides the validation rule's choice
(accelerometer 2, kept below and in `weights/E3_single_accel/selected.json` as the validation-only result). So
accelerometer 1's test result, 28/28, is not an unbiased estimate. Record: `weights/E3_single_accel/deployed.json`.

Accelerometer 1, seed 42, measured: FP32 test 28/28 faults, 4/4 healthy, accuracy / recall / precision / F1 / balanced
accuracy / ROC-AUC / MCC all 1.000 (every seed); **INT8 test 28/28, 0 false alarms, no decision changed in any split**;
RTL (xsim) bit-exact, 382 cycles per window. Health index (`H1_single_accel_a1`): ROC-AUC of D 1.000 / 1.000 / 0.929
(train / val / test); healthy recordings 100% except H_H_1_0 at 94%; at 15 Hz some faulty recordings are closer to the
healthy reference than the healthy ones (lowest faulty D 1.50 against healthy 1.85 and 2.07), so the index does not
separate at 15 Hz; 1/28 (val) and 4/28 (test) faulty recordings read 100%. The 15-Hz healthy margin of the classifier
is small (logits -3.39 and -2.50 against a cut of -0.62). Export: `export/E3_single_accel_a1/`.

## 1. Summary (first version: the validation-rule result)

- Three variants of E3, each with one accelerometer and ln f (8 inputs, 8 -> 32 -> 16 -> 1), trained with E3's exact
  rules and seeds 42, 43, 44. E3's files are unchanged.
- **Selected on validation: accelerometer 2** (`E3_single_accel_a2`, seed 42 exported). Validation saturates for all
  three (recall, F1, ROC-AUC = 1.000 in every seed); the pre-declared rule decided on its 8th key, window-level
  validation ROC-AUC (1.0000 against 0.9998 and 0.9990), backed by the lowest validation loss (0.0022 against 0.0037
  and 0.0102). That is weak evidence.
- **Test (FP32), accelerometer 2: 26/28 faults found in every seed, 4/4 healthy correct, ROC-AUC 1.000, F1 0.963,
  balanced accuracy 0.964.** Both misses are at 15 Hz (F_B_1_0, S_W_1_0). INT8 seed 42: 25/28 (R_M_1_0 crosses the
  cut). E3 (historical): 27/28.
- **On test, accelerometer 1 is better: 28/28 in every seed.** It was not selected because the rule uses validation
  only, and changing the choice now would use the test set. It is also the sensor whose mounting matches our hardware
  (section 7). Which one to deploy is a team decision; section 5 sets out both sides.
- **Health index on accelerometer 2:** D separates healthy from faulty perfectly in every split (ROC-AUC 1.000).
  Every healthy recording scores 100%, including the two 15-Hz ones that scored 0% with three accelerometers. The
  0-100% scale saturates, though: 11 of 28 faulty test recordings also score 100%, most of them at 15 Hz. The cause
  of the old 15-Hz failure was accelerometer 3's skewness and kurtosis (section 6).
- **INT8 and RTL:** the 8-input model runs unchanged on the 8x8 systolic MAC array; xsim matches Python bit for bit;
  382 cycles per window (E3: 566). These are simulation results, not FPGA measurements.

## 2. What was changed

| File | Change |
|---|---|
| `train.py` | New experiments `E3_single_accel_a1`, `_a2`, `_a3` (`single_accel_inputs(k)` = `log_inputs(..., accels=(k,))`); `main()` split into `run(name, out)` so other scripts can train; reports written as UTF-8 (on Windows `±` was written in cp1252). E0-E3 unchanged. |
| `features.py` | `vibration_inputs(x)`, `drive_inputs(f)`, `window_inputs(accel, f, extra=())`: the board-side 8-input vector from one accelerometer's raw 1-s window, with a slot for later sensor groups. The table code is unchanged. |
| `health.py` | `--accels` and `--name` (default `1 2 3`, `H1`: unchanged H1); `statistics(rows, accels)`. |
| `export.py` | `--health` (default `H1`), `--out`; the C header's text follows the model's accelerometers and size; the FP32 self-check allows 1e-5 between machines (it was exact equality, which fails on Windows by 7.6e-7: float32 rounding, README). E3's export reproduces: hex files, header and every integer identical. |
| `rtl_check.py` | `--sim vivado` (xsim, with `-O0`: Vivado 2019.1's default optimizer miscompiles `tb/tb_mlp.sv`, see the hardware report). Icarus stays the default. |
| `single_accel.py` (new) | Trains the three variants, applies the selection rule, writes `weights/E3_single_accel/selected.json` and `results/E3_single_accel/analysis.{json,md}`. |
| `test_single_accel.py` (new) | 22 pytest checks (section 9). |
| New outputs | `weights/E3_single_accel_a{1,2,3}/`, `results/E3_single_accel_a{1,2,3}/`, `weights|results/E3_single_accel/`, `weights|results/H1_single_accel_a{1,2}/`, `export/E3_single_accel_a{1,2}/`, `weights/E3_single_accel/deployed.json` |

No RTL, testbench or `mac.py` file was changed.

### Code against the description in the request (checked before any change)

The request's description matches the code, with these details from the code:
- Each accelerometer has 8 stored statistics; the model uses 7 (the mean is dropped). ln is applied to std, RMS,
  max|x| and peak-to-peak; crest, skewness and (Pearson) kurtosis are used as is.
- "Commanded drive frequency" = `f_hz`, the drive command's mean over each 1-s window. For 7 of the 64 ramp
  recordings, the ramp the drive actually followed was fitted from the 1x shaft line tracked on **accelerometers 2 and 3**
  (`speed.py`). That is a correction of the dataset's labels of the command, not a model input, and it does not use the
  accelerometer at run time; on our hardware `f` comes from the drive. It is noted because it is the one place where
  accelerometers 2 and 3 touch every variant's data.
- Threshold: the lowest cut on the validation recording scores that maximizes validation F1 with validation recall
  >= 0.8. In practice this is exactly the lowest faulty validation score (section 5).
- Class weighting: `pos_weight` = train healthy / train faulty = 8/56 = 0.142857 (down-weights the faulty class).
- Early stopping: patience 15 on the weighted validation BCE of the windows, improvement > 1e-5, best epoch kept.
- Ten-second averaging: a recording's score is the mean of its 10 window logits (on the chip: sum >= 10 * T_int).
- Weight decay 0, no dropout, deterministic on the CPU, one thread.

## 3. Model, data and training (unchanged from E3 except the input count)

- Inputs (8), in this order: `a<k>_log_std, a<k>_log_rms, a<k>_log_absmax, a<k>_log_p2p, a<k>_crest, a<k>_skew,
  a<k>_kurt, log_f`. Standardized with the train windows' mean and population std (in `model.json`).
- MLP 8 -> 32 -> 16 -> 1, ReLU after the two hidden layers, one logit; 833 parameters (E3: 1,281).
- Data: 128 ten-second recordings at 42 kHz, cut into 1,280 one-second windows. Split by speed code, every window
  of a recording in its recording's split: train 3, 4, 5, 8 (8 healthy / 56 faulty recordings), val 2, 7 (4/28),
  test 1, 6 (4/28). Checked by `test_single_accel.py`.
- Adam (lr 1e-3, betas 0.9/0.999), BCEWithLogitsLoss with pos_weight 0.142857, batch 64, at most 100 epochs,
  patience 15, seeds 42, 43, 44.

## 4. Results (new measurements; recordings, FP32)

### Validation (the selection basis)

All three variants: recall, precision, F1, balanced accuracy, specificity, ROC-AUC and MCC = 1.000 in every seed.

| Variant | Window ROC-AUC (mean ± std) | Best val loss (mean ± std) | Rank |
|---|---|---|---|
| a1 | 0.9990 ± 0.0002 | 0.0102 ± 0.0009 | 3 |
| **a2** | **1.0000 ± 0.0000** | **0.0022 ± 0.0002** | **1** |
| a3 | 0.9998 ± 0.0003 | 0.0037 ± 0.0013 | 2 |

### Test (every seed)

| Variant | Seed | Accuracy | Precision | Recall | F1 | Bal. acc. | Specificity | ROC-AUC | MCC | [[TN,FP],[FN,TP]] | Missed |
|---|---|---|---|---|---|---|---|---|---|---|---|
| a1 | 42, 43, 44 | 1.000 | 1.000 | 1.000 | 1.000 | 1.000 | 1.000 | 1.000 | 1.000 | [[4,0],[0,28]] | none |
| **a2** | 42, 43, 44 | 0.938 | 1.000 | 0.929 | 0.963 | 0.964 | 1.000 | 1.000 | 0.787 | [[4,0],[2,26]] | F_B_1_0, S_W_1_0 |
| a3 | 42 | 0.969 | 1.000 | 0.964 | 0.982 | 0.982 | 1.000 | 1.000 | 0.878 | [[4,0],[1,27]] | R_U_1_1 |
| a3 | 43 | 0.969 | 1.000 | 0.964 | 0.982 | 0.982 | 1.000 | 1.000 | 0.878 | [[4,0],[1,27]] | F_B_6_1 |
| a3 | 44 | 0.938 | 1.000 | 0.929 | 0.963 | 0.964 | 1.000 | 1.000 | 0.787 | [[4,0],[2,26]] | S_W_6_0, F_B_6_1 |

Mean ± std over seeds: a1 all 1.000 ± 0; a2 0.938 / 0.929 / 0.963 / 0.964 (accuracy / recall / F1 / balanced
accuracy), std 0; a3 0.958 ± 0.015 / 0.952 ± 0.017 / 0.976 ± 0.009 / 0.976 ± 0.008. No variant has a false positive
on validation or test in any seed.

### Train and losses (overfitting check)

| Variant | Train recall (42/43/44) | Best / last epoch | Train loss at best | Val loss at best |
|---|---|---|---|---|
| a1 | 1.000 | 99/100, 99/100, 93/100 | 0.0003-0.0004 | 0.0089-0.0108 |
| a2 | 1.000 | 99/100, 98/100, 98/100 | 0.0003 | 0.0019-0.0025 |
| a3 | 0.893 / 0.875 / 0.875 | 96/100, 61/76, 100/100 | 0.0005-0.0027 | 0.0018-0.0049 |

- The validation loss is still falling at epoch ~100 for a1 and a2 (best epoch 93-99): no sign of classic
  overfitting within the 100 epochs. The train/val loss ratio (about 7x for a2, 30x for a1) shows the train windows
  are fitted much more tightly than the unseen speeds.
- Accelerometer 3 alone **misses 6-7 training faults** at the validation cut: it underfits, so its information is
  insufficient on its own.
- With only 4 healthy recordings per evaluation split, all from the same physical motor, "no overfitting" here means
  "no overfitting to the train speed codes", not "generalizes to other motors".

### Where the errors are

- **Speed:** every recording-level miss of accelerometers 1 and 2 is at **15 Hz** (speed code 1, the only speed below the
  training range of 16.5-60 Hz); accelerometer 3's misses are at 15 Hz and 30->60 Hz. Validation (30 Hz and 45->15 Hz)
  has no misses.
- **Windows** (val + test, 1-s decisions at the recording cut): accelerometer 2 misses 21-26 of 168 faulty windows at
  14-20 Hz and 21-25 of 221 at 30-40 Hz, none at 40-61 Hz; no false alarms. Accelerometer 1 misses 7 of 221 at 30-40 Hz
  and has 1 false alarm (of 24 healthy windows) at 14-20 Hz. The 10-s average removes most window errors.
- **Fault classes:** accelerometer 2 misses F_B (bearing fault) and S_W (stator winding) at 15 Hz, unloaded; these
  two classes, and R_U for E3, are the hardest. Accelerometer 3 also misses F_B and S_W at 30->60 Hz.
- **Margins at 15 Hz** (seed 42, logits): accelerometer 2's healthy 15-Hz recordings score -4.65 and -4.69 against
  E3's (historical) -27.1 and -20.1; its two missed faults score 2.12 and 2.09 against a cut of 3.65. The healthy
  low-speed margin is much smaller with one accelerometer.

## 5. Which accelerometer is best

**By the pre-declared validation rule: accelerometer 2.** The choice is consistent across seeds: a2 has the lowest
validation loss and perfect window ROC-AUC in all three seeds. But every validation classification metric is tied at 1,
and the deciding differences are a few windows out of 320, so the validation set cannot really rank the three.

**What the test split shows (not used for the choice):** accelerometer 1 finds 28/28 in all three seeds, 2 finds
26/28, 3 finds 26-27/28. All three rank every test recording correctly (ROC-AUC 1.000). The differences come from
the cut position at 15 Hz, not from the ranking.

**Why the cut matters (an inherited weakness, also in E3):** the rule "lowest cut that maximizes validation F1"
always lands exactly on the lowest faulty validation score (a2 seed 42: cut 3.648 = R_U_2_0's score), while the
healthy validation scores stop at -6.9. A faulty test recording only slightly less abnormal than the mildest
validation fault is then missed, although it is far from every healthy recording. Accelerometer 2's two misses
(2.12, 2.09) and the INT8 flip of R_M_1_0 (3.68 against 3.65) are exactly this. I did not move the cut: it would be a
change chosen after seeing test. Recommendation: fix a margin-centred cut rule (for example the midpoint between the
highest healthy and the lowest faulty validation score) **as a new experiment**, decided before it is evaluated,
ideally with new data.

**Accelerometer 1 versus 2 for our hardware:** accelerometer 1 is mounted on the **motor** (drive end); accelerometers 2
and 3 are on the test rig's **shaft bearing housings** (section 7). Our system will have one accelerometer on the
motor, so accelerometer 1 is the physically matching sensor, and it also had the best test result. Against it: the
project log (27 Oct) found that accelerometer 1's spread alone separates the one healthy motor from every faulty one
at every speed, so its perfect score may reflect "this is the quiet motor" more than the fault; it has an
integrated temperature sensor and a constant offset of about 5 m/s^2; and it carries VFD electrical noise
(dataset paper). Choosing accelerometer 1 now on these grounds is legitimate only if the team states the mounting
argument as the reason, and must be reported as a post-test decision. The export is one command (section 10).

**Does one accelerometer carry enough information?** On this dataset, yes for detection: any of the three ranks every
test recording correctly, and accelerometers 1 and 2 match or approach E3's recall. Accelerometer 3 alone does not
(it misses train faults). Low speed is the weak point for all of them.

**Against E3 (historical):** E3 27/28, recall 0.964, F1 0.982, balanced accuracy 0.982, MCC 0.878 (seed 42), mean
recall 0.940 ± 0.034. Accelerometer 2: one more miss (26/28) but identical across seeds (std 0); accelerometer 1: one
fewer (28/28). Precision, specificity and ROC-AUC are 1.000 for all. Note E3's results were trained on another machine
and its test split shaped its design.

## 6. Health index (output 2)

Same method as H1 (`health.py`), refitted on accelerometer 2's 7 statistics: per statistic a line in ln f and its
spread, from the 80 healthy **train** windows only; D = mean over 10 windows of the RMS z-distance; anchors from train
only: D_100 = 3.208 (largest leave-one-speed-out healthy D, H_H_8_0), D_0 = 4.114 (median faulty train D).
Validation was not used to fit anything and no development decision was taken on it beyond running the fixed method.

| Split | Healthy HI | Faulty HI min / median / max | Faulty at 100% | Faulty at 0% | ROC-AUC of D |
|---|---|---|---|---|---|
| train | 100 x 8 | 0 / 0 / 100 | - | 28/56 | 1.000 |
| val | 100 x 4 | 0 / 45 / 100 | 10/28 | 12/28 | 1.000 |
| test | 100 x 4 | 0 / 59 / 100 | 11/28 | 11/28 | 1.000 |

Per speed code, the faulty median HI is 100% at 15 Hz (test), 46% at 30 Hz, 45% at 45->15 Hz, 0% at 30->60 Hz.
There is no case where the index shows poor condition for a healthy recording (0 of 16 below 100%).

**The 15-Hz 0% problem.** With three accelerometers (H1) the healthy 15-Hz recordings scored 0%. The z-scores show why:
accelerometer 3's kurtosis is +32 and +16 standard deviations from the healthy line at 15 Hz and its skewness -15 and
-6 (`analysis.md`, last table); accelerometer 3 alone even gives D_0 < D_100 (its index cannot be built). On
accelerometer 2 the largest |z| of the healthy 15-Hz recordings is 1.85, so they score 100%. On accelerometer 1 they
score 94% and 100% (test ROC-AUC 0.929). So the problem is solved by dropping accelerometer 3, not by changing the
method.

**Is it reliable?** As a ranking, on this dataset, yes (ROC-AUC 1.000 in every split). As a percentage, no:
- at 15 Hz the healthy D (1.08, 1.12) and the lowest faulty D (1.25) are close, and the median faulty recording reads
  100%; the 0-100% anchors are fixed across speeds and too loose for low speed;
- 11 of 28 faulty test recordings read 100%, so "100%" does not mean "healthy";
- the dataset has 8 motors (1 healthy, 7 each with one artificial fault) and no fault severities or wear progression,
  so nothing supports a continuous degradation percentage. HI is a distance from one healthy motor's vibration at that
  speed. It is not remaining strength or life, and it should not be shown to users as such.

`health.py` works on any number of statistic columns, so temperature and measured-RPM statistics can be appended in
`statistics()` once there is synchronized data to fit them.

## 7. Sensors, units, mounting

From the dataset paper (Sehri & Dumond, Data in Brief 2024, doi:10.1016/j.dib.2024.110144) and `dataset.py`:

| Channel | Sensor | Mounting | Used |
|---|---|---|---|
| Accelerometer 1 (column 1) | PCB 603C01, integrated temperature sensor | magnet on the **motor drive end** | a1 variant |
| Microphone (column 2) | PCB 130F20 | near the left bearing housing, on a separate stand | no |
| Accelerometer 2 (column 3) | PCB 623C01 | stud-mounted on the **shaft bearing housing near the drive end** | **selected** |
| Accelerometer 3 (column 4) | PCB 623C01 | stud-mounted on the shaft bearing housing farthest from the drive end | a3 variant |
| Temperature (column 5) | from accelerometer 1 | motor surface, drive end | no |

- Units m/s^2 (converted by the authors with the manufacturer sensitivities), single axis; the axis direction is not
  stated. 42,000 samples/s, 10 s per file, no filter, NI USB-6212 with a PCB 482C conditioner.
- Rig: SpectraQuest Machinery Fault & Rotor Dynamics Simulator; motors Marathon D396, 3 HP, 3-phase induction, 6205
  bearings, on a plate with rubber dampers.
- Preprocessing assumptions the board must reproduce: 1-s windows of exactly 42,000 samples at 42 kHz (a different
  rate changes max|x|, peak-to-peak, crest and kurtosis); raw acceleration in m/s^2 with its DC offset kept (no
  high-pass: the mean is dropped from the inputs, but RMS includes it); population moments; f = the drive's commanded
  frequency in Hz, not a tachometer reading.
- **Why mounting matters:** the selected model learned the vibration seen through a stud-mounted sensor on a bearing
  housing of this rig. A sensor on our motor's housing, magnet-mounted or in another axis, sees different transfer
  paths, resonances and amplitudes; the standardizer and health reference would be off even for a healthy motor.
  Matching the location, the mounting method and the axis is necessary, and it is still not sufficient: our motor,
  base and load differ from the rig. Plan to recollect a healthy reference (and the standardizer) on our own motor.

## 8. Limitations

- **Test set not independent:** E3's development used it, and this report shows all three variants' test results.
  The accelerometer was chosen on validation, but the test numbers are development results.
- **One healthy motor.** Every healthy recording (train, val, test) is the same physical motor; each fault is a
  different motor. A model can separate "this motor" from "the others" without learning faults. Nothing in this
  dataset can rule that out.
- **Tiny evaluation sets:** 4 healthy and 28 faulty recordings per split. The false-alarm rate 0/4 has a 95% interval
  of 0-60%; recall 26/28 is 0.76-0.99 (Clopper-Pearson).
- **15 Hz is outside the training range** (16.5-60 Hz); every recording-level miss of the selected model is there.
- **Validation saturates** and the cut sits on the lowest faulty validation score (section 5).
- Results computed on Windows (Python 3.12, PyTorch 2.14.1, NumPy 2.1.2), not the README's pinned Python 3.14 /
  NumPy 2.5.4; E3 retrains here with identical decisions and scores within 7e-6 of the committed ones.

## 9. Tests run

| Check | Result |
|---|---|
| `python -m pytest test_single_accel.py` (22 checks: one accelerometer and 8 inputs in E3's order per variant; train-only standardizer; no recording in two splits; 9 saved models load, have 8->32->16->1 shapes and reproduce their saved scores and decisions; board-side `window_inputs()` equals the table features; the selection follows the rule on validation keys; the health index uses the selected accelerometer's 7 statistics, train-fitted; INT8 hex + golden model reproduce the exported vectors, mean INT8 error < 0.5 logit; E3/H1 files untouched in git; E3 retrains to the same decisions) | **22 passed** |
| E3 retrained into a scratch folder, compared with `results/E3` | identical decisions, scores within 6.6e-6 (Windows vs Mac rounding) |
| H1 rerun into a scratch folder | HI within 2.4e-13 |
| `export.py` (E3) into a scratch folder | hex files, C header and every integer identical; FP32 floats differ in the last bits |
| `rtl_check.py --sim vivado` (E3) | **PASS** (566 / 818 cycles, as committed) |
| `rtl_check.py --experiment E3_single_accel_a2 --sim vivado` | **PASS** (hardware report) |
| `rtl_check.py --experiment E3_single_accel_a1 --sim vivado` (deployed model) | **PASS** (382 / 562 cycles; 28 of 32 test recordings called faulty = the 28 faulty) |
| `pytest` after the deployment decision (adds: `deployed.json` is consistent and flagged post-test; both INT8 exports checked) | **24 passed** |
| `mac.py test --quick --sim vivado` (accelerator edge cases, 2x2 to 16x16) | **PASS** 20/20 |
| `mac.py mlp --sim vivado` | **fails on this PC**: Vivado 2019.1's optimizer miscompiles `tb_mlp.sv` (not the RTL; `rtl_check.py` works around it with `-O0`). Not caused by these changes. |
| Icarus Verilog runs | **not run**: Icarus is not installed on this PC |
| `report/make_report.py` (PDF) | **not run**: `reportlab` is not installed; the PDF is unchanged and does not include this work |
| `features.py` / `ramps.py` | **not run**: the 2.5 GB dataset is not on this PC (not needed: the cached tables hold all three accelerometers) |

## 10. How to reproduce (inside `model/`)

```
python single_accel.py                                            # train a1, a2, a3; select; analysis
python health.py --accels 2 --name H1_single_accel_a2             # health index of the selected accelerometer
python export.py --experiment E3_single_accel_a2 --health H1_single_accel_a2
python rtl_check.py --experiment E3_single_accel_a2 --sim vivado  # or --sim icarus
python health.py --accels 1 --name H1_single_accel_a1             # the deployed model (accelerometer 1)
python export.py --experiment E3_single_accel_a1 --health H1_single_accel_a1
python rtl_check.py --experiment E3_single_accel_a1 --sim vivado
python -m pytest test_single_accel.py -q
```

## 11. Recommendations for the next phase

1. Done 28 Oct: accelerometer 1 chosen by mounting, recorded as a post-test decision (section 0). Mount our sensor
   like it: on the motor's drive end, same axis, magnet or stud as decided, and re-fit the reference on our motor.
2. **Collect our own data before trusting any number:** a healthy baseline on our motor at several speeds and loads,
   with the accelerometer mounted where and how it will stay, at 42 kHz (or retrain at our rate), synchronized with
   the temperature and RPM sensors. Use it as a truly unseen test set.
3. Write a **margin-centred threshold rule** as a new, pre-declared experiment (section 5).
4. Calibrate the health index per speed band (or drop the percentage and report a z-distance with "normal" and
   "abnormal" bands) once there is more than one healthy motor.
5. Add temperature and measured RPM as new input groups (`features.window_inputs(..., extra=...)`, `health.statistics`)
   only with synchronized training data; keep the commanded frequency until then.
6. Fix `mac.py`'s xsim build for Vivado 2019.1 (`xelab -O0`) or install Icarus Verilog on this PC.
