# Tiny-TPU: MAC Attack's Tiny Tapeout chip (SKY130)

The 8x8 FPGA design does not fit Tiny Tapeout (16 tiles at most), so the professor's plan (12 Nov 2026, "RSCL
Tiny-TPU" starter kit) is a small chip that a host microcontroller drives: the **RP2040** on the Tiny Tapeout demo
board (bought with the chip, not built) keeps the model and loops through it, and the chip does the multiply-adds.
The 8x8 FPGA design, `model/` and `modelV2/` stay as they are.

There are **two versions**:

| | **Version 1** (`chip/`): the professor's design | **Version 2** (`chip_v2/`): our expansion |
|---|---|---|
| PEs | 1 | 2 (a 1x2 array) |
| Numbers | INT4 x INT4, 16-bit sum | INT8 x INT8 (INT4 models work too), exact 22-bit sum |
| Host sends | every (input, weight) pair | each layer's inputs once, then 2 weights per clock (BURST) |
| Between layers | host: scale, bias, ReLU in floating point | **on chip**: bias, rescale, ReLU (POST); outputs stay on chip in ping-pong buffers. Bypass (READ) still lets the host do it |
| Models tested | professor's INT4 8-4-2 | professor's INT4 8-4-2 (bypass) **and** our modelV2 INT8 13-32-16-4 fully on chip |
| Size (Yosys estimate, rough) | ~0.3 tile -> `1x1` | ~10 tiles -> `8x2` (shrink after the first build shows the real area) |
| On the ZedBoard (same core file, AXI wrapper) | `fpga_zed/` | `fpga_zed_v2/` |

```
 PC (PyTorch)                 RP2040 (host, on the demo board)                 Tiny-TPU chip
 train -> INT8/INT4 export -> holds every weight + scale, runs the layers  ->  multiply-adds (V1, V2)
                              (V1: also bias / rescale / ReLU)             <-  V2: + bias / rescale / ReLU,
                                                                               hidden layers stay on chip
```

| Folder | What |
|---|---|
| `model/` | The professor's kit, unchanged: features, PyTorch MLP 8-4-2, INT4 export, golden vectors (`model/README.md`) |
| `chip/` | **Version 1** RTL (`src/tiny_tpu_pe.v`, `src/project.v`), Tiny Tapeout files, cocotb test |
| `fpga_zed/` | Version 1 on the ZedBoard: AXI wrapper around the same `tiny_tpu_pe.v`, Vivado script, ARM test program |
| `chip_v2/` | **Version 2** RTL (`src/tiny_tpu_v2_core.v`, `src/project.v`), Tiny Tapeout files, cocotb test |
| `fpga_zed_v2/` | Version 2 on the ZedBoard: AXI wrapper around the same `tiny_tpu_v2_core.v`, Vivado script, ARM test program |

The RTL is the `.v` files; everything else is tests, scripts and docs. Plain Verilog on purpose: Yosys (Tiny
Tapeout) reads only part of SystemVerilog, and Vivado 2019.1 block designs need a Verilog top for a module reference.

## Version 1 (`chip/`)

- `src/tiny_tpu_pe.v`: signed INT4 x INT4, signed 16-bit accumulator, CLEAR / MAC / READ / NOP, sticky overflow flag.
  Platform-independent: `fpga_zed/` uses the same file.
- `src/project.v`: top `tt_um_titaniumthunder_tiny_tpu`, STROBE/ACK handshake (pins in the file header, `docs/info.md`).
- Test (`make -B` in `chip/test`, 2/2 pass): all 12 of the professor's golden inferences (624 commands, every READ
  exact), all 256 INT4 products, overflow at 668 x 49 + 1, CLEAR, NOP, slow host. A planted sign bug is caught.
- Tiny Tapeout GitHub build: passed in `RTL_3D_view` (13 Nov), `1x1` tile.

## Version 2 (`chip_v2/`)

- `src/tiny_tpu_v2_core.v`: two INT8 PEs with exact 22-bit sums and per-PE overflow flags; two 32-byte buffers
  (ping-pong: inputs in one, outputs into the other, `CLEAR` with DATA = 1 swaps them for the next layer); one shared
  post-processing unit, `y = clamp(((sum + bias) * m0 + 2^(shift-1)) >> shift, ReLU ? 0 : -128, 127)`, the same
  integer step as the FPGA postproc and modelV2, with bias (24-bit), m0 (16-bit) and shift loaded per neuron by
  `LOAD_P`. `READ` is the bypass: raw sums out, host does the math.
- `src/project.v`: top `tt_um_titaniumthunder_tiny_tpu_v2`. Commands on `uio_in[2:0]` (NOP, CLEAR, LOAD_X, MAC,
  READ, BURST, LOAD_P, POST); handshake (any speed, PE 0) or streaming (one command per clock) mode; `BURST n`
  turns the next n clocks into weight pairs on `ui_in` + `uio_in`. All `uio` pins are inputs; ACK is in the status byte.
- Per layer (streaming): first layer `CLEAR`, `LOAD_X` x inputs; per neuron pair `CLEAR`, `LOAD_P` x 12,
  `BURST n` + n pairs, `POST` (ReLU flag); `CLEAR` with DATA = 1 for the next layer; last layer `CLEAR`,
  `BURST n` + pairs, `READ`, read the sums.
- Test (`make -B` in `chip_v2/test`, 5/5 pass, 13 Nov):
  - modelV2 13-32-16-4 **on chip**: all 64 reference rows; all 3,072 on-chip POST outputs equal Python's integer
    requantization, and all 256 final sums equal `vectors_C.hex`. 878 clocks per inference (~18 us at 50 MHz).
  - modelV2 in bypass mode (host requantization), rows 0-15 exact.
  - The professor's INT4 model in bypass mode, burst and handshake: 72 sums each, exact.
  - POST fuzz: 60 random layers (random sizes up to 32 x 32, bias, m0, shift 0..47, ReLU on/off): 959 outputs
    exact, read back from the chip's buffer through the array.
  - Edge cases: 200 dual products, per-PE overflow flags, a POST while busy is ignored, CLEAR right after a POST,
    POST in handshake mode, BURST ignored in handshake mode.
  - Planted bugs (no rounding, no buffer swap, PE 1 using PE 0's value in the shared unit) each fail 2-3 tests.
- Verilator -Wall clean. Not yet run through the Tiny Tapeout GitHub build.
- ZedBoard version (`fpga_zed_v2/`, see its README): the ARM drives the same core over AXI4-Lite (one write =
  1, 2 or 4 core steps). The ARM test program itself, run against the RTL in a Verilator co-simulation, passes
  7/7 (all 65,536 INT8 products on both PEs, overflow flags, modelV2 on chip and in bypass for all 64 rows, the
  professor's INT4 model); a cocotb AXI test passes 3/3. Not yet built in Vivado.

### Run a test

```
cd tinytpu/chip_v2/test              # or tinytpu/chip/test for Version 1
pip install -r requirements.txt      # cocotb; also needs Icarus Verilog
make -B                              # Version 2 must end with TESTS=5 PASS=5 FAIL=0
```

### Build the layout and 3D view (free, no submission)

Repo from https://github.com/TinyTapeout/ttsky-verilog-template (Public), Settings -> Pages -> Source: GitHub
Actions, upload the **contents** of `chip/` or `chip_v2/` (info.yaml, src/, test/, docs/) to the repo root. The gds
run gives the layout, a gate-level rerun of the test, and the 3D viewer at `https://<owner>.github.io/<repo>/`.

## Train the model (`model/`)

See `model/README.md`. `chip/test/golden_vectors.json` and `int4_package.json` come from the professor's synthetic
demo run; after a real training run copy the new pair into `chip/test/` (and `chip_v2/test/`), rerun the tests, and
regenerate `fpga_zed/sw/model_data.h` (`python fpga_zed/sw/make_model_header.py`). The demo's 12 golden vectors are
all **healthy** inputs, so the next export should pick test windows from both classes. Version 2's modelV2 data is
in `chip_v2/test/modelV2/` (from `modelV2/export/.../seed0`).

## Open items

- RP2040 host driver (MicroPython or C) for Version 2's commands.
- Build `fpga_zed/` and `fpga_zed_v2/` in Vivado and run their ARM test programs on the ZedBoard.
- Show Version 2 to the professor (it extends his contract: INT8, 2 PEs, on-chip post-processing).
- Tiny Tapeout SKY shuttle deadline (Nov 30 per the professor): confirm on app.tinytapeout.com; submitting costs money per tile.
