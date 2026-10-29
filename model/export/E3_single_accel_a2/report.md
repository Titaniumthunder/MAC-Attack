# E3_single_accel_a2 (seed 42) in INT8

Input scale s_x = 0.0356306 (p99.9; validation mean |logit error| max 0.4340, p99.9 0.2359)

Hidden scales s_h: 0.111347, 0.165829; bias_last -162; logit scale 0.000690221; FP32 cut 3.6484 -> T_int 5286 (faulty if sum of the last 10 window logit_int >= 10 * T_int)

| Layer | K x N | W_q range | bias range | m0 range | shift range |
|---|---|---|---|---|---|
| 0 | 8 x 32 | -127 .. 127 | -3352 .. 3753 | 33036 .. 65197 | 25 .. 26 |
| 1 | 32 x 16 | -127 .. 127 | -271 .. 865 | 34344 .. 63427 | 24 .. 25 |
| 2 | 16 x 1 | -106 .. 127 | (ARM: -162) | - | - |

## FP32 against INT8 (recordings; INT8: sum of 10 window logits >= 10 T_int)

| Split | FP32 [[TN,FP],[FN,TP]] | INT8 | FP32 ROC-AUC | INT8 ROC-AUC | INT8 accuracy / precision / recall / F1 | Decisions changed |
|---|---|---|---|---|---|---|
| train | [[8, 0], [0, 56]] | [[8, 0], [0, 56]] | 1.000 | 1.000 | 1.000 / 1.000 / 1.000 / 1.000 | 0 |
| val | [[4, 0], [0, 28]] | [[4, 0], [0, 28]] | 1.000 | 1.000 | 1.000 / 1.000 / 1.000 / 1.000 | 0 |
| test | [[4, 0], [2, 26]] | [[4, 0], [3, 25]] | 1.000 | 1.000 | 0.906 / 1.000 / 0.893 / 0.943 | 1 (R_M_1_0.csv) |

Window logits, |INT8 x logit scale - FP32|: mean 0.1848, max 28.1312 (test: mean 0.1608, max 1.1649).

Missed test recordings (INT8): F_B_1_0.csv, R_M_1_0.csv, S_W_1_0.csv; false alarms: none

## On the chip (mlp_equation, P = 8, ZedBoard settings, 214.286 MHz)

| Rows M | Passes | Model cycles | Time | Array use |
|---|---|---|---|---|
| 1 | 14 | 382 | 1.78 us | 3.2% |
| 10 | 14 | 562 | 2.62 us | 21.8% |
