# Single-accelerometer E3: comparison

University of Ottawa motor dataset, recording level (one decision per 10-s recording = mean of 10 one-second window
logits), positive class = faulty. Test split = speed codes 1 (15 Hz) and 6 (30->60 Hz): 28 faulty, 4 healthy
recordings. Generated numbers: `results/E3_single_accel/analysis.md` (new models), `results/E3/` (E3).

**E3 is a historical result** (trained 27 Oct on the Mac, committed files; its test split steered its design). **The
three single-accelerometer rows are new measurements** (trained 28 Oct on Windows, `python single_accel.py`). The
accelerometer was chosen on validation only; test rows are reported, not used to choose. Every test split here has
already been seen during E3's development, so none of these is an untouched hold-out.

**Deployed: accelerometer 1** (team decision of 28 Oct, by mounting, taken after these test results were seen, so its
28/28 is not an unbiased estimate). Selected by the validation rule: accelerometer 2. Accelerometer 1 in INT8: 28/28,
no decision changed; RTL 382 cycles per window (xsim).

## Test, FP32, seed 42 (the reported/exported seed)

| Model | Inputs | Params | Accuracy | Recall | Precision | F1 | Bal. acc. | Specificity | ROC-AUC | MCC | Faults found | Healthy correct |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| E3, accelerometers 1+2+3 (historical) | 22 | 1,281 | 0.969 | 0.964 | 1.000 | 0.982 | 0.982 | 1.000 | 1.000 | 0.878 | 27/28 | 4/4 |
| **Accelerometer 1 only (deployed)** | 8 | 833 | 1.000 | 1.000 | 1.000 | 1.000 | 1.000 | 1.000 | 1.000 | 1.000 | 28/28 | 4/4 |
| **Accelerometer 2 only (selected)** | 8 | 833 | 0.938 | 0.929 | 1.000 | 0.963 | 0.964 | 1.000 | 1.000 | 0.787 | 26/28 | 4/4 |
| Accelerometer 3 only | 8 | 833 | 0.969 | 0.964 | 1.000 | 0.982 | 0.982 | 1.000 | 1.000 | 0.878 | 27/28 | 4/4 |

## Test, FP32, mean ± std over seeds 42, 43, 44

| Model | Accuracy | Recall | Precision | F1 | Bal. acc. | ROC-AUC | Faults found (42 / 43 / 44) |
|---|---|---|---|---|---|---|---|
| E3 (historical) | 0.948 ± 0.029 | 0.940 ± 0.034 | 1.000 ± 0 | 0.969 ± 0.018 | 0.970 ± 0.017 | 1.000 ± 0 | 27 / 25 / 27 |
| Accelerometer 1 | 1.000 ± 0 | 1.000 ± 0 | 1.000 ± 0 | 1.000 ± 0 | 1.000 ± 0 | 1.000 ± 0 | 28 / 28 / 28 |
| **Accelerometer 2 (selected)** | 0.938 ± 0 | 0.929 ± 0 | 1.000 ± 0 | 0.963 ± 0 | 0.964 ± 0 | 1.000 ± 0 | 26 / 26 / 26 |
| Accelerometer 3 | 0.958 ± 0.015 | 0.952 ± 0.017 | 1.000 ± 0 | 0.976 ± 0.009 | 0.976 ± 0.008 | 0.999 ± 0.001* | 27 / 27 / 26 |

\* recording ROC-AUC is 1.000 in every seed; 0.999 is the window-level figure. Rounded to 3 decimals.

## Validation (the selection basis), mean over seeds

| Model | Recall | Bal. acc. | F1 | ROC-AUC | Window ROC-AUC | Best val loss (weighted BCE) | Rank |
|---|---|---|---|---|---|---|---|
| E3 (historical) | 1.000 | 1.000 | 1.000 | 1.000 | - | 0.0069 | - |
| Accelerometer 1 | 1.000 | 1.000 | 1.000 | 1.000 | 0.9990 | 0.0102 | 3 |
| **Accelerometer 2** | 1.000 | 1.000 | 1.000 | 1.000 | **1.0000** | **0.0022** | **1** |
| Accelerometer 3 | 1.000 | 1.000 | 1.000 | 1.000 | 0.9998 | 0.0037 | 2 |

Validation saturates for every model; the rule fell through to its 8th key (window-level ROC-AUC), where the gaps
are a handful of window pairs. Treat the choice as weakly supported (see `02a_Single_accel_model_report.md`, section 5).

## Other differences

| | E3 | Single accelerometer |
|---|---|---|
| Layer sizes | 22 -> 32 -> 16 -> 1 | 8 -> 32 -> 16 -> 1 |
| INT8 weights (bytes) | 1,232 | 784 |
| Chip cycles per window, M = 1 (xsim) | 566 | 382 (accelerometer 2 export) |
| Chip cycles per 10-window batch (xsim) | 818 | 562 |
| INT8 test faults found (seed 42) | 27/28 | 25/28 (accelerometer 2; FP32 26/28) |
| Health index, test ROC-AUC of D | 0.527 (H1, three accelerometers) | 1.000 (accelerometer 2) |
| Healthy 15-Hz recordings' health index | 0%, 0% | 100%, 100% (accelerometer 2) |
