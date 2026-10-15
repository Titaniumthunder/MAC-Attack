# MAC Attack — Python Golden Model for `mac_test.c`

This package reproduces the eight ZedBoard/Vitis test cases **exactly as in the uploaded C source**. The standalone Python script requires Python 3.9+ and no third-party libraries.

## Files

- `mac_golden_model.py` — signed INT8 → INT32 golden matrix multiplication, C-identical random inputs, expected passes and cycles, AXI write vector exports, and UART result checker.
- `mac_test.c` — your **unaltered** original C program.
- `mac_test_uart_dump.c` — your C program with an **optional post-timing UART dump**, allowing the Python checker to independently verify **every** hardware output.
- `mac_golden_vectors/` — all eight cases, with `*_A.csv`, `*_B.csv`, `*_C_expected.csv`, and `*_axi_writes.csv`, plus `golden_summary.json`. These were generated for **P=16**; regenerate them if your array size differs.

## 1. Run the Python model (on your laptop, not in Vitis)

```bash
python3 mac_golden_model.py --array-size 16
```

**Important:** use the **actual array size** printed by the board (`Found it: PxP array`). The default is 16 only as an example. The model calculates

```
passes = ceil(K / P) * ceil(N / P)
cycles = passes * (M + 3*P - 2)
```

For a 16×16 array and a 64×64 matrix multiplication, expected `passes=16`, `cycles=1760`.

## 2. Verify the **original** C program's UART summary

1. Program your ZedBoard with the Vivado `.bit`/`.xsa`-based hardware and run the original `mac_test.c` as a standalone Vitis application.
2. Capture the complete USB-UART output at **115200 baud, 8N1** to `board_uart.txt` using PuTTY, Tera Term, minicom, etc.
3. Run:

```bash
python3 mac_golden_model.py --array-size 16 --uart-log board_uart.txt
```

The checker verifies the original C's eight PASS/FAIL lines, reported dimensions, correct-element counts, measured/expected pass counts, and measured/expected cycles. If available, it also checks the first test's hand-calculated element. **This mode relies on the ARM-side comparison performed by the C program; it cannot independently inspect every element because the original program does not print them.**

## 3. Independently verify **all** FPGA result entries

1. In Vitis, use `mac_test_uart_dump.c` instead of `mac_test.c`. It keeps the tests and expected values unchanged. It adds these lines **after** each case's timing measurements:

```
GOLDEN_BEGIN 1 4 4 4
GOLDEN_ROW 0 72 ...
...
GOLDEN_END 1
```

2. Capture the **entire** UART log including all eight cases and all `GOLDEN_ROW` lines. The folded 64×64 case prints 4,096 results and may take a few seconds at 115200 baud.
3. Run:

```bash
python3 mac_golden_model.py --array-size 16 --uart-log board_uart.txt --require-dumps
```

Python checks each C result against its **independently generated** matrix output, reporting the first wrong position and value (`C[i][j]`) plus the number of mismatches. It also verifies the C PASS summaries and cycle counts. A zero exit status indicates all comparisons passed; nonzero indicates a mismatch or missing data.

To disable the extra printing in the optional C source, compile with `-DMAC_GOLDEN_DUMP=0` (or change its default macro to 0).

## 4. Export inputs and expected outputs for simulation or debugging

```bash
python3 mac_golden_model.py --array-size 16 --export-dir golden_vectors
```

For each test, the resulting files contain:

- `*_A.csv`: signed decimal INT8 A matrix in row order (M × K).
- `*_B.csv`: signed decimal INT8 B matrix in row order (K × N).
- `*_C_expected.csv`: signed decimal INT32 C matrix (M × N).
- `*_axi_writes.csv`: `offset_hex,value_hex` table, reproducing C's write order, DIM register and packed `LOAD_DATA` values. Every 32-bit word packs four consecutive row-major bytes, **first byte in bits [7:0]**, with zero-fill in any unfinished final word. Hardware must ignore padding beyond the logical matrix size.
- `golden_summary.json`: dimensions, PRNG seed before/after, expected cycles/passes, first result, and word counts.

The first case is 4×4. **Do not reset the xorshift state between cases**: the C code advances a single generator throughout all eight tests. Cases filled with -128 or 127 do **not** consume PRNG values; B identity also does not consume any.

## What is verified, and what is not

The Python implementation was checked against the **original C generator and software multiplication compiled on the host**. For each of the 8 cases, checksums over **every A byte, every B byte, every signed INT32 C byte**, and the end-of-case RNG state matched. The checker was also tested against a simulated UART transcript containing an intentional wrong output; it correctly flagged that mismatch.

**No FPGA board or Vivado hardware execution is performed by the Python script.** Hardware correctness requires the actual board UART output (or another real hardware result export) to be checked against these vectors. The pass/cycle predictions replicate the C program's specified formula, not a separately verified timing proof of the Verilog implementation.

**Scope:** signed 8-bit inputs, 32-bit sums, M/K/N up to 64, eight tests defined in `mac_test.c`. The Python script does not implement INT4, saturation, requantization, AXI electrical timing, measured power, or a performance speed-up estimate.
