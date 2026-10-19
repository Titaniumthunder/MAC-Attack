# 200 MHz RTL update

The optimized P=8 ZedBoard design meets a 5.000 ns (200 MHz) clock in Vivado 2019.1 on xc7z020clg484-1. The earlier user-reported design ran at 111.111 MHz. Keeping the same compute cycle counts makes the computation itself about 1.8x faster; AXI transfers and software overhead do not scale by the same factor.

## Files installed

- `rtl/mm_core.sv`: pipelined prefetch pointers and edge masks, narrower counters, predicted weight-load enables, early C reads and registered C writes.
- `rtl/pe.sv`: DSP multiplication with input/product pipeline stages. The default standalone interface retains its original behavior; the core explicitly selects early activation delivery.
- `rtl/systolic_array.sv`: forwards the optional pipeline parameter while retaining the same array connections and valid schedule. Original positional parameter order is preserved.
- `zed/mac_axi.v`: registered loader bounds and staged result readback. Register addresses, values and handshakes are unchanged. AXI reads gain one response cycle; compute cycle counts and core result-read latency are unchanged.

Previous files are saved in `frequency200/backup_before_200mhz/`. The complete candidate source snapshot is `frequency200/rtl_200mhz/` plus `frequency200/mac_axi_200mhz.v`.

## Block diagram and timing

The PS7, AXI interconnect, reset controller and MAC blocks keep their original connections. The only intentional block-design configuration change is PS FCLK0 = 200 MHz. Internal registers move work across clock cycles without changing the matrix accelerator's high-level structure.

The clean delivery build is recorded in `frequency200/system_200mhz_timing.rpt`: setup slack +0.007 ns, hold slack +0.043 ns, pulse-width slack +1.520 ns, zero failing endpoints. There are no unconstrained internal endpoints. This is a narrow setup margin; operation above 200 MHz is not established. Timing applies to P=8, BITS=8, ACC=32, MAXD=64, SAT=0 on the specified part, not every parameter combination.

That run uses 1,736 LUTs (3.26%), 3,071 flip-flops (2.89%), 6 block RAM tiles (4.29%) and 64 DSP48 slices (29.09%). DSP arithmetic replaces much of the earlier LUT arithmetic.

Open `C:\mac_attack_accel\frequency200\zed_verified\mac_zed_verified.xpr` in Vivado. Its completed implementation meets 200 MHz with the margins above. The final reports are `frequency200/system_200mhz_timing.rpt`, `frequency200/system_200mhz_paths.rpt` and `frequency200/system_200mhz_util.rpt`. This clean build uses the same RTL bytes installed in the main project. No bitstream was generated; the project is implemented through routing.

## Verification

All tests completed successfully under Vivado XSim:

- Core self-check: 8/8 at P=16, 8/8 at P=2 and 8/8 at P=3.
- Dimension/counter bounds: 3/3 at MAXD=255, P=7, exercising M, K and N = 255 separately.
- AXI wrapper: 12/12 at each of P=4, P=8 and P=16.
- Extras: wrapping and saturated arithmetic, postprocessing and UART integration.
- Array comparison: every element of a 64x64 matrix product at P=4, P=8 and P=16; original expected cycle counts pass.

Logs are in `frequency200/simulation_staged/`. Run the complete regression with:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File C:\mac_attack_accel\frequency200\verify_200mhz.ps1
```

Run the complete 200 MHz synthesis/implementation flow with:

```powershell
C:\Xilinx\Vivado\2019.1\bin\vivado.bat -mode batch -source C:\mac_attack_accel\frequency200\build_200mhz.tcl
```

The existing project retains its previous clock setting. Open the delivered 200 MHz project to use the verified clock configuration. No board has been programmed or hardware measurements taken. Static timing and RTL simulation are the verification evidence.

