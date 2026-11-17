# Tiny-TPU Version 2 on the ZedBoard

The FPGA prototype of the Version 2 chip. The ARM plays the host (the RP2040's job on the Tiny Tapeout board)
over AXI4-Lite. The core is **the same file as the chip**, `../chip_v2/src/tiny_tpu_v2_core.v`; only
`tiny_tpu_v2_axi.v` is FPGA-specific. It takes the place of the chip's pins (`../chip_v2/src/project.v`).

| File | What |
|---|---|
| `tiny_tpu_v2_axi.v` | AXI4-Lite wrapper: each write runs 1, 2 or 4 core steps back to back; the response waits until they are done |
| `create_tinytpu_v2_zed_project.tcl` | Vivado 2019.1 project + block design (Zynq -> interconnect -> tiny_tpu_v2_axi, 50 MHz since 16 Nov: 100 MHz missed timing) |
| `sw/tinytpu_v2_test.c` | ARM test program: the core's own hardware test (SDK, standalone) |
| `sw/model_v2_test.c` | ARM test program: modelV2, the same test as `MAC_model_V2` on the MAC Attack accelerator (16 Nov) |
| `sw/tinytpu_model_test.c` | ARM test program: the professor's Tiny-TPU RSCL model, the same test as `MAC_model_TinyTPU` (16 Nov) |
| `sw/tpu_v2_driver.h` | The core's driver (register sequences), shared by the two model programs |
| `sw/tinytpu_model.h` | The Tiny-TPU model and its 64 test rows, written by `../mac_mlp/export_mac_mlp.py` (same file as `MAC_model_TinyTPU`'s) |
| `sw/model_v2_data.h` | modelV2 (64 rows) and the professor's INT4 model, for the program (generated) |
| `sw/make_model_v2_header.py` | Writes `model_v2_data.h` from `../chip_v2/test/` (modelV2/ and golden_vectors.json) |
| `sim/test_axi_v2.py`, `sim/run.py` | cocotb simulation with a standard AXI master (`python run.py`; cocotb, cocotbext-axi, Icarus) |
| `sim/cosim/` | Runs `sw/tinytpu_v2_test.c` itself against the RTL (`sh run_cosim.sh`; Verilator) |
| `sim/xsim_cosim/` | Runs any of the three ARM programs against the RTL in **Vivado's simulator** (DPI-C; only Vivado needed): `run_xsim_cosim.bat <program>` |
| `build_bitstream.tcl` | No-GUI build (16 Nov): project, bitstream, timing check, hardware export (`vivado -mode batch -source`) |
| `sdk_build.tcl` | No-GUI build of the three ARM programs: BSP from `hsi`, SDK make and ARM gcc, Release, libm (`xsct sdk_build.tcl`) |
| `run_on_board.tcl` | Programs the board over JTAG and starts one program (`xsct run_on_board.tcl <program>`) |

## Open the committed project and run it (no rebuild)

Since 16 Nov 2026 the Vivado project `tinytpu_v2_zed_project/` is in git with its results, like the MAC Attack project
(`.gitignore` lists exactly what is tracked): the project, the block design, the bitstream and reports, and the SDK
applications `model_v2_test`, `tinytpu_model_test` and `tinytpu_v2_test` (sources and project files). Not in git: the exported `.hdf`, the hardware platform and the
BSP. Every application expects a BSP named **`model_v2_test_bsp`**.

1. Open `tinytpu_v2_zed_project\tinytpu_v2_zed.xpr` in Vivado 2019.1. If it says the runs are out of date, do not rebuild.
2. **File > Export > Export Hardware**, tick *Include bitstream*, `<Local to Project>`. Then **File > Launch SDK**
   (both locations `<Local to Project>`).
3. In the SDK: **File > New > Board Support Package**, name `model_v2_test_bsp`, standalone, `ps7_cortexa9_0`.
4. **File > Import > General > Existing Projects into Workspace**, root directory the `.sdk` folder, select the
   applications, leave "Copy projects into workspace" unticked. Build each one (Release).
5. Board on (J17 JTAG, J14 UART at 115200 8N1, jumpers on JTAG): right-click an application > Run As > Run
   Configurations > Target Setup: tick Reset entire system, Program FPGA, Run ps7_init and Run ps7_post_config,
   then Run. Expected last lines: `model_v2_test` ALL MODEL TESTS PASSED (3/3), `tinytpu_model_test` ALL TINY-TPU MODEL TESTS PASSED (3/3), `tinytpu_v2_test` ALL TINY-TPU V2 TESTS PASSED (8/8).

Full walkthrough: `docs/guides/TinyTPU_Vivado_SDK_guide.pdf`. Board results of 16 Nov:
`docs/Model/16_TinyTPU_V1_V2_ZedBoard_run.pdf`.

## Registers (base 0x43C00000 unless Vivado assigns another)

| Offset | Name | |
|---|---|---|
| 0x00 | CMD | write: `[10:8]` command, `[7:0]` data. 0 NOP, 1 CLEAR (data 1 = next layer), 2 LOAD_X, 3 MAC (PE 0), 4 READ, 6 LOAD_P, 7 POST (data bit 0 ReLU, bit 1 PE 0 only) |
| 0x04 | PAIR | write: `[7:0]` weight for PE 0, `[15:8]` for PE 1: one dual MAC |
| 0x08 | PAIR2 | write: two dual MACs (`[15:0]` first pair, `[31:16]` second) |
| 0x0C | LOADX4 | write: four inputs (LOAD_X), `[7:0]` first |
| 0x10 | LOADP4 | write: four parameter bytes (LOAD_P); a neuron pair's 12 bytes = 3 writes |
| 0x14 | RESULT0 | read: PE 0's result, sign-extended (raw sum after READ, 8-bit output after POST) |
| 0x18 | RESULT1 | read: PE 1's result |
| 0x1C | STATUS | read: `[0]` OVF0, `[1]` OVF1, `[6:2]` input position |
| 0x20 | ID | read: `0x54505538` ("TPU8") |
| 0x24 | STEPS | read: core steps run since reset (one per clock) |

The chip's `BURST` (two weights per clock on the pins) becomes `PAIR` / `PAIR2` here.
A write's response comes back only when its steps are done (after a `POST`, when both outputs are in place),
so the program never polls: write, write, ..., read.

## Steps

1. Vivado 2019.1: **Tools > Run Tcl Script...** -> `create_tinytpu_v2_zed_project.tcl`. Check the printed tpu
   address (0x43C00000; otherwise change `TPU_BASE` in `sw/tinytpu_v2_test.c`).
2. **Generate Bitstream**. Open the implemented design and check timing: WNS must be 0 or more. If it is
   negative, set `FCLK_MHZ` to 50 in the script and run it again.
3. **File > Export > Export Hardware** (include bitstream), then **Launch SDK**.
4. In the SDK: new Application Project for ps7_cortexa9_0, Hello World template. Replace `helloworld.c` with
   `sw/tinytpu_v2_test.c` and add `sw/model_v2_data.h`. Use the **Release** build (-O2). If the linker can't
   find `exp`, add the math library (`m`) under C/C++ Build Settings > Linker > Libraries.
   For the two model tests make one more application each, the same way: `sw/model_v2_test.c` +
   `model_v2_data.h` + `tpu_v2_driver.h`, and `sw/tinytpu_model_test.c` + `tinytpu_model.h` + `tpu_v2_driver.h`.
5. Program the FPGA, run, and watch the USB-UART (J14) at 115200 8N1. It must end with
   `ALL TINY-TPU V2 TESTS PASSED (8/8)`.

What the program checks: the ID; all 65,536 INT8 products on both PEs; the per-PE overflow flags; modelV2
on chip for all 64 rows (every POST output against the ARM's own integer math, every final sum against
`vectors_C`); modelV2 in bypass mode; the professor's INT4 model in bypass mode (72 sums); the professor's
model through its whole host flow (the ARM makes the hidden INT4 values from the chip's sums and prints the
predicted class, test 6b, added 16 Nov); then it times modelV2 on the core against the ARM alone.

**Without the GUI** (16 Nov), from a Command Prompt in this folder:
```
C:\Xilinx\Vivado\2019.1\bin\vivado.bat -mode batch -source build_bitstream.tcl    (ends with BUILD OK)
C:\Xilinx\SDK\2019.1\bin\xsct.bat sdk_build.tcl                                     (ends with SDK BUILD OK)
C:\Xilinx\SDK\2019.1\bin\xsct.bat run_on_board.tcl model_v2_test                    (board on, terminal open)
C:\Xilinx\SDK\2019.1\bin\xsct.bat run_on_board.tcl tinytpu_model_test
C:\Xilinx\SDK\2019.1\bin\xsct.bat run_on_board.tcl tinytpu_v2_test
```
`sdk_build.tcl` does not use the SDK's Eclipse commands (`createhw`, `createapp`): in SDK 2019.1 they fail when
the folder path has a space in it, as `C:\Users\James Manikyan\...` does. It makes the BSP with `hsi` and builds
each program with the SDK's own make and ARM gcc in `tinytpu_v2_zed_project/sw_build/<program>/`.

## The two model tests (16 Nov): the same tests as on the MAC Attack accelerator

`model_v2_test` and `tinytpu_model_test` run the same models, rows, checks and printout as the MAC Attack
accelerator's `MAC_model_V2` and `MAC_model_TinyTPU` (`docs/Model/15_ZedBoard_run_modelV2_and_TinyTPU.pdf`), so
the two boards' outputs can be compared line by line. Differences come from the hardware: the core takes one
row at a time (no "rows per run") and keeps no weights, so the model is sent with every row.

| Program | Tests | Last line |
|---|---|---|
| `model_v2_test` | ARM alone; on chip (hidden layers by POST); bypass (ARM requantizes); then status and health % for every 7th row | `ALL MODEL TESTS PASSED (3/3)` |
| `tinytpu_model_test` | ARM alone (professor's contract); host mode (core sums, ARM float step); on chip (layer 0's step by POST: bias 17, 9, -5, 14, m0 47624, shift 20); then the 12 golden rows' logits | `ALL TINY-TPU MODEL TESTS PASSED (3/3)` |

### Vivado co-simulation (16 Nov 2026)

`sim\xsim_cosim\run_xsim_cosim.bat <program>` compiles the board program unchanged (main renamed) into Vivado's
simulator; its `Xil_Out32` / `Xil_In32` become AXI transactions on `tiny_tpu_v2_axi` + the chip's core file.

- `model_v2_test`: 3/3. 256/256 sums on chip and in bypass; every printed sum, status and health % is
  identical to the MAC Attack board run (for example row 63: faulty, 76.1 %). Core 852 clocks per row on chip,
  612 in bypass.
- `tinytpu_model_test`: 3/3. Host mode 256/256/128 and 64/64 classes; on chip 128/128 sums, 64/64 classes,
  golden rows = contract 12/12; golden logits equal to the expected ones to the last digit. Core 60 clocks per
  row on chip (1.2 us at 50 MHz), 40 in host mode.
- `tinytpu_v2_test`: 8/8, test 6b included (its first run against the RTL).
- In the simulation the ARM's own work takes no time, so "ARM alone" shows 0 us and no speedup is printed.

**Expect the ARM alone to be faster.** One inference is 387 bus writes (in simulation the core itself
needs 852 clocks, 17 us at the 50 MHz the board build uses). This is a prototype of the chip, to prove its RTL on real hardware before
the tape-out; the speedup design is the 8x8 array in `rtl/` and `zed/`.

## Simulation results (14 Nov 2026)

Test 6b (16 Nov) is not in these runs; it passed against the RTL in the Vivado co-simulation (above).

- `sim/cosim` (the ARM program itself, unchanged, on the RTL, with random AXI handshake delays): 7/7 pass with
  waits of 0, 2 and 5 clocks.
- `sim/run.py` (cocotbext-axi master): 3/3 pass. modelV2 on chip, 64 rows, all 3,072 POST outputs and
  256 final sums exact; write-response timing; registers.
- Planted wrapper bugs (no wait after POST, response before the steps finish, PAIR2 shifting by one byte,
  LOADP4 sending LOAD_X) each fail at least one test.
- Verilator -Wall clean. Yosys 7-series estimate: about 1,800 LUTs, 970 flip-flops, 3 DSP48E1 (the
  XC7Z020 has 53,200 LUTs and 220 DSPs). Timing is checked only by Vivado (step 2).

## After a new model export

Copy the new files into `../chip_v2/test/` (modelV2/ and golden_vectors.json), run
`python sw/make_model_v2_header.py`, rerun the chip test and `sim/cosim/run_cosim.sh`, and rebuild the SDK app.

## Block design by hand (if the script's block-design step fails)

Create Block Design `system` -> add ZYNQ7 Processing System, Run Block Automation (board preset) -> in the Zynq,
enable M_AXI_GP0 and set FCLK_CLK0 to 50 MHz -> drag `tiny_tpu_v2_axi` from Sources into the diagram ->
Run Connection Automation (connects AXI, clock and reset) -> Address Editor: assign -> Validate -> Create HDL
Wrapper (let Vivado manage) -> set it as top.
