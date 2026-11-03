# MAC Attack chip for OpenLane 2 (SKY130)

A small but complete version of our chip, ready for OpenLane 2:

```
serial in -> uart_rx -> host_if -> mm_core (A, B, C buffers + 4x4 systolic array)
serial out <- uart_tx <---'
```

- 4x4 systolic array (16 PEs), INT8 inputs, 19-bit exact accumulators, matrices up to 8x8
- 5 pins: `clk`, `rst`, `uart_rx_i`, `uart_tx_o`, `busy_led`
- Clock period 4 ns (250 MHz); serial port at 115,200 baud (`CLKS_PER_BIT` = 2170)
- Core settings of the ZedBoard build that met 250 MHz (step 14): `PIPE` = 2, `MEM_REG` = 2,
  `HREAD_REG` = 1. The PEs are `pe.sv` (standard cells), not DSP48E1s.
  (Before 20 Oct this folder held the 40 MHz version: 25 ns, 32-bit accumulators, `PIPE` = `MEM_REG` = 1.)

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
- (20 Oct, 250 MHz version) RTL simulation of `src/mac_attack_chip.v` over its serial port: the same
  6 tests pass, cycles match the equation, `perf_total` = cycles + 7. Verilator lint: 0 errors.
  The gate-level simulation was not repeated for this version.

## First OpenLane run (20 Oct 2026, OpenLane 2.3.10, `runs/RUN_250MHz`)

The flow ran every step, then stopped with "setup violations" (so there is no `final/` folder;
the GDS is `runs/RUN_250MHz/56-magic-streamout/mac_attack_chip.gds`).

| | Result |
|---|---|
| Die | 697 x 708 um |
| Standard cells | 31,845 (4,393 flip-flops), 59% utilization, 0.276 mm^2 cell area |
| Setup, typical corner (tt, 25 C, 1.8 V) | WNS -1.41 ns, TNS -113 ns, 218 failing endpoints: about 5.4 ns, **185 MHz** |
| Setup, slow corner (ss, 100 C, 1.6 V) | WNS -6.47 ns (about 95 MHz) |
| Setup, fast corner (ff, -40 C, 1.95 V) | met (+0.64 ns) |
| Hold | met except 1 endpoint at ff (-0.019 ns) |
| DRC (Magic, KLayout) / LVS | clean / clean |
| Antenna | 7 nets |
| Max slew | 133 violations |
| Power | 91 mW |

So this RTL does not make 250 MHz in SKY130 (typical corner about 185 MHz).
