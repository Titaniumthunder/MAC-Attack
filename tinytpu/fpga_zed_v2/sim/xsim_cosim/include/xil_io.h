/* Simulation stand-in for the Xilinx SDK's xil_io.h (Vivado xsim co-simulation, shim.c). */
#ifndef XIL_IO_H
#define XIL_IO_H
#include <stdint.h>
void Xil_Out32(uintptr_t addr, uint32_t value);
uint32_t Xil_In32(uintptr_t addr);
#endif
