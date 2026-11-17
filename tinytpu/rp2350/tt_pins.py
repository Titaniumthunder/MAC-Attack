# Pin layer for the Tiny Tapeout demo board (RP2350, tt-micropython-firmware), MAC Attack, Apache-2.0.
# The drivers (tinytpu_v1.py, tinytpu_v2.py) only call these five or six methods.

from ttboard.demoboard import DemoBoard
from ttboard.mode import RPMode
import ttboard.util.platform as plat


class TTPins:
    def __init__(self, project, uio_drive):
        """project: the design's top module name on the shuttle, e.g. 'tt_um_titaniumthunder_tiny_tpu_v2'.
        uio_drive: which uio pins the RP2350 drives (1 = RP2350 output): 0xFF for Version 2, 0x0F for
        Version 1 (the chip drives uio[5:4])."""
        tt = DemoBoard.get()
        self.tt = tt
        tt.mode = RPMode.ASIC_RP_CONTROL        # the RP2350 drives inputs, clock and reset
        if not tt.shuttle.has(project):
            raise ValueError("%s is not on this chip (%s)" % (project, tt.shuttle))
        tt.shuttle.get(project).enable()        # select our design in the chip's multiplexer
        tt.clock_project_stop()                 # no free-running clock: we make every edge
        tt.pins.project_clk_driven_by_RP2(True)
        plat.write_clock(0)
        tt.uio_oe_pico.value = uio_drive
        tt.ui_in.value = 0
        tt.uio_in.value = 0

    def ui(self, v):
        self.tt.ui_in.value = v

    def uio(self, v):
        self.tt.uio_in.value = v

    def clock(self):
        plat.write_clock(1)                     # rising edge: the chip acts here
        plat.write_clock(0)

    def uo(self):
        return self.tt.uo_out.value

    def uio_out(self):
        return self.tt.uio_out.value

    def reset(self, clocks=5):
        self.tt.reset_project(True)
        for _ in range(clocks):
            self.clock()
        self.tt.reset_project(False)
        self.clock()
