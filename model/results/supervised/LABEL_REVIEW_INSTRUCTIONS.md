# How to complete the label review with a teammate

*For the reviewer and the independent second checker. Label table under review:*
`4eff40d85f35e35dcc1f8129c1f90267c44f3a748c576639ac2ced4deb20a475`. *Nothing has been signed for you; the names and
every confirmation are yours to enter.*

## 1. What you are signing

- **The labels:**
  - **Healthy (0):** B02 M0052–M0151, B03 M0001–M0100, B04 M0051–M0150.
  - **Deteriorated (1), provisional end-stage proxy labels:** B02 M1112–M1116, B03 M0610–M0614, B04 M1110–M1114.
  - **B01:** no labels.
  - **Everything else:** unlabelled. The Motor Health Index has no labels.
- **The 15 statements** in `model/results/supervised/label_review.TEMPLATE.json`. Each one has its own page in
  `docs/Multitask_MLP_reports/Label_review_packet.pdf`.
- **The table they belong to:** `model/results/supervised/label_table.json`, whose SHA-256 begins `4eff40d8`. A
  sign-off of any other table is rejected.

## 2. Before you start: check you have the latest table

Run this inside `model/`:

```bash
python -c "import json, labels as lb; d=json.load(open('results/supervised/label_table.json')); t=json.load(open('results/supervised/label_review.TEMPLATE.json')); print(d['sha256']); print('content matches its hash:', d['sha256']==lb.table_digest(d['table'])); print('template is for this table:', t['label_table_sha256']==d['sha256'])"
```

**Expected output:**

```
4eff40d85f35e35dcc1f8129c1f90267c44f3a748c576639ac2ced4deb20a475
content matches its hash: True
template is for this table: True
```

If the first line doesn't begin `4eff40d8`, or either check says False, stop and tell me.

## 3. Get the original documents and check they are the right files

| Document | Where | SHA-256 |
|---|---|---|
| Dataset description v2 (O. K. Aimiyekagbon, 25 March 2024, 9 pages) | Zenodo record 10.5281/zenodo.10805042, file `LDM_UPB_Run-to-failure_data_set_of_ball_bearings.pdf`. Download it yourselves; it is not in the repository. | 949c855fa0cc6d2b12c83b476a03b7ab9498cf2ee4219ef50004e21ae0dd1b80 |
| B01 log | `model/newdata/B01/B01_log.pdf` | 4a5445c8ac9f9249b1341ccb356e2fe6c04ac8a083a696e34c72f7011ac2d282 |
| B02 log | `model/newdata/B02/B02_log.pdf` | 5beffbeebd5ffa1ff62e6c83cee0b74a9ab53e0de4e31f932703ea81dbf522e7 |
| B03 log | `model/newdata/B03/B03_log.pdf` | caa9c543658ff37474eaa643275fdb7c2fb61d697e770445733325484ff41d2f |
| B04 log | `model/newdata/B04/B04_log.pdf` | 84ea2506dbeaaa14741cd3fe330424463b13db2db561a3c4dabbe4a33d2964da |

To check a file's SHA-256 on Windows (PowerShell): `Get-FileHash <file> -Algorithm SHA256`. In Git Bash:
`sha256sum <file>`. A different hash means a different version of the document; tell me before going on.

## 4. Who does what

| Role | Who | JSON fields |
|---|---|---|
| Reviewer | one of you | `checked_by`, `date` |
| Independent second checker | the other, a different person | `independent_check_by`, `independent_check_date` |

- **Work separately first.** Each of you goes through all 15 pages of the packet on your own, with the original
  documents open, and fills in your own tick row (Confirm or Change, plus a comment). Don't look at the other
  person's ticks until you have both finished.
- **Check against the source, not the packet.** For every quote, open the cited document at the cited page and
  confirm the wording is there. For every "our data" statement, you may rerun the cited check or ask me to show it.
- **Then compare.** Go through the 15 items together. Any item where either of you ticked Change, or where you
  disagree, goes to step 6. Do not sign anything yet.

## 5. What to look for on each item

| Item | Check in particular |
|---|---|
| 1 | Table 3 on description p.8: defect types for B01–B04 |
| 2 | You accept that the final five rows are provisional end-stage proxy labels: the onset is unknown, and the stop does not by itself prove the defect caused it |
| 3 | 100 healthy and 5 deteriorated rows per bearing; B01 withheld |
| 4 | Description p.4 says "[6, 10] g"; the B02 log gives 0.65 V; log p.1 gives 10 g/V; no document names the accelerometer |
| 5, 6 | B01: description p.4 "no criteria was pre-set" against the B01 log's 09:13 entry; the 08:45 "operated for a maximum of 15 minutes" |
| 7, 8, 9, 10 | B02 log p.2: the 08:59, 13:32 and 14:36 entries |
| 11, 12 | B03 log p.2: the 15:10 and 18:23 entries |
| 13, 14 | B04 log p.1 and p.2: the 12:45, 13:45 and 18:26 entries |
| 15 | B04 speed and dynamic load are documented as a suspected logging or scaling discrepancy, not confirmed by the authors. Description p.7 and the B04 log mention no scale factor |

## 6. If anything should change

- **Stop.** Do not create `label_review.json`.
- **Tell me** the item number, what should change, and why (with the document and page).
- **I then update** the labels or the wording, regenerate the label table (its hash changes), the template and the
  packet, and show you the result.
- **Start again from step 2** with the new hash. Ticks made on an older table don't carry over.

## 7. Recording the sign-off (only when both of you confirm all 15 items)

- **7a. Copy the template.** Inside `model/`:

   ```bash
   cp results/supervised/label_review.TEMPLATE.json results/supervised/label_review.json
   ```

- **7b. Edit the copy with a text editor:**
   - **Every item:** set `"confirmed": true`, without quotes. Optionally add your comments in `"comment"`.
   - **The header fields:** fill in `checked_by`, `date`, `independent_check_by` and `independent_check_date`. Use the
     format `YYYY-MM-DD` for dates.
   - **Leave unchanged:** `label_table_sha256`, every `check` and every `source`. The readiness check compares them
     with the current table and template.

   The top of the file then looks like this, with your own entries in place of the angle brackets:

   ```
   "label_table_sha256": "4eff40d85f35e35dcc1f8129c1f90267c44f3a748c576639ac2ced4deb20a475",
   "checked_by": "<reviewer's name>",
   "date": "<YYYY-MM-DD>",
   "independent_check_by": "<second checker's name>",
   "independent_check_date": "<YYYY-MM-DD>",
   ```

- **7c. Tell me the review is complete.**

## 8. What happens next

- **8a. I run** `python supervised_prep.py`. It prints "ready" only if all of the following hold:
   - the label table is unedited (its content matches its hash);
   - `label_review.json` names that hash;
   - its 15 items match the current template word for word;
   - every item is `true`;
   - both names are filled in and differ;
   - B02 and B04 pass the data checks;
   - three bearings have both kinds of label;
   - the MLP is still the 8 → 32 → 16 → 2 network.
- **8b. If it is blocked**, it prints the reason:

   | Message | Fix |
   |---|---|
   | label_review.json missing | Step 7 not done yet |
   | does not sign off the current label_table.json | Wrong hash, or `checked_by` empty: copy the template again |
   | items differ from the current template | The file came from an older template: copy it again |
   | has items not confirmed | An item is not `true` (check for quotes or a missing item) |
   | needs an independent check by a second person | `independent_check_by` empty, or the same name as `checked_by` |
   | was edited after labels.py wrote it | Someone changed the table by hand: tell me |

- **8c. If it prints "ready"**, I run `python train_deterioration.py`. This is the first experimental deterioration-head
   run, and its settings are already fixed:
   - **Folds:** B02, B03 and B04, each held out once and trained on the other two.
   - **Network:** the unchanged MLP. The Motor Health Index head is frozen and checked unchanged after training.
   - **Training:** three seeds, and a decision rule fixed in advance.
   - **Comparison:** against the anomaly detector and the 6.5 g rig rule; B03 is reported separately.
   - **Outputs:** `results/supervised/run1/`.
- **8d. Never touched:** the four locked test bearings (B06, B07, B13, B17).
