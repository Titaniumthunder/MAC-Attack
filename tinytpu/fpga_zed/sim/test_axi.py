# SPDX-FileCopyrightText: © 2026 MAC Attack
# SPDX-License-Identifier: Apache-2.0
#
# Simulates tiny_tpu_axi the way the ARM will drive it on the ZedBoard: AXI4-Lite writes to CMD,
# reads of RESULT / STATUS / ID. Replays all 12 golden inferences (the same golden_vectors.json
# the chip test uses), then edge cases. Run: python run.py   (needs cocotb, cocotbext-axi, Icarus)

import json
import random
from pathlib import Path

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles
from cocotbext.axi import AxiLiteBus, AxiLiteMaster

CMD, RESULT, STATUS, ID = 0x0, 0x4, 0x8, 0xC
NOP, CLEAR, MAC, READ = 0, 1, 2, 3
VECTORS = Path(__file__).resolve().parents[2] / "chip" / "test" / "golden_vectors.json"


def word(cmd, a=0, w=0):
    return ((cmd & 3) << 8) | ((w & 0xF) << 4) | (a & 0xF)


def s32(v):
    return v - (1 << 32) if v & 0x80000000 else v


class Arm:
    def __init__(self, dut):
        self.axi = AxiLiteMaster(AxiLiteBus.from_prefix(dut, "s_axi"), dut.s_axi_aclk, dut.s_axi_aresetn,
                                 reset_active_level=False)

    async def wr(self, addr, value):
        await self.axi.write_dword(addr, value)

    async def rd(self, addr):
        return await self.axi.read_dword(addr)

    async def cmd(self, cmd, a=0, w=0):
        await self.wr(CMD, word(cmd, a, w))

    async def read(self):
        await self.cmd(READ)
        return s32(await self.rd(RESULT)), (await self.rd(STATUS)) & 1


async def start(dut):
    cocotb.start_soon(Clock(dut.s_axi_aclk, 10, unit="ns").start())    # 100 MHz
    dut.s_axi_aresetn.value = 0
    arm = Arm(dut)                       # drives the AXI inputs (valid = 0) during reset, like the interconnect
    await ClockCycles(dut.s_axi_aclk, 10)
    dut.s_axi_aresetn.value = 1
    await ClockCycles(dut.s_axi_aclk, 5)
    return arm


@cocotb.test()
async def test_golden_vectors(dut):
    arm = await start(dut)
    assert await arm.rd(ID) == 0x54505534, "ID register"
    vectors = json.loads(VECTORS.read_text())
    reads = 0
    for i, vec in enumerate(vectors):
        for op in vec["commands"]:
            if op["op"] == "CLEAR":
                await arm.cmd(CLEAR)
            elif op["op"] == "MAC":
                await arm.cmd(MAC, op["a"], op["w"])
            else:
                got, ovf = await arm.read()
                assert ovf == 0, f"vector {i}: overflow"
                assert got == op["expected_acc"], f"vector {i}: {got} != {op['expected_acc']}"
                reads += 1
    dut._log.info(f"{len(vectors)} golden inferences over AXI, {reads} READs, all exact")


@cocotb.test()
async def test_edge_cases(dut):
    arm = await start(dut)
    assert await arm.read() == (0, 0), "after reset"
    for a in range(-8, 8):
        for w in range(-8, 8):
            await arm.cmd(CLEAR)
            await arm.cmd(MAC, a, w)
            assert await arm.read() == (a * w, 0), f"{a} * {w}"
    dut._log.info("all 256 INT4 products exact")

    await arm.cmd(CLEAR)
    await arm.cmd(MAC, -7, 5)
    await arm.cmd(NOP, 7, 7)
    assert await arm.read() == (-35, 0), "NOP"
    assert await arm.rd(CMD) == word(READ), "CMD reads back the last word"

    await arm.cmd(CLEAR)
    for _ in range(668):
        await arm.cmd(MAC, 7, 7)
    assert await arm.read() == (32732, 0)
    await arm.cmd(MAC, 7, 7)
    assert (await arm.read())[1] == 1, "overflow flagged"
    await arm.cmd(CLEAR)
    assert await arm.read() == (0, 0), "CLEAR resets acc and flag"
    dut._log.info("overflow flagged and cleared")

    # Back-to-back writes without waiting for each response (the AXI master queues them)
    rng = random.Random(3)
    pairs = [(rng.randint(-7, 7), rng.randint(-7, 7)) for _ in range(64)]
    await arm.cmd(CLEAR)
    await cocotb.triggers.Combine(*[cocotb.start_soon(arm.cmd(MAC, a, w)) for a, w in pairs])
    assert await arm.read() == (sum(a * w for a, w in pairs), 0), "queued writes"
    dut._log.info("64 queued MAC writes: exact")
