<!-- T_DATASET -->
| Bearing | Sampling | Files | Warm-up rows | Operating rows | Segments | Recorded span | Healthy (0) | End-stage (1) | Unlabelled | Temperature input | Rows with an input clipped at ±16 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| B02 | 128 kHz | 1116 | 51 | 1065 | 2 | 5.6 h | M0052–M0151 | M1112–M1116 | 960 | valid | 252 |
| B03 | 128 kHz | 614 | 0 | 614 | 1 | 3.2 h | M0001–M0100 | M0610–M0614 | 509 | valid | 62 |
| B04 | 128 kHz | 1114 | 50 | 1064 | 1 | 5.7 h | M0051–M0150 | M1110–M1114 | 959 | valid | 672 |
| B08 (new) | 128 kHz | 1827 | 50 | 1777 | 2 | 10.6 h | M0051–M0150 | M1823–M1827 | 1672 | masked (x8 = 0) | 607 |
| B09 (new) | 128 kHz | 1813 | 50 | 1763 | 1 | 12.1 h | M0051–M0150 | M1809–M1813 | 1658 | valid | 517 |
| B11 (new) | 64 kHz | 1953 | 0 | 1953 | 1 | 8.8 h | M0001–M0100 | M1949–M1953 | 1848 | valid (V1–V3), but T1 sensor fault from M0979 | 1247 |
| B12 (new) | 64 kHz | 767 | 0 | 767 | 1 | 2.5 h | M0001–M0100 | M0763–M0767 | 662 | valid | 438 |

<!-- T_BEARING_B02 -->
| Detector | First alarm (id) | Clock time | Min. before last record | Changes (latched) | Changes (unlatched) | Healthy rows above / alarmed | End-stage recall | Unlabelled rows alarmed |
|---|---|---|---|---|---|---|---|---|
| MLP E (selected), latched | 867–868 | 13:16:16–13:16:33 | 80.0–80.3 | 1 | 1 | 0 / 0 | 100 % | 25.5 % |
| MLP nested choice (E), latched | 867–868 | 13:16:16–13:16:33 | 80.0–80.3 | 1 | 1 | 0 / 0 | 100 % | 25.5 % |
| MLP B (primary, weight decay), latched | 865–867 | 13:15:35–13:16:16 | 80.3–81.0 | 1 | 1 | 0 / 0 | 100 % | 25.6 % |
| MLP A (Run 1–2 settings), latched | 611–906 | 11:58:28–13:28:01 | 68.6–158.1 | 1 | 19–21 | 0 / 0 | 100 % | 29.1 % |
| Anomaly detector (A, F42, speed) | 865 | 13:15:35 | 81.0 | 1 | 1 | 1 / 0 | 100 % | 25.7 % |
| Anomaly detector (A, F128, speed) | 864 | 13:15:16 | 81.3 | 1 | 1 | 1 / 0 | 100 % | 25.8 % |
| B02's 6.5 g limit on the rear sensor, latched | 1109 | 14:34:28 | 2.1 | 1 | 3 | 0 / 0 | 100 % | 0.3 % |

<!-- T_BEARING_B03 -->
| Detector | First alarm (id) | Clock time | Min. before last record | Changes (latched) | Changes (unlatched) | Healthy rows above / alarmed | End-stage recall | Unlabelled rows alarmed |
|---|---|---|---|---|---|---|---|---|
| MLP E (selected), latched | 561 | 18:07:08 | 16.5 | 1 | 1 | 0 / 0 | 100 % | 9.6 % |
| MLP nested choice (C), latched | 561 | 18:07:08 | 16.5 | 1 | 1 | 0 / 0 | 100 % | 9.6 % |
| MLP B (primary, weight decay), latched | 558–561 | 18:06:11–18:07:08 | 16.5–17.5 | 1 | 1 | 0 / 0 | 100 % | 10.0 % |
| MLP A (Run 1–2 settings), latched | 580–590 | 18:13:09–18:16:15 | 7.4–10.5 | 1 | 3–5 | 0 / 0 | 100 % | 4.3 % |
| Anomaly detector (A, F42, speed) | 549 | 18:03:16 | 20.4 | 1 | 1 | 1 / 0 | 100 % | 12.0 % |
| Anomaly detector (A, F128, speed) | 549 | 18:03:16 | 20.4 | 1 | 1 | 1 / 0 | 100 % | 12.0 % |
| B02's 6.5 g limit on the rear sensor, latched | never | – | – | 0 | 0 | 0 / 0 | 0 % | 0.0 % |

<!-- T_BEARING_B04 -->
| Detector | First alarm (id) | Clock time | Min. before last record | Changes (latched) | Changes (unlatched) | Healthy rows above / alarmed | End-stage recall | Unlabelled rows alarmed |
|---|---|---|---|---|---|---|---|---|
| MLP E (selected), latched | 445 | 14:58:24 | 208.6 | 1 | 1 | 0 / 0 | 100 % | 69.3 % |
| MLP nested choice (C), latched | 444–445 | 14:58:06–14:58:24 | 208.6–208.9 | 1 | 1 | 0 / 0 | 100 % | 69.4 % |
| MLP B (primary, weight decay), latched | 444 | 14:58:06 | 208.9 | 1 | 7–35 | 0 / 0 | 100 % | 69.4 % |
| MLP A (Run 1–2 settings), latched | 489 | 15:12:25 | 194.6 | 1 | 65–75 | 0 / 0 | 100 % | 64.8 % |
| Anomaly detector (A, F42, speed) | 442 | 14:57:25 | 209.6 | 1 | 1 | 1 / 0 | 100 % | 69.7 % |
| Anomaly detector (A, F128, speed) | 442 | 14:57:25 | 209.6 | 1 | 1 | 1 / 0 | 100 % | 69.7 % |
| B02's 6.5 g limit on the rear sensor, latched | 1113 | 18:26:40 | 0.3 | 1 | 1 | 0 / 0 | 40 % | 0.0 % |

<!-- T_BEARING_B08 -->
| Detector | First alarm (id) | Clock time | Min. before last record | Changes (latched) | Changes (unlatched) | Healthy rows above / alarmed | End-stage recall | Unlabelled rows alarmed |
|---|---|---|---|---|---|---|---|---|
| MLP E (selected), latched | 1216 | 21:46:50 | 214.1 | 1 | 1 | 0 / 0 | 100 % | 36.3 % |
| MLP nested choice (E), latched | 1216 | 21:46:50 | 214.1 | 1 | 1 | 0 / 0 | 100 % | 36.3 % |
| MLP B (primary, weight decay), latched | 1215–1216 | 21:46:16–21:46:50 | 214.1–214.7 | 1 | 1–3 | 0 / 0 | 100 % | 36.3 % |
| MLP A (Run 1–2 settings), latched | 1215–1219 | 21:46:16–21:47:36 | 213.4–214.7 | 1 | 27–47 | 0 / 0 | 100 % | 36.2 % |
| Anomaly detector (A, F42, speed) | 614 | 18:16:28 | 424.5 | 1 | 7 | 1 / 0 | 100 % | 72.3 % |
| Anomaly detector (A, F128, speed) | 614 | 18:16:28 | 424.5 | 1 | 7 | 1 / 0 | 100 % | 72.3 % |
| B02's 6.5 g limit on the rear sensor, latched | 1674 | 00:26:12 | 54.8 | 1 | 2 | 0 / 0 | 100 % | 8.9 % |

<!-- T_BEARING_B09 -->
| Detector | First alarm (id) | Clock time | Min. before last record | Changes (latched) | Changes (unlatched) | Healthy rows above / alarmed | End-stage recall | Unlabelled rows alarmed |
|---|---|---|---|---|---|---|---|---|
| MLP E (selected), latched | 226–230 | 17:14:14–17:15:46 | 644.0–645.5 | 1 | 5–7 | 0 / 0 | 100 % | 95.4 % |
| MLP nested choice (E), latched | 226–230 | 17:14:14–17:15:46 | 644.0–645.5 | 1 | 5–7 | 0 / 0 | 100 % | 95.4 % |
| MLP B (primary, weight decay), latched | 202 | 17:04:43 | 655.0 | 1 | 5–11 | 0 / 0 | 100 % | 96.9 % |
| MLP A (Run 1–2 settings), latched | 207–212 | 17:06:51–17:08:28 | 651.3–652.9 | 1 | 7–13 | 0 / 0 | 100 % | 96.6 % |
| Anomaly detector (A, F42, speed) | 211 | 17:08:04 | 651.7 | 1 | 9 | 1 / 0 | 100 % | 96.4 % |
| Anomaly detector (A, F128, speed) | 207 | 17:06:51 | 652.9 | 1 | 3 | 1 / 0 | 100 % | 96.6 % |
| B02's 6.5 g limit on the rear sensor, latched | never | – | – | 0 | 0 | 0 / 0 | 0 % | 0.0 % |

<!-- T_BEARING_B11 -->
| Detector | First alarm (id) | Clock time | Min. before last record | Changes (latched) | Changes (unlatched) | Healthy rows above / alarmed | End-stage recall | Unlabelled rows alarmed |
|---|---|---|---|---|---|---|---|---|
| MLP E (selected), latched | 712–713 | 12:38:54–12:39:08 | 337.9–338.1 | 1 | 1–21 | 3 / 0 | 100 % | 66.9 % |
| MLP nested choice (C), latched | 707–711 | 12:37:35–12:38:39 | 338.4–339.4 | 1 | 3–11 | 0 / 0 | 100 % | 67.1 % |
| MLP B (primary, weight decay), latched | 590–699 | 12:06:36–12:35:24 | 341.6–370.4 | 1 | 69–103 | 0 / 0 | 100 % | 72.4 % |
| MLP A (Run 1–2 settings), latched | 540–1877 | 11:53:12–17:56:17 | 20.7–383.8 | 1 | 12–108 | 0 / 0 | 100 % | 58.0 % |
| Anomaly detector (A, F42, speed) | 706 | 12:37:18 | 339.7 | 1 | 1 | 1 / 0 | 100 % | 67.3 % |
| Anomaly detector (A, F128, speed) | not available (no 20–64 kHz band at 64 kHz) | – | – | – | – | – | – | – |
| B02's 6.5 g limit on the rear sensor, latched | never | – | – | 0 | 0 | 0 / 0 | 0 % | 0.0 % |

<!-- T_BEARING_B12 -->
| Detector | First alarm (id) | Clock time | Min. before last record | Changes (latched) | Changes (unlatched) | Healthy rows above / alarmed | End-stage recall | Unlabelled rows alarmed |
|---|---|---|---|---|---|---|---|---|
| MLP E (selected), latched | never | – | never | 0 | 0 | 0 / 0 | 0 % | 0.0 % |
| MLP nested choice (C), latched | never | – | never | 0 | 0 | 0 / 0 | 0 % | 0.0 % |
| MLP B (primary, weight decay), latched | never | – | never | 0 | 0 | 0 / 0 | 0 % | 0.0 % |
| MLP A (Run 1–2 settings), latched | never | – | never | 0 | 0 | 0 / 0 | 0 % | 0.0 % |
| Anomaly detector (A, F42, speed) | 563 | 10:41:34 | 40.8 | 1 | 14 | 1 / 0 | 100 % | 30.2 % |
| Anomaly detector (A, F128, speed) | not available (no 20–64 kHz band at 64 kHz) | – | – | – | – | – | – | – |
| B02's 6.5 g limit on the rear sensor, latched | never | – | – | 0 | 0 | 0 / 0 | 0 % | 0.0 % |

<!-- T_SCORES -->
| Model | Decision | Accuracy | Precision | Recall | F1 | TN / FP / FN / TP |
|---|---|---|---|---|---|---|
| A: Run 1-2 settings | latched alarm | 0.9932 | 1.0000 | 0.8571 | 0.9231 | 3500 / 0 / 25 / 150 |
| A: Run 1-2 settings | raw score > 0.5 | 0.9875 | 1.0000 | 0.7371 | 0.8487 | 3500 / 0 / 46 / 129 |
| B: weight decay 0.01 | latched alarm | 0.9932 | 1.0000 | 0.8571 | 0.9231 | 3500 / 0 / 25 / 150 |
| B: weight decay 0.01 | raw score > 0.5 | 0.9932 | 1.0000 | 0.8571 | 0.9231 | 3500 / 0 / 25 / 150 |
| C: B + log inputs | latched alarm | 0.9932 | 1.0000 | 0.8571 | 0.9231 | 3500 / 0 / 25 / 150 |
| C: B + log inputs | raw score > 0.5 | 0.9943 | 1.0000 | 0.8800 | 0.9362 | 3500 / 0 / 21 / 154 |
| D: B, no temperature | latched alarm | 0.9932 | 1.0000 | 0.8571 | 0.9231 | 3500 / 0 / 25 / 150 |
| D: B, no temperature | raw score > 0.5 | 0.9932 | 1.0000 | 0.8571 | 0.9231 | 3500 / 0 / 25 / 150 |
| E: C + D | latched alarm | 0.9932 | 1.0000 | 0.8571 | 0.9231 | 3500 / 0 / 25 / 150 |
| E: C + D | raw score > 0.5 | 0.9924 | 0.9804 | 0.8571 | 0.9146 | 3497 / 3 / 25 / 150 |
| Nested selection (unbiased) | latched alarm | 0.9932 | 1.0000 | 0.8571 | 0.9231 | 3500 / 0 / 25 / 150 |
| Anomaly detector (A, F42, speed) (7 bearings, 1 run) | latched alarm | 1.0000 | 1.0000 | 1.0000 | 1.0000 | 700 / 0 / 0 / 35 |
| B02's 6.5 g limit on the rear sensor | latched alarm | 0.9687 | 1.0000 | 0.3429 | 0.5106 | 700 / 0 / 23 / 12 |

<!-- T_CANDIDATES -->
| Candidate | Healthy rows alarmed (35 runs) | End-stage recall | Unlatched changes (mean) | Labelled log-loss | Highest score on a healthy row | Scores < 0.001 or > 0.999 | Unlabelled scores in 0.05–0.95 | Final training loss | Chosen by nested selection (of 7 folds) |
|---|---|---|---|---|---|---|---|---|---|
| A: Run 1-2 settings | 0 | 85.7 % | 30.3 | 0.1610 | 0.225 | 88.9 % | 3.6 % | 0.0005 | 0 |
| B: weight decay 0.01 | 0 | 85.7 % | 15.5 | 0.0302 | 0.358 | 37.5 % | 18.7 % | 0.0154 | 0 |
| C: B + log inputs | 0 | 85.7 % | 2.9 | 0.0224 | 0.476 | 3.4 % | 17.7 % | 0.0191 | 4 |
| D: B, no temperature | 0 | 85.7 % | 20.7 | 0.0327 | 0.408 | 37.9 % | 9.0 % | 0.0166 | 0 |
| E: C + D | 0 | 85.7 % | 2.8 | 0.0245 | 0.542 | 0.8 % | 19.8 % | 0.0210 | 3 |

<!-- T_NESTED -->
| Outer (held-out) bearing | Chosen on the 6 inner folds | Inner healthy rows alarmed | Inner end-stage recall | Inner unlatched changes | Inner log-loss | Inner unlatched changes, every candidate |
|---|---|---|---|---|---|---|
| B02 | E_wd_slog_noT | 0 | 0.833 | 2.43 | 0.0255 | A 31.7, B 20.4, C 3.2, D 28.2, E 2.4 |
| B03 | C_wd_slog | 0 | 0.833 | 2.77 | 0.0228 | A 32.4, B 28.8, C 2.8, D 30.9, E 6.0 |
| B04 | C_wd_slog | 0 | 0.867 | 3.30 | 0.0227 | A 22.5, B 17.9, C 3.3, D 22.0, E 3.7 |
| B08 | E_wd_slog_noT | 0 | 0.833 | 1.77 | 0.0263 | A 27.9, B 13.1, C 4.2, D 22.2, E 1.8 |
| B09 | E_wd_slog_noT | 0 | 0.833 | 1.17 | 0.0275 | A 32.5, B 15.4, C 2.4, D 25.4, E 1.2 |
| B11 | C_wd_slog | 0 | 1.000 | 6.00 | 0.0196 | A 21.2, B 9.2, C 6.0, D 9.9, E 1.9 |
| B12 | C_wd_slog | 0 | 1.000 | 1.73 | 0.0140 | A 36.7, B 4.2, C 1.7, D 4.3, E 1.9 |

<!-- T_INT8 -->
| Models | Networks | Rows | Decisions changed | Share | On labelled rows | Latched first alarm identical | Mean abs. logit error | Max abs. logit error | Networks with dead weights zeroed |
|---|---|---|---|---|---|---|---|---|---|
| A: Run 1-2 settings | 35 | 45015 | 74 | 0.164 % | 0 | 33 | 0.244 | 11.26 | 1 |
| B: weight decay 0.01 | 35 | 45015 | 74 | 0.164 % | 0 | 33 | 0.058 | 0.46 | 30 |
| C: B + log inputs | 35 | 45015 | 44 | 0.098 % | 2 | 34 | 0.038 | 0.28 | 35 |
| D: B, no temperature | 35 | 45015 | 40 | 0.089 % | 0 | 34 | 0.064 | 2.08 | 35 |
| E: C + D | 35 | 45015 | 13 | 0.029 % | 3 | 35 | 0.039 | 0.35 | 35 |
| Final E models (all 7 bearings, in-sample) | 5 | 45015 | 39 | 0.087 % | 4 | 34 of 35 bearing runs | 0.041 | 0.29 | 5 |

<!-- T_RTL -->
| Network | Batches of 64 | Cycles per 64 | M = 64 | Cycles per 1 | M = 1 |
|---|---|---|---|---|---|
| Final E, seed 0 (all 7 bearings) | 24 | 1642 | PASS | 382 | PASS |
| Outer B_wd/B02 (seed 0) | 9 | 1642 | PASS | 382 | PASS |
| Outer B_wd/B03 (seed 0) | 9 | 1642 | PASS | 382 | PASS |
| Outer B_wd/B04 (seed 0) | 9 | 1642 | PASS | 382 | PASS |
| Outer B_wd/B08 (seed 0) | 9 | 1642 | PASS | 382 | PASS |
| Outer B_wd/B09 (seed 0) | 9 | 1642 | PASS | 382 | PASS |
| Outer B_wd/B11 (seed 0) | 9 | 1642 | PASS | 382 | PASS |
| Outer B_wd/B12 (seed 0) | 9 | 1642 | PASS | 382 | PASS |
| Outer C_wd_slog/B03 (seed 0) | 9 | 1642 | PASS | 382 | PASS |
| Outer C_wd_slog/B04 (seed 0) | 9 | 1642 | PASS | 382 | PASS |
| Outer C_wd_slog/B11 (seed 0) | 9 | 1642 | PASS | 382 | PASS |
| Outer C_wd_slog/B12 (seed 0) | 9 | 1642 | PASS | 382 | PASS |
| Outer E_wd_slog_noT/B02 (seed 0) | 9 | 1642 | PASS | 382 | PASS |
| Outer E_wd_slog_noT/B08 (seed 0) | 9 | 1642 | PASS | 382 | PASS |
| Outer E_wd_slog_noT/B09 (seed 0) | 9 | 1642 | PASS | 382 | PASS |

<!-- T_RUNS -->
| Bearing | Run 1 (unlatched rule; 2 training bearings, 3 seeds) | Run 2 (latched; same networks) | Run 3 A (Run 1–2 settings, 6 training bearings, 5 seeds; unlatched changes) | Run 3 E (selected; unlatched changes) | Anomaly detector (A, F42, speed) |
|---|---|---|---|---|---|
| B02 | 76.6–79.5 / 9–17 | 76.6–79.5 / 1 | 68.6–158.1 / 19–21 | 80.0–80.3 / 1 | 81.0 / 1 |
| B03 | 7.4 / 1–3 | 7.4 / 1 | 7.4–10.5 / 3–5 | 16.5 / 1 | 20.4 / 1 |
| B04 | 194.6–204.4 / 43–47 | 194.6–204.4 / 1 | 194.6 / 65–75 | 208.6 / 1 | 209.6 / 1 |

<!-- T_BEARINGLEVEL -->
| Bearings | E (selected) | C | B (primary) | A (Run 1–2 settings) | Nested selection | Anomaly detector | Trivial rule: latch right after commissioning |
|---|---|---|---|---|---|---|---|
| all 7 | 6/7 (0.42–1.00) | 6/7 (0.42–1.00) | 6/7 (0.42–1.00) | 6/7 (0.42–1.00) | 6/7 (0.42–1.00) | 7/7 (0.59–1.00) | 7/7 (0.59–1.00) |
| exploratory (B02–B04) | 3/3 (0.29–1.00) | 3/3 (0.29–1.00) | 3/3 (0.29–1.00) | 3/3 (0.29–1.00) | 3/3 (0.29–1.00) | 3/3 (0.29–1.00) | 3/3 (0.29–1.00) |
| unbiased new (B08, B09, B11, B12) | 3/4 (0.19–0.99) | 3/4 (0.19–0.99) | 3/4 (0.19–0.99) | 3/4 (0.19–0.99) | 3/4 (0.19–0.99) | 4/4 (0.40–1.00) | 4/4 (0.40–1.00) |
| all except B12 (descriptive) | 6/6 (0.54–1.00) | 6/6 (0.54–1.00) | 6/6 (0.54–1.00) | 6/6 (0.54–1.00) | 6/6 (0.54–1.00) | 6/6 (0.54–1.00) | 6/6 (0.54–1.00) |

<!-- T_TRIVIAL -->
| Trivial rule (no learning, no data) | End stage latched before the stop | Healthy rows alarmed | Accuracy on labelled rows | First alarm, min before last record |
|---|---|---|---|---|
| Never alarm | 0 of 7 | 0 | 0.9524 | – |
| Latch an alarm at the first measurement after commissioning (row 101) | 7 of 7 | 0 | 1.0000 | 133–677 |

<!-- T_LAG -->
| Bearing | Anomaly detector first alarm (id) | Detector, min before last record | E: lag (measurements; + = later) | C: lag | B: lag |
|---|---|---|---|---|---|
| B02 | 865 | 81.0 | +2, +3 | +1 | +0, +2 |
| B03 | 549 | 20.4 | +12 | +12 | +9, +12 |
| B04 | 442 | 209.6 | +3 | +2, +3 | +2 |
| B08 | 614 | 424.5 | +602 | +602 | +601, +602 |
| B09 | 211 | 651.7 | +15, +19 | -4 | -9 |
| B11 | 706 | 339.7 | +6, +7 | +1, +3, +5 | -116, -7 |
| B12 | 563 | 40.8 | never | never | never |

<!-- T_X8 -->
| Bearing | x8 on the 5 end-stage rows (raw) | x8 as the clip16 network sees it | x8 = 0 on all 100 healthy rows |
|---|---|---|---|
| B02 | 12.9, 12.8, 12.8, 12.9, 13.0 | 12.9, 12.8, 12.8, 12.9, 13.0 | yes |
| B03 | 1.8, 1.9, 7.4, 10.5, 21.1 | 1.8, 1.9, 7.4, 10.5, 16.0 | yes |
| B04 | 7.1, 7.4, 7.2, 7.2, 7.2 | 7.1, 7.4, 7.2, 7.2, 7.2 | yes |
| B08 | 0.0, 0.0, 0.0, 0.0, 0.0 | 0.0, 0.0, 0.0, 0.0, 0.0 | yes |
| B09 | 11.4, 11.1, 11.5, 11.0, 11.0 | 11.4, 11.1, 11.5, 11.0, 11.0 | yes |
| B11 | -59.5, -60.0, -59.5, -60.2, -60.6 | -16.0, -16.0, -16.0, -16.0, -16.0 | yes |
| B12 | 31.0, 31.2, 30.9, 30.8, 31.1 | 16.0, 16.0, 16.0, 16.0, 16.0 | yes |

