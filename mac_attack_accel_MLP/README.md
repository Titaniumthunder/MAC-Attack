# MAC Attack accelerator: matrix core and first chip blocks

A 16x16 systolic array (256 multiply-accumulate units, INT8, 32-bit accumulators) that
multiplies matrices of any size up to 64x64 by cutting them into 16x16 tiles (folding).
(That is `rtl/chip_top.sv` and the testbenches; the ZedBoard build in `zed/` is 8x8, P = 8,
with exact 22-bit accumulators.) It is the same structure as Google's TPU matrix unit, much smaller. Everything is
SystemVerilog, and every result is checked automatically.

## What is in here

| Block | File | What it does in the chip | Status |
|---|---|---|---|
| Processing element | `rtl/pe.sv` | One multiply-add per clock: `psum_out = psum_in + a * w` | Done |
| Systolic array | `rtl/systolic_array.sv`, `rtl/delay_line.sv` | P x P PEs with input skew and output deskew | Done |
| Folding controller | `rtl/mm_core.sv` | Walks the tiles; edge tiles padded with zeros | Done |
| A, B, C buffers | `rtl/mm_core.sv` | On-chip memories for the matrices (up to 64x64) | Done |
| Accumulators | `rtl/mm_core.sv` | Add each tile's partial sums into C | Done |
| Performance counters | `rtl/mm_core.sv` | Passes, cycles in passes, total cycles | Done |
| Saturating accumulators | `SAT` option in `pe.sv`, `mm_core.sv` | Clamp instead of wrapping on overflow | Started: tested, not used by default |
| Post-processing unit | `rtl/postproc.sv` | Bias + requantize + ReLU (the TPU's activation unit), one scale per output channel | Done: used by the on-chip MLP (21 Oct); built with it in Vivado, timing met at 214.286 MHz (step 15c, 22 Oct) |
| On-chip MLP | `rtl/mlp_ctrl.sv` | Runs a whole MLP (up to 4 layers) with no help from the ARM between layers: weight slots, scale memory, postproc units, layer sequencer | Done in simulation and in Vivado: bit-exact (21 Oct); built, timing met at 214.286 MHz (step 15c, 22 Oct, WNS +0.081 ns); board run: TODO: confirm (recorded on branch Alex_edit, not yet on main); `docs/log.md` section 5, step 15 |
| Host interface | `rtl/uart_rx.sv`, `rtl/uart_tx.sv`, `rtl/host_if.sv`, `rtl/chip_top.sv` | Laptop talks to the chip over a serial line (the ASIC's top; not in the ZedBoard build) | Started: works in simulation (`tb_chip`), not on a board |
| ZedBoard: ARM drives the core | `zed/` (`mac_axi.v`, `pe_dsp48.sv`, `tb_axi.sv`, `create_zed_project.tcl`); board program `zed/mac_zed_project/mac_zed.sdk/MAC_attack_V2/src/mac_test.c` | AXI4-Lite registers so the Zynq's ARM loads, runs and reads the array | Done in simulation and in Vivado: `tb_axi` 20/20, board program 30/30 against the RTL in Verilator (15 tests x 2 bus modes); built at 214.286 MHz (step 15c, WNS +0.081 ns); board run: TODO: confirm (recorded on branch Alex_edit, not yet on main). See `zed/README.md` |

The chip layout trial (OpenLane 2 / SKY130) is in `../mac_attack_accel/openlane/mac_attack_chip/`.
The Arty A7 board files, its Vivado project script and the three testbenches only it used
(`tb_selfcheck`, `tb_compare`, `tb_extras`) were removed on 8 Nov 2026: the project runs on the ZedBoard.
They are in the git history if ever needed.

## Running it

- **In Vivado (the ZedBoard):** see `zed/README.md`. `zed/create_zed_project.tcl` builds the project;
  Run Behavioral Simulation runs `tb_axi`, which plays the ARM and must end with ALL AXI TESTS PASSED.
- **With Python:** `mac.py` runs the RTL in a simulator and checks every result against NumPy (below).

## `mac.py` (Python checks the answers)

`mac.py` runs the simulator from a Command Prompt and compares every result with NumPy.
It also runs the full 60-case test suite. Use it when you want many sizes or random
matrices of your own choosing.

1. Install Python 3 (tick "Add python.exe to PATH") and run `pip install numpy`.
2. Open a **Command Prompt** (not the Vivado Tcl Shell), `cd` into this folder.
3. `python mac.py multiply 4 4 4 --data small --P 4`

`mac.py` finds Vivado on the PATH or in the usual install folders. If not, add
`--vivado-bin "C:\Xilinx\Vivado\2024.2\bin"` (the version on that computer). Each new
array size is compiled once (about a minute). On a Mac without Vivado, install Icarus
Verilog (`brew install icarus-verilog`) and add `--sim icarus`.

| Command | What it shows |
|---|---|
| `python mac.py multiply 64 64 64` | 64x64 on the 16x16 array, checked against NumPy |
| `python mac.py compare 64 64 64` | 4x4 vs 8x8 vs 16x16 (table below) |
| `python mac.py uart 16 16 16` | Whole chip over the serial line (simulated) |
| `python mac.py saturate` / `postproc` | The started blocks |
| `python mac.py mlp` | On-chip MLP: whole random models, every output and counter checked |
| `python mac.py test` | All 60 test cases |

(`mac.py board` was for the Arty board, which is no longer used.)

## The equations

```
passes  Np = ceil(K/P) x ceil(N/P)          number of P x P tiles of B
cycles  T  = Np x (M + 3P - 2)              P to load a tile, M to stream rows of A,
                                             P - 1 input skew, P - 1 drain
PE busy U  = M K N / (P^2 T)
```
The measured cycle count equals T in every test. The trade-off the project studies, for a
64x64x64 multiply (`mac.py compare 64 64 64`):

| Array | PEs | Passes | Cycles | PEs busy | Speedup |
|---|---|---|---|---|---|
| 4x4 | 16 | 256 | 18,944 | 86.5% | 1.0x |
| 8x8 | 64 | 64 | 5,504 | 74.4% | 3.4x |
| 16x16 | 256 | 16 | 1,760 | 58.2% | 10.8x |

16 times the hardware gives 10.8 times the speed, because every pass spends `3P - 2`
cycles loading weights, filling and draining.

## How it was checked

Done in Icarus Verilog 12, Verilator 5 and Yosys:
- **Correctness:** 60/60 test cases match NumPy bit for bit, and every cycle count equals the equation.
- **Other blocks:** saturating mode matches the Python model; 800/800 post-processing outputs match; the serial-line chip matches at 8x8x8, 16x16x16 and 20x30x10.
- **Lint:** Verilator `--lint-only -Wall` is clean for every module, at P = 2, 3, 4, 8 and 16.
- **Tests catch bugs:** nine bugs were put into the RTL on purpose, including unsigned weights, wrong weight order, no zero padding, wrong deskew, C read one cycle late, and an extra idle cycle. The quick test suite failed on every one.
- **On the ZedBoard:** see `zed/README.md` for the Vivado builds, timing and board results.

## Serial protocol (laptop to chip)

Used by `chip_top` (the ASIC's top) and `mac.py uart`.

| Laptop sends | Chip replies |
|---|---|
| `I` | `M A C` P BITS ACC MAXD |
| `D` m k n | `k`, or `e` if a size is 0 or above 64 |
| `A` + m*k bytes, row by row | `k` |
| `B` + k*n bytes, row by row | `k` |
| `G` | `g` + passes + cycles + total cycles (4 bytes each, least significant first) |
| `C` | m*n results, 4 bytes each, row by row |
