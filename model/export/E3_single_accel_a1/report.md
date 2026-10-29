# E3_single_accel_a1 (seed 42) in INT8

Input scale s_x = 0.038896 (p99.9; validation mean |logit error| max 0.3732, p99.9 0.3670)

Hidden scales s_h: 0.118791, 0.104619; bias_last -185; logit scale 0.000474013; FP32 cut -0.6204 -> T_int -1308 (faulty if sum of the last 10 window logit_int >= 10 * T_int)

| Layer | K x N | W_q range | bias range | m0 range | shift range |
|---|---|---|---|---|---|
| 0 | 8 x 32 | -127 .. 127 | -3524 .. 5553 | 32832 .. 63319 | 25 .. 26 |
| 1 | 32 x 16 | -127 .. 127 | -1010 .. 780 | 34868 .. 61944 | 23 .. 25 |
| 2 | 16 x 1 | -79 .. 127 | (ARM: -185) | - | - |

## FP32 against INT8 (recordings; INT8: sum of 10 window logits >= 10 T_int)

| Split | FP32 [[TN,FP],[FN,TP]] | INT8 | FP32 ROC-AUC | INT8 ROC-AUC | INT8 accuracy / precision / recall / F1 | Decisions changed |
|---|---|---|---|---|---|---|
| train | [[8, 0], [0, 56]] | [[8, 0], [0, 56]] | 1.000 | 1.000 | 1.000 / 1.000 / 1.000 / 1.000 | 0 |
| val | [[4, 0], [0, 28]] | [[4, 0], [0, 28]] | 1.000 | 1.000 | 1.000 / 1.000 / 1.000 / 1.000 | 0 |
| test | [[4, 0], [0, 28]] | [[4, 0], [0, 28]] | 1.000 | 1.000 | 1.000 / 1.000 / 1.000 / 1.000 | 0 |

Window logits, |INT8 x logit scale - FP32|: mean 0.1936, max 50.2867 (test: mean 0.1261, max 0.5464).

Missed test recordings (INT8): none; false alarms: none

## On the chip (mlp_equation, P = 8, ZedBoard settings, 214.286 MHz)

| Rows M | Passes | Model cycles | Time | Array use |
|---|---|---|---|---|
| 1 | 14 | 382 | 1.78 us | 3.2% |
| 10 | 14 | 562 | 2.62 us | 21.8% |
