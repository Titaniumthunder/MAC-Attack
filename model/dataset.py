"""The University of Ottawa electric motor dataset: what each recording is, and the fixed split.

  2_CSV_Data_Files/1_Unloaded_Condition/{A}_{B}_{speed}_{load}.csv   (load 0)
  2_CSV_Data_Files/2_Loaded_Condition/{A}_{B}_{speed}_{load}.csv     (load 1)

  label     0 = healthy (H_H), 1 = faulty (every other class)
  speed     1-4: constant 15, 30, 45, 60 Hz; 5-8: ramps 15->45, 30->60, 45->15, 60->30 over the 10 s
  split     by speed code, as in James's report: train 3, 4, 5, 8; val 2, 7; test 1, 6

Every recording is 10 s at 42 kHz (420,000 rows). The .mat files are copies of the same recordings and
1_Time is not a recording, so only the 128 CSV files are used.
"""
import re
from pathlib import Path

HERE = Path(__file__).resolve().parent
REPO = HERE.parent
MAC_DIR = REPO / "mac_attack_accel_MLP"       # mac.py: requantize, golden_mlp, ... (imported, never edited)
FEATURES = HERE / "features"

FS = 42_000
SECONDS = 10
ROWS = FS * SECONDS
WINDOWS = 10                                  # 1-s windows per recording
HEADER = ["Accelerometer 1 (m/s^2)", "Microphone (V)", "Accelerometer 2 (m/s^2)",
          "Accelerometer 3 (m/s^2)", "Temperature (Celsius)"]
ACCEL_COLS = {1: 0, 2: 2, 3: 3}               # accelerometer -> CSV column (microphone, temperature unused)
CONDITIONS = {"1_Unloaded_Condition": 0, "2_Loaded_Condition": 1}
SPEED_HZ = {1: (15, 15), 2: (30, 30), 3: (45, 45), 4: (60, 60),
            5: (15, 45), 6: (30, 60), 7: (45, 15), 8: (60, 30)}    # nominal commanded Hz at t = 0 s and t = 10 s
SPLIT = {3: "train", 4: "train", 5: "train", 8: "train", 2: "val", 7: "val", 1: "test", 6: "test"}
HEALTHY = "H_H"
NAME = re.compile(r"^([A-Z]_[A-Z])_([1-8])_([01])\.csv$")


def recordings(data):
    """Every recording under the dataset folder `data`, sorted by load then file name:
    dicts with path, file, cls, label, speed, load, split. Checks the counts the split relies on."""
    data = Path(data)
    recs = []
    for folder, load in CONDITIONS.items():
        files = sorted((data / "2_CSV_Data_Files" / folder).glob("*.csv"))
        for p in files:
            m = NAME.match(p.name)
            if not m or int(m.group(3)) != load:
                raise SystemExit(f"Unexpected file name: {p}")
            cls, speed = m.group(1), int(m.group(2))
            recs.append({"path": p, "file": p.name, "cls": cls, "label": int(cls != HEALTHY),
                         "speed": speed, "load": load, "split": SPLIT[speed]})
    counts = {s: [sum(1 for r in recs if r["split"] == s and r["label"] == y) for y in (0, 1)]
              for s in ("train", "val", "test")}
    if len(recs) != 128 or counts != {"train": [8, 56], "val": [4, 28], "test": [4, 28]}:
        raise SystemExit(f"Expected 128 recordings split 8/56, 4/28, 4/28 (healthy/faulty); "
                         f"found {len(recs)}: {counts}. Is --data the dataset's top folder?")
    return recs


def commanded_hz(speed, t0=0.0, t1=float(SECONDS)):
    """Mean of the nominal command over [t0, t1) seconds: constant, or the nominal linear ramp's value at the
    middle of the interval. 7 of the 64 ramp recordings did not follow the nominal ramp (speed.py,
    features/speed.csv); E2 and E3 use features/windows.csv f_hz instead. Used for E1's f."""
    a, b = SPEED_HZ[speed]
    return a + (b - a) * (t0 + t1) / 2 / SECONDS
