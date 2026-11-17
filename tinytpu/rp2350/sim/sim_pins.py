# The simulator's pin layer: the same methods as tt_pins.TTPins, but on the cocotb testbench (tb.v).
# The drivers are ordinary blocking code, as on the RP2350; they run in a cocotb "bridge" thread and
# each pin call hands control to the simulator ("resume") until it is done.
from cocotb.task import resume
from cocotb.triggers import Timer


@resume
async def _drive(sig, v):
    sig.value = v
    await Timer(1, "ns")            # let it settle before the next edge or read


@resume
async def _read(sig):
    await Timer(1, "ns")            # outputs settle (uo_out follows BSEL / PSEL / HI combinationally)
    return int(sig.value)


@resume
async def _clock(clk):
    clk.value = 1                   # rising edge: the chip acts here
    await Timer(5, "ns")
    clk.value = 0
    await Timer(5, "ns")


class SimPins:
    def __init__(self, dut):
        self.dut = dut
        self.ops = 0

    def ui(self, v):
        self.ops += 1
        _drive(self.dut.ui_in, v)

    def uio(self, v):
        self.ops += 1
        _drive(self.dut.uio_in, v)

    def clock(self):
        self.ops += 1
        _clock(self.dut.clk)

    def uo(self):
        self.ops += 1
        return _read(self.dut.uo_out)

    def uio_out(self):
        self.ops += 1
        return _read(self.dut.uio_out)

    def reset(self, clocks=5):
        _drive(self.dut.rst_n, 0)
        for _ in range(clocks):
            self.clock()
        _drive(self.dut.rst_n, 1)
        self.clock()


async def start(dut):
    """Testbench idle state: design enabled, clock low (the host makes every edge), out of reset."""
    dut.ena.value = 1
    dut.clk.value = 0
    dut.rst_n.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    await Timer(10, "ns")
