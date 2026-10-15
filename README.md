# MAC Attack

A folded, quantized systolic MAC array accelerator (a "mini TPU").

**Application: Machine Guardian** — machine-sound anomaly detection running on a ZedBoard.

## Folder map

```
.
├── mac_attack_accel/        Main project (see mac_attack_accel/README.md)
│   ├── rtl/                 SystemVerilog RTL (PE, systolic array, mm_core, host_if, UART, chip_top)
│   ├── tb/                  Testbenches
│   ├── mac.py               Python golden model
│   ├── fpga/                Arty A7 top, constraints, synth/bitstream Tcl
│   ├── zed/                 ZedBoard AXI wrapper, test C code, create_zed_project.tcl
│   ├── vivado/              create_project.tcl for the standalone Vivado project
│   └── openlane/            OpenLane / SKY130 chip config and sources
├── docs/                    Project brief and shared documents
├── Alex/                    Alex's working area
├── James/                   James's working area
└── Marco/                   Marco's working area
```

## Who owns what

| Person | Areas |
|--------|-------|
| Alex   | RTL / architecture, board bring-up (ZedBoard), chip interface spec, board results |
| James  | Verification (Python golden model), ML track (DCASE data, training, INT8/INT4 quantization), equation proofs |
| Marco  | Physical design (OpenLane / SKY130), fabrication research, power measurement |

## Rules

1. **Pull before you start, push when you finish.**
2. **Vivado project folders are generated — never commit them.** `zed/mac_zed_project/` and
   `vivado/mac_attack_project/` are rebuilt by the Tcl scripts (e.g. `zed/create_zed_project.tcl`).
   They are already in `.gitignore`.
3. **Clone to a short path with no spaces or non-ASCII characters** (e.g. `C:\work\mac_attack`).
   Vivado 2019.1 rejects non-ASCII paths, and spaces cause trouble with Tcl scripts.
4. **Large files go to Google Drive, not git** — datasets (DCASE audio), big weight files, etc.
