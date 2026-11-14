# SPDX-FileCopyrightText: © 2026 MAC Attack
# SPDX-License-Identifier: Apache-2.0
#
# Tiny-TPU Version 2 tests. The test plays the host (the RP2040) and must match the references exactly:
#   1. our modelV2 INT8 13-32-16-4 run ON CHIP: hidden layers use POST (bias + rescale + ReLU on chip)
#      and their outputs stay in the chip's buffers; only the last layer's raw sums come out (READ).
#      Every POST output = Python's integer requantization; every final sum = vectors_C.hex (64 rows).
#   2. the same model in bypass mode (READ every layer, host does the requantization).
#   3. the professor's INT4 8-4-2 (golden_vectors.json) in bypass mode, burst and handshake.
#   4. random layers with random bias / m0 / shift / ReLU (POST fuzz), reading the stored outputs
#      back through the array with one-hot weights; plus edge cases from the 2-PE design.

import json
import random
from pathlib import Path

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, FallingEdge, RisingEdge, Timer

NOP, CLEAR, LOAD_X, MAC, READ, BURST, LOAD_P, POST = range(8)
HERE = Path(__file__).parent
ACC = 22


def u8(v):
    return v & 0xFF


def post_ref(acc, bias, m0, sh, relu):
    """The on-chip POST, in Python (= modelV2 requant / FPGA postproc; shift capped at 47)."""
    sh = min(sh, 47)
    y = ((acc + bias) * m0 + ((1 << (sh - 1)) if sh else 0)) >> sh
    return max(0 if relu else -128, min(127, y))


class Host:
    def __init__(self, dut, mode):
        self.dut = dut
        self.mode = mode
        self.clocks = 0

    def _uio(self, cmd=NOP, strobe=0, bsel=0, psel=0):
        return (cmd & 7) | (strobe << 3) | (self.mode << 4) | (bsel << 5) | (psel << 7)

    # ---- streaming: one (ui, uio) slot per clock
    async def stream(self, slots):
        dut = self.dut
        for ui, uio in slots:
            await FallingEdge(dut.clk)
            dut.ui_in.value = ui
            dut.uio_in.value = uio
        await FallingEdge(dut.clk)
        dut.ui_in.value = 0
        dut.uio_in.value = self._uio()
        await ClockCycles(dut.clk, 3)            # idle clocks: a POST's two results land within 3 edges
        await FallingEdge(dut.clk)
        self.clocks += len(slots)

    def cmd(self, c, data=0):
        return (u8(data), self._uio(c, 1))

    def burst(self, w0s, w1s):
        return [self.cmd(BURST, len(w0s))] + [(u8(a), u8(b)) for a, b in zip(w0s, w1s)]

    def params(self, p0, p1):
        out = []
        for bias, m0, sh in (p0, p1):
            b = bias & 0xFFFFFF
            out += [self.cmd(LOAD_P, b & 0xFF), self.cmd(LOAD_P, b >> 8), self.cmd(LOAD_P, b >> 16),
                    self.cmd(LOAD_P, m0 & 0xFF), self.cmd(LOAD_P, m0 >> 8), self.cmd(LOAD_P, sh)]
        return out

    # ---- handshake (MODE 0): ACK is status bit 7, BSEL = 3 while waiting
    async def handshake(self, ops):
        dut = self.dut
        for c, data in ops:
            dut.ui_in.value = u8(data)
            dut.uio_in.value = self._uio(c, 0, bsel=3)
            await ClockCycles(dut.clk, 1)
            dut.uio_in.value = self._uio(c, 1, bsel=3)
            await self._ack(1)
            dut.uio_in.value = self._uio(c, 0, bsel=3)
            await self._ack(0)

    async def _ack(self, level):
        for _ in range(50):
            await RisingEdge(self.dut.clk)
            await Timer(1, unit="ns")
            if int(self.dut.uo_out.value) >> 7 == level:
                return
        raise AssertionError(f"ACK never went {level}")

    # ---- reading the result registers
    async def _byte(self, bsel, psel=0):
        self.dut.uio_in.value = self._uio(NOP, 0, bsel, psel)
        await Timer(1, unit="ns")
        v = int(self.dut.uo_out.value)
        self.dut.uio_in.value = self._uio()
        return v

    async def result(self, pe):
        b0, b1, b2 = await self._byte(0, pe), await self._byte(1, pe), await self._byte(2, pe)
        v = b0 | (b1 << 8) | ((b2 & 0x3F) << 16)
        return v - (1 << ACC) if v & (1 << (ACC - 1)) else v

    async def status(self):
        s = await self._byte(3)
        return {"ack": s >> 7, "ptr": (s >> 2) & 31, "ovf1": (s >> 1) & 1, "ovf0": s & 1}

    # ---- building blocks (streaming)
    async def load_inputs(self, x):
        await self.stream([self.cmd(CLEAR)] + [self.cmd(LOAD_X, v) for v in x])

    async def layer_post(self, cols, params, relu):
        """Inputs already in the chip. Every neuron pair: CLEAR, LOAD_P x 12, BURST, POST.
        Returns the POST outputs as read from the result registers. Then swaps buffers (next layer)."""
        ys = []
        for j in range(0, len(cols), 2):
            single = j + 1 >= len(cols)
            w0, p0 = cols[j], params[j]
            w1, p1 = (cols[j + 1], params[j + 1]) if not single else ([0] * len(w0), (0, 0, 0))
            await self.stream([self.cmd(CLEAR)] + self.params(p0, p1) + self.burst(w0, w1)
                              + [self.cmd(POST, (1 if relu else 0) | (2 if single else 0))])
            st = await self.status()
            assert st["ovf0"] == 0 and st["ovf1"] == 0, "unexpected overflow"
            ys.append(await self.result(0))
            if not single:
                ys.append(await self.result(1))
        await self.stream([self.cmd(CLEAR, 1)])                   # next layer: outputs become inputs
        return ys

    async def layer_read(self, cols):
        """Inputs already in the chip. Every neuron pair: CLEAR, BURST, READ (raw sums, bypass)."""
        sums = []
        for j in range(0, len(cols), 2):
            w0 = cols[j]
            w1 = cols[j + 1] if j + 1 < len(cols) else [0] * len(w0)
            await self.stream([self.cmd(CLEAR)] + self.burst(w0, w1) + [self.cmd(READ)])
            st = await self.status()
            assert st["ovf0"] == 0 and st["ovf1"] == 0, "unexpected overflow"
            sums.append(await self.result(0))
            if j + 1 < len(cols):
                sums.append(await self.result(1))
        return sums

    async def layer_handshake(self, x, cols):
        await self.handshake([(CLEAR, 0)] + [(LOAD_X, v) for v in x])
        sums = []
        for wj in cols:
            await self.handshake([(CLEAR, 0)] + [(MAC, w) for w in wj] + [(READ, 0)])
            sums.append(await self.result(0))
        return sums


async def reset(dut):
    cocotb.start_soon(Clock(dut.clk, 20, unit="ns").start())   # 50 MHz
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 5)


def load_modelv2():
    q = json.loads((HERE / "modelV2" / "quant.json").read_text())
    layers = q["layers"]
    if isinstance(layers, str):
        import ast
        layers = ast.literal_eval(layers)
    sizes = q["sizes"]
    xs = [int(l, 16) for l in (HERE / "modelV2" / "vectors_X.hex").read_text().split()]
    xs = [v - 256 if v > 127 else v for v in xs]
    X = [xs[r * sizes[0]:(r + 1) * sizes[0]] for r in range(len(xs) // sizes[0])]
    cs = [int(l, 16) for l in (HERE / "modelV2" / "vectors_C.hex").read_text().split()]
    cs = [v - (1 << 22) if v & (1 << 21) else v for v in cs]
    C = [cs[r * sizes[-1]:(r + 1) * sizes[-1]] for r in range(len(cs) // sizes[-1])]
    return layers, sizes, X, C


def columns(L):
    W = L["W"]                                                   # K x N
    return [[W[k][j] for k in range(len(W))] for j in range(len(W[0]))]


@cocotb.test()
async def test_modelv2_on_chip(dut):
    """modelV2 with the hidden layers post-processed ON CHIP; only the final raw sums come out."""
    await reset(dut)
    host = Host(dut, mode=1)
    layers, sizes, X, C = load_modelv2()
    posts = 0
    for r, (x, c) in enumerate(zip(X, C)):
        await host.load_inputs(x)
        a = x
        for li, L in enumerate(layers[:-1]):
            cols = columns(L)
            sums = [sum(p * q for p, q in zip(a, col)) for col in cols]
            expect = [post_ref(s, L["bias"][j], L["m0"][j], L["shift"][j], L["relu"]) for j, s in enumerate(sums)]
            params = [(L["bias"][j], L["m0"][j], L["shift"][j]) for j in range(len(cols))]
            ys = await host.layer_post(cols, params, L["relu"])
            assert ys == expect, f"row {r} layer {li}: POST {ys} != {expect}"
            posts += len(ys)
            a = expect
        got = await host.layer_read(columns(layers[-1]))
        assert got == c, f"row {r}: {got} != {c}"
    dut._log.info(f"modelV2 {'-'.join(map(str, sizes))} on chip: {len(X)} rows, {posts} POST outputs and "
                  f"{len(X) * sizes[-1]} final sums exact; {host.clocks // len(X)} clocks per inference")


@cocotb.test()
async def test_modelv2_bypass(dut):
    """The same model with READ every layer and the host doing the requantization (bypass)."""
    await reset(dut)
    host = Host(dut, mode=1)
    layers, _, X, C = load_modelv2()
    for r in range(16):
        a = X[r]
        for li, L in enumerate(layers):
            await host.load_inputs(a)
            sums = await host.layer_read(columns(L))
            if li == len(layers) - 1:
                assert sums == C[r], f"row {r}"
            else:
                a = [post_ref(s, L["bias"][j], L["m0"][j], L["shift"][j], L["relu"]) for j, s in enumerate(sums)]
    dut._log.info("modelV2 in bypass mode: rows 0-15 exact")


def professor_layers(vec):
    neurons, cur = [], None
    for op in vec["commands"]:
        if op["op"] == "CLEAR":
            cur = {"layer": op["layer"], "a": [], "w": []}
        elif op["op"] == "MAC":
            cur["a"].append(op["a"])
            cur["w"].append(op["w"])
        else:
            cur["expected"] = op["expected_acc"]
            neurons.append(cur)
    out = []
    for layer in sorted({n["layer"] for n in neurons}):
        ns = [n for n in neurons if n["layer"] == layer]
        out.append((ns[0]["a"], [n["w"] for n in ns], [n["expected"] for n in ns]))
    return out


@cocotb.test()
async def test_professor_int4_bypass(dut):
    """The professor's INT4 model: his host math is floating point, so it runs in bypass mode."""
    await reset(dut)
    vectors = json.loads((HERE / "golden_vectors.json").read_text())
    for mode in (1, 0):
        host = Host(dut, mode)
        n = 0
        for i, vec in enumerate(vectors):
            for x, cols, expected in professor_layers(vec):
                if mode == 1:
                    await host.load_inputs(x)
                    got = await host.layer_read(cols)
                else:
                    got = await host.layer_handshake(x, cols)
                assert got == expected, f"mode {mode} vector {i}: {got} != {expected}"
                n += len(expected)
        dut._log.info(f"professor's INT4 model, {'burst' if mode else 'handshake'}: {n} sums exact")


@cocotb.test()
async def test_post_fuzz(dut):
    """Random layers with random bias / m0 / shift / ReLU; the stored outputs are read back through the
    array with one-hot weights, so both the POST math and the buffer swap are checked."""
    await reset(dut)
    host = Host(dut, mode=1)
    rng = random.Random(11)
    checked = 0
    for trial in range(60):
        k = rng.randint(1, 32)
        n = rng.randint(1, 32)
        x = [rng.randint(-128, 127) for _ in range(k)]
        cols = [[rng.randint(-128, 127) for _ in range(k)] for _ in range(n)]
        relu = rng.random() < 0.5
        params = []
        for _ in range(n):
            sh = rng.choice([0, 1, 2, rng.randint(3, 30), rng.randint(31, 47), 47])
            params.append((rng.randint(-(1 << 23), (1 << 23) - 1), rng.randint(0, 65535), sh))
        await host.load_inputs(x)
        ys = await host.layer_post(cols, params, relu)
        sums = [sum(p * q for p, q in zip(x, c)) for c in cols]
        expect = [post_ref(s, *params[j], relu) for j, s in enumerate(sums)]
        assert ys == expect, f"trial {trial}: {ys} != {expect}"
        # read the stored outputs back: one-hot weight columns over the n stored values
        onehot = [[1 if i == j else 0 for i in range(n)] for j in range(n)]
        assert await host.layer_read(onehot) == expect, f"trial {trial}: stored outputs differ"
        checked += n
    dut._log.info(f"POST fuzz: 60 random layers, {checked} outputs exact in the registers and in the buffer")


@cocotb.test()
async def test_edge_cases(dut):
    await reset(dut)
    host = Host(dut, mode=1)
    rng = random.Random(9)

    for _ in range(200):
        x, w0, w1 = (rng.randint(-128, 127) for _ in range(3))
        await host.stream([host.cmd(CLEAR), host.cmd(LOAD_X, x), host.cmd(CLEAR)] + host.burst([w0], [w1])
                          + [host.cmd(READ)])
        assert (await host.result(0), await host.result(1)) == (x * w0, x * w1)
    dut._log.info("both PEs: 200 products exact")

    # per-PE overflow flags
    await host.stream([host.cmd(CLEAR)] + [host.cmd(LOAD_X, -128)] * 32 + [host.cmd(CLEAR)]
                      + host.burst([-128] * 32, [1] * 32) * 4 + [host.cmd(READ)])
    st = await host.status()
    assert st["ovf0"] == 1 and st["ovf1"] == 0
    await host.stream([host.cmd(CLEAR)])
    st = await host.status()
    assert st["ovf0"] == 0 and st["ovf1"] == 0
    dut._log.info("overflow flags per PE, cleared by CLEAR")

    # a POST while the unit is busy is ignored; one 4 clocks later is taken (outputs at 0,1 then 2,3),
    # and a CLEAR / next layer right after a POST does not disturb it
    x = [10, -3, 7]
    w0, w1 = [5, 2, -1], [-4, 6, 3]
    p0, p1 = (100, 30000, 8), (-50, 45000, 9)
    await host.load_inputs(x)
    await host.stream([host.cmd(CLEAR)] + host.params(p0, p1) + host.burst(w0, w1)
                      + [host.cmd(POST, 0), host.cmd(POST, 0), host.cmd(NOP), host.cmd(NOP), host.cmd(POST, 0),
                         host.cmd(CLEAR, 1)])
    s0, s1 = sum(a * b for a, b in zip(x, w0)), sum(a * b for a, b in zip(x, w1))
    e = [post_ref(s0, *p0, False), post_ref(s1, *p1, False)] * 2
    assert await host.layer_read([[1 if i == j else 0 for i in range(4)] for j in range(4)]) == e
    dut._log.info("POST while busy ignored, POST 4 clocks later taken, CLEAR right after a POST is safe")

    # handshake mode can run POST too (PE 0 only), and BURST is ignored there
    hs = Host(dut, mode=0)
    await hs.handshake([(CLEAR, 0), (LOAD_X, 9), (CLEAR, 0), (BURST, 4)])
    assert (await hs.status())["ptr"] == 0, "BURST does nothing in handshake mode"
    await hs.handshake([(MAC, -7)] + [(LOAD_P, b) for b in (5, 0, 0, 0, 1, 1)] + [(LOAD_P, 0)] * 6
                       + [(POST, 2)])
    await ClockCycles(dut.clk, 2)
    assert await hs.result(0) == post_ref(-63, 5, 256, 1, False), "POST in handshake mode"
    dut._log.info("handshake mode: MAC + LOAD_P + POST work, BURST ignored")
