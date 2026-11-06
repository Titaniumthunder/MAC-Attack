# Archive

Files that are no longer used, kept for history. Nothing here is part of a build. Moved with `git mv`, so
`git log --follow <file>` still shows each file's history.

| Archived path | Was at | Moved | Why |
|---|---|---|---|
| `archive/Alex/step14/` | `Alex/step14/` | 5 Nov 2026 | Step 14 staging copies. `mm_core.sv` and `mac_axi.v` are byte-identical to design 1's `rtl/mm_core.sv` and `zed/mac_axi.v`, where step 14 was merged on 19 Oct (b8853fd). The test harness (`tb_s14.sv`, `mon_axi.sv`, `run_s14.sh`) is kept with them; `run_s14.sh` hard-codes `/home/claude/mac_work`. See `docs/log.md`, section 5, step 14 |
