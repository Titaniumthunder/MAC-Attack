# RTL timing optimization

The change is confined to rtl/mm_core.sv. The external module ports, Zynq block design, P x P weight-stationary systolic array, PE latency, A/B/C buffer organization, arithmetic and saturation behavior, host protocols, and performance-counter equations are preserved. No additional pipeline stages or per-pass cycles were added.

## Changes

- Replace 32-bit integer controller registers with bounded unsigned counters. Dimension and row counters remain capable of the full documented 1..255 dimension range. Tile and cycle widths are derived from P, including padded edge tiles.
- Calculate terminal counts at start, removing repeated subtraction from the counter-to-memory-address path.
- Express A/B writes using constant lane slices and individual lane enables. Vivado can infer byte-write RAM instead of 128 separate single-bit RAM banks in the P=8 build.

## Validation

Vivado 2019.1 XSim, final RTL:

- tb_selfcheck, P=16: 8/8, including full 64x64 and odd-sized matrices.
- tb_selfcheck, P=3: 8/8, including non-power-of-two edge tiles.
- tb_axi, P=8: 12/12, including host load protection.
- tb_extras: all parts passed (wrapping/saturation reference checks, 800 post-processing outputs, and UART chip integration).
- tb_counter_limits, P=7, MAXD=255: 3/3, exercising maximum M, K and N independently.
- Original matrix results, pass counts and per-pass cycle counts are retained.

Re-run with PowerShell:

```powershell
& C:\mac_attack_accel\timing_work\run_regression.ps1
```

The original core is saved as timing_work/mm_core_original.sv. Timing comparison source snapshots, reports, and checkpoints are in timing_work. The top-level RTL is the maintained source; timing_work/rtl is a verification snapshot.

## Clock changes and scope

The routed comparisons isolate mac_axi with P=8 on xc7z020clg484-1, using an 8 ns clock and 2 ns input/output delays. These are matched out-of-context comparisons, not timing signoff for the complete Zynq system. A slack-derived clock estimate is not a measured maximum frequency or a guaranteed board clock.

To use the changed RTL in the existing Vivado project, refresh the mac module reference, regenerate its output products, reset synthesis/implementation runs, and rerun implementation. Keep the existing system block diagram. Verify setup, hold, pulse width, and unconstrained-path checks on the full routed design before using a higher FCLK setting. Do not merely edit a timing constraint to claim a faster board clock. If changing the actual Zynq FCLK, update the software FCLK_HZ assumption too; UART-based builds also need a matching CLKS_PER_BIT.

The historical generated OpenLane Verilog snapshot has not been regenerated or timed. Regenerate it from the updated SystemVerilog before using this optimization in that separate ASIC flow. Existing bitstreams and hardware exports do not contain the new RTL until rebuilt.

## Measured routed comparison

Same Vivado version, part, P=8, implementation commands, clock and interface constraints:

| Metric | Original | Final RTL |
|---|---:|---:|
| Worst setup slack at 8 ns (125 MHz) | -4.199 ns | -0.760 ns |
| Setup-equivalent minimum period (8 ns minus WNS) | 12.199 ns | 8.760 ns |
| Frequency estimate from that period | 81.97 MHz | 114.16 MHz |
| Slice LUTs | 7,099 | 6,319 |
| Block RAM tiles | 68 | 6 |

The estimated clock headroom improves approximately 39.3%. The final 125 MHz run still has 40 failing setup endpoints; it is not a passing 125 MHz implementation. Its worst hold slack is +0.151 ns and pulse-width slack is +3.020 ns. The remaining worst setup path is controller terminal-count logic to the B-lane validity register. These estimates are specific to P=8 and this device, not measurements for P=16 or SKY130.

Reports: timing_work/baseline_timing.rpt, final_timing.rpt, baseline_util.rpt, final_util.rpt. The older optimized_* reports show the intermediate controller-only revision; final_* corresponds to the installed RTL.

Re-analyzing the same routed final checkpoint at a 9.091 ns period (approximately 110 MHz) gives +0.331 ns setup slack and +0.151 ns hold slack; see final_110mhz_timing.rpt. This is a timing re-analysis, not a new board implementation. Vivado warns that HD.CLK_SRC is unset in the isolated design, so the actual top-level clock insertion delay/skew is not modeled. Complete-system routing and its real clock constraints remain essential before selecting a production clock.
