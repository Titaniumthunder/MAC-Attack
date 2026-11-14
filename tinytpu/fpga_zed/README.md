# Tiny-TPU on the ZedBoard

The FPGA prototype of the Tiny-TPU chip. The ARM plays the host (the RP2040's job on the Tiny Tapeout board)
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

## After training a real model

Copy the new `int4_package.json` and `golden_vectors.json` into `../chip/test/`, run
`python sw/make_model_header.py`, rerun the chip test (`../chip/test`, `make -B`), and rebuild the SDK app.

## Block design by hand (if the script's block-design step fails)

Create Block Design `system` -> add ZYNQ7 Processing System, Run Block Automation (board preset) -> in the Zynq,
enable M_AXI_GP0 and set FCLK_CLK0 to 100 MHz -> drag `tiny_tpu_axi` from Sources into the diagram ->
Run Connection Automation (connects AXI, clock and reset) -> Address Editor: assign -> Validate -> Create HDL
Wrapper (let Vivado manage) -> set it as top.
