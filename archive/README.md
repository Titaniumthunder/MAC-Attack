# Archive

Files that are no longer used, kept for history. Nothing here is part of a build. Moved with `git mv`, so
`git log --follow <file>` still shows each file's history.

| Archived path | Was at | Moved | Why |
|---|---|---|---|
| `archive/Alex/step14/` | `Alex/step14/` | 5 Nov 2026 | Step 14 staging copies. `mm_core.sv` and `mac_axi.v` are byte-identical to design 1's `rtl/mm_core.sv` and `zed/mac_axi.v`, where step 14 was merged on 19 Oct (b8853fd). The test harness (`tb_s14.sv`, `mon_axi.sv`, `run_s14.sh`) is kept with them; `run_s14.sh` hard-codes `/home/claude/mac_work`. See `docs/log.md`, section 5, step 14 |
| `archive/mac_attack_accel/zed/mac_test.c` | `mac_attack_accel/zed/mac_test.c` | 5 Nov 2026 | The 13 Oct board program (50 MHz, 8 tests). The current one is the SDK app `mac_attack_accel/zed/mac_zed_project/mac_zed.sdk/MAC_attack_V2/src/mac_test.c` (250 MHz). No script or project used the old copy |
| `archive/mac_attack_accel_MLP/zed/mac_test.c` | `mac_attack_accel_MLP/zed/mac_test.c` | 5 Nov 2026 | The same 13 Oct file (same content). The current one is `mac_attack_accel_MLP/zed/mac_zed_project/mac_zed.sdk/MAC_attack_V2/src/mac_test.c` (214.286 MHz, model tests). `James/Python_Golden_Model/mac_test.c` is a third copy, left with James |
