/*
 * mac_test.c: bare-metal test of the MAC Attack accelerator on the ZedBoard.
 *
 * The ARM (Cortex-A9) loads matrices into our systolic array over AXI4-Lite, starts it,
 * reads the results back, and checks every value against the same multiply done in software
 * on the ARM. It also times each step, so we can compare the FPGA with the ARM doing the math.
 *
 * Build (Xilinx SDK, Vivado 2019.1): make a standalone application for ps7_cortexa9_0 from the
 * exported hardware (.hdf, exported with "Include bitstream"); the "Hello World" template is
 * fine. Replace its main source with this file.
 *
 * Use the Release build so the ARM software multiply is compiled with optimisation (-O2).
 * The program prints which kind of build it is.
 *
 * After changing the PL clock in Vivado: re-export the hardware AND update the hardware
 * platform in the SDK. The PL clock is set by ps7_init when the board starts, not by the
 * bitstream, so an old hardware platform keeps the old clock. This program measures the real
 * clock and prints a warning if it does not match FCLK_HZ.
 *
 * Output goes to the USB-UART (J14) at 115200 baud, 8N1.
 */
#include <stdio.h>
#include <stdint.h>
#include "xil_io.h"
#include "xtime_l.h"

/* Base address of the accelerator: copy it from Vivado's Address Editor if it differs. */
#ifndef MAC_BASE
#define MAC_BASE 0x43C00000u
#endif
/* PL clock (FCLK_CLK0) in Hz. Use the value from Vivado's Clock Summary, not the one you asked
 * for: asking the Zynq for 80 MHz gives 76.929 MHz (period 12.999 ns). */
#ifndef FCLK_HZ
#define FCLK_HZ 200000000u   /* 200.000 MHz: step 7c build (asked for 190, the Zynq gave 200) */
#endif
/* Clock of the matrix core in Hz. One clock (CORE_CLK = 0): the same as FCLK_HZ. With the core on
 * its own clock (step 12, CORE_CLK = 1): the Clocking Wizard's actual output frequency. The "array"
 * times and the clock check use this one, because the performance counters count core cycles. */
#ifndef CORE_HZ
#define CORE_HZ FCLK_HZ
#endif

/* Register map: the same offsets as in mac_axi.v */
#define REG_CTRL       0x00u
#define REG_STATUS     0x04u
#define REG_DIMS       0x08u
#define REG_LOAD_PTR   0x0Cu
#define REG_LOAD_DATA  0x10u
#define REG_RES_PTR    0x14u
#define REG_RES_DATA   0x18u
#define REG_PASSES     0x1Cu
#define REG_CYCLES     0x20u
#define REG_TOTAL      0x24u
#define REG_INFO       0x28u
#define REG_ID         0x2Cu
#define REG_CONFIG     0x30u
#define STATUS_BUSY     0x1u
#define STATUS_DONE     0x2u
#define STATUS_LOAD_ERR 0x4u
#define STATUS_WAIT     0x8u    /* the core's own clock is not running yet (CORE_CLK = 1 only) */

#define MAXD 64

/* Runs with at least this many cycles are used to measure the real PL clock
 * (long runs, so the start-up and polling time is small next to the run). */
#define CLOCK_CHECK_MIN_CYCLES 5000ul

static int8_t  A[MAXD][MAXD], B[MAXD][MAXD];
static int32_t C_hw[MAXD][MAXD], C_sw[MAXD][MAXD];
static int     P = 0;                 /* array size, read from the INFO register */

/* For the clock check: PL cycles counted by the accelerator, and ARM timer ticks for the
 * same runs. Real PL clock = cycles / seconds. */
static uint64_t clk_cycles = 0;
static XTime    clk_ticks  = 0;

static void     wr(uint32_t off, uint32_t v) { Xil_Out32(MAC_BASE + off, v); }
static uint32_t rd(uint32_t off)             { return Xil_In32(MAC_BASE + off); }

/* Prints a frequency in Hz as MHz with two decimals, e.g. "76.93 MHz" */
static void print_mhz(unsigned long hz)
{
    unsigned long c = (hz + 5000u) / 10000u;          /* hundredths of a MHz, rounded */
    printf("%lu.%02lu MHz", c / 100u, c % 100u);
}

/* Same xorshift generator as the testbenches, so the matrices match the simulations */
static uint32_t seed = 0x2468ACE1u;
static uint32_t next_rand(void)
{
    seed ^= seed << 13;
    seed ^= seed >> 17;
    seed ^= seed << 5;
    return seed & 0x7FFFFFFFu;
}

enum { RANDOM, SMALL, MINV, MAXV, IDENT, MIXV };   /* MIXV: A = 127, B = -128 */

static int8_t value(int kind, int is_b, int r, int c)
{
    switch (kind) {
    case SMALL: return (int8_t)((int)(next_rand() % 19u) - 9);
    case MINV:  return -128;
    case MAXV:  return 127;
    case MIXV:  return is_b ? -128 : 127;
    case IDENT: if (is_b) return (int8_t)(r == c ? 1 : 0); /* A is random */
                return (int8_t)((int)(next_rand() % 256u) - 128);
    default:    return (int8_t)((int)(next_rand() % 256u) - 128);
    }
}

static void make_data(int kind, int M, int K, int N)
{
    for (int i = 0; i < M; i++) for (int k = 0; k < K; k++) A[i][k] = value(kind, 0, i, k);
    for (int k = 0; k < K; k++) for (int j = 0; j < N; j++) B[k][j] = value(kind, 1, k, j);
}

/* Send a matrix as one stream of bytes in row order, 4 bytes per LOAD_DATA write */
static void load_matrix(int is_b, int8_t (*m)[MAXD], int rows, int cols)
{
    uint32_t w = 0;
    int n = 0;
    wr(REG_LOAD_PTR, (uint32_t)(is_b & 1));                   /* start at row 0, column 0 */
    for (int r = 0; r < rows; r++)
        for (int c = 0; c < cols; c++) {
            w |= (uint32_t)(uint8_t)m[r][c] << (8 * (n & 3));
            n++;
            if ((n & 3) == 0) { wr(REG_LOAD_DATA, w); w = 0; }
        }
    if (n & 3) wr(REG_LOAD_DATA, w);                          /* extra bytes are dropped */
}

static void sw_matmul(int M, int K, int N)
{
    for (int i = 0; i < M; i++)
        for (int j = 0; j < N; j++) {
            int32_t s = 0;
            for (int k = 0; k < K; k++) s += (int32_t)A[i][k] * (int32_t)B[k][j];
            C_sw[i][j] = s;
        }
}

static unsigned long to_us(XTime t) { return (unsigned long)((t * 1000000ull) / COUNTS_PER_SECOND); }

static int tests_run = 0, tests_passed = 0;

static void run_test(const char *name, int kind, int M, int K, int N)
{
    XTime t0, t1, t2, t3, t4;
    uint32_t status;
    make_data(kind, M, K, N);

    XTime_GetTime(&t0);
    wr(REG_DIMS, (uint32_t)M | ((uint32_t)K << 8) | ((uint32_t)N << 16));
    load_matrix(0, A, M, K);
    load_matrix(1, B, K, N);
    XTime_GetTime(&t1);
    wr(REG_CTRL, 1u);                                          /* start */
    do status = rd(REG_STATUS); while (!(status & STATUS_DONE));
    XTime_GetTime(&t2);
    wr(REG_RES_PTR, 0u);                                       /* read C from (0,0) */
    for (int i = 0; i < M; i++)
        for (int j = 0; j < N; j++) C_hw[i][j] = (int32_t)rd(REG_RES_DATA);
    XTime_GetTime(&t3);
    sw_matmul(M, K, N);                                        /* the ARM does it alone */
    XTime_GetTime(&t4);

    int correct = 0;
    for (int i = 0; i < M; i++)
        for (int j = 0; j < N; j++) correct += (C_hw[i][j] == C_sw[i][j]);
    unsigned long passes = rd(REG_PASSES), cycles = rd(REG_CYCLES), total = rd(REG_TOTAL);
    unsigned long eq_passes = (unsigned long)(((K + P - 1) / P) * ((N + P - 1) / P));
    unsigned long eq_cycles = eq_passes * (unsigned long)(M + 3 * P - 2);
    int ok = correct == M * N && passes == eq_passes && cycles == eq_cycles && !(status & STATUS_LOAD_ERR);
    tests_run++;
    tests_passed += ok;

    /* Clock check: the accelerator counted "total" PL cycles while busy, and the ARM timer
     * measured the same run (t1 to t2), so total / time = the real PL clock. */
    if (cycles >= CLOCK_CHECK_MIN_CYCLES) {
        clk_cycles += total;
        clk_ticks  += t2 - t1;
    }

    printf("%s  %-28s %2dx%2dx%2d  %4d/%-4d correct  passes %lu (eq %lu)  cycles %lu (eq %lu)\r\n",
           ok ? "PASS" : "FAIL", name, M, K, N, correct, M * N, passes, eq_passes, cycles, eq_cycles);
    /* "array" is calculated (cycles / CORE_HZ); "run" is measured by the ARM timer */
    printf("      array %lu us (calc) | over the bus: load %lu us, run %lu us, read %lu us | ARM software %lu us\r\n",
           (unsigned long)((cycles * 1000000ull) / CORE_HZ),
           to_us(t1 - t0), to_us(t2 - t1), to_us(t3 - t2), to_us(t4 - t3));
}

/* Compares the measured core clock with CORE_HZ and warns if they differ by more than 5% */
static void check_clock(void)
{
    if (clk_ticks == 0) return;
    unsigned long meas = (unsigned long)((clk_cycles * (uint64_t)COUNTS_PER_SECOND) / clk_ticks);
    printf("\r\n Core clock: CORE_HZ says ");
    print_mhz(CORE_HZ);
    printf(", measured on the board ");
    print_mhz(meas);
    printf("\r\n");

    uint64_t diff = meas > CORE_HZ ? (uint64_t)(meas - CORE_HZ) : (uint64_t)(CORE_HZ - meas);
    if (diff * 20u > (uint64_t)CORE_HZ) {
        printf(" WARNING: the core is not running at CORE_HZ, so the \"array\" times are wrong.\r\n");
        printf("          If you changed the clock in Vivado: re-export the hardware with the bitstream\r\n");
        printf("          and update the hardware platform in the SDK (ps7_init sets the clock).\r\n");
        printf("          Otherwise set FCLK_HZ (and CORE_HZ with two clocks) to the values Vivado shows.\r\n");
    }
}

int main(void)
{
    printf("\r\n==================================================================\r\n");
    printf(" MAC Attack accelerator on the ZedBoard\r\n");
    printf("==================================================================\r\n");
    uint32_t id = rd(REG_ID);
    if (id != 0x4D414331u) {
        printf("Accelerator not found at 0x%08lx (ID read 0x%08lx).\r\n", (unsigned long)MAC_BASE, (unsigned long)id);
        printf("Check the base address in Vivado's Address Editor and MAC_BASE in this file.\r\n");
        return 1;
    }
    uint32_t info = rd(REG_INFO);
    P = (int)(info & 0xFFu);
    printf(" Found it: %dx%d array, %lu-bit inputs, %lu-bit sums, matrices up to %lu, clock ",
           P, P, (unsigned long)((info >> 8) & 0xFFu), (unsigned long)((info >> 16) & 0xFFu),
           (unsigned long)(info >> 24));
    print_mhz(FCLK_HZ);
    printf(" (FCLK_HZ)\r\n");
    uint32_t cfg = rd(REG_CONFIG);
    printf(" Pipeline: PIPE %lu, MEM_REG %lu%s; core clock: %s", (unsigned long)(cfg & 0xFFu),
           (unsigned long)((cfg >> 8) & 0xFFu), (cfg & 0x20000u) ? ", one DSP48E1 per PE" : "",
           (cfg & 0x10000u) ? "its own, " : "the same as the bus, ");
    print_mhz(CORE_HZ);
    printf(" (CORE_HZ)\r\n");
    /* With its own clock, wait until the core is out of reset (the Clocking Wizard has locked) */
    for (int i = 0; i < 1000000 && (rd(REG_STATUS) & STATUS_WAIT); i++) ;
    if (rd(REG_STATUS) & STATUS_WAIT) {
        printf(" The core clock never started (STATUS bit 3 stays 1): check the Clocking Wizard's\r\n");
        printf(" input clock and reset, and that ps7_init ran.\r\n");
        return 1;
    }
#ifdef __OPTIMIZE__
    printf(" Build: optimised (Release), so the ARM software times are a fair baseline.\r\n\r\n");
#else
    printf(" Build: NOT optimised (-O0, Debug). ARM software times are slower than they should be;\r\n");
    printf("        switch to the Release build before quoting them.\r\n\r\n");
#endif

    run_test("small numbers",              SMALL,   4,  4,  4);
    printf("      hand check: C[0][0] = %d*%d + %d*%d + %d*%d + %d*%d = %d, hardware gave %d\r\n",
           A[0][0], B[0][0], A[0][1], B[1][0], A[0][2], B[2][0], A[0][3], B[3][0],
           (int)C_sw[0][0], (int)C_hw[0][0]);
    run_test("random INT8, 16x16",         RANDOM, 16, 16, 16);
    run_test("random INT8, 64x64 folded",  RANDOM, 64, 64, 64);
    run_test("odd sizes (edge tiles)",     RANDOM, 37, 50, 23);
    run_test("one row of A",               RANDOM,  1, 64, 64);
    run_test("every input -128",           MINV,   16, 16, 16);
    run_test("every input 127",            MAXV,   16, 16, 16);
    run_test("B = identity",               IDENT,  16, 16, 16);
    /* The two largest sums possible with K = 64: they need every accumulator bit
     * (64 x 16384 = 1,048,576 and 64 x -16256 = -1,040,384). */
    run_test("every input -128, K = 64",   MINV,   64, 64, 64);
    run_test("A = 127, B = -128, K = 64",  MIXV,   64, 64, 64);

    check_clock();

    printf("\r\n==================================================================\r\n");
    if (tests_passed == tests_run) printf(" ALL BOARD TESTS PASSED (%d/%d)\r\n", tests_passed, tests_run);
    else                           printf(" FAILED: %d of %d tests passed\r\n", tests_passed, tests_run);
    printf("==================================================================\r\n");
    return 0;
}
