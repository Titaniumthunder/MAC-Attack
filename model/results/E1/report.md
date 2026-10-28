# E1: log amplitudes and log f

Inputs (15): a2_log_std, a2_log_rms, a2_log_absmax, a2_log_p2p, a2_crest, a2_skew, a2_kurt, a3_log_std, a3_log_rms, a3_log_absmax, a3_log_p2p, a3_crest, a3_skew, a3_kurt, log_f

Train 64, val 32, test 32 (recordings); pos_weight = 0.142857. Positive class = faulty.

## Every seed (threshold from validation)

| Seed | Split | Accuracy | Precision | Recall | F1 | ROC-AUC | [[TN,FP],[FN,TP]] | t (cut) | Best / last epoch |
|---|---|---|---|---|---|---|---|---|---|
| 42 | train | 1.000 | 1.000 | 1.000 | 1.000 | 1.000 | [[8, 0], [0, 56]] | 0.2183 (-1.2757) | 100 / 100 |
| 42 | val | 1.000 | 1.000 | 1.000 | 1.000 | 1.000 | [[4, 0], [0, 28]] | 0.2183 (-1.2757) | 100 / 100 |
| 42 | test | 0.594 | 1.000 | 0.536 | 0.698 | 0.929 | [[4, 0], [13, 15]] | 0.2183 (-1.2757) | 100 / 100 |
| 43 | train | 1.000 | 1.000 | 1.000 | 1.000 | 1.000 | [[8, 0], [0, 56]] | 0.2105 (-1.3218) | 100 / 100 |
| 43 | val | 1.000 | 1.000 | 1.000 | 1.000 | 1.000 | [[4, 0], [0, 28]] | 0.2105 (-1.3218) | 100 / 100 |
| 43 | test | 0.594 | 0.895 | 0.607 | 0.723 | 0.562 | [[2, 2], [11, 17]] | 0.2105 (-1.3218) | 100 / 100 |
| 44 | train | 1.000 | 1.000 | 1.000 | 1.000 | 1.000 | [[8, 0], [0, 56]] | 0.2292 (-1.2128) | 100 / 100 |
| 44 | val | 1.000 | 1.000 | 1.000 | 1.000 | 1.000 | [[4, 0], [0, 28]] | 0.2292 (-1.2128) | 100 / 100 |
| 44 | test | 0.594 | 1.000 | 0.536 | 0.698 | 0.973 | [[4, 0], [13, 15]] | 0.2292 (-1.2128) | 100 / 100 |

## Seed 42 (the reported run) against James's report (test)

| | Faults found | False alarms | ROC-AUC |
|---|---|---|---|
| James | 18/28 | 0/4 | 0.875 |
| E1 | 15/28 | 0/4 | 0.929 |

## Test, mean and spread over the seeds

| | Accuracy | Precision | Recall | F1 | ROC-AUC |
|---|---|---|---|---|---|
| mean ± std | 0.594 ± 0.000 | 0.965 ± 0.050 | 0.560 ± 0.034 | 0.706 ± 0.012 | 0.821 ± 0.184 |

## Missed faults by speed code (test; missed / faulty recordings at that speed)

| Seed | 1 (15->15 Hz) | 6 (30->60 Hz) | False alarms by speed |
|---|---|---|---|
| 42 | 13/14 | 0/14 | none |
| 43 | 11/14 | 0/14 | 1: 2 |
| 44 | 13/14 | 0/14 | none |

## Missed faults by fault class (test; missed / recordings of that class)

| Seed | B_R | F_B | K_A | R_M | R_U | S_W | V_U |
|---|---|---|---|---|---|---|---|
| 42 | 2/4 | 2/4 | 2/4 | 2/4 | 2/4 | 1/4 | 2/4 |
| 43 | 1/4 | 1/4 | 2/4 | 2/4 | 2/4 | 1/4 | 2/4 |
| 44 | 2/4 | 2/4 | 2/4 | 2/4 | 2/4 | 1/4 | 2/4 |

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

- seed 42: B_R_1_0.csv, F_B_1_0.csv, K_A_1_0.csv, R_M_1_0.csv, R_U_1_0.csv, S_W_1_0.csv, V_U_1_0.csv, B_R_1_1.csv, F_B_1_1.csv, K_A_1_1.csv, R_M_1_1.csv, R_U_1_1.csv, V_U_1_1.csv
- seed 43: B_R_1_0.csv, F_B_1_0.csv, K_A_1_0.csv, R_M_1_0.csv, R_U_1_0.csv, S_W_1_0.csv, V_U_1_0.csv, K_A_1_1.csv, R_M_1_1.csv, R_U_1_1.csv, V_U_1_1.csv; false alarms: H_H_1_0.csv, H_H_1_1.csv
- seed 44: B_R_1_0.csv, F_B_1_0.csv, K_A_1_0.csv, R_M_1_0.csv, R_U_1_0.csv, S_W_1_0.csv, V_U_1_0.csv, B_R_1_1.csv, F_B_1_1.csv, K_A_1_1.csv, R_M_1_1.csv, R_U_1_1.csv, V_U_1_1.csv
