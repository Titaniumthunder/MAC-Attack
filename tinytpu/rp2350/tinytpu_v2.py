# Host driver for Tiny-TPU Version 2 (tt_um_titaniumthunder_tiny_tpu_v2), MAC Attack, Apache-2.0.
#
# Runs on the RP2350 of the Tiny Tapeout demo board (MicroPython) and, unchanged, in the cocotb
# simulation (sim/). All pin access goes through a small "pins" object: tt_pins.TTPins on the board,
# sim/test_v2_driver.py's SimPins in simulation. It has five methods:
#     ui(v)       drive ui_in[7:0]
#     uio(v)      drive uio_in[7:0]
#     clock()     one clock cycle: rising edge, then back low
#     uo()        read uo_out[7:0]
#     reset()     rst_n low for a few clocks, then high
#
# How it talks to the chip: streaming mode (MODE = 1) with the RP2350 making every clock edge.
#   command:  ui_in = DATA, uio_in = {MODE, VALID, CMD}, one clock    -> the chip runs it on that edge
#   burst:    BURST n, then n clocks with ui_in = PE 0's weight, uio_in = PE 1's weight
#   read:     uio_in = {MODE, BSEL, PSEL} with VALID = 0, then read uo_out (no clock needed)
# Because the host makes every edge, it can be as slow as it likes and the chip still sees exactly one
# command per edge.

NOP, CLEAR, LOAD_X, MAC, READ, BURST, LOAD_P, POST = range(8)
VALID = 0x08          # uio_in[3]
MODE = 0x10           # uio_in[4]: 1 = streaming
PSEL = 0x80           # uio_in[7]: read PE 1
BSEL_LOW, BSEL_MID, BSEL_HIGH, BSEL_STATUS = 0, 1, 2, 3    # uio_in[6:5]

# A layer is a tuple (k, n, relu, W, BIAS, M0, SHIFT): k inputs, n outputs, W = n*k signed bytes
# neuron by neuron, then per neuron the 24-bit bias, 16-bit m0 and shift (model_v2.py has them).
K, N, RELU, W, BIAS, M0, SHIFT = range(7)


def s8(v):
    v &= 0xFF
    return v - 256 if v > 127 else v


def requant(acc, bias, m0, shift, relu):
    """The chip's POST step: clamp(((acc + bias) * m0 + 2^(shift-1)) >> shift, relu ? 0 : -128, 127)."""
    if shift > 47:
        shift = 47
    t = (acc + bias) * m0
    if shift:
        t += 1 << (shift - 1)
    t >>= shift                     # Python ints: arithmetic shift = floor, like the RTL
    if t > 127:
        return 127
    lo = 0 if relu else -128
    return lo if t < lo else t


def infer_host(layers, x, hidden=None):
    """The same integer model on the host alone (reference and fallback)."""
    a = [s8(v) for v in x]
    for i, L in enumerate(layers):
        k, n, w = L[K], L[N], L[W]
        sums = []
        for j in range(n):
            s = 0
            base = j * k
            for i2 in range(k):
                s += a[i2] * s8(w[base + i2])
            sums.append(s)
        if i == len(layers) - 1:
            return sums
        a = [requant(sums[j], L[BIAS][j], L[M0][j], L[SHIFT][j], L[RELU]) for j in range(n)]
        if hidden is not None:
            hidden.append(a)


def decode(sums, bias_last, out_scale, names):
    """Last layer's raw sums -> (status name, health %, real outputs), as in modelV2."""
    import math
    real = [(sums[j] + bias_last[j]) * out_scale[j] for j in range(len(sums))]
    best = 0
    for j in range(1, len(names)):
        if real[j] > real[best]:
            best = j
    return names[best], 100.0 / (1.0 + math.exp(-real[-1])), real


class TinyTPUv2:
    def __init__(self, pins):
        self.p = pins
        self.clocks = 0             # clock edges sent (for timing reports)

    # ------------------------------------------------------------ pin level
    def reset(self):
        self.p.ui(0)
        self.p.uio(MODE)
        self.p.reset()

    def cmd(self, c, data=0):
        """One command: DATA on ui_in, {MODE, VALID, CMD} on uio_in, one clock edge."""
        self.p.ui(data & 0xFF)
        self.p.uio(MODE | VALID | c)
        self.p.clock()
        self.clocks += 1

    def idle(self, n=1):
        """n clock edges with VALID = 0."""
        self.p.uio(MODE)
        for _ in range(n):
            self.p.clock()
        self.clocks += n

    def burst(self, w0, w1):
        """BURST: PE 0 gets w0[i], PE 1 gets w1[i] on the same clock edge, one pair per edge."""
        n = len(w0)
        if n == 0:
            return
        self.cmd(BURST, n)
        p = self.p
        for i in range(n):
            p.ui(w0[i] & 0xFF)
            p.uio(w1[i] & 0xFF)
            p.clock()
        self.clocks += n
        p.uio(MODE)                 # the pins are commands again; VALID = 0

    def byte(self, bsel, pe):
        self.p.uio(MODE | (bsel << 5) | (PSEL if pe else 0))
        return self.p.uo()

    def result(self, pe):
        """The 22-bit raw sum latched by READ (signed)."""
        v = self.byte(BSEL_LOW, pe) | (self.byte(BSEL_MID, pe) << 8) | ((self.byte(BSEL_HIGH, pe) & 0x3F) << 16)
        return v - (1 << 22) if v & (1 << 21) else v

    def output(self, pe):
        """The 8-bit output of the last POST (signed)."""
        return s8(self.byte(BSEL_LOW, pe))

    def status(self):
        """(ack, input position, ovf0, ovf1)"""
        s = self.byte(BSEL_STATUS, 0)
        return s >> 7, (s >> 2) & 31, s & 1, (s >> 1) & 1

    # ------------------------------------------------------------ model level
    def load_inputs(self, x):
        self.cmd(CLEAR)
        for v in x:
            self.cmd(LOAD_X, v)

    def _params(self, L, j):
        """12 LOAD_P bytes: per PE bias (3 bytes), m0 (2), shift (1); PE 1 gets zeros for an odd last neuron."""
        for jj in (j, j + 1):
            if jj < L[N]:
                b, m, s = L[BIAS][jj] & 0xFFFFFF, L[M0][jj], L[SHIFT][jj]
            else:
                b = m = s = 0
            for byte in (b, b >> 8, b >> 16, m, m >> 8, s):
                self.cmd(LOAD_P, byte)

    def _weights(self, L, j):
        k, w = L[K], L[W]
        w0 = w[j * k:(j + 1) * k]
        w1 = w[(j + 1) * k:(j + 2) * k] if j + 1 < L[N] else bytes(k)
        return w0, w1

    def layer_on_chip(self, L, read_back=False):
        """A hidden layer with bias / rescale / ReLU on chip. The inputs must already be in the chip; the
        outputs go to the other buffer and become the next layer's inputs (CLEAR with DATA = 1 at the end).
        read_back = True also reads every output, to check it."""
        n = L[N]
        out = [] if read_back else None
        for j in range(0, n, 2):
            single = j + 1 >= n
            self.cmd(CLEAR)
            self._params(L, j)
            self.burst(*self._weights(L, j))
            self.cmd(POST, (1 if L[RELU] else 0) | (2 if single else 0))
            self.idle(3)            # POST: y0 is in place 2 edges later, y1 3 edges later
            if read_back:
                out.append(self.output(0))
                if not single:
                    out.append(self.output(1))
        self.cmd(CLEAR, 1)          # next layer: the outputs become the inputs
        return out

    def layer_sums(self, L):
        """A layer in bypass mode: raw 22-bit sums out (READ). The inputs must already be in the chip."""
        sums = []
        for j in range(0, L[N], 2):
            self.cmd(CLEAR)
            self.burst(*self._weights(L, j))
            self.cmd(READ)
            sums.append(self.result(0))
            if j + 1 < L[N]:
                sums.append(self.result(1))
        return sums

    def infer(self, layers, x, hidden=None):
        """One inference: hidden layers on chip, last layer raw sums.
        hidden = [] collects each hidden layer's outputs (read back from the chip)."""
        self.load_inputs(x)
        for L in layers[:-1]:
            ys = self.layer_on_chip(L, hidden is not None)
            if hidden is not None:
                hidden.append(ys)
        return self.layer_sums(layers[-1])

    def infer_bypass(self, layers, x):
        """One inference with every layer in bypass mode: the host does bias / rescale / ReLU."""
        a = list(x)
        for i, L in enumerate(layers):
            self.load_inputs(a)
            sums = self.layer_sums(L)
            if i == len(layers) - 1:
                return sums
            a = [requant(sums[j], L[BIAS][j], L[M0][j], L[SHIFT][j], L[RELU]) for j in range(L[N])]
