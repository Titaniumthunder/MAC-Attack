# Two-clock mode (mac_axi CORE_CLK = 1, step 12). Add this file to the project only in that mode
# (create_zed_project.tcl does it when CORE_MHZ > 0).
#
# The AXI side (registers, loader) runs on clk_fpga_0 (FCLK_CLK0 from the Zynq). The matrix core
# runs on the Clocking Wizard's clk_out1 (block "clk_core"). mac_axi crosses between the two only
# through:
#   * two-flip-flop synchronizers marked ASYNC_REG (start, done, reset, core ready),
#   * dual-clock block RAMs (A and B: written on clk_fpga_0, read on the core clock; the copy of C:
#     written on the core clock, read on clk_fpga_0),
#   * registers that do not change while the other side reads them (DIMS while a run starts, the
#     performance counters after done).
# So timing analysis must not relate the two clocks to each other:
set_clock_groups -name core_vs_axi -asynchronous \
    -group [get_clocks clk_fpga_0] \
    -group [get_clocks -of_objects [get_pins -hier -filter {NAME =~ *clk_core/clk_out1}]]

# Check after implementation (Tcl console, implemented design open):
#   report_clock_interaction   -> clk_fpga_0 vs the core clock: "Asynchronous Groups"
#   report_cdc -details        -> only the crossings listed above
