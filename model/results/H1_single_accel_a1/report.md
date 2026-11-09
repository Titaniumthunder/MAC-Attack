# H1_single_accel_a1: health index (output 2)

D_100 = 1.9203 (largest leave-one-speed-out D of the healthy train recordings), D_0 = 4.4905 (median D of the faulty train recordings). HI = 100% * clip((D_0 - D) / (D_0 - D_100), 0, 1).

Leave-one-speed-out D of the healthy train recordings: H_H_3_0 1.703, H_H_3_1 1.045, H_H_4_0 0.564, H_H_4_1 1.316, H_H_5_0 1.724, H_H_5_1 1.920, H_H_8_0 1.684, H_H_8_1 0.978

## Per split

| Split | Healthy HI (each) | Healthy at 100% | Faulty HI min / median / max | Faulty <= 50% | Faulty at 0% | ROC-AUC of D |
|---|---|---|---|---|---|---|
| train | 100, 100, 100, 100, 100, 100, 100, 100 | 8/8 | 0 / 0 / 62 | 50/56 | 28/56 | 1.000 |
| val | 100, 100, 100, 100 | 4/4 | 0 / 37 / 100 | 20/28 | 2/28 | 1.000 |
| test | 94, 100, 100, 100 | 3/4 | 0 / 46 / 100 | 14/28 | 9/28 | 0.929 |

## Per speed code (HI %; healthy: both loads; faulty: min / median / max of 14)

| Speed code | Split | Healthy | Faulty | Healthy D | Faulty D min |
|---|---|---|---|---|---|
| 1 (15->15 Hz) | test | 94, 100 | 64 / 82 / 100 | 2.07, 1.85 | 1.50 |
| 2 (30->30 Hz) | val | 100, 100 | 0 / 33 / 100 | 1.33, 1.04 | 1.85 |
| 3 (45->45 Hz) | train | 100, 100 | 0 / 5 / 55 | 1.35, 0.82 | 3.08 |
| 4 (60->60 Hz) | train | 100, 100 | 0 / 0 / 62 | 0.58, 0.99 | 2.90 |
| 5 (15->45 Hz) | train | 100, 100 | 0 / 32 / 56 | 0.72, 0.80 | 3.05 |
| 6 (30->60 Hz) | test | 100, 100 | 0 / 0 / 29 | 1.47, 1.32 | 3.75 |
| 7 (45->15 Hz) | val | 100, 100 | 0 / 37 / 73 | 1.02, 0.93 | 2.61 |
| 8 (60->30 Hz) | train | 100, 100 | 0 / 0 / 60 | 1.32, 0.91 | 2.94 |

## Per fault class (HI %, min / median / max over its 16 recordings; val and test only: 8)

| Class | All | Val + test |
|---|---|---|
| B_R | 0 / 23 / 72 | 0 / 44 / 72 |
| F_B | 0 / 0 / 79 | 0 / 25 / 79 |
| H_H | 94 / 100 / 100 | 94 / 100 / 100 |
| K_A | 0 / 21 / 100 | 0 / 41 / 100 |
| R_M | 0 / 0 / 94 | 0 / 12 / 94 |
| R_U | 0 / 19 / 100 | 0 / 40 / 100 |
| S_W | 0 / 56 / 100 | 0 / 72 / 100 |
| V_U | 0 / 8 / 100 | 0 / 24 / 100 |
