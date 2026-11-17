# Tiny-TPU on the ZedBoard

The FPGA prototype of the Tiny-TPU chip. The ARM plays the host (the RP2350's job on the Tiny Tapeout board)
over AXI4-Lite. The processing element is **the same file as the chip**, `../chip/src/tiny_tpu_pe.v`; only
`tiny_tpu_axi.v` is FPGA-specific.

| File | What |
|---|---|
| `tiny_tpu_axi.v` | AXI4-Lite wrapper: one write to CMD = one command, executed before the write response |
| `create_tinytpu_zed_project.tcl` | Vivado 2019.1 project + block design (Zynq -> interconnect -> tiny_tpu_axi, 100 MHz) |
| `sw/tinytpu_test.c` | ARM test program (SDK, standalone) |
| `sw/model_data.h` | The INT4 model and test vectors for the program (generated) |
| `sw/make_model_header.py` | Writes `model_data.h` from `../chip/test/int4_package.json` + `golden_vectors.json` |
| `sim/test_axi.py`, `sim/run.py` | cocotb simulation of the wrapper over AXI (`python run.py`; needs cocotb, cocotbext-axi, Icarus) |
| `sw/tinytpu_model_test.c` | ARM test program (16 Nov): the professor's model on the same 64 rows, checks and printout as `MAC_model_TinyTPU` and Version 2's `tinytpu_model_test`, in host mode |
| `sw/tinytpu_model.h` | Its model and rows, written by `../mac_mlp/export_mac_mlp.py` (the same file as the other two boards') |
| `sim/xsim_cosim/` | Runs either ARM program against the RTL in **Vivado's simulator** (DPI-C; only Vivado needed): `run_xsim_cosim.bat <program>` |
| `build_bitstream.tcl`, `sdk_build.tcl`, `run_on_board.tcl` | No-GUI build and board run (16 Nov), as in `../fpga_zed_v2` |

## Open the committed project and run it (no rebuild)

Since 16 Nov 2026 the Vivado project `tinytpu_zed_project/` is in git with its results, like the MAC Attack project
(`.gitignore` lists exactly what is tracked): the project, the block design, the bitstream and reports, and the SDK
applications `model_v2_test` (despite its name, the Tiny-TPU model test: modelV2 cannot run on Version 1) and `tinytpu_test` (sources and project files). Not in git: the exported `.hdf`, the hardware platform and the
BSP. Every application expects a BSP named **`model_v2_test_bsp`**.

1. Open `tinytpu_zed_project\tinytpu_zed.xpr` in Vivado 2019.1. If it says the runs are out of date, do not rebuild.
2. **File > Export > Export Hardware**, tick *Include bitstream*, `<Local to Project>`. Then **File > Launch SDK**
   (both locations `<Local to Project>`).
3. In the SDK: **File > New > Board Support Package**, name `model_v2_test_bsp`, standalone, `ps7_cortexa9_0`.
4. **File > Import > General > Existing Projects into Workspace**, root directory the `.sdk` folder, select the
   applications, leave "Copy projects into workspace" unticked. Build each one (Release).
5. Board on (J17 JTAG, J14 UART at 115200 8N1, jumpers on JTAG): right-click an application > Run As > Run
   Configurations > Target Setup: tick Reset entire system, Program FPGA, Run ps7_init and Run ps7_post_config,
   then Run. Expected last lines: `model_v2_test` ALL TINY-TPU MODEL TESTS PASSED (2/2), `tinytpu_test` ALL TINY-TPU TESTS PASSED (5/5).

Full walkthrough: `docs/guides/TinyTPU_Vivado_SDK_guide.pdf`. Board results of 16 Nov:
`docs/Model/16_TinyTPU_V1_V2_ZedBoard_run.pdf`.

## Registers (base 0x43C00000 unless Vivado assigns another)

| Offset | Name | |
|---|---|---|
| 0x00 | CMD | write: `[3:0]` a, `[7:4]` w (signed INT4), `[9:8]` command: 0 NOP, 1 CLEAR, 2 MAC, 3 READ |
| 0x04 | RESULT | read: 16-bit result of the last READ, sign-extended |
| 0x08 | STATUS | read: `[0]` OVF (sticky overflow, cleared by CLEAR) |
| 0x0C | ID | read: `0x54505534` ("TPU4") |

## Steps

1. Vivado 2019.1: **Tools > Run Tcl Script...** -> `create_tinytpu_zed_project.tcl`. Check the printed tpu
   address (0x43C00000; otherwise change `TPU_BASE` in `sw/tinytpu_test.c`).
2. **Generate Bitstream**, then **File > Export > Export Hardware** (include bitstream), then **Launch SDK**.
3. In the SDK: new Application Project for ps7_cortexa9_0, Hello World template. Replace `helloworld.c` with
   `sw/tinytpu_test.c` and add `sw/model_data.h`. Use the **Release** build (-O2). If the linker can't
   find `rint`, add the math library (`m`) under C/C++ Build Settings > Linker > Libraries.
4. Program the FPGA, run, and watch the USB-UART (J14) at 115200 8N1. It must end with
   `ALL TINY-TPU TESTS PASSED (5/5)`.

What the program checks: the ID; the 12 golden inferences command by command (72 READs); the real host flow
(the ARM computes its own INT4 operands, logits and class, which must equal the Python reference); all 256 INT4
products; the overflow flag; then it times one inference with the PE against the ARM alone.

**Expect the ARM alone to be faster.** Every multiply-add is one bus write, and an 8x8-bit multiply is one
instruction on the ARM. This PE proves the arithmetic in hardware; it is not a speedup on its own.

## Without the GUI, and the model test (16 Nov 2026)

From a Command Prompt in this folder (board: J17 JTAG, J14 UART, terminal at 115200 8N1, boot jumpers on JTAG):
```
C:\Xilinx\Vivado\2019.1\bin\vivado.bat -mode batch -source build_bitstream.tcl    (ends with BUILD OK)
C:\Xilinx\SDK\2019.1\bin\xsct.bat sdk_build.tcl                                     (ends with SDK BUILD OK)
C:\Xilinx\SDK\2019.1\bin\xsct.bat run_on_board.tcl tinytpu_model_test               (ALL TINY-TPU MODEL TESTS PASSED (2/2))
C:\Xilinx\SDK\2019.1\bin\xsct.bat run_on_board.tcl tinytpu_test                     (ALL TINY-TPU TESTS PASSED (5/5))
```
`tinytpu_model_test` runs the professor's model on the same 64 rows as the MAC Attack accelerator's
`MAC_model_TinyTPU` and Version 2's `tinytpu_model_test` (12 golden + 52 random INT4 rows): ARM alone, then host
mode, every multiply-add on the PE (52 commands per row), the float step on the ARM. Version 1 has no on-chip
step, so there is no on-chip mode. modelV2 cannot run here: its weights and inputs are INT8, the PE takes INT4.

Vivado co-simulation (`sim\xsim_cosim\run_xsim_cosim.bat <program>`, 16 Nov): `tinytpu_model_test` 2/2 (256/256/128
sums, 256 hidden values, 64/64 classes, golden logits equal to the expected ones); `tinytpu_test` 5/5.

## After training a real model

Copy the new `int4_package.json` and `golden_vectors.json` into `../chip/test/`, run
`python sw/make_model_header.py`, rerun the chip test (`../chip/test`, `make -B`), and rebuild the SDK app.

## Block design by hand (if the script's block-design step fails)

Create Block Design `system` -> add ZYNQ7 Processing System, Run Block Automation (board preset) -> in the Zynq,
enable M_AXI_GP0 and set FCLK_CLK0 to 100 MHz -> drag `tiny_tpu_axi` from Sources into the diagram ->
Run Connection Automation (connects AXI, clock and reset) -> Address Editor: assign -> Validate -> Create HDL
Wrapper (let Vivado manage) -> set it as top.
