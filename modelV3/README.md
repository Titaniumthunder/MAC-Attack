# modelV3: the INT4 bearing model for Tiny-TPU Version 1 (ZedBoard)

modelV3 is its own model, in its own folder. It is a copy of modelV2's code, including the INT4 path for Tiny-TPU
Version 1 (`int4.py`, `train.py --int4`, `hardware_int4.py`). It has its own `data/`, `runs/`, `export/`, `report/` and
`rawdata/`, and its own ZedBoard program. Nothing here reads or writes modelV2's results, and modelV2 is unchanged by
it. `../modelV2/README.md` explains the pipeline, the network and the INT4 host flow ("INT4 for Tiny-TPU Version 1").
Everything there applies here, with `modelV3/` in place of `modelV2/`.

- **Data:** the same as modelV2. Training uses 7 Paderborn bearings (B02, B03, B04, B08, B09, B11, B12); the held-out
  Ottawa bearings are used for evaluation only. The locked bearings (B06, B07, B13, B17) stay refused until
  `freeze.py` runs.
- **Outputs:**
  - the report PDF is `docs/Model/17_modelV3_bearing_status_and_health.pdf`;
  - the ZedBoard header is `tinytpu/fpga_zed/sw/modelv3_int4.h`, run by `modelv3_int4_test.c`. modelV2's
    `modelv2_int4.h` and its program are separate and unchanged.

## Data on disk

`rawdata/` (gitignored) holds links, so no data is copied:
- `paderborn/<B>` points to `model/newdata/<B>`;
- `ottawa` points to `modelV2/rawdata/ottawa`.

## Commands (from the repo root)

| Step | Command |
|---|---|
| Build the data | `python modelV3/prep.py` |
| Train the FP32 baseline | `python modelV3/train.py --data paderborn --name A_fp32` |
| Train INT4 | `python modelV3/train.py --data paderborn --name A_int4 --int4` |
| Export INT4, seed 0 to the ZedBoard | `python modelV3/hardware_int4.py --run modelV3/runs/<A_int4 folder> --to-zed` |
| Evaluate (validation folds) | `python modelV3/evaluate.py` |
| ZedBoard simulation, no board | `tinytpu\fpga_zed\sim\xsim_cosim\run_xsim_cosim.bat modelv3_int4_test` |
| ZedBoard | in `tinytpu/fpga_zed`: `xsct sdk_build.tcl`, then `xsct run_on_board.tcl modelv3_int4_test` |

## Results (18 Nov 2026, validation folds: 7 bearings x 3 seeds)

The runs are `runs/20261118-230326_A_fp32` (FP32) and `runs/20261118-230616_A_int4` (INT4, 8 hidden levels).

| | FP32 | **INT4, integer flow (what the board computes)** |
|---|---|---|
| End stages caught | 21/21 | **21/21** |
| Healthy rows alarmed | 0/3150 | **0/3150** |
| Health MAE before / after onset | 4.8 / 11.1 % | **0.9 / 10.3 %** |
| Ottawa (held out): healthy called healthy / damaged called faulty | 1.00 / 1.00 | **1.00 / 1.00** |
| Failing raised, minutes before the end: B02 / B03 / B04 / B08 / B11 | 76 / 20 / 210 / 214 / 339 | **the same** |
| B09, the same (3 seeds) | 646, 646, 646 | **653, 646, 646** |
| B12, the same (3 seeds) | 41, 41, 41 | **33, 33, 3** |

- The integer flow changes none of the INT4 model's status decisions on the folds.
- Health % moves by at most 0.00001 points between training and the integer flow.
- The export is `export/20261118-230616_A_int4_int4/`.
- `modelv3_int4_test` passed 4/4 against the Version 1 RTL in Vivado's simulator: every INT4 input, all 3,328 PE
  sums and every output equal Python's, with no overflow. It has not been run on the board yet.
- The results match modelV2's INT4 model to within run-to-run variation: same data, same recipe, a fresh training
  run. The only weak spot is the same as modelV2's: one seed of B12, the hardest bearing, warns only 3 minutes
  before the end.
