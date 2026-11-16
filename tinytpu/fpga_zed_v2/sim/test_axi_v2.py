# SPDX-FileCopyrightText: © 2026 MAC Attack
# SPDX-License-Identifier: Apache-2.0
#
# Simulates tiny_tpu_v2_axi (the ZedBoard top for Tiny-TPU Version 2) with a standard AXI4-Lite master
# (cocotbext-axi), the way the ARM drives it:
#   1. modelV2 13-32-16-4 on chip, all 64 reference rows, through the registers (same steps as
#      sw/tinytpu_v2_test.c): every POST output = Python's requantization, every final sum = vectors_C.
#   2. The wrapper's timing contract: a write's response comes back only after its steps are done, and
#      after a POST only once both outputs are in place (so the ARM never polls).
#   3. Registers: ID, STEPS, STATUS, and writes / reads to unused addresses do nothing.
# Run: python run.py   (needs cocotb, cocotbext-axi, Icarus Verilog)

import json
from pathlib import Path

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge
from cocotbext.axi import AxiLiteBus, AxiLiteMaster

CMD, PAIR, PAIR2, LOADX4, LOADP4, RES0, RES1, STATUS, ID, STEPS = range(0, 0x28, 4)
NOP, CLEAR, LOAD_X, MAC, READ, _, LOAD_P, POST = range(8)
MODEL = Path(__file__).resolve().parents[2] / "chip_v2" / "test" / "modelV2"


def u8(v):
    return v & 0xFF


def s32(v):
    return v - (1 << 32) if v & 0x80000000 else v


def pack4(b0, b1=0, b2=0, b3=0):
    return u8(b0) | (u8(b1) << 8) | (u8(b2) << 16) | (u8(b3) << 24)


def post_ref(acc, bias, m0, sh, relu):
    sh = min(sh, 47)
    y = ((acc + bias) * m0 + ((1 << (sh - 1)) if sh else 0)) >> sh
    return max(0 if relu else -128, min(127, y))


def load_modelv2():
    q = json.loads((MODEL / "quant.json").read_text())
    sizes, layers = q["sizes"], q["layers"]
    xs = [int(t, 16) for t in (MODEL / "vectors_X.hex").read_text().split()]
    xs = [v - 256 if v > 127 else v for v in xs]
    cs = [int(t, 16) for t in (MODEL / "vectors_C.hex").read_text().split()]
    cs = [v - (1 << 22) if v & (1 << 21) else v for v in cs]
    X = [xs[r * sizes[0]:(r + 1) * sizes[0]] for r in range(len(xs) // sizes[0])]
    C = [cs[r * sizes[-1]:(r + 1) * sizes[-1]] for r in range(len(cs) // sizes[-1])]
    for L in layers:
        L["cols"] = [[L["W"][k][j] for k in range(len(L["W"]))] for j in range(len(L["W"][0]))]
    return layers, sizes, X, C


class Arm:
    """The ARM's side: the same register steps as sw/tinytpu_v2_test.c."""

    def __init__(self, dut):
        self.axi = AxiLiteMaster(AxiLiteBus.from_prefix(dut, "s_axi"), dut.s_axi_aclk, dut.s_axi_aresetn,
                                 reset_active_level=False)

    async def wr(self, addr, value):
        await self.axi.write_dword(addr, value)

    async def rd(self, addr):
        return await self.axi.read_dword(addr)

    async def cmd(self, c, data=0):
        await self.wr(CMD, ((c & 7) << 8) | u8(data))

    async def result(self, pe):
        return s32(await self.rd(RES1 if pe else RES0))

    async def load_inputs(self, x):
        await self.cmd(CLEAR)
        i = 0
        while i + 4 <= len(x):
            await self.wr(LOADX4, pack4(*x[i:i + 4]))
            i += 4
        for v in x[i:]:
            await self.cmd(LOAD_X, v)

    async def weights(self, w0, w1):
        i = 0
        while i + 2 <= len(w0):
            await self.wr(PAIR2, pack4(w0[i], w1[i], w0[i + 1], w1[i + 1]))
            i += 2
        if i < len(w0):
            await self.wr(PAIR, pack4(w0[i], w1[i]))

    async def params(self, p0, p1):
        b = []
        for bias, m0, sh in (p0, p1):
            bias &= 0xFFFFFF
            b += [bias & 0xFF, (bias >> 8) & 0xFF, bias >> 16, m0 & 0xFF, m0 >> 8, sh]
        for i in range(0, 12, 4):
            await self.wr(LOADP4, pack4(*b[i:i + 4]))

    async def layer_post(self, L):
        ys = []
        n = len(L["cols"])
        for j in range(0, n, 2):
            single = j + 1 >= n
            w0 = L["cols"][j]
            w1 = L["cols"][j + 1] if not single else [0] * len(w0)
            p0 = (L["bias"][j], L["m0"][j], L["shift"][j])
            p1 = (L["bias"][j + 1], L["m0"][j + 1], L["shift"][j + 1]) if not single else (0, 0, 0)
            await self.cmd(CLEAR)
            await self.params(p0, p1)
            await self.weights(w0, w1)
            await self.cmd(POST, (1 if L["relu"] else 0) | (2 if single else 0))
            assert (await self.rd(STATUS)) & 3 == 0, "overflow"
            ys.append(await self.result(0))
            if not single:
                ys.append(await self.result(1))
        await self.cmd(CLEAR, 1)
        return ys

    async def layer_read(self, cols):
        sums = []
        for j in range(0, len(cols), 2):
            w0 = cols[j]
            w1 = cols[j + 1] if j + 1 < len(cols) else [0] * len(w0)
            await self.cmd(CLEAR)
            await self.weights(w0, w1)
            await self.cmd(READ)
            sums.append(await self.result(0))
            if j + 1 < len(cols):
                sums.append(await self.result(1))
        return sums


async def start(dut):
    cocotb.start_soon(Clock(dut.s_axi_aclk, 10, unit="ns").start())    # 100 MHz
    dut.s_axi_aresetn.value = 0
    arm = Arm(dut)                       # drives the AXI inputs (valid = 0) during reset, like the interconnect
    await ClockCycles(dut.s_axi_aclk, 10)
    dut.s_axi_aresetn.value = 1
    await ClockCycles(dut.s_axi_aclk, 5)
    return arm


@cocotb.test()
async def test_modelv2_on_chip(dut):
    arm = await start(dut)
    layers, sizes, X, C = load_modelv2()
    posts = 0
    for r, (x, c) in enumerate(zip(X, C)):
        await arm.load_inputs(x)
        a = x
        for li, L in enumerate(layers[:-1]):
            sums = [sum(p * q for p, q in zip(a, col)) for col in L["cols"]]
            expect = [post_ref(s, L["bias"][j], L["m0"][j], L["shift"][j], L["relu"]) for j, s in enumerate(sums)]
            ys = await arm.layer_post(L)
            assert ys == expect, f"row {r} layer {li}: {ys} != {expect}"
            posts += len(ys)
            a = expect
        got = await arm.layer_read(layers[-1]["cols"])
        assert got == c, f"row {r}: {got} != {c}"
    dut._log.info(f"modelV2 {'-'.join(map(str, sizes))} over AXI: {len(X)} rows, {posts} POST outputs and "
                  f"{len(X) * sizes[-1]} final sums exact")


async def response_clocks(dut, arm, addr, value):
    """Clocks from the write's first valid clock to its response handshake."""
    count = 0
    done = False

    async def counter():
        nonlocal count
        while not done:
            await RisingEdge(dut.s_axi_aclk)
            count += 1

    task = cocotb.start_soon(counter())
    await arm.wr(addr, value)
    done = True
    await RisingEdge(dut.s_axi_aclk)
    task.cancel()
    return count


@cocotb.test()
async def test_timing_contract(dut):
    arm = await start(dut)
    base = await response_clocks(dut, arm, CMD, NOP << 8)
    pair = await response_clocks(dut, arm, PAIR2, 0)
    loadx = await response_clocks(dut, arm, LOADX4, 0)
    post = await response_clocks(dut, arm, CMD, (POST << 8) | 0)
    dut._log.info(f"write response after: 1 step {base}, PAIR2 {pair}, LOADX4 {loadx}, POST {post} clocks")
    assert pair == base + 1, "PAIR2 = 2 steps"
    assert loadx == base + 3, "LOADX4 = 4 steps"
    assert post >= base + 3, "after a POST the response waits until both outputs are in place"

    # a POST's outputs are there for the very next access, with no idle time in between
    x, w0, w1 = [10, -3, 7], [5, 2, -1], [-4, 6, 3]
    p0, p1 = (100, 30000, 8), (-50, 45000, 9)
    await arm.load_inputs(x)
    await arm.cmd(CLEAR)
    await arm.params(p0, p1)
    await arm.weights(w0, w1)
    await arm.cmd(POST, 0)
    y1 = await arm.result(1)                     # PE 1's output lands last
    y0 = await arm.result(0)
    s0, s1 = sum(a * b for a, b in zip(x, w0)), sum(a * b for a, b in zip(x, w1))
    assert (y0, y1) == (post_ref(s0, *p0, False), post_ref(s1, *p1, False))
    dut._log.info("POST outputs readable on the very next access")


@cocotb.test()
async def test_registers(dut):
    arm = await start(dut)
    assert await arm.rd(ID) == 0x54505538, "ID"
    s0 = await arm.rd(STEPS)
    await arm.cmd(CLEAR)
    await arm.wr(LOADX4, pack4(1, 2, 3, 4))
    await arm.cmd(CLEAR)
    await arm.wr(PAIR2, pack4(1, 1, 1, 1))
    await arm.wr(PAIR, pack4(1, 1))
    assert await arm.rd(STEPS) - s0 == 1 + 4 + 1 + 2 + 1, "STEPS counts core steps"
    assert ((await arm.rd(STATUS)) >> 2) & 31 == 3, "input position after 3 dual MACs"
    await arm.cmd(READ)
    assert (await arm.result(0), await arm.result(1)) == (6, 6), "1+2+3 on both PEs"
    s1 = await arm.rd(STEPS)
    for addr in (RES0, RES1, STATUS, ID, STEPS, 0x28, 0x3C):           # read-only / unused: no steps
        await arm.wr(addr, 0xFFFFFFFF)
    assert await arm.rd(STEPS) == s1, "writes to read-only or unused addresses do nothing"
    for addr in (CMD, PAIR, PAIR2, LOADX4, LOADP4, 0x28, 0x3C):
        assert await arm.rd(addr) == 0, f"0x{addr:02X} reads 0"
    assert (await arm.result(0), await arm.result(1)) == (6, 6)
    dut._log.info("ID, STEPS, STATUS position, unused addresses: as documented")
