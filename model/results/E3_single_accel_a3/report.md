# E3_single_accel_a3: E3 with accelerometer 3 only

Inputs (8): a3_log_std, a3_log_rms, a3_log_absmax, a3_log_p2p, a3_crest, a3_skew, a3_kurt, log_f

Train 640, val 320, test 320 (windows); pos_weight = 0.142857. Positive class = faulty.

## Every seed (threshold from validation)

| Seed | Split | Accuracy | Precision | Recall | F1 | ROC-AUC | [[TN,FP],[FN,TP]] | t (cut) | Best / last epoch |
|---|---|---|---|---|---|---|---|---|---|
| 42 | train | 0.906 | 1.000 | 0.893 | 0.943 | 1.000 | [[8, 0], [6, 50]] | 0.9996 (+7.7079) | 96 / 100 |
| 42 | val | 1.000 | 1.000 | 1.000 | 1.000 | 1.000 | [[4, 0], [0, 28]] | 0.9996 (+7.7079) | 96 / 100 |
| 42 | test | 0.969 | 1.000 | 0.964 | 0.982 | 1.000 | [[4, 0], [1, 27]] | 0.9996 (+7.7079) | 96 / 100 |
| 43 | train | 0.891 | 1.000 | 0.875 | 0.933 | 1.000 | [[8, 0], [7, 49]] | 0.9936 (+5.0488) | 61 / 76 |
| 43 | val | 1.000 | 1.000 | 1.000 | 1.000 | 1.000 | [[4, 0], [0, 28]] | 0.9936 (+5.0488) | 61 / 76 |
| 43 | test | 0.969 | 1.000 | 0.964 | 0.982 | 1.000 | [[4, 0], [1, 27]] | 0.9936 (+5.0488) | 61 / 76 |
| 44 | train | 0.891 | 1.000 | 0.875 | 0.933 | 1.000 | [[8, 0], [7, 49]] | 0.9996 (+7.7682) | 100 / 100 |
| 44 | val | 1.000 | 1.000 | 1.000 | 1.000 | 1.000 | [[4, 0], [0, 28]] | 0.9996 (+7.7682) | 100 / 100 |
| 44 | test | 0.938 | 1.000 | 0.929 | 0.963 | 1.000 | [[4, 0], [2, 26]] | 0.9996 (+7.7682) | 100 / 100 |

## Seed 42 (the reported run) against James's report (test)

| | Faults found | False alarms | ROC-AUC |
|---|---|---|---|
| James | 18/28 | 0/4 | 0.875 |
| E3_single_accel_a3 | 27/28 | 0/4 | 1.000 |

## Test, mean and spread over the seeds

| | Accuracy | Precision | Recall | F1 | ROC-AUC |
|---|---|---|---|---|---|
| mean ± std | 0.958 ± 0.015 | 1.000 ± 0.000 | 0.952 ± 0.017 | 0.976 ± 0.009 | 1.000 ± 0.000 |

## Missed faults by speed code (test; missed / faulty recordings at that speed)

| Seed | 1 (15->15 Hz) | 6 (30->60 Hz) | False alarms by speed |
|---|---|---|---|
| 42 | 1/14 | 0/14 | none |
| 43 | 0/14 | 1/14 | none |
| 44 | 0/14 | 2/14 | none |

## Missed faults by fault class (test; missed / recordings of that class)

| Seed | B_R | F_B | K_A | R_M | R_U | S_W | V_U |
|---|---|---|---|---|---|---|---|
| 42 | 0/4 | 0/4 | 0/4 | 0/4 | 1/4 | 0/4 | 0/4 |
| 43 | 0/4 | 1/4 | 0/4 | 0/4 | 0/4 | 0/4 | 0/4 |
| 44 | 0/4 | 1/4 | 0/4 | 0/4 | 0/4 | 1/4 | 0/4 |

## Missed faults by speed code (val; missed / faulty recordings at that speed)

| Seed | 2 (30->30 Hz) | 7 (45->15 Hz) | False alarms by speed |
|---|---|---|---|
| 42 | 0/14 | 0/14 | none |
| 43 | 0/14 | 0/14 | none |
| 44 | 0/14 | 0/14 | none |

## Missed faults by fault class (val; missed / recordings of that class)

| Seed | B_R | F_B | K_A | R_M | R_U | S_W | V_U |
|---|---|---|---|---|---|---|---|
| 42 | 0/4 | 0/4 | 0/4 | 0/4 | 0/4 | 0/4 | 0/4 |
| 43 | 0/4 | 0/4 | 0/4 | 0/4 | 0/4 | 0/4 | 0/4 |
| 44 | 0/4 | 0/4 | 0/4 | 0/4 | 0/4 | 0/4 | 0/4 |

## Missed recordings (test)

- seed 42: R_U_1_1.csv
- seed 43: F_B_6_1.csv
- seed 44: S_W_6_0.csv, F_B_6_1.csv
