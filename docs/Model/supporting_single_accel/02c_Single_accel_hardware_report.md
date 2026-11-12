# E3_single_accel_a2 on the INT8 accelerator

28 Oct 2026. The selected single-accelerometer model (accelerometer 2, seed 42) converted with the existing pipeline
(`export.py`, unchanged method) and run on the existing RTL (`rtl_check.py` -> `mac_attack_accel_MLP/tb/tb_mlp.sv`).
**Everything here is simulation (Vivado 2019.1 xsim) or Python; nothing was measured on the FPGA.** No RTL file
was changed. Files: `export/E3_single_accel_a2/` (`W<l>.hex`, `Bias<l>.hex`, `Scl<l>.hex`, `mg_model.h`, `quant.json`,
`report.md`, `vectors/`).

## Deployed model: E3_single_accel_a1 (accelerometer 1, seed 42)

Chosen by the team after the test results (mounting; see `02a_Single_accel_model_report.md` section 0). Same
architecture and pipeline as the a2 export below; `export/E3_single_accel_a1/`.

- s_x p99.9 = 0.038896 (validation mean |logit error| 0.3670 against 0.3732 for max); hidden scales 0.118791,
  0.104619; m0 32,832..63,319, shift 23..26; bias_last -185; logit scale 0.000474013; FP32 cut -0.6204 ->
  **T_int = -1308** (faulty if the sum of 10 window logits >= -13,080; a negative T_int is fine, `ceil` as for E3).
- FP32 against INT8: train [[8,0],[0,56]], val [[4,0],[0,28]], test [[4,0],[0,28]] in both; **no decision changed in any
  split**; ROC-AUC 1.000. Window error mean 0.194 (test 0.126, max 0.546).
- Lowest 15-Hz margins in INT8 sums: healthy H_H_1_1 -52,404 and faulty S_W_1_0 37,180 against -13,080.
- **RTL (`rtl_check.py --experiment E3_single_accel_a1 --sim vivado`): PASS** on all 1,280 windows (1,642 cycles per
  M = 64 run), M = 10 (**562 cycles**, 2.62 us), M = 1 (**382 cycles**, 1.78 us); logits identical in the three runs;
  every test decision equals the vectors (28 of 32 called faulty). Simulation only.

## Dimensions and size

| | E3 (historical) | E3_single_accel_a2 |
|---|---|---|
| Layers (K x N) | 22x32, 32x16, 16x1 | **8x32**, 32x16, 16x1 |
| Weights (INT8) | 1,232 | 784 |
| Biases (INT32; last layer on the ARM) | 48 + 1 | 48 + 1 |
| Parameters (FP32 model) | 1,281 | 833 |
| Passes on the 8x8 array (P = 8) | 3x4 + 4x2 + 2x1 = 22 | **1x4 + 4x2 + 2x1 = 14** |

The first layer's K = 8 fills exactly one tile row of the 8x8 array (E3's 22 needed 3 tiles, the last one padded).
Every accumulator sum fits in 22 bits (checked in `export.py`).

## INT8 conversion (existing spec, nothing changed)

- Inputs: training standardizer, then one input scale; candidates max and 99.9th percentile of |x_std| over the train
  windows, chosen on validation: **p99.9, s_x = 0.0356306** (validation mean |logit error| 0.2359 against 0.4340).
- Weights per output channel, max |W| / 127; hidden scales from the largest train activation: s_h = 0.111347,
  0.165829; m0 in 33,036..65,197, shift 24..26; last-layer bias on the ARM: -162; logit scale 0.000690221.
- Decision: FP32 cut 3.6484 (validation) -> **T_int = 5286**; faulty if the sum of the last 10 window logits >= 52,860.

| Split | FP32 [[TN,FP],[FN,TP]] | INT8 | ROC-AUC FP32 / INT8 | Decisions changed |
|---|---|---|---|---|
| train | [[8,0],[0,56]] | [[8,0],[0,56]] | 1.000 / 1.000 | 0 |
| val | [[4,0],[0,28]] | [[4,0],[0,28]] | 1.000 / 1.000 | 0 |
| test | [[4,0],[2,26]] | **[[4,0],[3,25]]** | 1.000 / 1.000 | **1: R_M_1_0** |

- **Quantization changes one test decision:** R_M_1_0 (rotor misalignment, 15 Hz) has FP32 score 3.681 against the cut
  3.648 (margin 0.033 logit); INT8 sum 51,830 against 52,860. The mean window error is 0.16 logit on test, so any
  recording within about that of the cut can flip. INT8 test: accuracy 0.906, recall 0.893, precision 1.000,
  F1 0.943, no false alarm. This is the cut-placement issue of the model report (section 5); the threshold was not
  re-tuned on test.
- Window logits, |INT8 x scale - FP32|: mean 0.185, max 28.1 (all splits; the largest are windows whose inputs clip at
  the p99.9 scale, far from the cut); test: mean 0.161, max 1.16.

## Python golden model

`mac.golden_mlp()` (unchanged) runs the exported hex files; `test_single_accel.py` checks that it reproduces every
test window's INT8 inputs and raw sum in `vectors/test_windows.csv`. `mg_model.h` holds everything the ARM needs,
including the health index (`MG_HI_*`, 7 statistics of accelerometer 2).

## RTL simulation (`python rtl_check.py --experiment E3_single_accel_a2 --sim vivado`)

ZedBoard settings: P 8, ACC 22, PIPE 2, MEM_REG 2, HREAD_REG 1, NL 4, 8 postproc lanes, 9-stage postproc.

| Run | Result | Model cycles (xsim) | Equation | Time at 214.286 MHz |
|---|---|---|---|---|
| All 1,280 windows, M = 64 x 20 runs | **PASS**: every raw sum C, the A buffer and the 4 counters = Python | 1,642 per run | 1,642 | 7.66 us |
| 32 test recordings, M = 10 each | **PASS** | **562** | 562 | 2.62 us |
| One window at a time, M = 1 (x 10) | **PASS** | **382** | 382 | 1.78 us |
| Decisions | **PASS**: logits identical in the three runs; every test recording's sum and decision = the exported vectors (25 of 32 called faulty) | | | |

The same check of E3 on this PC also passes, with E3's committed figures (566 cycles at M = 1, 818 at M = 10).
The 214.286 MHz figure is the clock of the earlier on-chip MLP build (project log), not re-verified here.

### Simulator note (no RTL change needed)

On this PC only Vivado 2019.1 is installed (no Icarus). `rtl_check.py` was Icarus-only, so `--sim vivado` was added.
xelab's default optimizer (-O2) in 2019.1 miscompiles the **testbench** `tb_mlp.sv`: after `NN[0] = N0` the array keeps
its default 8, so the testbench loads 8x8 layers and writes 8 outputs per row (reproduced with a `$display`; a minimal
module does not show it). With `xelab -O0` the testbench runs correctly and every number matches. The new model did not
expose any RTL compatibility issue, so no RTL was changed. `mac.py mlp --sim vivado` still hits the same xsim problem
(`mac.py` was not edited); `mac.py test --quick --sim vivado` passes 20/20.

## Compatibility

- K0 = 8 <= MAXD 64, 3 layers <= NL 4, N <= 64: within the accelerator's limits, no new parameter needed.
- The board flow is the same as E3's: compute 8 inputs per second on the ARM, quantize, one model run (M = 1, or M = 10
  for the last 10 s), add `MG_BIAS_LAST`, sum 10 logits against `10 * MG_T_INT`.

## Remaining FPGA deployment tasks

1. Load `export/E3_single_accel_a1/` (the deployed model) into the ZedBoard app; the
   ARM side must compute the 8 inputs with `mg_model.h`'s formulas and C's `round()`; check against
   `vectors/test_windows.csv` on the board.
2. Measure on the board: cycles from the hardware counters, wall-clock time per window including AXI transfers and
   feature extraction, at the clock actually achieved.
3. Real sensor path: sample one accelerometer at 42 kHz (or retrain at our rate), m/s^2 with the DC offset kept,
   drive-reported commanded frequency; then a healthy baseline on our motor.
4. Re-run `rtl_check.py` with Icarus (the README's reference simulator) where it is installed.
