# E3 (seed 42) in INT8

Input scale s_x = 0.0475667 (p99.9; validation mean |logit error| max 0.4778, p99.9 0.4323)

Hidden scales s_h: 0.0716283, 0.131701; bias_last -120; logit scale 0.000626296; FP32 cut 1.1071 -> T_int 1768 (faulty if sum of the last 10 window logit_int >= 10 * T_int)

| Layer | K x N | W_q range | bias range | m0 range | shift range |
|---|---|---|---|---|---|
| 0 | 22 x 32 | -127 .. 127 | -2902 .. 3287 | 34176 .. 65009 | 24 .. 25 |
| 1 | 32 x 16 | -127 .. 127 | -1101 .. 1887 | 37489 .. 61169 | 24 .. 26 |
| 2 | 16 x 1 | -99 .. 127 | (ARM: -120) | - | - |

## FP32 against INT8 (recordings; INT8: sum of 10 window logits >= 10 T_int)

| Split | FP32 [[TN,FP],[FN,TP]] | INT8 | FP32 ROC-AUC | INT8 ROC-AUC | INT8 accuracy / precision / recall / F1 | Decisions changed |
|---|---|---|---|---|---|---|
| train | [[8, 0], [0, 56]] | [[8, 0], [0, 56]] | 1.000 | 1.000 | 1.000 / 1.000 / 1.000 / 1.000 | 0 |
| val | [[4, 0], [0, 28]] | [[4, 0], [0, 28]] | 1.000 | 1.000 | 1.000 / 1.000 / 1.000 / 1.000 | 0 |
| test | [[4, 0], [1, 27]] | [[4, 0], [1, 27]] | 1.000 | 1.000 | 0.969 / 1.000 / 0.964 / 0.982 | 0 |

Window logits, |INT8 x logit scale - FP32|: mean 0.4388, max 47.9955 (test: mean 1.0926, max 47.9955).

Missed test recordings (INT8): R_U_1_1.csv; false alarms: none

## On the chip (mlp_equation, P = 8, ZedBoard settings, 214.286 MHz)

| Rows M | Passes | Model cycles | Time | Array use |
|---|---|---|---|---|
| 1 | 22 | 566 | 2.64 us | 3.4% |
| 10 | 22 | 818 | 3.82 us | 23.5% |
