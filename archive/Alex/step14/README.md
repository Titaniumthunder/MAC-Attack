# Step 14 files (one clock at 250 MHz), agreed 18 Oct 2026, not in the build yet

These are the step 14 versions of two design files, kept here so they are not lost. The Vivado
project does not use this folder. Full description and test results: `docs/log.md`, section 5, step 14.

| File | Goes to | Change |
|---|---|---|
| `mm_core.sv` | `mac_attack_accel/rtl/mm_core.sv` | (a) new parameter `HREAD_REG` (default 0 = unchanged): one more register on the host's read of C, before the lane select |
| `mac_axi.v` | `mac_attack_accel/zed/mac_axi.v` | `HREAD_REG = 1` (reads wait 4 clocks instead of 3); (b) loader flags (inside, last column, last row) kept in flip-flops, worked out one step ahead |

To use (on the `try-250MHz` branch, not on `Alex_edit`): copy the two files over the ones in the
"Goes to" column, open the project, Refresh Changed Modules on the `mac` block, set FCLK_CLK0 to
250 MHz, Generate Bitstream. In SDK `mac_test.c`, set `FCLK_HZ` to 250000000u.

Test files (Icarus Verilog 12): `tb_s14.sv` (lockstep against the step 13 design, and read logs old
against new), `mon_axi.sv` (checks the loader flags inside `zed/tb_axi.sv`), `run_s14.sh`. The step 13
files must be renamed `mac_axi_old` / `mm_core_old` for the lockstep runs.
