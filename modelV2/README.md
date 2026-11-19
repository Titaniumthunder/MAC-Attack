# modelV2: bearing status and health for the MAC accelerator

One MLP (13 → 32 → 16 → 4, INT8). Output: three status logits (healthy / developing / faulty) and one health logit.
The host turns them into Normal / Anomaly / Warning / Failing and a health %.

Two versions, identical except for the training data:
- **A**: Paderborn run-to-failure only. Trains healthy / faulty and health %. Cannot learn "developing".
- **B**: Paderborn + Ottawa UORED-VAFCLS. Ottawa's stage labels also train the status head; health % is still Paderborn only.

The Ottawa pre-checks failed (`prechecks/prechecks.html`), so B's "developing" output is only to be trusted if
`evaluate.py` shows it near 0 on healthy Paderborn rows, rising after onset, and not tied to ~1800 rpm.

Rules: nothing here writes into `model/` (it is imported read-only); locked bearings (Paderborn B06, B07, B13, B17;
Ottawa 4, 7, 15, 19) are refused until `freeze.py` has run; no RTL changes.

## Data

All raw recordings are under `modelV2/rawdata/` (gitignored):

- `rawdata/paderborn/<B..>/`: one folder per bearing. B02, B03, B04 are stored here. B08, B09, B11, B12 are links to
  `model/newdata/`, where the old model's scripts expect them (no second copy on disk).
- `rawdata/ottawa/`: a link to the UORED-VAFCLS folder in `Capstone/`.
- Locked test: B06, B07, B13, B17 are kept as feature tables only (`data/paderborn_<B>.csv`); their raw files (72 GB) were deleted after the tables were built.

## Commands, in order (from the repo root)

| Step | Command | Output |
|---|---|---|
| Tests | `model/.venv/bin/python -m pytest -q modelV2/tests` | 4 rule tests |
| Prep | `model/.venv/bin/python modelV2/prep.py` | `data/` (features cached per bearing) |
| Pre-checks | `model/.venv/bin/python modelV2/precheck.py` | `prechecks/prechecks.html` |
| Dry run | `model/.venv/bin/python modelV2/train.py --data paderborn --name A --quick` | `runs/<date-time>_A/` |
| Train A | `model/.venv/bin/python modelV2/train.py --data paderborn --name A` | `runs/<date-time>_A/live.html`, `runs/compare.html` |
| Train B | `model/.venv/bin/python modelV2/train.py --data paderborn+ottawa --name B` | another run folder |
| No-history variant | `model/.venv/bin/python modelV2/train.py --data paderborn+ottawa --name B_nohist --history 0` | another run folder |
| Evaluate | `model/.venv/bin/python modelV2/evaluate.py` | `runs/*/eval.json`, `timelines.png`, `report/comparison.json` |
| INT8 + RTL | `model/.venv/bin/python modelV2/hardware.py --run modelV2/runs/<folder>` | `runs/<folder>/hardware.json`, `export/<folder>/seed*/` |
| INT4 (Tiny-TPU V1) | see "INT4 for Tiny-TPU Version 1" below | `runs/<folder>/hardware_int4.json`, `export/<folder>_int4/seed*/` |
| Report | `model/.venv/bin/python modelV2/report.py` | `report/report.html`, `docs/Model/13_modelV2_bearing_status_and_health.pdf` |
| Freeze | `model/.venv/bin/python modelV2/freeze.py --run modelV2/runs/<folder>` | `frozen.json` (once) |
| Locked test | `model/.venv/bin/python modelV2/locked_eval.py` | `report/locked_results.json` (once; needs the feature tables of B06, B07, B13, B17) |
| Live replay | `model/.venv/bin/python modelV2/live.py --model modelV2/export/<folder>/seed0 --replay modelV2/rawdata/paderborn/B08` | `live_status.html` |

While a training run is going, open its `live.html` in a browser: it refreshes itself.

## Files

| File | What it does |
|---|---|
| `config.py` | constants, paths, the locked sets, the "never write under model/" guard |
| `pipeline.py` | host-side pipeline: signal chain, features, baseline, network inputs, status ladder, temperature rule |
| `prep.py` | raw recordings → feature tables → `data/rows.npz`, `folds.json`, `summary.json` |
| `precheck.py` | the three checks on Ottawa and on dataset overlap |
| `net.py` | the network and the masked two-head loss |
| `train.py` | training, run folders, `live.html`, `compare.html` |
| `page.py` | the curve figure and self-refreshing HTML pages |
| `evaluate.py` | validation results per held-out bearing, with run 3 beside them |
| `hardware.py` | INT8 export, FP32 vs INT8, RTL bit-exact check |
| `freeze.py`, `locked_eval.py` | freeze a model, then the one-time locked test |
| `report.py` | report (HTML + PDF) from saved results |
| `live.py` | live inference from a source (replay source included; sensor source is a stub) |
| `int4.py` | INT4 for Tiny-TPU Version 1: the host flow (contract), the quantization-aware network `QMLP`, the integer reference `forward_int`, a model of the PE |
| `hardware_int4.py` | INT4 export for Version 1 (ZedBoard header, `quant4.json`), integer flow on every validation fold, PE check |

## INT4 for Tiny-TPU Version 1 (18 Nov 2026)

Version 1 (`tinytpu/chip`, on the ZedBoard as `tinytpu/fpga_zed`) is one INT4 x INT4 processing element with a 16-bit
sum, so the INT8 export above cannot run on it. `int4.py` is the INT4 version: the professor's Version 1 host flow
extended from 2 layers to 3, with the same 13 inputs and the same 13-32-16-4 network.

- The chip does only the multiply-adds: CLEAR, one MAC per input, READ (1,096 commands per inference). The host does
  the rest in double precision. It standardizes each input (`MU`, `SD` from the training rows), then per layer
  computes `z = acc * S_A[l] * S_W[j] + B[j]`, applies ReLU, and rounds back to INT4 for the next layer with
  `q4(v) = clip(rint(v), -7, 7)`.
- Weights are INT4 in [-7, 7] with one scale per neuron. Activations have one learned scale per layer. Biases stay
  float, on the host.
- Overflow cannot happen: |sum| <= 49 x 32 = 1,568, far inside 16 bits. `integer_model` refuses any layer wider
  than 668.
- Changes from the INT8 model, and why:
  - **Inputs:** standardized per input, replacing the single INT8 `S_X`. With 7 levels, a shared scale would give
    most inputs only one or two steps.
  - **Weight scales:** one per neuron. This is free, because the host multiplies per neuron anyway.
  - **Training:** quantization-aware (`train.py --int4`). It runs FP32 for the first half, then INT4 fake
    quantization with straight-through rounding and learned activation scales. It uses `INT4_STEPS` = 6000 steps
    instead of 4000. Weight decay is switched off in the INT4 phase: with per-neuron scales it shrinks
    every weight, and the outputs with them (the first INT4 run, `runs/20261118-210533_A_int4`, failed this way).
  - **Activation scales:** start at the 99th percentile instead of the maximum.
  - **Layer sizes:** `--hidden` lets a run try wider layers.

These commands need `data/rows.npz`, i.e. the raw data and `prep.py`:

| Step | Command |
|---|---|
| Baseline: INT4 of the existing FP32 run, no retraining | `model/.venv/bin/python modelV2/hardware_int4.py --run modelV2/runs/<FP32 folder>` |
| Train INT4 (version A) | `model/.venv/bin/python modelV2/train.py --data paderborn --name A_int4 --int4` |
| Export it, seed 0 to the ZedBoard | `model/.venv/bin/python modelV2/hardware_int4.py --run modelV2/runs/<A_int4 folder> --to-zed` |
| Compare (FP32, its INT4, the INT4 run) | `model/.venv/bin/python modelV2/evaluate.py` |
| ZedBoard simulation, no board (Vivado 2019.1) | `tinytpu/fpga_zed/sim/xsim_cosim/run_xsim_cosim.bat modelv2_int4_test` |
| ZedBoard | in `tinytpu/fpga_zed`: `xsct sdk_build.tcl`, then `xsct run_on_board.tcl modelv2_int4_test` |

`hardware_int4.py --demo` needs no data. It does a post-training INT4 conversion of the frozen model, calibrated and
tested on the 64 rows of its INT8 export (`export/20261110-220018_A_severity_onset_int4_ptq_demo/`).

Results on those 64 rows (18 Nov). These check the export and are **not a validation**, because the same rows
calibrate and test:
- Status matches FP32 and INT8 on 64/64 rows.
- Health % is 2.9 points from FP32 on average (14.4 at worst).
- Most of the loss comes from the hidden ReLU activations, which have only 8 levels (0..7).

The demo's header is the committed `tinytpu/fpga_zed/sw/modelv2_int4.h`. The board program passed 4/4 against the
Version 1 RTL in Vivado's simulator: all 3,328 PE sums and every output equal `forward_int`, with no overflow.

### Results (18 Nov 2026, version A, validation folds: 7 bearings x 3 seeds)

The data was rebuilt on Windows with numpy 2.1.2. It has the same rows, and the frozen networks reproduce their saved
outputs to 1.4e-6, but its fingerprint differs from the frozen run's. So the FP32 baseline was retrained on it:
`runs/20261118-210234_A_fp32`, with the frozen run's validation losses (status 0.0411, health error 6.3 %).

| | FP32 (`A_fp32`) | FP32 rounded to INT4, no retraining | **INT4 trained (`A_int4`), integer flow** | INT4, 16 hidden levels (`A_int4_h16`), integer flow |
|---|---|---|---|---|
| End stages caught | 21/21 | 21/21 | **21/21** | 21/21 |
| Healthy rows alarmed | 0/3150 | 0/3150 | **0/3150** | 0/3150 |
| Health MAE before / after onset | 4.8 / 11.1 % | 4.4 / 15.0 % | **0.8 / 9.6 %** | 0.8 / 10.1 % |
| Health, worst row vs its reference | | 45 points off FP32 | 3.6 points off its own training | 0.00001 points off its own training |
| Ottawa (held out): healthy called healthy / damaged called faulty | 1.00 / 1.00 | 1.00 / 1.00 | **1.00 / 1.00** | 1.00 / 1.00 |
| Ottawa health % by stage (healthy, developing, faulty) | 97 / 21 / 16 | 97 / 21 / 16 | **100 / 16 / 14** | 100 / 15 / 13 |
| Failing raised, minutes before the end of the recording: B02 / B03 / B04 / B08 / B09 / B11 | 76 / 20 / 210 / 214 / 646 / 339 | the same | **the same** | the same |
| B12, the same (3 seeds) | 41, 41, 41 | 41, 41, 41 | **28, 27, 3** | 33, 28, 3 |

Failing comes within about a minute of the detector's onset on every bearing (it needs 3 faulty rows in a row), and that
is 20 to 646 minutes before the end of each recording.

`A_int4` is `runs/20261118-211245_A_int4`. Its export is `export/20261118-211245_A_int4_int4/`, and seed 0 is in
`tinytpu/fpga_zed/sw/modelv2_int4.h`. The integer flow (what the board computes) changes none of its status decisions
on the folds. `modelv2_int4_test` passed 4/4 against the Version 1 RTL in Vivado's simulator.

The only loss against FP32 is the early warning on B12, the hardest bearing (end-stage score 1.2 x threshold), and it
mostly comes from one seed. Part of the health gain may come from the longer training (6,000 steps, no weight decay in
the second half), not from INT4. The first INT4 run (`runs/20261118-210533_A_int4`) failed because weight decay was
still on during the INT4 phase, and it is kept as a record.

`--hidden-levels 16` (`runs/20261118-220513_A_int4_h16`) sends the hidden activations as 0..15 offset by -8: the PE
accepts -8, and the host adds 8 x sum(w) back (`MV4_CORR`), with no RTL change. It also passed 4/4 in the simulator,
but it did not improve the model: B12's weak seed is unchanged and health after onset is slightly worse. So INT4
resolution is not what limits the model, and the board keeps `A_int4` (8 levels). The option stays, off by default.

The locked test has already been used for the frozen INT8 model (`report/locked_results.json`), so the INT4 models are
judged on the validation folds only.
