# Tiny-TPU RSCL model -> MAC Attack accelerator interface

`export_mac_mlp.py` reads the professor's `int4_package.json` and `golden_vectors.json` (by default from
`tinytpu/chip/test/`). It writes the model and 64 test rows for `mac_attack_accel_MLP_TinyTPU/`:

- `zed/tinytpu_vectors_pkg.sv`, for the Vivado testbench `tb_tinytpu.sv`
- `zed/mac_zed_project/mac_zed.sdk/MAC_model_TinyTPU/src/tinytpu_model.h`, for the ARM program

The script first re-runs the professor's contract and stops if a sum, logit or class differs from
`golden_vectors.json`. It also stops if the on-chip integer path differs from the contract on a golden row.
See `mac_attack_accel_MLP_TinyTPU/README.md` for how to test.

```
python tinytpu/mac_mlp/export_mac_mlp.py
```
