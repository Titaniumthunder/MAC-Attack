# E3_single_accel_a1: E3 with accelerometer 1 only

Inputs (8): a1_log_std, a1_log_rms, a1_log_absmax, a1_log_p2p, a1_crest, a1_skew, a1_kurt, log_f

Train 640, val 320, test 320 (windows); pos_weight = 0.142857. Positive class = faulty.

## Every seed (threshold from validation)

| Seed | Split | Accuracy | Precision | Recall | F1 | ROC-AUC | [[TN,FP],[FN,TP]] | t (cut) | Best / last epoch |
|---|---|---|---|---|---|---|---|---|---|
| 42 | train | 1.000 | 1.000 | 1.000 | 1.000 | 1.000 | [[8, 0], [0, 56]] | 0.3497 (-0.6204) | 99 / 100 |
| 42 | val | 1.000 | 1.000 | 1.000 | 1.000 | 1.000 | [[4, 0], [0, 28]] | 0.3497 (-0.6204) | 99 / 100 |
| 42 | test | 1.000 | 1.000 | 1.000 | 1.000 | 1.000 | [[4, 0], [0, 28]] | 0.3497 (-0.6204) | 99 / 100 |
| 43 | train | 1.000 | 1.000 | 1.000 | 1.000 | 1.000 | [[8, 0], [0, 56]] | 0.3338 (-0.6912) | 99 / 100 |
| 43 | val | 1.000 | 1.000 | 1.000 | 1.000 | 1.000 | [[4, 0], [0, 28]] | 0.3338 (-0.6912) | 99 / 100 |
| 43 | test | 1.000 | 1.000 | 1.000 | 1.000 | 1.000 | [[4, 0], [0, 28]] | 0.3338 (-0.6912) | 99 / 100 |
| 44 | train | 1.000 | 1.000 | 1.000 | 1.000 | 1.000 | [[8, 0], [0, 56]] | 0.3198 (-0.7546) | 93 / 100 |
| 44 | val | 1.000 | 1.000 | 1.000 | 1.000 | 1.000 | [[4, 0], [0, 28]] | 0.3198 (-0.7546) | 93 / 100 |
| 44 | test | 1.000 | 1.000 | 1.000 | 1.000 | 1.000 | [[4, 0], [0, 28]] | 0.3198 (-0.7546) | 93 / 100 |

## Seed 42 (the reported run) against James's report (test)

| | Faults found | False alarms | ROC-AUC |
|---|---|---|---|
| James | 18/28 | 0/4 | 0.875 |
| E3_single_accel_a1 | 28/28 | 0/4 | 1.000 |

## Test, mean and spread over the seeds

| | Accuracy | Precision | Recall | F1 | ROC-AUC |
|---|---|---|---|---|---|
| mean ± std | 1.000 ± 0.000 | 1.000 ± 0.000 | 1.000 ± 0.000 | 1.000 ± 0.000 | 1.000 ± 0.000 |

## Missed faults by speed code (test; missed / faulty recordings at that speed)

| Seed | 1 (15->15 Hz) | 6 (30->60 Hz) | False alarms by speed |
|---|---|---|---|
| 42 | 0/14 | 0/14 | none |
| 43 | 0/14 | 0/14 | none |
| 44 | 0/14 | 0/14 | none |

## Missed faults by fault class (test; missed / recordings of that class)

| Seed | B_R | F_B | K_A | R_M | R_U | S_W | V_U |
|---|---|---|---|---|---|---|---|
| 42 | 0/4 | 0/4 | 0/4 | 0/4 | 0/4 | 0/4 | 0/4 |
| 43 | 0/4 | 0/4 | 0/4 | 0/4 | 0/4 | 0/4 | 0/4 |
| 44 | 0/4 | 0/4 | 0/4 | 0/4 | 0/4 | 0/4 | 0/4 |

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

- seed 42: none
- seed 43: none
- seed 44: none
