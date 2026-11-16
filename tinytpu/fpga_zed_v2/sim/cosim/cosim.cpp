// Co-simulation: runs the ARM test program (../../sw/tinytpu_v2_test.c, unchanged) against the RTL
// (tiny_tpu_v2_axi.v + the chip's tiny_tpu_v2_core.v, Verilated). Every Xil_Out32 / Xil_In32 in the
// program becomes an AXI4-Lite transaction, with random delays between the address, data and response
// handshakes (seeded), so the wrapper sees the orderings a real interconnect can produce.
// Build and run: ./run_cosim.sh
// (the test program is compiled separately, with its main() renamed tinytpu_v2_main)

#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <random>

#include "Vtiny_tpu_v2_axi.h"
#include "verilated.h"

extern "C" {
#include "xil_io.h"
#include "xtime_l.h"
int tinytpu_v2_main(void);
}

static const uint32_t TPU_BASE = 0x43C00000u;
static Vtiny_tpu_v2_axi *top;
static uint64_t cycles = 0;
static std::mt19937 rng(1);
static int jitter = 2;            // max random wait (clocks) before each valid / ready; 0 = none

static void tick()
{
    top->s_axi_aclk = 0;
    top->eval();
    top->s_axi_aclk = 1;
    top->eval();
    cycles++;
}

static int wait_clocks() { return jitter ? (int)(rng() % (unsigned)(jitter + 1)) : 0; }

static uint32_t offset(uintptr_t addr)
{
    if (addr < TPU_BASE || addr >= TPU_BASE + 0x40) {
        std::fprintf(stderr, "[cosim] access outside the core: 0x%08lx\n", (unsigned long)addr);
        std::exit(2);
    }
    return (uint32_t)(addr - TPU_BASE);
}

static void timeout(int t, const char *what)
{
    if (t > 1000) {
        std::fprintf(stderr, "[cosim] %s: no handshake after 1000 clocks\n", what);
        std::exit(3);
    }
}

extern "C" void Xil_Out32(uintptr_t addr, uint32_t value)
{
    top->s_axi_awaddr = offset(addr);
    top->s_axi_awprot = 0;
    top->s_axi_wdata = value;
    top->s_axi_wstrb = 0xF;
    int aw_at = wait_clocks(), w_at = wait_clocks();
    bool aw_done = false, w_done = false;
    for (int t = 0; !(aw_done && w_done); t++) {
        timeout(t, "write address/data");
        top->s_axi_awvalid = !aw_done && t >= aw_at;
        top->s_axi_wvalid = !w_done && t >= w_at;
        bool aw_hs = top->s_axi_awvalid && top->s_axi_awready;
        bool w_hs = top->s_axi_wvalid && top->s_axi_wready;
        tick();
        aw_done |= aw_hs;
        w_done |= w_hs;
    }
    top->s_axi_awvalid = 0;
    top->s_axi_wvalid = 0;
    int b_at = wait_clocks();
    for (int t = 0;; t++) {
        timeout(t, "write response");
        top->s_axi_bready = t >= b_at;
        bool hs = top->s_axi_bvalid && top->s_axi_bready;
        tick();
        if (hs) break;
    }
    top->s_axi_bready = 0;
}

extern "C" uint32_t Xil_In32(uintptr_t addr)
{
    top->s_axi_araddr = offset(addr);
    top->s_axi_arprot = 0;
    int ar_at = wait_clocks();
    for (int t = 0;; t++) {
        timeout(t, "read address");
        top->s_axi_arvalid = t >= ar_at;
        bool hs = top->s_axi_arvalid && top->s_axi_arready;
        tick();
        if (hs) break;
    }
    top->s_axi_arvalid = 0;
    int r_at = wait_clocks();
    uint32_t v = 0;
    for (int t = 0;; t++) {
        timeout(t, "read data");
        top->s_axi_rready = t >= r_at;
        bool hs = top->s_axi_rvalid && top->s_axi_rready;
        if (hs) v = top->s_axi_rdata;
        tick();
        if (hs) break;
    }
    top->s_axi_rready = 0;
    return v;
}

extern "C" void XTime_GetTime(XTime *t) { *t = cycles; }

int main(int argc, char **argv)
{
    Verilated::commandArgs(argc, argv);
    if (argc > 1) jitter = std::atoi(argv[1]);
    top = new Vtiny_tpu_v2_axi;
    top->s_axi_aresetn = 0;
    top->s_axi_awvalid = top->s_axi_wvalid = top->s_axi_bready = 0;
    top->s_axi_arvalid = top->s_axi_rready = 0;
    for (int i = 0; i < 10; i++) tick();
    top->s_axi_aresetn = 1;
    for (int i = 0; i < 5; i++) tick();

    std::printf("[cosim] ARM test program on the RTL, random handshake waits up to %d clocks\n", jitter);
    int rc = tinytpu_v2_main();
    std::printf("[cosim] %llu clocks simulated (%.1f ms at 100 MHz); program returned %d\n",
                (unsigned long long)cycles, cycles / 1e5, rc);
    top->final();
    delete top;
    return rc;
}
