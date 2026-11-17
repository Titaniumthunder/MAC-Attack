/*
 * tpu_v2_driver.h: the ARM's driver for Tiny-TPU Version 2 (tiny_tpu_v2_axi), shared by the model test programs
 * model_v2_test.c and tinytpu_model_test.c. The same register sequences as tinytpu_v2_test.c (which keeps its own
 * copy, the one the Verilator co-simulation checked on 14 Nov), written for any layer given as arrays.
 *
 * Weights are neuron by neuron (N x K, row order): neuron j's K weights at w + j * k.
 */
#ifndef TPU_V2_DRIVER_H
#define TPU_V2_DRIVER_H
#include <stdint.h>
#include "xil_io.h"

#ifndef TPU_BASE
#define TPU_BASE 0x43C00000u          /* tiny_tpu_v2_axi in Vivado's Address Editor */
#endif
/* The PL clock the bitstream was built with (FCLK_MHZ in create_tinytpu_v2_zed_project.tcl) */
#ifndef FCLK_MHZ
#define FCLK_MHZ 50
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

enum { TPU_NOP = 0, TPU_CLEAR = 1, TPU_LOAD_X = 2, TPU_MAC = 3, TPU_READ = 4, TPU_LOAD_P = 6, TPU_POST = 7 };

static inline void tpu_wr(uint32_t off, uint32_t v) { Xil_Out32(TPU_BASE + off, v); }
static inline uint32_t tpu_rd(uint32_t off)             { return Xil_In32(TPU_BASE + off); }

static inline uint32_t tpu_pack4(int b0, int b1, int b2, int b3)
{
    return (uint32_t)(uint8_t)b0 | ((uint32_t)(uint8_t)b1 << 8) | ((uint32_t)(uint8_t)b2 << 16) |
           ((uint32_t)(uint8_t)b3 << 24);
}

static inline void tpu_cmd(int c, int data) { tpu_wr(REG_CMD, ((uint32_t)(c & 7) << 8) | (uint8_t)data); }
static inline int32_t tpu_result(int pe)       { return (int32_t)tpu_rd(pe ? REG_RES1 : REG_RES0); }
static inline int tpu_ovf(void)            { return (int)(tpu_rd(REG_STATUS) & 3u); }

/* A layer's inputs into the input buffer: CLEAR, then four per write */
static inline void tpu_load_inputs(const int8_t *x, int k)
{
    int i = 0;
    tpu_cmd(TPU_CLEAR, 0);
    for (; i + 4 <= k; i += 4) tpu_wr(REG_LOADX4, tpu_pack4(x[i], x[i + 1], x[i + 2], x[i + 3]));
    for (; i < k; i++) tpu_cmd(TPU_LOAD_X, x[i]);
}

/* Two neurons' weights, two dual MACs per write (w1 = NULL: PE 1 gets zeros) */
static inline void tpu_weights(const int8_t *w0, const int8_t *w1, int k)
{
    int i = 0;
    for (; i + 2 <= k; i += 2)
        tpu_wr(REG_PAIR2, tpu_pack4(w0[i], w1 ? w1[i] : 0, w0[i + 1], w1 ? w1[i + 1] : 0));
    if (i < k) tpu_wr(REG_PAIR, tpu_pack4(w0[i], w1 ? w1[i] : 0, 0, 0));
}

/* A neuron pair's POST parameters: per PE bias (3 bytes), m0 (2), shift (1) = 12 bytes = 3 writes.
 * j1 < 0: PE 1 unused. */
static inline void tpu_params(const int32_t *bias, const uint16_t *m0, const uint8_t *shift, int j0, int j1)
{
    uint8_t b[12] = {0};
    for (int p = 0; p < 2; p++) {
        int j = p ? j1 : j0;
        if (j < 0) continue;
        uint32_t bb = (uint32_t)bias[j] & 0xFFFFFFu;
        b[6 * p + 0] = (uint8_t)bb;
        b[6 * p + 1] = (uint8_t)(bb >> 8);
        b[6 * p + 2] = (uint8_t)(bb >> 16);
        b[6 * p + 3] = (uint8_t)m0[j];
        b[6 * p + 4] = (uint8_t)(m0[j] >> 8);
        b[6 * p + 5] = shift[j];
    }
    for (int i = 0; i < 12; i += 4) tpu_wr(REG_LOADP4, tpu_pack4(b[i], b[i + 1], b[i + 2], b[i + 3]));
}

/* A hidden layer ON CHIP (inputs already in the chip): bias, rescale, ReLU (POST); the outputs stay in the chip
 * and become the next layer's inputs (CLEAR with data 1 at the end). y != NULL: also read them back. */
static inline void tpu_layer_post(const int8_t *w, const int32_t *bias, const uint16_t *m0, const uint8_t *shift,
                           int k, int n, int relu, int8_t *y, int *ovf)
{
    for (int j = 0; j < n; j += 2) {
        int single = (j + 1 >= n);
        tpu_cmd(TPU_CLEAR, 0);
        tpu_params(bias, m0, shift, j, single ? -1 : j + 1);
        tpu_weights(w + j * k, single ? 0 : w + (j + 1) * k, k);
        tpu_cmd(TPU_POST, (relu ? 1 : 0) | (single ? 2 : 0));
        if (y) {
            if (ovf) *ovf |= tpu_ovf();
            y[j] = (int8_t)tpu_result(0);
            if (!single) y[j + 1] = (int8_t)tpu_result(1);
        }
    }
    tpu_cmd(TPU_CLEAR, 1);
}

/* A layer in bypass mode (inputs already in the chip): raw sums out (READ) */
static inline void tpu_layer_read(const int8_t *w, int k, int n, int32_t *s, int *ovf)
{
    for (int j = 0; j < n; j += 2) {
        int single = (j + 1 >= n);
        tpu_cmd(TPU_CLEAR, 0);
        tpu_weights(w + j * k, single ? 0 : w + (j + 1) * k, k);
        tpu_cmd(TPU_READ, 0);
        if (ovf) *ovf |= tpu_ovf();
        s[j] = tpu_result(0);
        if (!single) s[j + 1] = tpu_result(1);
    }
}

/* ---------------------------------------------------------------- host math */

/* floor(v / 2^sh) without relying on how C shifts negative numbers */
static inline int64_t tpu_floor_shift(int64_t v, int sh) { return v >= 0 ? (v >> sh) : -(((-v) - 1) >> sh) - 1; }

/* The chip's POST, bit for bit: clamp(((acc + bias) * m0 + 2^(sh-1)) >> sh, relu ? 0 : -128, 127) */
static inline int tpu_requant(int32_t acc, int32_t bias, uint16_t m0, int sh, int relu)
{
    if (sh > 47) sh = 47;
    int64_t t = ((int64_t)acc + bias) * (int64_t)m0;
    if (sh) t += (int64_t)1 << (sh - 1);
    t = tpu_floor_shift(t, sh);
    if (t > 127) return 127;
    if (relu && t < 0) return 0;
    if (!relu && t < -128) return -128;
    return (int)t;
}

static inline int32_t tpu_dot(const int8_t *a, const int8_t *w, int k)
{
    int32_t s = 0;
    for (int i = 0; i < k; i++) s += (int32_t)a[i] * w[i];
    return s;
}

/* Which side is faster and by how much, one decimal (as in the MAC Attack programs) */
#include <stdio.h>
static inline void tpu_print_speedup(unsigned long accel_us, unsigned long arm_us)
{
    if (accel_us == 0 || arm_us == 0) { printf("too short to compare\r\n"); return; }
    int acc_wins = accel_us < arm_us;
    unsigned long big = acc_wins ? arm_us : accel_us, small = acc_wins ? accel_us : arm_us;
    unsigned long x10 = (big * 10u + small / 2u) / small;
    printf("%s %lu.%lux faster\r\n", acc_wins ? "Tiny-TPU core" : "ARM", x10 / 10u, x10 % 10u);
}

#endif
