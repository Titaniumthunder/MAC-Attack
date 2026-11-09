# Machine Guardian: label review preparation and readiness check

*2 November 2026. Covers the request to finish the label review before training: show the 15 review items one at a
time with evidence from the original documentation, prepare for an independent check, and run the readiness check.
Nothing was approved and nothing was trained.*

## 1. Summary

- **A review packet is ready:** `docs/Multitask_MLP_reports/Label_review_packet.pdf`. It gives one page per item for all 15 items in
  `label_review.TEMPLATE.json`. Each page shows:
  - what is being confirmed;
  - the current label;
  - the wording of the original documents, quoted with the page number;
  - what our data show;
  - the assumptions;
  - a recommendation;
  - a tick box for the reviewer and one for an independent second checker.
- **No item is approved.** Every `confirmed` field in the template is empty, and `label_review.json` does not exist.
- **The readiness check was run. Result: not ready.** The only blocker is the missing signed review. Every data check
  passes, three bearings (B02, B03, B04) have both kinds of label, and the network is unchanged.
- **Training has not started.** `train_deterioration.py` refuses to run while the review is unsigned. No run folder
  exists.
- **Unchanged:**
  - the health-index head;
  - the four locked test bearings B06, B07, B13 and B17, which have no data, processing or results on this machine.

## 2. What was done

| Step | Result |
|---|---|
| Collected the original documents | Dataset description v2 (9 pages, from the Zenodo record) and the four experiment logs; SHA-256 recorded for each |
| Read every cited passage again | Quotes in the packet are copied from the documents with their page numbers; nothing is paraphrased as a quote |
| Cross-checked the numbers in the packet against the data | File counts, timestamps, temperature crossings, RMS values, speed ratios (B04 0.4982–0.5003) |
| Wrote the packet | `results/supervised/LABEL_REVIEW_PACKET.md`, built as `docs/Multitask_MLP_reports/Label_review_packet.pdf` (one item per page) |
| Ran the readiness check | `python supervised_prep.py`: blocked on the review only (section 4) |
| Ran the tests | 61 pass |

No code changed in this step. The label table is the one from the B01 decision: `label_table.json`, SHA-256
4eff40d85f35e35d…. The labels are unchanged; only the wording of items 2 and 15 was revised (section 7).

## 3. The 15 items and the recommendations

| Item | Bearing | What is confirmed | Main source | Recommendation |
|---|---|---|---|---|
| 1 | all | Defect types after dismantling | Description p.8, Table 3 | keep |
| 2 | all | Assumptions A1–A4; the final five rows are provisional end-stage proxy labels | Description p.2, p.4, p.8; logs p.2 | keep; onset unknown; the stop does not prove the cause |
| 3 | all | 100 healthy / 5 deteriorated rows; B01 withheld | `labels.py` (design choice) | keep |
| 4 | B02, B04 | End labels placed by a vibration stop rule | Description p.3, p.4, p.8; B02 log p.1–2; B04 log p.2 | keep, compared with the rule; B03 reported separately |
| 5 | B01 | No deteriorated label | Description p.4, p.8; B01 log p.2 | keep withheld |
| 6 | B01 | No healthy label | B01 log p.2; description p.4 | keep the decision |
| 7 | B02 | Healthy M0052–M0151 | B02 log p.2; description p.2 | keep |
| 8 | B02 | Deteriorated M1112–M1116 | B02 log p.2; description p.4, p.8 | keep |
| 9 | B02 | 13:32 pause is not a label | B02 log p.2 | keep it unlabelled |
| 10 | B02 | 13 crossings in our data vs 4 in the log | B02 log p.2 | acknowledge |
| 11 | B03 | Healthy M0001–M0100 | B03 log p.2; description p.2 | keep |
| 12 | B03 | Deteriorated M0610–M0614 | B03 log p.2; description p.4, p.8 | keep |
| 13 | B04 | Healthy M0051–M0150 | B04 log p.1–2; description p.2 | keep |
| 14 | B04 | Deteriorated M1110–M1114 | B04 log p.2; description p.4, p.8 | keep |
| 15 | B04 | Speed and dynamic load: suspected logging or scaling discrepancy | Description p.7; B04 log p.1 | document as suspected, not confirmed by the authors |

**The three points needing the most care:**

- **Vibration stop rule (items 4, 8, 14).**
  - **What the documents say:** B02 and B04 ended on the vibration criterion ("within [6, 10] g", description p.4).
    B02's log gives the limit, 0.65 V, which is 6.5 g at the log's 10 g/V.
  - **What they do not say:** which accelerometer the rule used. Our data point to the rear sensor A, the model's
    input sensor.
  - **The risk:** a trained head could just relearn the stop rule.
  - **The safeguards:**
    - the rule is scored as a reference detector (it catches 40% of the deteriorated rows on B02 and B04, and 0% on
      B03);
    - B03, the temperature stop, is reported separately.
- **B04 speed (item 15).**
  - **The finding:** the description defines `meanAbs_speed` as the measured shaft speed and mentions no scale factor.
    B04's values are 0.498–0.500 times the set speed in every row.
  - **The evidence:** the vibration spectrum in 14 files across the run shows the shaft at the set speed. This
    supports a suspected logging or scaling discrepancy; it is not confirmed by the dataset authors.
  - **The effect:** none on the labels or the model inputs.
- **B01 (items 5 and 6).**
  - **The facts:** the description says no criterion was pre-set, while the log says the temperature threshold was
    exceeded at 09:13. The data show T1 reaching 110 °C at 09:12:49, about 16 minutes after warm-up, followed by two
    restarts.
  - **The decision:** B01 has no labels and is in no fold.

## 4. Readiness check

`python supervised_prep.py`, run on 2 November 2026 (`results/supervised/readiness.json`):

| Requirement | Status |
|---|---|
| B02 and B04 processed | pass |
| Hard data checks, B01–B04 (ids, file counts against the description, sample rate, finite samples, timestamps, file-to-row alignment, log transcribed, measured speed or a documented note) | pass, no failures |
| At least two bearings with a deteriorated label | pass (B02, B03, B04) |
| MLP is 8 → 32 → 16 → 2, 850 parameters | pass |
| `label_review.json` exists, signs the current table, every item confirmed | **fail: missing** |
| Independent second checker named, different from the reviewer | **fail: missing** (not reached) |
| **Overall** | **not ready** |

`python train_deterioration.py` stops with "supervised training is blocked". No `results/supervised/run1/` exists.

## 5. What happens after the review

1. **Review:** you and your teammate review the packet independently and settle any disagreement. If a label changes,
   I regenerate the table and the packet.
2. **Sign-off:** copy `label_review.TEMPLATE.json` to `label_review.json`. Set every `confirmed` to true, add comments
   where useful, and fill in `checked_by`, `date`, `independent_check_by` and `independent_check_date`.
3. **Readiness check:** run `python supervised_prep.py` again; it must print "ready". I will run it when you tell me the
   review is signed.
4. **Training:** only if it passes, run `python train_deterioration.py`, the first experimental run. Its settings were
   fixed before any training:
   - **Folds:** B02, B03 and B04, each held out once and trained on the other two.
   - **Network:** the unchanged 8 → 32 → 16 → 2 MLP. The health-index head is frozen and checked unchanged afterwards.
   - **Training:** 2,000 class-balanced steps of 64 rows, Adam at learning rate 0.001, the temperature input blanked
     in half of the training rows, seeds 0, 1 and 2.
   - **Decision rule:** probability above 0.5, three in a row. It is not tuned.
   - **Comparison:** against the anomaly detector (both configurations) and the 6.5 g rig rule on each held-out
     bearing. B03 is reported separately.
   - **Outputs:** `results/supervised/run1/`. A run is never overwritten.
5. **Limits of the run:** with 300 healthy and 15 deteriorated rows from three bearings, it tests the method. It is not
   a detection rate, a detection delay, or a test-set result.

## 6. Files

| File | What it is |
|---|---|
| `docs/Multitask_MLP_reports/Label_review_packet.pdf`, `results/supervised/LABEL_REVIEW_PACKET.md` | The 15 items, one per page, with quotes, data and tick boxes |
| `results/supervised/label_review.TEMPLATE.json` | The sign-off template (unsigned; every item has its source) |
| `results/supervised/LABEL_REVIEW_WALKTHROUGH.md` | The reasoning behind each recommendation |
| `docs/Multitask_MLP_reports/Label_review_report.pdf` | Processing of B02 and B04, the label table, the comparison with the anomaly detector |
| `results/supervised/readiness.json` | The readiness check result above |
| `docs/Multitask_MLP_reports/Review_step_report.pdf`, this file | This report |

Nothing is committed.

## 7. Wording revised after the first review (2 November)

You kept the B02, B03 and B04 label ranges and asked for two clarifications. They are now in the template, the packet,
the walkthrough, the label review report and `label_table.json`. The table's evidence text changed, so its hash is now
4eff40d8…. No label changed: the same 300 healthy and 15 deteriorated rows.

- **Item 2:** the final five measurements are provisional end-stage proxy labels. The exact damage onset is unknown,
  and the rig stopping at a threshold does not by itself prove the bearing defect caused the stop.
- **Item 15:** B04's half-scale speed and dynamic-load readings are a suspected logging or scaling discrepancy,
  supported by the vibration analysis and not confirmed by the dataset authors. The registry note in
  `paderborn_experiments.json` says the same.

The review is still unsigned: no `confirmed` field is set and no name is filled in.

