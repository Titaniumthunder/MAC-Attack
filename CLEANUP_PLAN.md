# Repo cleanup plan (Phase 1, read-only)

Branch `cleanup/repo-organization`, created from `main` (ee9b175) on 5 Nov. Nothing is changed or committed yet.
The 52 uncommitted Vivado changes from `MLmodel` came along unchanged (all in
`mac_attack_accel_MLP/zed/mac_zed_project/`). Phase 2 commits name their paths explicitly (never `commit -a`), so
these 52 stay as they are.

## 0. Decisions needed before Phase 2

| # | Question | Evidence | Options |
|---|---|---|---|
| Q1 | Base branch | `MLmodel` is 8 commits ahead of `main` (model exports, Paderborn, OpenLane 250 MHz, step 16). `Alex_edit` 9793402 (24 Oct MLP board run, 30/30 at 214.286 MHz) is on no remote branch and conflicts with `main`'s `docs/log.md` | (a) `main` as instructed; this plan avoids every file `MLmodel` touches. (b) First merge 9793402 into this branch (needs your OK; the conflict is in `docs/log.md` only) |
| Q2 | README rule 2 ("only project sources are committed") vs reality | `.gitignore` re-includes `mac_zed.runs/`, `mac_zed.hw/`, `*.bit`, `*.hdf`, `mac_zed.sdk/*`, per the 18 Oct decision (log.md:102). Tracked: 239.5 MB in 60 files over 1 MB, all in the two `mac_zed_project/` folders. Design 1 also tracks its BSP (347 files) | (a) Rewrite rule 2 to match `.gitignore` (recommended; no file leaves git). (b) Stop tracking build output: that removes files from git, so it is not in this plan |
| Q3 | Which model export is current | Section 3 below. On `main` only `model/export/E3/` exists | Needs Alex's decision |
| Q4 | log.md:104 wording ("the second clock waits for a faster board") | Its own reasons don't depend on the board. See F5 | Approve the proposed note, or give your own wording |
| Q5 | Running `rtl_check.py` | `model/.venv` doesn't exist on this PC (the README command is the macOS form). It needs torch 2.14.1, scipy and scikit-learn (`model/requirements.txt`). No planned change touches `model/` or `mac_attack_accel_MLP/mac.py`, its only inputs | (a) You run it on your Mac. (b) A throwaway venv outside the repo. (c) Skip |

## 1. Folder map (tracked: 1,450 files, 288 MB)

| Folder | What it is | Files / size | In this plan |
|---|---|---|---|
| `Alex/` | Alex's area: 33 Vivado report copies (`*.rpt`), `step14/` staging files | 40 / 3.1 MB | `step14/` to archive (M1); `.rpt` kept |
| `James/` | Golden model, test vectors | 40 / 0.2 MB | not touched |
| `Marco/` | OpenLane results, 19 Oct | 4 / 32 KB | not touched |
| `docs/` | `log.md` (the one log, 2,074 lines), brief, model report PDF, dataflow page | 4 / 1.1 MB | text fixes |
| `mac_attack_accel/` | **Design 1:** 250 MHz matrix multiplier, step 14, ran on the board 24/24. Current (log.md:111) | 685 / 84 MB | kept; doc fixes; old `zed/mac_test.c` to archive (M3) |
| `mac_attack_accel_MLP/` | **Design 2:** on-chip MLP, step 15c, 214.286 MHz | 608 / 197 MB | doc fixes; old `zed/mac_test.c` to archive (M2) |
| `model/` | Machine Guardian model (Ottawa). Imports `mac_attack_accel_MLP/mac.py` | 66 / 2.2 MB | not touched (Q3) |

## 2. Protected (not moved, renamed or regenerated)

- `mac_attack_accel_MLP/zed/mac_zed_project/` (all of it); `mac_attack_accel_MLP/rtl/*.sv`, `zed/mac_axi.v`,
  `zed/pe_dsp48.sv`, `zed/create_zed_project.tcl`, `zed/mac_zed_cdc.xdc`.
- `mac_attack_accel/zed/mac_zed_project/`: archive only as a whole and only with approval. **Not proposed:**
  design 1 is current, and the MLP project points into this folder (N3).
- `model/.venv`, datasets, OpenLane run folders, `James/`, `Marco/`, `mac_zed.runs`, `mac_zed.hw`, `*.bit`, `*.rpt`.

## 3. Model export: evidence for Alex's decision (no change made)

| Export | Branch | Task | Status in the repo | Test result (development numbers, the test split was seen) |
|---|---|---|---|---|
| `E3` (seed 42, 22 inputs) | main, MLmodel | Ottawa healthy/faulty | **[proposed], Alex to confirm** (log.md:118, :1862; model/README.md:57). `rtl_check.py` and `export.py` default to it | INT8: 27/28 faults, 0/4 false alarms, F1 0.982 (log.md:1962) |
| `E3_single_accel_a1` | MLmodel | Ottawa, accelerometer 1 only | "Deployed", decided 28 Oct "by the team (James), after the test results" (`weights/E3_single_accel/deployed.json`); not in log.md | 28/28, 0 false alarms; "not an unbiased estimate" (same file) |
| `E3_single_accel_a2` | MLmodel | Ottawa, accelerometer 2 | Chosen by the validation rule, overridden (`deployed.json`) | INT8 25/28, F1 0.943 |
| `MTL_run3` | MLmodel | Paderborn multi-task | "SUPERSEDED (v1): do not use" (its README:1) | - |
| `MTL_run3_v2` (E) | MLmodel | Paderborn multi-task | "(selected)" but "Not frozen; not evaluated on the locked test bearings; ... not on the ZedBoard" (README:1-5); 5 seeds, none picked; health head untrained | F1 0.923, recall 0.857 (run 3 report) |
| `MTL_run3_v2_C` | MLmodel | same, with temperature | "statistically indistinguishable" from E | same row-level metrics |

- log.md:112 records Alex's 27 Oct switch to Ottawa ("decided (Alex)"). Nothing records a switch back to Paderborn.
- The `MLmodel` copy of `model/README.md` contradicts itself: line 57 says E3 is "[proposed]", line 74 says a1 is "Deployed".
- No board code uses any export yet: the SDK `mac_test.c` builds a random 64-64-64-6 model.
- **Questions for Alex:** which task (Ottawa or Paderborn); which export; which seed (if MTL); then update log.md and
  `model/README.md` on `MLmodel` (not here, to avoid a conflict).

## 4. Moves (`git mv` only)

| # | Old path | New path | Reason (evidence) | References to update |
|---|---|---|---|---|
| M1 | `Alex/step14/` (6 files) | `archive/Alex/step14/` | `mm_core.sv` and `mac_axi.v` are byte-identical to design 1's `rtl/mm_core.sv` and `zed/mac_axi.v` (merged 19 Oct, b8853fd). README line 1 "not in the build yet" is stale. `run_s14.sh` hard-codes `/home/claude/mac_work` and cannot run here | log.md:930 (path); log.md:54 (if it names the folder); `archive/Alex/step14/README.md` header note |
| M2 | `mac_attack_accel_MLP/zed/mac_test.c` | `archive/mac_attack_accel_MLP/zed/mac_test.c` | The 13 Oct 50 MHz program (184 lines, `FCLK_HZ` 50 MHz). The current one is the SDK `MAC_attack_V2/src/mac_test.c` (674 lines, 214.285714 MHz). No Tcl, `.xpr` or script uses it | MLP `zed/README.md`:25, :142; MLP `README.md`:24; `README.md`:82; log.md:1508 (answers that open question) |
| M3 | `mac_attack_accel/zed/mac_test.c` | `archive/mac_attack_accel/zed/mac_test.c` | Same file (same blob), design 1's current program is its SDK V2 (467 lines, 250 MHz) | d1 `zed/README.md`:25, :142; d1 `README.md`:23; `README.md`:82 |
| M4 | (new) | `archive/README.md` | What is archived, from where, why, and when | - |

`James/Python_Golden_Model/mac_test.c` (the same file) stays: it's James's, and his golden model refers to it.

**Not moved, with the reason:**

| Candidate | Why it stays |
|---|---|
| `MAC_Attack_V1/` SDK app (both projects; unused, 0 references, BSP `standalone_bsp_0` missing) | Inside the protected project folders (whole-folder rule). Remove it from the SDK workspace yourself if you want |
| Design 1 `system_wrapper_hw_platform_1/` (8 of 9 files equal `_0`, 8 MB) | Same rule; the SDK `.metadata` still uses it |
| `Alex/*.rpt` (33 files) | Generated reports; log.md cites them on 48 lines |
| 19 files identical in both designs | Each design is self-contained (relative `.xpr` paths) |
| `mac_attack_accel/` as a whole | Current design; the MLP `.xpr` points into it (N3); `MLmodel` changes 7 of its files |

## 5. Doc fixes (only claims checked against code; anything unverifiable becomes "TODO: confirm")

| # | File | Line: now -> fixed (evidence) |
|---|---|---|
| F1 | `mac_attack_accel_MLP/zed/README.md` | 14, 106: FCLK_CLK0 "50 MHz" -> asked 225, actual 214.285706 MHz (`system.bd`, ps7 xci; SDK `FCLK_HZ` 214285714). 123, 236: "at 50 MHz" -> 214.286 MHz (impl_1 WNS +0.081 ns). 162: "32-bit sums ... 50 MHz" -> what the program prints now (22-bit sums, 214.29 MHz; SDK c 624-640). 177: "/ 50 MHz" -> "/ CORE_HZ". 244: mark as history. 22: "12 registers" -> 21 (0x00-0x50, `mac_axi.v` 160-165). 80: tb prints 22, not 32. 92: 12/12 -> 20/20. 95: "about 1.54 ms" -> TODO: confirm. 25, 142: path -> SDK `MAC_attack_V2/src/mac_test.c`. 27-31: status (20/20, 30/30 against the RTL, built at 214.286 MHz). 38-46: this project tracks no `.hdf`, hardware platform or BSP (N2). 62-64: the Tcl rebuilds at 200 MHz, not the committed clock (N1). 15-16, 111-112: add the register slice `mac_rs`, `mlp_ctrl` and the `core_locked` constant. 132-155: add a note that this project uses the 2019.1 `.hdf` + Xilinx SDK flow and that the Vitis steps apply to 2020.1 and later only. 168: array 110 us -> 25.7 us (5,504 / 214.286 MHz). 170: 8/8 -> 30/30. 183-187: board numbers: TODO (the 24 Oct board run is only on `Alex_edit`, Q1). 196: STATUS bit 3, two-clock builds only. 207: CONFIG bit 16 "(two-clock mode: simulated, never built)". 211: PARAM_DATA is dropped and flagged while busy |
| F2 | `mac_attack_accel/zed/README.md` | The same lines with design 1 values: 250.000 MHz, 13 registers, 14/14, 24/24 on the board, 64x64 array 22.0 us. Add the missing 0x30 CONFIG register. 204: PERF_TOTAL = PERF_CYCLES + 7, not + 3 (`mac_axi.v` 27). Section 0 (`.hdf`/BSP tracked) is correct here |
| F3 | `README.md` | 12: the MLP project is not "the same 250 MHz settings": FCLK asked 225 -> 214.286 MHz, plus `mac_rs`, step 15c. 45-48, 79-81: rule 2 and the BSP line rewritten per Q2. 5, 39, 51: "machine-sound / DCASE" -> Ottawa motor vibration (log.md:112). 82: new `mac_test.c` paths (M2, M3) |
| F4 | `mac_attack_accel/README.md`, `mac_attack_accel_MLP/README.md` | 3: 16x16 / 32-bit is `chip_top`; the ZedBoard build is 8x8 with 22-bit sums. 19-20: "not yet built" -> built. 23/24: test counts (D1 14/14, 24/24; D2 20/20, 30/30). 76/77: `tb_selfcheck` perf_total + 5, not + 3 (`mm_core.sv` 56, defaults PIPE 1, MEM_REG 1). 214/216: "Nothing has run on a board yet" -> ZedBoard runs since 15 Oct. Arty 100 MHz (doc vs doc) -> TODO: confirm |
| F5 | `docs/log.md` | **Two-clock caveat** "(written and simulated in `tb_axi`, 15/15; not built in Vivado, not run on the board)" at 92, 99-101, 514, 822-838, 896, 995-1017, 1491. 1512: wrong per code (CORE_CLK = 1 drops the MLP, `mac_axi.v`:167), so fix it. **92 vs 104:** add a dated note under 104 (Q4), proposed text: "Step 12 is deferred, not waiting on hardware: two clocks help only the FPGA build (Tiny Tapeout has one clock pin) and compute is about 8% of a 64x64 run; revisit if a faster FPGA is bought (20 Oct, line 61)." **Stale:** 125 "tb_axi 12/12" -> 14/14 / 20/20; 143 "Not merged into `Alex_edit` yet" -> merged; 305 stale "not built" row; headings 653, 767, 841, 898, 1019, 1171, 1266 "not built" -> add "(built later: see row ...)". Old entries are kept, notes are added. 1085-1092: add the 15c numbers 3,198 / 4,262 / 12,774 (section 7 is already right). 1423: "+ 6" -> "+ 7". 1429: "best so far" -> superseded by step 14. 1017: 10/10 -> 24/24 / 30/30. 1155: path -> `mac_attack_accel_MLP/rtl/mlp_ctrl.sv`. 2055: path -> `docs/Machine_Guardian_model_report.pdf`. 960: `try-250MHz` -> `try_250MHz`. 1441: `first-rtl-results.md` is not in the repo -> TODO: confirm. 1508: answered by M2/M3 |
| F6 | `Alex/README.md`, `archive/Alex/step14/README.md` | "Shared source goes in `mac_attack_accel/`" -> both design folders. step14 line 1: "merged into design 1 on 19 Oct (b8853fd)"; line 11: `try_250MHz` |

**Skipped (not mine to edit, or conflict risk):** `James/README.md`:5, 8 and `Marco/README.md`:8 (same stale
lines: tell James and Marco). The OpenLane READMEs, line 62 "Not run through OpenLane yet", contradict
`Marco/openlane_results/` (Marco's area, and `MLmodel` changes `openlane/`). `model/README.md` (Q3, `MLmodel`
changes it). Unverifiable numbers in the zed READMEs (bus clocks, "26234 / 8976", "7.0x") become "TODO: confirm".

## 6. Needs Alex (no action from me)

| # | Item | What to do |
|---|---|---|
| N1 | `create_zed_project.tcl:24` `set FCLK_MHZ 200`, but the 214.286 MHz build asked for **225** (ps7 xci `PCW_FPGA0_PERIPHERAL_FREQMHZ` 225, actual 214.285706). Design 1's copy also says 200; its build is 250 | Proposed: MLP `set FCLK_MHZ 225 ;# the Zynq gives 214.285706 MHz (IO PLL 1500 / 7); FCLK_HZ 214285714 in mac_test.c`. Design 1: 250. The script is not run. Protected file, your edit |
| N2 | The MLP project has **no `.hdf`** (none tracked, none on disk). Design 1 has three | In Vivado with the MLP project: File > Export > Export Hardware, include bitstream, into `mac_zed.sdk/`. `.gitignore` already tracks `*.hdf` |
| N3 | **The MLP `.xpr` points into design 1's folder:** line 24 `IPOutputRepo` = `C:/Users/alexsalamati/Xilinx/Lab/MAC-Attack/mac_attack_accel/zed/mac_zed_project/mac_zed.cache/ip`, line 29 `IPUserFilesDir` = `$PPRDIR/../../../mac_attack_accel/...`. Design 1's own `.xpr` uses `$PCACHEDIR/ip` and `$PIPUSERFILESDIR`. Cause: I copied design 1's project into the MLP folder on 21 Oct. Effect: the MLP build writes IP output into design 1's folder, and archiving design 1 would break it | In Vivado with the MLP project: Settings > IP > set the IP cache and IP user-files locations to this project's own `mac_zed.cache/ip` and `mac_zed.ip_user_files`. To find the Tcl property names: `report_property [current_project]` (TODO: confirm the names in 2019.1). Then commit the `.xpr` |
| N4 | The two-clock mode has no "not built" caveat in protected code comments (`mac_axi.v`, Tcl lines 26-27 and 97-109). The MLP Tcl doesn't warn that `CORE_MHZ > 0` drops the MLP | Your edit if you want it |
| N5 | 9793402 on `Alex_edit` (24 Oct MLP board run, measured ARM model time 84.6 us per row) is on no remote | Q1 (b), or push `Alex_edit` again |

## 7. Commits and checks (Phase 2, only approved items)

| Commit | Content | Check |
|---|---|---|
| C1 | M1 + M4 (archive `Alex/step14/`, add `archive/README.md`) + log.md:54/930 paths | `git grep -n "Alex/step14"` shows only `archive/` and the updated lines |
| C2 | M2 + M3 (archive the old `mac_test.c` copies) + the READMEs that point to them | `git grep -n "zed/mac_test.c"` shows none outside `archive/` and the log's history |
| C3-C8 | F1 ... F6, one file group per commit | Each changed number re-read from its code line |
| End | - | `git status`: only the 52 Vivado files unstaged. No RTL, tb, Tcl or `.xpr` path changes. Optional smoke test: `mac.py test --sim icarus` (Icarus 13 now installed) and `tb_axi` in XSim with `--relax` in both designs. `rtl_check.py` per Q5. Then `git log --oneline main..HEAD`, `git diff --stat main` |
