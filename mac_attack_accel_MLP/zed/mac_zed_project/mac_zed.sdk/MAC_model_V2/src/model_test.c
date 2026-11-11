/*
 * model_test.c: the frozen modelV2 bearing-health model (13 -> 32 -> 16 -> 4, INT8) on the ZedBoard.
 *
 * The ARM loads the model into the accelerator's on-chip MLP once (weights into slots 0-2, every
 * channel's bias, m0 and shift), then sends the 64 test rows 1, 8 and 64 at a time. The FPGA runs all
 * three layers and returns the last layer's 4 raw sums per row. Every sum must equal the value the
 * golden model computed when the model was exported (model_vectors.h). It then prints what the host
 * makes of the sums: the status class and the health %.
 *
 * Files next to this one:
 *   model.h          the model, a copy of modelV2/export/20261110-220018_A_severity_onset/seed0/model.h
 *   model_vectors.h  the 64 test rows and their expected sums (the same export's vectors_X/_C.hex)
 *
 * Needs a bitstream with the on-chip MLP (mac_axi MLP = 1; CONFIG bit 18). Same registers and the same
 * order of writes as mac_test.c's model tests. Output: USB-UART (J14), 115200 baud, 8N1.
 * Feature extraction, the baseline and the status ladder are not here: they run on the host
 * (modelV2/live.py). This program proves the chip part.
 */
#include <stdio.h>
#include <stdint.h>
#include "xil_io.h"
#include "xtime_l.h"
#include "model.h"
#include "model_vectors.h"

/* Base address of the accelerator: copy it from Vivado's Address Editor if it differs. */
#ifndef MAC_BASE
#define MAC_BASE 0x43C00000u
#endif

/* Register map: the same offsets as in mac_axi.v */
#define REG_CTRL       0x00u
#define REG_STATUS     0x04u
#define REG_DIMS       0x08u
#define REG_LOAD_PTR   0x0Cu    /* [0] 0 = inputs A, 1 = weights B; [25:24] weight slot */
#define REG_LOAD_DATA  0x10u
#define REG_RES_PTR    0x14u
#define REG_RES_DATA   0x18u
#define REG_INFO       0x28u
#define REG_ID         0x2Cu
#define REG_CONFIG     0x30u
#define REG_MODEL      0x34u    /* number of layers - 1 */
#define REG_LAYER0     0x38u    /* + 4 * layer: [7:0] N, [8] ReLU */
#define REG_PARAM_PTR  0x48u    /* [7:0] channel, [9:8] layer */
#define REG_PARAM_DATA 0x4Cu    /* per channel: bias, then (shift << 16) | m0 */
#define REG_MCYCLES    0x50u
#define CTRL_MODEL      0x2u
#define CONFIG_MLP      (1u << 18)
#define STATUS_DONE     0x2u
#define STATUS_LOAD_ERR 0x4u
#define STATUS_WAIT     0x8u

#define LAYERS 3
#define K0     13                                  /* inputs */
#define NOUT   4                                   /* 3 status logits + 1 health logit */
static const int            layer_n[LAYERS] = { 32, 16, NOUT };
static const int8_t  *const layer_w[LAYERS] = { MG2_W0, MG2_W1, MG2_W2 };   /* K x N, row order */
static const int32_t *const layer_b[LAYERS] = { MG2_B0, MG2_B1, MG2_B2 };
static const int32_t *const layer_m0[LAYERS - 1] = { MG2_M0_0, MG2_M0_1 };
static const int8_t  *const layer_sh[LAYERS - 1] = { MG2_SHIFT_0, MG2_SHIFT_1 };
static const char *const status_name[3] = { "healthy", "developing", "faulty" };

static int32_t C_hw[MG2_ROWS][NOUT];

static void     wr(uint32_t off, uint32_t v) { Xil_Out32(MAC_BASE + off, v); }
static uint32_t rd(uint32_t off)             { return Xil_In32(MAC_BASE + off); }

/* n bytes as one stream, byte 0 in bits 7:0, 4 per LOAD_DATA write (extra bytes of the last word are dropped) */
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

/* The model, once: it stays in the FPGA while input rows come and go. */
static void load_model(void)
{
    int k = K0;
    for (int l = 0; l < LAYERS; l++) {
        int n = layer_n[l], relu = l < LAYERS - 1;
        wr(REG_DIMS, 1u | ((uint32_t)k << 8) | ((uint32_t)n << 16));       /* the weights are K x N */
        load_bytes(1u | ((uint32_t)l << 24), layer_w[l], k * n);
        wr(REG_PARAM_PTR, (uint32_t)l << 8);                               /* layer l, channel 0 */
        for (int j = 0; j < n; j++) {
            wr(REG_PARAM_DATA, (uint32_t)layer_b[l][j]);
            /* the last layer returns raw sums, so its scale is never used: any valid value (shift 1, m0 1) */
            wr(REG_PARAM_DATA, relu ? ((uint32_t)(uint8_t)layer_sh[l][j] << 16) | (uint32_t)layer_m0[l][j] : 0x10001u);
        }
        wr(REG_LAYER0 + 4u * (uint32_t)l, (uint32_t)n | ((uint32_t)relu << 8));
        k = n;
    }
    wr(REG_MODEL, LAYERS - 1);
}

/* 'rows' input rows through the whole model in one run; the 4 raw sums of each row go to out. 0 = load error. */
static int run_rows(const int8_t *x, int rows, int32_t (*out)[NOUT])
{
    uint32_t status;
    wr(REG_DIMS, (uint32_t)rows | ((uint32_t)K0 << 8) | ((uint32_t)NOUT << 16));
    load_bytes(0u, x, rows * K0);
    wr(REG_CTRL, CTRL_MODEL);
    do status = rd(REG_STATUS); while (!(status & STATUS_DONE));
    wr(REG_RES_PTR, 0u);
    for (int i = 0; i < rows; i++)
        for (int j = 0; j < NOUT; j++) out[i][j] = (int32_t)rd(REG_RES_DATA);
    return !(status & STATUS_LOAD_ERR);
}

/* 1 / (1 + e^-x) without the math library: e^x as (1 + x/1024)^1024, within 0.3 % for |x| < 2.5 */
static float sigmoid(float x)
{
    if (x > 20.0f) x = 20.0f;
    if (x < -20.0f) x = -20.0f;
    float e = 1.0f - x / 1024.0f;
    for (int i = 0; i < 10; i++) e *= e;
    return 1.0f / (1.0f + e);
}

/* The host's part (model.h): real[j] = (C[j] + bias_last[j]) * out_scale[j]; status = the largest of 0..2 */
static void decode(const int32_t *c, int *status, int *health_tenths)
{
    float real[NOUT];
    for (int j = 0; j < NOUT; j++) real[j] = (float)(c[j] + MG2_BIAS_LAST[j]) * MG2_OUT_SCALE[j];
    *status = real[1] > real[0] ? 1 : 0;
    if (real[2] > real[*status]) *status = 2;
    *health_tenths = (int)(1000.0f * sigmoid(real[3]) + 0.5f);
}

static int tests_run = 0, tests_passed = 0;

static void run_test(int batch)
{
    XTime t0, t1;
    int ok = 1, correct = 0;
    XTime_GetTime(&t0);
    for (int r = 0; r < MG2_ROWS; r += batch) ok &= run_rows(&MG2_VEC_X[r * K0], batch, &C_hw[r]);
    XTime_GetTime(&t1);
    unsigned long mcyc = rd(REG_MCYCLES);                      /* FPGA clocks of the last run */
    for (int r = 0; r < MG2_ROWS; r++)
        for (int j = 0; j < NOUT; j++) correct += C_hw[r][j] == MG2_VEC_C[r * NOUT + j];
    ok = ok && correct == MG2_ROWS * NOUT;
    tests_run++;
    tests_passed += ok;
    unsigned long us = (unsigned long)(((t1 - t0) * 1000000ull) / COUNTS_PER_SECOND);
    printf("%s  %2d row%s per run  %3d/%d sums correct  %d rows in %lu us (%lu us per row), FPGA %lu clocks per run\r\n",
           ok ? "PASS" : "FAIL", batch, batch == 1 ? " " : "s", correct, MG2_ROWS * NOUT, MG2_ROWS, us,
           us / MG2_ROWS, mcyc);
}

int main(void)
{
    printf("\r\n==================================================================\r\n");
    printf(" modelV2 bearing-health model (13-32-16-4) on the MAC Attack accelerator\r\n");
    printf("==================================================================\r\n");
    uint32_t id = rd(REG_ID);
    if (id != 0x4D414331u) {
        printf("Accelerator not found at 0x%08lx (ID read 0x%08lx).\r\n", (unsigned long)MAC_BASE, (unsigned long)id);
        printf("Check the base address in Vivado's Address Editor and MAC_BASE in this file.\r\n");
        return 1;
    }
    uint32_t info = rd(REG_INFO);
    printf(" Found it: %lux%lu array, matrices up to %lu\r\n", (unsigned long)(info & 0xFFu),
           (unsigned long)(info & 0xFFu), (unsigned long)(info >> 24));
    if (!(rd(REG_CONFIG) & CONFIG_MLP)) {
        printf(" This bitstream has no on-chip MLP (CONFIG bit 18 = 0): build mac_axi with MLP = 1.\r\n");
        return 1;
    }
    for (int i = 0; i < 1000000 && (rd(REG_STATUS) & STATUS_WAIT); i++) ;      /* a separate core clock has started */

    load_model();
    printf(" Model loaded: 1,088 weights in 3 layers\r\n\r\n");
    run_test(1);
    run_test(8);
    run_test(64);

    printf("\r\n What the host reads from the sums (rows as the FPGA returned them, 64 per run):\r\n");
    for (int r = 0; r < MG2_ROWS; r += 7) {
        int status, health;
        decode(C_hw[r], &status, &health);
        printf("  row %2d  sums %7ld %7ld %7ld %7ld  status %-10s  health %3d.%d %%\r\n", r, (long)C_hw[r][0],
               (long)C_hw[r][1], (long)C_hw[r][2], (long)C_hw[r][3], status_name[status], health / 10, health % 10);
    }

    printf("\r\n==================================================================\r\n");
    if (tests_passed == tests_run) printf(" ALL MODEL TESTS PASSED (%d/%d)\r\n", tests_passed, tests_run);
    else                           printf(" FAILED: %d of %d tests passed\r\n", tests_passed, tests_run);
    printf("==================================================================\r\n");
    return 0;
}
