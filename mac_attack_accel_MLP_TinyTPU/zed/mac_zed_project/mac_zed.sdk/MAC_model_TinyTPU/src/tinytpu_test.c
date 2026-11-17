/*
 * tinytpu_test.c: the Tiny-TPU RSCL motor-vibration model (INT4 8 -> 4 -> 2, the professor's kit) on the
 * MAC Attack accelerator, ZedBoard.
 *
 * The model and 64 test rows are in tinytpu_model.h (rows 0-11: the professor's golden vectors, 12-63: random
 * INT4 rows), written by tinytpu/mac_mlp/export_mac_mlp.py. Four tests, every value checked:
 *
 *   1. ARM alone: the professor's contract in software (layer sums, host float step, logits, class).
 *   2. Host mode: the accelerator does each layer's multiply-adds as a plain multiply (C = A x B); the ARM does
 *      the contract's float step between them (dequantize, float bias, ReLU, requantize to INT4).
 *      All 256 + 128 sums, the 256 hidden INT4 values and the 64 classes must equal the contract.
 *   3. On-chip mode: the whole model in one run of the on-chip MLP (64 rows, 8 and 1 at a time). The float
 *      step becomes postproc's integer one (bias, m0, shift, ReLU). The final sums must equal the integer path
 *      (MT_ACC1C) and, on the 12 golden rows, the contract too.
 * The same check runs in Vivado as tb_tinytpu.sv (Run Behavioral Simulation).
 *
 * Needs a bitstream with the on-chip MLP (mac_axi MLP = 1, CONFIG bit 18); test 2 works without it.
 * Output: USB-UART (J14), 115200 baud, 8N1. Feature extraction and normalization run on the host
 * (tinytpu/model/src/pipeline.py); this program proves the chip part.
 */
#include <stdio.h>
#include <stdint.h>
#include "xil_io.h"
#include "xtime_l.h"
#include "tinytpu_model.h"

#ifndef MAC_BASE
#define MAC_BASE 0x43C00000u              /* copy it from Vivado's Address Editor if it differs */
#endif

/* Register map: the same offsets as in mac_axi.v */
#define REG_CTRL       0x00u
#define REG_STATUS     0x04u
#define REG_DIMS       0x08u
#define REG_LOAD_PTR   0x0Cu
#define REG_LOAD_DATA  0x10u
#define REG_RES_PTR    0x14u
#define REG_RES_DATA   0x18u
#define REG_INFO       0x28u
#define REG_ID         0x2Cu
#define REG_CONFIG     0x30u
#define REG_MODEL      0x34u
#define REG_LAYER0     0x38u
#define REG_PARAM_PTR  0x48u
#define REG_PARAM_DATA 0x4Cu
#define REG_MCYCLES    0x50u
#define CTRL_START      0x1u
#define CTRL_MODEL      0x2u
#define CONFIG_MLP      (1u << 18)
#define STATUS_DONE     0x2u
#define STATUS_LOAD_ERR 0x4u
#define STATUS_WAIT     0x8u

static const char *const class_name[2] = { "faulty", "healthy" };   /* the package's labels, in order */

static void     wr(uint32_t off, uint32_t v) { Xil_Out32(MAC_BASE + off, v); }
static uint32_t rd(uint32_t off)             { return Xil_In32(MAC_BASE + off); }

static void load_bytes(uint32_t ptr, const int8_t *p, int n)
{
    uint32_t w = 0;
    wr(REG_LOAD_PTR, ptr);
    for (int i = 0; i < n; i++) {
        w |= (uint32_t)(uint8_t)p[i] << (8 * (i & 3));
        if ((i & 3) == 3) { wr(REG_LOAD_DATA, w); w = 0; }
    }
    if (n & 3) wr(REG_LOAD_DATA, w);
}

static uint32_t wait_done(void)
{
    uint32_t s;
    do s = rd(REG_STATUS); while (!(s & STATUS_DONE));
    return s;
}

static void read_c(int32_t *out, int n)
{
    wr(REG_RES_PTR, 0u);
    for (int i = 0; i < n; i++) out[i] = (int32_t)rd(REG_RES_DATA);
}

/* C (m x n) = A (m x k) x B (k x n) on the array, weights in slot 0. Returns 0 on a load error. */
static int matmul(const int8_t *a, const int8_t *b, int m, int k, int n, int32_t *c)
{
    wr(REG_DIMS, (uint32_t)m | ((uint32_t)k << 8) | ((uint32_t)n << 16));
    load_bytes(0u, a, m * k);
    load_bytes(1u, b, k * n);
    wr(REG_CTRL, CTRL_START);
    uint32_t s = wait_done();
    read_c(c, m * n);
    return !(s & STATUS_LOAD_ERR);
}

/* ---------------------------------------------------------------- the professor's host step (no libm) */
/* round to nearest, ties to even (numpy rint) */
static long rint_even(double x)
{
    int neg = x < 0;
    double a = neg ? -x : x;
    long t = (long)a;
    double f = a - (double)t;
    if (f > 0.5 || (f == 0.5 && (t & 1))) t++;
    return neg ? -t : t;
}

/* layer-0 sums -> hidden INT4: ReLU(acc * S_A0 * S_W0 + b0f), / S_A1, rint, clamp to [-7, 7] */
static void host_hidden(const int32_t *acc0, int8_t *h)
{
    for (int j = 0; j < MT_N0; j++) {
        double v = (double)acc0[j] * MT_S_A0 * MT_S_W0 + MT_B0F[j];
        if (v < 0.0) v = 0.0;
        long q = rint_even(v / MT_S_A1);
        h[j] = (int8_t)(q > 7 ? 7 : q < -7 ? -7 : q);
    }
}

/* layer-1 sums -> logits and class (argmax; a tie gives class 0, as numpy) */
static int host_class(const int32_t *acc1, double *logit)
{
    double l[MT_N1];
    for (int j = 0; j < MT_N1; j++) l[j] = (double)acc1[j] * MT_S_A1 * MT_S_W1 + MT_B1F[j];
    if (logit) { logit[0] = l[0]; logit[1] = l[1]; }
    return l[1] > l[0] ? 1 : 0;
}

static long to_micro(double v) { return rint_even(v * 1e6); }

/* ---------------------------------------------------------------- tests */
static int tests_run = 0, tests_passed = 0;
static unsigned long us_sw = 0;

static unsigned long us_since(XTime t0)
{
    XTime t1;
    XTime_GetTime(&t1);
    return (unsigned long)(((t1 - t0) * 1000000ull) / COUNTS_PER_SECOND);
}

static void result(int ok, const char *what) { tests_run++; tests_passed += ok; printf("%s  %s", ok ? "PASS" : "FAIL", what); }

/* 1. the contract on the ARM alone */
static void test_sw(void)
{
    int ok0 = 0, okh = 0, ok1 = 0, okc = 0;
    XTime t0;
    XTime_GetTime(&t0);
    for (int r = 0; r < MT_ROWS; r++) {
        int32_t a0[MT_N0], a1[MT_N1];
        int8_t h[MT_N0];
        for (int j = 0; j < MT_N0; j++) {
            int32_t s = 0;
            for (int k = 0; k < MT_K0; k++) s += MT_X[r * MT_K0 + k] * MT_W0[k * MT_N0 + j];
            a0[j] = s;
            ok0 += s == MT_ACC0[r * MT_N0 + j];
        }
        host_hidden(a0, h);
        for (int j = 0; j < MT_N0; j++) okh += h[j] == MT_H[r * MT_N0 + j];
        for (int j = 0; j < MT_N1; j++) {
            int32_t s = 0;
            for (int k = 0; k < MT_N0; k++) s += h[k] * MT_W1[k * MT_N1 + j];
            a1[j] = s;
            ok1 += s == MT_ACC1[r * MT_N1 + j];
        }
        okc += host_class(a1, 0) == MT_CLS[r];
    }
    us_sw = us_since(t0);
    int ok = ok0 == MT_ROWS * MT_N0 && okh == MT_ROWS * MT_N0 && ok1 == MT_ROWS * MT_N1 && okc == MT_ROWS;
    result(ok, "ARM alone (contract)  ");
    printf("layer 0 %3d/%d, hidden %3d/%d, layer 1 %3d/%d, class %2d/%d  (%lu us)\r\n", ok0, MT_ROWS * MT_N0, okh,
           MT_ROWS * MT_N0, ok1, MT_ROWS * MT_N1, okc, MT_ROWS, us_sw);
}

/* 2. host mode: two plain multiplies on the array, the float step on the ARM */
static int32_t acc0_hw[MT_ROWS * MT_N0], acc1_hw[MT_ROWS * MT_N1];
static int8_t  h_hw[MT_ROWS * MT_N0];

static void test_host_mode(void)
{
    int ok0 = 0, okh = 0, ok1 = 0, okc = 0, ld = 1;
    XTime t0;
    XTime_GetTime(&t0);
    ld &= matmul(MT_X, MT_W0, MT_ROWS, MT_K0, MT_N0, acc0_hw);
    for (int r = 0; r < MT_ROWS; r++) host_hidden(&acc0_hw[r * MT_N0], &h_hw[r * MT_N0]);
    ld &= matmul(h_hw, MT_W1, MT_ROWS, MT_N0, MT_N1, acc1_hw);
    int cls[MT_ROWS];
    for (int r = 0; r < MT_ROWS; r++) cls[r] = host_class(&acc1_hw[r * MT_N1], 0);
    unsigned long us = us_since(t0);
    for (int i = 0; i < MT_ROWS * MT_N0; i++) { ok0 += acc0_hw[i] == MT_ACC0[i]; okh += h_hw[i] == MT_H[i]; }
    for (int i = 0; i < MT_ROWS * MT_N1; i++) ok1 += acc1_hw[i] == MT_ACC1[i];
    for (int r = 0; r < MT_ROWS; r++) okc += cls[r] == MT_CLS[r];
    int ok = ld && ok0 == MT_ROWS * MT_N0 && okh == MT_ROWS * MT_N0 && ok1 == MT_ROWS * MT_N1 && okc == MT_ROWS;
    result(ok, "host mode (contract)  ");
    printf("layer 0 %3d/%d, hidden %3d/%d, layer 1 %3d/%d, class %2d/%d  (%lu us)\r\n", ok0, MT_ROWS * MT_N0, okh,
           MT_ROWS * MT_N0, ok1, MT_ROWS * MT_N1, okc, MT_ROWS, us);
}

/* 3. on-chip mode */
static void load_model(void)
{
    /* layer 0: 8 x 4 weights in slot 0, per channel bias then (shift << 16 | m0), ReLU */
    wr(REG_DIMS, 1u | ((uint32_t)MT_K0 << 8) | ((uint32_t)MT_N0 << 16));
    load_bytes(1u | (0u << 24), MT_W0, MT_K0 * MT_N0);
    wr(REG_PARAM_PTR, 0u << 8);
    for (int j = 0; j < MT_N0; j++) {
        wr(REG_PARAM_DATA, (uint32_t)MT_BIAS0[j]);
        wr(REG_PARAM_DATA, (MT_SHIFT << 16) | MT_M0);
    }
    wr(REG_LAYER0, (uint32_t)MT_N0 | (1u << 8));
    /* layer 1: 4 x 2 weights in slot 1; the raw sums come back (the ARM adds the float bias), so bias 0 and
       any valid scale */
    wr(REG_DIMS, 1u | ((uint32_t)MT_N0 << 8) | ((uint32_t)MT_N1 << 16));
    load_bytes(1u | (1u << 24), MT_W1, MT_N0 * MT_N1);
    wr(REG_PARAM_PTR, 1u << 8);
    for (int j = 0; j < MT_N1; j++) { wr(REG_PARAM_DATA, 0u); wr(REG_PARAM_DATA, 0x10001u); }
    wr(REG_LAYER0 + 4u, (uint32_t)MT_N1);
    wr(REG_MODEL, 1u);
}

static int32_t acc1_chip[MT_ROWS * MT_N1];

static void test_chip_mode(int batch)
{
    int oks = 0, okc = 0, okg = 0, ld = 1;
    XTime t0;
    XTime_GetTime(&t0);
    for (int r0 = 0; r0 < MT_ROWS; r0 += batch) {
        wr(REG_DIMS, (uint32_t)batch | ((uint32_t)MT_K0 << 8) | ((uint32_t)MT_N1 << 16));
        load_bytes(0u, &MT_X[r0 * MT_K0], batch * MT_K0);
        wr(REG_CTRL, CTRL_MODEL);
        ld &= !(wait_done() & STATUS_LOAD_ERR);
        read_c(&acc1_chip[r0 * MT_N1], batch * MT_N1);
    }
    unsigned long us = us_since(t0), mcyc = rd(REG_MCYCLES);
    for (int r = 0; r < MT_ROWS; r++) {
        const int32_t *c = &acc1_chip[r * MT_N1];
        int same = c[0] == MT_ACC1C[r * MT_N1] && c[1] == MT_ACC1C[r * MT_N1 + 1];
        oks += 2 * same;
        okc += host_class(c, 0) == MT_CLSC[r];
        if (r < MT_GOLDEN) okg += c[0] == MT_ACC1[r * MT_N1] && c[1] == MT_ACC1[r * MT_N1 + 1];
    }
    int ok = ld && oks == MT_ROWS * MT_N1 && okc == MT_ROWS && okg == MT_GOLDEN;
    result(ok, "on-chip MLP, ");
    printf("%2d row%s per run  sums %3d/%d, class %2d/%d, golden = contract %2d/%d  (%lu us, FPGA %lu clocks per run)\r\n",
           batch, batch == 1 ? " " : "s", oks, MT_ROWS * MT_N1, okc, MT_ROWS, okg, MT_GOLDEN, us, mcyc);
}

int main(void)
{
    printf("\r\n==================================================================\r\n");
    printf(" Tiny-TPU RSCL model (INT4 8-4-2) on the MAC Attack accelerator\r\n");
    printf("==================================================================\r\n");
    uint32_t id = rd(REG_ID);
    if (id != 0x4D414331u) {
        printf("Accelerator not found at 0x%08lx (ID read 0x%08lx).\r\n", (unsigned long)MAC_BASE, (unsigned long)id);
        return 1;
    }
    uint32_t info = rd(REG_INFO), cfg = rd(REG_CONFIG);
    printf(" Found it: %lux%lu array, matrices up to %lu; on-chip MLP %s\r\n", (unsigned long)(info & 0xFFu),
           (unsigned long)(info & 0xFFu), (unsigned long)(info >> 24), (cfg & CONFIG_MLP) ? "yes" : "NO");
    printf(" %d test rows: 0-%d the golden vectors, %d-%d random INT4 rows\r\n\r\n", MT_ROWS, MT_GOLDEN - 1,
           MT_GOLDEN, MT_ROWS - 1);
    for (int i = 0; i < 1000000 && (rd(REG_STATUS) & STATUS_WAIT); i++) ;

    test_sw();
    test_host_mode();
    if (cfg & CONFIG_MLP) {
        load_model();
        test_chip_mode(MT_ROWS);
        test_chip_mode(8);
        test_chip_mode(1);
    } else {
        printf("SKIP  on-chip MLP: this bitstream has no on-chip MLP (CONFIG bit 18 = 0)\r\n");
    }

    printf("\r\n The golden rows (host mode), logits x 1e6:\r\n");
    for (int r = 0; r < MT_GOLDEN; r++) {
        double l[MT_N1];
        int c = host_class(&acc1_hw[r * MT_N1], l);
        printf("  row %2d  sums %4ld %4ld  logits %9ld %9ld (expected %9ld %9ld)  %-7s (expected %-7s, true %s)\r\n", r,
               (long)acc1_hw[r * MT_N1], (long)acc1_hw[r * MT_N1 + 1], to_micro(l[0]), to_micro(l[1]),
               (long)MT_LOGIT_U[r * MT_N1], (long)MT_LOGIT_U[r * MT_N1 + 1], class_name[c], class_name[MT_CLS[r]],
               MT_TRUE[r] < 0 ? "-" : class_name[MT_TRUE[r]]);
    }

    printf("\r\n==================================================================\r\n");
    if (tests_passed == tests_run) printf(" ALL TINY-TPU MODEL TESTS PASSED (%d/%d)\r\n", tests_passed, tests_run);
    else                           printf(" FAILED: %d of %d tests passed\r\n", tests_passed, tests_run);
    printf("==================================================================\r\n");
    return 0;
}
