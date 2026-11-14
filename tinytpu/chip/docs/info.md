<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

Tiny-TPU is one processing element (PE) of a tiny neural-network accelerator, built by team MAC Attack
(Alex Salamati, James Manikyan, Marco Flores) for a motor-vibration fault detector.

The PE multiplies two signed 4-bit numbers (INT4, an activation `a` and a weight `w`) and adds the product to a
signed 16-bit accumulator. A host microcontroller (the RP2040 on the Tiny Tapeout demo board) keeps the trained
model, streams each neuron's activation/weight pairs to the chip, reads back the 16-bit sum, and finishes the
neuron itself (scale, bias, ReLU).

Commands: `CLEAR` (accumulator = 0), `MAC` (accumulator += a x w), `READ` (copy the accumulator to the output
register), `NOP`. If a MAC would leave the 16-bit range, the OVF flag goes high and stays high until the next
`CLEAR`, so an overflow is never silent.

## How to test

Pins: `a` on `ui_in[3:0]`, `w` on `ui_in[7:4]` (both two's complement), command on `uio_in[1:0]`
(0 NOP, 1 CLEAR, 2 MAC, 3 READ), STROBE on `uio_in[2]`, byte select HI on `uio_in[3]`, ACK on `uio_out[4]`,
OVF on `uio_out[5]`, result byte on `uo_out[7:0]`.

Each command is a 4-phase handshake:

1. Set `a`, `w` and the command.
2. Raise STROBE.
3. Wait for ACK = 1 (the command has run).
4. Lower STROBE and wait for ACK = 0.

To compute a dot product: `CLEAR`, one `MAC` per (a, w) pair, `READ`, then read `uo_out` with HI = 0 (bits 7:0)
and HI = 1 (bits 15:8). Example: MAC(3, 2), MAC(-2, 4), MAC(1, -1) gives 6 - 8 - 1 = -3, read as 0xFFFD.

## External hardware

None beyond the Tiny Tapeout demo board: its RP2040 acts as the host.
