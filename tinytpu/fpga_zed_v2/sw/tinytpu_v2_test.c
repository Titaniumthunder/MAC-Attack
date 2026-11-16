/*
 * tinytpu_v2_test.c: bare-metal test of Tiny-TPU Version 2 on the ZedBoard.
 *
 * The ARM (Cortex-A9) plays the host, the job the RP2040 does on the Tiny Tapeout board. The core is the
 * same RTL as the chip (two INT8 PEs, ping-pong buffers, on-chip bias + rescale + ReLU); the ARM keeps the
 * models (model_v2_data.h) and streams them in over AXI4-Lite.
 *
 * Tests, in order:
 *   1. ID register.
 *   2. All 65,536 INT8 products on both PEs (PE 1 gets the bitwise NOT of PE 0's weight).
 *   3. Per-PE 22-bit overflow flags; CLEAR clears them.
 *   4. modelV2 13-32-16-4 ON CHIP, all 64 reference rows: the hidden layers' POST outputs must equal the ARM's
 *      own integer requantization, and the last layer's raw sums must equal vectors_C (the Python reference).
 *   5. modelV2 in bypass mode (READ every layer, the ARM requantizes), all 64 rows.
 *   6. The professor's INT4 8-4-2 in bypass mode: 12 vectors, 72 sums.
 *   7. Timing: modelV2 on the chip core vs the ARM doing the same integer math alone.
 *
 * Build: Vivado SDK (2019.1), standalone application for ps7_cortexa9_0 from the exported hardware;
 * replace the template's source with this file and model_v2_data.h (make_model_v2_header.py writes it).
 * Release build (-O2). Output: USB-UART (J14), 115200 baud, 8N1.
 * The same file also runs in simulation against the RTL (../sim/cosim, see README.md).
 */
#include <stdio.h>
#include <stdint.h>
#include <math.h>
#include "xil_io.h"
#include "xtime_l.h"
#include "model_v2_data.h"

/* Base address of tiny_tpu_v2_axi: copy it from Vivado's Address Editor if it differs */
#ifndef TPU_BASE
#define TPU_BASE 0x43C00000u
#endif

#define REG_CMD     0x00u
#define REG_PAIR    0x04u
#define REG_PAIR2   0x08u
#define REG_LOADX4  0x0Cu
#define REG_LOADP4  0x10u
#define REG_RES0    0x14u
#define REG_RES1    0x18u
#define REG_STATUS  0x1Cu
#define REG_ID      0x20u
#define REG_STEPS   0x24u
#define TPU_ID      0x54505538u      /* "TPU8" */

enum { NOP = 0, CLEAR = 1, LOAD_X = 2, MAC = 3, READ = 4, LOAD_P = 6, POST = 7 };

static int tests_run = 0, tests_passed = 0;
static unsigned long n_wr = 0, n_rd = 0;      /* bus accesses, for the timing report */

/* ------------------------------------------------------------------ the core over AXI */

static void wr(uint32_t off, uint32_t v) { n_wr++; Xil_Out32(TPU_BASE + off, v); }
static uint32_t rd(uint32_t off) { n_rd++; return Xil_In32(TPU_BASE + off); }

static uint32_t pack4(int b0, int b1, int b2, int b3)
{
    return (uint32_t)(uint8_t)b0 | ((uint32_t)(uint8_t)b1 << 8) | ((uint32_t)(uint8_t)b2 << 16) |
           ((uint32_t)(uint8_t)b3 << 24);
}

static void cmd(int c, int data) { wr(REG_CMD, ((uint32_t)(c & 7) << 8) | (uint8_t)data); }
static int32_t result(int pe) { return (int32_t)rd(pe ? REG_RES1 : REG_RES0); }
static int ovf_flags(void) { return (int)(rd(REG_STATUS) & 3u); }

/* A layer's inputs into the input buffer: CLEAR, then four per write */
static void load_inputs(const int8_t *x, int k)
{
    int i = 0;
    cmd(CLEAR, 0);
    for (; i + 4 <= k; i += 4) wr(REG_LOADX4, pack4(x[i], x[i + 1], x[i + 2], x[i + 3]));
    for (; i < k; i++) cmd(LOAD_X, x[i]);
}

/* Two neurons' weights, two dual MACs per write (w1 = NULL: PE 1 gets zeros) */
static void weights(const int8_t *w0, const int8_t *w1, int k)
{
    int i = 0;
    for (; i + 2 <= k; i += 2)
        wr(REG_PAIR2, pack4(w0[i], w1 ? w1[i] : 0, w0[i + 1], w1 ? w1[i + 1] : 0));
    if (i < k) wr(REG_PAIR, pack4(w0[i], w1 ? w1[i] : 0, 0, 0));
}

/* A neuron pair's POST parameters: per PE bias (3 bytes), m0 (2), shift (1) = 12 bytes = 3 writes */
static void params(const tpu_layer_t *L, int j0, int j1)
{
    uint8_t b[12] = {0};
    for (int p = 0; p < 2; p++) {
        int j = p ? j1 : j0;
        if (j < 0) continue;
        uint32_t bias = (uint32_t)L->bias[j] & 0xFFFFFFu;
        b[6 * p + 0] = (uint8_t)bias;
        b[6 * p + 1] = (uint8_t)(bias >> 8);
        b[6 * p + 2] = (uint8_t)(bias >> 16);
        b[6 * p + 3] = (uint8_t)L->m0[j];
        b[6 * p + 4] = (uint8_t)(L->m0[j] >> 8);
        b[6 * p + 5] = L->shift[j];
    }
    for (int i = 0; i < 12; i += 4) wr(REG_LOADP4, pack4(b[i], b[i + 1], b[i + 2], b[i + 3]));
}

/* A hidden layer ON CHIP: inputs are already in the chip, the outputs go to the other buffer (POST).
 * y != NULL: also read every output back from the result registers, to check it. Ends with CLEAR(next layer)
 * so the outputs become the next layer's inputs. ovf collects the overflow flags (only when y != NULL). */
static void layer_post(const tpu_layer_t *L, int8_t *y, int *ovf)
{
    for (int j = 0; j < L->n; j += 2) {
        int single = (j + 1 >= L->n);
        cmd(CLEAR, 0);
        params(L, j, single ? -1 : j + 1);
        weights(L->w + j * L->k, single ? NULL : L->w + (j + 1) * L->k, L->k);
        cmd(POST, (L->relu ? 1 : 0) | (single ? 2 : 0));
        if (y) {
            *ovf |= ovf_flags();
            y[j] = (int8_t)result(0);
            if (!single) y[j + 1] = (int8_t)result(1);
        }
    }
    cmd(CLEAR, 1);
}

/* A layer in bypass mode: inputs already in the chip, raw sums out (READ) */
static void layer_read(const int8_t *w, int k, int n, int32_t *s, int *ovf)
{
    for (int j = 0; j < n; j += 2) {
        int single = (j + 1 >= n);
        cmd(CLEAR, 0);
        weights(w + j * k, single ? NULL : w + (j + 1) * k, k);
        cmd(READ, 0);
        if (ovf) *ovf |= ovf_flags();
        s[j] = result(0);
        if (!single) s[j + 1] = result(1);
    }
}

/* ------------------------------------------------------------------ host math (= modelV2 / post_ref) */

/* floor(v / 2^sh) without relying on how C shifts negative numbers */
static int64_t floor_shift(int64_t v, int sh) { return v >= 0 ? (v >> sh) : -(((-v) - 1) >> sh) - 1; }

/* The chip's POST: clamp(((acc + bias) * m0 + 2^(sh-1)) >> sh, relu ? 0 : -128, 127) */
static int requant(int32_t acc, int32_t bias, uint16_t m0, int sh, int relu)
{
    if (sh > 47) sh = 47;
    int64_t t = ((int64_t)acc + bias) * (int64_t)m0;
    if (sh) t += (int64_t)1 << (sh - 1);
    t = floor_shift(t, sh);
    if (t > 127) return 127;
    if (relu && t < 0) return 0;
    if (!relu && t < -128) return -128;
    return (int)t;
}

static int32_t dot(const int8_t *a, const int8_t *w, int k)
{
    int32_t s = 0;
    for (int i = 0; i < k; i++) s += (int32_t)a[i] * w[i];
    return s;
}

/* modelV2 on the ARM alone; hid[l] gets layer l's outputs (if not NULL) */
static void infer_arm(const int8_t *x, int32_t *c, int8_t hid[][M_MAX_N])
{
    int8_t a[M_MAX_N], b[M_MAX_N];
    for (int i = 0; i < M_N_IN; i++) a[i] = x[i];
    for (int l = 0; l < M_N_LAYERS - 1; l++) {
        const tpu_layer_t *L = &M_LAYERS[l];
        for (int j = 0; j < L->n; j++)
            b[j] = (int8_t)requant(dot(a, L->w + j * L->k, L->k), L->bias[j], L->m0[j], L->shift[j], L->relu);
        for (int j = 0; j < L->n; j++) a[j] = b[j];
        if (hid) for (int j = 0; j < L->n; j++) hid[l][j] = b[j];
    }
    const tpu_layer_t *L = &M_LAYERS[M_N_LAYERS - 1];
    for (int j = 0; j < L->n; j++) c[j] = dot(a, L->w + j * L->k, L->k);
}

/* modelV2 on the chip: hidden layers ON CHIP, last layer raw sums out. hid != NULL: read the hidden outputs */
static void infer_chip(const int8_t *x, int32_t *c, int8_t hid[][M_MAX_N], int *ovf)
{
    load_inputs(x, M_N_IN);
    for (int l = 0; l < M_N_LAYERS - 1; l++) layer_post(&M_LAYERS[l], hid ? hid[l] : NULL, ovf);
    const tpu_layer_t *L = &M_LAYERS[M_N_LAYERS - 1];
    layer_read(L->w, L->k, L->n, c, hid ? ovf : NULL);
}

/* ------------------------------------------------------------------ tests */

static void report(const char *name, int ok, const char *detail)
{
    tests_run++;
    tests_passed += ok;
    printf("%s  %-36s %s\r\n", ok ? "PASS" : "FAIL", name, detail);
}

static unsigned long us(XTime t) { return (unsigned long)((t * 1000000ull) / COUNTS_PER_SECOND); }

int main(void)
{
    char buf[160];
    printf("\r\n==================================================================\r\n");
    printf(" Tiny-TPU Version 2 on the ZedBoard: 2 INT8 PEs, on-chip bias/rescale/ReLU\r\n");
    printf("==================================================================\r\n");

    /* 1. ID */
    uint32_t id = rd(REG_ID);
    if (id != TPU_ID) {
        printf("Core not found at 0x%08lx (ID read 0x%08lx). Check TPU_BASE against Vivado's Address Editor.\r\n",
               (unsigned long)TPU_BASE, (unsigned long)id);
        return 1;
    }
    report("ID register", 1, "0x54505538 \"TPU8\"");

    /* 2. All INT8 products, both PEs */
    long prod_ok = 0;
    for (int x = -128; x < 128; x++) {
        cmd(CLEAR, 0);
        cmd(LOAD_X, x);
        for (int w = -128; w < 128; w++) {
            int w1 = ~w;                                        /* also covers -128..127 */
            cmd(CLEAR, 0);
            wr(REG_PAIR, pack4(w, w1, 0, 0));
            cmd(READ, 0);
            prod_ok += (result(0) == x * w) && (result(1) == x * w1);
        }
    }
    snprintf(buf, sizeof buf, "%ld/65536 on both PEs", prod_ok);
    report("all INT8 products", prod_ok == 65536, buf);

    /* 3. Overflow flags: 127 x (-128 x -128) = 2,080,768 fits in 22 bits, one more (2^21) does not */
    static const int8_t neg[32] = {-128, -128, -128, -128, -128, -128, -128, -128, -128, -128, -128,
                                   -128, -128, -128, -128, -128, -128, -128, -128, -128, -128, -128,
                                   -128, -128, -128, -128, -128, -128, -128, -128, -128, -128};
    load_inputs(neg, 32);
    cmd(CLEAR, 0);
    for (int i = 0; i < 63; i++) wr(REG_PAIR2, pack4(-128, 1, -128, 1));   /* ptr wraps after 32 */
    wr(REG_PAIR, pack4(-128, 1, 0, 0));
    cmd(READ, 0);
    int32_t full = result(0), small = result(1);
    int f1 = ovf_flags();
    wr(REG_PAIR, pack4(-128, 1, 0, 0));
    int f2 = ovf_flags();
    cmd(CLEAR, 0);
    int f3 = ovf_flags();
    snprintf(buf, sizeof buf, "127 MACs %ld/%ld flags %d, +1 -> %d, CLEAR -> %d", (long)full, (long)small, f1, f2,
             f3);
    report("22-bit overflow flags", full == 2080768 && small == -16256 && f1 == 0 && f2 == 1 && f3 == 0, buf);

    /* 4. modelV2 on chip, all rows */
    int8_t hid_c[M_N_LAYERS][M_MAX_N], hid_a[M_N_LAYERS][M_MAX_N];
    int rows_ok = 0, posts = 0, posts_ok = 0, ovf = 0;
    for (int r = 0; r < M_N_ROWS; r++) {
        int32_t c[M_N_OUT], c_arm[M_N_OUT];
        infer_chip(M_X[r], c, hid_c, &ovf);
        infer_arm(M_X[r], c_arm, hid_a);
        for (int l = 0; l < M_N_LAYERS - 1; l++)
            for (int j = 0; j < M_LAYERS[l].n; j++) {
                posts++;
                posts_ok += hid_c[l][j] == hid_a[l][j];
            }
        int ok = 1;
        for (int j = 0; j < M_N_OUT; j++) ok &= c[j] == M_C[r][j];
        rows_ok += ok;
        if (r < 4 || !ok) {
            double real[M_N_OUT];
            int best = 0;
            for (int j = 0; j < M_N_OUT; j++) real[j] = (double)(c[j] + M_BIAS_LAST[j]) * M_OUT_SCALE[j];
            for (int j = 1; j < M_N_STATUS; j++) if (real[j] > real[best]) best = j;
            printf("      row %2d: %-10s health %5.1f%%%s\r\n", r, M_STATUS_NAMES[best],
                   100.0 / (1.0 + exp(-real[M_N_OUT - 1])), ok ? "" : "  <-- differs from vectors_C");
        }
    }
    snprintf(buf, sizeof buf, "%d/%d rows, %d/%d POST outputs exact", rows_ok, M_N_ROWS, posts_ok, posts);
    report("modelV2 on chip = Python", rows_ok == M_N_ROWS && posts_ok == posts && !ovf, buf);

    /* 5. modelV2 in bypass mode */
    rows_ok = 0;
    ovf = 0;
    for (int r = 0; r < M_N_ROWS; r++) {
        int8_t a[M_MAX_N];
        int32_t s[M_MAX_N];
        for (int i = 0; i < M_N_IN; i++) a[i] = M_X[r][i];
        for (int l = 0; l < M_N_LAYERS; l++) {
            const tpu_layer_t *L = &M_LAYERS[l];
            load_inputs(a, L->k);
            layer_read(L->w, L->k, L->n, s, &ovf);
            if (l < M_N_LAYERS - 1)
                for (int j = 0; j < L->n; j++) a[j] = (int8_t)requant(s[j], L->bias[j], L->m0[j], L->shift[j], L->relu);
        }
        int ok = 1;
        for (int j = 0; j < M_N_OUT; j++) ok &= s[j] == M_C[r][j];
        rows_ok += ok;
    }
    snprintf(buf, sizeof buf, "%d/%d rows exact", rows_ok, M_N_ROWS);
    report("modelV2 bypass = Python", rows_ok == M_N_ROWS && !ovf, buf);

    /* 6. The professor's INT4 model, bypass */
    int sums = 0, sums_ok = 0;
    ovf = 0;
    for (int v = 0; v < P_N_VEC; v++) {
        int32_t s0[P_N_HID], s1[P_N_OUT];
        load_inputs(P_A0[v], P_N_IN);
        layer_read(&P_W0[0][0], P_N_IN, P_N_HID, s0, &ovf);
        load_inputs(P_A1[v], P_N_HID);
        layer_read(&P_W1[0][0], P_N_HID, P_N_OUT, s1, &ovf);
        for (int j = 0; j < P_N_HID; j++) { sums++; sums_ok += s0[j] == P_S0[v][j]; }
        for (int j = 0; j < P_N_OUT; j++) { sums++; sums_ok += s1[j] == P_S1[v][j]; }
    }
    snprintf(buf, sizeof buf, "%d/%d sums exact (%d vectors)", sums_ok, sums, P_N_VEC);
    report("professor's INT4 model (bypass)", sums_ok == sums && !ovf, buf);

    /* 7. Timing: ROUNDS x all rows each way; the chip path does not read the hidden outputs back */
#ifndef ROUNDS
#define ROUNDS 20
#endif
    XTime t0, t1, t2;
    int timed_ok = 1;
    volatile int32_t sink = 0;
    uint32_t steps0 = rd(REG_STEPS);
    unsigned long w0 = n_wr, r0 = n_rd;
    XTime_GetTime(&t0);
    for (int k = 0; k < ROUNDS; k++)
        for (int r = 0; r < M_N_ROWS; r++) {
            int32_t c[M_N_OUT];
            infer_chip(M_X[r], c, NULL, NULL);
            for (int j = 0; j < M_N_OUT; j++) timed_ok &= c[j] == M_C[r][j];
            sink += c[0];
        }
    XTime_GetTime(&t1);
    unsigned long writes = n_wr - w0, reads = n_rd - r0;
    uint32_t steps = rd(REG_STEPS) - steps0;
    for (int k = 0; k < ROUNDS; k++)
        for (int r = 0; r < M_N_ROWS; r++) {
            int32_t c[M_N_OUT];
            infer_arm(M_X[r], c, NULL);
            for (int j = 0; j < M_N_OUT; j++) timed_ok &= c[j] == M_C[r][j];
            sink += c[0];
        }
    XTime_GetTime(&t2);
    unsigned long n_inf = (unsigned long)ROUNDS * M_N_ROWS;
    unsigned long chip_ns = (unsigned long)((us(t1 - t0) * 1000ull) / n_inf);
    unsigned long arm_ns = (unsigned long)((us(t2 - t1) * 1000ull) / n_inf);
    snprintf(buf, sizeof buf, "%lu inferences each way, all = vectors_C", n_inf);
    report("timing runs exact", timed_ok, buf);
    printf("\r\n Time per inference: chip core %lu ns, ARM alone %lu ns\r\n", chip_ns, arm_ns);
    printf(" Per inference: %lu AXI writes + %lu reads; the core ran %lu steps (%lu ns at 100 MHz),\r\n",
           writes / n_inf, reads / n_inf, (unsigned long)(steps / n_inf), (unsigned long)(steps / n_inf) * 10ul);
    printf(" so the rest of the chip-core time is the bus.\r\n");

    printf("\r\n==================================================================\r\n");
    if (tests_passed == tests_run) printf(" ALL TINY-TPU V2 TESTS PASSED (%d/%d)\r\n", tests_passed, tests_run);
    else                           printf(" FAILED: %d of %d tests passed\r\n", tests_passed, tests_run);
    printf("==================================================================\r\n");
    return tests_passed == tests_run ? 0 : 1;
}
