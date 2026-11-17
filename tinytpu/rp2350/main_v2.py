# Board test for Tiny-TPU Version 2 on the Tiny Tapeout demo board (RP2350, MicroPython).
# Copy tinytpu_v2.py, tt_pins.py and model_v2.py to the board, then:  import main_v2
# It runs modelV2 on the chip for every reference row and checks each result against vectors_C:
#   1. a few rows with every hidden output read back and checked against the RP2350's own integer math
#   2. all rows, hidden layers on chip (the normal way), timed
#   3. all rows in bypass mode (the RP2350 does bias / rescale / ReLU), timed
#   4. the same model on the RP2350 alone, timed (the baseline)
import time
from tt_pins import TTPins
from tinytpu_v2 import TinyTPUv2, infer_host, decode
import model_v2 as M

PROJECT = "tt_um_titaniumthunder_tiny_tpu_v2"

tpu = TinyTPUv2(TTPins(PROJECT, uio_drive=0xFF))
tpu.reset()
print("Tiny-TPU v2: modelV2 %s, %d reference rows" % ("-".join(str(s) for s in M.SIZES), M.N_ROWS))

# 1. hidden outputs read back
bad = 0
for r in range(4):
    hid_chip, hid_host = [], []
    sums = tpu.infer(M.LAYERS, M.X[r], hid_chip)
    infer_host(M.LAYERS, M.X[r], hid_host)
    if hid_chip != hid_host or sums != list(M.C[r]):
        bad += 1
    status, health, _ = decode(sums, M.BIAS_LAST, M.OUT_SCALE, M.STATUS_NAMES)
    print("  row %d: %-10s health %5.1f %%" % (r, status, health))
print("%s  hidden outputs + sums, rows 0-3" % ("PASS" if bad == 0 else "FAIL"))


def run(name, fn):
    ok = 0
    c0 = tpu.clocks
    t0 = time.ticks_us()
    for r in range(M.N_ROWS):
        ok += fn(M.X[r]) == list(M.C[r])
    dt = time.ticks_diff(time.ticks_us(), t0)
    print("%s  %-22s %d/%d rows exact, %d us per row, %d chip clocks per row"
          % ("PASS" if ok == M.N_ROWS else "FAIL", name, ok, M.N_ROWS, dt // M.N_ROWS,
             (tpu.clocks - c0) // M.N_ROWS))
    return ok == M.N_ROWS


all_ok = bad == 0
all_ok &= run("on chip (POST)", lambda x: tpu.infer(M.LAYERS, x))
all_ok &= run("bypass (RP2350 rescale)", lambda x: tpu.infer_bypass(M.LAYERS, x))
all_ok &= run("RP2350 alone", lambda x: infer_host(M.LAYERS, x))
print("ALL TINY-TPU V2 BOARD TESTS PASSED" if all_ok else "SOME TESTS FAILED")
