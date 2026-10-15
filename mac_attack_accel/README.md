# MAC Attack accelerator: matrix core and first chip blocks

A 16x16 systolic array (256 multiply-accumulate units, INT8, 32-bit accumulators) that
multiplies matrices of any size up to 64x64 by cutting them into 16x16 tiles (folding).
It is the same structure as Google's TPU matrix unit, much smaller. Everything is
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
| Post-processing unit | `rtl/postproc.sv` | Bias + requantize + ReLU (the TPU's activation unit) | Started: tested on its own, not yet connected to the core |
| Host interface | `rtl/uart_rx.sv`, `rtl/uart_tx.sv`, `rtl/host_if.sv`, `rtl/chip_top.sv` | Laptop talks to the chip over a serial line | Started: works in simulation, not yet on a board |
| Board top | `fpga/arty_top.sv`, `fpga/arty_a7.xdc` | Clock, reset button, USB-UART pins, LEDs for the Arty A7 | Started: not yet built in Vivado |
| Vivado project script | `vivado/create_project.tcl` | Creates the Vivado project with all files added | Done: works in Vivado (folder must be on `C:\`) |
| ZedBoard: ARM drives the core | `zed/` (`mac_axi.v`, `tb_axi.sv`, `mac_test.c`, `create_zed_project.tcl`) | AXI4-Lite registers so the Zynq's ARM loads, runs and reads the array | Started: 12/12 in simulation, C program 8/8 against the RTL; not yet built in Vivado. See `zed/README.md` |
| Chip layout trial | `openlane/mac_attack_chip/` | Same core (P = 4) as plain Verilog for OpenLane 2 / SKY130 | Started: netlist checked in simulation; see its README |

There are two ways to run it. **Way 1 needs only Vivado** and works like a class lab.
Way 2 uses a Python script and is for checking many sizes at once.

## Way 1: in Vivado (no Python needed)

1. Unzip, then put the folder on a local Windows drive with a short path, for example
   `C:\mac_attack_accel` (it should contain `rtl`, `tb`, `vivado`). **Not** in a Mac shared
   folder (`\\Mac\Home\...` in a Parallels VM) or any other network path: Vivado's
   simulator cannot run from there and fails with `[USF-XSim-62] 'compile' step failed`.
2. Open Vivado. Do not create a project yourself. Go to **Tools > Run Tcl Script...** and pick
   `vivado\create_project.tcl`. It creates the project with every file already added,
   in `vivado\mac_attack_project`.
3. Click **SIMULATION > Run Simulation > Run Behavioral Simulation**.
4. Read the results in the **Tcl Console** at the bottom. Every test prints PASS or FAIL,
   and the last line says `ALL TESTS PASSED (8/8)`. The waveform window shows the array
   loading weights, streaming inputs and producing outputs.

If the simulation stops after 1 microsecond, type `run all` in the Tcl Console.

If the simulation fails:

| Message | Cause and fix |
|---|---|
| `[USF-XSim-62] 'compile' step failed`, path starts with `//` or `\\` | The folder is on a network path. Close the project, copy the folder to `C:\`, run `create_project.tcl` from there. The script now stops with an error if it detects this. |
| `[USF-XSim-62]` with a `C:\` path | Vivado rejects a line of code. Send the first red ERROR line in the Tcl Console, or `xvlog.log` from `vivado\mac_attack_project\mac_attack.sim\sim_1\behav\xsim\`. |

There are three testbenches. To switch, go to **Sources > Simulation Sources > sim_1**,
right-click a testbench, choose **Set as Top**, and run the simulation again.

| Testbench | What it shows | Simulated time |
|---|---|---|
| `tb_selfcheck` (default) | 8 tests on the 16x16 array: a small 4x4 multiply printed in full, then 64x64 (16 tiles), odd sizes, one row, all -128, all 127, identity. Checks every result and the cycle equation. | about 0.33 ms |
| `tb_compare` | The same 64x64 multiply on 4x4, 8x8 and 16x16 arrays, as one table | about 0.75 ms |
| `tb_extras` | The blocks we have started: saturation versus wrapping, the post-processing unit, and the whole chip driven over a serial line | about 0.33 ms |

The testbenches make their own test matrices and work out the correct answers with plain
loops, so they need no input files. To try a different array size, change
`parameter int P = 16` at the top of `tb/tb_selfcheck.sv` to 4 or 8.

### Reading the `tb_selfcheck` waveform

Vivado shows every signal at the top level of the testbench, so there are 40 rows. They fall into five groups:

| Group | Signals | What they are |
|---|---|---|
| Chip pins (19) | `clk`, `rst` | 100 MHz clock (solid green when zoomed out) and reset (high for 3 cycles at time 0) |
| | `wr_en`, `wr_sel`, `wr_row`, `wr_col`, `wr_data` | Load port: write one INT8 number per clock into A (`wr_sel` = 0) or B (`wr_sel` = 1) at (row, col) |
| | `dim_m`, `dim_k`, `dim_n`, `start` | Matrix sizes for this test, then a one-clock "go" pulse |
| | `busy`, `done` | High while the core computes; one-clock pulse when C is complete |
| | `rd_row`, `rd_col`, `rd_data` | Read port: ask for C[row][col], the 32-bit result appears on the next clock |
| | `perf_passes`, `perf_cycles`, `perf_total` | Hardware counters: tile passes, cycles in passes, total busy cycles (3 more: start-up, last row, done) |
| Probes (8) | `array_loading_weights`, `array_streaming_inputs`, `array_output_ready` | The array's three phases in each pass |
| | `pass_number`, `cycle_in_pass`, `reduction_block`, `output_block` | Controller counters (`pass_number` is a copy of `perf_passes`) |
| | `c_lane0` | Partial sum leaving column 0 of the array; meaningful only while `array_output_ready` is high |
| Testbench (4) | `test_number`, `tests_run`, `tests_passed` | Which test, and the score |
| | `seed` | State of the random-number generator that makes the test matrices |
| Constants (9) | `P`, `BITS`, `ACC`, `MAXD` | 16x16 array, 8-bit inputs, 32-bit sums, matrices up to 64 |
| | `RANDOM`, `SMALL`, `MINV`, `MAXV`, `IDENT` | Codes for the kind of test data (0 to 4) |

Set `wr_data`, `rd_data` and `c_lane0` to **Radix > Signed Decimal**; otherwise negative numbers show as large
positive ones (4294948765 is -18531, `wr_data` 135 is -121).

### What each `tb_selfcheck` test is for

| Test | Size (M x K x N) | Data | Passes, cycles | What it is there to catch |
|---|---|---|---|---|
| 1 | 4x4x4 | -9 to 9, printed | 1, 50 | Readable by hand; sizes smaller than the array (zero padding) |
| 2 | 16x16x16 | random INT8 | 1, 62 | Exactly one full tile: every one of the 256 PEs is used |
| 3 | 64x64x64 | random INT8 | 16, 1,760 | Folding: 16 tiles, partial sums from 4 reduction blocks added into C |
| 4 | 37x50x23 | random INT8 | 8, 664 | Sizes that are not multiples of 16: partly filled edge tiles |
| 5 | 1x64x64 | random INT8 | 16, 752 | Only one row of A: shortest possible stream through the pipeline |
| 6 | 16x16x16 | all -128 | 1, 62 | -128 x -128 = 16,384 is the only INT8 product that needs all 16 bits |
| 7 | 16x16x16 | all 127 | 1, 62 | Largest positive values (sum 258,064) |
| 8 | 16x16x16 | B = identity | 1, 62 | C must equal A: any weight in the wrong PE shows up at once |

Bugs planted on purpose (Icarus, 11 Oct), and which tests caught them (x):

| Planted bug | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 |
|---|---|---|---|---|---|---|---|---|
| Weights loaded in reverse order | x | x | x | x | x | | | x |
| Multiply ignores the sign (unsigned) | x | x | x | x | x | | | x |
| No zero padding at the edges | x | | | x | | | | |
| Tile results not added together | | | x | x | x | | | |
| Product one bit too narrow | | | x | | x | x | | |

A sixth bug, one extra cycle per pass, makes the core never say done; the testbench's safety timeout stops it
with `ERROR: timeout`. Every bug is caught by at least one test, and no single test catches all of them. Tests 3 and 5 caught the
narrow product only because the random data happened to contain -128 x -128; test 6 always does. Test 7
caught none of these; it guards the largest positive sums.

**Adding a signal:** in the **Scope** panel select a module, then in the **Objects** panel right-click a signal
and choose **Add to Wave Window**. `create_project.tcl` turns on `log_all_signals`, so the new row shows its
whole history; otherwise type `restart` then `run all` in the Tcl Console.

**Watching the PEs multiply (test 1):** in Scope open `tb_selfcheck > dut > u_array > g_r[0] > g_c[0] > u_pe`
and add `w`, `a_in` and `psum_out` (Radix > Signed Decimal). Do the same for `g_r[1]`, `g_r[2]`, `g_r[3]`
(column `g_c[0]`). Zoom to about 0.38 to 0.90 us. After the weights load (about 0.55 us), column 0 holds
w = 5, 2, 9, -3, and `psum_out` steps 25, 33, 69, 72 down the rows one clock apart; `c_lane0` shows 72 at
about 0.85 us. While weights are loading, the PEs also multiply leftover inputs; those sums are thrown away
(`array_output_ready` is low), but gating the inputs to 0 would save power.

**Demo layout:** delete the rows you don't need (select, press Delete; this only changes the view, not the
design), then click the save icon in the waveform toolbar and save as
`vivado\tb_selfcheck.wcfg` (next to `create_project.tcl`, not inside `mac_attack_project`, which the script
replaces). `create_project.tcl` adds any `.wcfg` in `vivado\` to the project, so the layout opens
automatically, also on another computer.

The project also has the board design (`arty_top`) and the Arty A7 pin file, so **Run
Synthesis** shows how much of the FPGA the 16x16 design uses. The project is set for the
A7-100T; for an A7-35T, change the part in `create_project.tcl` and use P = 8 in `fpga/arty_top.sv`.

## Way 2: `mac.py` (Python checks the answers)

`mac.py` runs the same simulator from a Command Prompt and compares every result with NumPy.
It also runs the full 60-case test suite. Use it when you want many sizes or random
matrices of your own choosing.

1. Install Python 3 (tick "Add python.exe to PATH") and run `pip install numpy`.
2. Open a **Command Prompt** (not the Vivado Tcl Shell), `cd C:\mac_attack_accel`
3. `python mac.py multiply 4 4 4 --data small --P 4`

`mac.py` finds Vivado on the PATH or in the usual install folders. If not, add
`--vivado-bin "C:\Xilinx\Vivado\2024.2\bin"` (the version on that computer). Each new
array size is compiled once (about a minute). On a Mac without Vivado, install Icarus
Verilog (`brew install icarus-verilog`) and add `--sim icarus`.

| Command | What it shows |
|---|---|
| `python mac.py multiply 64 64 64` | 64x64 on the 16x16 array, checked against NumPy |
| `python mac.py compare 64 64 64` | 4x4 vs 8x8 vs 16x16 |
| `python mac.py uart 16 16 16` | Whole chip over the serial line |
| `python mac.py saturate` / `postproc` | The started blocks |
| `python mac.py test` | All 60 test cases |

## What to show on Tuesday (Way 1)

1. **`tb_selfcheck`**: the 4x4 example printed in full (check one entry by hand), then
   64x64 on the 16x16 array: 4,096 correct results, 16 passes, 1,760 cycles, exactly what
   the equation predicts. Show the waveform: `array_loading_weights` high for 16 cycles,
   then `array_streaming_inputs`, then `array_output_ready`, once per pass.
2. **`tb_compare`**: the trade-off the project studies.

| Array | PEs | Passes | Cycles | PEs busy | Speedup |
|---|---|---|---|---|---|
| 4x4 | 16 | 256 | 18,944 | 86.5% | 1.0x |
| 8x8 | 64 | 64 | 5,504 | 74.4% | 3.4x |
| 16x16 | 256 | 16 | 1,760 | 58.2% | 10.8x |

   16 times the hardware gives 10.8 times the speed, because every pass spends `3P - 2`
   cycles loading weights, filling and draining.
3. **`tb_extras`**: the other chip blocks we have started. With 16-bit accumulators,
   8 x (-128 x -128) = 131,072 wraps around to **0**; the saturating version stops at
   32,767. Saturation also breaks some results whose final value fits, because a partial
   sum overflowed along the way. Then the post-processing unit, and the whole chip
   answering a laptop over a serial line.

## The equations

```
passes  Np = ceil(K/P) x ceil(N/P)          number of P x P tiles of B
cycles  T  = Np x (M + 3P - 2)              P to load a tile, M to stream rows of A,
                                             P - 1 input skew, P - 1 drain
PE busy U  = M K N / (P^2 T)
```
The measured cycle count equals T in every test.

## How it was checked

Done in Icarus Verilog 12, Verilator 5 and Yosys:
- **Correctness:** 60/60 test cases match NumPy bit for bit, and every cycle count equals the equation.
- **Other blocks:** saturating mode matches the Python model; 800/800 post-processing outputs match; the serial-line chip matches at 8x8x8, 16x16x16 and 20x30x10.
- **Lint:** Verilator `--lint-only -Wall` is clean for every module, at P = 2, 3, 4, 8 and 16.
- **Vivado testbenches:** `tb_selfcheck` 8/8 tests pass, `tb_compare` all three sizes pass, `tb_extras` all three parts pass (in Icarus). Six planted bugs were each caught by `tb_selfcheck` (table under "What each `tb_selfcheck` test is for").
- **Tests catch bugs:** nine bugs were put into the RTL on purpose, including unsigned weights, wrong weight order, no zero padding, wrong deskew, C read one cycle late, and an extra idle cycle. The quick test suite failed on every one.
- **FPGA size estimate:** Yosys synthesis for Artix-7 (an estimate; Vivado's numbers are the real ones):

| Array | Multipliers (DSP) | LUTs | Flip-flops | Fits A7-35T? | Fits A7-100T? |
|---|---|---|---|---|---|
| 4x4 | 16 | about 1,600 | about 1,200 | yes | yes |
| 8x8 | 64 | about 2,100 | about 2,400 | yes | yes |
| 16x16 | 256 | about 7,100 | about 7,700 | probably not | yes, if Vivado builds about 16 multipliers from LUTs |

The A7-100T has 240 DSP slices and 63,400 LUTs; the A7-35T has 90 and 20,800.
To get Vivado's real numbers without a board:
`vivado -mode batch -source fpga/synth_check.tcl -tclargs 16 xc7a100tcsg324-1`

**Not checked yet:**
- In Vivado, only `tb_selfcheck` has been run so far (9 Oct: `create_project.tcl` worked, 8/8 PASS, 330.43 us simulated, same results as Icarus). `tb_compare`, `tb_extras` and Vivado synthesis have not been run in Vivado yet.
- Nothing has run on a board yet, and timing at 100 MHz has not been checked.
- These are FPGA estimates only. Chip area, power and speed come from the SKY130 / OpenLane flow, which is a later stage.

## Later: on the Arty board

```
vivado -mode batch -source fpga/build_bitstream.tcl -tclargs 16 xc7a100tcsg324-1
```
Use `8 xc7a35ticsg324-1L` for an A7-35T. WNS printed at the end must be 0 or more.
Program the board in Vivado's Hardware Manager, then:
```
pip install pyserial
python mac.py board 16 16 16 --port COM5
```
LD4 lights while the core computes; LD5 blinks to show the design is running.

## Serial protocol (laptop to chip)

| Laptop sends | Chip replies |
|---|---|
| `I` | `M A C` P BITS ACC MAXD |
| `D` m k n | `k`, or `e` if a size is 0 or above 64 |
| `A` + m*k bytes, row by row | `k` |
| `B` + k*n bytes, row by row | `k` |
| `G` | `g` + passes + cycles + total cycles (4 bytes each, least significant first) |
| `C` | m*n results, 4 bytes each, row by row |
