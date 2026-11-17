# The host: RP2350 drivers for both chips

Team focus: **Version 1** (`tinytpu_v1.py`). On the Tiny Tapeout demo board the RP2350 (MicroPython) is the host: it keeps the model, selects our design in
the chip's multiplexer, drives the inputs, reads the outputs and makes the clock. These drivers are that host.
The same driver files also run, unchanged, in cocotb against the RTL (`sim/`), so the communication is verified
before there is a chip.

| File | Runs on | What |
|---|---|---|
| `tinytpu_v2.py` | board + sim | Version 2 driver: commands, BURST, POST, READ, whole-model inference, the host's own integer math |
| `tinytpu_v1.py` | board + sim | Version 1 driver: STROBE/ACK handshake, the professor's floating-point host flow |
| `tt_pins.py` | board | Pin layer for the demo board (tt-micropython-firmware) |
| `model_v2.py`, `model_v1.py` | board + sim | The models and their reference results (generated, do not edit) |
| `make_models.py` | PC | Writes the two model files from `../chip_v2/test/modelV2/` and `../chip/test/` |
| `main_v2.py`, `main_v1.py` | board | Board tests: run the models on the chip, check every result, time it |
| `sim/` | PC | cocotb: `sim_pins.py` (pin layer on the testbench), `test_v1_driver.py`, `test_v2_driver.py`, `run.py` |

## How it works

### The pin layer

The drivers never touch hardware directly. They call six methods on a `pins` object:

| Method | Board (`tt_pins.py`) | Simulation (`sim/sim_pins.py`) |
|---|---|---|
| `ui(v)` | `tt.ui_in.value = v` | `dut.ui_in.value = v` |
| `uio(v)` | `tt.uio_in.value = v` | `dut.uio_in.value = v` |
| `clock()` | clock pin high, then low | `clk` high 5 ns, low 5 ns |
| `uo()` | `tt.uo_out.value` | `dut.uo_out.value` |
| `uio_out()` | `tt.uio_out.value` (Version 1's ACK/OVF) | `dut.uio_out.value` |
| `reset()` | `rst_n` low for 5 clocks | same |

That is why the same driver code can be tested in simulation and then run on the board.

### Version 2: one command per clock edge

The driver uses streaming mode (MODE = 1) and makes every clock edge itself, so MicroPython can be as slow as it
likes and the chip still sees exactly one command per edge:

```
            set pins                 clock()        set pins                clock()
 ui_in    : DATA ---------------------|------------ next DATA ---------------|-------
 uio_in   : MODE|VALID|CMD -----------|------------ MODE|VALID|CMD ----------|-------
 clk      : ____________________/‾‾‾‾\______________________________/‾‾‾‾\________
                                  ^ the chip runs the command on this rising edge
```

- **BURST n**: one command, then `n` clocks where `ui_in` is PE 0's weight and `uio_in` is PE 1's weight. Both
  PEs multiply-add on every one of those edges. Then the pins are commands again.
- **Reading**: set `uio_in` to MODE + BSEL (which byte) + PSEL (which PE) with VALID = 0, and read `uo_out`. No
  clock is needed; the output follows the select pins. A 22-bit sum takes three reads; an 8-bit POST output one.
- **After POST** the driver sends 3 idle clocks: PE 0's output lands 2 edges later and PE 1's 3 edges later.

One modelV2 inference (`TinyTPUv2.infer`):

```
CLEAR, LOAD_X x 13                                    inputs into buffer A
layer 1 (13 -> 32), 16 neuron pairs, each:
    CLEAR, LOAD_P x 12 (bias, m0, shift for both)     BURST 13 + 13 weight pairs
    POST (ReLU) + 3 idle                              2 outputs -> buffer B (stay on chip)
CLEAR (next layer)                                    buffer B becomes the input
layer 2 (32 -> 16), 8 pairs, the same                 outputs -> buffer A
CLEAR (next layer)
layer 3 (16 -> 4), 2 pairs: CLEAR, BURST 16, READ     read the 4 raw sums (bypass)
```

That is about 950 clocks. The RP2350 then turns the 4 sums into the answer (`decode`): status = largest of
healthy / developing / faulty, health % = sigmoid of the 4th output.
`infer_bypass` does every layer with READ and lets the RP2350 do bias / rescale / ReLU (`requant`, the same
integer formula as the chip); `infer_host` runs the whole model on the RP2350 alone (the reference).

### Version 1: handshake (the team's focus)

Version 1 is the professor's design: one INT4 PE, and the host does everything else. The pins (`chip/src/project.v`):

| Pin | Direction | What |
|---|---|---|
| `ui_in[3:0]` | RP2350 -> chip | a, the input (signed INT4) |
| `ui_in[7:4]` | RP2350 -> chip | w, the weight (signed INT4) |
| `uio_in[1:0]` | RP2350 -> chip | command: 0 NOP, 1 CLEAR, 2 MAC, 3 READ |
| `uio_in[2]` | RP2350 -> chip | STROBE |
| `uio_in[3]` | RP2350 -> chip | HI: `uo_out` shows the result's high byte |
| `uio_out[4]` | chip -> RP2350 | ACK |
| `uio_out[5]` | chip -> RP2350 | OVF, sticky 16-bit overflow (cleared by CLEAR) |
| `uo_out[7:0]` | chip -> RP2350 | result byte (low, or high with HI = 1) |
| `clk`, `rst_n` | RP2350 -> chip | the RP2350 makes every clock edge |

The chip drives `uio[5:4]`, so the RP2350 drives only `uio[3:0]` (`UIO_DRIVE = 0x0F`).

Every command is a 4-phase handshake (`TinyTPUv1.cmd`), about 6 clocks:

```
 clock edge     :  1   2   3   4   5   6
 STROBE (host)  :  1   1   1   0   0   0     raised before edge 1, lowered once ACK = 1
 ACK (chip)     :  0   0   1   1   1   0     read after each edge
 command        :          runs              a, w and CMD held stable until ACK = 1
```

STROBE goes through a 2-flip-flop synchronizer, so the command runs on the 3rd clock edge after STROBE rises; ACK
rises on that same edge. Then STROBE falls and ACK falls 3 edges later. Because the RP2350 waits for ACK, the
handshake works at any host speed, and also with a free-running clock instead of a stepped one.

- `neuron(a, w)`: CLEAR, one MAC per input, READ, then two reads of `uo_out` (HI = 0, HI = 1) and OVF.
- `infer(tpu, M, x)` is the professor's host flow (`infer_int4` in `model/src/pipeline.py`):
  1. quantize the 8 normalized features to INT4: `q = clip(round(x / s_a0), -7, 7)` (round half to even)
  2. 4 hidden neurons on the chip: `sum = Σ q·w` (CLEAR, 8 MACs, READ each)
  3. on the RP2350: `h = ReLU(sum · s_a0 · s_w0 + b0)`, then quantize `h` with `s_a1`
  4. 2 output neurons on the chip, then `logit = sum · s_a1 · s_w1 + b1`
  5. class = the larger logit (`faulty` / `healthy`)
- One inference: 6 neurons, 52 commands, about 312 clocks.

## On the board

1. Flash the Tiny Tapeout MicroPython firmware (it comes on the demo board) and connect over USB (Thonny or
   `mpremote`).
2. Copy the files to the board, for Version 2: `tinytpu_v2.py`, `tt_pins.py`, `model_v2.py`, `main_v2.py`
   (`mpremote cp tinytpu_v2.py tt_pins.py model_v2.py main_v2.py :`).
3. In the REPL: `import main_v2`. It must end with `ALL TINY-TPU V2 BOARD TESTS PASSED`. For Version 1:
   `tinytpu_v1.py`, `tt_pins.py`, `model_v1.py`, `main_v1.py`, then `import main_v1`.

`tt_pins.TTPins` selects the design by its top module name (`tt_um_titaniumthunder_tiny_tpu_v2` /
`tt_um_titaniumthunder_tiny_tpu`), stops the board's automatic clock, and sets which `uio` pins the RP2350 drives.
The model inputs are the already-quantized features (`model_v2.X`, `model_v1.TEST_X`); computing features from
the vibration sensor on the RP2350 is not part of this yet.

## In simulation

```
cd tinytpu/rp2350/sim
python run.py          # cocotb + Icarus; both tests must pass
```

- Version 2 (`test_v2_driver.py`): all 64 modelV2 rows exact, every one of the 3,072 hidden outputs read back and
  equal to the host's math; 16 rows again without read-back (950 clocks per row) and 16 in bypass mode.
- Version 1 (`test_v1_driver.py`): all 12 of the professor's golden inputs exact: the 6 sums, both logits, the class.
- Planted driver bugs (only 1 idle clock after POST, PSEL on the wrong pin, m0 bytes swapped, Version 1's HI on
  the wrong pin) each make the matching test fail.

Not yet checked: the drivers have not run under MicroPython or on hardware (they use only plain Python that
MicroPython supports). The RP2350's floats are single precision, so `main_v1.py` compares logits to 1e-4.

## After a new model export

Copy the new files into `../chip_v2/test/modelV2/` or `../chip/test/`, run `python make_models.py`, rerun
`sim/run.py`, and copy the new `model_v*.py` to the board.
