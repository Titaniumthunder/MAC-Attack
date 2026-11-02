"""Experimental anomaly-detection baseline on the Paderborn experiments (normal vs abnormal; NOT deterioration).

  python anomaly_baseline.py                 every experiment in results/paderborn/ (run paderborn.py first)
  python anomaly_baseline.py B01 B03

Design (fixed 1 Nov 2026 before any score was computed; nothing below is tuned on the results):
  Reference ("commissioning")  each bearing's first REF_N = 100 operating (non-warm-up) measurements, about 30 min.
                               Everything is fitted on this period only, per bearing, as a new motor would be
                               calibrated on its own first half hour.
  Features (one accelerometer) F128: ln RMS, ln peak, kurtosis, crest, ln RMS 1-5 kHz, ln 5-20 kHz, ln 20-64 kHz
                               F42:  the same at 42.67 kHz: ln lr_RMS, ln lr_peak, lr_kurtosis, lr_crest,
                                     ln 1-5 kHz, ln 5-20 kHz (the bands a 42-kHz chain can still see)
  Condition normalization      per feature, least squares on the reference: f = b0 + b . c, with c one of
                               none | speed (ln measured rpm) | speed+T (+ T1) | speed+load (+ static, dynamic peak)
                               | speed+load+T; z = (f - fit) / sigma_ref
  Score                        s = sqrt(mean_j z_j^2) (RMS of the feature z, as health.py's H1)
  Threshold                    tau = the 99th percentile of the reference scores
  Alarm                        "persistent" from the first measurement that starts RUN = 3 consecutive s > tau;
                               single exceedances are counted, not alarmed
  Primary configuration        what the final hardware can measure: rear accelerometer (A), F128, speed-only.
                               The other channel, F42, temperature and load are variants for the questions in the
                               report; the primary result does not change with them.
  Cross-bearing (leave-one-bearing-out) check: normalization and tau fitted on the reference of every OTHER bearing,
  applied to the held-out bearing without using its own data ("global" model), against the per-bearing ("commissioned")
  model.

Reported, label-free: false exceedances inside each bearing's reference and in the period after it before the first
persistent alarm; the first persistent alarm; how far scores go afterwards; lead time to the logged stop. The data have
no confirmed deterioration labels, so nothing here is a detection rate or a health value.

Writes results/paderborn/anomaly/baseline.json, scores_<EXP>.csv, figures/*.png.
"""
import json, sys
from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import matplotlib.dates as mdates
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

from paderborn import HERE, META, load

ROOT = HERE / "results" / "paderborn"
OUT = ROOT / "anomaly"
REF_N, Q, RUN = 100, 99, 3
FSETS = {"F128": [("rms", True), ("peak", True), ("kurt", False), ("crest", False), ("band_1k_5k", True),
                  ("band_5k_20k", True), ("band_20k_64k", True)],
         "F42": [("lr_rms", True), ("lr_peak", True), ("lr_kurt", False), ("lr_crest", False), ("band_1k_5k", True),
                 ("band_5k_20k", True)]}
CONDS = {"none": [], "speed": ["ln_speed"], "speed+T": ["ln_speed", "T1_C"], "speed+load": ["ln_speed", "stat_kN", "dyn_kN"],
         "speed+load+T": ["ln_speed", "stat_kN", "dyn_kN", "T1_C"]}
PRIMARY = ("A", "F128", "speed")
BLUE, ORANGE, AQUA, MUTED, INK2 = "#2a78d6", "#eb6834", "#1baf7a", "#8a8984", "#52514e"
plt.rcParams.update({"font.family": "DejaVu Sans", "font.size": 9, "axes.spines.top": False, "axes.spines.right": False,
                     "axes.grid": True, "grid.color": "#e4e3df", "legend.frameon": False, "axes.edgecolor": MUTED})


def prepare(d):
    d = d[~d["warmup"]].reset_index(drop=True).copy()
    d["ln_speed"] = np.log(d["speed_rpm"])
    d["stat_kN"] = d["stat_N"] / 1000
    d["dyn_kN"] = d["peakDyn_N"] / 1000
    d["ref"] = np.arange(len(d)) < REF_N
    return d


def feats(d, ch, fset):
    cols = []
    for name, lg in FSETS[fset]:
        v = d[f"acc{ch}_{name}"].to_numpy()
        cols.append(np.log(v) if lg else v)
    return np.column_stack(cols), [f"{'ln ' if lg else ''}{n}" for n, lg in FSETS[fset]]


def fit(d_ref, ch, fset, cond):
    F, names = feats(d_ref, ch, fset)
    X = np.column_stack([np.ones(len(d_ref))] + [d_ref[c].to_numpy() for c in CONDS[cond]])
    B, *_ = np.linalg.lstsq(X, F, rcond=None)
    R = F - X @ B
    sig = R.std(axis=0)
    r2 = 1 - (R ** 2).sum(axis=0) / ((F - F.mean(axis=0)) ** 2).sum(axis=0)
    model = {"B": B, "sigma": np.where(sig > 1e-12, sig, 1.0), "ch": ch, "fset": fset, "cond": cond, "names": names,
             "r2": r2}
    model["tau"] = float(np.percentile(score(d_ref, model)[0], Q))
    return model


def score(d, m):
    F, _ = feats(d, m["ch"], m["fset"])
    X = np.column_stack([np.ones(len(d))] + [d[c].to_numpy() for c in CONDS[m["cond"]]])
    Z = (F - X @ m["B"]) / m["sigma"]
    return np.sqrt((Z ** 2).mean(axis=1)), Z


def first_persistent(s, tau, start):
    above = s > tau
    for i in range(start, len(s) - RUN + 1):
        if above[i:i + RUN].all():
            return i
    return None


def evaluate(d, s, tau, exp):
    ref = d["ref"].to_numpy()
    i0 = first_persistent(s, tau, REF_N)
    pre = slice(REF_N, i0 if i0 is not None else len(s))
    stop = META["experiments"].get(exp, {}).get("log_end")
    out = {"tau": tau, "ref_exceed": int((s[ref] > tau).sum()), "ref_n": int(ref.sum()),
           "post_ref_pre_alarm_n": int(pre.stop - pre.start), "post_ref_pre_alarm_exceed": int((s[pre] > tau).sum()),
           "first_alarm": None}
    if i0 is not None:
        r = d.iloc[i0]
        after = s[i0:]
        out["first_alarm"] = {"measurement_id": int(r.measurement_id), "timestamp": str(r.timestamp),
                              "operating_min": float(r.operating_min), "T1_C": float(r.T1_C),
                              "fraction_alarmed_after": float((after > tau).mean()),
                              "median_score_after_over_tau": float(np.median(after) / tau),
                              "minutes_before_last_record": float((d.timestamp.iloc[-1] - r.timestamp).total_seconds() / 60)}
        if stop:
            out["first_alarm"]["minutes_before_log_end"] = float((pd.Timestamp(stop) - r.timestamp).total_seconds() / 60)
    return out


def figures(data, res):
    OUT.joinpath("figures").mkdir(parents=True, exist_ok=True)
    exps = list(data)
    # 1. primary score over time, per bearing
    fig, axs = plt.subplots(len(exps), 1, figsize=(9, 2.9 * len(exps)))
    axs = np.atleast_1d(axs)
    for ax, e in zip(axs, exps):
        d = data[e]
        m = fit(d[d.ref], *PRIMARY)
        s, _ = score(d, m)
        ax.plot(d.timestamp[d.ref], s[d.ref], ".", ms=3.5, color=AQUA, label="reference (first 100)")
        ax.plot(d.timestamp[~d.ref], s[~d.ref], ".", ms=3.5, color=BLUE, label="monitored")
        ax.axhline(m["tau"], color=INK2, linewidth=0.9, linestyle="--")
        fa = res["experiments"][e]["primary"]["first_alarm"]
        if fa:
            ax.axvline(pd.Timestamp(fa["timestamp"]), color=ORANGE, linewidth=1.2)
            ax.text(pd.Timestamp(fa["timestamp"]), m["tau"] * 1.15, f" first persistent alarm M{fa['measurement_id']:04d}",
                    color=INK2, fontsize=8)
        stop = META["experiments"].get(e, {}).get("log_end")
        if stop:
            ax.axvline(pd.Timestamp(stop), color=MUTED, linewidth=0.9, linestyle=":")
        ax.set_yscale("log")
        ax.set_ylabel(f"{e}: anomaly score")
        ax.xaxis.set_major_formatter(mdates.DateFormatter("%H:%M"))
        ax.text(0.995, 0.03, f"threshold {m['tau']:.2f} (dashed)", transform=ax.transAxes, ha="right", fontsize=8, color=INK2)
    axs[0].legend(loc="lower left", bbox_to_anchor=(0, 1.0), ncol=2)
    axs[-1].set_xlabel("Time (dotted: last log entry). Primary configuration: rear accelerometer, 128 kHz features, speed-only normalization")
    fig.tight_layout()
    fig.savefig(OUT / "figures" / "anomaly_scores.png", dpi=160)
    plt.close(fig)

    # 2. load effect: speed-only residual z against combined load, reference periods
    feats_show = [("rms", "ln RMS"), ("band_20k_64k", "ln 20-64 kHz"), ("kurt", "kurtosis")]
    fig, axs = plt.subplots(1, 3, figsize=(9, 2.9))
    for e, col in zip(exps, (BLUE, ORANGE, AQUA, "#6250d6")):
        d = data[e]
        r = d[d.ref]
        m = fit(r, "A", "F128", "speed")
        _, Z = score(r, m)
        for ax, (f, lab) in zip(axs, feats_show):
            j = [n for n, _ in FSETS["F128"]].index(f)
            ax.plot(r.stat_kN + r.dyn_kN, Z[:, j], ".", ms=3.5, color=col, label=e)
            ax.set_title(lab, fontsize=9, color=INK2)
    for ax in axs:
        ax.set_xlabel("static + dynamic peak load (kN)")
    axs[0].set_ylabel("z after speed-only fit")
    axs[0].legend(loc="upper left")
    fig.tight_layout()
    fig.savefig(OUT / "figures" / "load_effect.png", dpi=160)
    plt.close(fig)

    # 3. the two channels and F42, primary normalization: per-bearing score ratio to tau
    fig, axs = plt.subplots(len(exps), 1, figsize=(9, 2.6 * len(exps)), sharex=False)
    axs = np.atleast_1d(axs)
    for ax, e in zip(axs, exps):
        d = data[e]
        for (ch, fs), col, lab in ((("A", "F128"), BLUE, "rear, 128 kHz"), (("C", "F128"), ORANGE, "front, 128 kHz"),
                                   (("A", "F42"), AQUA, "rear, 42 kHz")):
            m = fit(d[d.ref], ch, fs, "speed")
            s, _ = score(d, m)
            ax.plot(d.measurement_id, s / m["tau"], ".", ms=2.5, color=col, label=lab)
        ax.axhline(1, color=INK2, linewidth=0.9, linestyle="--")
        ax.set_yscale("log")
        ax.set_ylabel(f"{e}: score / threshold")
    axs[0].legend(loc="lower left", bbox_to_anchor=(0, 1.0), ncol=3)
    axs[-1].set_xlabel("Measurement id (speed-only normalization; above 1 = above the bearing's own threshold)")
    fig.tight_layout()
    fig.savefig(OUT / "figures" / "single_sensor_variants.png", dpi=160)
    plt.close(fig)


def main():
    exps = sys.argv[1:] or sorted(p.name for p in ROOT.iterdir() if (p / f"{p.name}_processed.csv").exists())
    data = {e: prepare(load(e)) for e in exps}
    res = {"design": {"ref_n": REF_N, "threshold_percentile": Q, "persistence": RUN, "primary": PRIMARY,
                      "feature_sets": {k: [n for n, _ in v] for k, v in FSETS.items()}, "conditions": CONDS},
           "experiments": {}}
    for e, d in data.items():
        r = {"n_operating": len(d), "ref_period": [str(d.timestamp[0]), str(d.timestamp[REF_N - 1])],
             "ref_T1": [float(d.T1_C[0]), float(d.T1_C[REF_N - 1])], "variants": {}}
        for ch in "AC":
            for fs in FSETS:
                for c in CONDS:
                    m = fit(d[d.ref], ch, fs, c)
                    s, Z = score(d, m)
                    ev = evaluate(d, s, m["tau"], e)
                    ev["ref_r2"] = dict(zip(m["names"], np.round(m["r2"], 3).tolist()))
                    # per-feature first persistent exceedance of |z| > 3 (which features carry the change)
                    ev["feature_first_alarm"] = {}
                    for j, n in enumerate(m["names"]):
                        i0 = first_persistent(np.abs(Z[:, j]), 3.0, REF_N)
                        ev["feature_first_alarm"][n] = None if i0 is None else int(d.measurement_id[i0])
                    ev["feature_end_z"] = dict(zip(m["names"], np.round(np.median(Z[-20:], axis=0), 1).tolist()))
                    r["variants"][f"{ch}|{fs}|{c}"] = ev
                    if (ch, fs, c) == PRIMARY:
                        r["primary"] = ev
                        pd.DataFrame({"measurement_id": d.measurement_id, "timestamp": d.timestamp, "reference": d.ref,
                                      "score": s, "threshold": m["tau"], "above": s > m["tau"]}) \
                            .to_csv(OUT / f"scores_{e}.csv" if OUT.exists() else (OUT.mkdir(parents=True) or OUT / f"scores_{e}.csv"),
                                    index=False, float_format="%.6g")
        # load: how much of the speed-only residual the load explains in the reference, and the load range in sigma
        m_s = fit(d[d.ref], "A", "F128", "speed")
        _, Zs = score(d[d.ref], m_s)
        L = (d.stat_kN + d.dyn_kN)[d.ref].to_numpy()
        r["load_effect_ref"] = {n: {"corr_with_total_load": float(np.corrcoef(Zs[:, j], L)[0, 1]),
                                    "sigma_shift_over_load_range": float(np.polyfit(L, Zs[:, j], 1)[0] * (L.max() - L.min()))}
                                for j, n in enumerate(m_s["names"])}
        r["speed_coef_A_F128"] = dict(zip(m_s["names"], np.round(m_s["B"][1], 3).tolist()))
        res["experiments"][e] = r
    # leave-one-bearing-out: global model from the other bearings' references, applied to the held-out bearing
    lobo = {}
    if len(data) > 1:
        for e in data:
            others = pd.concat([d[d.ref] for k, d in data.items() if k != e], ignore_index=True)
            m = fit(others, *PRIMARY)
            d = data[e]
            s, _ = score(d, m)
            ev = evaluate(d, s, m["tau"], e)
            ev["held_out_ref_exceed_fraction"] = float((s[d.ref] > m["tau"]).mean())
            ev["held_out_ref_median_score_over_tau"] = float(np.median(s[d.ref]) / m["tau"])
            lobo[e] = {"global (fitted on " + ", ".join(k for k in data if k != e) + ")": ev,
                       "commissioned (own reference)": res["experiments"][e]["primary"]}
    res["leave_one_bearing_out"] = lobo
    OUT.mkdir(parents=True, exist_ok=True)
    (OUT / "baseline.json").write_text(json.dumps(res, indent=1, default=str) + "\n", encoding="utf-8")
    figures(data, res)
    for e, r in res["experiments"].items():
        p = r["primary"]
        fa = p["first_alarm"]
        print(f"{e}: tau {p['tau']:.2f}; reference exceed {p['ref_exceed']}/{p['ref_n']}; after reference before alarm "
              f"{p['post_ref_pre_alarm_exceed']}/{p['post_ref_pre_alarm_n']}; first persistent alarm "
              + (f"M{fa['measurement_id']:04d} {fa['timestamp']} ({fa.get('minutes_before_log_end', float('nan')):.1f} min "
                 f"before log end, {fa['minutes_before_last_record']:.1f} min before last record), alarmed after "
                 f"{fa['fraction_alarmed_after']:.0%}" if fa else "none"))


if __name__ == "__main__":
    main()
