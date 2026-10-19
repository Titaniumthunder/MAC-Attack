# MAC Attack chip for OpenLane 2 (SKY130)

A small but complete version of our chip, ready for OpenLane 2:

```
serial in -> uart_rx -> host_if -> mm_core (A, B, C buffers + 4x4 systolic array)
serial out <- uart_tx <---'
```

- 4x4 systolic array (16 PEs), INT8 inputs, 32-bit accumulators, matrices up to 8x8
- 5 pins: `clk`, `rst`, `uart_rx_i`, `uart_tx_o`, `busy_led`
- Clock period 25 ns (40 MHz); serial port at 115,200 baud

| File | What it is |
|---|---|
| `config.json` | OpenLane settings: design name, source file, clock pin and period |
| `src/mac_attack_chip.v` | The whole design in one plain-Verilog file, translated from our SystemVerilog with sv2v |
| `source/mac_attack_chip.sv` | The SystemVerilog top level it was made from (the rest is `rtl/*.sv` in the main project) |

## Run it

OpenLane 2 runs on Linux, on macOS, or on Windows through WSL (not directly on Windows).

```
nix-shell --pure ~/openlane2/shell.nix
openlane ~/mac_attack_chip/config.json
```

If OpenLane was installed with Docker, add `--dockerized` after `openlane`.

## Look at it

```
openlane --last-run --flow openinklayout ~/mac_attack_chip/config.json
```

Or open `runs/RUN_<date>/final/gds/mac_attack_chip.gds` in KLayout. The numbers (area, cell count,
timing slack, power) are in `runs/RUN_<date>/final/metrics.csv`.

## What to expect

Yosys synthesis to SKY130 cells (before OpenLane adds buffers and fill):

| P | MAXD | Cells | Flip-flops | Cell area |
|---|---|---|---|---|
| 4 | 8 (this file) | 26,600 | 5,000 | 0.23 mm^2 |
| 4 | 16 | 73,700 | 14,200 | 0.58 mm^2 |
| 8 | 16 | 100,000 | 17,500 | 0.82 mm^2 |

About 3,100 of the 5,000 flip-flops are the A, B and C buffers, so most of the layout is memory,
not the array. Real chips use SRAM blocks for this instead of flip-flops.

To try another size, change `P` and `MAXD` in `module mac_attack_chip` at the top of
`src/mac_attack_chip.v`. Bigger sizes take much longer to run.

## How it was checked

- RTL simulation of `src/mac_attack_chip.v` over its serial port: identify, 8x8x8 (4 passes),
  5x7x3, 1x8x8, all -128, 4x4x4, and rejecting a size of 9. All pass, cycle counts match the equation.
- The same tests on the Yosys gate-level netlist: all pass.
- Verilator lint: 0 errors (56 width warnings from the translation). No latches.
- Not run through OpenLane yet: placement, routing and timing are the next check.
