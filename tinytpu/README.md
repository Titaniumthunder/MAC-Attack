# Tiny-TPU: MAC Attack's Tiny Tapeout chip (SKY130)

The 8x8 FPGA design does not fit Tiny Tapeout (16 tiles at most), so the professor's plan (12 Nov 2026, "RSCL
Tiny-TPU" starter kit) is a small chip that a host microcontroller drives: the **RP2350** on the Tiny Tapeout demo
board (bought with the chip, not built) keeps the model and loops through it, and the chip does the multiply-adds.
(The TT04-TT08 demo boards had an RP2040; boards for TT09 and later, including SKY26e, have the RP2350.)
The 8x8 FPGA design, `model/` and `modelV2/` stay as they are.

There are **two versions**. **Team focus (17 Nov 2026): Version 1** is the design we take to tape-out, the
board and the demo; Version 2 stays in the repo as our expansion, paused.

| | **Version 1** (`chip/`): the professor's design | **Version 2** (`chip_v2/`): our expansion |
|---|---|---|
| PEs | 1 | 2 (a 1x2 array) |
| Numbers | INT4 x INT4, 16-bit sum | INT8 x INT8 (INT4 models work too), exact 22-bit sum |
| Host sends | every (input, weight) pair | each layer's inputs once, then 2 weights per clock (BURST) |
| Between layers | host: scale, bias, ReLU in floating point | **on chip**: bias, rescale, ReLU (POST); outputs stay on chip in ping-pong buffers. Bypass (READ) still lets the host do it |
| Models tested | professor's INT4 8-4-2 | professor's INT4 8-4-2 (bypass) **and** our modelV2 INT8 13-32-16-4 fully on chip |
| Tiny Tapeout layout (team review, 16 Nov) | 1 tile (`1x1`), 50 MHz, clean | 16 tiles (`8x2`), 25 MHz, 32 slew + 2 fanout violations left (fix below) |
| On the ZedBoard (same core file, AXI wrapper) | `fpga_zed/` | `fpga_zed_v2/` |

```
 PC (PyTorch)                 RP2350 (host, on the demo board)                 Tiny-TPU chip
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
| `check_signoff.py` | Prints a layout run's electrical / timing / physical checks from its `metrics.csv` |
| `rp2350/` | The host side: MicroPython drivers for both versions on the demo board's RP2350, model files, cocotb tests that run the same drivers against the RTL (`rp2350/README.md`) |
| `fpga_zed_v2/` | Version 2 on the ZedBoard: AXI wrapper around the same `tiny_tpu_v2_core.v`, Vivado script, ARM test program |

The RTL is the `.v` files; everything else is tests, scripts and docs. Plain Verilog on purpose: Yosys (Tiny
Tapeout) reads only part of SystemVerilog, and Vivado 2019.1 block designs need a Verilog top for a module reference.

## Version 1 (`chip/`)

- `src/tiny_tpu_pe.v`: signed INT4 x INT4, signed 16-bit accumulator, CLEAR / MAC / READ / NOP, sticky overflow flag.
  Platform-independent: `fpga_zed/` uses the same file.
- `src/project.v`: top `tt_um_titaniumthunder_tiny_tpu`, STROBE/ACK handshake (pins in the file header, `docs/info.md`).
- Test (`make -B` in `chip/test`, 2/2 pass): all 12 of the professor's golden inferences (624 commands, every READ
  exact), all 256 INT4 products, overflow at 668 x 49 + 1, CLEAR, NOP, slow host. A planted sign bug is caught.
- Tiny Tapeout: the GitHub build passed in `RTL_3D_view` (13 Nov), but its metrics had 33 max-slew violations
  (a green run is not electrical signoff). With the physical settings now in `src/config.json` (slow/fast-corner
  repair, repair after global routing; no RTL change) the team's local LibreLane 3.0.14 run is clean: 0 slew /
  cap / fanout violations, 50 MHz, 1 tile (16 Nov, `docs/tinytapeout-review`). Rerun the GitHub build to confirm.

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
    requantization, and all 256 final sums equal `vectors_C.hex`. 878 clocks per inference (~35 us at 25 MHz).
  - modelV2 in bypass mode (host requantization), rows 0-15 exact.
  - The professor's INT4 model in bypass mode, burst and handshake: 72 sums each, exact.
  - POST fuzz: 60 random layers (random sizes up to 32 x 32, bias, m0, shift 0..47, ReLU on/off): 959 outputs
    exact, read back from the chip's buffer through the array.
  - Edge cases: 200 dual products, per-PE overflow flags, a POST while busy is ignored, CLEAR right after a POST,
    POST in handshake mode, BURST ignored in handshake mode.
  - Planted bugs (no rounding, no buffer swap, PE 1 using PE 0's value in the shared unit) each fail 2-3 tests.
- Verilator -Wall clean.
- Tiny Tapeout layout (team review, 16 Nov, LibreLane 3.0.14, exact RTL): fits `8x2` = 16 tiles; precheck 15/15,
  DRC / LVS / antenna clean, gate-level test 5/5. 50 MHz failed setup (the slow corner reaches about 33 MHz), so
  `CLOCK_PERIOD` is 40 ns (25 MHz, `info.yaml` too); clocks per operation are unchanged. 32 max-slew (worst 0.887 ns
  vs 0.75 ns) and 2 max-fanout (11 vs 10) violations remained. The new physical settings, still no RTL change:
  long-wire buffering (`DESIGN_REPAIR_MAX_WIRE_LENGTH` 400 um), repair to tighter limits than signoff
  (`src/pnr.sdc`: 0.6 ns, fanout 8; `src/signoff.sdc` keeps 0.75 ns and 10). Not run yet: rerun and check with
  `check_signoff.py`.
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
`src/` includes `config.json`, `pnr.sdc` and `signoff.sdc` (the physical settings); copy them too.

A green gds run does **not** show the electrical checks. Download the run's `GDS_logs` artifact and run
`python check_signoff.py runs/wokwi/final/metrics.csv`: it must end with `CLEAN` (0 slew / cap / fanout
violations, setup and hold met, DRC / LVS / antenna clean). For a local run, point it at the project folder.

## Talking to the chip (`rp2350/`)

The RP2350 is wired to all 24 project pins plus clock and reset. It first selects our design in the chip's
multiplexer, then drives `ui_in` and `uio_in`, reads `uo_out`, and makes the clock itself, one edge per command:

```
 RP2350 (demo board)                  Tiny-TPU Version 2
   GPIO --8--> ui_in[7:0]    DATA (PE 0's weight during BURST)
   GPIO --8--> uio_in[7:0]   CMD, VALID, MODE, BSEL, PSEL (PE 1's weight during BURST)
   GPIO <--8-- uo_out[7:0]   selected result byte, or status {ACK, position, OVF1, OVF0}
   GPIO -----> clk, rst_n    the RP2350 makes every clock edge
```

- Version 2: streaming mode, the RP2350 steps the clock (`rp2350/tinytpu_v2.py`). About 950 clocks per modelV2
  inference; the speed is set by MicroPython, not the chip.
- Version 1: the STROBE/ACK handshake from `chip/src/project.v` (`rp2350/tinytpu_v1.py`); the chip drives
  `uio[5:4]` (ACK, OVF), so the RP2350 drives only `uio[3:0]`.
- Both drivers run unchanged in cocotb against the RTL (`python rp2350/sim/run.py`): Version 2 all 64 modelV2
  rows exact (3,072 hidden outputs read back), Version 1 all 12 golden inputs exact (sums, logits, class).

## Shuttle

TTSKY26e (and TTSKY26d, same shuttle CI-2612) closes **30 Nov 2026**; chips are expected about 25 May 2027 and
should ship about 25 June 2027 (https://www.tinytapeout.com/runs, checked 17 Nov 2026). Tiles are bought at
app.tinytapeout.com/prepurchase. The chip will most likely arrive after the capstone ends, so the demo is the
ZedBoard plus simulation.

## Train the model (`model/`)

See `model/README.md`. `chip/test/golden_vectors.json` and `int4_package.json` come from the professor's synthetic
demo run; after a real training run copy the new pair into `chip/test/` (and `chip_v2/test/`), rerun the tests, and
regenerate `fpga_zed/sw/model_data.h` (`python fpga_zed/sw/make_model_header.py`). The demo's 12 golden vectors are
all **healthy** inputs, so the next export should pick test windows from both classes. Version 2's modelV2 data is
in `chip_v2/test/modelV2/` (from `modelV2/export/.../seed0`).

## Open items

Version 1 (the focus):
- Rerun the official Tiny Tapeout GitHub build with the new `chip/src/config.json` and check it with
  `check_signoff.py` (the 13 Nov GitHub build had 33 slew violations; the local run with these settings is clean).
- Run the full ZedBoard test program `fpga_zed/sw/tinytpu_test.c` (5/5).
- Decide on submitting to TTSKY26e (1 tile) before 30 Nov 2026.
- Train on real data with the professor's kit (`model/`); the demo's golden vectors are all healthy inputs.

Version 2 (paused):
- RP2350 drivers: written and verified against the RTL in cocotb; not yet run on hardware (needs the chip, or the
  ZedBoard as a stand-in: the Tiny Tapeout top on its PMOD pins, wired to a Pico 2).
- Version 2 electrical signoff: rerun the layout with the new settings and check it with `check_signoff.py`.
- Both FPGA versions ran on the ZedBoard (16 Nov, short model tests: V1 2/2, V2 3/3, every sum exact). Still to run:
  the full ARM test programs (`fpga_zed/sw/tinytpu_test.c` 5/5, `fpga_zed_v2/sw/tinytpu_v2_test.c` 7/7).
- Show Version 2 to the professor (it extends his contract: INT8, 2 PEs, on-chip post-processing).
- Submit before 30 Nov 2026 (TTSKY26e) if the team decides to: Version 1 is 1 tile; Version 2 is 16 tiles and still
  needs clean electrical signoff. Submitting costs money per tile.
