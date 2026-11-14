<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

Tiny-TPU v2 is a small neural-network accelerator by team MAC Attack (Alex Salamati, James Manikyan,
Marco Flores) for a motor-vibration fault detector. It runs a multilayer perceptron layer by layer while the host
(the RP2040 on the demo board) streams in the weights.

- **Two processing elements** (a 1x2 array): each multiplies signed 8-bit numbers and adds them into an exact
  22-bit sum. In a **BURST**, two weights arrive per clock (`ui_in` and `uio_in`), so both PEs work on two neurons
  at once.
- **Two 32-byte buffers** (ping-pong): the PEs read a layer's inputs from one while the outputs go into the other.
  `CLEAR` with "next layer" swaps them, so hidden-layer results never leave the chip.
- **On-chip post-processing** (`POST`): `y = clamp(((sum + bias) * m0 + 2^(shift-1)) >> shift, ReLU ? 0 : -128, 127)`,
  the same integer step as the team's FPGA design. One shared unit does PE 0 then PE 1.
- **Bypass**: `READ` gives the raw 22-bit sums instead, so the host can do the post-processing itself.

Any model with layers of at most 32 inputs and 32 outputs loads at run time; nothing about the model is built in.

## How to test

Pins: DATA `ui_in`; CMD `uio_in[2:0]` (0 NOP, 1 CLEAR, 2 LOAD_X, 3 MAC, 4 READ, 5 BURST, 6 LOAD_P, 7 POST);
STROBE/VALID `uio_in[3]`; MODE `uio_in[4]` (0 handshake, 1 streaming); BSEL `uio_in[6:5]`; PSEL `uio_in[7]`.
`uo_out` shows the selected PE's result bits 7:0 / 15:8 / 21:16 (BSEL 0/1/2) or the status byte
{ACK, input position, OVF1, OVF0} (BSEL 3). The result is the raw sum after READ, or the 8-bit output
(sign-extended) after POST.

Streaming (MODE 1): every rising clock with VALID = 1 runs CMD on DATA; `BURST n` makes the next n clocks weight
pairs. Per layer: `CLEAR`, `LOAD_X` each input (first layer only); per neuron pair: `CLEAR`, `LOAD_P` x 12
(per PE: bias 3 bytes, m0 2 bytes, shift), `BURST n` + n weight pairs, `POST` (DATA bit 0 = ReLU, bit 1 = PE 0 only);
then `CLEAR` with DATA = 1 for the next layer. Last layer: `CLEAR`, `BURST n` + pairs, `READ`, read the sums.
Handshake (MODE 0, any host speed, PE 0 only): set DATA and CMD, raise STROBE, wait for ACK = 1 (status bit 7,
BSEL = 3), lower STROBE, wait for ACK = 0.

## External hardware

None beyond the Tiny Tapeout demo board: its RP2040 acts as the host.
