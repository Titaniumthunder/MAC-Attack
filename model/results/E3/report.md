# E3: E2 plus accelerometer 1

Inputs (22): a1_log_std, a1_log_rms, a1_log_absmax, a1_log_p2p, a1_crest, a1_skew, a1_kurt, a2_log_std, a2_log_rms, a2_log_absmax, a2_log_p2p, a2_crest, a2_skew, a2_kurt, a3_log_std, a3_log_rms, a3_log_absmax, a3_log_p2p, a3_crest, a3_skew, a3_kurt, log_f

Train 640, val 320, test 320 (windows); pos_weight = 0.142857. Positive class = faulty.

## Every seed (threshold from validation)

| Seed | Split | Accuracy | Precision | Recall | F1 | ROC-AUC | [[TN,FP],[FN,TP]] | t (cut) | Best / last epoch |
|---|---|---|---|---|---|---|---|---|---|
| 42 | train | 1.000 | 1.000 | 1.000 | 1.000 | 1.000 | [[8, 0], [0, 56]] | 0.7516 (+1.1071) | 93 / 100 |
| 42 | val | 1.000 | 1.000 | 1.000 | 1.000 | 1.000 | [[4, 0], [0, 28]] | 0.7516 (+1.1071) | 93 / 100 |
| 42 | test | 0.969 | 1.000 | 0.964 | 0.982 | 1.000 | [[4, 0], [1, 27]] | 0.7516 (+1.1071) | 93 / 100 |
| 43 | train | 1.000 | 1.000 | 1.000 | 1.000 | 1.000 | [[8, 0], [0, 56]] | 0.7086 (+0.8886) | 97 / 100 |
| 43 | val | 1.000 | 1.000 | 1.000 | 1.000 | 1.000 | [[4, 0], [0, 28]] | 0.7086 (+0.8886) | 97 / 100 |
| 43 | test | 0.906 | 1.000 | 0.893 | 0.943 | 1.000 | [[4, 0], [3, 25]] | 0.7086 (+0.8886) | 97 / 100 |
| 44 | train | 1.000 | 1.000 | 1.000 | 1.000 | 1.000 | [[8, 0], [0, 56]] | 0.7303 (+0.9962) | 98 / 100 |
| 44 | val | 1.000 | 1.000 | 1.000 | 1.000 | 1.000 | [[4, 0], [0, 28]] | 0.7303 (+0.9962) | 98 / 100 |
| 44 | test | 0.969 | 1.000 | 0.964 | 0.982 | 1.000 | [[4, 0], [1, 27]] | 0.7303 (+0.9962) | 98 / 100 |

## Seed 42 (the reported run) against James's report (test)

| | Faults found | False alarms | ROC-AUC |
|---|---|---|---|
| James | 18/28 | 0/4 | 0.875 |
| E3 | 27/28 | 0/4 | 1.000 |

## Test, mean and spread over the seeds

| | Accuracy | Precision | Recall | F1 | ROC-AUC |
|---|---|---|---|---|---|
| mean ± std | 0.948 ± 0.029 | 1.000 ± 0.000 | 0.940 ± 0.034 | 0.969 ± 0.018 | 1.000 ± 0.000 |

## Missed faults by speed code (test; missed / faulty recordings at that speed)

| Seed | 1 (15->15 Hz) | 6 (30->60 Hz) | False alarms by speed |
|---|---|---|---|
| 42 | 1/14 | 0/14 | none |
| 43 | 3/14 | 0/14 | none |
| 44 | 1/14 | 0/14 | none |

## Missed faults by fault class (test; missed / recordings of that class)

| Seed | B_R | F_B | K_A | R_M | R_U | S_W | V_U |
|---|---|---|---|---|---|---|---|
| 42 | 0/4 | 0/4 | 0/4 | 0/4 | 1/4 | 0/4 | 0/4 |
| 43 | 0/4 | 0/4 | 1/4 | 1/4 | 1/4 | 0/4 | 0/4 |
| 44 | 0/4 | 0/4 | 0/4 | 0/4 | 1/4 | 0/4 | 0/4 |

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
- seed 43: K_A_1_0.csv, R_M_1_1.csv, R_U_1_1.csv
- seed 44: R_U_1_1.csv
