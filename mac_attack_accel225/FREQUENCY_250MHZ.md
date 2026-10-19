# 250 MHz RTL delivery

The P=8 ZedBoard system meets a 4.000 ns (250 MHz) clock in Vivado 2019.1 on xc7z020clg484-1. All eleven regression groups pass. This is static timing and RTL simulation verification; no bitstream was generated and the board was not programmed.

## Open this verified project

`C:\mac_attack_accel\frequency250\zed_fullctrl\mac_zed_fullctrl.xpr`

The completed implementation includes **post-route physical optimization**. Its route-only checkpoint fails timing; use the final post-route checkpoint and reports. Settings: Performance_Explore implementation strategy, Default placement directive, AggressiveExplore post-route physical optimization.

Final evidence:

- `frequency250/system_fullctrl_postopt_timing.rpt`: setup +0.002 ns, hold +0.026 ns, pulse width +1.020 ns; zero failing endpoints, zero unconstrained internal endpoints; 250.000 MHz clock.
- `frequency250/system_fullctrl_postopt_paths.rpt`: final critical paths.
- `frequency250/system_fullctrl_postopt_util.rpt`: 1,667 LUTs, 3,177 FFs, 12 BRAM tiles, 64 DSPs.

The setup margin is only 2 ps. This proves this implemented design meets the specified constraints, not that another implementation, tool version, parameter configuration, or frequency above 250 MHz will pass. Always check timing after rebuilding. Timing applies to P=8, BITS=8, ACC=32, MAXD=64, SAT=0.

## Changes from the 200 MHz version

- Explicit DSP48E1 pipeline and dedicated partial-sum cascade connections within the existing systolic array. The array still has 64 processing elements. Internal sums use 48 bits; the wrapping output retains the original 32-bit result. Generic/saturating configurations retain the behavioral PE path.
- Separate A/B byte banks use BRAM read-output clearing for edge masks, removing the external mask mux from the operand path. This increases BRAM usage from 6 to 12 tiles.
- Predicted, registered A/B address enables and activation-valid controls shorten controller paths without adding compute cycles.
- Registered C readback, captured AXI writes, pipelined loader bounds, and a replicated local compute reset shorten interface/control paths. Reset completion is guarded to prevent a stale DONE flag.
- AXI writes and reads each gain one response cycle compared with the 200 MHz version. Register addresses, values, matrix results and compute counters are preserved.

The PS7, AXI interconnect, reset block and MAC hierarchy, connections and address map are unchanged. The clock configuration changes to 250 MHz. Compute cycles remain `ceil(K/P)*ceil(N/P)*(M+3P-2)`; total busy cycles remain compute cycles + 3. At the same dimensions, compute time is 20% shorter than at 200 MHz; software/transfer overhead is separate.

Installed sources: `rtl/mm_core.sv`, `rtl/systolic_array.sv`, new `rtl/dsp_cascade_pe.sv`, and `zed/mac_axi.v`. `rtl/pe.sv` is unchanged. The original project's source list now includes the DSP helper. The original project is not the completed 250 MHz run; open the verified project above. The older creation script still defaults to 50 MHz.

The verified project uses matching isolated sources in `frequency250/rtl_fullctrl/` and `frequency250/mac_axi_bounds.v`. Earlier and experimental variants in frequency250 are not delivery versions. Prior main sources and original XPR are preserved in `frequency250/backup_before_install/`; the independent 200 MHz project remains in `frequency200/zed_verified/`.

## Verification and reproduction

All eleven groups passed in `frequency250/simulation_fullctrl/`:

- Core correctness: 8/8 each at P=16, P=2 and P=3.
- Counter limits: 3/3, P=7 and MAXD=255.
- AXI matrix/register tests: 12/12 each at P=4, P=8 and P=16.
- Saturation/wrapping, postprocessing and UART integration.
- 64x64 matrix and exact cycle-count comparison at P=4/8/16.
- Explicit DSP primitive equivalence: 2,000 random cycles in each of four first/last-row modes, 4 ns clock.
- Reset recovery during pending writes, stalled reads, active computation and completion, 4 ns clock.

Existing matrix tests retain their simulation clock; static timing establishes 250 MHz timing for the implemented full system. Original expected results and cycle counts were not relaxed.

Run regressions:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File C:\mac_attack_accel\frequency250\verify_fullctrl.ps1
```

Rebuild the final implementation (replaces that project's run results):

```powershell
& 'C:\Xilinx\Vivado\2019.1\bin\vivado.bat' -mode batch -source C:\mac_attack_accel\frequency250\rebuild_250mhz.tcl
```

Include `rtl/dsp_cascade_pe.sv` in custom source lists; standalone XSim primitive simulations need `unisims_ver` and `glbl`, as shown in the regression script. Software that converts counters to time must use the actual 250,000,000 Hz clock.
