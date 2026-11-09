# E3_single_accel_a2: E3 with accelerometer 2 only

Inputs (8): a2_log_std, a2_log_rms, a2_log_absmax, a2_log_p2p, a2_crest, a2_skew, a2_kurt, log_f

Train 640, val 320, test 320 (windows); pos_weight = 0.142857. Positive class = faulty.

## Every seed (threshold from validation)

| Seed | Split | Accuracy | Precision | Recall | F1 | ROC-AUC | [[TN,FP],[FN,TP]] | t (cut) | Best / last epoch |
|---|---|---|---|---|---|---|---|---|---|
| 42 | train | 1.000 | 1.000 | 1.000 | 1.000 | 1.000 | [[8, 0], [0, 56]] | 0.9746 (+3.6484) | 99 / 100 |
| 42 | val | 1.000 | 1.000 | 1.000 | 1.000 | 1.000 | [[4, 0], [0, 28]] | 0.9746 (+3.6484) | 99 / 100 |
| 42 | test | 0.938 | 1.000 | 0.929 | 0.963 | 1.000 | [[4, 0], [2, 26]] | 0.9746 (+3.6484) | 99 / 100 |
| 43 | train | 1.000 | 1.000 | 1.000 | 1.000 | 1.000 | [[8, 0], [0, 56]] | 0.9714 (+3.5254) | 98 / 100 |
| 43 | val | 1.000 | 1.000 | 1.000 | 1.000 | 1.000 | [[4, 0], [0, 28]] | 0.9714 (+3.5254) | 98 / 100 |
| 43 | test | 0.938 | 1.000 | 0.929 | 0.963 | 1.000 | [[4, 0], [2, 26]] | 0.9714 (+3.5254) | 98 / 100 |
| 44 | train | 1.000 | 1.000 | 1.000 | 1.000 | 1.000 | [[8, 0], [0, 56]] | 0.9663 (+3.3568) | 98 / 100 |
| 44 | val | 1.000 | 1.000 | 1.000 | 1.000 | 1.000 | [[4, 0], [0, 28]] | 0.9663 (+3.3568) | 98 / 100 |
| 44 | test | 0.938 | 1.000 | 0.929 | 0.963 | 1.000 | [[4, 0], [2, 26]] | 0.9663 (+3.3568) | 98 / 100 |

## Seed 42 (the reported run) against James's report (test)

| | Faults found | False alarms | ROC-AUC |
|---|---|---|---|
| James | 18/28 | 0/4 | 0.875 |
| E3_single_accel_a2 | 26/28 | 0/4 | 1.000 |

## Test, mean and spread over the seeds

| | Accuracy | Precision | Recall | F1 | ROC-AUC |
|---|---|---|---|---|---|
| mean ± std | 0.938 ± 0.000 | 1.000 ± 0.000 | 0.929 ± 0.000 | 0.963 ± 0.000 | 1.000 ± 0.000 |

## Missed faults by speed code (test; missed / faulty recordings at that speed)

| Seed | 1 (15->15 Hz) | 6 (30->60 Hz) | False alarms by speed |
|---|---|---|---|
| 42 | 2/14 | 0/14 | none |
| 43 | 2/14 | 0/14 | none |
| 44 | 2/14 | 0/14 | none |

## Missed faults by fault class (test; missed / recordings of that class)

| Seed | B_R | F_B | K_A | R_M | R_U | S_W | V_U |
|---|---|---|---|---|---|---|---|
| 42 | 0/4 | 1/4 | 0/4 | 0/4 | 0/4 | 1/4 | 0/4 |
| 43 | 0/4 | 1/4 | 0/4 | 0/4 | 0/4 | 1/4 | 0/4 |
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

- seed 42: F_B_1_0.csv, S_W_1_0.csv
- seed 43: F_B_1_0.csv, S_W_1_0.csv
- seed 44: F_B_1_0.csv, S_W_1_0.csv
