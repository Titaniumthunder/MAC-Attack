# E0: James's baseline rebuilt

Inputs (16): a2_mean, a2_std, a2_rms, a2_absmax, a2_p2p, a2_crest, a2_skew, a2_kurt, a3_mean, a3_std, a3_rms, a3_absmax, a3_p2p, a3_crest, a3_skew, a3_kurt

Train 64, val 32, test 32 (recordings); pos_weight = 0.142857. Positive class = faulty.

## Every seed (threshold from validation)

| Seed | Split | Accuracy | Precision | Recall | F1 | ROC-AUC | [[TN,FP],[FN,TP]] | t (cut) | Best / last epoch |
|---|---|---|---|---|---|---|---|---|---|
| 42 | train | 0.969 | 0.966 | 1.000 | 0.982 | 1.000 | [[6, 2], [0, 56]] | 0.0852 (-2.3733) | 100 / 100 |
| 42 | val | 0.969 | 0.966 | 1.000 | 0.982 | 0.991 | [[3, 1], [0, 28]] | 0.0852 (-2.3733) | 100 / 100 |
| 42 | test | 0.688 | 1.000 | 0.643 | 0.783 | 0.875 | [[4, 0], [10, 18]] | 0.0852 (-2.3733) | 100 / 100 |
| 43 | train | 0.969 | 0.966 | 1.000 | 0.982 | 0.964 | [[6, 2], [0, 56]] | 0.3203 (-0.7523) | 32 / 47 |
| 43 | val | 1.000 | 1.000 | 1.000 | 1.000 | 1.000 | [[4, 0], [0, 28]] | 0.3203 (-0.7523) | 32 / 47 |
| 43 | test | 0.562 | 1.000 | 0.500 | 0.667 | 0.768 | [[4, 0], [14, 14]] | 0.3203 (-0.7523) | 32 / 47 |
| 44 | train | 0.969 | 0.966 | 1.000 | 0.982 | 1.000 | [[6, 2], [0, 56]] | 0.0990 (-2.2089) | 100 / 100 |
| 44 | val | 1.000 | 1.000 | 1.000 | 1.000 | 1.000 | [[4, 0], [0, 28]] | 0.0990 (-2.2089) | 100 / 100 |
| 44 | test | 0.625 | 1.000 | 0.571 | 0.727 | 0.893 | [[4, 0], [12, 16]] | 0.0990 (-2.2089) | 100 / 100 |

## Seed 42 (the reported run) against James's report (test)

| | Faults found | False alarms | ROC-AUC |
|---|---|---|---|
| James | 18/28 | 0/4 | 0.875 |
| E0 | 18/28 | 0/4 | 0.875 |

## Test, mean and spread over the seeds

| | Accuracy | Precision | Recall | F1 | ROC-AUC |
|---|---|---|---|---|---|
| mean ± std | 0.625 ± 0.051 | 1.000 ± 0.000 | 0.571 ± 0.058 | 0.726 ± 0.047 | 0.845 ± 0.055 |

## Missed faults by speed code (test; missed / faulty recordings at that speed)

| Seed | 1 (15->15 Hz) | 6 (30->60 Hz) | False alarms by speed |
|---|---|---|---|
| 42 | 10/14 | 0/14 | none |
| 43 | 14/14 | 0/14 | none |
| 44 | 12/14 | 0/14 | none |

## Missed faults by fault class (test; missed / recordings of that class)

| Seed | B_R | F_B | K_A | R_M | R_U | S_W | V_U |
|---|---|---|---|---|---|---|---|
| 42 | 1/4 | 2/4 | 2/4 | 2/4 | 1/4 | 1/4 | 1/4 |
| 43 | 2/4 | 2/4 | 2/4 | 2/4 | 2/4 | 2/4 | 2/4 |
| 44 | 2/4 | 2/4 | 2/4 | 2/4 | 1/4 | 1/4 | 2/4 |

## Missed faults by speed code (val; missed / faulty recordings at that speed)

| Seed | 2 (30->30 Hz) | 7 (45->15 Hz) | False alarms by speed |
|---|---|---|---|
| 42 | 0/14 | 0/14 | 2: 1 |
| 43 | 0/14 | 0/14 | none |
| 44 | 0/14 | 0/14 | none |

## Missed faults by fault class (val; missed / recordings of that class)

| Seed | B_R | F_B | K_A | R_M | R_U | S_W | V_U |
|---|---|---|---|---|---|---|---|
| 42 | 0/4 | 0/4 | 0/4 | 0/4 | 0/4 | 0/4 | 0/4 |
| 43 | 0/4 | 0/4 | 0/4 | 0/4 | 0/4 | 0/4 | 0/4 |
| 44 | 0/4 | 0/4 | 0/4 | 0/4 | 0/4 | 0/4 | 0/4 |

## Missed recordings (test)

- seed 42: F_B_1_0.csv, K_A_1_0.csv, R_M_1_0.csv, B_R_1_1.csv, F_B_1_1.csv, K_A_1_1.csv, R_M_1_1.csv, R_U_1_1.csv, S_W_1_1.csv, V_U_1_1.csv
- seed 43: B_R_1_0.csv, F_B_1_0.csv, K_A_1_0.csv, R_M_1_0.csv, R_U_1_0.csv, S_W_1_0.csv, V_U_1_0.csv, B_R_1_1.csv, F_B_1_1.csv, K_A_1_1.csv, R_M_1_1.csv, R_U_1_1.csv, S_W_1_1.csv, V_U_1_1.csv
- seed 44: B_R_1_0.csv, F_B_1_0.csv, K_A_1_0.csv, R_M_1_0.csv, V_U_1_0.csv, B_R_1_1.csv, F_B_1_1.csv, K_A_1_1.csv, R_M_1_1.csv, R_U_1_1.csv, S_W_1_1.csv, V_U_1_1.csv
