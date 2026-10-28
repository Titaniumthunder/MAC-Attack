# H1: health index (output 2)

D_100 = 2.5076 (largest leave-one-speed-out D of the healthy train recordings), D_0 = 3.8042 (median D of the faulty train recordings). HI = 100% * clip((D_0 - D) / (D_0 - D_100), 0, 1).

Leave-one-speed-out D of the healthy train recordings: H_H_3_0 1.514, H_H_3_1 1.020, H_H_4_0 1.608, H_H_4_1 1.807, H_H_5_0 2.061, H_H_5_1 2.299, H_H_8_0 2.508, H_H_8_1 0.975

## Per split

| Split | Healthy HI (each) | Healthy at 100% | Faulty HI min / median / max | Faulty <= 50% | Faulty at 0% | ROC-AUC of D |
|---|---|---|---|---|---|---|
| train | 100, 100, 100, 100, 100, 100, 100, 100 | 8/8 | 0 / 0 / 97 | 45/56 | 28/56 | 1.000 |
| val | 100, 100, 100, 94 | 3/4 | 0 / 22 / 100 | 20/28 | 12/28 | 0.955 |
| test | 0, 100, 0, 100 | 2/4 | 0 / 35 / 100 | 15/28 | 7/28 | 0.527 |

## Per speed code (HI %; healthy: both loads; faulty: min / median / max of 14)

| Speed code | Split | Healthy | Faulty | Healthy D | Faulty D min |
|---|---|---|---|---|---|
| 1 (15->15 Hz) | test | 0, 0 | 7 / 76 / 100 | 8.17, 4.45 | 2.03 |
| 2 (30->30 Hz) | val | 100, 100 | 0 / 22 / 100 | 1.22, 0.85 | 2.07 |
| 3 (45->45 Hz) | train | 100, 100 | 0 / 20 / 97 | 1.10, 0.70 | 2.54 |
| 4 (60->60 Hz) | train | 100, 100 | 0 / 14 / 83 | 0.91, 1.03 | 2.73 |
| 5 (15->45 Hz) | train | 100, 100 | 0 / 9 / 95 | 0.81, 0.94 | 2.57 |
| 6 (30->60 Hz) | test | 100, 100 | 0 / 0 / 59 | 1.08, 1.08 | 3.04 |
| 7 (45->15 Hz) | val | 100, 94 | 0 / 22 / 95 | 1.98, 2.58 | 2.57 |
| 8 (60->30 Hz) | train | 100, 100 | 0 / 0 / 89 | 1.23, 0.90 | 2.64 |

## Per fault class (HI %, min / median / max over its 16 recordings; val and test only: 8)

| Class | All | Val + test |
|---|---|---|
| B_R | 0 / 15 / 79 | 0 / 19 / 79 |
| F_B | 0 / 0 / 100 | 0 / 28 / 100 |
| H_H | 0 / 100 / 100 | 0 / 100 / 100 |
| K_A | 0 / 23 / 100 | 0 / 45 / 100 |
| R_M | 0 / 0 / 96 | 0 / 0 / 96 |
| R_U | 0 / 2 / 100 | 0 / 22 / 100 |
| S_W | 0 / 61 / 100 | 0 / 58 / 100 |
| V_U | 0 / 6 / 100 | 0 / 28 / 100 |
