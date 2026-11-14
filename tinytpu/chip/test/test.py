# SPDX-FileCopyrightText: © 2026 MAC Attack
# SPDX-License-Identifier: Apache-2.0
#
# Plays the host (the RP2040) on the chip's pins with the STROBE/ACK handshake from project.v,
# and checks the chip against the professor's golden vectors (golden_vectors.json, exported by
# the RSCL Tiny-TPU pipeline): every CLEAR / MAC / READ of 12 full 8-4-2 inferences, and every
# READ must return exactly the expected 16-bit accumulator. Plus edge cases: signs, -8,
# overflow flag, CLEAR, NOP, and slow/fast host timing.

import json
import random
from pathlib import Path

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge, Timer

NOP, CLEAR, MAC, READ = 0, 1, 2, 3
OPS = {"CLEAR": CLEAR, "MAC": MAC, "READ": READ}
VECTORS = Path(__file__).with_name("golden_vectors.json")


class Host:
    def __init__(self, dut, hold=0):
        self.dut = dut
        self.hold = hold                     # extra clocks the host waits between steps

    def _uio(self, cmd, strobe, hi):
        return (cmd & 3) | (strobe << 2) | (hi << 3)

    async def _wait_ack(self, level, limit=50):
        for _ in range(limit):
            await RisingEdge(self.dut.clk)
            await Timer(1, unit="ns")
            if int(self.dut.uio_out.value) >> 4 & 1 == level:
                return
        raise AssertionError(f"ACK never went {level}")

    async def command(self, cmd, a=0, w=0):
        dut = self.dut
        dut.ui_in.value = ((w & 0xF) << 4) | (a & 0xF)
        dut.uio_in.value = self._uio(cmd, 0, 0)
        await ClockCycles(dut.clk, 1 + self.hold)
        dut.uio_in.value = self._uio(cmd, 1, 0)          # STROBE up
        await self._wait_ack(1)
        await ClockCycles(dut.clk, self.hold)
        dut.uio_in.value = self._uio(cmd, 0, 0)          # STROBE down
        await self._wait_ack(0)

    async def read(self):
        """READ, then the two result bytes (HI = 0, then 1). Returns (signed value, ovf)."""
        await self.command(READ)
        dut = self.dut
        dut.uio_in.value = self._uio(NOP, 0, 0)
        await Timer(1, unit="ns")
        lo = int(dut.uo_out.value)
        dut.uio_in.value = self._uio(NOP, 0, 1)
        await Timer(1, unit="ns")
        hi = int(dut.uo_out.value)
        dut.uio_in.value = self._uio(NOP, 0, 0)
        v = (hi << 8) | lo
        if v & 0x8000:
            v -= 1 << 16
        ovf = int(dut.uio_out.value) >> 5 & 1
        return v, ovf


async def reset(dut):
    cocotb.start_soon(Clock(dut.clk, 20, unit="ns").start())   # 50 MHz
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 5)


@cocotb.test()
async def test_golden_vectors(dut):
    """All 12 inferences from golden_vectors.json, command by command."""
    await reset(dut)
    host = Host(dut)
    vectors = json.loads(VECTORS.read_text())
    reads = 0
    for i, vec in enumerate(vectors):
        for op in vec["commands"]:
            if op["op"] == "CLEAR":
                await host.command(CLEAR)
            elif op["op"] == "MAC":
                await host.command(MAC, op["a"], op["w"])
            else:
                got, ovf = await host.read()
                assert ovf == 0, f"vector {i}: unexpected overflow"
                assert got == op["expected_acc"], f"vector {i}: READ {got}, expected {op['expected_acc']}"
                reads += 1
    dut._log.info(f"{len(vectors)} golden inferences, {reads} READs, all accumulators exact")


@cocotb.test()
async def test_edge_cases(dut):
    """Signs, -8, overflow flag, CLEAR clears it, NOP changes nothing, slow host."""
    await reset(dut)
    host = Host(dut)

    assert (await host.read()) == (0, 0), "after reset"

    # every signed product, -8..7 x -8..7, one at a time
    for a in range(-8, 8):
        for w in range(-8, 8):
            await host.command(CLEAR)
            await host.command(MAC, a, w)
            assert (await host.read()) == (a * w, 0), f"{a} * {w}"
    dut._log.info("all 256 signed INT4 products exact")

    # NOP does nothing
    await host.command(CLEAR)
    await host.command(MAC, -7, 5)
    await host.command(NOP, 7, 7)
    assert (await host.read()) == (-35, 0)

    # largest legal sum: 668 x (7*7) = 32732 fits; one more 7*7 overflows the 16-bit accumulator
    await host.command(CLEAR)
    for _ in range(668):
        await host.command(MAC, 7, 7)
    assert (await host.read()) == (32732, 0)
    await host.command(MAC, 7, 7)
    v, ovf = await host.read()
    assert ovf == 1, "overflow must be flagged"
    await host.command(MAC, -7, 7)                     # stays flagged (sticky)
    assert (await host.read())[1] == 1
    await host.command(CLEAR)
    assert (await host.read()) == (0, 0), "CLEAR resets acc and the flag"
    dut._log.info("overflow is flagged, sticky, and cleared by CLEAR")

    # a slow host (long holds between steps) gets the same answers
    slow = Host(dut, hold=7)
    rng = random.Random(7)
    pairs = [(rng.randint(-7, 7), rng.randint(-7, 7)) for _ in range(20)]
    await slow.command(CLEAR)
    for a, w in pairs:
        await slow.command(MAC, a, w)
    assert (await slow.read()) == (sum(a * w for a, w in pairs), 0)
    dut._log.info("slow host: same result")
