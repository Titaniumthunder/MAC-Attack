/* Simulation stand-in for the Xilinx SDK's xtime_l.h: time = simulated 100 MHz clocks (tb_cosim.sv).
 * The ARM's own work takes no simulated time, so "ARM alone" shows 0 us in the co-simulation. */
#ifndef XTIME_L_H
#define XTIME_L_H
#include <stdint.h>
typedef uint64_t XTime;
#define COUNTS_PER_SECOND 100000000ull
void XTime_GetTime(XTime *t);
#endif
