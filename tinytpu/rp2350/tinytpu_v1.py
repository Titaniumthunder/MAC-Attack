# Host driver for Tiny-TPU Version 1 (tt_um_titaniumthunder_tiny_tpu, the professor's design),
# MAC Attack, Apache-2.0.
#
# Runs on the RP2350 of the Tiny Tapeout demo board (MicroPython) and, unchanged, in the cocotb
# simulation (sim/). Pin access goes through a "pins" object (see tinytpu_v2.py); Version 1 also
# needs uio_out() to read ACK and OVF, which the chip drives on uio[4] and uio[5].
#
# How it talks to the chip: the 4-phase handshake of chip/src/project.v, with the RP2350 making the
# clock edges:
#   1. operands on ui_in ({w, a}), command on uio_in[1:0]
#   2. STROBE (uio_in[2]) = 1, clock until ACK (uio_out[4]) = 1     -> the command has run
#   3. STROBE = 0, clock until ACK = 0                              -> ready for the next one
# Reading: uio_in[3] (HI) picks the result byte on uo_out, no clock needed.
# The professor's model is INT4 and the host does the rest in floating point (scale, bias, ReLU,
# requantize, argmax), exactly as pipeline.py / fpga_zed/sw/tinytpu_test.c.

NOP, CLEAR, MAC, READ = 0, 1, 2, 3
STROBE = 0x04         # uio_in[2]
HI = 0x08             # uio_in[3]
ACK = 0x10            # uio_out[4]
OVF = 0x20            # uio_out[5]
UIO_DRIVE = 0x0F      # the host drives uio[3:0]; the chip drives uio[5:4]


class NoAck(Exception):
    pass


class TinyTPUv1:
    def __init__(self, pins, max_clocks=10):
        self.p = pins
        self.max_clocks = max_clocks
        self.clocks = 0

    def reset(self):
        self.p.ui(0)
        self.p.uio(0)
        self.p.reset()

    def _wait_ack(self, level):
        for _ in range(self.max_clocks):
            self.p.clock()
            self.clocks += 1
            if ((self.p.uio_out() & ACK) != 0) == level:
                return
        raise NoAck("ACK did not go to %d" % level)

    def cmd(self, c, a=0, w=0):
        p = self.p
        p.ui(((w & 0xF) << 4) | (a & 0xF))
        p.uio(c)                    # operands and command first, STROBE still 0
        p.uio(c | STROBE)
        self._wait_ack(1)
        p.uio(c)
        self._wait_ack(0)

    def read(self):
        """READ, then (16-bit signed sum, sticky overflow flag)."""
        self.cmd(READ)
        self.p.uio(0)
        lo = self.p.uo()
        self.p.uio(HI)
        hi = self.p.uo()
        v = lo | (hi << 8)
        return (v - 65536 if v & 0x8000 else v), (self.p.uio_out() >> 5) & 1

    def neuron(self, a, w):
        """CLEAR, one MAC per input, READ -> (sum, overflow)."""
        self.cmd(CLEAR)
        for i in range(len(a)):
            self.cmd(MAC, a[i], w[i])
        return self.read()


def quant4(v, scale):
    """rint (ties to even, like numpy and C rint) then clip to [-7, 7]. Python's and MicroPython's round()
    both round halves to even."""
    q = round(v / scale)
    return 7 if q > 7 else (-7 if q < -7 else q)


def infer(tpu, M, x):
    """The professor's host flow (infer_int4 in pipeline.py) with the chip doing every dot product.
    x: normalized features. Returns (class index, logits, the 6 sums, overflow seen).
    tpu = None runs the dot products on the host instead (reference)."""
    def dot(a, w):
        if tpu is None:
            s = 0
            for i in range(len(a)):
                s += a[i] * w[i]
            return s, 0
        return tpu.neuron(a, w)

    sums, ovf = [], 0
    qa = [quant4(v, M.SCALE_A[0]) for v in x]
    h = []
    for j in range(M.N_HID):
        s, o = dot(qa, M.W0[j])
        sums.append(s)
        ovf |= o
        z = s * M.SCALE_A[0] * M.SCALE_W[0] + M.B0[j]
        h.append(z if z > 0.0 else 0.0)                     # ReLU
    qh = [quant4(v, M.SCALE_A[1]) for v in h]
    logits = []
    for j in range(M.N_OUT):
        s, o = dot(qh, M.W1[j])
        sums.append(s)
        ovf |= o
        logits.append(s * M.SCALE_A[1] * M.SCALE_W[1] + M.B1[j])
    best = 0
    for j in range(1, M.N_OUT):
        if logits[j] > logits[best]:
            best = j
    return best, logits, sums, ovf


def normalize(raw, M):
    """Raw features (rms, std, peak, crest, kurtosis, skew, low_band, high_band) -> model inputs."""
    return [(raw[i] - M.MEAN[i]) / M.STD[i] for i in range(M.N_IN)]
