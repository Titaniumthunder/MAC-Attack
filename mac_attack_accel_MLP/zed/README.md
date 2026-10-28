# ZedBoard version: the ARM drives the systolic array

This folder runs the same matrix core (`rtl/mm_core.sv`, P x P systolic array) on the
ZedBoard (Zynq XC7Z020, `xc7z020clg484-1`). On the Arty the laptop talked to the chip over
UART. Here the board's own ARM processor talks to it over AXI, which is the path the Machine
Guardian design needs (sensor -> ARM/PL -> array -> anomaly score).

```
 ┌──────────────────────── Zynq XC7Z020 ─────────────────────────┐
 │ PS (hard silicon): 2x Cortex-A9, DDR controller, USB-UART,    │
 │                    Ethernet, timers                           │
 │        │ M_AXI_GP0 (32-bit AXI, ARM is the master)            │
 │ ───────┼────────────────────────────────────────────────────  │
 │ PL     ▼        (FPGA fabric, FCLK_CLK0 = 50 MHz)             │
 │   AXI interconnect ──► mac_axi (registers) ──► mm_core        │
 │                                     A, B, C buffers + P x P PEs│
 └───────────────────────────────────────────────────────────────┘
```

| File | What it is |
|---|---|
| `mac_axi.v` | AXI4-Lite wrapper: 12 registers the ARM reads and writes (map below). Plain Verilog on purpose (see Notes). |
| `tb_axi.sv` | Self-checking testbench that plays the ARM: same registers, same order as the C program. |
| `create_zed_project.tcl` | Makes the Vivado project, the simulation set-up and the block design. |
| `mac_test.c` | Bare-metal program for the ARM (Vitis): loads matrices, runs, checks every value, times each step. |

**What has been checked (13 Oct):** `tb_axi` passes 12/12 at P = 4, 8 and 16 (Icarus).
`mac_test.c` was compiled on a PC and run against the RTL through Verilator (the `Xil_Out32` /
`Xil_In32` calls were turned into AXI transactions): 8/8 at P = 8 and 16. Two planted bugs were
caught (byte order reversed: 8 tests fail; no result auto-increment: 6 fail).
**Not checked yet:** the block design, the bitstream and the board. Those need real Vivado.

---

## 0. Open the committed project and run it (no rebuild)

Since 18 Oct 2026 the Vivado project `mac_zed_project/` is in git together with its results, so you can
program the board without the 20-minute build. In git: `mac_zed.xpr`, the block design (`mac_zed.srcs`),
the run results (`mac_zed.runs`: bitstream, checkpoints, reports) and, in `mac_zed.sdk`, the `.hdf`, the
hardware platform, the BSP and `MAC_attack_V2`. Not in git (the tools remake them): caches, simulation
files, logs, the SDK workspace settings (`.metadata`) and the apps' `Debug`/`Release` folders.
Needs Vivado and SDK **2019.1** and the ZedBoard board files (section 2, step 2).

1. `git pull`, then open `zed/mac_zed_project/mac_zed.xpr`. If Vivado says the runs are out of date (git
   does not keep file dates), do not rebuild: Open Implemented Design still shows the timing, and the
   bitstream is already in the SDK hardware platform.
2. Start SDK on the workspace `zed/mac_zed_project/mac_zed.sdk` (Vivado: File > Launch SDK, both locations
   `<Local to Project>`).
3. A new workspace does not list the projects yet: File > Import > General > Existing Projects into
   Workspace, root directory `mac_zed.sdk`, select all, do **not** tick "Copy projects into workspace".
4. Board: JTAG and the USB-UART (J14) plugged in, terminal at 115200 8N1. Right-click `MAC_attack_V2` >
   Run As > Run Configurations > Target Setup: tick Reset entire system, Program FPGA, Run ps7_init and
   Run ps7_post_config, then Run. Pass: `ALL BOARD TESTS PASSED` and the measured PL clock equal to
   `FCLK_HZ` in `mac_test.c`.

Rules for the team:
- Push a build only if it met timing (WNS >= 0) and passed on the board; write the clock, WNS and the board
  result in the commit message.
- One person pushes builds at a time. Two different builds pushed at once conflict on binary files.
- Opening the project changes a few files (for example `mac_zed.xpr`). If you did not change the design,
  undo those before you pull: `git status`, then `git restore <file>` for each one.
- If the project breaks: delete `mac_zed_project/` except `mac_zed.sdk/`, run `create_zed_project.tcl`
  (section 2), and get the SDK files back with `git checkout -- mac_zed_project/mac_zed.sdk` if the
  script removed them.

## 1. Copy the folder to a local drive

Same rule as before: `C:\mac_attack_accel`, not `\\Mac\Home\...` (the simulator fails on
network paths and the script stops if it sees one).

## 2. Make the project and simulate

1. Vivado > Tools > Run Tcl Script... > `zed\create_zed_project.tcl`.
2. If it prints `WARNING: no ZedBoard board files found`: Tools > Vivado Store > Boards,
   search **ZedBoard**, install, run the script again.
3. Flow Navigator > Run Simulation > Run Behavioral Simulation. Read the Tcl Console:

```
  ID   = 0x4d414331  (MAC1)
  INFO = P 8, 8-bit inputs, 32-bit sums, matrices up to 64
  DIMS write then read back: 0x050607    (ok)

  PASS  small numbers                   4x 4x 4    16/16   correct  passes   1 (eq   1)  cycles    26 (eq    26)  bus: load     58, run    42, read    100 clocks
  PASS  random INT8, one 16x16         16x16x16   256/256  correct  passes   4 (eq   4)  cycles   152 (eq   152)  bus: load    778, run   168, read   1540 clocks
  PASS  random INT8, 64x64 folded      64x64x64  4096/4096 correct  passes  64 (eq  64)  cycles  5504 (eq  5504)  bus: load  12298, run  5520, read  24580 clocks
  ...
  PASS  load during a run is dropped and flagged (STATUS = 0x6)

  Clocks over all 8 multiplies: loading 26234, computing 8976, reading 36338
  Moving data takes 7.0x as long as the computing, even with an ideal bus.

 ALL AXI TESTS PASSED (12/12)
```

The simulation ends at about 1.54 ms of simulated time.

If the script ends with `Block design 'system' built`, skip to step 10.
If it ends with `NOTE: the block design step stopped`, build it by hand (steps 3 to 9).

## 3 to 9. Block design in the GUI (only if the script's block design step stopped)

3. Flow Navigator > IP Integrator > **Create Block Design**, name `system`.
4. **+** (Add IP) > *ZYNQ7 Processing System*. Click **Run Block Automation**, keep
   *Apply Board Preset* ticked, OK. This sets the DDR, the UART and the MIO pins for the ZedBoard.
5. Double-click the Zynq block:
   - *Clock Configuration > PL Fabric Clocks*: **FCLK_CLK0 = 50 MHz**.
   - *PS-PL Configuration > AXI Non Secure Enablement > GP Master AXI Interface*:
     **M AXI GP0 interface** ticked (the board preset usually has it on already).
6. In the Sources window, right-click `mac_axi.v` > **Add Module to Block Design**.
   Double-click the new block and set **P = 8**.
7. **Run Connection Automation**, tick All Automation, OK. Vivado adds an AXI interconnect
   (or a SmartConnect) and a Processor System Reset, and wires the clocks and resets.
8. **Address Editor** tab: the `mac` block should be at **0x43C0_0000**. Any range is fine
   (only the low 7 address bits are decoded, so the registers just repeat inside the window).
   If the address is different, change `MAC_BASE` at the top of `mac_test.c`.
9. **Validate Design** (F6): no errors. In Sources, right-click `system.bd` >
   **Create HDL Wrapper** > *Let Vivado manage*. Make `system_wrapper` the top
   (right-click > Set as Top) if it is not already bold.

## 10. Bitstream and timing

1. **Generate Bitstream** (it runs synthesis and implementation first).
2. Open Implemented Design > **Report Timing Summary**: **WNS must be 0 or more** at 50 MHz.
   If it is negative, write down the WNS and the worst path (Source, Destination) before changing anything.
3. **Report Utilization**: write down LUT, FF, BRAM and DSP. (For scale: P = 16 on the Arty
   A7-100T used 28,390 LUTs and 128 BRAMs; the XC7Z020 has 53,200 LUTs and 140 BRAMs.)
4. **No XDC file is needed**: `mac_axi` has no pins of its own. Everything it uses (clock,
   reset, bus) comes from the Zynq inside the chip, and the board preset handles the DDR and MIO pins.

## 11. Export the hardware

File > Export > **Export Hardware** > *Include bitstream* > save `system_wrapper.xsa`.

## 12. Vitis: build the ARM program

Menu names change between versions. The steps are the same:

1. Make a **platform** from `system_wrapper.xsa`: processor `ps7_cortexa9_0`, OS **standalone**.
   - Vitis 2023.2 and later (Unified IDE): File > New Component > Platform.
   - Vitis 2020.1 to 2023.1 (Classic): File > New > Application Project > *Create a new platform from hardware (XSA)*.
2. Make an **application** on that platform from the *Hello World* template.
3. Delete `helloworld.c` from the app's `src` and add `zed/mac_test.c` instead.
4. Turn on optimisation (Release configuration, or `-O2` in the app's compiler settings), so
   the ARM's software multiply is a fair comparison.
5. Build.

## 13. Run it on the board

1. **Boot-mode jumpers JP7 to JP11 in the JTAG position.** Check the picture in Digilent's
   ZedBoard programming guide or the silkscreen on the board before moving them.
2. Micro-USB cable to **J17 (PROG)** for JTAG, and a second one to **J14 (UART)**.
   Plug in the 12 V supply and switch the board on.
3. Open a serial terminal on the UART's COM port (Device Manager shows it):
   **115200 baud, 8 data bits, no parity, 1 stop bit**. Vitis has one built in; PuTTY or Tera Term also work.
4. In Vitis, **Run** the application on hardware (Classic: Run As > Launch Hardware).
   This programs the PL with the bitstream, then loads and starts the program on the ARM.

What the terminal should show (this is the Verilator run; the times on the board will differ):

```
 MAC Attack accelerator on the ZedBoard
 Found it: 8x8 array, 8-bit inputs, 32-bit sums, matrices up to 64, clock 50 MHz

PASS  small numbers                 4x 4x 4    16/16   correct  passes 1 (eq 1)  cycles 26 (eq 26)
      array 0 us | over the bus: load 1 us, run 0 us, read 1 us | ARM software 0 us
      hand check: C[0][0] = 5*5 + 4*2 + 4*9 + -1*-3 = 72, hardware gave 72
PASS  random INT8, 64x64 folded    64x64x64  4096/4096 correct  passes 64 (eq 64)  cycles 5504 (eq 5504)
      array 110 us | over the bus: load 245 us, run 110 us, read 409 us | ARM software 0 us
...
 ALL BOARD TESTS PASSED (8/8)
```

How to read the second line of each test:

| Number | Where it comes from | What it means |
|---|---|---|
| array | `PERF_CYCLES` / 50 MHz | Time the systolic array spends computing. Same as the equation T = Np(M + 3P − 2). |
| load | ARM timer around the `LOAD_DATA` writes | Moving A and B into the PL, 4 bytes per write. |
| run | ARM timer from start to `done` | Array time plus the ARM polling `STATUS`. |
| read | ARM timer around the `RESULT_DATA` reads | Moving C back, one 32-bit value per read. |
| ARM software | ARM timer around a plain C triple loop | The same multiply on the Cortex-A9 alone. 0 in the Verilator run because no real ARM ran. |

**What to expect on the real board (not measured yet):** every `Xil_Out32` / `Xil_In32` is a
separate bus transaction that takes several times longer than the 5 to 6 clocks the testbench
needs, so `load` and `read` will be larger than in simulation. For 64x64 the ARM software may
well beat the accelerator end to end. That is a result, not a bug: it is the I/O bottleneck,
measured. It is the reason for the next steps below.

---

## Register map (base 0x43C0_0000)

| Offset | Name | R/W | Bits |
|---|---|---|---|
| 0x00 | CTRL | W | [0] start a multiply, [1] run the model (on-chip MLP; wins over [0]). Ignored while busy. Also clears DONE and LOAD_ERR. |
| 0x04 | STATUS | R | [0] busy, [1] done (stays set until the next start), [2] load attempted while busy (dropped) |
| 0x08 | DIMS | RW | [7:0] M, [15:8] K, [23:16] N, [25:24] weight slot a multiply uses. Ignored while busy. (A is M x K, B is K x N) |
| 0x0C | LOAD_PTR | RW | [0] matrix (0 = A, 1 = B), [15:8] row, [23:16] column to start at, [25:24] weight slot B goes into |
| 0x10 | LOAD_DATA | W | 4 INT8 values, byte 0 first. The position moves one column right after each byte and wraps to the next row, so a matrix is one stream of bytes in row order. Bytes past the end are dropped. |
| 0x14 | RESULT_PTR | RW | [7:0] row, [15:8] column of the next C value |
| 0x18 | RESULT_DATA | R | C[row][col], signed 32-bit; the position then moves on (column first, then row) |
| 0x1C | PERF_PASSES | R | Tile passes in the last run: ⌈K/P⌉ · ⌈N/P⌉ |
| 0x20 | PERF_CYCLES | R | Cycles in passes: passes · (M + 3P − 2) |
| 0x24 | PERF_TOTAL | R | All busy cycles (PERF_CYCLES + 3 + PIPE + MEM_REG). After a model run the three counters are sums over its layers |
| 0x28 | INFO | R | [7:0] P, [15:8] input bits, [23:16] accumulator bits, [31:24] MAXD |
| 0x2C | ID | R | 0x4D414331 ("MAC1") |
| 0x30 | CONFIG | R | [7:0] PIPE, [15:8] MEM_REG, [16] core on its own clock, [17] DSP48E1 PEs, [18] on-chip MLP built, [19] postproc deeper than 3 stages (7, or 9 if [29]), [22:20] weight slots, [23] HREAD_REG, [28:24] postproc units, [29] 9-stage postproc (step 15c) |
| 0x34 | MODEL | RW | [1:0] number of layers - 1 |
| 0x38-0x44 | LAYER0-3 | RW | [7:0] N of the layer, [8] ReLU after it (K of layer l = N of layer l-1; K of layer 0 = DIMS.K) |
| 0x48 | PARAM_PTR | RW | [7:0] channel, [9:8] layer, [16] field (0 = bias, 1 = m0 and shift) |
| 0x4C | PARAM_DATA | W | field 0: 32-bit bias; field 1: [15:0] m0, [21:16] shift (1 .. 48). The pointer then moves on: bias, scale, next channel |
| 0x50 | MODEL_CYCLES | R | Clocks of the last model run, start to done |

One multiply, in order: write DIMS; LOAD_PTR = A at (0,0); stream A with LOAD_DATA; the same
for B; CTRL = 1; poll STATUS until done; RESULT_PTR = (0,0); read RESULT_DATA M x N times.

A model (on-chip MLP, `docs/log.md` section 5 step 15), once: for each layer l, DIMS = (1, K_l, N_l),
LOAD_PTR = B in slot l, stream its weights; PARAM_PTR = (layer l, channel 0, bias), stream bias 0,
{shift, m0} 0, bias 1, ...; LAYERl = N_l | ReLU << 8; MODEL = layers - 1. Then for every batch: DIMS =
(M, K_0, N_last), LOAD_PTR = A, stream the rows, CTRL = 2, poll STATUS, RESULT_PTR = (0,0), read
M x N_last raw sums (the ARM adds the last layer's bias).

---

## Troubleshooting

| What you see | Likely cause | Fix |
|---|---|---|
| Script stops: network path | Folder is on `\\Mac\Home\...` | Copy to `C:\` (step 1) |
| `no ZedBoard board files found` | Board files not installed | Vivado Store > Boards > ZedBoard |
| `tb_axi` prints `ERROR: timeout` | Core never reported done | Check the RTL files are the ones from this zip |
| Terminal shows nothing | Wrong COM port, wrong baud, or cable on J17 only | Cable on J14, 115200 8N1 |
| Program hangs at the first register access | PL not programmed (an AXI access to an empty PL never gets a reply) | Run on hardware again so Vitis programs the bitstream first |
| `Accelerator not found at 0x43c00000` | Address differs | Copy the address from the Address Editor into `MAC_BASE` |
| A test FAILs | A real bug, or a version mismatch | Run `tb_axi` in Vivado first; it uses the same data |
| Timing fails at 50 MHz | Long path in the core | Send WNS and the worst path; try P = 4 to confirm the flow first |

---

## Notes

- **Why `mac_axi.v` is plain Verilog:** Vivado's block design can only add a Verilog or VHDL
  file as a module (*Add Module to Block Design*). The core under it stays SystemVerilog.
- **Why 50 MHz and P = 8 first:** the Arty build failed timing at 100 MHz with P = 16. Getting
  one clean build on the board comes before speed. Then raise the clock or P, one at a time.
- **Why the same random seed everywhere:** `tb_axi.sv`, `mac_test.c` and the earlier testbenches
  use the same xorshift generator (seed 0x2468ACE1), so a board failure can be reproduced in simulation.
- **Data movement:** even with an ideal bus, loading and reading take 2.3x (P = 4), 7.0x (P = 8)
  and 17.4x (P = 16) as long as the computing. A bigger array makes this worse, not better,
  because the compute gets faster and the bus does not.

## Next steps toward Machine Guardian

1. **Keep the weights in the PL.** The autoencoder's weights never change, so load them once and
   only send the audio features (A) for each window. That removes the B load from the loop.
2. **Bulk transfers.** Replace 4-byte register writes with AXI DMA (AXI-Stream) or AXI burst
   transfers on an HP port.
3. **INT4 mode** for the adaptive INT4/INT8 path.
4. **Clock enables / gating.** Hold the PEs while weights load (they compute junk then) and while
   idle; compare with Vivado's Report Power using simulation activity.
5. **Sensor input.** An SPI reader in the PL for a Pmod microphone, feeding a sample FIFO.
6. **Ethernet (cluster idea).** On the ZedBoard the Ethernet port belongs to the PS (ARM, lwIP),
   so a cluster of boards keeps this same AXI wrapper; only the ARM software changes.
