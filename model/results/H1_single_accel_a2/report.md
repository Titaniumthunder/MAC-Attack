# H1_single_accel_a2: health index (output 2)

D_100 = 3.2082 (largest leave-one-speed-out D of the healthy train recordings), D_0 = 4.1138 (median D of the faulty train recordings). HI = 100% * clip((D_0 - D) / (D_0 - D_100), 0, 1).

Leave-one-speed-out D of the healthy train recordings: H_H_3_0 1.930, H_H_3_1 1.302, H_H_4_0 2.291, H_H_4_1 1.804, H_H_5_0 1.492, H_H_5_1 1.976, H_H_8_0 3.208, H_H_8_1 0.806

## Per split

| Split | Healthy HI (each) | Healthy at 100% | Faulty HI min / median / max | Faulty <= 50% | Faulty at 0% | ROC-AUC of D |
|---|---|---|---|---|---|---|
| train | 100, 100, 100, 100, 100, 100, 100, 100 | 8/8 | 0 / 0 / 100 | 36/56 | 28/56 | 1.000 |
| val | 100, 100, 100, 100 | 4/4 | 0 / 45 / 100 | 15/28 | 12/28 | 1.000 |
| test | 100, 100, 100, 100 | 4/4 | 0 / 59 / 100 | 13/28 | 11/28 | 1.000 |

## Per speed code (HI %; healthy: both loads; faulty: min / median / max of 14)

| Speed code | Split | Healthy | Faulty | Healthy D | Faulty D min |
|---|---|---|---|---|---|
| 1 (15->15 Hz) | test | 100, 100 | 0 / 100 / 100 | 1.12, 1.08 | 1.25 |
| 2 (30->30 Hz) | val | 100, 100 | 0 / 46 / 100 | 1.48, 0.59 | 2.22 |
| 3 (45->45 Hz) | train | 100, 100 | 0 / 0 / 100 | 1.25, 0.72 | 2.95 |
| 4 (60->60 Hz) | train | 100, 100 | 0 / 83 / 100 | 1.03, 0.76 | 2.50 |
| 5 (15->45 Hz) | train | 100, 100 | 0 / 19 / 100 | 0.63, 0.85 | 2.85 |
| 6 (30->60 Hz) | test | 100, 100 | 0 / 0 / 86 | 0.73, 0.96 | 3.34 |
| 7 (45->15 Hz) | val | 100, 100 | 0 / 45 / 100 | 1.31, 1.04 | 2.82 |
| 8 (60->30 Hz) | train | 100, 100 | 0 / 0 / 100 | 1.13, 0.72 | 2.70 |

## Per fault class (HI %, min / median / max over its 16 recordings; val and test only: 8)

| Class | All | Val + test |
|---|---|---|
| B_R | 0 / 0 / 100 | 0 / 11 / 100 |
| F_B | 0 / 54 / 100 | 0 / 62 / 100 |
| H_H | 100 / 100 / 100 | 100 / 100 / 100 |
| K_A | 0 / 70 / 100 | 0 / 85 / 100 |
| R_M | 0 / 0 / 100 | 0 / 0 / 100 |
| R_U | 0 / 0 / 100 | 0 / 23 / 100 |
| S_W | 0 / 95 / 100 | 0 / 95 / 100 |
| V_U | 0 / 16 / 100 | 0 / 65 / 100 |
