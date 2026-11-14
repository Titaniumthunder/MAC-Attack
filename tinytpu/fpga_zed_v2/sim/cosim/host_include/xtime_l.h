/* Simulation stand-in for the Xilinx SDK's xtime_l.h: time = simulated 100 MHz clocks. Only for the
 * co-simulation (the ARM's own work takes no simulated time, so "ARM alone" shows 0 ns there). */
#ifndef XTIME_L_H
#define XTIME_L_H
#include <stdint.h>
#ifdef __cplusplus
extern "C" {
#endif
typedef uint64_t XTime;
#define COUNTS_PER_SECOND 100000000ull
void XTime_GetTime(XTime *t);
#ifdef __cplusplus
}
#endif
#endif
