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

Later: a separate fast clock for the core (GALS, as in NVIDIA Simba).

## 6. Problems and fixes

| Date | Problem | Fix |
|---|---|---|
| 13 Oct | Vivado 2019.1: "Please use ASCII characters for file name or path". | Move the project to a plain ASCII path. |
| 13 Oct | Re-running the Tcl script: "Project mac_zed is currently open". | Open the existing `mac_zed.xpr` instead (File > Open Project); one project per Vivado window. |
| 15 Oct | SDK "Program FPGA failed: Could not find FPGA device" (Windows in a Parallels VM). Hardware Manager showed `localhost (0)`. | Pass the Digilent and Cypress USB devices to Windows; install the Digilent cable driver from `C:\Xilinx\Vivado\2019.1\data\xicom\cable_drivers\nt64`. |
| 15 Oct | Asking FCLK for 80 MHz gave 76.929 MHz. | The Zynq PLL only makes certain frequencies; use the Actual Frequency (or the Clocking Wizard for exact values). Set `FCLK_HZ` in `mac_test.c` to the actual value. |
| 15 Oct | Board still ran at 50 MHz after the 76.9 MHz bitstream. | The PL clock is set by ps7_init from the SDK hardware platform. Re-export hardware (with bitstream), update/recreate the hardware platform, check `ps7_init.html`, check Run Configuration > Target Setup. **Open.** |
| 16 Oct | Tcl report files would not write ("Directory ... does not exist"): space in "MAC Attack", and Vivado was on another machine. | Repo folder renamed to `MAC_Attack`; write reports with a path relative to the project. |
| 16 Oct | Zynq Clock Configuration "Input Frequency" was set to 100 by mistake. | Must stay 33.333333 MHz (the ZedBoard crystal). The PL clock is set under PL Fabric Clocks > FCLK_CLK0. |
| 16 Oct | `report_design_analysis -timing` failed. | Run implementation and open the implemented design first. |

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
| Timing, 187.512 MHz, step 7 (best so far) | WNS +0.416 ns, WHS +0.036 ns; LUT 2,768, FF 4,532, CARRY4 540, BRAM 6, DSP 64 | Vivado |
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

## 9. Open questions

- How many cycles does the fixed address logic add or save? (Should be zero; check PERF_CYCLES against the equation.)
- (Answered 17 Oct) 2 DSPs per PE: fixed in step 7 by building the add from LUTs; Vivado now uses 64 DSPs.
- 200 MHz: the floor at 187.5 MHz is about 203 MHz, but the 200 MHz build failed. Next candidates: the loader compares
  and the start-of-run lane masks (section 5, step 7). Or accept 187.5 MHz.
- The Arty P = 16 project: with `use_dsp` it would want 256 DSPs and the A7-35T has 90. Turn the hint off there (or set PIPE = 0).
- v2 architecture: tiling in software (simpler hardware) or keep the folding controller in hardware?
- v2 array size on the board: P = 8 or 12 (both fit in DSPs; 14 x 14 is the maximum)?
- Model size: DCASE baseline shape, or something smaller for a 64 x 64 core?
- Where are mel features computed first: PC or ARM?

## 10. Template for a new timeline row

| YYYY-MM-DD | What was finished (one line) | File, log, or screenshot that proves it |
