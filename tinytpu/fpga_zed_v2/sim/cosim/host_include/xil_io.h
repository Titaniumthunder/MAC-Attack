/* Simulation stand-in for the Xilinx SDK's xil_io.h: Xil_Out32 / Xil_In32 become AXI4-Lite transactions
 * on the Verilated RTL (cosim.cpp). Only for the co-simulation; the SDK build uses the real header. */
#ifndef XIL_IO_H
#define XIL_IO_H
#include <stdint.h>
#ifdef __cplusplus
extern "C" {
#endif
void Xil_Out32(uintptr_t addr, uint32_t value);
uint32_t Xil_In32(uintptr_t addr);
#ifdef __cplusplus
}
#endif
#endif
