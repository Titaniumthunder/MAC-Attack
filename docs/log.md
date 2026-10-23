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
| 16 Oct | (James, on the PC) **Board run at 76.93 MHz, Release (-O2) build: ALL BOARD TESTS PASSED (8/8)**, measured clock 76.45 MHz, so the hardware platform was updated this time. First fair ARM baseline: 64x64 ARM software 2,080 us (Debug: 11,223 us); accelerator 1,509 us (load 531, run 72, read 906) = 1.4x. Logged on 18 Oct from James's screenshot. | SDK terminal (screenshot, James) |
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
| 18 Oct | Committed and pushed on `Alex_edit` ("200MHz clock", 0409010). | git |
| 18 Oct | **Step 13, one clock, rebuilt at 200.000 MHz** (Alex's VM): WNS +0.259 ns, WHS +0.037 ns, 0 failing of 10,627 endpoints; bitstream written with 0 critical warnings. LUT 1,096, FF 2,792, BRAM 4.5, DSP 64, power 1.884 W. The worst paths are the Xilinx AXI interconnect and the loader in `mac_axi.v` (bus side); none in the core. Reports copied to `Alex/timing_summary_v7.rpt`, `Alex/utilization_v7.rpt`. Not run on the board yet. | `impl_1` reports (18 Oct 19:55) |
| 18 Oct | `.gitignore` changed so the Vivado project is tracked (block design, run results with the bitstream, SDK projects); `zed/README.md` section 0 says how a teammate opens it and runs the board without rebuilding. | `.gitignore`, `zed/README.md` |
| 18 Oct | Committed and pushed on `Alex_edit` ("vivado project tracked", f698a1e): the project with the step 13 bitstream, but not the SDK `.hdf`, hardware platform or BSP. Pulled on the PC. | git |
| 18 Oct | On the PC, Vivado re-ran synthesis and implementation of the pulled project (the two IP runs were not redone; finished 21:20): same result, WNS +0.259 ns, WHS +0.037 ns. Hardware exported with the bitstream; SDK hardware platform and BSP updated (ps7_init FCLK0 = IO PLL 1000 / 5 = 200 MHz; the PC's old platform from 16 Oct was 1000 / 13 = 76.9 MHz). | `impl_1` reports (18 Oct 21:20), `mac_zed.sdk/system_wrapper.hdf` |
| 18 Oct | **Step 8 done: ALL BOARD TESTS PASSED (10/10) at 200 MHz** with the step 13 build (PIPE 2, MEM_REG 2, one DSP48E1 per PE, one clock). Every pass and cycle count equals the equation. Clock check: CORE_HZ 200.00 MHz, measured 197.81 MHz (the 1.1% gap is ARM time inside the measured window, section 4). 64x64: array 27.5 us, accelerator total 1,559 us, ARM software 11,615 us. Debug (-O0) build. | SDK terminal (screenshot, 18 Oct 21:25) |
| 18 Oct | **Release build at 200 MHz: ALL BOARD TESTS PASSED (10/10)**, measured clock 198.13 MHz. 64x64: load 320, run 27, read 508 us; accelerator 855 us against ARM 2,227 us = **2.6x faster** (1.4x at 76.93 MHz Release). The bus got 1.7-1.8x faster with the clock, so part of every bus transfer runs on the PL clock (section 4). | SDK terminal (screenshot, 18 Oct 22:33) |
| 18 Oct | ARM-side speed-ups in SDK `MAC_attack_V2/src/mac_test.c` (no FPGA change): (1) posted writes: the accelerator's 1 MB section remapped as Device memory, with a flush (dsb + L2 cache sync, as Linux `wmb()`) before the start, after the start, after RESULT_PTR and before time stamps; (2) loading copies 4 bytes as one word when a row is a multiple of 4 bytes; (3) two layer tests: weights loaded once, then 64 input rows, 1 or 8 per run; (4) every test runs in both bus modes on the same matrices, with a before/after summary. Checked on a PC against a register model whose posted writes are delivered late and overtaken by reads: 24/24, and removing any of the 4 needed flushes makes tests fail. Compiles against the BSP headers. | `mac_test.c`; PC model |
| 18 Oct | **New `mac_test.c` on the board, 200 MHz, Release: ALL BOARD TESTS PASSED (24/24)**, measured clock 198.11 MHz. 64x64: 799 -> **335 us** (load 263 -> 61, read 508 -> 245), accelerator **2.8x -> 6.6x** faster than the ARM. Layer, weights once, 8 rows per run: 855 -> **390 us**, **5.7x** faster than the ARM. | SDK terminal (screenshot, 18 Oct 22:56) |
| 19 Oct | **Step 14 written** (for one clock at 250 MHz): host read of C registered before the lane select (`mm_core.sv` `HREAD_REG`, reads wait 4 clocks) and the loader's flags from flip-flops (`mac_axi.v`). Simulation: lockstep against step 13 identical in every clock, read logs identical, `tb_axi` 14/14 (P = 4, 8, 16) and 15/15 (two clocks), team testbenches byte-identical, 3 planted bugs caught. Files in `Alex/step14/`, not in the build yet. | section 5, step 14 |
| 19 Oct | **Step 14 built at 250.000 MHz** (one clock, branch `try_250MHz`, Alex's VM, default implementation strategy): fails by 0.081 ns, WNS -0.081 ns, TNS -0.231 ns, **6 failing** of 10,833 endpoints (was 45 at 250 MHz on 17 Oct), WHS +0.051 ns. LUT 1,170, FF 2,997, BRAM 4.5, DSP 64, power 1.940 W. The host read of C and the loader no longer fail. Left: the Xilinx protocol converter (2), the C working copy's block RAM -> `cq2` (2), loader write data -> B block RAM (1), the accumulator add (1). Reports copied to `Alex/timing_summary_v8.rpt`, `Alex/utilization_v8.rpt`. Next: the same build with `Performance_ExplorePostRoutePhysOpt`. | `impl_1` reports (19 Oct 15:17) |
| 19 Oct | **250.000 MHz met timing** (step 14, one clock, branch `try_250MHz`, Alex's VM): same RTL, implementation strategy `Performance_ExplorePostRoutePhysOpt`. After routing WNS -0.003 ns (2 endpoints); the post-route physical optimization then gave **WNS +0.008 ns, TNS 0, 0 failing of 10,835 endpoints, WHS +0.019 ns**. Bitstream written, 0 critical warnings. LUT 1,170, FF 2,997, BRAM 4.5, DSP 64, power 1.940 W. The closest paths are all inside the Xilinx protocol converter. Reports copied to `Alex/timing_summary_v9.rpt` (post-route physopt), `Alex/utilization_v9.rpt`. Not run on the board yet (the board is at home). | `impl_1` reports (19 Oct 15:28) |
| 19 Oct | `try_250MHz` committed ("Try_250MHz"), then the SDK hardware platform fixed and committed ("SDK_file_250MHz"). SDK had copied the new `.hdf` into the platform but not unpacked it (SDK.log: "The new hardware specification file contains the same information as the current specification file. No changes were done"), so `ps7_init` still set 200 MHz. The 7 files were unpacked from the new `.hdf` by hand; `ps7_init.tcl` now writes 0x00200200 to FPGA0_CLK_CTRL (IO PLL 1000 / 2 / 2 = 250 MHz). | `SDK.log`, `system_wrapper_hw_platform_0/ps7_init.html` |
| 19 Oct | **Board run at 250 MHz (James): ALL BOARD TESTS PASSED (24/24)**, Release, both bus modes; every C value correct and every pass and cycle count equal to the equation. Measured clock 247.55 MHz (CORE_HZ 250.00; the same ~1% gap as at 200 MHz). 64x64x64 with posted writes: 335 -> **293 us**, accelerator **7.6x** faster than the ARM (6.6x at 200 MHz). Layer, 8 rows per run: 390 -> **337 us**, **6.6x** (5.7x). | SDK terminal output (James, 19 Oct) |
| 16 Oct | `docs/systolic_dataflow.html`: animated cycle-by-cycle view of data moving from the A/B buffers through the array to C (1-stage / 2-stage PE, MEM_REG on/off). Its model matches `systolic_array.sv` + `pe.sv` in Icarus cycle for cycle (every PE partial-sum register, `c_row`, `out_valid`; P = 2, 3, 4, PIPE = 0 and 1). | Icarus Verilog 12 |

| 20 Oct | Meeting with the professor (Pocket recording "TPU Clock Speed and FPGA Update", 12:08): 250 MHz shown; he asked for the chip's size (which technology, how many Tiny Tapeout tiles; "keep redesigning until we meet the size of the chip"); **approved the multi-task MLP on vibration, temperature and RPM** ("you have to train the model first ... and import the inference in the TPU"); a better FPGA can be ordered ("search about four or five options, and then we can convince Dr. J"); federated learning across laptops mentioned as a later idea. | Pocket recording, 20 Oct |
| 21 Oct | **On-chip MLP agreed** (section 2, section 5 step 15): one CTRL write runs a whole MLP of up to 4 layers on the FPGA. Weights in 4 slots of the B buffer, every channel's bias, m0 and shift in a scale memory, 8 postproc units write each layer's INT8 output back into A; the last layer's raw sums are read as before and the ARM adds that layer's bias. | section 5, step 15 |
| 21 Oct | **On-chip MLP written and simulated** (not built): new `rtl/mlp_ctrl.sv`; `mm_core.sv` (weight slots, A word write, writeback read of C), `postproc.sv` (per-channel scale fix, 7-stage option), `mac_axi.v` (registers 0x34-0x50, 7-bit AXI address), SDK `mac_test.c` (model tests), new tests. Simulation: 160 random whole models (P = 4, 8, 16; 1 to 8 postproc units; DSP48E1 PEs too), each run twice, bit-exact against `mac.py` `golden_mlp()` with every counter equal to the equation; `tb_axi` 20/20; `mac_test.c` against the RTL 30/30; old tests identical to step 14 and a lockstep with step 14 identical in every clock; 13/13 planted bugs caught. Not built in Vivado yet. | section 5, step 15 |
| 22 Oct | **Step 15 (on-chip MLP) built at 250.000 MHz** (`mac_attack_accel_MLP`, Alex's PC, strategy `Performance_ExplorePostRoutePhysOpt`, finished 10:17): `tb_axi` 20/20 in XSim; timing **fails by 0.156 ns**: WNS -0.156 ns, TNS -1.436 ns, 34 of 20,659 endpoints, WHS +0.011 ns (floor about 241 MHz). LUT 4,403, FF 6,221, BRAM 7.5, DSP 80, power 2.180 W, as step 15 predicted. Worst 10 paths: the Xilinx protocol converter in the AXI interconnect (6; the same paths passed by only 0.008 ns in step 14) and `pw_layer` -> the write address of every lane's scale memory (4, new). Bitstream written but not to be used. Reports copied to `Alex/timing_summary_v10.rpt` (post-route physopt), `Alex/utilization_v10.rpt`. | `impl_1` reports (22 Oct 10:17), Design Runs (screenshot) |
| 22 Oct | **Step 15b written and simulated** (not built): each lane registers its own copy of the scale-memory write (`mlp_ctrl.sv`), and an AXI Register Slice sits between the interconnect and `mac` (block design, `zed/create_zed_project.tcl`). Same 250 MHz, every result unchanged. Simulation: 110 random models bit-exact against `golden_mlp()` (P = 4, 8, 16; 1, 2 and 8 postproc units; 3- and 7-stage postproc), `tb_axi` 20/20 with DSP48E1 PEs, Verilator lint clean, planted wrong-lane bug caught. | section 5, step 15b |
| 22 Oct | **Step 15b built at 250.000 MHz** (register slice `mac_rs` in the block design, address still 0x43C00000 / 64K; finished 11:05): timing **fails by 0.175 ns**: WNS -0.175 ns (-0.185 after routing), TNS -1.556 ns, 36 of 21,261 endpoints, WHS +0.020 ns. LUT 4,470, FF 6,571 (+350, as expected), BRAM 7.5, DSP 80, power 2.182 W. **Both targeted paths are gone** (scale-memory write address; `mac_axi` -> converter). The 10 worst are now: inside the Xilinx protocol converter (1, the worst), the postproc shift and clamp stages in lanes 0, 2, 4, 6 (8), the model's cycle-sum adder (1). Reports copied to `Alex/timing_summary_v11.rpt`, `Alex/utilization_v11.rpt`. | `impl_1` reports (22 Oct 11:05), Design Runs (screenshot) |
| 22 Oct | **Step 15c written and simulated** (not built): postproc in 9 stages (`PPIPE = 2`: the shift in two steps, by a multiple of 8 then by 0-7; the clamp in two, its three tests then the choice), the model's counter sums added from local copies one clock after each layer's done (`mlp_ctrl.sv`), CONFIG bit 29 = 9-stage postproc and `PP_PIPE = 2` by default (`mac_axi.v`); SDK `mac_test.c`, `tb_axi.sv` and `mac.py` take the stages from CONFIG. Every output identical; a model takes 2 clocks more per layer boundary (64-64-64-6, 1 row: 3,194 -> 3,198). Simulation: lockstep of the 9-stage unit against the old 7- and 3-stage units, 842,802 inputs at ACC 22 and at ACC 32 (every shift 0-63): all identical; 200 random models bit-exact (P = 4, 8, 16; 1, 2, 4, 8 units; 3, 7, 9 stages; HREAD_REG 0 and 1); `tb_axi` 20/20; SDK `mac_test.c` against the RTL in Verilator 30/30; 9/9 planted bugs caught. | section 5, step 15c |
| 22 Oct | **Step 15c built at 250.000 MHz** (impl_1, `Performance_ExplorePostRoutePhysOpt`, finished 12:45, stopped after the post-route physical optimization): timing **fails by 0.029 ns** (was 0.175): WNS -0.029 ns (-0.038 after routing), TNS -0.088 ns, **6** of 21,824 endpoints, WHS +0.037 ns. LUT 4,440, FF 7,147 (+576, the extra postproc stages and counter copies), BRAM 7.5, DSP 80, power 2.187 W. The postproc and cycle-sum paths are gone. Left: inside the Xilinx protocol converter (2), the host's C read address `rd_row` -> C block RAM (3), the C block RAM -> `hq_sel` (1); all within 0.03 ns. Reports copied to `Alex/timing_summary_v12.rpt`, `Alex/utilization_v12.rpt`. | `impl_1` reports (22 Oct 12:45), Design Runs (screenshot) |
| 22 Oct | Step 15c at 250 MHz, four implementation runs, each with post-route physical optimization `AggressiveExplore`: impl_1 (`Performance_ExplorePostRoutePhysOpt`) WNS -0.029 ns (no gain), impl_2 (`Performance_ExtraTimingOpt`) -0.097 ns, impl_4 (`Performance_WLBlockPlacement`) -0.103 ns, impl_3 (`Performance_NetDelay_high`) not finished. **250 MHz not met** (best -0.029 ns, 6 endpoints). | Design Runs (screenshot, 13:2x) |
| 22 Oct | **Step 15c met timing at 214.286 MHz** (Alex: FCLK_CLK0 asked for 225 MHz, Actual Frequency 214.285706 MHz, Clock Summary 214.316 MHz / 4.666 ns; same RTL): impl_1 WNS **+0.081 ns**, TNS 0, **0 failing** of 21,781 endpoints, WHS +0.024 ns; impl_2 +0.061, impl_4 +0.068. Bitstream written. LUT 4,402, FF 7,048, BRAM 7.5, DSP 80, power 2.118 W. Closest path: the writeback token -> the scale memory read (LUT RAM, 87% wire). `mac_test.c` FCLK_HZ = 214285714. Reports copied to `Alex/timing_summary_v13.rpt`, `Alex/utilization_v13.rpt`. Not run on the board yet. | `impl_1` reports (22 Oct 13:18), Design Runs (screenshot) |
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
| 18 Oct | The Vivado project `zed/mac_zed_project` is tracked in git with its results and SDK projects; `create_zed_project.tcl` stays as the way to rebuild it. Only builds that met timing and passed on the board are pushed, by one person at a time. | Teammates and the professor can program the board without the 20-minute build. | agreed |
| 20 Oct | The model is a multi-task MLP on three sensors (vibration, temperature, RPM), trained first, then run on the accelerator. | The professor approved it in the 20 Oct meeting. The written proposal was acoustic (DCASE autoencoder); dataset still to pick (Paderborn or KAIST have these signals). | agreed (professor) |
| 21 Oct | Next RTL work: the on-chip MLP; the second clock (step 12) waits for a faster board. | Two clocks only help the FPGA (Tiny Tapeout has one clock pin, about 66 MHz) and compute is about 8% of a 64 x 64 run. Running the model on the chip removes most of the bus traffic and carries over to a chip. | agreed |
| 21 Oct | Model rules for the hardware: at most 64 inputs (e.g. 62 vibration bins + temperature + RPM), at most 4 layers, every width at most 64 (multiples of 8 keep every lane busy), linear heads on a shared trunk merged into one last layer (e.g. 5 fault classes + 1 anomaly score = 6 outputs), INT8 symmetric, 32-bit biases, one scale (m0, shift) per output channel, rounding as `postproc.sv` (halves up). James's NumPy model must match `mac.py` `requantize()` and `golden_mlp()` bit for bit. | One chain of layers keeps the sequencer simple; per-channel scales keep the accuracy (and INT4 later). | agreed |
| 21 Oct | The last layer's raw sums are read through RESULT_DATA as before; the ARM adds that layer's bias (32-bit logits). | No new read path into A (the A read address is one of the slowest paths at 250 MHz), and logits are better than INT8 for an anomaly score. | agreed |
| 21 Oct | Postproc units: a parameter; 8 on the FPGA (one C word per clock), 1 for a chip. | 8 units cost about 16 DSPs (156 are free); a chip cannot afford 8 multipliers and shifters. | agreed |
| 21 Oct | Weights: a fixed 64 x 64 slot per layer; the slot number is the top bits of the weight address. | No adder in front of the weight block RAM's address at 250 MHz. Costs 16 KB (4 RAMB36) instead of about 9 KB. | agreed |
| 21 Oct | K of layer l is N of layer l-1 (taken from the layer table by the hardware); K of layer 0 is DIMS.K. | A layer's input is always exactly the previous layer's output; the C program cannot make them disagree. | done |
| 21 Oct | AXI address 6 -> 7 bits, for 8 new registers. | The 6-bit map (0x00-0x3C) had only 3 free registers. Vivado needs Refresh Changed Modules. | done |
| 22 Oct | The on-chip MLP build runs at 214.286 MHz for now (FCLK_CLK0 asked for 225); design 1 (`mac_attack_accel`) stays at 250 MHz. | 250 MHz missed by 0.029 ns after steps 15b and 15c and four implementation strategies; the last 6 paths are inside the Xilinx protocol converter and the C block RAM read. A working build first, to run the model on the board; 250 MHz (or the highest clock the Zynq can make below it) stays the goal. | decided (Alex) |

## 3. Current status (what is and is not proven)

- [done] RTL simulation: 60/60 cases match NumPy; Vivado `tb_selfcheck` 8/8.
- [done] AXI wrapper `tb_axi` 12/12 in XSim 2019.1.
- [done] ZedBoard block design, bitstream, timing met at 50 MHz and at 76.9 MHz.
- [done] Board: 8/8 tests pass at 50 MHz.
- [done] Board: 10/10 tests pass at **200 MHz** (step 13 build, 18 Oct); measured clock 197.81 MHz. Debug build.
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
- [done] Step 13: simulation (section 5); built at 200 MHz (WNS +0.259 ns, on the VM and again on the PC with the same result); run on the board (10/10).
- NOT done: step 12 (two clocks) built in Vivado.
- (Done) Board runs above 50 MHz: 76.93 MHz on 16 Oct (James, Release) and 200 MHz on 18 Oct (Debug), section 4.
- [done] Release (-O2) build on the board: 76.93 MHz (16 Oct, James) and 200 MHz (18 Oct), section 4. At 200 MHz the accelerator is 2.6x faster than the ARM for 64x64x64.
- [done] Step 14 in simulation (section 5), built at **250 MHz: timing met** (WNS +0.008 ns, branch `try_250MHz`, 19 Oct), and **run on the board: 24/24 at 250 MHz** (measured 247.55 MHz, James, 19 Oct). Not merged into `Alex_edit` yet.
- [done] ARM-side bus changes (posted writes, word copies, weights loaded once): 64x64x64 6.6x faster than the ARM; one 64x64 layer over 64 rows, 8 rows per run, 5.7x (section 4).
- [done] On-chip MLP in simulation (21 Oct, section 5 step 15): 160 random models bit-exact against `golden_mlp()` (P = 4, 8, 16), `tb_axi` 20/20, `mac_test.c` against the RTL 30/30; plain multiplies unchanged (lockstep with step 14 identical in every clock, old test outputs identical).
- [done] On-chip MLP built in Vivado at 250 MHz (22 Oct): `tb_axi` 20/20 in XSim, resources as predicted, but timing fails by 0.156 ns (section 5, step 15b). Step 15b (two timing fixes, same clock) built 22 Oct: its two paths are gone, but timing still fails by 0.175 ns (converter inside, postproc shift and clamp, cycle-sum adder).
- [done] Step 15c (postproc in 9 stages, counter sums from local copies, same clock, every output identical) written and simulated: `tb_axi` 20/20, SDK `mac_test.c` against the RTL 30/30. Built 22 Oct: fails by 0.029 ns at 250 MHz (6 endpoints: converter, C block RAM read); **meets timing at 214.286 MHz** (WNS +0.081 ns). Not run on the board yet.
- NOT done: on-chip MLP meeting timing at 250 MHz and run on the board. NOT done: a trained model to run on it.
- NOT done: INT8 and INT4 AUC on real data. Nothing trained yet.
- NOT done: audio front end.

## 4. Board results

All times in microseconds. Speedup = ARM software / (load + run + read).

### 50 MHz (15 Oct, original RTL, Debug build)

| Test | Array (calc) | Load | Run | Read | ARM software | Winner |
|---|---|---|---|---|---|---|
| 4x4x4 | 0.5 | 6 | 1 | 6 | 4 | ARM, 3.3x |
| 16x16x16 | 3 | 74 | 3 | 97 | 189 | Accelerator, 1.1x |
| 64x64x64 | 110 | 1,153 | 110 | 1,549 | 11,223 | Accelerator, 4.0x |
| 37x50x23 | 25 | 425 | 25 | 322 | 1,833 | Accelerator, 2.4x |
| 1x64x64 | 29 | 586 | 29 | 24 | 175 | ARM, 3.7x |

- 64x64: moving data is 96% of the time; (load + read) / array = 24.5x, against 6.7x in the ideal-bus simulation.
- [claim] The ARM software time is a steady ~43 ns per multiply-add, which suggests an unoptimised (Debug, -O0) build. Re-measure with Release before quoting any speedup. (Confirmed 16 Oct: the Release build takes 2,080 us, 5.4x less; see 76.93 MHz below.)
- [claim] The 1x64x64 case is the autoencoder's shape (one row at a time). Reloading all weights per inference would take ~37 ms (estimate), longer than a 32 ms audio hop, so weights must stay in the FPGA.

### 76.93 MHz (16 Oct, James; Release build; 76.9 MHz bitstream with 32-bit sums)

ALL BOARD TESTS PASSED (8/8); every pass and cycle count equals the equation. Measured clock 76.45 MHz (FCLK_HZ 76.93).

| Test | Array (calc) | Load | Run | Read | ARM software | Winner |
|---|---|---|---|---|---|---|
| 4x4x4 | 0.3 | 3 | 0 | 3 | 0 | ARM (6 vs 0) |
| 16x16x16 | 2.0 | 33 | 2 | 56 | 33 | ARM, 2.8x |
| 64x64x64 | 71.5 | 531 | 72 | 906 | 2,080 | Accelerator, 1.4x |
| 37x50x23 | 16.1 | 197 | 16 | 189 | 343 | ARM, 1.2x |
| 1x64x64 | 19.1 | 271 | 19 | 14 | 32 | ARM, 9.5x |

- This is the fair baseline. The Release ARM software is 5.4x faster than Debug at 64x64 (2,080 against 11,223 us): about 7.9 ns, or 5.3 ARM clocks at 666.7 MHz, per multiply-add.
- Against the Release ARM the accelerator wins only at 64x64, by 1.4x. Moving data is 95% of the accelerator's time (1,437 of 1,509 us); (load + read) / array = 20x.
- The 1x64x64 shape (one input row through a 64x64 layer, the autoencoder's case) loses 9.5x: loading the 64x64 weights (271 us) alone takes 8x the ARM's whole job (32 us).

### 200 MHz (18 Oct, step 13 build: PIPE 2, MEM_REG 2, one DSP48E1 per PE, one clock; Debug build)

ALL BOARD TESTS PASSED (10/10); every pass and cycle count equals the equation. Array (calc) = cycles / 200 MHz.

| Test | Array (calc) | Load | Run | Read | ARM software | Winner | At 50 MHz |
|---|---|---|---|---|---|---|---|
| 4x4x4 | 0.13 | 4 | 0 | 3 | 4 | ARM, 1.8x | ARM, 3.3x |
| 16x16x16 | 0.76 | 48 | 1 | 49 | 194 | Accelerator, 2.0x | Accelerator, 1.1x |
| 64x64x64 | 27.5 | 755 | 27 | 777 | 11,615 | Accelerator, 7.5x | Accelerator, 4.0x |
| 37x50x23 | 6.2 | 278 | 6 | 162 | 1,896 | Accelerator, 4.3x | Accelerator, 2.4x |
| 1x64x64 | 7.4 | 383 | 7 | 12 | 181 | ARM, 2.2x | ARM, 3.7x |

- The other 5 tests (every input -128, every input 127, B = identity at 16x16x16; every input -128, and A = 127 with B = -128, at 64x64x64) gave the same times as the random test of the same size.
- The array got 4x faster (64x64: 110 -> 27.5 us) but the bus only 1.5-2x (load 1,153 -> 755 us, read 1,549 -> 777 us). [claim, wrong] Most of each bus word's time is ARM time, which the PL clock does not speed up. (These were Debug numbers. In Release the bus gets 1.7-1.8x faster from 76.93 to 200 MHz; see the Release table below.) 64x64: moving data is now 98% of the time; (load + read) / array = 56x (24.5x at 50 MHz).
- Clock check: CORE_HZ says 200.00 MHz, measured 197.81 MHz. [claim] Not a slower clock: FCLK0 = IO PLL 1000 / 5 = 200 MHz. The measured window (t1 to t2 in `mac_test.c`) also holds the start write, the polling reads after the run ends and the timer reads: about 0.3 us per 64x64 run (5,511 cycles = 27.56 us at 200 MHz; 197.81 MHz implies 27.86 us). So it reads about 1% low; the warning threshold is 5%.
- Debug (-O0) build: the ARM software and the bus loops are both slower than in Release. The Winner column is against a Debug ARM and overstates the gain: 64x64 shows 7.5x here, but 1.4x against the Release ARM (76.93 MHz table). Re-measure with Release (section 5, step 8, item 6).
- Same 64x64 run, 76.93 MHz Release against 200 MHz Debug: run 72 -> 27 us (2.6x, the clock ratio), read 906 -> 777 us (mostly waiting on the FPGA, so the clock helps), load 531 -> 755 us (4 bytes packed by ARM code before every write, so Debug hurts more than the clock helps), ARM software 2,080 -> 11,615 us (Debug only).

### 200 MHz (18 Oct, step 13 build, Release build)

ALL BOARD TESTS PASSED (10/10); every pass and cycle count equals the equation. Measured clock 198.13 MHz.

| Test | Array (calc) | Load | Run | Read | ARM software | Winner | At 76.93 MHz, Release |
|---|---|---|---|---|---|---|---|
| 4x4x4 | 0.13 | 1 | 0 | 2 | 0 | ARM (3 vs 0) | ARM (6 vs 0) |
| 16x16x16 | 0.76 | 20 | 1 | 31 | 35 | ARM, 1.5x | ARM, 2.8x |
| 64x64x64 | 27.5 | 320 | 27 | 508 | 2,227 | Accelerator, 2.6x | Accelerator, 1.4x |
| 37x50x23 | 6.2 | 119 | 6 | 106 | 367 | Accelerator, 1.6x | ARM, 1.2x |
| 1x64x64 | 7.4 | 162 | 7 | 8 | 34 | ARM, 5.2x | ARM, 9.5x |

- Same 64x64 run, both Release, 76.93 -> 200 MHz: run 72 -> 27 us (2.6x, the clock ratio), load 531 -> 320 us (1.7x), read 906 -> 508 us (1.8x), total 1,509 -> 855 us (1.8x). ARM software 2,080 -> 2,227 us (it does not use the PL clock; the 7% difference is not explained).
- So the bus also speeds up with the PL clock: the AXI interconnect, the protocol converter and `mac_axi` all run on FCLK_CLK0. [claim] Fitting t = a + n / f_PL to the two runs: a write costs about 92 ns on the ARM side plus about 13 PL cycles, a read about 64 ns plus about 12 PL cycles. Only two points, from two hardware versions (the 16 Oct bitstream had the older `mac_axi`), so this is an estimate.
- Moving data is still 97% of the accelerator's time at 64x64: (320 + 508) / 855; (load + read) / array = 30x.
- 1x64x64: loading the 64x64 weights is 162 of the 177 us.

### 200 MHz, Release, new `mac_test.c`: both bus modes (18 Oct)

ALL BOARD TESTS PASSED (24/24), every pass and cycle count equal to the equation, in both modes. Same matrices in both modes. Times in us.

| Test | Strongly ordered: load / run / read = total | Posted writes: load / run / read = total | ARM software | Before -> after |
|---|---|---|---|---|
| 16x16x16 | 17 / 1 / 31 = 49 | 4 / 1 / 15 = 20 | 36 | ARM 1.4x -> accelerator 1.8x |
| 64x64x64 | 263 / 27 / 508 = 799 | 61 / 27 / 245 = 335 | 2,227 | accelerator 2.8x -> 6.6x |
| 37x50x23 | 119 / 6 / 106 = 231 | 27 / 6 / 51 = 84 | 367 | accelerator 1.6x -> 4.3x |
| 1x64x64, weights sent again | 134 / 7 / 8 = 149 | 31 / 7 / 4 = 42 | 34 | ARM 4.4x -> ARM 1.3x |
| Layer: weights once, 64 rows, 1 per run | weights 132, rows 1,159 (18.1 per row) = 1,291 | weights 30, rows 795 (12.4 per row) = 826 | 2,228 | accelerator 1.7x -> 2.7x |
| Layer: weights once, 64 rows, 8 per run | weights 132, rows 723 (11.2 per row) = 855 | weights 30, rows 359 (5.6 per row) = 390 | 2,227 | accelerator 2.6x -> 5.7x |

- Word copies alone (strongly ordered mode against the earlier 200 MHz Release run): 64x64 load 320 -> 263 us. 37x50x23 is unchanged because rows that are not a multiple of 4 bytes still use the byte-by-byte path.
- Posted writes: 2,048 writes in 61 us = 30 ns = 6 PL cycles per write. [claim] That is `mac_axi`'s own limit: it accepts one write, then writes its 4 bytes one per clock before it accepts the next.
- Reads also got 2x faster: 508 -> 245 us, 124 -> 60 ns (about 12 PL cycles) per read. [claim] With Device memory the ARM can have several reads in flight; with strongly ordered memory each read must finish before the next one starts. So reads now wait on `mac_axi` and the AXI interconnect, not on the ARM.
- Both directions are now set by the FPGA side, so the PL clock matters for the bus again (a faster FCLK, or fewer cycles per transfer in `mac_axi`).
- 64x64 with posted writes: load 61 (18%), run 27 (8%), read 245 (74%).
- The single 1x64x64 test still sends the 4 KB of weights every time, so the ARM still wins it; the layer tests are the real use (one row through a layer: 177 us before, 12.4 us now with weights kept, 5.6 us per row in batches of 8).
- 24/24 in posted mode means the 4 flush points keep the ordering correct on the board, as the PC model predicted.

### 250 MHz, Release, both bus modes (19 Oct, step 14 build, branch `try_250MHz`; James ran it)

ALL BOARD TESTS PASSED (24/24), every C value correct and every pass and cycle count equal to the equation, in both
modes. Measured clock 247.55 MHz (CORE_HZ 250.00 MHz). Times in us.

| Test | Strongly ordered: load / run / read = total | Posted writes: load / run / read = total | ARM software | Posted writes, 200 -> 250 MHz |
|---|---|---|---|---|
| 16x16x16 | 15 / 0 / 29 = 44 | 3 / 0 / 14 = 17 | 36 | 20 -> 17 us; accelerator 1.8x -> 2.0x |
| 64x64x64 | 236 / 22 / 467 = 726 | 49 / 22 / 221 = 293 | 2,227 | 335 -> 293 us; 6.6x -> **7.6x** |
| 37x50x23 | 111 / 5 / 98 = 214 | 27 / 5 / 46 = 78 | 367 | 84 -> 78 us; 4.3x -> 4.7x |
| 1x64x64, weights sent again | 120 / 6 / 7 = 133 | 25 / 6 / 3 = 34 | 34 | 42 -> 34 us; ARM 1.3x -> even |
| Layer: weights once, 64 rows, 1 per run | weights 118, rows 1,006 (15.7 per row) = 1,125 | weights 24, rows 666 (10.4 per row) = 690 | 2,227 | 826 -> 690 us; 2.7x -> 3.2x |
| Layer: weights once, 64 rows, 8 per run | weights 118, rows 653 (10.2 per row) = 771 | weights 24, rows 313 (4.8 per row) = 337 | 2,228 | 390 -> 337 us; 5.7x -> **6.6x** |

- Array (calc): 64x64x64 is 5,504 cycles at both clocks, 27.5 -> 22.0 us, exactly the clock ratio (1.25x).
- Writes follow the clock: 2,048 writes in 49 us = 24 ns = 6 PL cycles, the same 6 cycles as at 200 MHz (61 us).
- Reads gain less: 245 -> 221 us, 60 -> 54 ns per read (about 13.5 cycles at 250 MHz against 12 at 200). Step 14 adds
  one clock to every register read, and part of each read is ARM and interconnect time that the PL clock does not
  shorten. The estimate before the run (section 5, step 14) was 285 us for 64x64; measured 293 us.
- 37x50x23 load is unchanged (27 us): its rows are not a multiple of 4 bytes, so they go byte by byte from the ARM.
- 64x64 with posted writes: load 49 (17%), run 22 (8%), read 221 (75%). Reads are now the largest share.

## 5. Clock speed history (step by step)

One entry per Vivado build that changed the clock or the RTL. ZedBoard XC7Z020-1, P = 8.

How to read a timing result:

    worst path = T_clk - WNS             (the slowest register-to-register path, at most)
    floor Fmax = 1 / (T_clk - WNS)       (a floor, not a ceiling: the tool only works as hard as the clock asks)
    every path:  T_clk >= t_clk->Q + t_wire + t_logic + t_setup + t_jitter

Zynq PL clocks come from one of the PS PLLs divided by whole numbers. From the 1000 MHz IO PLL: 1000/13 = 76.9,
/10 = 100, /7 = 142.9, /6 = 166.7, /5 = 200. Other values come from another PLL: asking for 180 MHz gave 187.512 MHz.
Always use the Actual Frequency Vivado shows (or the Clocking Wizard for exact values). The board itself keeps
running at 50 MHz until the SDK hardware platform (ps7_init) is updated (section 6). (Updated: the board ran at 76.93 MHz on 16 Oct and at 200 MHz on 18 Oct, section 4.)

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
| 13 (one clock) | 18 Oct | 200.000 | **yes**, board 10/10 | +0.259 / +0.037 | 4.74 ns / 211 MHz | Last-row flags, `idle_q`, A/B feed registers swapped (MEM_REG = 2); one clock (`CORE_CLK = 0`). Worst paths on the bus side | same as 10b + 11 | 1,096 / 2,792 / 4.5 / 64 |
| 14 | - | 250.000 (one clock) | not built | - | - | Host C read registered before the lane select (`HREAD_REG = 1`); loader flags from flip-flops | same cycles per pass; reads 1 clock longer | - |
| 14 (one clock) | 19 Oct | 250.000 | **no** | -0.081 / +0.051 | 4.08 ns / 245 MHz | Host read of C registered (`HREAD_REG`), loader flags from flip-flops; default implementation strategy | +1 bus clock per register read | 1,170 / 2,997 / 4.5 / 64 |
| 14 (one clock), Explore | 19 Oct | **250.000** | **yes**, board 24/24 | +0.008 / +0.019 | 3.99 ns / 250 MHz | Same RTL; strategy `Performance_ExplorePostRoutePhysOpt` (post-route physical optimization closed the last 2 endpoints) | +1 bus clock per register read | 1,170 / 2,997 / 4.5 / 64 |
| 12 + 13 | - | AXI 200, core 250 | not built | - | - | Two clocks with the step 13 core | same as 10b + 11, in core cycles | - |
| 15 (one clock), Explore | 22 Oct | 250.000 | **no** | -0.156 / +0.011 | 4.16 ns / 241 MHz | On-chip MLP (`MLP = 1`: weight slots, scale memory, 8 postproc units with 7 stages, layer sequencer); same strategy. Worst paths: the Xilinx protocol converter and the scale-memory write address | plain multiplies as step 14; model runs: `MODEL_CYCLES` equation (step 15) | 4,403 / 6,221 / 7.5 / 80 |
| 15b | 22 Oct | 250.000 (one clock) | **no** | -0.175 / +0.020 | 4.18 ns / 239 MHz | Per-lane scale-memory write registers; AXI register slice in front of `mac`. Those paths are gone; worst now: inside the protocol converter, postproc shift and clamp, cycle-sum adder | as step 15; about +2 bus clocks per AXI access | 4,470 / 6,571 / 7.5 / 80 |
| 15c | 22 Oct | 250.000 (one clock) | **no** | -0.029 / +0.037 | 4.03 ns / 248 MHz | Postproc in 9 stages (shift and clamp each split in two); model counter sums from local copies | model: +2 clocks per layer boundary (drain RL + 9 + 1 = 12); plain multiplies unchanged | - |
| 15c | 22 Oct | **214.286** (asked 225) | **yes** | +0.081 / +0.024 | 4.59 ns / 218 MHz | Same RTL as the 250 MHz build; clock setting only (250 MHz missed by 0.029 ns with four strategies) | as 15c | 4,402 / 7,048 / 7.5 / 80 |

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

### Step 8: board run at 200 MHz (prepared 17 Oct, done 18 Oct with the step 13 build)

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

Result (18 Oct, PC, step 13 build): `ALL BOARD TESTS PASSED (10/10)` and `Core clock: CORE_HZ says 200.00 MHz,
measured on the board 197.81 MHz` (no warning). Differences from the procedure: the clock line now says `Core clock`
and `CORE_HZ` (the program also supports two clocks, step 12); the first run was Debug; the Release run followed the same evening (section 4);
the measured value reads about 1% low by design (section 4). Times in section 4.

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

### Step 14: one clock at 250 MHz (agreed 18 Oct; (a) and (b) written and simulated 19 Oct, not built)

Why: with posted writes (section 4) the bus is set by the FPGA side (6 PL cycles per write, about 12 per read). With
one clock, a faster FCLK speeds up the bus as well as the array; step 12 (a faster core clock only) would speed up only
the array's 8% share of a 64x64 run. FCLK_CLK0 = 250 MHz is IO PLL 1000 / 4 (exact) and the most the PS-PL AXI port
allows (DS187, Table 19).

Closest paths in the step 13 build at 200 MHz (`impl_1` timing summary, 18 Oct, PC re-run; same as Alex's VM build):

| Slack at 200 MHz (ns) | From -> to | Logic levels | Data path (ns): logic / route | What it is |
|---|---|---|---|---|
| +0.259, +0.348, +0.382 | `auto_pc` write channel: `bid_fifo` `cnt_read` -> `incr_cmd` `axaddr_incr` | 6 (2 CARRY4) | 4.291: 2.015 / 2.276 | Xilinx protocol converter (AXI3 -> AXI4-Lite). Not our RTL |
| +0.295, +0.295, +0.460 | `ld_col` -> `ld_row` clock enable | 3 (LUT5, 2 LUT6) | 4.392: 0.890 / 3.502 | Loader in `mac_axi.v` |
| +0.337, +0.407 | `w_load_q` replica -> DSP `CEB2` (row 7) | 0 | 4.127: 0.456 / 3.671 | Weight-load enable, fanout to 64 DSPs |
| +0.461 | `auto_pc` read channel: `axlen_cnt` -> `axlen_cnt` reset | 3 | 3.873: 1.257 / 2.616 | Xilinx protocol converter |

- At 250 MHz the period is 1 ns shorter. From the step 11b build at 250 MHz, the failing groups that step 13 did not
  change are the host read of C (15 endpoints, -0.263 ns), the protocol converter (4, -0.225 ns) and the loader
  (6, -0.038 ns). (At 250 MHz Vivado placed the `w_load` replicas well enough; that path did not fail in 11b.)

Proposed order:
1. Commit the working 200 MHz state, then on a new branch set FCLK_CLK0 to 250 MHz and build step 13 unchanged, to get
   the current failing list (no RTL change; a build takes a few minutes).
2. RTL fixes for what fails: (a) host read of C: register the 8-lane C word before the lane select, `mac_axi.v` waits
   4 clocks per register read instead of 3 (176 FFs, one more clock per read); (b) loader: the last-column and
   inside-the-matrix flags worked out one step ahead (as step 13 (a)), so `ld_row`'s enable comes from a flip-flop;
   (c) protocol converter: Vivado implementation strategy Performance_ExplorePostRoutePhysOpt first (no RTL).
3. `mac_test.c`: `FCLK_HZ` 250000000.

Expected (estimate): 64x64 with posted writes 335 -> about 285 us (write 6 x 4 ns = 24 ns, read about 13 x 4 ns =
52 ns, array 22 us).

Written (19 Oct), files in `Alex/step14/` (not yet in `rtl/` and `zed/`, so the 200 MHz build is unchanged):
- `mm_core.sv`: new parameter `HREAD_REG` (default 0 = exactly as before, for the UART/Arty top, OpenLane and the
  team testbenches). With 1, the C word and its lane number are registered once more (on hclk) before the lane
  select, so `rd_data` comes 2 cycles after `rd_row`/`rd_col` instead of 1. 176 + 3 FFs.
- `mac_axi.v`: `HREAD_REG = 1` passed to the core; a register read waits `RD_WAIT` = 4 clocks instead of 3
  (keeps the old margin: even a read taken in the same clock as a RESULT_PTR write gets the new value).
  Loader: `ld_inside`, `ld_col_last`, `ld_row_last` are flip-flops. While no byte is written they are worked out
  from the registers; while bytes are written they step one step ahead (next column: last = col == len - 2; next row:
  inside = !row_last, col_last = (len == 1), row_last = row == rows - 2). LOAD_PTR/DIMS change the position at least
  3 clocks and the sizes 2 clocks before the next first byte, so the flags are right when bytes start (1 clock to spare).
  `ld_row`'s enable is then (ld_left != 0) & ld_inside & ld_col_last, all flip-flops.

Checked (Icarus Verilog 12, Verilator 5.020, Xilinx DSP48E1 model), with a new testbench `tb_s14.sv` whose AXI master
offers the next transfer as soon as the previous one is accepted, with random gaps and random bready/rready:
- Lockstep, step 13 `mac_axi` against the new one with `HREAD_REG = 0`: every AXI output, the loader position, the
  core's load port, the read pointer, DIMS, flags and counters equal in **every clock**: 7 runs (P = 4, 8, 16; 4 seeds;
  one with no gaps), 183,887 to 282,168 clocks each, 0 differences.
- Loader flags against their definitions in every clock a byte is written: 0 mismatches in every run (43,000 to
  77,000 checks per `tb_s14` run, 33,820 per `tb_axi` run).
- Same transfers on the step 13 design and on the new one with `HREAD_REG = 1`: the logs of every timing-independent
  read are **identical** (P = 4: 12,817 reads; P = 8: 15,334, 25,156 and 25,189; P = 16: 15,419).
- `zed/tb_axi.sv` on the new RTL with DSP48E1 PEs: 14/14 at P = 4, 8, 16; two clocks (core at 40, 250 and 400 MHz): 15/15.
- Team testbenches (`tb_selfcheck`, `tb_compare`, `tb_extras`, `tb_mm`, `tb_chip`, `tb_postproc`): byte-identical to step 13.
- Verilator lint `-Wall`: clean for HREAD_REG 0/1 x CORE_CLK 0/1.
- Planted bugs: next-row `ld_col_last` forced to 0 (caught, 827 and 7,869 differences); `ld_row_last` stepped with
  rows - 1 (caught, 51 and 149); rows - 1 two clocks late (caught, 4 and 9: the tests reach the shortest LOAD_PTR ->
  first byte gap). Rows - 1 one clock late is not a bug (it uses the 1 clock to spare) and passes, as expected.
- A first version of the old-against-new log compare differed in 4 reads: the testbench let a read finish after the
  next write. Fixed in the testbench (a write now waits for earlier reads, as on the ARM); not an RTL problem.

Next: on branch `try-250MHz`, copy the two files into `rtl/` and `zed/`, FCLK_CLK0 = 250 MHz, build; then `mac_test.c`
`FCLK_HZ` = 250000000. If only the Xilinx protocol converter fails, try Performance_ExplorePostRoutePhysOpt.

Built 19 Oct (branch `try_250MHz`; `rtl/mm_core.sv` and `zed/mac_axi.v` replaced by the files above; FCLK_CLK0 250.000
MHz; `mac_test.c` `FCLK_HZ` 250000000; default implementation strategy, because the strategy setting was not found):
WNS -0.081 ns, TNS -0.231 ns, 6 failing endpoints of 10,833, WHS +0.051 ns. LUT 1,170, FF 2,997, BRAM 4.5, DSP 64,
1.940 W. Neither the host read of C nor the loader is among the failing paths any more.

| Slack (ns) | From -> to | Levels | Data path (ns) | What it is |
|---|---|---|---|---|
| -0.081 | `auto_pc` `bid_fifo` (SRL) -> `bresp_cnt` reset | 3 | 3.462 | Xilinx protocol converter, write response |
| -0.074, -0.003 | `cmem` block RAM -> `cq2[149]`, `cq2[171]` | 0 | 3.965, 3.729 (2.454 is the block RAM's clock-to-out) | C working copy read; the block RAM output now also feeds the step 14 register (fanout 2) |
| -0.059 | `auto_pc` `bid_fifo` `cnt_read` -> `axaddr_incr` | 5 | 3.998 | Xilinx protocol converter, write address |
| -0.013 | `core_wr_data[1]` -> `bmem` data input | 0 | 2.972 (2.553 wire, fanout 11) | Loader's byte to the B block RAM (one byte goes to all 8 lanes) |
| -0.002 | `cq2[167]` -> `wq[175]` | 4 (3 CARRY4) | 3.901 | The C accumulator add |

Next: the same RTL with the `Performance_ExplorePostRoutePhysOpt` implementation strategy (implementation only). If
the C working copy still fails: give the host its own C copy read through the block RAM's output register, so the
working copy's block RAM drives only `cq2` again.

Second build, 19 Oct: same RTL, strategy `Performance_ExplorePostRoutePhysOpt` (Design Runs > impl_1 > Change Run
Settings > Strategy; or `set_property strategy Performance_ExplorePostRoutePhysOpt [get_runs impl_1]`). After routing:
WNS -0.003 ns, 2 endpoints. The post-route physical optimization then closed them: **WNS +0.008 ns, TNS 0, 0 failing
endpoints, WHS +0.019 ns: 250 MHz met.** Bitstream written, 0 critical warnings. Same resources as the first build.
All the closest paths are inside the Xilinx protocol converter; the C working copy, the loader byte and the accumulator
add all passed. The margin is small (8 ps), so any later change must be re-checked at 250 MHz, and the board run is
still to do (`mac_test.c` already has `FCLK_HZ` 250000000).

Board run, 19 Oct (James): ALL BOARD TESTS PASSED (24/24) at 250 MHz, measured 247.55 MHz; section 4.

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

### Step 15: on-chip MLP (agreed 21 Oct, written and simulated 21 Oct, not built)

**Why.** The professor approved a multi-task MLP on vibration, temperature and RPM (20 Oct) and asked us to
train it first and then run its inference on the accelerator. Until now the accelerator does one matrix
multiply per command, so for an MLP the ARM would read C back after every layer, add the bias, requantize,
apply ReLU and send the result back in. On the board one 64 x 64 layer over 64 rows took 337 us at 250 MHz,
mostly bus time (reads are 75% of a 64 x 64 run). Running the whole model on the FPGA removes the traffic
between layers, and it is the same RTL a chip would need (its pins are slower still).

**What changed.** The PE array, the folding controller and the buffers are unchanged; the new parts sit around them.

| Part | File | Change |
|---|---|---|
| Weight slots | `rtl/mm_core.sv` | `NL` (4): B holds one 64 x 64 matrix per layer, 2,048 x 64 bits (16 KB) instead of 512 x 64. The slot is the top address bits (`{layer, kb, k, nb}`), taken at start like the sizes (`run_layer`); loading B picks the slot (`wr_layer`). |
| A word write | `rtl/mm_core.sv` | `AWR = 1`: a whole A word (i, blk) in one clock (`aw_*`), sharing the A block RAM's write port with the loader (they are never used together; the word write wins). |
| C word read | `rtl/mm_core.sv` | `rd_word`: the whole C word the read port fetched (same timing as `rd_data`). `wb_rd`, `wb_row`, `wb_blk`: the writeback's read address goes into the existing C address mux straight from bit fields (no adder), so this path is no longer than in step 14. |
| Postproc | `rtl/postproc.sv` | m0, shift and relu now travel down the pipeline with the data (the fix in section 6). `PPIPE = 1`: 7 stages (bias add; multiply plus 2 registers for the two DSPs a 33 x 17 multiply needs; add the rounding constant; shift; clamp). Same numbers as 3 stages. |
| Sequencer, scale memory, writeback | `rtl/mlp_ctrl.sv` (new) | Wraps `mm_core`. Layer table (N and ReLU per layer), a scale memory (32-bit bias, 16-bit m0, 6-bit shift per channel per layer, in LUT RAM), 8 postproc units, the state machine below. Plain multiplies go straight through. |
| Registers | `zed/mac_axi.v` | `MLP = 1` (default) puts `mlp_ctrl` between the AXI side and `mm_core`; `MLP = 0` builds the step 14 design. CTRL bit 1, slot fields in DIMS and LOAD_PTR, registers 0x34-0x50 (below), AXI address 7 bits. CONFIG bits 18-28 describe the model hardware. |
| Board program | SDK `MAC_attack_V2/src/mac_test.c` | 3 model tests per bus mode (1, 8 and 64 rows per run) with the same integer model on the ARM as reference and baseline; skipped when CONFIG bit 18 is 0. 30 tests in all. |
| Tests | `tb/tb_mlp.sv` (new), `tb/tb_postproc.sv`, `zed/tb_axi.sv`, `mac.py` | `mac.py`: `requantize()`, `scale_to_m0_shift()`, `golden_mlp()`, `mlp_equation()`, command `python mac.py mlp`; `postproc` now also tests a new scale every clock. |
| Tie-offs | `rtl/chip_top.sv`, `tb/tb_mm.sv`, `tb_selfcheck.sv`, `tb_compare.sv`, `tb_extras.sv` | The new `mm_core` ports tied to 0; nothing else changed. |

**Per layer** (layer l = 0 .. L-1, M rows; K_0 = DIMS.K, K_l = N_(l-1), N_l from LAYERl):

    C = A x W_l                                                  exact 22-bit sums, as before
    l < L-1:  A <- clamp( ((C + bias) * m0 + 2^(shift-1)) >> shift,  relu ? 0 : -128,  127 )   per output channel
    l = L-1:  C stays in the C buffer; RESULT_DATA returns it; the ARM adds the bias (logits)

Writeback: C word (i, nb) holds C[i][8nb .. 8nb+7] and A word (i, nb) holds A[i][8nb ..], and layer l's N is
layer l+1's K, so A word (i, nb) = postproc(C word (i, nb)): one word per clock with 8 units, M x ceil(N/8)
clocks, channel 8nb + j in lane j. With fewer units each word takes 8 / units clocks.

**State machine** (`mlp_ctrl`): set up (the layer's K, N and slot go to `mm_core` through registers) -> start ->
wait for done -> writeback (one word per clock) -> drain -> next layer; after the last layer, done. One
writeback word made in clock c: its C read goes out in c, the word arrives in c + 2 (RL = 1 + HREAD_REG), enters
the postproc units in c + 3, comes out in c + 10 and is written into A in c + 11. The drain (RL + 7 clocks)
waits until the last word is written and the scale memory is no longer read with this layer's number; without
it most multi-layer models fail (planted bug below). Is C final when the writeback starts? The last C word is
written in the clock before `done` (traced in `mm_core`), and the first writeback read comes two clocks after
`done`, so even a 1-row, 1-block layer is safe; tested ("one row, one block per layer", "one value per layer").

**Registers** (also at the top of `mac_axi.v`):

| Offset | Name | R/W | Bits |
|---|---|---|---|
| 0x00 | CTRL | W | [0] one multiply, [1] run the model (wins over [0]) |
| 0x08 | DIMS | RW | as before, plus [25:24] weight slot a multiply uses. For a model run: M = rows, K = inputs, N = the last layer's N (RESULT_DATA steps by it) |
| 0x0C | LOAD_PTR | RW | as before, plus [25:24] weight slot that B is loaded into |
| 0x1C-0x24 | PERF_* | R | after a model run: sums over its layers |
| 0x30 | CONFIG | R | as before, plus [18] model hardware built, [19] 7-stage postproc, [22:20] weight slots, [23] HREAD_REG, [28:24] postproc units |
| 0x34 | MODEL | RW | [1:0] number of layers - 1 |
| 0x38-0x44 | LAYER0-3 | RW | [7:0] N, [8] ReLU after the layer |
| 0x48 | PARAM_PTR | RW | [7:0] channel, [9:8] layer, [16] field (0 = bias, 1 = m0 and shift) |
| 0x4C | PARAM_DATA | W | field 0: bias; field 1: [15:0] m0, [21:16] shift (1 .. 48). Then the pointer moves on (bias, scale, next channel), so a layer's scales are one stream. Dropped and flagged (LOAD_ERR) while busy |
| 0x50 | MODEL_CYCLES | R | clocks of the last model run, start to done |

C program (`load_model`, `run_model_test` in `mac_test.c`): once, for each layer: DIMS = (1, K_l, N_l),
LOAD_PTR = B in slot l, stream W_l; PARAM_PTR = (layer l, channel 0, bias), stream bias 0, {shift, m0} 0,
bias 1, ...; LAYERl = N_l | ReLU << 8; then MODEL = L - 1. For every batch: DIMS = (M, K_0, N_last),
LOAD_PTR = A, stream the rows, CTRL = 2, poll STATUS, RESULT_PTR = 0, read M x N_last values.

**Cycles** (checked in every simulated run and by `mac_test.c` on the board):

    per layer:       Np (M + 3P - 2) + 3 + PIPE + MEM_REG        (the matrix core, as before)
                     + 3                                          (set up, start, done)
    between layers:  M ceil(N/P) (P / units) + RL + PPD + 1       (writeback + drain; M ceil(N/8) + 10 here)
    MODEL_CYCLES = the sum

| 64-64-64-6 model, 250 MHz (simulation) | Model clocks | Time | Per row | Clocks in passes |
|---|---|---|---|---|
| 1 row per run | 3,194 | 12.8 us | 12.8 us | 3,128 |
| 8 rows per run | 4,258 | 17.0 us | 2.1 us | 4,080 |
| 64 rows per run | 12,770 | 51.1 us | 0.8 us | 11,696 |

[claim] ARM estimate, not measured: 8,576 multiply-adds per row, at 8.5 ns each (2,227 us for 262,144 on the
18 Oct board run) about 73 us per row. The board test measures it (it times the same model on the ARM).

**Resources (Yosys `synth_xilinx` estimate of `mac_axi` with MLP = 0 and MLP = 1, not Vivado; to check in Vivado):**

| | Step 14 (MLP = 0) | On-chip MLP (MLP = 1) | XC7Z020 |
|---|---|---|---|
| LUT (logic) | 842 | 3,874 | 53,200 |
| LUT as memory (scale memory, RAM32M x 4) | 0 | 320 | 17,400 |
| FF | 1,950 | 4,999 | 106,400 |
| DSP48E1 | 64 | 80 (2 per postproc unit) | 220 |
| Block RAM tiles | 4.5 | 7.5 (B is 16 KB) | 140 |

Most of the new logic is the 8 postproc units (each a 33-bit and a 50-bit adder, a 50-bit shifter and 7 stages
of registers). Vivado counted 1,170 LUT and 2,997 FF for the step 14 build (it includes the AXI interconnect),
so expect roughly 4,500 LUT and 6,000 FF: under 10% of the chip. If the chip version needs it smaller, the
postproc's internal widths can shrink (the shift range we use is far below 48).

**Timing risks at 250 MHz** (each one more LUT than in step 14; each can be fixed with a register without
changing a result): (1) the A write address now has a mux (loader or writeback) after the loader's address
adder; (2) the loader's write data now reaches 5 block RAMs (A and 4 for B) instead of 2, and a write-data path
into B was within 0.05 ns at 250 MHz on 17 Oct; (3) the AXI read mux has 21 registers instead of 13; (4) `start`
is OR'ed with the sequencer's start. The postproc multiply and shift were pipelined for 250 MHz, and the C read
address got its own input on the existing mux.

**Verification** (Icarus Verilog 12 and Verilator 5.020; runs with PE_PRIM = 1 use Yosys's DSP48E1 simulation model):

| Check | Result |
|---|---|
| Old tests on the new RTL: `mac.py test` (60 cases), `compare`, `saturate`, `uart`, `tb_extras`, `tb_selfcheck` | output identical to step 14, line for line |
| Lockstep: the step 14 `mac_axi` and the new one (MLP = 1) get the same random AXI traffic on the old registers, with random delays on every valid and ready | every AXI output identical in every clock: 6 seeds, 500 transactions each, 265,051 clocks |
| `postproc`, new against old with one scale per stream: every shift 0-63, both ReLU settings, extreme inputs | 115,141 values identical; the 3-stage unit also cycle for cycle |
| `postproc`, a new scale every clock (`mac.py postproc`), full input ranges | 2,000/2,000 with 3 stages and with 7 (the old unit: 942/2,000) |
| `mac.py mlp`: random whole models (1-4 layers, sizes 1-64, M 1-64, ReLU on and off, saturating scales, extreme 32-bit biases), each run twice with new inputs and the same weights; the last layer's sums, the last layer's INT8 inputs read out of A, and all four counters against Python | P = 8: 38 models; 1, 2 and 4 postproc units; 3-stage postproc with HREAD_REG 0; P = 4; P = 16 (18 models each): all 146 pass |
| The same with each PE as a DSP48E1 (the board build) | 14/14 |
| `tb_axi` (the ARM's view over AXI, Icarus) | 20/20: the 14 old tests + 6 model tests (8 rows, 1 row, PARAM_PTR stepping, a multiply from slot 2 and from slot 0 after the model, loads during a model run dropped and flagged) |
| SDK `mac_test.c` compiled on a PC and run against the RTL in Verilator (each `Xil_Out32` / `Xil_In32` an AXI transaction) | ALL BOARD TESTS PASSED (30/30): the 24 old tests + 3 model tests in each bus mode; model clocks 3,194 / 4,258 / 12,770, equal to the equation |
| Verilator `-Wall` lint | no warnings: `mm_core`, `mlp_ctrl`, `mac_axi` (MLP 0 and 1, one and two clocks, NL 1-4), `chip_top` |

**Planted bugs** (each one alone, `python mac.py mlp` with 11 models):

| Planted bug | Result | Models failing |
|---|---|---|
| writeback lanes reversed | caught | 9 of 11 models fail |
| scale memory address + 1 | caught | 9 of 11 models fail |
| scales always from layer 0 | caught | 6 of 11 models fail |
| K of every layer = DIMS.K | caught | 5 of 11 models fail |
| ReLU never applied | caught | 5 of 11 models fail |
| C word taken 1 clock early | caught | 7 of 11 models fail |
| last block of a row not written back | caught | 9 of 11 models fail |
| no drain before the next layer | caught | 9 of 11 models fail |
| per-layer done passed on | caught | simulation error: The simulation reported an error. |
| writeback reads the host's C address | caught | 7 of 11 models fail |
| weight slot ignored (always slot 0) | caught | 9 of 11 models fail |
| postproc rounds with the next shift | caught | 7 of 11 models fail |
| A word write: lane 0 only | caught | 8 of 11 models fail |

The models that still pass under a planted bug are the one-layer ones (no writeback). The drain bug fails
on data, not only on the clock count: words still in flight would use the next layer's scales.

**Build plan** (the same Vivado project, on a new branch from `try_250MHz`):
1. Pull. Tcl console: `add_files -norecurse <repo>/mac_attack_accel/rtl/mlp_ctrl.sv`, then
   `update_compile_order -fileset sources_1` (`postproc.sv` is in the project already).
2. Block design: Refresh Changed Modules on `mac`; critical warning [Coretcl 2-1280] is expected (the AXI
   address is 7 bits now). Check the `mac` block: MLP 1, NL 4, PP_LANES 0, PP_PIPE 1, HREAD_REG 1, PE_PRIM 1,
   CORE_CLK 0. Validate Design. The Address Editor range stays as it is.
3. Synthesis first: about 80 DSPs and 7.5 BRAM tiles; the step 13 Tcl check should show `bmem` as 4 RAMB36.
4. Implementation with `Performance_ExplorePostRoutePhysOpt` at 250 MHz; reports to `Alex/` as `_v10`. If it
   fails, the worst 100 paths (`report_timing -max_paths 100 -nworst 1 -unique_pins -file ...`).
5. `tb_axi` in XSim: 20/20 (14 as before + 6 model tests).
6. Export Hardware with the bitstream, update the SDK hardware platform (check `ps7_init.html` still says 250 MHz;
   section 6 if the SDK says "no changes"), build `MAC_attack_V2` Release and run it: ALL BOARD TESTS PASSED (30/30).

Not in this step: a trained model (the tests use random models whose per-channel scales are fitted to the data,
so the outputs use the whole INT8 range and some channels saturate on purpose), INT4, the chip version (its
weights would need about 2-3 mm2 of flip-flops; a Tiny Tapeout tile is about 0.016 mm2).

### Step 15b: two timing fixes for 250 MHz (agreed and written 22 Oct, not built)

**Step 15 built (22 Oct, Alex's PC).** Project `mac_attack_accel_MLP/zed/mac_zed_project`: a copy of the step 14
project (FCLK_CLK0 250 MHz, `Performance_ExplorePostRoutePhysOpt`), `rtl/mlp_ctrl.sv` added, `mac` refreshed
(defaults: MLP 1, NL 4, PP_PIPE 1, HREAD_REG 1, PE_PRIM 1, CORE_CLK 0), `core_locked` tied to a Constant 1 (section 6,
17 Oct). `tb_axi` in XSim: ALL AXI TESTS PASSED (20/20). Implementation **fails by 0.156 ns**: WNS -0.156 ns,
TNS -1.436 ns, 34 of 20,659 endpoints, WHS +0.011 ns (worst path at most 4.156 ns, floor about 241 MHz).
LUT 4,403 (4,022 logic + 381 as memory), FF 6,221, BRAM 7.5, DSP 80, power 2.180 W: what step 15 predicted
(about 4,500 / 6,000 / 7.5 / 80). The bitstream was written, but with failing timing it is not guaranteed to
compute correctly, so it is not used. Reports: `Alex/timing_summary_v10.rpt` (post-route physopt),
`Alex/utilization_v10.rpt`.

The 10 worst paths (the report lists 10 of the 34 endpoints):

| Paths | Slack (ns) | From -> to | Logic | Whose |
|---|---|---|---|---|
| 4 | -0.156 to -0.079 | `mac_axi` `axi_awready` -> protocol converter `axaddr_incr` | 5 levels (2 CARRY4), about 2.1 ns of wire | Xilinx converter's next-address adder, started by our handshake register |
| 1 | -0.113 | converter `aw_cmd_fsm` state -> `wrap_cnt_r` | 4 LUTs, 3.1 ns of wire (76%) | inside the converter |
| 1 | -0.111 | converter B FIFO `cnt_read` -> its replica | 3 LUTs, clock skew -0.42 ns | inside the converter (the replica was made by physical optimization) |
| 4 | -0.068 | `mac_axi` `pw_layer[0]` -> lane 4's bias memory, write address (RAM32M WADR3) | 0 levels, 3.3 ns of wire (88%) | ours: one register drives the write address of every lane's scale memory |

The converter paths are the ones that were closest in step 14 at 250 MHz (they passed by +0.008 ns,
`Alex/timing_summary_v9.rpt`). The MLP adds about 3,200 LUTs around them and the margin is gone. The scale-memory
path is new in step 15: the scale memory is about 80 RAM32M (LUT RAM) spread over the 8 lanes, each lane next to
its postproc DSPs, and one flip-flop in `mac_axi` drove all their write addresses.

**What changed** (rule: same 250 MHz clock, every result unchanged).

| Part | File | Change |
|---|---|---|
| Scale memory write | `rtl/mlp_ctrl.sv` | Each lane registers its own copy of the write (its enable, field, address, data: `lw_*`) and writes its LUT RAM from that copy, so each copy can be placed next to its lane. `(* keep *)` stops synthesis merging the 8 identical copies back into one. The write lands 1 clock later. Nothing can read the word in between: scale writes are dropped while busy, a model reads the scale memory only after its first layer's matrix passes, and back-to-back writes stay in order (it is a pipeline). About 8 x 39 = 312 more flip-flops. |
| AXI register slice | block design (`mac_rs`), `zed/create_zed_project.tcl` | AXI Register Slice (AXI4-Lite, every channel fully registered, `REG_* = 1`) between `axi_ic/M00_AXI` and `mac/s_axi`. No path is left from `mac_axi`'s handshake registers (`awready` and the others) into the converter, and the converter can sit next to the ARM. About +2 clocks per bus access (8 ns on about 100 ns per access); no change to any result or to `MODEL_CYCLES`. |

The converter's internal paths (2 of the 10) cannot be edited (Xilinx IP). The two changes take away the other
paths, so the converter is left alone near the ARM. If it still fails: the worst 100 paths, then a Pblock that
keeps the interconnect next to the PS7 (same clock).

**Verification of the `mlp_ctrl.sv` change** (Icarus Verilog 12, Verilator 5.020; the register slice is Xilinx IP
and is not in these simulations, `tb_axi` drives `mac_axi` directly):

| Check | Result |
|---|---|
| `mac.py mlp`, P = 8, seeds 1 and 7 | 20/20 and 28/28 models bit-exact, every counter equal to the equation |
| P = 4; P = 16 | 20/20; 14/14 |
| 2 postproc units; 1 unit; 3-stage postproc | 20/20; 14/14; 14/14 |
| `tb_axi` with each PE as a DSP48E1 (Yosys simulation model) | ALL AXI TESTS PASSED (20/20) |
| Verilator `--lint-only -Wall`, `mlp_ctrl` | no warnings |
| Planted bug: lane g writes lane g+1's memory | caught: 9 of 11 models fail (the 2 that pass have one layer, so no writeback) |

**Build plan** (the same project, `mac_attack_accel_MLP/zed/mac_zed_project`):
1. Pull. Block design: Refresh Changed Modules on `mac` (no port changes).
2. Tcl console (Vivado logs these; `create_zed_project.tcl` has the same in `build_block_design`):

        open_bd_design [get_files system.bd]
        delete_bd_objs [get_bd_intf_nets axi_ic_M00_AXI]
        set rs [create_bd_cell -type ip -vlnv [lindex [lsort [get_ipdefs -all xilinx.com:ip:axi_register_slice:*]] end] mac_rs]
        set_property -dict [list CONFIG.PROTOCOL {AXI4LITE} CONFIG.REG_AW {1} CONFIG.REG_AR {1} CONFIG.REG_W {1} CONFIG.REG_R {1} CONFIG.REG_B {1}] $rs
        connect_bd_intf_net [get_bd_intf_pins axi_ic/M00_AXI] [get_bd_intf_pins mac_rs/S_AXI]
        connect_bd_intf_net [get_bd_intf_pins mac_rs/M_AXI] [get_bd_intf_pins mac/s_axi]
        connect_bd_net [get_bd_pins ps7/FCLK_CLK0] [get_bd_pins mac_rs/aclk]
        connect_bd_net [get_bd_pins rst_fclk0/peripheral_aresetn] [get_bd_pins mac_rs/aresetn]
        assign_bd_address
        validate_bd_design
        save_bd_design
        foreach s [get_bd_addr_segs -of_objects [get_bd_addr_spaces ps7/Data]] { puts "[get_property NAME $s] [get_property OFFSET $s] [get_property RANGE $s]" }

   The last line must print `SEG_mac_reg0 0x43C00000 64K` (MAC_BASE in `mac_test.c`). `assign_bd_address` may say
   there is nothing to assign; that is fine.
3. Generate Bitstream (synthesis and implementation run again), 250 MHz, same strategy. Expect about 6,550 FF.
4. Reports to `Alex/` as `_v11`. If it fails: `report_timing -max_paths 100 -nworst 1 -unique_pins -file <repo>/Alex/timing_paths_v11.rpt`.
5. Then step 15 build plan 5-6: `tb_axi` in XSim 20/20, Export Hardware with the bitstream, SDK (BSP `MAC_attack_V2_bsp`),
   `MAC_attack_V2` Release: ALL BOARD TESTS PASSED (30/30), with no "model tests are skipped" line.

Note: `zed/create_zed_project.tcl` still sets FCLK_MHZ 200 and does not set the implementation strategy; the
tracked project (250 MHz, `Performance_ExplorePostRoutePhysOpt`) is the reference.

**Result (22 Oct, built 11:05).** Register slice in (`mac_rs`, AXI4-Lite, every channel `REG_* = 1`; address
`SEG_mac_reg0` 0x43C00000 / 64K). Timing **fails by 0.175 ns**: WNS -0.175 ns (-0.185 ns after routing, the
post-route physical optimization gained 0.010), TNS -1.556 ns, 36 of 21,261 endpoints, WHS +0.020 ns (worst path at
most 4.175 ns, floor about 239 MHz). LUT 4,470, FF 6,571 (+350, the per-lane copies), BRAM 7.5, DSP 80, power
2.182 W. Reports: `Alex/timing_summary_v11.rpt`, `Alex/utilization_v11.rpt`.

Both paths this step was for are gone: no scale-memory write address and no `mac_axi` -> converter path among the
failing ones. The next layer of paths is now on top (each was hidden below the previous worst):

| Paths | Slack (ns) | From -> to | Logic | Whose |
|---|---|---|---|---|
| 1 | -0.175 | converter `s_axburst_eq1` -> `axaddr_incr[7]` | 6 levels (2 CARRY4), 2.1 ns of wire | inside the Xilinx protocol converter |
| 3 | -0.156 to -0.069 | postproc `t5` / `sh5` -> `y6` (lanes 2 and 4) | 3 LUTs, 2.9-3.1 ns of wire (72-79%) | ours: stage 6, the 50-bit shift by 0-63 in one clock |
| 5 | -0.129 to -0.049 | postproc `y6` -> `out_q` set pins (lanes 0 and 6) | 7 levels (6 CARRY4) | ours: stage 7, the 50-bit compares of the clamp and the output select in one clock |
| 1 | -0.088 | `u_core` `perf_total` -> `sum_total` | 5 levels (3 CARRY4), 1.9 ns of wire | ours: the model's cycle sum, a 32-bit add across modules |

The step 15 resource and power numbers are unchanged, so the design is at the edge of the XC7Z020-1 at 250 MHz:
several paths of 3 or more logic levels with long wires each miss by 0.05-0.18 ns.

### Step 15c: postproc in 9 stages, counter sums from local copies (agreed and written 22 Oct, not built)

**Why.** Step 15b at 250 MHz: 8 of the 10 worst paths are in the postproc units' stage 6 (a 50-bit shift by 0-63 in
one clock: 3 LUT levels and about 3 ns of wire) and stage 7 (three 50-bit comparisons and the output choice in one
clock: 6 CARRY4), and 1 is the model's cycle sum (a 32-bit add from `mm_core`'s counter across the chip). The worst
one is inside the Xilinx protocol converter, which we cannot change (build plan step 6). Rule: same 250 MHz, every
result unchanged.

**What changed.**

| Part | File | Change |
|---|---|---|
| Postproc, 9 stages | `rtl/postproc.sv` | `PPIPE = 2` (new): stages 1-5 as `PPIPE = 1`; stage 6 shifts by `shift[5:3] x 8`, stage 7 by `shift[2:0]`; stage 8 registers the clamp's three tests (y > 127, y < 0, y < -128) and y's low 8 bits; stage 9 picks the output. Same numbers for every input: t >>> s = (t >>> 8a) >>> b for s = 8a + b (a shift past the top fills with the sign either way), and stages 8-9 are `clamp()` with its comparisons registered. `PPIPE = 0` and `1` unchanged. About 64 more flip-flops per unit (about 512 for 8). |
| Latency | `rtl/mlp_ctrl.sv` | `PPD` = 3, 7 or 9; default `PPIPE = 2`. The drain between layers is RL + PPD + 1 = 12 clocks (was 10). |
| Counter sums | `rtl/mlp_ctrl.sv` | `mm_core`'s three counters are copied every clock (`cq_*`); a layer's counts are added one clock after its done (`sum_add`), from the copies, next to the sum registers. Same sums; they are final one clock after the model's done. The host reads them many clocks later, after it has seen done in STATUS (`tb_axi` and `mac_test.c` check every sum, with random bus delays in `tb_axi`). |
| Registers | `zed/mac_axi.v` | `PP_PIPE = 2` by default; CONFIG bit 29 = 9-stage postproc (bit 19 still = more than 3 stages). |
| Board program | SDK `MAC_attack_V2/src/mac_test.c` | `pp_stages(cfg)`: 9 if bit 29, else 7 if bit 19, else 3; used in the model clock equation and the printout. Also right for older bitstreams. |
| Tests | `zed/tb_axi.sv`, `tb/tb_postproc.sv`, `tb/tb_mlp.sv`, `mac.py` | `tb_axi` takes the drain from CONFIG as `mac_test.c` does; `mac.py`: `pp_stages()`, `--ppipe 2` (default), `postproc` checks all three pipelines. |
| Docs | `zed/README.md` | CONFIG bit 29 in the register table. |

**Cycles.** Only the model's drain between layers changes: MODEL_CYCLES + 2 per layer boundary. 64-64-64-6 model
(2 boundaries): 1 row 3,194 -> **3,198**, 8 rows 4,258 -> **4,262**, 64 rows 12,770 -> **12,774** clocks. Plain
multiplies and the PERF counters are unchanged.

**Verification** (Icarus Verilog 12, Verilator 5.020):

| Check | Result |
|---|---|
| Lockstep: the new 9-stage unit against the old file's 7-stage and 3-stage units, the same inputs every clock. Directed: m0 = 1, every shift 0-63, values at every output limit and every rounding tie, both ReLU settings. Random: new acc, bias, m0, shift (0-63) and ReLU every clock, extreme values, valid 15 of 16 clocks. ACC = 22 and ACC = 32 | 842,802 outputs each, all identical; `out_valid` exactly 9 clocks after `in_valid` |
| `mac.py postproc` (a new scale every clock, full ranges) | 2,000/2,000 for 3, 7 and 9 stages; 400/400 with one scale |
| `mac.py mlp`, default (P = 8, 9 stages), seeds 1, 7, 11 | 20/20, 28/28, 28/28 models |
| P = 4; P = 16; 1, 2, 4 postproc units; 7 and 3 stages; HREAD_REG 0 | 20/20; 14/14; 14/14, 20/20, 14/14; 14/14, 14/14; 14/14 |
| `tb_axi` with each PE as a DSP48E1 (Yosys model) | ALL AXI TESTS PASSED (20/20), "9-stage postproc", model 3,542 and 2,646 clocks = equation |
| SDK `mac_test.c` compiled on a PC and run against the RTL in Verilator (each `Xil_Out32` / `Xil_In32` one AXI transaction; PE_PRIM = 0) | ALL BOARD TESTS PASSED (30/30), "9-stage postproc", model clocks 3,198 / 4,262 / 12,774 = equation |
| The same program on the step 15b RTL (7 stages) | 30/30 (it reads the stages from CONFIG) |
| The step 15b program on the new RTL | 24/30: every output right, model clocks 4 more than its equation. **Rebuild the SDK app.** |
| Old tests: `mac.py test --quick`, `saturate`, `uart 8 8 8`, `compare 32 32 32` | all pass |
| Verilator `--lint-only -Wall`: `postproc` (PPIPE 0, 1, 2), `mlp_ctrl` (PPIPE 0-2; NL 1, 2, 4 with 1 and 2 units), `mac_axi` (MLP 0 and 1 x PP_PIPE 0-2) | no warnings |

**Planted bugs** (each alone):

| Planted bug | Caught by | Result |
|---|---|---|
| Stage 9 takes ReLU one stage early | lockstep | 39,063 outputs differ |
| Stage 7 shifts by the unregistered `shift[2:0]` | lockstep | 30,653 differ |
| Stage 6 shifts by multiples of 4 | lockstep | 381,705 differ |
| Low clamp test off by one (y < -129) | lockstep | 10,371 differ |
| `out_valid` one stage early | lockstep | 232,401 differ, latency wrong |
| Counter sums never added | `mac.py mlp` | 11 of 11 models fail |
| Sums added from the copies in the done clock (one clock early) | `mac.py mlp` | 11 of 11 fail |
| `PPD` left at 7 with the 9-stage unit | `mlp_ctrl`'s own simulation check | simulation error: postproc valid and writeback token out of step |
| CONFIG bit 29 missing | SDK program against the RTL | 24/30 (model clock counts) |

**Build plan** (the same project, `mac_attack_accel_MLP/zed/mac_zed_project`):
1. Block design: Refresh Changed Modules on `mac`; double-click it: `PP_PIPE` must be 2. Validate Design.
2. Four implementation runs at once (Tcl console). impl_1 keeps `Performance_ExplorePostRoutePhysOpt`; impl_2-4 try
   other strategies, each with post-route physical optimization:

        set flow [get_property FLOW [get_runs impl_1]]
        foreach {r s} {impl_2 Performance_ExtraTimingOpt impl_3 Performance_NetDelay_high impl_4 Performance_WLBlockPlacement} {
            if {[llength [get_runs -quiet $r]] == 0} { create_run $r -parent_run synth_1 -flow $flow -strategy $s }
            set_property strategy $s [get_runs $r]
            set_property STEPS.POST_ROUTE_PHYS_OPT_DESIGN.IS_ENABLED true [get_runs $r]
        }
        reset_run synth_1
        launch_runs synth_1 -jobs 4
        wait_on_run synth_1
        launch_runs impl_1 impl_2 impl_3 impl_4 -to_step write_bitstream -jobs 4

3. Use a run with WNS >= 0 (Design Runs window): right-click it, Make Active, then Export Hardware with the bitstream.
   Reports to `Alex/` as `_v12`.
4. `tb_axi` in XSim: ALL AXI TESTS PASSED (20/20), "9-stage postproc".
5. SDK: update the hardware platform (check `ps7_init.html` says 250 MHz), rebuild `MAC_attack_V2` Release (the new
   `mac_test.c`), run: ALL BOARD TESTS PASSED (30/30), "9-stage postproc", model clocks 3,198 / 4,262 / 12,774.
6. If no run meets timing: the worst 100 paths of the best run (`open_run impl_N`, then
   `report_timing -max_paths 100 -nworst 1 -unique_pins -file <repo>/Alex/timing_paths_v12.rpt`). If only the
   protocol converter is left: step 15d, the bus (ARM, interconnect) on its own 200 MHz clock with a Xilinx AXI
   Clock Converter in front of `mac`, which stays at 250 MHz (the fallback discussed 22 Oct).

**Result (22 Oct, built 12:45, impl_1 only, `Performance_ExplorePostRoutePhysOpt`).** Timing **fails by 0.029 ns**:
WNS -0.029 ns (-0.038 ns after routing), TNS -0.088 ns, 6 of 21,824 endpoints, WHS +0.037 ns (worst path at most
4.029 ns, floor about 248 MHz). LUT 4,440, FF 7,147, BRAM 7.5, DSP 80, power 2.187 W. Reports:
`Alex/timing_summary_v12.rpt`, `Alex/utilization_v12.rpt`. The run stopped after the post-route physical
optimization (no bitstream). No postproc and no cycle-sum path fails any more. The 6 left:

| Paths | Slack (ns) | From -> to | Logic | Whose |
|---|---|---|---|---|
| 2 | -0.029, -0.008 | inside the protocol converter (`axaddr_incr`, `wrap_cnt_r`) | 4-6 levels, 2-3 ns of wire | Xilinx IP |
| 3 | -0.016, -0.013, -0.008 | `mac_axi` `rd_row` -> C block RAM read address (host read and writeback share it) | 2 LUTs, 2.5 ns of wire | ours, the same as in step 14 |
| 1 | -0.015 | C block RAM (no output register, 2.45 ns clock-to-out) -> `hq_sel` | 0 levels | ours, the same as in step 14 |

These paths were also the closest ones in step 14 at 250 MHz (`Alex/timing_summary_v8.rpt`, `_v9.rpt`), where the
post-route physical optimization closed them. At 0.03 ns this is placement, not logic: next, the four-strategy
build (build plan step 2) and the post-route optimization with `AggressiveExplore`, before any RTL change (an
output register on the C block RAM would add a clock to every C read and change the cycle equations).

**Result at 250 MHz, four strategies** (each with post-route physical optimization `AggressiveExplore`): impl_1
`Performance_ExplorePostRoutePhysOpt` -0.029 ns (unchanged), impl_2 `Performance_ExtraTimingOpt` -0.097 ns, impl_4
`Performance_WLBlockPlacement` -0.103 ns, impl_3 `Performance_NetDelay_high` not finished. 250 MHz not met.

**Result at 214.286 MHz (Alex, 22 Oct 13:18).** FCLK_CLK0 asked for 225 MHz; the Zynq gives 214.285706 MHz (Clock
Summary 214.316 MHz, period 4.666 ns). Same RTL. impl_1: WNS **+0.081 ns**, TNS 0, 0 failing of 21,781 endpoints,
WHS +0.024 ns (worst path at most 4.585 ns); impl_2 +0.061 ns, impl_4 +0.068 ns. LUT 4,402, FF 7,048, BRAM 7.5,
DSP 80, power 2.118 W. Bitstream written. Reports: `Alex/timing_summary_v13.rpt`, `Alex/utilization_v13.rpt`.
`mac_test.c` FCLK_HZ = 214285714 (CORE_HZ follows it). The worst path is now new and far from the limit of the
250 MHz build: the tool only works as hard as the clock asks (section 5, "How to read a timing result").

Board steps at 214.286 MHz: Export Hardware with the bitstream; update the SDK hardware platform and check that
`ps7_init.html` shows FCLK0 at about 214.29 MHz (section 6, 19 Oct: SDK may say "no changes"); rebuild `MAC_attack_V2`
Release; run: ALL BOARD TESTS PASSED (30/30), "9-stage postproc", model clocks 3,198 / 4,262 / 12,774, and the
clock line "measured on the board" about 214 MHz with no WARNING.

Back towards 250 MHz: the 250 MHz build's worst path was at most 4.029 ns (floor about 248 MHz), so a clock between
214 and 248 MHz should also meet timing, if the Zynq can make it (check the Actual Frequency column before building).

## 6. Problems and fixes

| Date | Problem | Fix |
|---|---|---|
| 13 Oct | Vivado 2019.1: "Please use ASCII characters for file name or path". | Move the project to a plain ASCII path. |
| 13 Oct | Re-running the Tcl script: "Project mac_zed is currently open". | Open the existing `mac_zed.xpr` instead (File > Open Project); one project per Vivado window. |
| 15 Oct | SDK "Program FPGA failed: Could not find FPGA device" (Windows in a Parallels VM). Hardware Manager showed `localhost (0)`. | Pass the Digilent and Cypress USB devices to Windows; install the Digilent cable driver from `C:\Xilinx\Vivado\2019.1\data\xicom\cable_drivers\nt64`. |
| 15 Oct | Asking FCLK for 80 MHz gave 76.929 MHz. | The Zynq PLL only makes certain frequencies; use the Actual Frequency (or the Clocking Wizard for exact values). Set `FCLK_HZ` in `mac_test.c` to the actual value. |
| 15 Oct | Board still ran at 50 MHz after the 76.9 MHz bitstream. | The PL clock is set by ps7_init from the SDK hardware platform. Re-export hardware (with bitstream), update/recreate the hardware platform, check `ps7_init.html`, check Run Configuration > Target Setup. Step-by-step procedure in section 5, step 8 (17 Oct). **Fixed** on the PC: James's 16 Oct run measured 76.45 MHz with the 76.9 MHz build, and the 18 Oct run measured 197.81 MHz with the 200 MHz build. |
| 16 Oct | Tcl report files would not write ("Directory ... does not exist"): space in "MAC Attack", and Vivado was on another machine. | Repo folder renamed to `MAC_Attack`; write reports with a path relative to the project. |
| 16 Oct | Zynq Clock Configuration "Input Frequency" was set to 100 by mistake. | Must stay 33.333333 MHz (the ZedBoard crystal). The PL clock is set under PL Fabric Clocks > FCLK_CLK0. |
| 16 Oct | `report_design_analysis -timing` failed. | Run implementation and open the implemented design first. |
| 17 Oct | `docs/log.md` on Alex's computer went back to an earlier version at 17:59 (the steps 9 + 10 entries were missing). | Restored with the next update. Reload the log in any open editor before saving it. |
| 17 Oct | Critical warning [Coretcl 2-1280] when refreshing the `mac` block. | Expected after `mac_axi.v` gains ports or parameters; check the block's parameters and connections, then continue. |
| 17 Oct | Vivado built 2 DSPs per PE from `pe.sv` with PIPE = 2 (step 11). | Step 11b: the PE written as one DSP48E1 (`zed/pe_dsp48.sv`). |
| 17 Oct | Critical warning [BD 41-759]: `/mac/core_locked` not connected, tied to 0. | Harmless with `CORE_CLK = 0` (the pin is not used). To silence it: add a Constant IP (value 1) and connect it to `core_locked`. |
| 17 Oct | Step 11b at 250 MHz: mac synthesis stopped, [Synth 8-439] module 'pe_dsp48' not found (then [Synth 8-196] and [Synth 8-6156] on `systolic_array.sv`). No implementation ran. | `zed/pe_dsp48.sv` was not in the project (`mac_zed.xpr` lists only the older files). Add it: Add Sources > design sources > `zed/pe_dsp48.sv` (do not copy into the project), or in the Tcl console `add_files -norecurse <repo>/mac_attack_accel/zed/pe_dsp48.sv` and `update_compile_order -fileset sources_1`; then Refresh Changed Modules and run synthesis again. |
| 18 Oct | After pulling the tracked project on the PC, `mac_zed.sdk` still held the PC's own old files (16 Oct `.hdf` and hardware platform at 76.9 MHz, BSP), plus old run folders (`system_auto_pc_0_synth_1/`, `system_rst_fclk0_0_synth_1/`). With the new `.gitignore` they showed up in GitHub Desktop as changes. | Export Hardware with the bitstream (overwrites the `.hdf`), let the SDK update the platform, regenerate the BSP. Do not commit the two old run folders. |
| 18 Oct | Running `zed/create_zed_project.tcl` now would delete the tracked project (`create_project ... -force` into `mac_zed_project`). | Open `mac_zed.xpr`; run the Tcl only to rebuild a broken project. |
| 21 Oct | `postproc.sv` used m0 and relu one clock after the data and shift two clocks after: right only while they stay constant. The tests held them constant (400/400 and 800/800 passed). With a new scale every clock, as one scale per output channel needs, the old unit gave 942 of 2,000 right. | m0, shift and relu now enter with the data and travel down the pipeline. Constant scales give the same results as before (115,141 values with every shift 0-63, both ReLU settings: identical, cycle for cycle). New test with a new scale every clock: 2,000/2,000 in both pipelines. |
| 21 Oct | First AXI test of the model run: 0/48 outputs right, counters right. | A testbench bug, not the hardware: the model's inputs were made but `load_matrix` sent the old A matrix. Fixed in `tb_axi.sv`; then 48/48. |
| 21 Oct | Found while testing (already in step 14, not new): DIMS with **M = 0 makes the core stay busy forever** (S_LAST waits for row M - 1, which never comes), so the ARM would poll STATUS forever. K = 0 or N = 0 finish (they count as 256 and wrap). Checked on the step 14 `mm_core`: M = 0 still busy after 200,000 clocks. | Not fixed (it would change step 14). The C program never uses 0. Open question in section 9: reject a size of 0 in `mac_axi`. |
| 22 Oct | Step 15 at 250 MHz fails by 0.156 ns (simulation passes): the Xilinx protocol converter in the AXI interconnect (it passed by only 0.008 ns in step 14) and one `mac_axi` register driving the write address of every lane's scale memory. | Step 15b: per-lane write registers in `mlp_ctrl.sv` and an AXI register slice in front of `mac` (section 5). Behavioral simulation has no wire delays: it checks the logic, timing is checked only by implementation. |
| 22 Oct | `docs/log.md` on Alex's computer lost the 11:22 entries (the step 15b build result): the file on disk was the 10:49 version again. | Written again with the step 15c entries, and the file on disk checked after writing. Cause not known (an editor saving an older copy, as on 17 Oct, or the copy to the computer). Reload the log in any open editor before saving it. |

## 7. Numbers to remember

| Quantity | Value | Source |
|---|---|---|
| Cycles per pass | M + 3P - 2 | Simulation and board (8/8 at 50 MHz, 10/10 at 200 MHz) |
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
| Timing, 200.000 MHz, step 13 (one clock) | WNS +0.259 ns, WHS +0.037 ns, 0 failing of 10,627; LUT 1,096, FF 2,792, BRAM 4.5, DSP 64; power 1.884 W | Vivado |
| Timing, 250.000 MHz, step 14 (one clock), Performance_ExplorePostRoutePhysOpt | WNS +0.008 ns, TNS 0, WHS +0.019 ns, 0 failing of 10,835; LUT 1,170, FF 2,997, BRAM 4.5, DSP 64; power 1.940 W | Vivado |
| Board, 76.93 MHz, Release build (James, 16 Oct) | 8/8; 64x64: ARM software 2,080 us, accelerator 1,509 us (1.4x); 1x64x64: ARM 32 us, accelerator 304 us (ARM 9.5x); measured clock 76.45 MHz | SDK terminal (James) |
| Board, 200 MHz, step 13 (Release build) | 10/10; 64x64: accelerator 855 us (load 320, run 27, read 508) against ARM 2,227 us (2.6x); 1x64x64: ARM 5.2x faster; measured clock 198.13 MHz | SDK terminal, 18 Oct 22:33 |
| Board, 200 MHz, Release, posted writes (new `mac_test.c`) | 24/24; 64x64: 335 us (load 61, run 27, read 245) against ARM 2,227 us (6.6x); layer, weights once, 8 rows per run: 390 us (5.7x); 30 ns per write, 60 ns per read | SDK terminal, 18 Oct 22:56 |
| Board, 200 MHz, step 13 (Debug build) | 10/10; 64x64: array 27.5 us, load 755 us, read 777 us, ARM software 11,615 us (7.5x); measured clock 197.81 MHz | SDK terminal, 18 Oct |
| Block RAM minimum clock period (XC7Z020-1) | RAMB36E1 2.576 ns (388 MHz) for the A/B buffers, 2.944 ns (340 MHz) for the C buffer's mode, so the core clock cannot go past about 340 MHz without changing the C buffer | Vivado's own Pulse Width check in the 18 Oct timing report |
| Zynq FCLK options on this board | [claim] FCLK = one PS PLL / two whole-number dividers. PLLs here: IO 1000 MHz, ARM 1333.3 MHz (CPU 666.7), DDR 1066.7 MHz (DDR 533.3). Near our range: 200 (IO/5), 213.3 (DDR/5), 222.2 (ARM/6), 250 (IO/4). The Actual Frequency in the Zynq dialog is what counts (asking 180 once gave 187.512, which this rule does not explain) | Zynq block design settings |
| Exact accumulator width | ACC >= 2*BITS + ceil(log2 MAXD): 22 bits for INT8 with MAXD = 64 (largest sum 1,048,576 = 64 x 16,384) | Proof in section 5, step 10 |
| PS-PL AXI interface, fastest clock | 250 MHz (all speed grades listed as FAXI_MAX) | Zynq-7000 data sheet DS187, Table 19 |
| Accumulator bits for K = 640 | INT4: 17, INT8: 25 | `first-rtl-results.md` (derived, check proof) |
| Data movement vs compute, 64x64 | 6.7x (simulation, ideal bus), 24.5x (board, 50 MHz, Debug), 20x (board, 76.93 MHz, Release), 56x (board, 200 MHz, Debug), 30x (board, 200 MHz, Release) | Simulation / board |
| Assumed autoencoder at P = 8, M = 1 | 264,192 MACs; 4,128 passes x 23 = 94,944 cycles | [claim] hand-computed by Claude |
| On-chip MLP clocks (step 15) | per layer Np (M + 3P - 2) + 3 + PIPE + MEM_REG + 3; between layers M ceil(N/P) (P / units) + RL + PPD + 1 (= M ceil(N/8) + 10 on the ZedBoard build) | RTL; every simulated model run |
| 64-64-64-6 model at 250 MHz | 1 row: 3,194 clocks = 12.8 us; 8 rows: 4,258 = 17.0 us (2.1 us per row); 64 rows: 12,770 = 51.1 us (0.8 us per row) | Simulation (Icarus; `mac_test.c` on the RTL in Verilator) |
| Postproc | 7 stages (PPIPE = 1) or 3; one result per clock per unit; 8 units; y = clamp(((acc + bias) m0 + 2^(s-1)) >> s) | RTL |

## 8. AI-assistance verification checklist

The professor warned: every equation needs a proof or a citation. Nothing below is trusted until ticked.

- [ ] Cycle equation T = Np (M + 3P - 2): derive from the RTL schedule. (It matches every simulation and board test so far, but that is evidence, not a proof.)
- [ ] Accumulator width w >= ceil(log2(K * 2^(2b-2) + 1)) + 1: prove, then check K = 640 gives 17 (INT4) and 25 (INT8).
- [ ] Assumed model shape 640-128-128-128-128-8-128-128-128-128-640 (DCASE baseline, from memory): check against the DCASE 2020 Task 2 baseline.
- [ ] MAC count 264,192 and 4,128 passes / 94,944 cycles: recompute.
- [x] XC7Z020 has 220 DSPs and 140 BRAM36 (and no high-speed transceivers): Xilinx selection guide.
- [ ] Exact accumulator width ACC >= 2*BITS + ceil(log2 MAXD) (22 bits for INT8, MAXD = 64): proof in section 5, step 10; team to check it.
- [x] PS-PL AXI interface at most 250 MHz: DS187 (Zynq-7000 DC and AC switching characteristics), Table 19.
- [ ] Fabric limits of the XC7Z020-1 (DSP48E1, block RAM, global clock buffer maximum frequency): look up in the data sheet. Claude quoted about 464 / 388 / 464 MHz from memory, not checked. (Block RAM: Vivado's own report gives 2.576 ns = 388 MHz, and 2.944 ns = 340 MHz in the C buffer's mode, 18 Oct; DSP and clock buffer still not checked.)
- [ ] ZedBoard audio codec ADAU1761 (I2C control, I2S audio) and its sample rates: check the ZedBoard manual and ADAU1761 datasheet.
- [ ] On-chip MLP clock equation (section 7): derive from the RTL. It matches every simulated model run so far.
- [ ] The requantize rounding in James's export is `mac.py` `requantize()` (halves up), not PyTorch's or TFLite's.

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
- "The board has only ever run at 50 MHz" (step 8, 17 Oct) and "first board run above 50 MHz" (18 Oct): James had run the 76.9 MHz build on 16 Oct (measured 76.45 MHz); it was not logged.
- "At 200 MHz the accelerator is 7.5x faster than the ARM" (Claude, 18 Oct): that was against the Debug ARM time. Against the Release ARM it is about 1.4x (76.93 MHz run; 200 MHz Release not measured yet).
- "Most of each bus word's time is ARM time, which the PL clock does not speed up", "at 200 MHz in Release expect about 1.4x" and "a clock above 200 MHz would save under 0.5% of the job" (Claude, 18 Oct, also in the Google Doc): the 200 MHz Release run gave 2.6x, because load and read got 1.7-1.8x faster with the clock. With one clock, a faster FCLK speeds up the bus too; with step 12 (bus 200 MHz, core faster) only the array speeds up.
- "Reads cannot be made faster from the ARM side" and "64x64 about 3.5x after the ARM changes" (Claude, 18 Oct): with Device memory the reads overlap and got 2x faster, and 64x64 reached 6.6x.
- "`postproc.sv` is written and tested on its own; it just is not connected yet" (Claude, 20 Oct): it was only right with one scale for the whole stream; fixed 21 Oct (section 6).
- "The writeback might read a C word before its last write lands, for M = 1 and N <= 8" (Claude, 21 Oct spec): no; the last C word is written the clock before `done`, and the first writeback read is two clocks after `done`.

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
- Why did Vivado re-run synthesis and implementation on the PC after the pull (18 Oct)? If a fresh clone always shows the runs as out-of-date, start the demo from the SDK (the hardware platform holds the bitstream), or allow a few minutes for the re-run.
- (Answered 18 Oct) Release board run at 200 MHz: 64x64x64 is 2.6x faster than the ARM, 1x64x64 is 5.2x slower.
- (Answered 18 Oct) Posted writes keep the order of start, status and results when flushed at the 4 points: 24/24 on the board.
- Next limits are in `mac_axi` (FPGA side): 6 PL cycles per write (bytes written one per clock) and about 12 per read (one read at a time, 3 wait cycles). Options: write the 4 bytes in one clock; let reads overlap; AXI DMA over an HP port for bursts.
- The dataset and the tasks (fault classes, plus an anomaly or severity output) for the multi-task MLP.
- Chip version of the on-chip MLP: 16 KB of weights in flip-flops is about 2-3 mm2 (a Tiny Tapeout tile is about 0.016 mm2): stream the weights in, or a much smaller model?
- `zed/mac_test.c` is the 13 Oct version; the SDK copy `MAC_attack_V2/src/mac_test.c` is the current one. Replace the old one?
- Reject a size of 0 (DIMS M, K or N, or a layer's N) in `mac_axi`, so a wrong value cannot hang the core (section 6, 21 Oct)?

## 10. Template for a new timeline row

| YYYY-MM-DD | What was finished (one line) | File, log, or screenshot that proves it |
