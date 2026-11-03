# Machine Guardian: review instructions and sign-off safeguards

*2 November 2026. Covers the request for clear instructions to complete the updated 15-item label review with a
teammate, on the label table whose hash begins 4eff40d8. The labels and the architecture are unchanged. Nothing was
signed, no name was filled in, and nothing was trained.*

## 1. Summary

- **Instructions written:** `docs/Multitask_MLP_reports/Label_review_instructions.pdf`. They cover:
  - how to confirm you have the 4eff40d8 table;
  - how to get and verify the source documents;
  - who fills in which fields;
  - how to review independently;
  - what to do if a label should change;
  - how to record the sign-off;
  - what the readiness check needs, and what each of its messages means.
- **Table confirmed current:**
  - `label_table.json` has SHA-256 4eff40d85f35e35dcc1f8129c1f90267c44f3a748c576639ac2ced4deb20a475.
  - Its content matches that hash.
  - The template refers to it.
- **Two safeguards added to the readiness check** (`supervised_prep.py`). It is still blocked until the label table is
  signed. Now it also blocks if:
  - the label table was edited by hand after `labels.py` wrote it (the hash is recomputed from the content);
  - `label_review.json` was copied from an older template (its 15 statements must match the current template word for
    word).

  These protect against signing the wrong table, the main risk now that the hash has changed twice.
- **One error found and corrected in the review packet:** the description PDF's SHA-256 was printed as
  `949c855fa0cc6d20`. The correct value starts `949c855fa0cc6d2b`; a shell command had cut the hash wrongly. The
  packet is rebuilt, and the instructions give all five documents' full hashes.
- **The readiness check is blocked:** "label_review.json missing". The training run is prepared but not started.

## 2. What was done

| Step | Result |
|---|---|
| Checked the label table | Stored hash = recomputed hash = template hash = 4eff40d8… |
| Recomputed the source-document hashes | Full SHA-256 for the description and the four logs; the packet's description hash corrected |
| Wrote the instructions | `results/supervised/LABEL_REVIEW_INSTRUCTIONS.md`, built as `docs/Multitask_MLP_reports/Label_review_instructions.pdf` |
| Tested the instructions' verification command | Prints the hash, "content matches its hash: True" and "template is for this table: True" |
| Added two checks to `ready()` in `supervised_prep.py` | The table must match its own hash; the review's items must match the current template |
| Tests | One new test, one updated to the stricter check; 62 pass |
| Readiness check | Blocked: "label_review.json missing" |

## 3. The readiness check now requires

| Requirement | Status today |
|---|---|
| B02 and B04 processed; data checks pass on B01–B04 | pass |
| Three bearings with both kinds of label (B02, B03, B04) | pass |
| MLP is 8 → 32 → 16 → 2 (850 parameters) | pass |
| `label_table.json` unedited (content matches hash) | pass |
| `label_review.json` exists and names the table's hash | **missing** |
| Its 15 items match the current template | not reached |
| Every item confirmed `true` | not reached |
| `checked_by` and `independent_check_by` filled in, different people | not reached |

## 4. The prepared training run (not started)

`train_deterioration.py` refuses to start until the readiness check passes. Its settings were fixed before any
training:

- **Folds:** B02, B03 and B04, each held out once and trained on the other two. B01 has no labels.
- **Network:** the unchanged 8 → 32 → 16 → 2 MLP. The Motor Health Index head is frozen, kept out of the optimizer,
  and checked unchanged after training.
- **Training:**
  - masked BCE loss;
  - Adam at learning rate 0.001;
  - 2,000 class-balanced steps of 64 rows;
  - the temperature input blanked in half of the training rows;
  - seeds 0, 1 and 2.
- **Decision rule:** probability above 0.5, three in a row. It is not tuned.
- **Comparison:** each held-out bearing is scored against the anomaly detector and the 6.5 g rig rule. B03, the
  temperature stop, is reported separately.
- **Reading the results:** the deteriorated labels are provisional end-stage proxies, so the results test the method.
  They are not a detection rate or a detection delay.
- **Outputs:** `results/supervised/run1/`. An existing run is never overwritten.

## 5. Unchanged

- **Labels:** 300 healthy and 15 deteriorated rows; B01 has none.
- **Model:** the label table's contents and the MLP architecture.
- **Never trained:** the Motor Health Index head.
- **Never touched:** the four locked test bearings (B06, B07, B13, B17).
- **Preserved:** all committed models and results.

## 6. Files

| File | What it is |
|---|---|
| `docs/Multitask_MLP_reports/Label_review_instructions.pdf`, `results/supervised/LABEL_REVIEW_INSTRUCTIONS.md` | The step-by-step instructions |
| `docs/Multitask_MLP_reports/Review_instructions_report.pdf`, `results/supervised/REVIEW_INSTRUCTIONS_REPORT.md` | This report |
| `docs/Multitask_MLP_reports/Label_review_packet.pdf` | Rebuilt with the corrected description hash |
| `supervised_prep.py`, `test_supervised.py` | The two new checks and their test |
| `report/make_review_docs.py` | Also builds the two new PDFs |

Nothing is committed.
