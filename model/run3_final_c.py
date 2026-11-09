"""Training Run 3: the alternative deployment candidate C_wd_slog (weight decay 0.01, log-compressed inputs, temperature input
USED), trained on all 7 development bearings, exported and RTL-checked like the selected E (3 Nov 2026).

  python run3_final_c.py   -> results/supervised/run3/train_alt_C/, results/supervised/run3/hardware_alt_C/,
                              export/MTL_run3_v2_C/          (refuses to overwrite)

Why: the pre-declared selection rule chose E_wd_slog_noT (temperature input fed as 0) by a margin inside the noise
(mean unlatched alarm-state changes 2.80 vs 2.86 over the 7 folds; the nested selection chose C on 4 of 7 outer folds).
The project specification keeps temperature as an input, so C is provided as the equivalent alternative with temperature.
Nothing here changes the selection or any Run 3 result; C's held-out (outer) results are already in train/results.json.
"""
import json

import numpy as np
import pandas as pd
import torch

import run3_hardware as hwmod
import train_deterioration_run3 as r3

CFG = "C_wd_slog"
OUT = r3.OUT.parent / "train_alt_C"
HWO = r3.OUT.parent / "hardware_alt_C"
EXP = r3.EXPORT.parent / "MTL_run3_v2_C"


def main():
    if OUT.exists() or HWO.exists() or EXP.exists():
        raise SystemExit("output exists: not overwritten")
    r3.load_data()
    OUT.mkdir(parents=True)
    HWO.mkdir(parents=True)
    rows, final = [], []
    Xall = np.concatenate([r3.inputs(e, r3.CONFIGS[CFG]) for e in r3.BEARINGS])
    Q0 = None
    for s in r3.SEEDS:
        net, _, last = r3.fit(CFG, r3.BEARINGS, s)
        torch.save(net.state_dict(), OUT / f"{CFG}_all7_seed{s}.pt")
        final.append({"cfg": CFG, "seed": s, "final_train_loss": last,
                      "weights_sha256": __import__("hashlib").sha256((OUT / f"{CFG}_all7_seed{s}.pt").read_bytes()).hexdigest()})
        net = hwmod.load(OUT / f"{CFG}_all7_seed{s}.pt", s)
        for e in r3.BEARINGS:
            Q = hwmod.quantize(net, CFG, r3.BEARINGS, r3.inputs(e, r3.CONFIGS[CFG]))
            rows.append({"cfg": CFG, "seed": s, "bearing": e, **hwmod.compare(Q, e)})
        Qa = hwmod.quantize(net, CFG, r3.BEARINGS, Xall)
        hwmod.export(Qa, CFG, s, EXP / f"seed{s}")
        if s == 0:
            Q0 = Qa
    pd.DataFrame(rows).to_csv(HWO / "int8_final_in_sample.csv", index=False, float_format="%.6g")
    rtl = hwmod.rtl(Q0, 24)
    summary = {"cfg": CFG, "final": final, "rtl_seed0": rtl, "int8_decisions_changed": int(pd.DataFrame(rows).decisions_changed.sum()),
               "int8_rows": int(pd.DataFrame(rows).rows.sum()),
               "int8_labelled_changed": int(pd.DataFrame(rows).decisions_changed_labelled.sum()), "exported": str(EXP),
               "note": __doc__.split("Why:")[1].strip()}
    (HWO / "hardware.json").write_text(json.dumps(summary, indent=1, default=str) + "\n", encoding="utf-8")
    print(json.dumps({k: v for k, v in summary.items() if k not in ("final", "note")}, indent=1, default=str))


if __name__ == "__main__":
    main()
