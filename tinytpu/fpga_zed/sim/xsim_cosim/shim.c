/* shim.c: connects an ARM board program (compiled with main renamed app_main) to tb_cosim.sv.
 * Xil_Out32 / Xil_In32 become AXI writes / reads on the RTL; XTime_GetTime reads the simulated clock count.
 * Only for the simulation; the SDK build uses the real xil_io.h and xtime_l.h. */
#include <stdio.h>
#include <stdint.h>
#include "svdpi.h"
#include "xil_io.h"
#include "xtime_l.h"

#define TPU_BASE_SIM 0x43C00000u

/* exported from tb_cosim.sv */
extern int sv_axi_write(unsigned int addr, unsigned int data);
extern int sv_axi_read(unsigned int addr, unsigned int *data);
extern long long sv_cycles(void);

int app_main(void);

static unsigned int shim_offset(uintptr_t addr)
{
    if (addr < TPU_BASE_SIM || addr >= TPU_BASE_SIM + 0x10) {
        printf("[xsim cosim] access outside the core: 0x%08lx\n", (unsigned long)addr);
        return 0xF;
    }
    return (unsigned int)(addr - TPU_BASE_SIM);
}

void Xil_Out32(uintptr_t addr, uint32_t value) { sv_axi_write(shim_offset(addr), value); }

uint32_t Xil_In32(uintptr_t addr)
{
    unsigned int v = 0;
    sv_axi_read(shim_offset(addr), &v);
    return v;
}

void XTime_GetTime(XTime *t) { *t = (XTime)sv_cycles(); }

/* imported by tb_cosim.sv */
int c_run_program(int *rc)
{
    *rc = app_main();
    fflush(stdout);
    return 0;
}
