/*
 * model_v2_test.c: the frozen modelV2 bearing-health model (13 -> 32 -> 16 -> 4, INT8) on Tiny-TPU Version 2,
 * ZedBoard. The same test as the MAC Attack accelerator's MAC_model_V2 (mac_attack_accel_MLP), on the chip RTL
 * instead: the same model, the same 64 rows, the same expected sums, the same printout, so the two boards'
 * outputs can be compared line by line.
 *
 *   1. ARM alone (software): the same integer math as the chip; its time is the baseline.
 *   2. On chip: hidden layers on the core (bias, rescale, ReLU by POST; the outputs stay in the chip), last
 *      layer's raw sums out. All 256 sums must equal the export's vectors_C.
 *   3. Bypass: every layer's raw sums out, the ARM requantizes between layers. All 256 sums again.
 * Then what the host makes of the sums for every 7th row: status and health %, decoded exactly as MAC_model_V2
 * does it (model.h's rule), so for the same sums the same text.
 *
 * Unlike the 8x8 array, the core takes one input row at a time (one 32-byte input buffer), so there is no
 * "rows per run": each row is one inference. The core clocks per row come from the STEPS register.
 *
 * Data: model_v2_data.h (make_model_v2_header.py; the same export as MAC_model_V2's model.h, checked equal).
 * Bitstream: tinytpu_v2_zed_project (build_bitstream.tcl). Output: USB-UART (J14), 115200 baud, 8N1.
 * Also runs in simulation against the RTL: sim/xsim_cosim (run_xsim_cosim.bat model_v2_test).
 */
#include <stdio.h>
#include <stdint.h>
#include "xil_io.h"
#include "xtime_l.h"
#include "model_v2_data.h"
#include "tpu_v2_driver.h"

static int32_t C_chip[M_N_ROWS][M_N_OUT], C_byp[M_N_ROWS][M_N_OUT], C_sw[M_N_ROWS][M_N_OUT];
static int tests_run = 0, tests_passed = 0;
static unsigned long us_sw = 0;

static unsigned long us_since(XTime t0)
{
    XTime t1;
    XTime_GetTime(&t1);
    return (unsigned long)(((t1 - t0) * 1000000ull) / COUNTS_PER_SECOND);
}

static int count_correct(int32_t (*c)[M_N_OUT])
{
    int ok = 0;
    for (int r = 0; r < M_N_ROWS; r++)
        for (int j = 0; j < M_N_OUT; j++) ok += c[r][j] == M_C[r][j];
    return ok;
}

/* modelV2 on the ARM alone, the chip's integer math */
static void infer_arm(const int8_t *x, int32_t *c)
{
    int8_t a[M_MAX_N], b[M_MAX_N];
    for (int i = 0; i < M_N_IN; i++) a[i] = x[i];
    for (int l = 0; l < M_N_LAYERS - 1; l++) {
        const tpu_layer_t *L = &M_LAYERS[l];
        for (int j = 0; j < L->n; j++)
            b[j] = (int8_t)tpu_requant(tpu_dot(a, L->w + j * L->k, L->k), L->bias[j], L->m0[j], L->shift[j], L->relu);
        for (int j = 0; j < L->n; j++) a[j] = b[j];
    }
    const tpu_layer_t *L = &M_LAYERS[M_N_LAYERS - 1];
    for (int j = 0; j < L->n; j++) c[j] = tpu_dot(a, L->w + j * L->k, L->k);
}

/* modelV2 on the core: hidden layers on chip, last layer's raw sums out */
static void infer_chip(const int8_t *x, int32_t *c, int *ovf)
{
    tpu_load_inputs(x, M_N_IN);
    for (int l = 0; l < M_N_LAYERS - 1; l++) {
        const tpu_layer_t *L = &M_LAYERS[l];
        tpu_layer_post(L->w, L->bias, L->m0, L->shift, L->k, L->n, L->relu, 0, 0);
    }
    const tpu_layer_t *L = &M_LAYERS[M_N_LAYERS - 1];
    tpu_layer_read(L->w, L->k, L->n, c, ovf);
}

/* modelV2 in bypass: every layer's raw sums out, the ARM requantizes */
static void infer_bypass(const int8_t *x, int32_t *c, int *ovf)
{
    int8_t a[M_MAX_N];
    int32_t s[M_MAX_N];
    for (int i = 0; i < M_N_IN; i++) a[i] = x[i];
    for (int l = 0; l < M_N_LAYERS; l++) {
        const tpu_layer_t *L = &M_LAYERS[l];
        tpu_load_inputs(a, L->k);
        tpu_layer_read(L->w, L->k, L->n, s, ovf);
        if (l < M_N_LAYERS - 1)
            for (int j = 0; j < L->n; j++) a[j] = (int8_t)tpu_requant(s[j], L->bias[j], L->m0[j], L->shift[j], L->relu);
        else
            for (int j = 0; j < L->n; j++) c[j] = s[j];
    }
}

/* 1 / (1 + e^-x) without the math library: e^x as (1 + x/1024)^1024, as MAC_model_V2 does it */
static float sigmoid(float x)
{
    if (x > 20.0f) x = 20.0f;
    if (x < -20.0f) x = -20.0f;
    float e = 1.0f - x / 1024.0f;
    for (int i = 0; i < 10; i++) e *= e;
    return 1.0f / (1.0f + e);
}

/* The host's part: real[j] = (C[j] + bias_last[j]) * out_scale[j]; status = the largest of 0..2 */
static void decode(const int32_t *c, int *status, int *health_tenths)
{
    float real[M_N_OUT];
    for (int j = 0; j < M_N_OUT; j++) real[j] = (float)(c[j] + M_BIAS_LAST[j]) * (float)M_OUT_SCALE[j];
    *status = real[1] > real[0] ? 1 : 0;
    if (real[2] > real[*status]) *status = 2;
    *health_tenths = (int)(1000.0f * sigmoid(real[M_N_OUT - 1]) + 0.5f);
}

static void run_sw(void)
{
    XTime t0;
    XTime_GetTime(&t0);
    for (int r = 0; r < M_N_ROWS; r++) infer_arm(M_X[r], C_sw[r]);
    us_sw = us_since(t0);
    int ok = count_correct(C_sw), pass = ok == M_N_ROWS * M_N_OUT;
    tests_run++;
    tests_passed += pass;
    printf("%s  ARM alone (software)  %3d/%d sums correct  %d rows in %lu us (%lu us per row)\r\n", pass ? "PASS" : "FAIL",
           ok, M_N_ROWS * M_N_OUT, M_N_ROWS, us_sw, us_sw / M_N_ROWS);
}

static void run_core(const char *name, void (*infer)(const int8_t *, int32_t *, int *), int32_t (*out)[M_N_OUT])
{
    int ovf = 0;
    XTime t0;
    uint32_t steps0 = tpu_rd(REG_STEPS);
    XTime_GetTime(&t0);
    for (int r = 0; r < M_N_ROWS; r++) infer(M_X[r], out[r], &ovf);
    unsigned long us = us_since(t0);
    unsigned long clocks = (unsigned long)(tpu_rd(REG_STEPS) - steps0) / M_N_ROWS;
    int ok = count_correct(out), pass = ok == M_N_ROWS * M_N_OUT && !ovf;
    tests_run++;
    tests_passed += pass;
    printf("%s  %-20s  %3d/%d sums correct  %d rows in %lu us (%lu us per row), core %lu clocks per row (%lu ns at %d MHz)\r\n",
           pass ? "PASS" : "FAIL", name, ok, M_N_ROWS * M_N_OUT, M_N_ROWS, us, us / M_N_ROWS, clocks,
           clocks * 1000ul / FCLK_MHZ, FCLK_MHZ);
    printf("      against the ARM alone (%lu us, bus time included on the core's side): ", us_sw);
    tpu_print_speedup(us, us_sw);
}

int main(void)
{
    printf("\r\n==================================================================\r\n");
    printf(" modelV2 bearing-health model (13-32-16-4) on Tiny-TPU Version 2\r\n");
    printf("==================================================================\r\n");
    uint32_t id = tpu_rd(REG_ID);
    if (id != TPU_ID) {
        printf("Core not found at 0x%08lx (ID read 0x%08lx). Check TPU_BASE against Vivado's Address Editor.\r\n",
               (unsigned long)TPU_BASE, (unsigned long)id);
        return 1;
    }
    printf(" Found it: Tiny-TPU V2, 2 INT8 PEs, on-chip bias/rescale/ReLU, %d MHz\r\n", FCLK_MHZ);
    printf(" Model: 992 weights and 52 biases in 3 layers, sent with every row (the core keeps no weights)\r\n");
#ifdef __OPTIMIZE__
    printf(" Build: optimised (Release), so the ARM software time is a fair baseline.\r\n\r\n");
#else
    printf(" Build: NOT optimised (-O0, Debug). The ARM software time is slower than it should be;\r\n");
    printf("        switch to the Release build before quoting the speedup.\r\n\r\n");
#endif
    run_sw();
    run_core("on chip (POST)", infer_chip, C_chip);
    run_core("bypass (ARM rescale)", infer_bypass, C_byp);

    printf("\r\n What the host reads from the sums (on-chip run):\r\n");
    for (int r = 0; r < M_N_ROWS; r += 7) {
        int status, health;
        decode(C_chip[r], &status, &health);
        printf("  row %2d  sums %7ld %7ld %7ld %7ld  status %-10s  health %3d.%d %%\r\n", r, (long)C_chip[r][0],
               (long)C_chip[r][1], (long)C_chip[r][2], (long)C_chip[r][3], M_STATUS_NAMES[status], health / 10,
               health % 10);
    }

    printf("\r\n==================================================================\r\n");
    if (tests_passed == tests_run) printf(" ALL MODEL TESTS PASSED (%d/%d)\r\n", tests_passed, tests_run);
    else                           printf(" FAILED: %d of %d tests passed\r\n", tests_passed, tests_run);
    printf("==================================================================\r\n");
    return tests_passed == tests_run ? 0 : 1;
}
