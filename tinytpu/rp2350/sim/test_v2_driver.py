# cocotb: the RP2350 driver for Version 2 (../tinytpu_v2.py, unchanged) and the model file the board
# loads (../model_v2.py), run against the chip's RTL (../../chip_v2/src) through the same pins.
import sys
from pathlib import Path

import cocotb
from cocotb.task import bridge

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
sys.path.insert(0, str(Path(__file__).resolve().parent))
import model_v2 as M                                   # noqa: E402
from sim_pins import SimPins, start                     # noqa: E402
from tinytpu_v2 import TinyTPUv2, infer_host, decode    # noqa: E402


def run(dut, rows_fast):
    pins = SimPins(dut)
    tpu = TinyTPUv2(pins)
    tpu.reset()
    r = {"rows": 0, "hidden": 0, "hidden_ok": 0, "fast": 0, "bypass": 0, "ovf": 0}

    # every row: hidden layers on chip, every hidden output read back and compared with the host's math
    for i in range(M.N_ROWS):
        hc, hh = [], []
        sums = tpu.infer(M.LAYERS, M.X[i], hc)
        infer_host(M.LAYERS, M.X[i], hh)
        r["rows"] += sums == list(M.C[i])
        for a, b in zip(hc, hh):
            r["hidden"] += len(b)
            r["hidden_ok"] += sum(1 for x, y in zip(a, b) if x == y)
        r["ovf"] |= tpu.status()[2] | tpu.status()[3]
        if i == 0:
            r["row0"] = decode(sums, M.BIAS_LAST, M.OUT_SCALE, M.STATUS_NAMES)[:2]

    # the board's normal path (no read-back), counting clocks and pin operations
    c0, o0 = tpu.clocks, pins.ops
    for i in range(rows_fast):
        r["fast"] += tpu.infer(M.LAYERS, M.X[i]) == list(M.C[i])
    r["clocks"] = (tpu.clocks - c0) // rows_fast
    r["ops"] = (pins.ops - o0) // rows_fast

    # bypass: the host does bias / rescale / ReLU
    for i in range(rows_fast):
        r["bypass"] += tpu.infer_bypass(M.LAYERS, M.X[i]) == list(M.C[i])
    return r


@cocotb.test()
async def driver_runs_modelv2(dut):
    await start(dut)
    rows_fast = 16
    r = await bridge(run)(dut, rows_fast)
    dut._log.info(f"on chip with read-back: {r['rows']}/{M.N_ROWS} rows, {r['hidden_ok']}/{r['hidden']} hidden outputs")
    dut._log.info(f"on chip: {r['fast']}/{rows_fast} rows, {r['clocks']} clocks and {r['ops']} pin operations per row")
    dut._log.info(f"bypass: {r['bypass']}/{rows_fast} rows; row 0 decodes as {r['row0'][0]}, health {r['row0'][1]:.1f} %")
    assert r["rows"] == M.N_ROWS and r["hidden_ok"] == r["hidden"] == M.N_ROWS * (32 + 16)
    assert r["fast"] == rows_fast and r["bypass"] == rows_fast and not r["ovf"]
