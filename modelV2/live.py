"""Live inference (no training): reads measurements from a source, learns the healthy baseline during commissioning,
then prints the status level and health % for every measurement and keeps modelV2/live_status.html up to date
(open it in a browser; it refreshes itself).

  model/.venv/bin/python modelV2/live.py --model modelV2/export/<run>/seed0 --replay modelV2/rawdata/paderborn/B08

The network runs as the chip's bit-exact INT8 model. Without --replay the (not yet written) sensor source is used.
"""
import argparse, json
from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import scipy.io as sio

import config as c
import hardware
import page
import pipeline as F
import prep
import anomaly_baseline as ab                      # model/
import paderborn as pb                             # model/

LEVELS = ["Normal", "Anomaly", "Warning", "Failing"]


class Source:
    """A source yields one measurement at a time, in time order:
       {"samples": 1.6 s or more of accelerometer samples (any unit, kept the same),
        "fs": their sample rate, 42000, 64000 or 128000 Hz,
        "rpm": shaft speed, "temp_c": bearing housing temperature, "time": pandas.Timestamp}"""

    def read(self):
        raise NotImplementedError


class SensorSource(Source):
    """The real sensor: not chosen yet. Implement read() to yield measurements in the format above."""

    def read(self):
        raise NotImplementedError("no sensor source yet: implement SensorSource.read(), or use --replay <folder>")


class ReplaySource(Source):
    """Streams a recorded Paderborn bearing folder (vibrationData/*.mat and its two CSVs), skipping warm-up rows."""

    def __init__(self, folder):
        self.folder, self.exp = Path(folder), Path(folder).name
        c.assert_unlocked([self.exp])

    def read(self):
        table = pb.annotate(pb.load_csvs(self.folder, self.exp), pb.META["experiments"].get(self.exp))
        for path, row in zip(prep.mat_files(self.folder, self.exp)[0], table.itertuples()):
            if row.warmup:
                continue
            m = sio.loadmat(path, variable_names=["measTime", "accHorizRear_A"])
            fs = min(F.RESAMPLE, key=lambda n: abs(n - 1 / np.diff(m["measTime"].ravel()).mean()))
            yield {"samples": m["accHorizRear_A"].ravel().astype(float), "fs": fs, "rpm": row.speed_rpm,
                   "temp_c": row.T1_C, "time": row.timestamp}


def plot(d, s, tau, level, shown):
    fig, axs = plt.subplots(3, 1, figsize=(10, 7), sharex=True)
    axs[0].plot(shown, color=ab.BLUE)
    axs[0].set_ylabel("health %")
    axs[0].set_ylim(0, 100)
    axs[1].step(range(len(level)), level, color=ab.INK2)
    axs[1].set_yticks(range(4), LEVELS)
    axs[2].semilogy(s / tau, ".", ms=3, color=ab.MUTED)
    axs[2].axhline(1, color=ab.ORANGE, linewidth=1)
    axs[2].set_ylabel("detector score / threshold")
    axs[2].set_xlabel("measurements since the start of the baseline")
    fig.tight_layout()
    return fig


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--model", type=Path, required=True, help="an exported model folder (hardware.py)")
    ap.add_argument("--replay", type=Path, help="a recorded Paderborn bearing folder")
    a = ap.parse_args()
    layers, last, quant = hardware.load_export(a.model)
    floor = np.array(list(quant["sigma_floor"].values()))
    rows, cal, hot = [], None, False
    for meas in (ReplaySource(a.replay) if a.replay else SensorSource()).read():
        x = F.to_42k(np.asarray(meas["samples"], float), meas["fs"])[:c.WIN]
        if len(x) < c.WIN:
            raise ValueError(f"{meas['time']}: {len(x)} samples at 42 kHz, need {c.WIN} (1.6 s)")
        rows.append({**F.window_features(x), "ln_speed": np.log(meas["rpm"]), "speed_rpm": meas["rpm"],
                     "T1_C": meas["temp_c"], "timestamp": meas["time"]})
        d = pd.DataFrame(rows)
        if cal is None:
            start, _ = F.commission(d)              # None until 100 rows without a step are in
            if start is None:
                print(f"{meas['time']}  commissioning: {len(d)} measurements")
                continue
            cal = start, F.baseline(d.iloc[start:start + c.REF_N], floor)
        d = d.iloc[cal[0]:].reset_index(drop=True)
        s, Z = ab.score(d, cal[1])
        out = hardware.int8(F.network_inputs(Z, s, d.speed_rpm, F.history(Z), np.full(len(d), quant["history"])), layers, last)
        level, shown = F.status(s, cal[1]["tau"], out[:, :3].argmax(1), out[:, 3])
        hot = bool(F.temperature_warning(d.timestamp, d.T1_C)[-1])
        if len(d) % 20 == 0:
            page.write_atomic(c.HERE / "live_status.html", page.html(
                f"{LEVELS[level[-1]]}, health {shown[-1]:.0f} %{', TEMPERATURE RISING FAST' if hot else ''} ({meas['time']})",
                plot(d, s, cal[1]["tau"], level, shown), refresh=True))
        print(f"{meas['time']}  {LEVELS[level[-1]]:8s} health {shown[-1]:5.1f} %  score/threshold {s[-1] / cal[1]['tau']:6.2f}"
              f"{'  TEMPERATURE RISING FAST' if hot else ''}")


if __name__ == "__main__":
    main()
