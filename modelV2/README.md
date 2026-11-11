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
| Report | `model/.venv/bin/python modelV2/report.py` | `report/report.html`, `report/report.pdf` |
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
