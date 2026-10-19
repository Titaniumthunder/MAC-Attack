# MAC Attack capstone: working log

Started 13 Oct 2026. Newest entries at the bottom of each section.
Tags: [done] = verified by the team, [claim] = from a document or from Claude, not verified by the team,
[proposed] = suggested, not yet agreed.

## 1. Timeline

| Date | What was done | Evidence / where |
|---|---|---|
| 13 Oct | Read the Machine Guardian proposal (acoustic anomaly detection on a ZedBoard with an adaptive INT4/INT8 systolic array). | `docs/Machine_Guardian_Project_Brief.pdf` |
| 13 Oct | Agreed demo direction: the FPGA takes an audio file and prints results "live-ish" while the audio plays. | Chat |
| 13 Oct | Arty project simulates on Vivado 2019.1: `tb_selfcheck` ALL TESTS PASSED (8/8), $finish at 330,430 ns (16x16 array). | Tcl Console |
| 13 Oct | `zed/create_zed_project.tcl` runs on Vivado 2019.1 and builds the block design by itself (Zynq -> AXI interconnect -> mac_axi, P = 8, 50 MHz). `mac` at 0x43C00000. | Tcl Console |
| 13 Oct | `tb_axi` ALL AXI TESTS PASSED (12/12) in XSim 2019.1, $finish at 1,543,900 ns. Data movement 7.0x the compute (ideal bus). | Tcl Console |
| 14 Oct | GitHub repo `Titaniumthunder/MAC-Attack` set up (private), per-person folders, `.gitignore`. | GitHub |
| 14 Oct | First ZedBoard bitstream at 50 MHz: WNS +4.664 ns, WHS +0.030 ns, all constraints met. | `Alex/timing_paths.rpt`, `Alex/utilization.rpt` |
| 15 Oct | Board programming fixed (Windows VM: USB passthrough + Digilent cable driver). | Chat |
| 15 Oct | **First board run: ALL BOARD TESTS PASSED (8/8)** at 50 MHz. Every pass and cycle count equals the equation. | SDK terminal (screenshot) |
| 15 Oct | Clock raised: FCLK_CLK0 requested 80 MHz, Zynq PLL gives **76.929 MHz** (12.999 ns). Implementation meets timing: WNS +0.135 ns, WHS +0.022 ns. | Vivado Design Runs |
| 15 Oct | Board run with the 76.9 MHz build still measured **49.77 MHz** (new clock check in `mac_test.c`): the SDK hardware platform (ps7_init) was stale, so the clock stayed at 50 MHz. | SDK terminal (screenshot) |
| 16 Oct | Exploration build at 100 MHz: fails timing (WNS -2.263 ns, 1,060 of 11,522 endpoints fail). Used to rank what limits the clock. | `Alex/design_analysis_100.rpt`, `Alex/timing_paths_100.rpt`, `Alex/timing_others_100.rpt` |
| 16 Oct | Confirmed: the B buffer (`bmem`, only 512 x 64 bits) is built from **64 BRAMs** (READ_WIDTH_B = 18). | Tcl Console |
| 16 Oct | Fixes 1-3 written in `rtl/mm_core.sv` (one BRAM per buffer, read-side counters one cycle ahead, lane masks per run). Simulation: every test log byte-identical to the old RTL, every cycle of the core identical after reset, 60/60 NumPy suite pass, plus 7 extra large/INT4/saturating cases at MAXD = 255. | Icarus Verilog 12; Yosys estimate below |
| 16 Oct | **Fixes 1-3 meet timing at 100 MHz**: WNS +1.095 ns. BRAM 6, LUT 7,073, FF 3,488. `tb_axi` 12/12. | Vivado Design Runs (screenshot) |
| 16 Oct | 2-stage PE written (cycle 1 multiply into a product register, cycle 2 add), plus BRAM output register and `use_dsp` hint. New parameters `PIPE` and `MEM_REG` (default 1 and 1). Simulation: all 7 testbenches pass in all 4 PIPE/MEM_REG combinations; 60/60 NumPy suite in each; PIPE = 0, MEM_REG = 0 is byte-identical to fixes 1-3; the default build differs only in `$finish` times and `perf_total` (+2); C is written with the same rows and values in the same order. Not yet built in Vivado. | Icarus Verilog 12; Yosys: 64 DSP48E1, 6 RAMB36E1 |
| 16 Oct | **2-stage PE build meets timing at 142.857 MHz** (FCLK 1000/7): WNS +0.456 ns, WHS +0.046 ns. LUT 2,062 (was 7,073), FF 2,252 (was 3,488), BRAM 6, DSP48E1 128 (2 per PE, expected 1). `tb_axi` reached $finish at 1,543,900 ns (same as before, as in Icarus); pass line not yet confirmed. The BRAM output register was absorbed into the BRAM (clk-to-out 0.88 ns). | `Alex/timing_summary_v2.rpt`, `utilization_v2.rpt`, `timing_paths_v2.rpt`, `design_analysis_v2.rpt` |
| 16 Oct | Fixes for the four slowest paths at 142.857 MHz: (1) `mac_axi.v` registers the AXI write address/data and decodes from the copies; (2) lane mask moved in front of the MEM_REG register; (3) C read one cycle earlier and registered, sum registered, C written one cycle later; (4) reset registered once in `mac_axi.v` (max_fanout 64), no reset on data registers (PE, skew/deskew, memory outputs). Simulation: all 7 testbenches in all 4 PIPE/MEM_REG combinations with logs byte-identical to the 2-stage version (same cycles, same `perf_total`); 60/60 suite in each; 9 extra cases (255x255x255, INT4, saturating, P = 3, M = 1) identical. Not yet built in Vivado. | Icarus Verilog 12; Yosys: FF 2,391 -> 1,582, SRL16E 184, CARRY4 183 -> 168, DSP48E1 64 |
| 16 Oct | **Path fixes meet timing at 166.667 MHz** (FCLK 1000/6): WNS +0.176 ns, WHS +0.028 ns. LUT 1,755, FF 2,536, SRL 304, BRAM 6, DSP 128. DSP check (PE 1,1): `prod_q_reg` AREG=2 BREG=2 MREG=0 PREG=1, `psum_out_reg` AREG=0 BREG=0 PREG=1, so the add has its own DSP (2 per PE). | `Alex/timing_summary_v3.rpt`, `timing_paths_v3.rpt`, `utilization_v3.rpt`, Tcl console |
| 16 Oct | Clock speed history written up step by step (50 -> 76.9 -> 100 -> 142.9 -> 166.7 MHz): what changed, why, cost, result. | Section 5 |
| 16 Oct | Changes for 200 MHz written (step 6 in section 5): loader limits in registers, `cq2` cleared by reset, skew/deskew from flip-flops, AXI read data registered, MEM_REG = 2 on the ZedBoard, `use_dsp` on the multiply only. All 7 testbenches in 6 PIPE/MEM_REG combinations; 60/60 suite in 4 of them; 9 extra cases identical. Not yet built in Vivado. | Icarus Verilog 12 |
| 16 Oct | **200 MHz build fails by 0.385 ns** (WNS -0.385, TNS -44.4, 318 endpoints; floor about 186 MHz). The failing path is the product crossing from the multiply DSP to a second DSP that does the add (2 DSPs per PE). Step 7 written: add moved into LUT carry chains. `tb_axi` 12/12 in XSim ($finish 1,665,400 ns). | `mac_zed.runs/impl_1/system_wrapper_timing_summary_routed.rpt`, Design Runs (screenshot) |
| 17 Oct | Step 7 (PE add in LUTs) built: **200 MHz fails**; asking for 180 MHz gave **187.512 MHz, which meets timing** (WNS +0.416 ns, WHS +0.036 ns). DSPs 128 -> 64. LUT 2,768, FF 4,532, BRAM 6. `tb_axi` 12/12 in XSim. Worst paths are now the AXI loader and the start-of-run lane masks, not the array. No more RTL changes for now. | `mac_zed.runs/impl_1/system_wrapper_timing_summary_routed.rpt` (17 Oct 00:06), `system_wrapper_utilization_placed.rpt` |
| 17 Oct | Step 7c: same RTL as 7b, clock asked for 190 MHz, the Zynq gave **200.000 MHz**, and it **meets timing**: WNS +0.209 ns, WHS +0.015 ns, 0 failing endpoints (of 10,335). LUT 2,779, FF 4,532, BRAM 6, DSP 64, total power 2.012 W. The 10 worst paths are all in `mac_axi.v` (RESULT_DATA stepping, loader -> block-RAM write enable); none in the array. Reports copied to `Alex/timing_summary_v4.rpt` and `Alex/utilization_v4.rpt` (the 187.5 MHz reports were overwritten and are lost). | `mac_zed.runs/impl_1/system_wrapper_timing_summary_routed.rpt` (17 Oct 16:45), Design Runs (screenshot) |
| 17 Oct | Step 8 prepared (board run at 200 MHz): `create_zed_project.tcl` now asks for 200 MHz; SDK `MAC_attack_V2/src/mac_test.c` has `FCLK_HZ` = 200,000,000 and two new tests (the two largest sums possible with K = 64). Procedure in section 5, step 8. Not run on the board yet. | files |
| 17 Oct | Steps 9 and 10 written (control paths in `mac_axi.v` and `mm_core.sv`; exact 22-bit accumulators). Simulation results in section 5. | Icarus Verilog 12, Verilator 5.020 |
| 17 Oct | **Steps 9 + 10 built together** (`EXACT_ACC` left at 1), 200.000 MHz (asked 190): **WNS +0.529 ns** (was +0.209), WHS +0.014 ns, 0 failing of 9,155 endpoints. LUT 2,192 (was 2,779), FF 3,847 (was 4,532), BRAM 4.5 tiles (was 6), DSP 64, CARRY4 398 (was 540), power 1.935 W (was 2.012). `tb_axi` 14/14 in XSim. The worst paths are now inside the array (PE add, weight-load enable), none in `mac_axi.v`. Reports copied to `Alex/timing_summary_v5.rpt`, `Alex/utilization_v5.rpt`. Not run on the board yet. | `impl_1` reports (17 Oct 17:49) |
| 17 Oct | Steps 10b, 11 and 12 written (`w_load` from a flip-flop; `PIPE = 2` PE with the add in the DSP; the core on its own clock). Simulation results in section 5. Not yet built in Vivado. | Icarus Verilog 12, Verilator 5.020 |
| 17 Oct | Steps 10b + 11 synthesized with FCLK 250.000 MHz. Refreshing the `mac` block gave critical warning [Coretcl 2-1280] (expected: `mac_axi` has new ports and parameters). Synthesis used PIPE = 2, EXACT_ACC = 1, CORE_CLK = 0 as intended, but **128 DSPs (2 per PE)**: the multiply in one DSP (MREG = 1, PREG = 0), the add in a second (PCIN + A:B, PREG = 1). The partial sums do use the cascade, but the product crosses the general routing unregistered, so 250 MHz is not expected to pass. | `system_mac_0_synth_1/runme.log` (DSP Final Report), `system_mac_0_utilization_synth.rpt` |
| 17 Oct | Step 11b written: each PE as one DSP48E1 placed directly (`zed/pe_dsp48.sv`, `PE_PRIM = 1`, the new default). Checked against Xilinx's own DSP48E1 simulation model (section 5). Not yet built. | Icarus Verilog 12 + XilinxUnisimLibrary DSP48E1.v |
| 17 Oct | **Step 11b built at 250.000 MHz** (one clock): **64 DSPs** (one per PE), but timing fails by 0.263 ns: WNS -0.263 ns, TNS -3.113 ns, 45 of 10,707 endpoints, WHS +0.037 ns (floor about 235 MHz). LUT 1,119 (was 2,192), FF 2,895 (was 3,847), BRAM 4.5, DSP 64, CARRY4 86 (was 398), power 1.940 W. No array path among the 10 worst: host read of C (7 paths), Xilinx AXI interconnect (1), the controller's last-row compare (2). Reports copied to `Alex/timing_summary_v6.rpt`, `Alex/utilization_v6.rpt`. | `impl_1` reports (17 Oct 22:40), Design Runs (screenshot) |
| 17 Oct | Worst 100 paths of the 250 MHz build (`Alex/timing_paths_v6.rpt`): of the 45 failing endpoints, 25 are on the bus side (C read, AXI interconnect, loader) and 20 in the core (last-row compare, state -> read-counter reset, A block RAM -> register, top-row weight wire). | `Alex/timing_paths_v6.rpt` |
| 18 Oct | **Step 13 written** (`rtl/mm_core.sv` only): last-row flags, `idle_q`, the A/B feed registers swapped (MEM_REG = 2). Simulation: 0 differences against the step 11b core in every cycle (45 settings, 4.26 million cycles); NumPy suite 560/560 exact; `tb_axi` 14/14 and byte-identical (P = 4, 8, 16; DSP48E1 and `pe.sv`); two clocks 15/15 (38.5 to 400 MHz core); team testbenches byte-identical; `mac.py test` 60/60; 6 planted bugs caught. Not built yet. | Icarus Verilog 12, Verilator 5.020, Xilinx DSP48E1 model |
| 16 Oct | `docs/systolic_dataflow.html`: animated cycle-by-cycle view of data moving from the A/B buffers through the array to C (1-stage / 2-stage PE, MEM_REG on/off). Its model matches `systolic_array.sv` + `pe.sv` in Icarus cycle for cycle (every PE partial-sum register, `c_row`, `out_valid`; P = 2, 3, 4, PIPE = 0 and 1). | Icarus Verilog 12 |

(Add a row each time work is finished.)

## 2. Decisions and reasons

| Date | Decision | Reason | Status |
|---|---|---|---|
| 13 Oct | Board = ZedBoard (XC7Z020-1). | Professor prefers it; the school owns one. | agreed |
| 13 Oct | Sound is the sensor for Machine Guardian. | Matches the proposal. | agreed |
| 13 Oct | The systolic array itself stays a matrix engine. Audio comes in through a separate front end. | The array only multiplies INT8 matrices. | agreed |
| 13 Oct | First demo front end: a PC streams features at real-time pace. Line-in jack and codec later. | Deterministic, checkable against Python. | [proposed] |
| 13 Oct | Live output is an anomaly score over time against a threshold, not AUC. | AUC needs many labelled clips (offline). | [proposed] |
| 14 Oct | Hardware stays a 2-D matrix-multiply engine; tensors (batches, convolutions) are reshaped into matrix multiplies in software. | Same as TPU-style designs; a 3-D array costs area for no gain on this workload. | [proposed] |
| 15 Oct | Single clock raised through the Zynq FCLK_CLK0 setting (not the Clocking Wizard) for now. | Simplest; the wizard is kept for the two-clock v2 design. | agreed |
| 15 Oct | Multiple boards, Raspberry Pi gateway and internet access: deferred. Focus on one FPGA working correctly. | Scope. | agreed |
| 16 Oct | No new board: the department will not buy one (Kria KV260 / ZUBoard were considered). | Budget. | agreed |
| 16 Oct | Goal: raise the clock and simplify the circuit; Alex tries the fixes first; architecture redesign (v2) after that, keeping an open mind. | Timing analysis below. | agreed |
| 16 Oct | Clock target 150 MHz or more ("aim higher"). Next step: 2-stage PE (multiply, then add) and a BRAM output register. | After fixes 1-3 the PE multiply-add and BRAM -> PE are the longest paths. | agreed |
| 17 Oct | Speed-ups must not change any result: every change is checked bit-exact against NumPy and against the previous RTL. | Show the processing is faster and still correct. | agreed |
| 17 Oct | Step 11: PE add inside the DSP (`PIPE = 2`), behavioral RTL first; a direct DSP48E1 PE only if Vivado does not map it. | The PE add was the worst path at 200 MHz. | agreed |
| 17 Oct | Step 12: the core gets its own clock from a Clocking Wizard (the professor's suggestion; GALS as in Simba). | The AXI port to the ARM is limited to 250 MHz. | agreed |
| 17 Oct | Step 13 before the step 12 build: three core fixes, every cycle and result unchanged. | The worst 100 paths at 250 MHz had 20 failing core endpoints, and the core stays at 250 MHz in step 12. | agreed |
| 17 Oct | Fallback for Monday: the 200 MHz build (steps 9 + 10) if 250 MHz does not pass; a core clock of 240 MHz from the wizard if it misses by a little. | Step 13 changes no result or cycle, so it can stay in either case. | agreed |

## 3. Current status (what is and is not proven)

- [done] RTL simulation: 60/60 cases match NumPy; Vivado `tb_selfcheck` 8/8.
- [done] AXI wrapper `tb_axi` 12/12 in XSim 2019.1.
- [done] ZedBoard block design, bitstream, timing met at 50 MHz and at 76.9 MHz.
- [done] Board: 8/8 tests pass at 50 MHz.
- [done] Fixes 1-3: timing met at 100 MHz in Vivado (WNS +1.095 ns). Not yet run on the board at 100 MHz.
- [done] 2-stage PE: timing met at 142.857 MHz in Vivado (WNS +0.456 ns). Not yet run on the board.
- [done] Fixes for the four 142.857 MHz paths: timing met at 166.667 MHz (WNS +0.176 ns). Not yet run on the board.
- [done] Step 6 built at 200 MHz: failed by 0.385 ns (worst path 5.39 ns, floor about 186 MHz). `tb_axi` 12/12 in XSim.
- [done] Step 7: timing met at **187.512 MHz** (WNS +0.416 ns), 64 DSPs. 200 MHz failed. Not yet run on the board.
- [done] Step 7c: timing met at **200.000 MHz** (WNS +0.209 ns), same RTL as step 7, clock asked for 190 MHz. Not yet run on the board.
- [done] Steps 9 and 10 in simulation: every result bit-exact against NumPy and identical to step 7c (section 5).
- [done] Steps 9 + 10 built together: timing met at 200.000 MHz with WNS +0.529 ns (floor about 224 MHz). Not yet run on the board.
- [done] Steps 10b, 11, 12 in simulation (section 5).
- [done] Step 11b built at 250 MHz, one clock: 64 DSPs, timing fails by 0.263 ns, no array path among the worst (section 5). Not run on the board.
- [done] Step 13 in simulation (section 5). Not built.
- NOT done: step 12 (two clocks) built in Vivado.
- NOT done: board run that actually runs at 76.9 MHz (needs the SDK hardware platform updated; see section 6).
- NOT done: Release (-O2) build of `mac_test.c`; the ARM software times so far are from the Debug build.
- NOT done: INT8 and INT4 AUC on real data. Nothing trained yet.
- NOT done: audio front end.

## 4. Board results (50 MHz, Debug build)

All times in microseconds. Speedup = ARM software / (load + run + read).

| Test | Array (calc) | Load | Run | Read | ARM software | Winner |
|---|---|---|---|---|---|---|
| 4x4x4 | 0.5 | 6 | 1 | 6 | 4 | ARM, 3.3x |
| 16x16x16 | 3 | 74 | 3 | 97 | 189 | Accelerator, 1.1x |
| 64x64x64 | 110 | 1,153 | 110 | 1,549 | 11,223 | Accelerator, 4.0x |
| 37x50x23 | 25 | 425 | 25 | 322 | 1,833 | Accelerator, 2.4x |
| 1x64x64 | 29 | 586 | 29 | 24 | 175 | ARM, 3.7x |

- 64x64: moving data is 96% of the time; (load + read) / array = 24.5x, against 6.7x in the ideal-bus simulation.
- [claim] The ARM software time is a steady ~43 ns per multiply-add, which suggests an unoptimised (Debug, -O0) build. Re-measure with Release before quoting any speedup.
- [claim] The 1x64x64 case is the autoencoder's shape (one row at a time). Reloading all weights per inference would take ~37 ms (estimate), longer than a 32 ms audio hop, so weights must stay in the FPGA.

## 5. Clock speed history (step by step)

One entry per Vivado build that changed the clock or the RTL. ZedBoard XC7Z020-1, P = 8.

How to read a timing result:

    worst path = T_clk - WNS             (the slowest register-to-register path, at most)
    floor Fmax = 1 / (T_clk - WNS)       (a floor, not a ceiling: the tool only works as hard as the clock asks)
    every path:  T_clk >= t_clk->Q + t_wire + t_logic + t_setup + t_jitter

Zynq PL clocks come from one of the PS PLLs divided by whole numbers. From the 1000 MHz IO PLL: 1000/13 = 76.9,
/10 = 100, /7 = 142.9, /6 = 166.7, /5 = 200. Other values come from another PLL: asking for 180 MHz gave 187.512 MHz.
Always use the Actual Frequency Vivado shows (or the Clocking Wizard for exact values). The board itself keeps
running at 50 MHz until the SDK hardware platform (ps7_init) is updated (section 6).

| Step | Date | Clock (MHz) | Met? | WNS / WHS (ns) | Worst path / floor | What changed | Run cycles | LUT / FF / BRAM tiles / DSP |
|---|---|---|---|---|---|---|---|---|
| 0 | 14 Oct | 50 | yes | +4.664 / +0.030 | 15.34 ns / 65 MHz | First bitstream (original RTL) | Np(M+3P-2) + 3 | as step 1 |
| 1 | 15 Oct | 76.929 (asked 80) | yes | +0.135 / +0.022 | 12.86 ns / 78 MHz | Clock setting only (FCLK_CLK0) | same | 7,577 / 3,573 / 68 / 0 |
| 2 | 16 Oct | 100 | **no** | -2.263 / - | 12.26 ns / 82 MHz | Nothing: exploration build to rank the limits | same | - |
| 3 | 16 Oct | 100 | yes | +1.095 / - | 8.91 ns / 112 MHz | Fixes 1-3 in `mm_core.sv` | same | 7,073 / 3,488 / 6 / 0 |
| 4 | 16 Oct | 142.857 (asked 150) | yes | +0.456 / +0.046 | 6.54 ns / 153 MHz | 2-stage PE, BRAM output register, `use_dsp` | +2 (Np(M+3P-2) + 5) | 2,062 / 2,252 / 6 / 128 |
| 5 | 16 Oct | 166.667 | yes | +0.176 / +0.028 | 5.82 ns / 172 MHz | Fixes for the 4 slowest paths (AXI write, lane mask, C update, reset) | same as step 4 | 1,755 / 2,536 / 6 / 128, + 304 SRLs |
| 6 | 16 Oct | 200 | **no** | -0.385 / +0.015 | 5.39 ns / 186 MHz | Loader limits in registers, `cq2` clear, skew/deskew from flip-flops, AXI read data registered, MEM_REG = 2, `use_dsp` on the multiply only | +1 per run (Np(M+3P-2) + 6) | 1,663 / 3,188 / 6 / 128 |
| 7a | 17 Oct | 200 | **no** | not recorded | - | The PE's 32-bit add moved out of DSPs into LUT carry chains (`use_dsp = "no"`) | same as step 6 | - |
| 7b | 17 Oct | **187.512** (asked 180) | **yes** | +0.416 / +0.036 | 4.92 ns / 203 MHz | Same RTL as 7a, slower clock | same as step 6 | 2,768 / 4,532 / 6 / **64** |
| 7c | 17 Oct | **200.000** (asked 190) | **yes** | +0.209 / +0.015 | 4.79 ns / 208 MHz | Same RTL as 7b, clock setting only | same as step 6 | 2,779 / 4,532 / 6 / 64 |
| 9 + 10 | 17 Oct | 200.000 (asked 190) | **yes** | +0.529 / +0.014 | 4.47 ns / 224 MHz | Control paths (step 9) and exact 22-bit accumulators (step 10), built together | same as step 6 | 2,192 / 3,847 / 4.5 / 64 |
| 10b + 11 | 17 Oct | 250.000 | synthesis only | - | - | `w_load` from a flip-flop; `PIPE = 2` (add inside the DSP): Vivado made 2 DSPs per PE | +1 per run: `perf_total = perf_cycles + 7` | mac block: 704 / 2,377 / 4.5 / **128** (synthesis) |
| 11b | 17 Oct | 250.000 | **no** | -0.263 / +0.037 | 4.26 ns / 235 MHz | Each PE as one DSP48E1 placed directly (`PE_PRIM = 1`) | same as 10b + 11 | 1,119 / 2,895 / 4.5 / **64** |
| 12 | - | AXI 200, core 250 + | not built | - | - | The core on its own clock (Clocking Wizard), `CORE_CLK = 1` | same as 10b + 11, in core cycles | - |
| 13 | - | (core 250, with step 12) | not built | - | - | Last-row flags, `idle_q`, A/B feed registers swapped (MEM_REG = 2) | no change | - |

### Step 0 -> 1: 50 to 76.9 MHz (clock setting only, 15 Oct)

- Changed: FCLK_CLK0 in the Zynq block, 50 -> 80 MHz requested; the PLL can only give 76.929 MHz.
- Why it worked: the 50 MHz build had 4.66 ns of slack, so the design was already faster than 50 MHz.
- Lesson: slack at a relaxed clock is a floor. The estimate "about 65 MHz" from the 50 MHz slack was too pessimistic.

### Step 2: 100 MHz fails, and why (exploration build, 16 Oct, no change)

WNS -2.263 ns, TNS -1,240 ns, 1,060 failing endpoints. What limited the clock:

| Rank | Structure | Worst slack at 100 MHz | Notes |
|---|---|---|---|
| 1 | A/B buffer read address: `t_reg` -> `o == t-1` -> next-cycle counters -> `k_n*TM + n_nb` -> BRAM address (`mm_core.sv` 89-121) | **-2.263 ns** | All 50 worst paths. 15-16 logic levels (11 carry chains), fanout 689, ~55% routing. Ends on the address pins of the A/B BRAMs. |
| 2 | B lane masks: `nt_reg` / `kt_reg` -> `b_lanes_q` (`mm_core.sv` 117-120) | **-1.768 ns** | 17-19 logic levels, 12-13 carry chains (32-bit compares). |
| 3 | PE multiply-add: weight register -> 8x8 LUT multiply -> 33-bit add -> output deskew (`pe.sv`) | +0.020 ns | ~9.5 ns. Multipliers are in LUTs (0 DSPs used). |
| 4 | A BRAM output -> PE row 0 multiply-add | +0.195 ns | BRAM read without output register feeding the MAC directly. |
| 5 | AXI loader: `dim_k` -> `ld_col` enable (`mac_axi.v`) | +0.403 ns | Mostly routing (7.5 ns). |

Why #1 was so slow: each 64-bit A/B buffer was split into 64 BRAMs (confirmed for `bmem`: 64 cells, READ_WIDTH_B = 18),
because of a variable part-select write, so the address fanned out across the chip; and the address was computed with
32-bit `int` arithmetic in the same cycle as the read.

### Step 3: 100 MHz met with fixes 1-3 (`mm_core.sv`, 16 Oct)

1. One BRAM per buffer: A and B are written with a byte enable per lane (fixed slices), marked `ram_style = "block"`.
   BRAM tiles 68 -> 6.
2. Read side runs one cycle ahead on its own small counters (`ro`, `rkb`, `rnb`, `ri`) with phase flags (`rw`, `ra`).
   For P and TM powers of two the read addresses are just bit fields of those counters (no adders). The array's
   control signals are the same flags one cycle later. Widths are the real ones (7-9 bits), not 32-bit `int`.
3. Limits (t-1, kt-1, nt-1, M-1) and the lane masks of the last K and N tiles are worked out once at start.

- Cost: none. Behaviour is unchanged cycle for cycle, so `PERF_CYCLES = Np (M + 3P - 2)` still holds and `mac_test.c` needs no change.
- Simulation: every test log byte-identical to the old RTL; 60/60 suite; 7 extra large/INT4/saturating cases at MAXD = 255.
- [claim] Yosys estimate: block RAMs 20 -> 6 (A 1, B 1, C 4), CARRY4 277 -> 183, LUT2 909 -> 244.
  Vivado check: `llength [get_cells -hier -filter {NAME =~ *u_core/bmem_reg* && REF_NAME =~ RAMB*}]` (expect 1).
- Result: WNS +1.095 ns at 100 MHz (worst path at most 8.9 ns). Next limits: PE multiply-add (#3) and BRAM -> PE (#4).

### Step 4: 142.857 MHz met with the 2-stage PE (16 Oct)

Files: `rtl/pe.sv`, `rtl/systolic_array.sv`, `rtl/mm_core.sv`. Parameters PIPE and MEM_REG (default 1 and 1).

- `pe.sv`, PIPE = 1: `prod_q <= a_in * w` (cycle 1), `psum_out <= psum_in + prod_q` (cycle 2). Every PE adds the same
  cycle, so the partial sum from above and the registered product still belong to the same row of A:
  row i reaches the adder of PE (k, j) at cycle s + i + k + j + PIPE. Array latency becomes 2P - 1 + PIPE.
- The multiply still uses the weight in the same cycle as before, so the next tile's weight load is not disturbed:
  cycles per pass stay M + 3P - 2 and `PERF_CYCLES` is unchanged.
- `mm_core.sv`, MEM_REG = 1: a second register after each BRAM read (BRAM output register), with the control flags
  delayed to match; one extra prime state (`S_PRIME2`). Vivado put it inside the block RAM: data leaves 0.88 ns after
  the clock instead of about 2.45 ns.
- `(* use_dsp = "yes" *)` on `pe`: multipliers move from LUTs into DSP48E1 slices. LUTs 7,073 -> 2,062.
- Cost: `perf_total = perf_cycles + 3 + PIPE + MEM_REG` (+5 by default, was +3), so 2 cycles per run.
- Simulation: all 7 testbenches in all 4 PIPE/MEM_REG combinations; 60/60 suite in each; PIPE = 0, MEM_REG = 0 byte-identical
  to step 3; C written with the same rows and values in the same order.
- Result: WNS +0.456 ns, WHS +0.046 ns at 142.857 MHz (worst path at most 6.544 ns, floor about 153 MHz).
- Found: 128 DSPs, 2 per PE (Yosys had estimated 64). Explained in step 5.
- Per-stage overhead on the path in the 100 MHz report: clk->Q 0.42 + setup 0.566 + uncertainty 0.154 = about 1.14 ns,
  so even a stage with no logic cannot pass about 877 MHz. Each further split gains less.

What limited step 4 (all within 0.4 ns of each other at 7.0 ns):

| Rank | Path | Needed | Delay breakdown |
|---|---|---|---|
| 1 | ARM write (PS7 WVALID) -> loader decode -> `ld_row`/`ld_col` enable (`mac_axi.v`) | 6.54 ns | PS7 clk-to-out 1.33, wires 3.88 (64%), 5 LUTs 0.87 |
| 2 | A BRAM -> lane mask (LUT2) -> PE (0,0) DSP A input | 6.43 ns | DSP A-input setup 3.72 (multiplier inside the setup, A register unused) |
| 3 | C buffer read -> 32-bit add (8 CARRY4) -> C buffer write | 6.38 ns | BRAM clk-to-out 2.45 (no output register), adder 1.68 |
| 4 | Reset -> DSP reset pins | 6.17 ns | one wire with fanout 1,760: 5.10 ns |

### Step 5: 166.667 MHz met with fixes for the four slowest paths (16 Oct)

Files: `rtl/delay_line.sv`, `rtl/pe.sv`, `rtl/systolic_array.sv`, `rtl/mm_core.sv`, `zed/mac_axi.v`.

| Path at 142.857 MHz | Fix | Cost |
|---|---|---|
| ARM write -> loader decode | `mac_axi.v` copies the write address and data into flip-flops and decodes from the copies (AXI holds them steady until accepted, so `wr_fire` is just `axi_awready`) | 0 cycles |
| A BRAM -> lane mask -> PE (0,0) | Lane mask applied in front of the MEM_REG register, so the array input comes straight from a flip-flop | 0 cycles |
| C read -> add -> C write | C read one cycle earlier and registered (`cq2`); sum registered (`wq`); written one cycle later. Safe because a C word is read again only in the next pass, at least M + 3P - 5 cycles later. Counters in this path narrowed to 6-8 bits | 0 cycles |
| Reset fanout | Reset registered once in `mac_axi.v` (`max_fanout = 64`); no reset on data registers (PE weight/activation/product/partial sum, skew and deskew delays, memory outputs). Delay lines get `srl_style = "srl_reg"` | 0 cycles |

- Simulation: all 7 testbenches in all 4 PIPE/MEM_REG combinations with logs byte-identical to step 4 (same cycles, same
  `perf_total`); 60/60 suite in each; 9 extra cases (255x255x255, INT4, saturating, P = 3, M = 1) identical.
- Yosys estimate: FF 2,391 -> 1,582, SRL16E 184, CARRY4 183 -> 168, DSP48E1 64.
- Result: WNS +0.176 ns, WHS +0.028 ns at 166.667 MHz (worst path at most 5.824 ns, floor about 172 MHz).
  LUT 1,755, FF 2,536, SRL 304, BRAM 6, DSP 128.
- DSP check (PE 1,1): `prod_q_reg` AREG=2 BREG=2 MREG=0 PREG=1, `psum_out_reg` AREG=0 BREG=0 MREG=0 PREG=1.
  Vivado pulled the activation and weight registers into the multiply DSP (AREG=2, BREG=2) and kept the product in its
  output register (PREG), so the 32-bit add got a second DSP of its own: 2 DSPs per PE.

### Step 6: changes for 200 MHz (written 16 Oct, not yet built in Vivado)

Paths at 166.667 MHz that needed more than 5.0 ns, and what was changed:

| Path at 166.667 MHz | Needed | Change | Cost |
|---|---|---|---|
| Loader: `ld_sel` -> row/column compares -> `ld_row`/`ld_col` enable (`mac_axi.v`) | 5.82 ns | The loader's limits (`ld_rows`, `ld_rowlen`, `ld_collast` = row length - 1) are registers, updated from `ld_sel` and the dimensions every cycle. They change only on a DIMS or LOAD_PTR write, at least 2 cycles before the next LOAD_DATA write can start. `ld_col + 1 == ld_rowlen` became `ld_col == ld_collast` (no adder) | 0 |
| Loader -> A/B block-RAM write enable | 5.61 ns | Same change | 0 |
| `cap_first` (fanout 256, 3.36 ns of wire) -> 32-bit add -> `wq` | 5.55 ns | `cq2` is cleared by its own synchronous reset when `cap_first` is 1, so the adder is just `cq2 + c_row`. `cap_first` has `max_fanout = 32` | 0 |
| Skew shift-register LUT -> DSP A input | 5.51 ns | `delay_line` uses `srl_style = "register"`: delays are built from flip-flops. (With "srl_reg", Vivado moved the end flip-flop into the DSP and left the LUT output, 1.64 ns after the clock, driving the wire.) | ~1,100 more FFs |
| C block RAM -> lane select -> AXI read data | 5.41 ns | `mac_axi.v` registers the C read data (`core_rd_q`); an AXI read now waits 3 cycles instead of 2 | +1 cycle per AXI read |
| B feed register -> far DSP B input (4.35 ns of wire) | 5.30 ns | `MEM_REG = 2`: a third register on the A and B feed and on the control flags, so the placer can put it halfway. `mac_axi.v` now passes `PIPE` and `MEM_REG` (ZedBoard: 1 and 2); `mm_core.sv` default stays 1. `S_PRIME` lasts 1 + MEM_REG cycles | +1 cycle per run: `perf_total = perf_cycles + 6` |
| 2 DSPs per PE | - | `use_dsp` moved from the whole `pe` module to the multiply only, so Vivado is not forced to give the add its own DSP | to be seen |

- Simulation (Icarus 12):
  - All 7 testbenches pass for PIPE = 0, 1 and MEM_REG = 0, 1, 2 (6 combinations).
  - With MEM_REG = 0 or 1, every log except `tb_axi` is byte-identical to step 5.
  - With MEM_REG = 2, the only differences are `perf_total` + 1 (`tb_mm` 55 -> 56) and the `$finish` times.
  - `tb_axi` differs only in its bus timings: each AXI read takes 1 more clock (4x4x4 read 100 -> 116 clocks); the 12 results are all correct.
  - 60/60 suite for PIPE/MEM_REG = 0/0, 1/1, 0/2 and 1/2 (the ZedBoard setting); identical to step 5 except the run totals.
  - 9 extra cases at 1/2 (255x255x255, INT4, saturating, P = 3, M = 1): identical results, run totals + 1 cycle.
- Files: `rtl/delay_line.sv`, `rtl/pe.sv`, `rtl/mm_core.sv`, `zed/mac_axi.v` (`rtl/systolic_array.sv` unchanged).
- Result at 200 MHz (16 Oct): **failed**, WNS -0.385 ns, TNS -44.427 ns, 318 of 13,260 endpoints; WHS +0.015 ns.
  Worst path 5.385 ns, so the floor is about 186 MHz. LUT 1,663, FF 3,188 (+652; shift-register LUTs 180 -> 60),
  BRAM 6, DSP still 128. `tb_axi` 12/12 in XSim, `$finish` at 1,665,400 ns (as predicted from Icarus).
- What failed: all 10 worst paths are inside a PE, from the multiply DSP (`prod_q_reg`) to the add DSP
  (`psum_out_reg`): 0.43 ns out of the first DSP + 2.6-3.1 ns of general routing + 1.94-1.96 ns setup through the
  second DSP's adder to its output register. Moving `use_dsp` to the multiply did not stop Vivado from giving the
  add its own DSP. The six step 6 fixes removed every path listed for step 5 from the worst paths.

### Step 7: PE add in LUT carry chains (written 16 Oct, built 17 Oct)

- Change (`rtl/pe.sv` only): `(* use_dsp = "no" *)` on the 33-bit `sum`, keeping `(* use_dsp = "yes" *)` on the
  multiply. The add is built from LUTs and carry chains next to the multiply DSP, so the product leaves the DSP's
  output register (about 0.4 ns), crosses a short wire, and goes through a 32-bit carry chain (about 1.7 ns) into
  `psum_out` flip-flops. Estimate: about 3.5 ns instead of 5.4 ns. [claim, not measured]
- Expected resources: DSP 128 -> 64 (one per PE); LUTs about +2,000 and FFs about +2,000 for P = 8 (64 PEs x 32-bit
  adders and `psum_out` registers). Lets P grow to 14 within 220 DSPs.
- Cost: none in cycles. Attribute-only change: every simulation log is byte-identical to step 6.
- If it still fails: the fallback is a 3-stage PE (one more register between the multiply and the add, all PEs alike,
  array latency 2P + 1), which keeps the 2 DSPs but gives the second one registered inputs.
- `tb_axi` (XSim, 17 Oct): ALL AXI TESTS PASSED (12/12), same output as step 6.
- Result at 200 MHz (7a): **failed**. The WNS was not recorded; the report was overwritten by the next build.
- Result at 187.512 MHz (7b, asked for 180 MHz): **met**, WNS +0.416 ns, WHS +0.036 ns, 0 failing endpoints.
  Worst path at most 4.917 ns, so the floor is about 203 MHz. The 200 MHz build still failed because the tool's result
  depends on the target (placement and routing change with the clock); the margin at 200 MHz is a few tenths of a ns.
- Resources at 187.512 MHz: **DSP 128 -> 64** (one per PE, as intended), LUT 1,663 -> 2,768, FF 3,188 -> 4,532,
  CARRY4 540, LUTRAM 60, BRAM 6. The LUT/FF increase is the 64 adders and their `psum_out` registers moving out of DSPs.
- What limits it now (worst 10 paths at 187.512 MHz, all control logic, none in the PE array):

  | Path | Needs | Notes |
  |---|---|---|
  | Loader: `ld_row` -> row compare (CARRY4) -> `ld_col` enable (`mac_axi.v`) | 4.92 ns | 3 logic levels, 3.0 ns of wire (68%) |
  | Start of run: `dim_n` -> lane mask of the last N tile (`nmask_last`, 6 CARRY4) (`mm_core.sv`) | 4.87 ns | computed in one cycle at start from the dimensions |
  | Loader: `ld_col` -> column compare -> `ld_row` enable | 4.87 ns | 3 logic levels, 3.7 ns of wire (82%) |

- Files built: `rtl/pe.sv` (step 7) with the step 6 versions of `rtl/delay_line.sv`, `rtl/mm_core.sv`, `zed/mac_axi.v`.
- Not changed after this build (17 Oct): the team decided to stop here for now. The paths above are the starting
  point if we go for 200 MHz later.

### Step 7c: 200 MHz met by asking for 190 MHz (17 Oct)

- Change: FCLK_CLK0 requested 190 MHz; the Zynq gave 200.000 MHz (1000 MHz IO PLL / 5), the same clock as step 7a.
  No RTL change.
- Result: **met**, WNS +0.209 ns, WHS +0.015 ns, TNS 0, 0 of 10,335 endpoints failing. Worst path at most 4.79 ns,
  floor about 208 MHz. LUT 2,779 (2,719 logic + 60 memory), FF 4,532, BRAM 6 (RAMB36), DSP 64. Power 2.012 W.
- [claim] Why 7a failed and 7c passed with the same 5.000 ns clock: changing the Zynq setting regenerates the PS7
  block, so the placer starts from a slightly different netlist and finds a different placement. The margin is only
  0.209 ns, so an unrelated change could lose it again. Steps 9 and 10 are meant to widen it.
- Reports: `Alex/timing_summary_v4.rpt`, `Alex/utilization_v4.rpt`. The 187.5 MHz reports were overwritten by this
  run. From now on, copy the `impl_1` reports to `Alex/` after every build (next: `_v5`).
- What limits it now (the 10 worst paths in the report; all in `mac_axi.v`, none in the array):

  | Path | Slack | Needs | Notes |
  |---|---|---|---|
  | `dim_n` -> `rd_col + 1 == dim_n` -> `rd_col` reset pin | +0.209 | 4.79 ns | RESULT_DATA stepping; 3 LUTs, 74% wire |
  | AXI interconnect read FIFO (`auto_pc` ... `cnt_read`) -> `rready` -> `rd_col` reset pin | +0.245 | 4.76 ns | the interconnect's handshake reaches our counters |
  | `ld_row` -> `ld_row < ld_rows` (CARRY4) -> A buffer write enable (`amem` ENBWREN) | +0.245 | 4.76 ns | loader bounds check into the block RAM |
  | `ld_col` -> bounds check -> B buffer write enable (`bmem` ENBWREN) | +0.387 | 4.61 ns | same, B buffer |

  "Needs" here is the clock period minus the slack. Only 10 paths are in the summary report, so paths with slack
  between +0.387 and about +0.5 ns are not visible. Next build: also write the worst 100 paths (Tcl in step 9).

### Step 8: board run at 200 MHz (prepared 17 Oct, not done)

Why: since 15 Oct every result above 50 MHz is a timing report only. The board has only ever run at 50 MHz, because
the SDK kept the old ps7_init (problem table, 15 Oct, still open). A speed claim needs the board run.

Files changed: `zed/create_zed_project.tcl` (`FCLK_MHZ` 200), SDK `MAC_attack_V2/src/mac_test.c` (`FCLK_HZ`
200000000; two new tests: every input -128 with K = 64, and A = 127, B = -128 with K = 64, the largest positive and
negative sums possible; they need all 22 accumulator bits). The old 8 tests are unchanged, so the board now runs 10.

Procedure (Vivado and SDK 2019.1):
1. Open `mac_zed.xpr`. Block design > double-click the Zynq block > Clock Configuration: Input Frequency 33.333333,
   PL Fabric Clocks FCLK_CLK0 Actual Frequency **200.000000**.
2. Generate Bitstream (implementation is already done, so only the bitstream step runs).
3. File > Export > Export Hardware, tick **Include bitstream**, location `<Local to Project>`, overwrite.
4. File > Launch SDK (exported location and workspace `<Local to Project>`). When the SDK says the hardware
   specification has changed, answer Yes. If it does not ask: right-click `system_wrapper_hw_platform_0` >
   Change Hardware Platform Specification, and pick the new `.hdf`.
5. Check the clock the board will get: open `system_wrapper_hw_platform_0/ps7_init.html` and find the PL clock 0
   (FCLK_CLK0) entry. It must say 200 MHz. If it still says 50: delete the hardware platform and the BSP projects
   (not `MAC_attack_V2`), make a new hardware platform from the new `.hdf`, make the BSP `MAC_attack_V2_bsp` again,
   then rebuild the app.
6. Build `MAC_attack_V2` in **Release** (right-click > Build Configurations > Set Active > Release) so the ARM
   software time is a fair comparison (section 3 still lists this as not done).
7. Run As > Run Configurations > the app > Target Setup: tick Reset entire system, Program FPGA, Run ps7_init,
   Run ps7_post_config. Run, with the terminal on J14 at 115200 8N1.
8. Pass: `PL clock: FCLK_HZ says 200.00 MHz, measured on the board 200.xx MHz` (no WARNING) and
   `ALL BOARD TESTS PASSED (10/10)`. Save a screenshot of the whole terminal and add the times to section 4.

### Step 9: control-path fixes (written 17 Oct, built with step 10 on 17 Oct)

Files: `zed/mac_axi.v`, `rtl/mm_core.sv`. No change in any result, cycle count or bus timing.

| Path (step 7c) | Change | Cost |
|---|---|---|
| `dim_n` -> `rd_col + 1 == dim_n` -> `rd_col` reset | `dim_n - 1` kept in a register (`dim_n_m1`), and "rd_col is the last column" (`rd_col_last`) registered every cycle. The stepping uses the flag: no adder or compare in front of `rd_row`/`rd_col` | 9 FFs |
| AXI interconnect `rready` -> `rd_col` reset | RESULT_DATA steps to the next C value when the read data is captured (`rd_wait` = 1), not when the ARM accepts it (`rready`). The next read can only start after this one is accepted, so the ARM sees the same values | 0 |
| `ld_row`/`ld_col` bounds compares -> A/B block-RAM write enables | The loader's write port into the core is registered (`core_wr_en/sel/row/col/data`). A byte reaches its buffer one clock later; the next AXI write (e.g. CTRL = start) is accepted at the earliest two clocks after the last byte, and the run reads the buffers later still | 26 FFs, 0 cycles |
| (#2 at 187.5 MHz) `dim_n` -> `nmask_last` (6 CARRY4) at the start of a run | For P and TM powers of two, the start-of-run limits are bit fields of `dim - 1`: `ceil(dim/P) - 1 = (dim-1) >> log2 P`; last-tile lanes `j <= (dim-1) mod P`; `thr = ~(dim-1)[log2 P - 1:0]`. Checked equal to the old formulas for every dim 0..255 and P = 2..32 (6,400 cases, 0 differences) | 0 |

Not changed: the loader's own stepping (`ld_row`/`ld_col` compares -> enables), #1 and #3 at 187.5 MHz but not in
the worst 10 at 200 MHz. It is the first candidate if the step 9 build shows it.

Alternative considered (Alex, 17 Oct): store N - 1 when DIMS is written (`rd_last_col <= wr_data_q[23:16] - 1`) and
compare `rd_col == rd_last_col` at `r_fire`. Correct, and the same idea as `dim_n_m1`, but on its own it leaves
`rready` from the interconnect in front of `rd_col` (path #2, +0.245 ns) and the loader path (#3, +0.245 ns), so
the WNS would only move from +0.209 to about +0.245 ns. Vivado had already folded the `+ 1` into LUTs (3 LUT levels,
74% wire). The version above removes all three paths. [proposed: keep the step 9 version]

How to build step 9 on its own (then step 10 is one parameter):
1. Pull the new files. In the block design, Refresh Changed Modules (yellow banner) so `mac` picks up the new
   parameter `EXACT_ACC`. Double-click `mac` and set **EXACT_ACC = 0** (32-bit accumulators, as before).
2. Keep FCLK_CLK0 at 200 MHz so the WNS can be compared with step 7c directly. Generate Bitstream.
3. Copy the reports to `Alex/` as `_v5`, and in the Tcl Console of the open implemented design also write the worst 100:
   `report_timing -max_paths 100 -nworst 1 -unique_pins -file [get_property DIRECTORY [current_project]]/../../../Alex/timing_paths_v5.rpt`
4. Run `tb_axi` in XSim: `ALL AXI TESTS PASSED (14/14)`.

Simulation (Icarus 12, every testbench on the step 7c RTL and on the new RTL):
- `tb_selfcheck` (P = 4, 8, 16), `tb_compare`, `tb_extras`: logs byte-identical to step 7c.
- `tb_axi` (P = 4, 8, 16) with `EXACT_ACC = 0`: every line of the old 12 tests identical, including every bus
  timing (load, run and read clocks); 14/14 with the two new largest-sum tests.
- `mac.py test`: 60/60 (P = 2, 3, 4, 8, 16) on the old and the new RTL; `mac.py postproc`, `saturate` and
  `uart 16 16 16` identical.
- Extended NumPy suite on `mm_core` (17 cases including 64x64x64 with every input -128, P = 4, 8, 16,
  PIPE/MEM_REG = 0/0, 1/1, 1/2, 0/2): C, passes, cycles and `perf_total` identical to step 7c in 204/204 runs,
  every C exact against NumPy.
- Verilator `--lint-only -Wall` clean: `mac_axi` at P = 4, 8, 16 with `EXACT_ACC` 0 and 1; `mm_core` at
  P = 2, 3, 4, 8, 16; `chip_top`.
- Planted bugs, each caught by `tb_axi`: last-column test against N instead of N - 1 (7 tests fail); loader write
  port with the column off by one (10 fail); last-tile lane mask `<` instead of `<=` (10 fail); `thr` not inverted
  (9 fail).
- Yosys estimate (synth_xilinx, not Vivado): CARRY4 170 -> 123, FF 1,746 -> 1,779, LUT 883 -> 850.

### Step 10: exact accumulator width, 22 bits instead of 32 (written 17 Oct, built with step 9 on 17 Oct)

Files: `zed/mac_axi.v` (parameter `EXACT_ACC`, default 1), `rtl/mm_core.sv` (the proof as a comment, and the
host's read of one C lane rewritten as a P-to-1 mux of whole lanes). `pe.sv`, `systolic_array.sv` unchanged: they
already take ACC as a parameter.

Found while checking: the old host read `cq1[rd_lane * ACC +: ACC]` is a plain 8-to-1 mux only while ACC is a power
of two. At ACC = 22 the synthesis tool builds a general shifter (Yosys: about 430 more LUTs) on the AXI read path.
Written as a mux of whole lanes (`cq1_lane[rd_lane]`) it is the same small mux for any ACC. Same values.

Why it cannot change any result (proof):
- One product: a, w in [-128, 127], so a*w is in [-16,256, 16,384]; 16,384 = 2^14 only for -128 * -128.
- One C value is a sum of K <= MAXD = 64 products, so C is in [-1,040,384, 1,048,576].
- A 22-bit two's-complement number holds [-2,097,152, 2,097,151]: every C fits, and so does every partial sum
  (a sum of fewer products). A 21-bit number holds [-1,048,576, 1,048,575]: 1,048,576 (every input -128, K = 64)
  does not fit, so **22 is the smallest exact width**.
- General rule: ACC >= 2*BITS + ceil(log2 MAXD). If MAXD is raised, ACC follows automatically (MAXD = 255: 24 bits).
- RESULT_DATA is the 22-bit value sign-extended to 32 bits, so `mac_test.c` and `tb_axi` read the same numbers.
  INFO bits [23:16] now say 22.
- A layer with K > 64 has to be split into several runs anyway (MAXD = 64); the ARM adds those partial results in
  32 bits.

What gets smaller, per PE: the 33-bit add becomes 23 bits (9 CARRY4 -> 6) and `psum_out` 32 -> 22 FFs; also the
deskew registers, the C buffer word (8 x 32 = 256 -> 176 bits) and the C read-modify-write adder.
Estimate (Yosys, not Vivado): CARRY4 123 -> 107, FF 1,779 -> 1,591, LUT 850 -> 736,
SRL16E 192 -> 142, block RAM 6 RAMB36 -> 2 RAMB36 + 5 RAMB18. [claim] Yosys puts the PE add inside the DSPs (it
ignores `use_dsp`), so Vivado should save more than this: the 64 PE adders (33 -> 23 bits) and their `psum_out`
registers (64 x 10 = 640 FFs) are not in these numbers.

Simulation: 
- `tb_axi` (P = 4, 8, 16) with `EXACT_ACC = 1`: 14/14. INFO says 22-bit sums; every other line identical to
  `EXACT_ACC = 0`, bus timings included.
- Extended suite at ACC = 22: 204/204 runs exact against NumPy and identical (C, passes, cycles, `perf_total`) to
  ACC = 32, including every input -128 with K = 64 (C = 1,048,576) and A = 127, B = -128 with K = 64
  (C = -1,040,384).
- Planted bugs: ACC = 21 (one bit short) fails only the new "every input -128, K = 64" test (13/14). **The 12 old
  tests all still pass with 21 bits**, so the new tests are needed, and 22 is the minimum. Sign extension removed
  (zeros instead of the sign bit): 7 tests fail.

Build: set `EXACT_ACC` back to 1 on the `mac` block, 200 MHz, Generate Bitstream, reports as `_v6`.

### Steps 9 + 10 built together (17 Oct)

- Built with `EXACT_ACC` at its default (1), so steps 9 and 10 are in one build; their separate effects are not
  known. FCLK_CLK0 still asked for 190 MHz; actual 200.000 MHz (5.000 ns), the same constraint as step 7c.
- Result: **met**, WNS +0.529 ns (was +0.209), WHS +0.014 ns, TNS 0, 0 of 9,155 endpoints failing. Worst path at most
  4.47 ns, floor about 224 MHz.
- Size: LUT 2,779 -> 2,192 (-21%), FF 4,532 -> 3,847 (-15%), CARRY4 540 -> 398, block RAM 6 -> 4.5 tiles
  (4 RAMB36 + 1 RAMB18), SRL16E 27, DSP 64. Total on-chip power 2.012 -> 1.935 W.
- `tb_axi` (XSim): ALL AXI TESTS PASSED (14/14).
- Every path that limited step 7c (RESULT_DATA stepping, loader -> block-RAM write enable) is gone from the worst 10.
  What limits it now (all inside the array):

  | Path | Slack | Needs | Notes |
  |---|---|---|---|
  | PE (5,0): product register (in the DSP) -> 22-bit add (6 CARRY4 + 1 LUT) -> `psum_out` | +0.529 | 4.47 ns | 1.90 ns logic, 2.03 ns wire. Same path in PEs (4,0), (4,3), (4,2), (1,0) |
  | FSM `state` -> `w_load` (1 LUT) -> weight-register clock enables (CEB1/CEB2) of the DSPs in PEs (4,2), (5,3) | +0.544 | 4.46 ns | 84% wire: `w_load = (state == S_RUN) && w_phase` drives the weight registers of all 64 PEs |

- Next options (not agreed yet):
  - The PE add is the array itself: step 11 (add inside the DSP, partial sums on the cascade).
  - `w_load` from a flip-flop (small, 0 cycles) [proposed]: gate the weight-load flag with `r_active` on the read side,
    where it is made, so after the flag delay line `w_load` comes straight from a register that Vivado can copy
    (`max_fanout`), with no LUT and no FSM state in the path. Needs a simulation check that it is high in exactly the
    same cycles as `(state == S_RUN) && w_phase`.
  - Clock only: ask for 222 MHz (see "Zynq FCLK options" in section 7). The floor estimate (224 MHz) is just above it.

### Step 10b: `w_load` from a flip-flop (agreed and written 17 Oct, not built)

File: `rtl/mm_core.sv`. No change in any cycle or result.

- Before: `w_load = (state == S_RUN) && w_phase`, one LUT after the FSM state register, driving the weight registers
  (DSP B-register clock enables) of all 64 PEs: 84% of the 4.46 ns path at 200 MHz was wire.
- Now: the weight-load flag is gated where it is made, on the read side: `rw && r_active`. It then goes through its
  own chain of 1 + MEM_REG flip-flops (the same delay as the other flags), and the last one drives the PEs directly.
  It has `max_fanout = 16`, so Vivado may copy it and place each copy near 8 PEs.
- Why it is the same signal: the read side starts a run (`r_active` set by `start`) in the same cycle the FSM enters
  S_PRIME, and S_PRIME lasts 1 + MEM_REG cycles, exactly the flag delay. So the flags of the read side's first active
  cycle reach the array in the first S_RUN cycle, and those of its last active cycle (`r_final`) in the last S_RUN
  cycle. Outside a run, `r_active` is 0, so the gated flag is 0 exactly when the state is not S_RUN.
- Checked cycle by cycle (lockstep below): the old and the new core side by side, with the same random loads, runs and
  reads, comparing `w_load`, busy, done, the counters and every C value read, every cycle.

Simulation (Icarus 12):
- Lockstep, old core (steps 9 + 10) against the new one, 30 random runs each (loads, runs up to 64x64x64, every C
  read back) for P = 2, 3, 4, 8, PIPE = 0, 1 and MEM_REG = 0, 1, 2 (24 settings): **0 differences** in `w_load`,
  busy, done, the counters or any C value, in any cycle.
- `tb_selfcheck` (P = 4, 8, 16), `tb_compare`, `tb_extras`: byte-identical to steps 9 + 10. `tb_axi` (P = 4, 8, 16)
  with PIPE = 1: byte-identical. `mac.py test` 60/60, `postproc`, `saturate`, `uart` pass.
- Planted bugs: the delay chain one flip-flop short makes `tb_axi` fail (4/14 pass). Without the `r_active` gate,
  `tb_axi` still passes (14/14: extra weight shifts while idle are overwritten by the next load), but the lockstep
  check sees 37,693 cycles where `w_load` differs, so it would no longer be the same circuit. The gate stays.

### Step 11: PE add inside the DSP, `PIPE = 2` (agreed and written 17 Oct, not built)

Files: `rtl/pe.sv` (new `PIPE = 2` branch), `rtl/systolic_array.sv` (comments), `zed/mac_axi.v` (default `PIPE = 2`).

- Before (`PIPE = 1`): the multiply is in the DSP (input registers AREG = 2, BREG = 2, product in PREG, no multiplier
  register), and the 22-bit add is in LUT carry chains next to it (step 7). At 200 MHz that add was the worst path
  (4.47 ns: 1.90 ns of carry chain, 2.03 ns of wire from the DSP output to the slices).
- Now (`PIPE = 2`):

  ```
  a_q      <= a_in;               // DSP input register   (AREG)
  m_q      <= a_q * w;            // multiplier register  (MREG); w is the weight register (BREG)
  psum_out <= psum_in + m_q;      // output register      (PREG); psum_in = PREG of the PE above
  ```

  This is the multiply-accumulate pattern of one DSP48E1 with all three of its pipeline registers, and the add uses
  the DSP's own 48-bit adder. Because `psum_in` is the output register of the PE above, the partial sum can travel
  down the column on the DSP cascade (PCOUT -> PCIN, dedicated wires between DSPs stacked in one column) instead of the
  general routing. Only the activation (to the right) and the bottom row's output use fabric.
- Why the results do not change: every PE gets the same extra stage, so the partial sum from above still meets the
  matching product one cycle later in every PE (the same argument as for PIPE = 1). Results leave the array one cycle
  later (latency 2P - 1 + PIPE). The weight is now used one cycle later: the last use (bottom-right PE, last row of A)
  falls in the first weight-load cycle of the next pass, and the weight register only changes at the end of that
  cycle, so the old weight is still there (0 cycles of margin; any error would corrupt results, and none was seen).
- The C accumulator's block bookkeeping (`cap_nb`, `cap_first`) changes P cycles after the last row of a pass leaves
  the array, so it needs PIPE <= P; true for every P >= 2 (P = 2, PIPE = 2 passes the suite below).
- Cycles: M + 3P - 2 per pass, unchanged; `perf_total = perf_cycles + 3 + PIPE + MEM_REG` (+1 per run).
- `pe.sv` stays behavioral (the same file for simulation and OpenLane); the DSP mapping is Vivado's choice. If Vivado
  does not build the cascade, the fallback is an FPGA-only PE that instantiates the DSP48E1 directly.
- What to check in the build (Tcl console, implemented design open):

  ```
  set dsps [get_cells -hier -filter {REF_NAME == DSP48E1 && NAME =~ *u_array*}]
  puts "DSPs in the array: [llength $dsps]"
  set c [lindex $dsps 20]
  puts "$c AREG=[get_property AREG $c] BREG=[get_property BREG $c] MREG=[get_property MREG $c] PREG=[get_property PREG $c]"
  puts "nets on PCIN pins: [llength [get_nets -quiet -of_objects [get_pins -quiet -of_objects $dsps -filter {REF_PIN_NAME =~ PCIN*}]]]"
  ```

  Expected: 64 DSPs; MREG = 1 and PREG = 1 (AREG/BREG 1 or 2); hundreds of PCIN nets if the cascade is used (only 1 or
  2, the constant nets, if it is not). And no PE add paths among the worst paths.

Simulation (Icarus 12):
- Extended NumPy suite on `mm_core`: 14 cases (including 64x64x64 with every input -128, and A = 127, B = -128) for
  P = 2, 3, 4, 8, 16 with PIPE/MEM_REG = 0/0, 1/1, 1/2, 2/0, 2/1, 2/2 (and HCLK_SEP = 1 for 2/2 and 1/2):
  **560/560 exact** against NumPy, every pass count and cycle count equal to the equation, and
  `perf_total = perf_cycles + 3 + PIPE + MEM_REG` in every run.
- `tb_axi` with the new default PIPE = 2 (P = 4, 8, 16): 14/14.
- Planted bug: the multiplier taking `a_in` instead of `a_q` (activations one cycle out of step) fails `tb_axi` (8/14).

### Step 12: the core on its own clock (agreed and written 17 Oct, not built)

The professor suggested a new clock; NVIDIA Simba runs each block on its own clock (GALS). Above 250 MHz the AXI port
to the ARM is the limit (DS187 Table 19), so the core has to leave the AXI clock to go faster.

Files: `zed/mac_axi.v` (parameter `CORE_CLK`, ports `core_clk`, `core_locked`), `rtl/mm_core.sv` (port `hclk`,
parameter `HCLK_SEP`), `zed/mac_zed_cdc.xdc` (new), `zed/create_zed_project.tcl` (`CORE_MHZ`), `zed/tb_axi.sv`
(optional second clock), SDK `mac_test.c` (`CORE_HZ`, CONFIG register, waits for the core clock). The other
`mm_core` users (`chip_top.sv`, the testbenches) connect `hclk` to their one clock: same design as before.

```
                 s_axi_aclk (FCLK_CLK0, 200 MHz)        |   core_clk (Clocking Wizard, e.g. 250 MHz +)
  ARM --AXI--> registers, loader --- write ---> [A, B block RAMs] --- read ---> array, controller
               STATUS, RESULT_DATA <-- read --- [C copy]  <------------ write --- accumulators (+ C working copy)
               CTRL start ---- toggle --> 2 FFs --> edge --> start
               done_flag  <--- edge <-- 2 FFs <---- toggle --- done
               rst ------------------------------> 2 FFs (with "locked") --> core reset
               STATUS bit 3 <--- 2 FFs <-------------------- core ready
               DIMS, perf counters: quasi-static (do not change while the other side reads them)
```

- Data crosses only through block RAMs with one port on each clock (A, B: written on the AXI clock, read on the core
  clock; C: the core keeps its working copy, which needs both ports on the core clock, and also writes a second copy
  that the AXI side reads). No FIFOs.
- Control crosses through toggles and two-flip-flop synchronizers (`ASYNC_REG`). CTRL start is accepted only while
  the core is idle and out of reset (STATUS bit 3 = 0); DIMS is written only while idle. The core samples DIMS at
  start, at least two core cycles after the start toggle, so DIMS has been stable for a long time.
- Reset: the AXI reset or "wizard not locked" goes through two flip-flops into the core clock.
- New register 0x30 CONFIG: [7:0] PIPE, [15:8] MEM_REG, [16] CORE_CLK. STATUS bit 3: waiting for the core clock.
- Constraints: `zed/mac_zed_cdc.xdc` sets the two clocks as asynchronous groups. After implementation:
  `report_clock_interaction` and `report_cdc -details`.
- Clocking Wizard: input FCLK_CLK0 (no input buffer, since FCLK already has a global buffer), output = the core clock,
  active-low reset from FCLK_RESET0_N (ps7_init can change FCLK after the bitstream is loaded, so the MMCM must be able
  to lock again), `locked` -> `core_locked`.
- `CORE_CLK = 0` (default): one clock, the same design as steps 10b and 11.

Found while checking: the C copy was first read at `cres[AW'(host_raddr)]`. A size cast keeps the sign of the `int`,
so for addresses 256 to 511 the 9-bit index was negative (out of range) and rows 32 to 63 of C read as unknown.
The single-clock code was safe because it assigns into an unsigned `c_raddr` first. Fixed with an unsigned
`h_raddr`. Vivado's simulator would have shown the same failure.

Simulation (Icarus 12; bus clock 50 MHz in `tb_axi`, the core clock unrelated to it):
- `tb_axi` with `CORE_CLK = 1` (P = 8, PIPE = 2), core clock 250, 294, 400, 68.5, 50.0 (same as the bus),
  50.1 (almost the same) and 38.5 MHz (slower than the bus): **15/15 every time**. Also PIPE = 1 at 250 MHz, P = 4 at
  250 MHz and P = 16 at 161 MHz: 15/15.
- `mm_core` with `HCLK_SEP = 1` in the NumPy suite above (P = 2 to 16): exact.
- Planted bugs, each caught by `tb_axi` in two-clock mode: start as a level instead of an edge (9/15 pass); done as a
  level (13/15); the C copy written one word off (9/15); the host's lane select off by one (9/15).
- Not checked by simulation: metastability itself (simulators do not model it). That is what the two-flip-flop
  synchronizers, `ASYNC_REG` and `report_cdc` are for.

### Step 11 synthesized (17 Oct): Vivado made two DSPs per PE

- Settings as intended (from the mac synthesis log): PIPE = 2, MEM_REG = 2, EXACT_ACC = 1 (ACC = 22), CORE_CLK = 0,
  FCLK 250.000 MHz. The critical warning on refresh ([Coretcl 2-1280], "the upgrade of system_mac_0 ... may require
  user intervention") only means the block's ports and parameters changed (new `core_clk`, `core_locked`, `PIPE`,
  `EXACT_ACC`, `CORE_CLK`); `core_clk` was connected to FCLK_CLK0, `core_locked` can stay unconnected in one-clock mode.
- DSP Final Report: 128 DSPs. Per PE, DSP 1 = the multiply, `(A''*B'')'` or `(A''*BCIN2)'` (AREG = 2, BREG = 1 or 2,
  MREG = 1, PREG = 0; the weights already use the B cascade), and DSP 2 = the add, `(PCIN+A:B)'` (PREG = 1; the partial
  sums use the P cascade). The product leaves DSP 1 through its ALU with no output register and crosses the general
  routing into DSP 2's A:B inputs: the same kind of path that failed at 200 MHz in step 6.
- Synthesis estimate for the mac block alone: LUT 704, FF 2,377, block RAM 4.5, DSP 128.
- So inference did not give one DSP per PE, which is what the agreed fallback is for: step 11b.

### Step 11b: each PE as one DSP48E1, placed directly (written 17 Oct, not built)

Files: `zed/pe_dsp48.sv` (new, FPGA only), `rtl/systolic_array.sv` and `rtl/mm_core.sv` (parameter `PE_PRIM`, default
0), `zed/mac_axi.v` (parameter `PE_PRIM`, default 1; CONFIG bit 17), `zed/create_zed_project.tcl` (adds the new file).

- `pe_dsp48.sv` is the circuit of `pe.sv` with PIPE = 2, written as one DSP48E1: A2 register = `a_q` (AREG = 1),
  B2 register = the weight (BREG = 1, clock enable `w_load`), M register = the product (MREG = 1), P register =
  `psum_in + product` (PREG = 1, OPMODE Z = PCIN; the top row adds 0). Weights shift down each column on the B cascade
  (BCOUT -> BCIN) and partial sums on the P cascade (PCOUT -> PCIN), so only the activations (to the right) and the
  bottom row's results use the general routing.
- The DSP48E1 module is referenced only when `PE_PRIM = 1`, so Icarus, Verilator, Yosys and OpenLane (which never set
  it) do not need it; checked with all three.
- Checked against Xilinx's own DSP48E1 simulation model (XilinxUnisimLibrary, the same model Vivado's simulator uses):

  - Lockstep, `pe.sv` with PIPE = 2 against the DSP48E1 PEs, side by side with the same random loads, runs and reads
    (20 runs each, P = 2, 3, 4, 8, 16, MEM_REG = 0, 1, 2): **0 differences** in the array's output rows, `w_load`,
    busy, done, the counters or any C value, in any cycle.
  - Extended NumPy suite with DSP48E1 PEs (P = 2 to 16, MEM_REG = 0, 1, 2, and HCLK_SEP = 1): **280/280 exact**, every
    pass and cycle count equal to the equation, `perf_total = perf_cycles + 5 + MEM_REG`.
  - `tb_axi` (P = 4, 8, 16) with `PE_PRIM = 1`: 14/14, and the log is byte-identical to `pe.sv` with PIPE = 2.
    With `PE_PRIM = 0` the log is byte-identical to the previous RTL.
  - Two clocks with DSP48E1 PEs: core at 250, 400, 68.5, 50.0 and 38.5 MHz (P = 8), 294 MHz (P = 4), 161 MHz
    (P = 16): 15/15 each.
  - Team testbenches (`tb_selfcheck` P = 4, 8, 16, `tb_compare`, `tb_extras`): byte-identical.
  - Planted bugs in `pe_dsp48.sv`, each caught by `tb_axi`: no partial sum from above (OPMODE Z = 0 in every row,
    4/14 pass); weight register always enabled (4/14); no A register (activations one cycle early, 8/14); no M register
    (8/14).
  - In simulation the DSP model holds its registers in reset for the first 100 ns (the global set/reset). `tb_axi`
    starts its first run long after that; on the board the global reset ends when the FPGA is configured.

What to check in the build: the mac synthesis utilization (`system_mac_0_synth_1/system_mac_0_utilization_synth.rpt`,
or the DSP column in Design Runs) must show **64 DSPs**. Then the DSP checks from step 11 (MREG = 1, PREG = 1,
hundreds of PCIN nets).

### Step 11b built at 250 MHz (17 Oct): one DSP per PE, the array is no longer the limit

- Build: one clock (`CORE_CLK = 0`), FCLK_CLK0 250.000 MHz, `PE_PRIM = 1`, PIPE = 2, MEM_REG = 2, ACC = 22. The first
  run stopped in synthesis because `zed/pe_dsp48.sv` was not in the project (section 6); after adding it, synthesis and
  implementation completed.
- Result: **64 DSPs**. WNS -0.263 ns, TNS -3.113 ns, 45 of 10,707 endpoints fail, WHS +0.037 ns. Worst path 4.263 ns,
  floor about 235 MHz. LUT 1,119 (was 2,192 in 9 + 10), FF 2,895 (was 3,847), BRAM 4.5, CARRY4 86 (was 398: the 64 PE
  adds moved from LUT carry chains into the DSPs), SRL16E 19, power 1.940 W (1.792 W dynamic).
- The 10 worst paths (the summary report lists only 10 of the 45):

| Slack (ns) | From -> to | Logic levels | Clock-to-out / wire / logic (ns) | What it is |
|---|---|---|---|---|
| -0.263, -0.182, -0.158, -0.114, -0.105, -0.095, -0.091 | C buffer `cmem_reg_*` (block RAM) -> `core_rd_q[*]` | LUT6 + MUXF7 | 2.454 / 1.341 / 0.369 = 4.164 (worst) | Host read of C: block RAM without an output register, then the lane select `hq1_lane[rd_lane]` in the same cycle (`mm_core.sv` -> `mac_axi.v`) |
| -0.225 | `auto_pc/.../ar_pipe/m_payload_i_reg[3]` -> `wrap_cnt_r_reg[3]` | 4 LUTs | 0.456 / 3.144 / 0.524 = 4.124 | Xilinx AXI interconnect, protocol converter (AXI3 from the ARM to our AXI4-Lite). Xilinx IP, not our RTL |
| -0.148 | `out_row_reg[5]` -> `FSM_sequential_state_reg[1]` | LUT6, LUT3, LUT5 | 0.419 / 2.731 / 0.538 = 3.688 | `S_LAST: if (out_valid && out_row == m_m1)` |
| -0.083 | `out_row_reg[5]` -> `out_row_reg[0]/R` | LUT6, LUT3, LUT2 | 0.419 / 2.621 / 0.544 = 3.584 | The wrap `out_row <= (out_row == m_m1) ? 0 : out_row + 1` |

- What it means: no PE, weight-load or partial-sum path is in the list, so step 11b did what it was for. Two of the
  three kinds are on the bus side and fail only because the bus and the core share one 250 MHz clock; the third is one
  compare in the core's controller (a 6-bit compare, then the `out_valid` gate, then the state or reset logic).
- All 45 failing endpoints, from the worst 100 paths (`Alex/timing_paths_v6.rpt`, `report_timing -max_paths 100
  -nworst 1 -unique_pins`), grouped by which clock each would be on in step 12 (bus 200 MHz, core 250 MHz):

| Group | Endpoints | Worst slack (ns) | Clock in step 12 |
|---|---|---|---|
| Host read of C: `cmem` block RAM -> lane select -> `core_rd_q` | 15 | -0.263 | bus |
| Xilinx AXI interconnect (`auto_pc`) | 4 | -0.225 | bus |
| Loader: `wr_addr_q` -> `ld_word`, `ld_rows` -> `ld_row` enable | 6 | -0.038 | bus |
| Last-row compare: `out_row` -> state register, `out_row` reset | 7 | -0.148 | core |
| State -> reset of the read-side counters (`state_reg[2]` -> `ro`/R; fanout 51, LUT4 + LUT5, R-pin setup 0.43 ns) | 7 | -0.074 | core |
| A buffer: `amem` block RAM -> `aq` (no logic; block RAM clock-to-out 2.454 ns, the per-lane mask keeps the output register out of the block RAM) | 4 | -0.053 | core |
| Top-row weight: `bq2` -> DSP B input (no logic, 2.93 ns of wire, fanout 11 for the sign bit) | 2 | -0.040 | core |

- So in step 12 the 25 bus endpoints run at 200 MHz (all met at 200 MHz in 9 + 10), and the 20 core endpoints stay
  at 250 MHz. The last-row flags (step 13 below) cover only 7 of the 20.
- Near misses on the core side (met by less than 0.05 ns): more `amem` -> `aq` bits, `perf_total` (32-bit carry chain,
  +0.008), `cmem` -> `cq2` (+0.016), `bq2` -> DSP B (+0.019), activation from one PE to the next DSP's A input (+0.033).
  250 MHz on the core is at the edge; with the Clocking Wizard any frequency can be asked for (for example 240 MHz).
- Still to do: the DSP checks.

### Step 13: three shorter core paths (agreed 17 Oct, written 18 Oct, not built)

Why: the worst 100 paths at 250 MHz (above) have 20 failing endpoints in the core, which stays at 250 MHz in step 12.
File: `rtl/mm_core.sv` only. Every cycle and every result is the same as before.

| Fix | Failing path it shortens | Change | Cost |
|---|---|---|---|
| (a) Last-row flags | `out_row` == M - 1 -> state register and `out_row` reset (7 endpoints, -0.148 ns) | `out_last` = (`out_row` == M - 1) and `pre_last` = (`pre_row` == M - 1) kept in flip-flops, worked out one step ahead: when a row counter steps, the new flag is (row == M - 2); M - 2 and "M = 1" are stored at start | about 10 FFs |
| (b) `idle_q` | `state` -> reset of the read-side counters (7 endpoints, -0.074 ns; the state register drives 51 loads) | `idle_q` = (state == S_IDLE) as its own flip-flop, set by the same next-state rules as the state machine; the read-side counters are cleared by `idle_q` | 1 FF |
| (c) A/B feed registers swapped (MEM_REG = 2) | `amem` block RAM -> `aq` (4 endpoints, -0.053 ns: block RAM clock-to-out 2.454 ns); likely also the top-row weight wire (2 endpoints, -0.040 ns) | Was: block RAM -> masked register -> plain register -> array. Now: block RAM -> plain register (Vivado can put it inside the block RAM: clock-to-out about 0.9 ns) -> masked register -> array. The lane masks get one more register so they still line up | 16 FFs for the masks; 128 FFs should move into the block RAMs |

Why each is exact:
- (a) The flag equals the compare in every cycle: true after reset and at start, and each step keeps it true (6-bit
  arithmetic, any M).
- (b) `idle_q` equals (state == S_IDLE) in every cycle: reset sets both; S_IDLE stays unless start, S_PRIME, S_RUN and
  S_LAST never go to S_IDLE, S_DONE (and any other code) always does.
- (c) Both versions give the array mask(block RAM word, lane mask) from two cycles earlier; only the order of the two
  registers changed.

Checked (Icarus Verilog 12, Verilator 5.020, Xilinx's DSP48E1 model):
- Lockstep against the step 11b core, P = 2, 3, 4, 8, 16 x PIPE = 0, 1, 2 x MEM_REG = 0, 1, 2 (45 settings, 12 runs
  each including M = 1, 2, 3, 63, 64): **0 differences** in the array's inputs and outputs, state, row counters,
  C addresses and writes, `w_load`, busy, done, counters and C reads; the three flags equal what they replace in every
  cycle (4,258,647 cycles). Fix (a) alone was also run with 24 runs per setting (10,235,457 cycles), 0 differences.
- Extended NumPy suite (P = 2 to 16; `pe.sv` with PIPE/MEM_REG 0/0, 1/1, 1/2, 2/2 and 2/2 with HCLK_SEP = 1;
  DSP48E1 PEs with MEM_REG 1, 2 and 2 with HCLK_SEP = 1): **560/560 exact**, every pass and cycle count equal to the
  equation, `perf_total = perf_cycles + 3 + PIPE + MEM_REG`.
- `tb_axi`, one clock, P = 4, 8, 16, with DSP48E1 PEs (the board setting), `pe.sv` PIPE = 2 and PIPE = 1: 14/14 each,
  **byte-identical** to the step 11b logs.
- `tb_axi`, two clocks, DSP48E1 PEs: core at 250, 240, 400, 68.5, 50.0, 38.5 MHz (P = 8), 294 MHz (P = 4), 161 MHz
  (P = 16), bus at 50 MHz: 15/15 each.
- Team testbenches (`tb_selfcheck` P = 4, 8, 16, `tb_compare`, `tb_extras`): byte-identical. `mac.py test`: 60/60.
- Verilator lint: clean in every setting.
- Planted bugs:

| Planted bug | Caught by |
|---|---|
| (a) new `out_last` compared with M - 1 instead of M - 2 | lockstep, at once |
| (a) new `pre_last` compared with M - 1 instead of M - 2 | `tb_axi` (6/14 pass) |
| (b) `idle_q` stays 1 when a run starts | `tb_axi` (the run never finishes) |
| (b) `idle_q` not set after S_DONE | lockstep (`idle_q` differs from the state for one cycle per run). `tb_axi` passes: in that cycle the read-side counters are already cleared and `start` cannot arrive |
| (c) B lane mask one cycle early | `tb_axi` (4/14 pass) |
| (c) A lane mask one cycle early | lockstep (the array's A input differs). `tb_axi` passes: the A mask only changes between passes, in cycles where no A row is valid |

- Yosys 0.33 does not put output registers into Xilinx block RAMs, so it cannot show (c); the Vivado build must (see
  the check in the build plan).

The bus-side paths (not changed; options for later):
- Xilinx interconnect: cannot be changed in our RTL. Keeping the bus at 200 MHz (met with +0.529 ns in 9 + 10)
  avoids it: that is step 12.
- Host read of C: only matters if the bus itself runs at 250 MHz. Fix then: read C through the block RAM's output
  register (clock-to-out about 0.9 ns instead of 2.45 ns) and select the lane in the next cycle; `mac_axi.v` waits
  4 clocks per register read instead of 3. In one-clock mode this needs the separate C copy for the host (as in
  step 12, about 2.5 more BRAM tiles), because the working copy's read port also feeds the accumulator. In step 12
  this path runs on the 200 MHz bus clock with about 0.7 ns to spare.
- Suggested order: step 13, then step 12 (bus 200 MHz, core 250 MHz; build plan item 3 below).

### Planted bugs for steps 10b, 11 and 12

All in the step 10b, 11 and 12 sections above: 8 planted bugs, 7 make `tb_axi` fail, and the one that does not
(`w_load` without its gate) is caught by the lockstep check.

### Build plan for steps 10b, 11 and 12

1. One clock, 250 MHz (the AXI maximum): pull the files. In the existing project, Add Sources >
   `zed/pe_dsp48.sv` (the script adds it for a new project). Refresh Changed Modules (the critical warning
   [Coretcl 2-1280] is expected), check the `mac` block has `PE_PRIM = 1` and `CORE_CLK = 0`. Run synthesis first
   and check 64 DSPs before implementing. Zynq FCLK_CLK0: ask for 250 (IO PLL / 4), check Actual Frequency 250.000000.
   Generate Bitstream. Copy the reports to `Alex/` as `_v6`, plus the worst 100 paths
   (`report_timing -max_paths 100 -nworst 1 -unique_pins -file [get_property DIRECTORY [current_project]]/../../../Alex/timing_paths_v6.rpt`),
   and run the DSP checks from step 11. `tb_axi` in XSim: 14/14.
2. If 1 fails only on PE paths: send the worst paths and the DSP check output; the fallback is the direct DSP48E1 PE.
3. Two clocks: set `FCLK_MHZ 200` and `CORE_MHZ 250` at the top of `create_zed_project.tcl` and run it (a new
   project; the GUI steps are below if the block design step stops). Same core speed as build 1, so only the clock
   structure changes. Then raise `CORE_MHZ` one step per build (275, 300, 333, ...), keeping each `_vN` report.
   `tb_axi` in XSim with `-generic_top "CORE_CLK=1"`: 15/15.
   GUI instead of the script: add IP > Clocking Wizard (name `clk_core`): Clocking Options > Input Clock Source
   "No buffer", input 200 MHz; Output Clocks > clk_out1 = the core clock; Reset Type Active Low; Locked on. Connect
   FCLK_CLK0 -> clk_in1, FCLK_RESET0_N -> resetn, clk_out1 -> mac/core_clk, locked -> mac/core_locked, set
   `CORE_CLK = 1` on `mac`, and add `zed/mac_zed_cdc.xdc` to the constraints.
   After step 13, also check that A and B use the block RAM's output register (implemented design open, Tcl console):
   `foreach c [get_cells -hier -filter {REF_NAME =~ RAMB*}] {puts "$c DOA_REG=[get_property DOA_REG $c] DOB_REG=[get_property DOB_REG $c]"}`
   The `amem` and `bmem` block RAMs should show 1 on their read side.
4. Board run for each speed (step 8 procedure): `FCLK_HZ` = the AXI clock, `CORE_HZ` = the core clock (two-clock
   mode), Release build. Pass: the measured core clock matches CORE_HZ and ALL BOARD TESTS PASSED (10/10).

## 6. Problems and fixes

| Date | Problem | Fix |
|---|---|---|
| 13 Oct | Vivado 2019.1: "Please use ASCII characters for file name or path". | Move the project to a plain ASCII path. |
| 13 Oct | Re-running the Tcl script: "Project mac_zed is currently open". | Open the existing `mac_zed.xpr` instead (File > Open Project); one project per Vivado window. |
| 15 Oct | SDK "Program FPGA failed: Could not find FPGA device" (Windows in a Parallels VM). Hardware Manager showed `localhost (0)`. | Pass the Digilent and Cypress USB devices to Windows; install the Digilent cable driver from `C:\Xilinx\Vivado\2019.1\data\xicom\cable_drivers\nt64`. |
| 15 Oct | Asking FCLK for 80 MHz gave 76.929 MHz. | The Zynq PLL only makes certain frequencies; use the Actual Frequency (or the Clocking Wizard for exact values). Set `FCLK_HZ` in `mac_test.c` to the actual value. |
| 15 Oct | Board still ran at 50 MHz after the 76.9 MHz bitstream. | The PL clock is set by ps7_init from the SDK hardware platform. Re-export hardware (with bitstream), update/recreate the hardware platform, check `ps7_init.html`, check Run Configuration > Target Setup. **Open.** Step-by-step procedure written in section 5, step 8 (17 Oct). |
| 16 Oct | Tcl report files would not write ("Directory ... does not exist"): space in "MAC Attack", and Vivado was on another machine. | Repo folder renamed to `MAC_Attack`; write reports with a path relative to the project. |
| 16 Oct | Zynq Clock Configuration "Input Frequency" was set to 100 by mistake. | Must stay 33.333333 MHz (the ZedBoard crystal). The PL clock is set under PL Fabric Clocks > FCLK_CLK0. |
| 16 Oct | `report_design_analysis -timing` failed. | Run implementation and open the implemented design first. |
| 17 Oct | `docs/log.md` on Alex's computer went back to an earlier version at 17:59 (the steps 9 + 10 entries were missing). | Restored with the next update. Reload the log in any open editor before saving it. |
| 17 Oct | Critical warning [Coretcl 2-1280] when refreshing the `mac` block. | Expected after `mac_axi.v` gains ports or parameters; check the block's parameters and connections, then continue. |
| 17 Oct | Vivado built 2 DSPs per PE from `pe.sv` with PIPE = 2 (step 11). | Step 11b: the PE written as one DSP48E1 (`zed/pe_dsp48.sv`). |
| 17 Oct | Critical warning [BD 41-759]: `/mac/core_locked` not connected, tied to 0. | Harmless with `CORE_CLK = 0` (the pin is not used). To silence it: add a Constant IP (value 1) and connect it to `core_locked`. |
| 17 Oct | Step 11b at 250 MHz: mac synthesis stopped, [Synth 8-439] module 'pe_dsp48' not found (then [Synth 8-196] and [Synth 8-6156] on `systolic_array.sv`). No implementation ran. | `zed/pe_dsp48.sv` was not in the project (`mac_zed.xpr` lists only the older files). Add it: Add Sources > design sources > `zed/pe_dsp48.sv` (do not copy into the project), or in the Tcl console `add_files -norecurse <repo>/mac_attack_accel/zed/pe_dsp48.sv` and `update_compile_order -fileset sources_1`; then Refresh Changed Modules and run synthesis again. |

## 7. Numbers to remember

| Quantity | Value | Source |
|---|---|---|
| Cycles per pass | M + 3P - 2 | Simulation and board (8/8) |
| Passes | ceil(K/P) * ceil(N/P) | Same |
| XC7Z020 resources | 220 DSPs, 140 BRAM36, 0 high-speed transceivers | Xilinx cost-optimized selection guide [done] |
| Utilization, P = 8 | LUT 7,577 (14%), FF 3,573 (3%), BRAM 68 of 140 (4 RAMB36 + 128 RAMB18), DSP 0 | Vivado, 76.9 MHz build |
| Timing, 50 MHz | WNS +4.664 ns, WHS +0.030 ns | Vivado |
| Timing, 76.929 MHz | WNS +0.135 ns, WHS +0.022 ns, total on-chip power 1.811 W (mostly the ARM side) | Vivado |
| Timing, 100 MHz (exploration) | WNS -2.263 ns, TNS -1,240 ns, 1,060 failing endpoints | Vivado |
| Timing, 100 MHz after fixes 1-3 | WNS +1.095 ns; BRAM 6, LUT 7,073, FF 3,488 | Vivado |
| Array latency, a_row to c_row | 2P - 1 + PIPE cycles | RTL; Icarus |
| Run overhead | perf_total = perf_cycles + 3 + PIPE + MEM_REG (ZedBoard from step 6: + 6) | Icarus (tb_mm 53 -> 55 -> 56) |
| Timing, 142.857 MHz, 2-stage PE | WNS +0.456 ns, WHS +0.046 ns; LUT 2,062, FF 2,252, BRAM 6, DSP 128 | Vivado |
| Timing, 166.667 MHz, path fixes | WNS +0.176 ns, WHS +0.028 ns; LUT 1,755, FF 2,536, SRL 304, BRAM 6, DSP 128 | Vivado |
| Timing, 200 MHz, step 6 | WNS -0.385 ns (fails), TNS -44.427 ns, WHS +0.015 ns; LUT 1,663, FF 3,188, BRAM 6, DSP 128 | Vivado |
| Timing, 187.512 MHz, step 7 | WNS +0.416 ns, WHS +0.036 ns; LUT 2,768, FF 4,532, CARRY4 540, BRAM 6, DSP 64 | Vivado |
| Timing, 200.000 MHz, step 7c | WNS +0.209 ns, WHS +0.015 ns; LUT 2,779, FF 4,532, BRAM 6, DSP 64; power 2.012 W | Vivado |
| Timing, 200.000 MHz, steps 9 + 10 (best so far) | WNS +0.529 ns, WHS +0.014 ns; LUT 2,192, FF 3,847, BRAM 4.5, DSP 64, CARRY4 398; power 1.935 W | Vivado |
| Timing, 250.000 MHz, step 11b (one clock) | WNS -0.263 ns (fails), TNS -3.113 ns, 45 of 10,707 endpoints, WHS +0.037 ns; LUT 1,119, FF 2,895, BRAM 4.5, DSP 64, CARRY4 86; power 1.940 W | Vivado |
| Zynq FCLK options on this board | [claim] FCLK = one PS PLL / two whole-number dividers. PLLs here: IO 1000 MHz, ARM 1333.3 MHz (CPU 666.7), DDR 1066.7 MHz (DDR 533.3). Near our range: 200 (IO/5), 213.3 (DDR/5), 222.2 (ARM/6), 250 (IO/4). The Actual Frequency in the Zynq dialog is what counts (asking 180 once gave 187.512, which this rule does not explain) | Zynq block design settings |
| Exact accumulator width | ACC >= 2*BITS + ceil(log2 MAXD): 22 bits for INT8 with MAXD = 64 (largest sum 1,048,576 = 64 x 16,384) | Proof in section 5, step 10 |
| PS-PL AXI interface, fastest clock | 250 MHz (all speed grades listed as FAXI_MAX) | Zynq-7000 data sheet DS187, Table 19 |
| Accumulator bits for K = 640 | INT4: 17, INT8: 25 | `first-rtl-results.md` (derived, check proof) |
| Data movement vs compute, 64x64 | 6.7x (simulation, ideal bus), 24.5x (board, 50 MHz) | Simulation / board |
| Assumed autoencoder at P = 8, M = 1 | 264,192 MACs; 4,128 passes x 23 = 94,944 cycles | [claim] hand-computed by Claude |

## 8. AI-assistance verification checklist

The professor warned: every equation needs a proof or a citation. Nothing below is trusted until ticked.

- [ ] Cycle equation T = Np (M + 3P - 2): derive from the RTL schedule. (It matches every simulation and board test so far, but that is evidence, not a proof.)
- [ ] Accumulator width w >= ceil(log2(K * 2^(2b-2) + 1)) + 1: prove, then check K = 640 gives 17 (INT4) and 25 (INT8).
- [ ] Assumed model shape 640-128-128-128-128-8-128-128-128-128-640 (DCASE baseline, from memory): check against the DCASE 2020 Task 2 baseline.
- [ ] MAC count 264,192 and 4,128 passes / 94,944 cycles: recompute.
- [x] XC7Z020 has 220 DSPs and 140 BRAM36 (and no high-speed transceivers): Xilinx selection guide.
- [ ] Exact accumulator width ACC >= 2*BITS + ceil(log2 MAXD) (22 bits for INT8, MAXD = 64): proof in section 5, step 10; team to check it.
- [x] PS-PL AXI interface at most 250 MHz: DS187 (Zynq-7000 DC and AC switching characteristics), Table 19.
- [ ] Fabric limits of the XC7Z020-1 (DSP48E1, block RAM, global clock buffer maximum frequency): look up in the data sheet. Claude quoted about 464 / 388 / 464 MHz from memory, not checked.
- [ ] ZedBoard audio codec ADAU1761 (I2C control, I2S audio) and its sample rates: check the ZedBoard manual and ADAU1761 datasheet.

Claims that turned out wrong (kept here on purpose):
- "INT4 saves no energy because the DSP48 multiplier is fixed-width": this build uses 0 DSPs (LUT multipliers), so INT4 should shrink them on this FPGA.
- "Fmax is about 65 MHz" (estimated from the 50 MHz slack): too pessimistic; 76.9 MHz met timing. Slack at a relaxed clock gives a floor, not a ceiling.
- "The 64 BRAMs are each 1 bit wide": the count is right (64), but READ_WIDTH_B is 18.
- "The two Unknown devices are the board": they were virtual devices (ROOT\SYSTEM).
- "The ZedBoard UART chip is Silicon Labs": it is Cypress (Cypress-USB2UART).
- "`use_dsp` gives one DSP per PE" (from the Yosys estimate): Vivado used 2 per PE (the add got its own DSP).
- "After the step 5 fixes, the next wall is activation -> DSP A input, 3.72 ns setup, in every PE": Vivado pulled the
  activation registers into the DSP itself (AREG = 2), so that setup is now 0.59 ns. The real next limits are listed under step 6 in section 5.
- "Zynq PL clocks are always 1000 MHz divided by a whole number": asking for 180 MHz gave 187.512 MHz, from another PS PLL.
- "`use_dsp` on the multiply only will stop the add getting its own DSP" (step 6): it did not; `use_dsp = "no"` on the add did (step 7).
- "The step 7 RTL cannot make 200 MHz" (7a failed): asking for 190 MHz gave 200.000 MHz and met timing (7c). Same clock period; the placement differed.

## 9. Open questions

- How many cycles does the fixed address logic add or save? (Should be zero; check PERF_CYCLES against the equation.)
- (Answered 17 Oct) 2 DSPs per PE: fixed in step 7 by building the add from LUTs; Vivado now uses 64 DSPs.
- (Answered 17 Oct) 200 MHz: met in step 7c (asked for 190 MHz). Next: steps 9 and 10 at 200 MHz, then a higher clock.
- (Answered 17 Oct) Above 250 MHz the AXI interface is the limit: step 12 gives the core its own clock.
- (Answered 17 Oct) Vivado did not map the `PIPE = 2` PE to one DSP (2 per PE); the direct DSP48E1 PE (step 11b) gives 64.
- What core clock can steps 11 + 12 reach? Next limits are probably the block RAM reads and the controller. (17 Oct, step 11b at
  250 MHz in one clock: the host read of C from block RAM, the Xilinx AXI interconnect and the controller's last-row compare.)
- The Arty P = 16 project: with `use_dsp` it would want 256 DSPs and the A7-35T has 90. Turn the hint off there (or set PIPE = 0).
- v2 architecture: tiling in software (simpler hardware) or keep the folding controller in hardware?
- v2 array size on the board: P = 8 or 12 (both fit in DSPs; 14 x 14 is the maximum)?
- Model size: DCASE baseline shape, or something smaller for a 64 x 64 core?
- Where are mel features computed first: PC or ARM?

## 10. Template for a new timeline row

| YYYY-MM-DD | What was finished (one line) | File, log, or screenshot that proves it |
