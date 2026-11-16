# Tiny-TPU Version 2 on the ZedBoard

The FPGA prototype of the Version 2 chip. The ARM plays the host (the RP2040's job on the Tiny Tapeout board)
over AXI4-Lite. The core is **the same file as the chip**, `../chip_v2/src/tiny_tpu_v2_core.v`; only
`tiny_tpu_v2_axi.v` is FPGA-specific. It takes the place of the chip's pins (`../chip_v2/src/project.v`).

| File | What |
|---|---|
| `tiny_tpu_v2_axi.v` | AXI4-Lite wrapper: each write runs 1, 2 or 4 core steps back to back; the response waits until they are done |
| `create_tinytpu_v2_zed_project.tcl` | Vivado 2019.1 project + block design (Zynq -> interconnect -> tiny_tpu_v2_axi, 100 MHz) |
| `sw/tinytpu_v2_test.c` | ARM test program (SDK, standalone) |
| `sw/model_v2_data.h` | modelV2 (64 rows) and the professor's INT4 model, for the program (generated) |
| `sw/make_model_v2_header.py` | Writes `model_v2_data.h` from `../chip_v2/test/` (modelV2/ and golden_vectors.json) |
| `sim/test_axi_v2.py`, `sim/run.py` | cocotb simulation with a standard AXI master (`python run.py`; cocotb, cocotbext-axi, Icarus) |
| `sim/cosim/` | Runs `sw/tinytpu_v2_test.c` itself against the RTL (`sh run_cosim.sh`; Verilator) |

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
5. Program the FPGA, run, and watch the USB-UART (J14) at 115200 8N1. It must end with
   `ALL TINY-TPU V2 TESTS PASSED (7/7)`.

What the program checks: the ID; all 65,536 INT8 products on both PEs; the per-PE overflow flags; modelV2
on chip for all 64 rows (every POST output against the ARM's own integer math, every final sum against
`vectors_C`); modelV2 in bypass mode; the professor's INT4 model in bypass mode (72 sums); then it times
modelV2 on the core against the ARM alone.

**Expect the ARM alone to be faster.** One inference is 387 bus writes (in simulation the core itself
needs 852 clocks, 8.5 us at 100 MHz). This is a prototype of the chip, to prove its RTL on real hardware before
the tape-out; the speedup design is the 8x8 array in `rtl/` and `zed/`.

## Simulation results (14 Nov 2026)

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
enable M_AXI_GP0 and set FCLK_CLK0 to 100 MHz -> drag `tiny_tpu_v2_axi` from Sources into the diagram ->
Run Connection Automation (connects AXI, clock and reset) -> Address Editor: assign -> Validate -> Create HDL
Wrapper (let Vivado manage) -> set it as top.
