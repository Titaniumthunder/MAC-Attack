# Source correction — November 16, 2026

The November 14 layouts in the previous shared review were derived implementations, not the team-authored Tiny Tapeout RTL. Their measurements remain historical results for those different circuits and must not be attributed to `chip/` or `chip_v2/`.

The correct sources are `tinytpu/chip/` and `tinytpu/chip_v2/` in MAC-Attack commit `84f407a761a48e0be67ace0a56991b94e2e0295b`. These were identified explicitly by the team on November 16. All source files are preserved in `source/`; hashes are recorded in `source-hashes.json`.

| Property | Correct `chip/` | Correct `chip_v2/` |
|---|---|---|
| Processing elements | One signed INT4 MAC | Two signed INT8 MACs |
| Accumulator | 16-bit, wrapping with sticky overflow flag | 22-bit, per-PE sticky overflow flags |
| Weight storage | Host streams every input/weight pair | Host streams weights; burst mode supplies two per clock |
| Intermediate processing | Host performs scale/bias/ReLU | Shared on-chip bias/rescale/ReLU; two 32-byte ping-pong buffers |
| Model support in team tests | INT4 8→4→2 | INT8 13→32→16→4 and INT4 bypass |
| GPIO | STROBE/ACK; 4 inputs and 2 outputs on uio | All 8 uio pins inputs; command/stream/burst modes |
| Source allocation | One tile, 1×1 | Sixteen tiles, 8×2 |
| Source clock target | 50 MHz | 50 MHz |

The previous Version 1 wrapper rejected -8 operands and rejected overflow updates; the team RTL accepts -8 and wraps while flagging overflow. The previous Version 2 had a single PE, fixed weight ROM and a different controller/interface; the team RTL has two PEs and host-streamed parameters. Neither previous layout is a substitute for these source files.

The existing Version 1 build at `Titaniumthunder/RTL_3D_view` workflow `43486100045`, commit `f982bfe410917ec205a2a8505de00e5233d828c0`, has byte-identical `project.v`, `tiny_tpu_pe.v` and `info.yaml`. Its published GDS and OASIS are byte-identical to that workflow's submission artifacts. Its workflow succeeded, including gate tests and precheck, but its metrics contain 33 max-transition violations. Preserve this result as upstream evidence; a green workflow alone is not clean electrical signoff.

The local Version 2 copy adds the missing `test/Makefile`, adapted from `chip/test/Makefile`. The original RTL and Python tests are unchanged. Both original test suites passed locally: 2/2 for Version 1 and 5/5 for Version 2. Subsequent implementation results and any physical-only changes are reported separately.

## Implementation repair history

V1 now passes the 50 MHz local flow, all 15 official prechecks and both routed functional gate tests in one tile. Physical optimization uses the slow process corner and the fast corner for hold repair, with post-global-route buffering. The RTL is unchanged.

V2's original 50 MHz, 8×2-tile implementation generated GDS but failed setup timing (−3.130 ns), with 2,496 transition, 8 capacitance and 63 fanout violations. The first 25 MHz repair passes all five gate tests and all 15 prechecks, and meets setup/hold timing, but still has 222 transition and 63 fanout violations. These are genuine electrical failures despite clean DRC/LVS/antenna results. A bounded final attempt uses clock sink clusters of eight and 40% transition-repair margin. Final selected measurements are in `chip_v2/physical.json`.

The 25 MHz target changes clock-rate/throughput only. It does not change RTL arithmetic, weights, supported models, commands, or the number of clocks per operation. It halves the clock-rate ceiling compared with the requested 50 MHz; host streaming can further limit inference throughput. No relaxed electrical limits are used.

Results were generated locally with the official Tiny Tapeout support tools, LibreLane 3.0.14, and SKY130A PDK revision `8afc8346a57fe1ab7934ba5a6056ea8b43078e71`. These are local implementation/verification results, not a new green GitHub Actions run. KLayout geometry checks are provided by the separate official precheck.

The final bounded V2 repair eliminates clock-tree fanout violations and reduces electrical failures to **32 transition and 2 data-net fanout violations**. Worst transition is **0.886521 ns against the unchanged 0.750 ns limit**. The two remaining fanout nets drive 11 loads against the limit of 10. Drivers implicated include `fanout36`, `fanout1883`, `_07962_`, and `fanout1650`; excessive fanout remains at `fanout1652/X` and `fanout395/X`. See `chip_v2/remaining-electrical.txt`. V2 therefore remains a diagnostic layout, not an electrically signed-off submission.

The immediate next work is targeted buffering/driver sizing of those data/control nets, followed by routing, extracted STA, DRC/LVS/antenna checks and gate tests again. Reducing model layers or quantization is not yet justified by these failures: the full team RTL fits the 16-tile outline. If the team later chooses to serialize the rescaling multiplier or shrink hardware buffers, throughput/host traffic would change and require explicit design review and new verification; no such behavior changes were made here.
