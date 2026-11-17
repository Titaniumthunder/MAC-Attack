# cocotb: the RP2350 driver for Version 1 (../tinytpu_v1.py, unchanged) and the model file the board
# loads (../model_v1.py), run against the chip's RTL (../../chip/src) through the same pins.
import sys
from pathlib import Path

import cocotb
from cocotb.task import bridge

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
sys.path.insert(0, str(Path(__file__).resolve().parent))
import model_v1 as M                                    # noqa: E402
from sim_pins import SimPins, start                     # noqa: E402
from tinytpu_v1 import TinyTPUv1, infer                 # noqa: E402


def run(dut):
    tpu = TinyTPUv1(SimPins(dut))
    tpu.reset()
    good, clocks = 0, []
    for i in range(len(M.TEST_X)):
        c0 = tpu.clocks
        c, logits, sums, ovf = infer(tpu, M, M.TEST_X[i])
        clocks.append(tpu.clocks - c0)
        good += (c == M.TEST_CLASS[i] and sums == list(M.TEST_SUMS[i]) and not ovf
                 and all(abs(a - b) < 1e-9 for a, b in zip(logits, M.TEST_LOGITS[i])))
    # the handshake also has to survive a slow host: more clocks allowed than needed
    return good, max(clocks)


@cocotb.test()
async def driver_runs_professor_model(dut):
    await start(dut)
    good, clocks = await bridge(run)(dut)
    dut._log.info(f"professor's model through the V1 driver: {good}/{len(M.TEST_X)} golden inputs exact "
                  f"(sums, logits, class), {clocks} clocks per inference")
    assert good == len(M.TEST_X)
