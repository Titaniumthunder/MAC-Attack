/*
 * tinytpu_model_test.c: the Tiny-TPU RSCL motor-vibration model (INT4 8 -> 4 -> 2, the professor's kit) on
 * Tiny-TPU Version 1 (one INT4 x INT4 PE, 16-bit sum), ZedBoard. The same rows, checks and printout as
 * MAC_model_TinyTPU (MAC Attack accelerator) and ../fpga_zed_v2/sw/tinytpu_model_test.c (Version 2).
 *
 * Version 1 only multiplies and adds (CLEAR, MAC, READ): everything else is the host's, exactly the professor's
 * contract. So the model runs in host mode only:
 *   1. ARM alone: the contract in software (layer sums, host float step, logits, class).
 *   2. Host mode: every multiply-add on the PE, one MAC command per (input, weight) pair; the ARM does the float
 *      step between the layers (dequantize, float bias, ReLU, requantize to INT4). All 256 + 128 sums, the 256
 *      hidden INT4 values and the 64 classes must equal the contract; the PE's overflow flag must stay clear.
 * Then the golden rows: sums, logits and class against the expected ones.
 * (modelV2 cannot run on Version 1: its weights and inputs are INT8, the PE takes INT4.)
 *
 * Data: tinytpu_model.h, written by tinytpu/mac_mlp/export_mac_mlp.py (the same file as the other two boards').
 * Bitstream: tinytpu_zed_project (build_bitstream.tcl). Output: USB-UART (J14), 115200 baud, 8N1.
 * Also runs in simulation against the RTL: sim/xsim_cosim (run_xsim_cosim.bat tinytpu_model_test).
 */
#include <stdio.h>
#include <stdint.h>
#include "xil_io.h"
#include "xtime_l.h"
#include "tinytpu_model.h"

#ifndef TPU_BASE
#define TPU_BASE 0x43C00000u          /* tiny_tpu_axi in Vivado's Address Editor */
#endif
#ifndef FCLK_MHZ
#define FCLK_MHZ 100                  /* FCLK_MHZ in create_tinytpu_zed_project.tcl */
#endif
#define REG_CMD    0x00u
#define REG_RESULT 0x04u
#define REG_STATUS 0x08u
#define REG_ID     0x0Cu
#define TPU_ID     0x54505534u        /* "TPU4" */
enum { NOP = 0, CLEAR = 1, MAC = 2, READ = 3 };

static const char *const class_name[2] = { "faulty", "healthy" };   /* the package's labels, in order */
static int tests_run = 0, tests_passed = 0;
static int32_t acc1_host[MT_ROWS * MT_N1];
static unsigned long n_cmd = 0;

/* ---------------------------------------------------------------- the PE over AXI */
static void tpu_cmd(int cmd, int a, int w)
{
    n_cmd++;
    Xil_Out32(TPU_BASE + REG_CMD, ((uint32_t)(cmd & 3) << 8) | ((uint32_t)(w & 15) << 4) | (uint32_t)(a & 15));
}

/* One neuron on the PE: CLEAR, MAC x k, READ; ovf collects the sticky overflow flag */
static int32_t pe_neuron(const int8_t *a, const int8_t *w, int k, int wstride, int *ovf)
{
    tpu_cmd(CLEAR, 0, 0);
    for (int i = 0; i < k; i++) tpu_cmd(MAC, a[i], w[i * wstride]);
    tpu_cmd(READ, 0, 0);
    int32_t v = (int32_t)Xil_In32(TPU_BASE + REG_RESULT);
    *ovf |= (int)(Xil_In32(TPU_BASE + REG_STATUS) & 1u);
    return v;
}

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

/* The weights in the header are K x N (MT_W0[k * N0 + j]): neuron j's weights are every N0-th byte from j */

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
    unsigned long us = us_since(t0);
    int ok = ok0 == MT_ROWS * MT_N0 && okh == MT_ROWS * MT_N0 && ok1 == MT_ROWS * MT_N1 && okc == MT_ROWS;
    result(ok, "ARM alone (contract)  ");
    printf("layer 0 %3d/%d, hidden %3d/%d, layer 1 %3d/%d, class %2d/%d  (%lu us)\r\n", ok0, MT_ROWS * MT_N0, okh,
           MT_ROWS * MT_N0, ok1, MT_ROWS * MT_N1, okc, MT_ROWS, us);
}

/* 2. host mode: every multiply-add on the PE, the float step on the ARM */
static void test_host_mode(void)
{
    int ok0 = 0, okh = 0, ok1 = 0, okc = 0, ovf = 0;
    unsigned long cmd0 = n_cmd;
    XTime t0;
    XTime_GetTime(&t0);
    for (int r = 0; r < MT_ROWS; r++) {
        int32_t a0[MT_N0];
        int8_t h[MT_N0];
        for (int j = 0; j < MT_N0; j++) a0[j] = pe_neuron(&MT_X[r * MT_K0], &MT_W0[j], MT_K0, MT_N0, &ovf);
        host_hidden(a0, h);
        for (int j = 0; j < MT_N1; j++) acc1_host[r * MT_N1 + j] = pe_neuron(h, &MT_W1[j], MT_N0, MT_N1, &ovf);
        for (int j = 0; j < MT_N0; j++) { ok0 += a0[j] == MT_ACC0[r * MT_N0 + j]; okh += h[j] == MT_H[r * MT_N0 + j]; }
    }
    unsigned long us = us_since(t0), cmds = (n_cmd - cmd0) / MT_ROWS;
    for (int i = 0; i < MT_ROWS * MT_N1; i++) ok1 += acc1_host[i] == MT_ACC1[i];
    for (int r = 0; r < MT_ROWS; r++) okc += host_class(&acc1_host[r * MT_N1], 0) == MT_CLS[r];
    int ok = !ovf && ok0 == MT_ROWS * MT_N0 && okh == MT_ROWS * MT_N0 && ok1 == MT_ROWS * MT_N1 && okc == MT_ROWS;
    result(ok, "host mode (contract)  ");
    printf("layer 0 %3d/%d, hidden %3d/%d, layer 1 %3d/%d, class %2d/%d  (%lu us, %lu PE commands per row)\r\n", ok0,
           MT_ROWS * MT_N0, okh, MT_ROWS * MT_N0, ok1, MT_ROWS * MT_N1, okc, MT_ROWS, us, cmds);
}

int main(void)
{
    printf("\r\n==================================================================\r\n");
    printf(" Tiny-TPU RSCL model (INT4 8-4-2) on Tiny-TPU Version 1\r\n");
    printf("==================================================================\r\n");
    uint32_t id = Xil_In32(TPU_BASE + REG_ID);
    if (id != TPU_ID) {
        printf("PE not found at 0x%08lx (ID read 0x%08lx). Check TPU_BASE against Vivado's Address Editor.\r\n",
               (unsigned long)TPU_BASE, (unsigned long)id);
        return 1;
    }
    printf(" Found it: Tiny-TPU V1, one INT4 x INT4 PE, 16-bit sum, %d MHz\r\n", FCLK_MHZ);
    printf(" %d test rows: 0-%d the golden vectors, %d-%d random INT4 rows (host mode: the PE has no on-chip step)\r\n\r\n",
           MT_ROWS, MT_GOLDEN - 1, MT_GOLDEN, MT_ROWS - 1);

    test_sw();
    test_host_mode();

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
