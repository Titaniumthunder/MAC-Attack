/*
 * tinytpu_model_test.c: the Tiny-TPU RSCL motor-vibration model (INT4 8 -> 4 -> 2, the professor's kit) on
 * Tiny-TPU Version 2, ZedBoard. The same test as the MAC Attack accelerator's MAC_model_TinyTPU, on the chip RTL
 * instead: the same model, the same 64 rows (0-11 the professor's golden vectors, 12-63 random INT4 rows), the
 * same expected values, the same printout.
 *
 *   1. ARM alone: the professor's contract in software (layer sums, host float step, logits, class).
 *   2. Host mode (the contract): the core does each layer's multiply-adds (READ, raw sums out); the ARM does the
 *      float step between them (dequantize, float bias, ReLU, requantize to INT4). All 256 + 128 sums, the 256
 *      hidden INT4 values and the 64 classes must equal the contract.
 *   3. On-chip mode: layer 0's step on the core (POST: integer bias, m0 / 2^shift, ReLU; the hidden values stay
 *      in the chip), layer 1's raw sums out. The 128 sums must equal the integer path (MT_ACC1C) and, on the 12
 *      golden rows, the contract too. The same integer step MAC_model_TinyTPU's on-chip MLP uses.
 * Then the golden rows: sums, logits and class against the expected ones.
 *
 * Data: tinytpu_model.h, written by tinytpu/mac_mlp/export_mac_mlp.py (the same file MAC_model_TinyTPU uses).
 * Bitstream: tinytpu_v2_zed_project (build_bitstream.tcl). Output: USB-UART (J14), 115200 baud, 8N1.
 * Also runs in simulation against the RTL: sim/xsim_cosim (run_xsim_cosim.bat tinytpu_model_test).
 */
#include <stdio.h>
#include <stdint.h>
#include "xil_io.h"
#include "xtime_l.h"
#include "tinytpu_model.h"
#include "tpu_v2_driver.h"

static const char *const class_name[2] = { "faulty", "healthy" };   /* the package's labels, in order */

/* The core takes weights neuron by neuron (N x K); the header has them K x N (the 8x8 array's order) */
static int8_t W0n[MT_N0 * MT_K0], W1n[MT_N1 * MT_N0];
static const uint16_t M0_0[MT_N0]    = { MT_M0, MT_M0, MT_M0, MT_M0 };       /* one scale for the layer */
static const uint8_t  SHIFT_0[MT_N0] = { MT_SHIFT, MT_SHIFT, MT_SHIFT, MT_SHIFT };

static int tests_run = 0, tests_passed = 0;
static int32_t acc1_host[MT_ROWS * MT_N1];

static unsigned long us_since(XTime t0)
{
    XTime t1;
    XTime_GetTime(&t1);
    return (unsigned long)(((t1 - t0) * 1000000ull) / COUNTS_PER_SECOND);
}

static void result(int ok, const char *what) { tests_run++; tests_passed += ok; printf("%s  %s", ok ? "PASS" : "FAIL", what); }

/* ---------------------------------------------------------------- the professor's host step (no libm) */
static long rint_even(double x)
{
    int neg = x < 0;
    double a = neg ? -x : x;
    long t = (long)a;
    double f = a - (double)t;
    if (f > 0.5 || (f == 0.5 && (t & 1))) t++;
    return neg ? -t : t;
}

static void host_hidden(const int32_t *acc0, int8_t *h)
{
    for (int j = 0; j < MT_N0; j++) {
        double v = (double)acc0[j] * MT_S_A0 * MT_S_W0 + MT_B0F[j];
        if (v < 0.0) v = 0.0;
        long q = rint_even(v / MT_S_A1);
        h[j] = (int8_t)(q > 7 ? 7 : q < -7 ? -7 : q);
    }
}

static int host_class(const int32_t *acc1, double *logit)
{
    double l[MT_N1];
    for (int j = 0; j < MT_N1; j++) l[j] = (double)acc1[j] * MT_S_A1 * MT_S_W1 + MT_B1F[j];
    if (logit) { logit[0] = l[0]; logit[1] = l[1]; }
    return l[1] > l[0] ? 1 : 0;
}

/* 1. the contract on the ARM alone */
static unsigned long us_sw = 0;
static void test_sw(void)
{
    int ok0 = 0, okh = 0, ok1 = 0, okc = 0;
    XTime t0;
    XTime_GetTime(&t0);
    for (int r = 0; r < MT_ROWS; r++) {
        int32_t a0[MT_N0], a1[MT_N1];
        int8_t h[MT_N0];
        for (int j = 0; j < MT_N0; j++) { a0[j] = tpu_dot(&MT_X[r * MT_K0], &W0n[j * MT_K0], MT_K0); ok0 += a0[j] == MT_ACC0[r * MT_N0 + j]; }
        host_hidden(a0, h);
        for (int j = 0; j < MT_N0; j++) okh += h[j] == MT_H[r * MT_N0 + j];
        for (int j = 0; j < MT_N1; j++) { a1[j] = tpu_dot(h, &W1n[j * MT_N0], MT_N0); ok1 += a1[j] == MT_ACC1[r * MT_N1 + j]; }
        okc += host_class(a1, 0) == MT_CLS[r];
    }
    us_sw = us_since(t0);
    int ok = ok0 == MT_ROWS * MT_N0 && okh == MT_ROWS * MT_N0 && ok1 == MT_ROWS * MT_N1 && okc == MT_ROWS;
    result(ok, "ARM alone (contract)  ");
    printf("layer 0 %3d/%d, hidden %3d/%d, layer 1 %3d/%d, class %2d/%d  (%lu us)\r\n", ok0, MT_ROWS * MT_N0, okh,
           MT_ROWS * MT_N0, ok1, MT_ROWS * MT_N1, okc, MT_ROWS, us_sw);
}

/* 2. host mode: the core does the sums, the ARM the float step */
static void test_host_mode(void)
{
    int ok0 = 0, okh = 0, ok1 = 0, okc = 0, ovf = 0;
    XTime t0;
    uint32_t steps0 = tpu_rd(REG_STEPS);
    XTime_GetTime(&t0);
    for (int r = 0; r < MT_ROWS; r++) {
        int32_t a0[MT_N0];
        int8_t h[MT_N0];
        tpu_load_inputs(&MT_X[r * MT_K0], MT_K0);
        tpu_layer_read(W0n, MT_K0, MT_N0, a0, &ovf);
        host_hidden(a0, h);
        tpu_load_inputs(h, MT_N0);
        tpu_layer_read(W1n, MT_N0, MT_N1, &acc1_host[r * MT_N1], &ovf);
        for (int j = 0; j < MT_N0; j++) { ok0 += a0[j] == MT_ACC0[r * MT_N0 + j]; okh += h[j] == MT_H[r * MT_N0 + j]; }
    }
    unsigned long us = us_since(t0), clocks = (unsigned long)(tpu_rd(REG_STEPS) - steps0) / MT_ROWS;
    for (int i = 0; i < MT_ROWS * MT_N1; i++) ok1 += acc1_host[i] == MT_ACC1[i];
    for (int r = 0; r < MT_ROWS; r++) okc += host_class(&acc1_host[r * MT_N1], 0) == MT_CLS[r];
    int ok = !ovf && ok0 == MT_ROWS * MT_N0 && okh == MT_ROWS * MT_N0 && ok1 == MT_ROWS * MT_N1 && okc == MT_ROWS;
    result(ok, "host mode (contract)  ");
    printf("layer 0 %3d/%d, hidden %3d/%d, layer 1 %3d/%d, class %2d/%d  (%lu us, core %lu clocks per row)\r\n", ok0,
           MT_ROWS * MT_N0, okh, MT_ROWS * MT_N0, ok1, MT_ROWS * MT_N1, okc, MT_ROWS, us, clocks);
}

/* 3. on-chip mode: layer 0's step by POST, layer 1's raw sums out */
static void test_chip_mode(void)
{
    int32_t acc1[MT_ROWS * MT_N1];
    int oks = 0, okc = 0, okg = 0, ovf = 0;
    XTime t0;
    uint32_t steps0 = tpu_rd(REG_STEPS);
    XTime_GetTime(&t0);
    for (int r = 0; r < MT_ROWS; r++) {
        tpu_load_inputs(&MT_X[r * MT_K0], MT_K0);
        tpu_layer_post(W0n, MT_BIAS0, M0_0, SHIFT_0, MT_K0, MT_N0, 1, 0, 0);
        tpu_layer_read(W1n, MT_N0, MT_N1, &acc1[r * MT_N1], &ovf);
    }
    unsigned long us = us_since(t0), clocks = (unsigned long)(tpu_rd(REG_STEPS) - steps0) / MT_ROWS;
    for (int r = 0; r < MT_ROWS; r++) {
        const int32_t *c = &acc1[r * MT_N1];
        oks += (c[0] == MT_ACC1C[r * MT_N1]) + (c[1] == MT_ACC1C[r * MT_N1 + 1]);
        okc += host_class(c, 0) == MT_CLSC[r];
        if (r < MT_GOLDEN) okg += c[0] == MT_ACC1[r * MT_N1] && c[1] == MT_ACC1[r * MT_N1 + 1];
    }
    int ok = !ovf && oks == MT_ROWS * MT_N1 && okc == MT_ROWS && okg == MT_GOLDEN;
    result(ok, "on chip (POST)        ");
    printf("sums %3d/%d, class %2d/%d, golden = contract %2d/%d  (%lu us, core %lu clocks per row, %lu ns at %d MHz)\r\n",
           oks, MT_ROWS * MT_N1, okc, MT_ROWS, okg, MT_GOLDEN, us, clocks, clocks * 1000ul / FCLK_MHZ, FCLK_MHZ);
}

int main(void)
{
    printf("\r\n==================================================================\r\n");
    printf(" Tiny-TPU RSCL model (INT4 8-4-2) on Tiny-TPU Version 2\r\n");
    printf("==================================================================\r\n");
    uint32_t id = tpu_rd(REG_ID);
    if (id != TPU_ID) {
        printf("Core not found at 0x%08lx (ID read 0x%08lx). Check TPU_BASE against Vivado's Address Editor.\r\n",
               (unsigned long)TPU_BASE, (unsigned long)id);
        return 1;
    }
    printf(" Found it: Tiny-TPU V2, 2 INT8 PEs, on-chip bias/rescale/ReLU, %d MHz\r\n", FCLK_MHZ);
    printf(" %d test rows: 0-%d the golden vectors, %d-%d random INT4 rows\r\n\r\n", MT_ROWS, MT_GOLDEN - 1,
           MT_GOLDEN, MT_ROWS - 1);
    for (int k = 0; k < MT_K0; k++) for (int j = 0; j < MT_N0; j++) W0n[j * MT_K0 + k] = MT_W0[k * MT_N0 + j];
    for (int k = 0; k < MT_N0; k++) for (int j = 0; j < MT_N1; j++) W1n[j * MT_N0 + k] = MT_W1[k * MT_N1 + j];

    test_sw();
    test_host_mode();
    test_chip_mode();

    printf("\r\n The golden rows (host mode), logits x 1e6:\r\n");
    for (int r = 0; r < MT_GOLDEN; r++) {
        double l[MT_N1];
        int c = host_class(&acc1_host[r * MT_N1], l);
        printf("  row %2d  sums %4ld %4ld  logits %9ld %9ld (expected %9ld %9ld)  %-7s (expected %-7s, true %s)\r\n", r,
               (long)acc1_host[r * MT_N1], (long)acc1_host[r * MT_N1 + 1], rint_even(l[0] * 1e6), rint_even(l[1] * 1e6),
               (long)MT_LOGIT_U[r * MT_N1], (long)MT_LOGIT_U[r * MT_N1 + 1], class_name[c], class_name[MT_CLS[r]],
               MT_TRUE[r] < 0 ? "-" : class_name[MT_TRUE[r]]);
    }

    printf("\r\n==================================================================\r\n");
    if (tests_passed == tests_run) printf(" ALL TINY-TPU MODEL TESTS PASSED (%d/%d)\r\n", tests_passed, tests_run);
    else                           printf(" FAILED: %d of %d tests passed\r\n", tests_passed, tests_run);
    printf("==================================================================\r\n");
    return tests_passed == tests_run ? 0 : 1;
}
