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
 *
 * Two bus modes (19 Oct 2026). Every test runs twice, once in each mode, so one board run gives
 * the before and after numbers side by side:
 *   1. Strongly ordered (the BSP's default for the PL address range): the ARM waits for the
 *      accelerator's write response after every single register write.
 *   2. Posted writes: the accelerator's 1 MB section is remapped as Device memory, so the ARM
 *      sends the next write without waiting. Before the start command, before the RESULT_PTR
 *      reads and before taking a time stamp, bus_flush() waits until every write so far has
 *      reached the accelerator. Reads still wait for their data in both modes.
 * Set BUS_MODES to 1 to run only mode 1 (the original behaviour).
 *
 * The "layer" tests are the Machine Guardian case: one 64 x 64 layer applied to 64 input rows.
 * The weights (B) are loaded once and stay in the FPGA (loading A or starting a run never changes
 * B), and the rows are sent one at a time or 8 at a time.
 */
#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include "xil_io.h"
#include "xtime_l.h"
#include "xil_mmu.h"         /* Xil_SetTlbAttributes, STRONG_ORDERED, DEVICE_MEMORY */
#include "xpseudo_asm.h"     /* dsb() */
#include "xparameters.h"     /* XPS_L2CC_BASEADDR */
#include "xl2cc.h"           /* XPS_L2CC_CACHE_SYNC_OFFSET */

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

/* 2 = run every test in both bus modes (before and after); 1 = strongly ordered only */
#ifndef BUS_MODES
#define BUS_MODES 2
#endif

/* aligned(4): load_matrix copies whole 32-bit words out of these rows */
static int8_t  A[MAXD][MAXD] __attribute__((aligned(4)));
static int8_t  B[MAXD][MAXD] __attribute__((aligned(4)));
static int32_t C_hw[MAXD][MAXD], C_sw[MAXD][MAXD];
static int     P = 0;                 /* array size, read from the INFO register */

/* For the clock check: PL cycles counted by the accelerator, and ARM timer ticks for the
 * same runs. Real PL clock = cycles / seconds. */
static uint64_t clk_cycles = 0;
static XTime    clk_ticks  = 0;

static void     wr(uint32_t off, uint32_t v) { Xil_Out32(MAC_BASE + off, v); }
static uint32_t rd(uint32_t off)             { return Xil_In32(MAC_BASE + off); }

/* Bus modes (see the top of the file) */
enum { BUS_STRONG = 0, BUS_POSTED = 1 };
static int bus_mode = BUS_STRONG;
static const char *const bus_name[2] = { "strongly ordered (waits for every write)",
                                         "posted writes (device memory)" };

/* Changes how the ARM's MMU maps the accelerator's 1 MB section. Xil_SetTlbAttributes also
 * cleans the data cache and flushes the TLB, so call it between tests, not inside one. */
static void set_bus_mode(int mode)
{
    Xil_SetTlbAttributes(MAC_BASE, mode == BUS_POSTED ? DEVICE_MEMORY : STRONG_ORDERED);
    bus_mode = mode;
}

/* Waits until every register write so far has reached the accelerator. dsb empties the ARM's
 * own write buffer; the L2 cache sync empties the L2 controller's store buffer, which (with
 * early write responses on in this BSP) can hold Device writes after the ARM sees them as done.
 * This is what Linux's wmb() does on this chip. In strongly ordered mode every write already
 * waited for the accelerator, so there is nothing to do. */
static void bus_flush(void)
{
    if (bus_mode != BUS_POSTED) return;
    dsb();
    Xil_Out32(XPS_L2CC_BASEADDR + XPS_L2CC_CACHE_SYNC_OFFSET, 0u);
    dsb();
}

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
    if ((cols & 3) == 0) {
        /* Fast path: every row is a whole number of words. Byte 0 goes in bits 7:0 of a
         * LOAD_DATA word, and the ARM is little-endian, so 4 bytes of a row copied as one
         * word are already in the right order: one load instead of 4 loads, shifts and ORs.
         * (memcpy of 4 bytes compiles to a single load and is safe for the compiler.) */
        for (int r = 0; r < rows; r++)
            for (int c = 0; c < cols; c += 4) {
                memcpy(&w, &m[r][c], 4);
                wr(REG_LOAD_DATA, w);
            }
        return;
    }
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

/* Prints which side is faster and by how much, with one decimal: "accelerator 1.4x faster" */
static void print_speedup(unsigned long accel_us, unsigned long arm_us)
{
    if (accel_us == 0 || arm_us == 0) { printf("too short to compare"); return; }
    int acc_wins = accel_us < arm_us;
    unsigned long big = acc_wins ? arm_us : accel_us, small = acc_wins ? accel_us : arm_us;
    unsigned long x10 = (big * 10u + small / 2u) / small;
    printf("%s %lu.%lux faster", acc_wins ? "accelerator" : "ARM", x10 / 10u, x10 % 10u);
}

/* Times kept for the before/after summary, in microseconds */
typedef struct { unsigned long load, run, read, total, sw; int valid; } times_t;
static times_t t64[2];                /* "random INT8, 64x64 folded", per bus mode */
static times_t tlayer[2][2];          /* layer tests: [bus mode][0 = 1 row per run, 1 = 8 rows] */

static int tests_run = 0, tests_passed = 0;

static void run_test(const char *name, int kind, int M, int K, int N, times_t *save)
{
    XTime t0, t1, t2, t3, t4;
    uint32_t status;
    make_data(kind, M, K, N);

    XTime_GetTime(&t0);
    wr(REG_DIMS, (uint32_t)M | ((uint32_t)K << 8) | ((uint32_t)N << 16));
    load_matrix(0, A, M, K);
    load_matrix(1, B, K, N);
    bus_flush();                                               /* every byte has arrived */
    XTime_GetTime(&t1);
    wr(REG_CTRL, 1u);                                          /* start */
    bus_flush();                                               /* the start arrives before the first STATUS read */
    do status = rd(REG_STATUS); while (!(status & STATUS_DONE));
    XTime_GetTime(&t2);
    wr(REG_RES_PTR, 0u);                                       /* read C from (0,0) */
    bus_flush();                                               /* the pointer is set before the first read */
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
    unsigned long us_load = to_us(t1 - t0), us_run = to_us(t2 - t1), us_read = to_us(t3 - t2);
    unsigned long us_total = to_us(t3 - t0), us_sw = to_us(t4 - t3);
    printf("      array %lu us (calc) | over the bus: load %lu us, run %lu us, read %lu us | ARM software %lu us | ",
           (unsigned long)((cycles * 1000000ull) / CORE_HZ), us_load, us_run, us_read, us_sw);
    print_speedup(us_total, us_sw);
    printf("\r\n");
    if (save) {
        save->load = us_load; save->run = us_run; save->read = us_read;
        save->total = us_total; save->sw = us_sw; save->valid = ok;
    }
}

/* The Machine Guardian case: one 64 x 64 layer (B = the weights) applied to 64 input rows (A).
 * The weights are loaded once and stay in the FPGA; then 'batch' input rows go in each run:
 * batch = 1 is one audio frame at a time, batch = 8 sends 8 frames together (8 runs instead of
 * 64, and each weight load inside the array serves 8 rows). Every result is checked, and every
 * run's pass and cycle counts are checked against the equations (those two register reads per
 * run are inside the timed part). */
static void run_layer_test(const char *name, int batch, times_t *save)
{
    const int ROWS = 64, K = 64, N = 64;
    XTime t0, t1, t2, t3, t4;
    uint32_t status = 0;
    int counts_ok = 1;
    make_data(RANDOM, ROWS, K, N);
    unsigned long eq_passes = (unsigned long)(((K + P - 1) / P) * ((N + P - 1) / P));
    unsigned long eq_cycles = eq_passes * (unsigned long)(batch + 3 * P - 2);

    XTime_GetTime(&t0);
    wr(REG_DIMS, (uint32_t)batch | ((uint32_t)K << 8) | ((uint32_t)N << 16));
    load_matrix(1, B, K, N);                                   /* the weights, once */
    bus_flush();
    XTime_GetTime(&t1);
    for (int r0 = 0; r0 < ROWS; r0 += batch) {
        load_matrix(0, A + r0, batch, K);                      /* only the new input rows */
        bus_flush();
        wr(REG_CTRL, 1u);                                      /* start */
        bus_flush();
        do status = rd(REG_STATUS); while (!(status & STATUS_DONE));
        if (status & STATUS_LOAD_ERR) counts_ok = 0;
        wr(REG_RES_PTR, 0u);
        bus_flush();
        for (int i = 0; i < batch; i++)
            for (int j = 0; j < N; j++) C_hw[r0 + i][j] = (int32_t)rd(REG_RES_DATA);
        if (rd(REG_PASSES) != eq_passes || rd(REG_CYCLES) != eq_cycles) counts_ok = 0;
    }
    XTime_GetTime(&t2);
    XTime_GetTime(&t3);
    sw_matmul(ROWS, K, N);                                     /* the ARM does all 64 rows alone */
    XTime_GetTime(&t4);

    int correct = 0;
    for (int i = 0; i < ROWS; i++)
        for (int j = 0; j < N; j++) correct += (C_hw[i][j] == C_sw[i][j]);
    int ok = correct == ROWS * N && counts_ok;
    tests_run++;
    tests_passed += ok;

    unsigned long us_w = to_us(t1 - t0), us_rows = to_us(t2 - t1), us_total = to_us(t2 - t0);
    unsigned long us_sw = to_us(t4 - t3);
    printf("%s  %-28s %2dx%2dx%2d  %4d/%-4d correct  %d runs of %d row%s, passes %lu cycles %lu each (eq)%s\r\n",
           ok ? "PASS" : "FAIL", name, ROWS, K, N, correct, ROWS * N, ROWS / batch, batch,
           batch == 1 ? "" : "s", eq_passes, eq_cycles, counts_ok ? "" : " COUNT MISMATCH");
    printf("      weights once %lu us | %d rows %lu us (%lu.%lu us per row) | total %lu us | ARM software %lu us | ",
           us_w, ROWS, us_rows, (us_rows * 10u / ROWS) / 10u, (us_rows * 10u / ROWS) % 10u, us_total, us_sw);
    print_speedup(us_total, us_sw);
    printf("\r\n");
    if (save) {
        save->load = us_w; save->run = us_rows; save->read = 0;
        save->total = us_total; save->sw = us_sw; save->valid = ok;
    }
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

/* Every test, in the current bus mode. The random generator restarts each time, so both bus
 * modes get exactly the same matrices. */
static void run_all(void)
{
    seed = 0x2468ACE1u;
    run_test("small numbers",              SMALL,   4,  4,  4, NULL);
    if (bus_mode == BUS_STRONG)
        printf("      hand check: C[0][0] = %d*%d + %d*%d + %d*%d + %d*%d = %d, hardware gave %d\r\n",
               A[0][0], B[0][0], A[0][1], B[1][0], A[0][2], B[2][0], A[0][3], B[3][0],
               (int)C_sw[0][0], (int)C_hw[0][0]);
    run_test("random INT8, 16x16",         RANDOM, 16, 16, 16, NULL);
    run_test("random INT8, 64x64 folded",  RANDOM, 64, 64, 64, &t64[bus_mode]);
    run_test("odd sizes (edge tiles)",     RANDOM, 37, 50, 23, NULL);
    run_test("one row of A",               RANDOM,  1, 64, 64, NULL);
    run_test("every input -128",           MINV,   16, 16, 16, NULL);
    run_test("every input 127",            MAXV,   16, 16, 16, NULL);
    run_test("B = identity",               IDENT,  16, 16, 16, NULL);
    /* The two largest sums possible with K = 64: they need every accumulator bit
     * (64 x 16384 = 1,048,576 and 64 x -16256 = -1,040,384). */
    run_test("every input -128, K = 64",   MINV,   64, 64, 64, NULL);
    run_test("A = 127, B = -128, K = 64",  MIXV,   64, 64, 64, NULL);
    /* Weights loaded once, then 64 input rows */
    run_layer_test("layer, 1 row per run",  1, &tlayer[bus_mode][0]);
    run_layer_test("layer, 8 rows per run", 8, &tlayer[bus_mode][1]);
}

static void print_before_after(const char *name, const times_t *a, const times_t *b)
{
    printf("  %-24s total %5lu -> %-5lu us  (ARM alone %lu us)  ", name, a->total, b->total, b->sw);
    print_speedup(a->total, a->sw);
    printf(" -> ");
    print_speedup(b->total, b->sw);
    printf("\r\n");
}

/* Side-by-side numbers from the two bus modes */
static void __attribute__((unused)) print_summary(void)
{
    printf("\r\n Before -> after: strongly ordered -> posted writes (same matrices, same build)\r\n");
    print_before_after("64x64x64, all sent", &t64[0], &t64[1]);
    printf("  %-24s load %lu -> %lu us, run %lu -> %lu us, read %lu -> %lu us\r\n", "",
           t64[0].load, t64[1].load, t64[0].run, t64[1].run, t64[0].read, t64[1].read);
    print_before_after("layer, 1 row per run", &tlayer[0][0], &tlayer[1][0]);
    print_before_after("layer, 8 rows per run", &tlayer[0][1], &tlayer[1][1]);
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

    for (int mode = 0; mode < BUS_MODES; mode++) {
        set_bus_mode(mode);
        printf("------------------------------------------------------------------\r\n");
        printf(" Bus mode %d of %d: %s\r\n", mode + 1, BUS_MODES, bus_name[mode]);
        printf("------------------------------------------------------------------\r\n");
        run_all();
    }
    set_bus_mode(BUS_STRONG);                                  /* back to the BSP's default */

    check_clock();
#if BUS_MODES == 2
    print_summary();
#endif

    printf("\r\n==================================================================\r\n");
    if (tests_passed == tests_run) printf(" ALL BOARD TESTS PASSED (%d/%d)\r\n", tests_passed, tests_run);
    else                           printf(" FAILED: %d of %d tests passed\r\n", tests_passed, tests_run);
    printf("==================================================================\r\n");
    return 0;
}
