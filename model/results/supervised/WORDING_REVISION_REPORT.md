# Machine Guardian: revised wording of review items 2 and 15

*2 November 2026. Covers the request to keep the B02, B03 and B04 label ranges and clarify two items before the final
sign-off. No label changed. The review was not signed, no name was filled in, and nothing was trained.*

## 1. Summary

- **Item 2:** the final five measurements of B02, B03 and B04 are now described as provisional end-stage proxy labels.
  - The exact damage onset is unknown.
  - The rig stopping at a threshold does not by itself prove that the bearing defect caused the stop.
- **Item 15:** B04's half-scale speed and dynamic-load readings are now documented as a suspected logging or scaling
  discrepancy. It is supported by our vibration analysis and not confirmed by the dataset authors.
- **The labels are unchanged:**

  | Bearing | Healthy rows | Deteriorated rows |
  |---|---|---|
  | B02 | 100 | 5 |
  | B03 | 100 | 5 |
  | B04 | 100 | 5 |
  | B01 | none | none |

- **The label table's hash changed** from 05b315fb… to 4eff40d8…. The assumption text is stored inside the table,
  which keeps the wording and the labels together. A sign-off must now be against 4eff40d8….
- **Still unsigned:**
  - every `confirmed` field is empty;
  - `checked_by` and `independent_check_by` are empty;
  - `label_review.json` does not exist.
- **The readiness check is blocked** on the missing sign-off only.

## 2. Revised wording of item 2

Template item 2 (`label_review.TEMPLATE.json`):

> Assumptions A1-A4 in label_table.json are acceptable. The final five measurements of B02, B03 and B04 are
> PROVISIONAL END-STAGE PROXY LABELS: they stand for the end-of-test state of a bearing found damaged after dismantling
> (description Table 3), not a verified deteriorated state at those measurements. The exact damage onset is unknown
> (A3). The rig stopping at its vibration or temperature threshold does not by itself prove that the bearing defect
> caused the stop (A2 is an assumption). The healthy labels rest on 'no defect was initiated' and 'Begin with a new
> bearing' (A4).

The assumptions stored with the labels in `label_table.json` (from `labels.py`):

| | Before | After |
|---|---|---|
| A1 | ASSUMPTION: the damage found at dismantling was present during the last END_N measurements | PROVISIONAL END-STAGE PROXY: the last END_N measurements stand for the end-of-test state; that the damage found at dismantling was already present then is assumed, not verified |
| A2 | ASSUMPTION: the stop criterion was triggered by the bearing, not the rig | ASSUMPTION: the bearing defect caused the stop; the rig stopping at its threshold does not by itself prove this |
| A3 | NOT an onset time: the end label marks documented damage, not when it began; onset unknown (masked) | NOT an onset time: the exact damage onset is unknown (masked middle); the end label marks the documented end stage, not when damage began |

A4 and the evidence entries E1 and E2 are unchanged.

**In the review packet:**
- **Item 2:** retitled "assumptions A1–A4 and provisional end-stage labels". It now opens with the statement above.
- **Recommendation:** call the deteriorated labels "provisional end-stage proxy labels" in every result, with A1 and A2
  named as the main uncertainties.
- **Items 8, 12 and 14** (the deteriorated labels of B02, B03 and B04): each now carries the same caveat. The rows
  stand for the end-of-test state; damage in them is assumed, not verified; and the stop does not by itself prove the
  defect caused it.

## 3. Revised wording of item 15

Template item 15:

> SUSPECTED logging/scaling discrepancy, NOT confirmed by the dataset authors: B04's recorded measured speed is
> 0.498-0.500 x and its peak dynamic load about 0.52 x the set values in every row (static load normal). Our vibration
> analysis supports, but does not prove, that the shaft ran at the set speed and these two columns were logged at half
> scale: in 14 files from M0001 to M1114 the shaft-frequency line sits at the set speed, with only background at the
> recorded speed. Neither the description nor the B04 log mentions it. Data kept as recorded; labels never use speed;
> the 8 inputs are identical with the speed doubled.

The B04 registry note in `paderborn_experiments.json`:

| Before | After |
|---|---|
| "… the vibration spectrum's shaft line is at the SET speed, so the shaft ran at the set speed and these two columns were logged at half scale." | "SUSPECTED logging/scaling discrepancy, not confirmed by the dataset authors: … The vibration spectrum's shaft line sits at the SET speed, which supports (does not prove) that the shaft ran at the set speed and these two columns were logged at half scale." |

**In the review packet**, item 15 is retitled "suspected logging or scaling discrepancy in speed and dynamic load".
It adds that:

- the cause is undocumented and cannot be established from the files we have;
- any future cross-bearing correction (doubling B04's two columns) must say that it rests on this suspected
  discrepancy.

**Elsewhere:**
- **Label review report:** its summary, section 4 and section 6 use the same wording. Section 4 is retitled "suspected
  logging or scaling discrepancy in speed and dynamic load".
- **Code:** a comment in `supervised_prep.py` now says the same.

## 4. What changed and what did not

| Changed | Not changed |
|---|---|
| Assumption text A1–A3 in `labels.py`, so the label table's hash is now 4eff40d8… | Every label: the same rows, counts and sources (checked by reading the label files) |
| Items 2 and 15 in `label_review.py` and the regenerated template | The other 13 items |
| The B04 registry note | The processed data, the inputs, the folds and the anomaly-detector comparison |
| The packet, the walkthrough, the label review report and the review step report (new section 7) | The MLP (8 → 32 → 16 → 2), the frozen health-index head, the locked test bearings, all committed results |
| The rebuilt PDFs in `docs/Multitask_MLP_reports/` | `label_review.json` (still not created) |

## 5. Checks

| Check | Result |
|---|---|
| Labels after regeneration | B01 0/0, B02 100/5, B03 100/5, B04 100/5 (healthy/deteriorated) |
| Template | 15 items, all `confirmed` empty, `checked_by` and `independent_check_by` empty, table hash 4eff40d8… |
| Readiness check (`python supervised_prep.py`) | blocked: "label_review.json missing" |
| Training run folder `results/supervised/run1/` | does not exist |
| Tests | 61 pass |
| Packet | 16 pages, one item per page |

## 6. Next steps

1. **Independent review:** you and your teammate review `Label_review_packet.pdf` against the source documents.
2. **Sign-off:** you fill in `label_review.json` yourselves. Copy it from the template, set every `confirmed`, and add
   your names and dates.
3. **Readiness check:** tell me when it's done. I'll run the check; only if it prints "ready" does the first
   experimental deterioration-head run start on B02, B03 and B04 with leave-one-bearing-out. The health-index head
   stays frozen and B06, B07, B13 and B17 stay locked.

Nothing is committed.

## 7. Files

| File | What changed |
|---|---|
| `labels.py`, `results/supervised/label_table.json`, `labels_B0x.csv` | Wording of A1–A3; table hash 4eff40d8… (labels identical) |
| `label_review.py`, `results/supervised/label_review.TEMPLATE.json` | Items 2 and 15 |
| `paderborn_experiments.json` | B04 note marked as suspected and not confirmed |
| `supervised_prep.py` | One comment |
| `results/supervised/LABEL_REVIEW_PACKET.md`, `LABEL_REVIEW_WALKTHROUGH.md`, `LABEL_REVIEW_REPORT.md`, `REVIEW_STEP_REPORT.md` | Revised wording |
| `docs/Multitask_MLP_reports/Label_review_packet.pdf`, `Label_review_report.pdf`, `Review_step_report.pdf` | Rebuilt |
| `docs/Multitask_MLP_reports/Wording_revision_report.pdf`, `results/supervised/WORDING_REVISION_REPORT.md` | This report |

