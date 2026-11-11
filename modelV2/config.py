"""Constants, paths and the two rules every modelV2 script relies on: model/ is read-only, locked bearings are refused."""
import json, sys
from pathlib import Path

sys.dont_write_bytecode = True                      # importing model/ code must not create model/__pycache__

HERE = Path(__file__).resolve().parent
REPO = HERE.parent
MODEL = REPO / "model"
sys.path.insert(0, str(MODEL))                      # model/ code is imported, never copied or edited

RAW = HERE / "rawdata"                              # gitignored; every raw recording modelV2 needs (some are links)
PADERBORN_RAW = RAW / "paderborn"                   # one folder per bearing: B02, B03, ...
OTTAWA_RAW = RAW / "ottawa" / "3_MatLab_Raw_Data_Files (.mat)"
DATA, RUNS, PRECHECKS, EXPORT, REPORT = (HERE / n for n in ("data", "runs", "prechecks", "export", "report"))
FROZEN = HERE / "frozen.json"                       # written once by freeze.py; unlocks the locked bearings

FS, CUTOFF, WIN = 42000, 15000, 67200               # Hz, Hz, samples (1.6 s)
FEATURES = [("rms", True), ("peak", True), ("kurt", False), ("crest", False),
            ("band_10_1k", True), ("band_1k_5k", True), ("band_5k_15k", True)]      # (name, take the log)
BANDS = {"band_10_1k": (10, 1000), "band_1k_5k": (1000, 5000), "band_5k_15k": (5000, 15000)}
HIST_FEATURES = ["rms", "band_1k_5k", "band_5k_15k", "kurt"]
INPUTS = ([f"z_{n}" for n, _ in FEATURES] + ["g_score"] + [f"m4_{n}" for n in HIST_FEATURES] + ["rpm"])
S_X = 9.210440366976517 / 127                       # ln(10001) / 127: slog's range on INT8

REF_N, HOLD_N, END_N, HIST = 100, 50, 20, 4
STEP_D = 3.0                                        # commissioning step check
# Smallest baseline sigma allowed, per FEATURES. A fixed constant (the smallest reference sigma seen on the 7 Paderborn
# development bearings, rounded), so it does not depend on which bearings are on disk or held out. It only matters
# for short baselines such as Ottawa's 5 windows, whose own sigma is far too small.
SIGMA_FLOOR = (0.04, 0.08, 0.04, 0.29, 0.07, 0.05, 0.056)
WARN_N, WARN_CLEAR, FAIL_N = 3, 20, 3               # host status ladder
# Health target = severity of the detector score: 100 % at or below HEALTH_FULL_AT (healthy rows stay below it), falling
# with the score's logarithm to 0 % at HEALTH_ZERO_AT (a typical end-stage score on the development bearings).
HEALTH_FULL_AT, HEALTH_ZERO_AT = 2.5, 25.0
# Temperature rule (host only): on when the housing temperature is more than TEMP_RISE_C above its own median over
# the previous TEMP_WINDOW measurements, 3 in a row; the first TEMP_SETTLE_MIN minutes after a start or stop are
# ignored (B08 takes about an hour to warm from 30 to 98 C). Set on the development bearings: after the first hour the
# largest such rise in healthy operation was 5.4 C.
TEMP_WINDOW, TEMP_RISE_C, TEMP_SETTLE_MIN = 50, 6.0, 60
# Training label for the status head: every Paderborn row after the detector's sustained onset counts as faulty, not
# only the last END_N rows, so the network also learns moderate, sustained damage (the level B12 ends at).
# Evaluation is unchanged: "end stage caught" still means the last END_N rows.
FAULTY_FROM_ONSET = True
HIDDEN, STEPS, QUICK_STEPS, BATCH, LR, WD, SEEDS = (32, 16), 4000, 300, 64, 1e-3, 0.01, (0, 1, 2)

PAD_DEV = ["B02", "B03", "B04", "B08", "B09", "B11", "B12"]
PAD_LOCKED = sorted(json.loads((MODEL / "results/splits/splits.json").read_text())["split"]["test"].values())
OTT_TYPE = {n: t for t, ns in {"inner": range(1, 6), "outer": range(6, 11), "ball": range(11, 16),
                               "cage": range(16, 21)}.items() for n in ns}
OTT_LOCKED = [4, 7, 15, 19]     # random.Random(20261110).choice per fault type; 1 and 10 were not eligible (seen)
OTT_DEV = [n for n in OTT_TYPE if n not in OTT_LOCKED]


def assert_unlocked(bearings):
    """Refuses a locked bearing (Paderborn "B06", Ottawa 4 or "U04", any letter case) until freeze.py has written
    frozen.json."""
    def locked(b):
        s = str(b).strip().upper()
        return s in PAD_LOCKED or (s.lstrip("U").isdigit() and int(s.lstrip("U")) in OTT_LOCKED)
    if isinstance(bearings, str):
        raise TypeError("pass a list of bearings")
    bad = sorted(str(b) for b in bearings if locked(b))
    if bad and not FROZEN.exists():
        raise RuntimeError(f"{bad} are locked test bearings: freeze a model first (freeze.py)")


def writable(path):
    """For outputs whose folder may not exist yet; refuses anything under model/. (Every modelV2 output path is built
    from HERE, so none can point into model/.)"""
    path = Path(path).resolve()
    if MODEL in path.parents or path == MODEL:
        raise RuntimeError(f"refusing to write under model/: {path}")
    path.parent.mkdir(parents=True, exist_ok=True)
    return path


def rows_sha256():
    """Fingerprint of the prepared data: a run is only evaluated or exported against the data it was trained on.
    Hashes the arrays, not the file, so running prep.py again on unchanged data gives the same fingerprint."""
    import hashlib
    import numpy as np
    h, rows = hashlib.sha256(), np.load(DATA / "rows.npz")
    for k in sorted(rows.files):
        h.update(k.encode() + np.ascontiguousarray(rows[k]).tobytes())
    return h.hexdigest()


def stale(run_cfg, name):
    """True (with a message) if prep.py has rebuilt the data since this run was trained."""
    if run_cfg.get("rows_sha256") != rows_sha256():
        print(f"{name}: skipped, prep.py has rebuilt the data since this run was trained")
        return True
    return False
