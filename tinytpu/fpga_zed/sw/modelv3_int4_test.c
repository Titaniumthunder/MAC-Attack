/*
 * modelv3_int4_test.c: modelV3 (13-32-16-4, bearing status + health) in INT4 on Tiny-TPU Version 1, ZedBoard.
 *
 * The ARM is the host (the RP2350's job on the Tiny Tapeout board): it keeps the INT4 model (modelv3_int4.h,
 * written by modelV3/hardware_int4.py), sends every multiply-add to the PE over AXI4-Lite (CLEAR, one MAC per
 * input, READ: 1,096 commands per inference) and does the rest itself in double precision: input
 * standardization, scale, bias, ReLU, requantization to INT4, and the outputs (int4.py in modelV3). Hidden
 * activations use 8 levels (0..7) or 16 (0..15 sent as -8..7, the host adds MV4_CORR back): the header says which.
 *
 * Tests, in order:
 *   1. ID register.
 *   2. The host flow on the PE for the header's test rows: every INT4 input, every PE sum (3,328 for 64 rows) and
 *      every output must equal Python's integer flow (forward_int) exactly; status and health printed per row.
 *   3. No overflow: the sticky flag stays 0 (|sum| <= 49 * 32 by construction).
 *   4. The ARM alone computes the same outputs (the integer flow without the PE).
 *   5. Timing: one inference with the PE vs the ARM alone.
 *
 * Build: as tinytpu_test (README): standalone application for ps7_cortexa9_0, this file + modelv3_int4.h, Release
 * (-O2), link the math library (m). Output: USB-UART (J14), 115200 8N1. Simulation without the board:
 * sim\xsim_cosim\run_xsim_cosim.bat modelv3_int4_test.
 */
#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <math.h>
#include "xil_io.h"
#include "xtime_l.h"
#include "modelv3_int4.h"

#ifndef TPU_BASE
#define TPU_BASE 0x43C00000u
#endif
#ifndef ROUNDS
#define ROUNDS 20                   /* timing rounds over the test rows (the simulation sets fewer) */
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

static int32_t neuron(const int *a, const signed char *w, int n, int use_pe, int *ovf_seen)
{
    int32_t s = 0;
    if (!use_pe) {
        for (int k = 0; k < n; k++) s += a[k] * w[k];
        return s;
    }
    tpu_cmd(CLEAR, 0, 0);
    for (int k = 0; k < n; k++) tpu_cmd(MAC, a[k], w[k]);
    tpu_cmd(READ, 0, 0);
    s = (int32_t)Xil_In32(TPU_BASE + REG_RESULT);
    if (Xil_In32(TPU_BASE + REG_STATUS) & 1u) *ovf_seen = 1;
    return s;
}

/* ------------------------------------------------------------------ host math (= int4.py forward_int) */

/* rint() rounds halves to even like numpy's rint; round() would differ on exact .5 values */
static int q4(double v)
{
    double q = rint(v);
    if (q > 7.0) q = 7.0;
    if (q < -7.0) q = -7.0;
    return (int)q;
}

/* A hidden activation (>= 0) as the PE operand: steps 0..MV4_HMAX, sent minus MV4_HSHIFT (the header's MV4_CORR
 * adds HSHIFT * sum(w) back to each sum). 8 levels: 0..7 as they are; 16 levels: 0..15 sent as -8..7. */
static int hq(double v)
{
    double q = rint(v);
    if (q > (double)MV4_HMAX) q = (double)MV4_HMAX;
    return (int)q - MV4_HSHIFT;
}

/* One inference. a0: the INT4 inputs; acc: every PE sum, layer by layer (MV4_NEURONS); out: the MV4_N_OUT outputs */
static void infer(const double *x, int *a0, int32_t *acc, double *out, int use_pe, int *ovf_seen)
{
    int a[MV4_WIDTH], next[MV4_WIDTH];
    const signed char *w = MV4_W;
    int nb = 0;                                                 /* first neuron of the layer, in MV4_SW / MV4_B */
    for (int i = 0; i < MV4_N_IN; i++) a[i] = a0[i] = q4(((x[i] - MV4_MU[i]) / MV4_SD[i]) / MV4_SA[0]);
    for (int l = 0; l < MV4_LAYERS; l++) {
        int k = MV4_SIZES[l], n = MV4_SIZES[l + 1], last = l == MV4_LAYERS - 1;
        for (int j = 0; j < n; j++) {
            int32_t s = neuron(a, w + j * k, k, use_pe, ovf_seen);
            double z = (double)(s + MV4_CORR[nb + j]) * MV4_SA[l] * MV4_SW[nb + j] + MV4_B[nb + j];
            acc[nb + j] = s;
            if (last) out[j] = z;
            else      next[j] = hq((z > 0.0 ? z : 0.0) / MV4_SA[l + 1]);     /* ReLU, then INT4 for the next layer */
        }
        memcpy(a, next, sizeof(int) * (size_t)n);
        w += n * k;
        nb += n;
    }
}

static int status_of(const double *o)
{
    int best = 0;
    for (int j = 1; j < 3; j++)
        if (o[j] > o[best]) best = j;
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
    char buf[160];
    printf("\r\n==================================================================\r\n");
    printf(" modelV3 INT4 %d-%d-%d-%d on Tiny-TPU Version 1 (one INT4 PE)\r\n", MV4_SIZES[0], MV4_SIZES[1],
           MV4_SIZES[2], MV4_SIZES[3]);
    printf("==================================================================\r\n");

    /* 1. ID */
    uint32_t id = Xil_In32(TPU_BASE + REG_ID);
    if (id != TPU_ID) {
        printf("PE not found at 0x%08lx (ID read 0x%08lx). Check TPU_BASE against Vivado's Address Editor.\r\n",
               (unsigned long)TPU_BASE, (unsigned long)id);
        return 1;
    }
    result("ID register", 1, "0x54505534 \"TPU4\"");

    /* 2-4. The test rows on the PE, then on the ARM alone */
    int in_ok = 0, acc_ok = 0, out_ok = 0, rows_ok = 0, arm_ok = 0, ovf_seen = 0;
    int count[3] = {0, 0, 0};
    for (int r = 0; r < MV4_ROWS; r++) {
        int a0[MV4_N_IN], a0b[MV4_N_IN];
        int32_t acc[MV4_NEURONS], accb[MV4_NEURONS];
        double o[MV4_N_OUT], ob[MV4_N_OUT];
        infer(MV4_X[r], a0, acc, o, 1, &ovf_seen);
        int ri = 1, ra = 1, ro = 1;
        for (int i = 0; i < MV4_N_IN; i++) ri &= a0[i] == MV4_A0[r][i];
        for (int j = 0; j < MV4_NEURONS; j++) { ra &= acc[j] == MV4_ACC[r][j]; acc_ok += acc[j] == MV4_ACC[r][j]; }
        for (int j = 0; j < MV4_N_OUT; j++) ro &= o[j] == MV4_OUT[r][j];      /* the same double operations: exact */
        in_ok += ri;
        out_ok += ro;
        rows_ok += ri && ra && ro;
        int st = status_of(o);
        count[st]++;
        if (r < 8 || !(ri && ra && ro))
            printf("      row %2d: %-10s health %5.1f %%%s\r\n", r, MV4_STATUS_NAMES[st], 100.0 / (1.0 + exp(-o[3])),
                   ri && ra && ro ? "" : "  <-- differs from Python");
        infer(MV4_X[r], a0b, accb, ob, 0, &ovf_seen);
        int same = 1;
        for (int j = 0; j < MV4_N_OUT; j++) same &= ob[j] == o[j];
        arm_ok += same;
    }
    printf("      ... status over all %d rows: %d healthy, %d developing, %d faulty\r\n", MV4_ROWS, count[0],
           count[1], count[2]);
    snprintf(buf, sizeof buf, "%d/%d rows; inputs %d, sums %d/%d, outputs %d", rows_ok, MV4_ROWS, in_ok, acc_ok,
             MV4_ROWS * MV4_NEURONS, out_ok);
    result("host flow on the PE = Python, exactly", rows_ok == MV4_ROWS, buf);
    result("no 16-bit overflow", !ovf_seen, ovf_seen ? "overflow flag seen" : "flag stayed 0");
    snprintf(buf, sizeof buf, "%d/%d rows", arm_ok, MV4_ROWS);
    result("ARM alone = PE", arm_ok == MV4_ROWS, buf);

    /* 5. Timing */
    XTime t0, t1, t2;
    int a0[MV4_N_IN], dummy = 0;
    int32_t acc[MV4_NEURONS];
    double o[MV4_N_OUT];
    volatile double sink = 0.0;
    XTime_GetTime(&t0);
    for (int k = 0; k < ROUNDS; k++)
        for (int r = 0; r < MV4_ROWS; r++) { infer(MV4_X[r], a0, acc, o, 1, &dummy); sink += o[0]; }
    XTime_GetTime(&t1);
    for (int k = 0; k < ROUNDS; k++)
        for (int r = 0; r < MV4_ROWS; r++) { infer(MV4_X[r], a0, acc, o, 0, &dummy); sink += o[0]; }
    XTime_GetTime(&t2);
    unsigned long n = (unsigned long)ROUNDS * MV4_ROWS;
    printf("\r\n Time per inference: with the PE %lu us, ARM alone %lu us (%d PE commands per inference)\r\n",
           us(t1 - t0) / n, us(t2 - t1) / n, MV4_COMMANDS);

    printf("\r\n==================================================================\r\n");
    if (tests_passed == tests_run) printf(" ALL MODELV3 INT4 TESTS PASSED (%d/%d)\r\n", tests_passed, tests_run);
    else                           printf(" FAILED: %d of %d tests passed\r\n", tests_passed, tests_run);
    printf("==================================================================\r\n");
    return tests_passed == tests_run ? 0 : 1;
}
