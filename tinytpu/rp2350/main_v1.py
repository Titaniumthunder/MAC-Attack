# Board test for Tiny-TPU Version 1 (the professor's design) on the Tiny Tapeout demo board.
# Copy tinytpu_v1.py, tt_pins.py and model_v1.py to the board, then:  import main_v1
# It runs the professor's INT4 model on his 12 golden inputs, with the chip doing every dot product, and
# checks every sum, logit and class against his Python reference. The RP2350 does its math in single
# precision, so logits are compared to 1e-4.
import time
from tt_pins import TTPins
from tinytpu_v1 import TinyTPUv1, UIO_DRIVE, infer
import model_v1 as M

PROJECT = "tt_um_titaniumthunder_tiny_tpu"

tpu = TinyTPUv1(TTPins(PROJECT, uio_drive=UIO_DRIVE))
tpu.reset()
print("Tiny-TPU v1: professor's INT4 %d-%d-%d, %d golden inputs" % (M.N_IN, M.N_HID, M.N_OUT, len(M.TEST_X)))

ok = 0
t0 = time.ticks_us()
for i in range(len(M.TEST_X)):
    c, logits, sums, ovf = infer(tpu, M, M.TEST_X[i])
    good = (c == M.TEST_CLASS[i] and sums == list(M.TEST_SUMS[i]) and not ovf
            and all(abs(a - b) < 1e-4 for a, b in zip(logits, M.TEST_LOGITS[i])))
    ok += good
    print("  input %2d: %-8s logits %+.4f %+.4f%s" % (i, M.LABELS[c], logits[0], logits[1], "" if good else "  <-- differs"))
dt = time.ticks_diff(time.ticks_us(), t0)
print("%s  %d/%d golden inputs exact, %d us per inference"
      % ("PASS" if ok == len(M.TEST_X) else "FAIL", ok, len(M.TEST_X), dt // len(M.TEST_X)))
