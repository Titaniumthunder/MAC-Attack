/*
 * tinytpu_test.c: bare-metal test of the Tiny-TPU processing element on the ZedBoard.
 *
 * The ARM (Cortex-A9) plays the host, the job the RP2040 does on the Tiny Tapeout board: it keeps the
 * INT4 model (model_data.h), sends every multiply-add to the PE over AXI4-Lite, and does the rest itself
 * (scale, bias, ReLU, requantize, argmax), exactly as the professor's Python reference (infer_int4).
 *
 * Tests, in order:
 *   1. ID register.
 *   2. Replay of the golden command stream (12 inferences, CLEAR/MAC/READ): every READ must match.
 *   3. The real host flow for the same 12 inputs: the host computes its own INT4 operands, which must
 *      equal the golden stream's, and its logits and class must equal Python's.
 *   4. All 256 INT4 products; overflow flag at 668 x 49 + 1; CLEAR clears it.
 *   5. Timing: one inference with the PE vs the ARM doing the same integer math alone.
 *
 * Build: Vivado SDK (2019.1), standalone application for ps7_cortexa9_0 from the exported hardware;
 * replace the template's source with this file and model_data.h (make_model_header.py writes it).
 * Release build (-O2). Output: USB-UART (J14), 115200 baud, 8N1.
 */
#include <stdio.h>
#include <stdint.h>
#include <math.h>
#include "xil_io.h"
#include "xtime_l.h"
#include "model_data.h"

/* Base address of tiny_tpu_axi: copy it from Vivado's Address Editor if it differs */
#ifndef TPU_BASE
#define TPU_BASE 0x43C00000u
#endif

#define REG_CMD    0x00u
#define REG_RESULT 0x04u
#define REG_STATUS 0x08u
#define REG_ID     0x0Cu
#define TPU_ID     0x54505534u      /* "TPU4" */

enum { NOP = 0, CLEAR = 1, MAC = 2, READ = 3 };

static int tests_run = 0, tests_passed = 0;

/* ------------------------------------------------------------------ the PE over AXI */

static void tpu_cmd(int cmd, int a, int w)
{
    Xil_Out32(TPU_BASE + REG_CMD, ((uint32_t)(cmd & 3) << 8) | ((uint32_t)(w & 15) << 4) | (uint32_t)(a & 15));
}

static int32_t tpu_read(int *ovf)
{
    tpu_cmd(READ, 0, 0);
    int32_t v = (int32_t)Xil_In32(TPU_BASE + REG_RESULT);
    if (ovf) *ovf = (int)(Xil_In32(TPU_BASE + REG_STATUS) & 1u);
    return v;
}

/* ------------------------------------------------------------------ host math (= pipeline.py) */

/* quant4: rint() rounds halves to even like numpy's rint (default rounding mode), then clip to [-7, 7].
 * Do not use round(): it rounds halves away from zero and would differ on exact .5 values. */
static int quant4(double v, double scale)
{
    double q = rint(v / scale);
    if (q > 7.0) q = 7.0;
    if (q < -7.0) q = -7.0;
    return (int)q;
}

/* Checks the host's own operands against the golden command stream, in order */
static int op_pos = 0, op_mismatch = 0;
static void expect_op(int op, int a, int w)
{
    if (op_pos >= N_OPS || OPS[op_pos].op != op || (op == MAC && (OPS[op_pos].a != a || OPS[op_pos].w != w)))
        op_mismatch++;
    op_pos++;
}

/* One neuron: dot product on the PE (use_pe = 1) or on the ARM alone (use_pe = 0) */
static int32_t neuron(const int *qa, const signed char *w, int n, int use_pe, int check, int *ovf_seen)
{
    if (!use_pe) {
        int32_t s = 0;
        for (int k = 0; k < n; k++) s += qa[k] * w[k];
        return s;
    }
    int ovf;
    tpu_cmd(CLEAR, 0, 0);
    if (check) expect_op(CLEAR, 0, 0);
    for (int k = 0; k < n; k++) {
        tpu_cmd(MAC, qa[k], w[k]);
        if (check) expect_op(MAC, qa[k], w[k]);
    }
    int32_t s = tpu_read(&ovf);
    if (check) expect_op(READ, 0, 0);
    if (ovf) *ovf_seen = 1;
    return s;
}

/* One inference: features -> logits, the same steps and order as infer_int4() in pipeline.py */
static int infer(const double *x, double *logits, int use_pe, int check, int *ovf_seen)
{
    int qa[N_IN], qh[N_HID];
    double h[N_HID];
    for (int k = 0; k < N_IN; k++) qa[k] = quant4(x[k], SCALE_A[0]);
    for (int j = 0; j < N_HID; j++) {
        int32_t s = neuron(qa, W0[j], N_IN, use_pe, check, ovf_seen);
        double z = (double)s * SCALE_A[0] * SCALE_W[0] + B0[j];
        h[j] = z > 0.0 ? z : 0.0;                                   /* ReLU */
    }
    for (int k = 0; k < N_HID; k++) qh[k] = quant4(h[k], SCALE_A[1]);
    int best = 0;
    for (int j = 0; j < N_OUT; j++) {
        int32_t s = neuron(qh, W1[j], N_HID, use_pe, check, ovf_seen);
        logits[j] = (double)s * SCALE_A[1] * SCALE_W[1] + B1[j];
        if (logits[j] > logits[best]) best = j;
    }
    return best;
}

/* ------------------------------------------------------------------ tests */

static void result(const char *name, int ok, const char *detail)
{
    tests_run++;
    tests_passed += ok;
    printf("%s  %-44s %s\r\n", ok ? "PASS" : "FAIL", name, detail);
}

static unsigned long us(XTime t) { return (unsigned long)((t * 1000000ull) / COUNTS_PER_SECOND); }

int main(void)
{
    char buf[128];
    printf("\r\n==================================================================\r\n");
    printf(" Tiny-TPU: one INT4 processing element on the ZedBoard (model %d-%d-%d)\r\n", N_IN, N_HID, N_OUT);
    printf("==================================================================\r\n");

    /* 1. ID */
    uint32_t id = Xil_In32(TPU_BASE + REG_ID);
    if (id != TPU_ID) {
        printf("PE not found at 0x%08lx (ID read 0x%08lx). Check TPU_BASE against Vivado's Address Editor.\r\n",
               (unsigned long)TPU_BASE, (unsigned long)id);
        return 1;
    }
    result("ID register", 1, "0x54505534 \"TPU4\"");

    /* 2. Golden command stream */
    int reads = 0, read_ok = 0, ovf_any = 0;
    for (int i = 0; i < N_OPS; i++) {
        if (OPS[i].op == CLEAR) tpu_cmd(CLEAR, 0, 0);
        else if (OPS[i].op == MAC) tpu_cmd(MAC, OPS[i].a, OPS[i].w);
        else {
            int ovf;
            int32_t v = tpu_read(&ovf);
            reads++;
            read_ok += (v == OPS[i].expected) && !ovf;
            ovf_any |= ovf;
        }
    }
    snprintf(buf, sizeof buf, "%d/%d READs exact, %d commands", read_ok, reads, N_OPS);
    result("golden command stream", read_ok == reads && !ovf_any, buf);

    /* 3. The real host flow */
    int class_ok = 0, logit_ok = 0, ovf_seen = 0;
    op_pos = 0;
    op_mismatch = 0;
    for (int i = 0; i < N_VEC; i++) {
        double lg[N_OUT];
        int c = infer(X[i], lg, 1, 1, &ovf_seen);
        int lok = 1;
        for (int j = 0; j < N_OUT; j++) lok &= fabs(lg[j] - EXPECTED_LOGITS[i][j]) < 1e-9;
        class_ok += (c == EXPECTED_CLASS[i]);
        logit_ok += lok;
        printf("      input %2d: %-8s logits %+.6f %+.6f%s\r\n", i, LABELS[c], lg[0], lg[1],
               lok && c == EXPECTED_CLASS[i] ? "" : "  <-- differs from Python");
    }
    snprintf(buf, sizeof buf, "%d/%d classes, %d/%d logits, operand mismatches %d", class_ok, N_VEC, logit_ok,
             N_VEC, op_mismatch);
    result("host flow = Python reference", class_ok == N_VEC && logit_ok == N_VEC && op_mismatch == 0 &&
           op_pos == N_OPS && !ovf_seen, buf);

    /* 4. Edge cases */
    int prod_ok = 0;
    for (int a = -8; a < 8; a++)
        for (int w = -8; w < 8; w++) {
            int ovf;
            tpu_cmd(CLEAR, 0, 0);
            tpu_cmd(MAC, a, w);
            prod_ok += (tpu_read(&ovf) == a * w) && !ovf;
        }
    snprintf(buf, sizeof buf, "%d/256", prod_ok);
    result("all INT4 products", prod_ok == 256, buf);

    int ovf1, ovf2, ovf3;
    tpu_cmd(CLEAR, 0, 0);
    for (int k = 0; k < 668; k++) tpu_cmd(MAC, 7, 7);
    int32_t full = tpu_read(&ovf1);
    tpu_cmd(MAC, 7, 7);
    tpu_read(&ovf2);
    tpu_cmd(CLEAR, 0, 0);
    int32_t zero = tpu_read(&ovf3);
    snprintf(buf, sizeof buf, "668 x 49 = %ld (ovf %d), +49 -> ovf %d, CLEAR -> %ld (ovf %d)", (long)full, ovf1,
             ovf2, (long)zero, ovf3);
    result("16-bit overflow flag", full == 32732 && !ovf1 && ovf2 && zero == 0 && !ovf3, buf);

    /* 5. Timing: 100 rounds of the 12 inferences each way */
    XTime t0, t1, t2;
    double lg[N_OUT];
    volatile int sink = 0;
    int dummy = 0;
    XTime_GetTime(&t0);
    for (int r = 0; r < 100; r++)
        for (int i = 0; i < N_VEC; i++) sink += infer(X[i], lg, 1, 0, &dummy);
    XTime_GetTime(&t1);
    for (int r = 0; r < 100; r++)
        for (int i = 0; i < N_VEC; i++) sink += infer(X[i], lg, 0, 0, &dummy);
    XTime_GetTime(&t2);
    unsigned long pe_ns = (unsigned long)((us(t1 - t0) * 1000ul) / (100ul * N_VEC));
    unsigned long arm_ns = (unsigned long)((us(t2 - t1) * 1000ul) / (100ul * N_VEC));
    printf("\r\n Time per inference: with the PE %lu ns, ARM alone %lu ns\r\n", pe_ns, arm_ns);
    printf(" (each PE command is one AXI write; the PE path is %d writes and %d reads per inference)\r\n",
           N_HID * (N_IN + 2) + N_OUT * (N_HID + 2), 2 * (N_HID + N_OUT));

    printf("\r\n==================================================================\r\n");
    if (tests_passed == tests_run) printf(" ALL TINY-TPU TESTS PASSED (%d/%d)\r\n", tests_passed, tests_run);
    else                           printf(" FAILED: %d of %d tests passed\r\n", tests_passed, tests_run);
    printf("==================================================================\r\n");
    return 0;
}
