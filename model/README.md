# Machine Guardian model (motor faults, University of Ottawa dataset)

The model the on-chip MLP (`mac_attack_accel_MLP/`, step 15) runs: healthy or faulty, from the vibration of an electric
motor. **Start with `docs/Machine_Guardian_model_report.pdf`** (in the repo's top folder): the whole system from the data to the chip, with every
result. Decisions and results are logged in `docs/log.md`, section 12.

## Setup (once per computer)

Python 3.14 was used (`requirements.txt` pins every package). From the repo's top folder:

```
python3 -m venv model/.venv
model/.venv/bin/pip install -r model/requirements.txt
```

On Windows: `py -m venv model\.venv`, then `model\.venv\Scripts\pip install -r model\requirements.txt`, and use
`.venv\Scripts\python` wherever this file says `.venv/bin/python`. The RTL check also needs Icarus Verilog 12 or newer
(`iverilog` and `vvp` on PATH; macOS: `brew install icarus-verilog`).

## Run it yourself (no dataset needed)

Everything below works from the files in git; only `features.py` and `ramps.py` need the 2.5 GB dataset. Inside
`model/`:

1. `.venv/bin/python rtl_check.py`: runs the exported INT8 model on the accelerator's RTL and checks every number
   (about 15 s; every line must say PASS; it works in a temporary folder).
2. `.venv/bin/python export.py`: rebuilds `export/E3/` from the trained weights and prints FP32 against INT8 per split
   (test: 27/28 faults found, 0/4 false alarms, 0 decisions changed).
3. `.venv/bin/python train.py E3 --out /tmp/mg`: retrains E3 (all three seeds, about 1 s) into another folder, so the
   committed results stay as they are; compare with `diff -r weights/E3 /tmp/mg/weights/E3` (and `results/E3`).
   Without `--out` it overwrites `weights/E3` and `results/E3`. `health.py --out` works the same way.
4. `.venv/bin/python report/make_report.py`: rebuilds the PDF report from the saved results.

On the Mac these were made on (Apple silicon), every rerun gives byte-identical files. On another operating system or
processor PyTorch can round differently in the last bits; compare the decisions and metrics, not the bytes.

The dataset is not in git (README rule 4: large files go to Google Drive; the CSV files are 2.5 GB). Only
`features.py` needs it (and `ramps.py`, for one file): keep "University of Ottawa Electric Motor Dataset – Vibr" anywhere outside the repo and pass its
top folder with `--data`. The name has spaces and an en dash, so always quote it. Training and export work from the
tables in `features/` without it.

## Commands (run inside `model/`)

| Command | Needs the dataset? | What it does |
|---|---|---|
| `.venv/bin/python features.py --data "<folder>"` | yes | Reads each of the 128 CSV files once (about 7 s) and writes `features/` (statistics, and each window's drive frequency) |
| `.venv/bin/python ramps.py --data "<folder>"` | yes (one file) | The ramp check: `results/ramps/ramps.png` (spectrogram of `H_H_5_0.csv`, the 1x line of every ramp recording) |
| `.venv/bin/python train.py E0` | no | Trains seeds 42, 43, 44 from `features/`, writes `weights/E0/` and `results/E0/` |
| `.venv/bin/python train.py E1` (`E2`, `E3`) | no | The same for E1 (log amplitudes and log f), E2 (E1 on 1-s windows), E3 (E2 plus accelerometer 1) |
| `.venv/bin/python health.py` | no | Output 2, the health index (H1): `weights/H1/health.json`, `results/H1/` |
| `.venv/bin/python export.py` | no | The proposed model (E3, seed 42; Alex to confirm) in INT8: `export/E3/` (hex files, C header, test vectors), checked with `golden_mlp()` |
| `.venv/bin/python rtl_check.py` | no | Runs `export/E3/` on the RTL (`tb/tb_mlp.sv`, Icarus 12 or newer) and checks every number (about 15 s) |
| `.venv/bin/python report/make_report.py` | no | The PDF report and its charts (`report/`), from the saved results |

`train.py` is deterministic: the same command gives byte-identical weights and results. So are the other scripts.

**The model** (27 Oct, [proposed], Alex to confirm; `docs/log.md` section 12): E3 seed 42, 22 inputs -> 32 -> 16 -> 1
(ReLU), one 1-s window per row; the motor is called faulty when the sum of its last 10 window logits reaches
10 x T_int (output 1). The health index (output 2) is planned to run on the ARM from the same window statistics
[proposed]. Everything the board needs is in `export/E3/mg_model.h`.

## Files

| Path | In git | What it is |
|---|---|---|
| `dataset.py` | yes | File names to class, label, speed code and load; the fixed split; the commanded frequency |
| `features.py` | yes | The 8 statistics per accelerometer, per recording and per 1-s window, with its checks |
| `speed.py` | yes | The drive frequency per window: tracks the 1x line of the ramps, fits a ramp-and-hold command |
| `ramps.py` | yes | The ramp check figure |
| `train.py` | yes | The experiments and the training, threshold and reporting rules (see its docstring) |
| `health.py` | yes | The health index (output 2) |
| `export.py`, `rtl_check.py` | yes | INT8 export and the RTL check |
| `features/recordings.csv` | yes | 128 rows, one per 10-s recording |
| `features/windows.csv` | yes | 1,280 rows, one per 1-s window (with `f_hz`, the window's drive frequency) |
| `features/speed.csv`, `tracks.csv` | yes | The drive command of each recording and its fit; the tracked 1x lines of the 64 ramp recordings |
| `weights/<E>/seed<s>.pt` | yes | PyTorch `state_dict`, load with `torch.load(path, weights_only=True)` |
| `weights/<E>/model.json` | yes | Inputs, layer sizes, standardizer, pos_weight, threshold and stopping epoch for each seed |
| `weights/H1/health.json` | yes | The health index's healthy reference and anchors |
| `results/<E>/` | yes | `report.md` (the tables), `metrics.json`, `scores.csv` (every recording's score and decision) |
| `results/H1/`, `results/ramps/` | yes | The health index's report and every recording's index; the ramp check figure |
| `export/E3/` | yes | `W<l>.hex`, `Bias<l>.hex`, `Scl<l>.hex` (for `tb_mlp.sv`), `mg_model.h`, `vectors/`, `quant.json`, `report.md` |
| `report/` | yes | `make_report.py` and the charts in `figures/`; it writes the PDF to `../docs/Machine_Guardian_model_report.pdf` |
| `.venv/` | no | Python environment |

The tables are in `features/`, not `data/`, because `.gitignore` ignores every `data/` folder.

## Data and split

- Only `2_CSV_Data_Files/{1_Unloaded_Condition,2_Loaded_Condition}/*.csv` is used (the `.mat` files are copies, `1_Time`
  is not a recording). Each file is 10 s at 42 kHz: accelerometers 1, 2, 3, microphone, temperature.
- Label 0 = healthy (`H_H`, 16 files), 1 = faulty (the 7 other classes, 112 files). Positive class = faulty.
- Speed codes: 1-4 = 15, 30, 45, 60 Hz; 5 = 15->45, 6 = 30->60, 7 = 45->15, 8 = 60->30 Hz (ramps over the 10 s).
- Split by speed code (as in James's report): train 3, 4, 5, 8 (8 healthy / 56 faulty), val 2, 7 (4/28), test 1, 6 (4/28).
- E0-E2 use accelerometers 2 and 3; E3 (the proposed model) adds accelerometer 1. No microphone, no temperature.

## Rules for experiments

Models are compared on validation only. Every experiment's test result is reported, and an experiment is never changed
after its test result has been seen: a new idea becomes a new experiment (E1, E2, ...).
