"""The locked bearing-level split of the Paderborn run-to-failure data set (B01-B17). Fixed on 2 Nov 2026, before any of
B02, B04-B17 was downloaded or looked at.

  python splits.py            write results/splits/splits.json once (refuses to overwrite), or verify it

Rule (declared before drawing; nothing here depends on any measurement):
  1. The bearing (experiment) is the unit: all measurements of one experiment are in the same set.
  2. Not eligible for the test set:
       B01, B03  already analysed in detail (anomaly baseline, multi-task inputs) - not blind any more;
       B05       deliberately interrupted;  B01, B16  no stop criterion pre-set  (dataset description, Table 3).
  3. One test bearing per operating regime, drawn with random.Random(SEED).choice from the eligible ones:
       S128  sinusoidal load, 128 kHz, variable speed      B01-B06
       N128  noise load,      128 kHz, variable speed      B07-B09
       N64v  noise load,       64 kHz, variable speed      B10-B13
       N64c  noise load,       64 kHz, constant 2700 rpm   B14-B17
  4. Everything else is the development set. Model choices use leave-one-bearing-out over the development set only.
The test bearings may be preprocessed (features only, by the same unchanged pipeline) but not plotted, scored or
inspected until a model is frozen; test_bearings() refuses without the frozen model's SHA-256.
"""
import hashlib, json, random
from pathlib import Path

HERE = Path(__file__).resolve().parent
OUT = HERE / "results" / "splits" / "splits.json"
SEED = 20261102
ALL = [f"B{i:02d}" for i in range(1, 18)]
REGIMES = {"S128": ["B01", "B02", "B03", "B04", "B05", "B06"], "N128": ["B07", "B08", "B09"],
           "N64v": ["B10", "B11", "B12", "B13"], "N64c": ["B14", "B15", "B16", "B17"]}
NOT_ELIGIBLE = {"B01": "analysed; no stop criterion pre-set", "B03": "analysed", "B05": "deliberately interrupted",
                "B16": "no stop criterion pre-set"}


def draw():
    rng = random.Random(SEED)
    test = {g: rng.choice(sorted(b for b in members if b not in NOT_ELIGIBLE)) for g, members in REGIMES.items()}
    dev = [b for b in ALL if b not in test.values()]
    return {"seed": SEED, "rule": __doc__.split("Rule")[1].split("The test bearings may")[0].strip(),
            "regimes": REGIMES, "not_eligible_for_test": NOT_ELIGIBLE,
            "test": test, "development": dev,
            "development_folds": [{"held_out": b, "train": [k for k in dev if k != b]} for b in dev]}


def digest(split):
    return hashlib.sha256(json.dumps(split, sort_keys=True).encode()).hexdigest()


def load():
    doc = json.loads(OUT.read_text(encoding="utf-8"))
    if digest(doc["split"]) != doc["sha256"]:
        raise RuntimeError("results/splits/splits.json was edited: its hash no longer matches")
    return doc["split"]


def development():
    return list(load()["development"])


def assert_development(experiments):
    """Call before any fitting or model choice: refuses a test bearing."""
    bad = sorted(set(experiments) & set(load()["test"].values()))
    if bad:
        raise RuntimeError(f"{bad} are locked test bearings")


def test_bearings(frozen_model_sha256=None):
    """The locked test bearings, only for the final evaluation of a frozen model (pass its file's SHA-256)."""
    if not frozen_model_sha256 or len(frozen_model_sha256) != 64:
        raise RuntimeError("the test set is locked: pass the SHA-256 of the frozen model file")
    return sorted(load()["test"].values())


def main():
    split = draw()
    if OUT.exists():
        if load() != split:
            raise SystemExit("splits.json differs from the declared rule: not touched")
        print(f"verified {OUT} (sha256 {digest(split)[:16]}...)")
    else:
        OUT.parent.mkdir(parents=True, exist_ok=True)
        OUT.write_text(json.dumps({"split": split, "sha256": digest(split), "fixed_on": "2026-11-02"}, indent=1) + "\n",
                       encoding="utf-8")
        print(f"wrote {OUT}")
    print("test:", split["test"], "\ndevelopment:", split["development"])


if __name__ == "__main__":
    main()
