# Machine Guardian — The Current Model

MAC-Attack senior capstone. This document describes only the latest model: the bearing-deterioration multi-task MLP
selected in Training Run 3 (configuration E). The earlier models and runs are covered by documents 01–11 in this
folder; `README.md` gives the reading order. Every number here comes from `model/results/supervised/run3/` and
`docs/Model/10_Training_run3.md`. Written 9 November 2026.

## 1. The Model in Brief

| | |
|---|---|
| What it does | Watches one bearing through one accelerometer (plus shaft speed) and raises a **deterioration alarm** when the bearing's vibration looks like a worn-out, end-of-life bearing |
| Network | multi-task MLP, **8 → 32 → 16 → 2**, ReLU, **850 parameters** |
| Configuration | **E**: weight decay 0.01, log-compressed inputs, temperature input switched off |
| Trained on | 7 Paderborn run-to-failure bearings: 9,003 measurements, of which 735 are labelled |
| Output 1 | deterioration score (0–1) and a latched alarm. **Trained** |
| Output 2 | Motor Health Index (0–100 %). **Untrained, frozen, never reported** |
| Held-out result | alarm before the stop on **6 of 7 bearings**; **0** false alarms on healthy rows; never earlier than the simple anomaly detector, which catches all 7 |
| Hardware | INT8 on the team's 8 × 8 systolic array: **382 clock cycles = 1.78 µs** per measurement, bit-exact in RTL simulation. **Not yet run on the ZedBoard** |
| Status | experimental. Not frozen, and not yet tested on the four locked test bearings |

> **Key finding:** the model works end to end, from vibration to an INT8 alarm on our accelerator, and it is stable and
> reproducible. It does not yet beat the label-free anomaly detector: it alarms at the same time or later, and misses
> one bearing.

## 2. The Data

### 2.1 Datasets and what each is used for

| Dataset | Use in the current model |
|---|---|
| **Paderborn run-to-failure bearing dataset** (Paderborn University, LDM; Zenodo 10.5281/zenodo.10805042): 17 bearings, each run under varying load and speed until it failed, with two accelerometers, temperature, speed and load | the only training and validation data |
| — 7 development bearings: B02, B03, B04, B08, B09, B11, B12 | training and leave-one-bearing-out validation |
| — 4 locked test bearings: B06, B07, B13, B17 | the final one-time test. **Never loaded** |
| — B01 | processed, but no labels (it overheated within 16 minutes and its documents contradict each other) |
| — B05, B10, B14, B15, B16 | not used yet (candidates for the next run) |

### 2.2 The seven training bearings

| Bearing | Sampling | Operating measurements | Recorded span | Stop (log) | Damage found at dismantling |
|---|---|---|---|---|---|
| B02 | 128 kHz | 1,065 | 5.6 h | vibration | inner race |
| B03 | 128 kHz | 614 | 3.2 h | temperature | inner race |
| B04 | 128 kHz | 1,064 | 5.7 h | vibration | inner race, ball |
| B08 | 128 kHz | 1,777 | 10.6 h | temperature | inner race, ball |
| B09 | 128 kHz | 1,763 | 12.1 h | vibration | outer race, ball |
| B11 | 64 kHz | 1,953 | 8.8 h | vibration | inner race, outer race, ball |
| B12 | 64 kHz | 767 | 2.5 h | vibration | inner race, ball |
| **Total** | | **9,003** | 48.5 h | | |

**What a data point is:** one 1.6-second vibration recording, taken every 12–23 s. It holds 204,800 samples per
channel at 128 kHz, or 102,400 at 64 kHz. Each recording becomes one row of 8 inputs.

### 2.3 Labels

| Label | Rule | Rows | Share of the 9,003 |
|---|---|---|---|
| Healthy (0) | first 100 operating measurements of each new bearing | 700 | 7.8 % |
| End-stage (1), **provisional proxy** | last 5 measurements before a documented stop | 35 | 0.4 % |
| Unlabelled | everything in between | 8,268 | 91.8 % |

- **Source:** the labels come only from the dataset documents (start of test, logged stop, damage found at
  dismantling). No sensor value is used to set them.
- **What the end-stage labels mean:** they stand for the end-of-test state. When damage actually began is unknown.
- **Health index:** no measured damage sizes exist, so the Motor Health Index has no labels.

## 3. How the Data Are Split

The split is always by **whole bearing**, never by individual measurement, so a model is always judged on a bearing it
has never seen.

| Level | Train | Validation | Test |
|---|---|---|---|
| Whole dataset (17 bearings) | 13 development bearings (76 %), of which 7 are used | – | 4 locked bearings (24 %), untouched |
| Each outer fold (7 bearings) | 6 bearings (86 %) | – | 1 held-out bearing (14 %) |
| Each inner fold, for choosing the configuration | 5 bearings (71 % of the 7) | 1 bearing (14 %) | the outer bearing (14 %) stays unseen |
| Final model | all 7 bearings (100 %, 735 labelled rows) | – | – |

**Nested leave-one-bearing-out:**

- **Outer loop:** each of the 7 bearings is held out in turn: 7 folds × 5 seeds = 35 held-out networks.
- **Inner loop:** inside each outer fold, 6 more folds choose the configuration.
- **Final model:** trained on all 7 bearings, so it has no held-out data. Its performance estimate is the 35 held-out
  networks.
- **Unbiased estimates:** only the four bearings added in Run 3 (B08, B09, B11, B12). B02–B04 helped design the
  configurations.

## 4. Input

### 4.1 The 8 inputs (one row per measurement)

| # | Input | What it represents | Used? |
|---|---|---|---|
| x1 | ln RMS | overall vibration energy | yes |
| x2 | ln peak | the largest spike | yes |
| x3 | kurtosis | impulsiveness, the impacts typical of bearing damage | yes |
| x4 | ln band energy 1–5 kHz | mid-frequency vibration | yes |
| x5 | ln band energy 5–20 kHz | high-frequency vibration, an early sign of bearing defects | yes |
| x6 | crest factor | peak relative to RMS | yes |
| x7 | shaft speed | the operating point | yes |
| x8 | temperature residual | measured minus expected temperature | **no, always fed 0** |

### 4.2 From sensor to network input

1. **Sensor:** one accelerometer (the rear one), converted to g. x1–x3 and x6 are computed at 42.67 kHz; the band
   energies come from the full-rate spectrum.
2. **Commissioning:** each bearing calibrates itself on its own first 100 operating measurements. Each feature is
   corrected for speed (f = b0 + b1 · ln rpm) and turned into a z-score against that period. Nothing is fitted across
   bearings.
3. **Log compression:** x = sign(z) · ln(1 + min(|z|, 10,000)). This keeps large deviations ordered instead of cutting
   them off.
4. **INT8:** x_q = round(x / 0.0725), where 0.0725 = ln(10,001) / 127.

## 5. The Network and Its 850 Parameters

| Layer | Shape | Weights | Biases | Parameters | What they do |
|---|---|---|---|---|---|
| Hidden layer 1 | 8 → 32, ReLU | 256 | 32 | **288** | Each of the 32 units adds up the 8 inputs with its own weights (how much each feature counts, and in which direction) plus a bias (its switch-on level). Each unit detects one pattern, such as "energy and spikiness both up" |
| Hidden layer 2 | 32 → 16, ReLU | 512 | 16 | **528** | Combines the 32 patterns into 16 higher-level features |
| Deterioration head | 16 → 1 | 16 | 1 | **17** | Weighs the 16 features into one score (a logit). **Trained** |
| Health-index head | 16 → 1 | 16 | 1 | **17** | Would give the Motor Health Index. **Untrained and frozen** |
| **Total** | | **800** | **50** | **850** | |

**Parameters that are actually active in the final model** (seed 0):

- **Trained:** 833 of the 850. The health-index head's 17 stay at their initial values.
- **Temperature weights:** the 32 weights connecting x8 have decayed to about 0 (largest 7 × 10⁻¹⁴), because x8 is
  always 0.
- **Inactive units:** 3 of the 32 first-layer units and 1 of the 16 second-layer units are switched off.
- **Near-zero weights:** in all, 132 weights are effectively zero. They are set to exactly 0 in the INT8 export.

Weight decay prunes the network in this way: it keeps the parameters it needs and shrinks the rest.

## 6. How It Trains

| Setting | Value |
|---|---|
| Loss | binary cross-entropy on the deterioration score, counting **only labelled rows**. Unlabelled rows and the health-index head contribute nothing |
| Optimizer | Adam, learning rate 0.001, **weight decay 0.01** |
| Steps | 2,000 steps of 64 rows (128,000 rows drawn; each labelled row is seen about 170 times) |
| Class balance | each batch is half healthy, half end-stage, drawn with replacement (the data are 700 : 35) |
| Temperature | x8 = 0 on every row, in training and in use |
| Seeds | 5 (0–4); every result reproduces bit for bit |
| Time | about 2 minutes for all 1,225 Run 3 trainings, on 8 processes |
| Final training loss | 0.019–0.022 (the 5 final networks) |
| Health-index head | excluded from the optimizer and checked bit-identical after training |

**How configuration E was chosen.** Five configurations were compared under a rule fixed before training. The rule
ranks, in order:

1. fewest healthy rows alarmed;
2. most end stages caught;
3. fewest alarm flickers;
4. lowest loss.

Alarm timing is not used, because the onset of damage is unknown. The first two criteria tied for every
configuration, so the choice came down to stability. Configuration C (the same as E but with temperature) is
statistically tied with E.

## 7. Output

| Output | Definition | Status |
|---|---|---|
| Deterioration score | p = sigmoid(logit), from 0 to 1 | trained |
| Alarm | on after **3 measurements in a row with p > 0.5**, then **latched** until a maintenance reset | trained, threshold fixed at 0.5 |
| Motor Health Index | 100 % × sigmoid(health output) | **disabled: never report it** |

The score is a detector output with a threshold, not a calibrated probability of failure.

## 8. Results (held-out bearings)

### 8.1 Per bearing

These come from the 35 held-out networks: each bearing scored by the networks that never saw it, over 5 seeds. The
anomaly detector is the label-free reference. It flags any departure from the bearing's own commissioning period.

| Bearing | First alarm (measurement) | Minutes before the stop | Alarm flickers (unlatched) | Healthy rows alarmed | End stage caught | Anomaly detector, minutes before the stop |
|---|---|---|---|---|---|---|
| B02 | M0867–M0868 | 80.0–80.3 | 1 | 0 | yes | 81.0 |
| B03 | M0561 | 16.5 | 1 | 0 | yes | 20.4 |
| B04 | M0445 | 208.6 | 1 | 0 | yes | 209.6 |
| B08 (new) | M1216 | 214.1 | 1 | 0 | yes | 424.5 |
| B09 (new) | M0226–M0230 | 644.0–645.5 | 5–7 | 0 | yes | 651.7 |
| B11 (new) | M0712–M0713 | 337.9–338.1 | 1–21 | 0 | yes | 339.7 |
| B12 (new) | never | – | 0 | 0 | **no** | 40.8 |

"Minutes before the stop" is the time before the test was ended, not a verified warning time before failure.

### 8.2 Summary

| Measure | Current model | Anomaly detector |
|---|---|---|
| Bearings whose end stage is caught | **6 of 7** (95 % interval 0.42–1.00) | 7 of 7 |
| New, unbiased bearings only | 3 of 4 | 4 of 4 |
| Healthy-row false alarms (latched) | **0 of 3,500** | 0 |
| First alarm | the same time or later on every bearing (2–19 measurements later on five, about 3.5 h later on B08, never on B12) | earlier or equal on every bearing |
| Alarm flickers (unlatched, mean per run) | **2.8** | 1–14 per bearing |
| Highest score on a healthy row | 0.54 (one B11 row, never 3 in a row) | – |
| Extreme scores (below 0.001 or above 0.999) | 0.8 % | – |

### 8.3 Row-level metrics, with a warning

These are computed on the labelled held-out rows: 100 healthy and 5 end-stage rows per bearing, × 7 bearings × 5
seeds = 3,675.

| Accuracy | Precision | Recall | F1 | TN / FP / FN / TP |
|---|---|---|---|---|
| 0.9932 | 1.0000 | 0.8571 | 0.9231 | 3,500 / 0 / 25 / 150 |

> **Caution:** these numbers look better than the model is. The healthy rows are each bearing's own commissioning
> period, where the inputs are near 0, and the end-stage rows are extreme, so a rule that simply switches the alarm on
> right after commissioning scores 1.000. All 25 misses are B12. Judge the model by the per-bearing results in 8.1.

### 8.4 Why it misses B12 and never warns earlier

- **B12:**
  - Its end stage is weak on the rear sensor: the largest input is 2.5–3.2 standard deviations, against 18–51 on the
    other bearings.
  - Its stop was probably triggered by the front sensor, which the model doesn't use.
  - A vibration step inside its commissioning period weakens its inputs further.
- **Never earlier:** every end-stage label is an extreme, worn-out state, so the network learns to wait for extreme
  readings. The anomaly detector flags any departure from normal. Without labels for intermediate stages, a supervised
  network trained this way can't be expected to warn earlier.

## 9. Hardware

| Item | Result |
|---|---|
| Format | INT8 weights, INT32 biases, 22-bit accumulators, 14 passes of the 8 × 8 array, both heads in one 16 × 2 layer |
| INT8 vs full precision (35 held-out networks) | 13 of 45,015 decisions change (0.03 %); the first alarm is identical in all 35 |
| INT8 vs full precision (5 final networks, in-sample) | 39 of 45,015 decisions change (0.09 %) |
| RTL simulation | bit-exact (final seed 0, all 735 labelled rows, among 16 trained networks checked) |
| Speed | 382 cycles = **1.78 µs** per measurement at 214.286 MHz; 1,642 cycles for 64 measurements |
| Board | **not yet run on the ZedBoard** |
| Exported files | `model/export/MTL_run3_v2/seed0–4/` (weights, biases and scales as hex, C header `mtl_run3.h`, `quant.json`, test vectors) |

All five final networks (seeds 0–4) are exported. Seed 0 is the one checked on the full set of labelled rows in RTL. No
single network has been frozen yet.

## 10. Limitations

- **Small sample:** only 7 bearings, and the bearing is the unit of evidence. No detection rate can be claimed.
- **Provisional labels:** the end-stage labels are proxies, the onset of damage is unknown, and the labels were not
  given a two-person sign-off (team decision).
- **Not better than the detector:** the model does not outperform the anomaly detector.
- **One sensor:** only the rear accelerometer is used, while two stops were probably triggered by the front one.
- **No temperature:** temperature is off. The data could not show that it helps (one sensor failed, and the bearings
  contradict each other).
- **Fixed threshold:** the 0.5 threshold is fixed, not tuned.
- **Uncovered regime:** the constant-speed regime (B14–B17) has no training bearing, and B17 is in the test set.
- **Simulation only:** all hardware results are from simulation.
- **Health index:** untrained.

## 11. Next Steps

1. **Combine the two detectors:** use the anomaly detector's per-bearing threshold as an input or a gate, with the MLP
   as a confirmer.
2. **Commissioning check:** add a validity check for the vibration commissioning period, which would catch B12's step.
3. **Sensor choice:** decide between the front sensor, the rear sensor, or both.
4. **More bearings:** add B10, B14 and B15 (outer race and constant speed).
5. **Threshold:** choose it inside the training folds instead of fixing it at 0.5.
6. **Final test:** freeze one model, test it once on B06, B07, B13 and B17, and report the result.
7. **Board:** run it on the ZedBoard, with the ARM code for features, commissioning and the alarm.

## 12. Files

| What | Where |
|---|---|
| Model definition | `model/mtl_model.py` |
| Input pipeline | `model/paderborn.py` (features), `model/mtl_inputs.py` (commissioning, z-scores) |
| Labels | `model/labels.py`; table `model/results/supervised/run3/prep/label_table_run3.json` |
| Training | `model/train_deterioration_run3.py` → `model/results/supervised/run3/train/` (final networks in `models/FINAL/`) |
| Hardware export and checks | `model/run3_hardware.py` → `model/export/MTL_run3_v2/`, `model/results/supervised/run3/hardware/` |
| Full Run 3 report | `docs/Model/10_Training_run3.pdf` |
