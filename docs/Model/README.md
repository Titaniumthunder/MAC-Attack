# Machine Guardian model documents: reading order

**Start here:** `00_Current_model.pdf` describes the model we have now: the Run 3 deterioration MLP, its data, inputs,
parameters, training, outputs, results and hardware. Everything else in this folder is the history of how we got there,
numbered in the order it happened.

## The progression

| # | Document | Date | Stage | What it established | What it led to |
|---|---|---|---|---|---|
| 00 | `00_Current_model.pdf` | 9 Nov | **The current model** | summary of the Run 3 model only | – |
| 01 | `01_Ottawa_three_accelerometer_model_E0-E3.pdf` | 27 Oct | First model: University of Ottawa motor dataset | healthy/faulty motor classifier (E3: 22 inputs from 3 accelerometers, 1,281 parameters); INT8 export; RTL check on our 8 × 8 accelerator | the final hardware has only one accelerometer |
| 02 | `02_Ottawa_single_accelerometer_model.pdf` | 28 Oct | One accelerometer | the same task with 8 inputs from 1 accelerometer (833 parameters), 28/28 test faults found; 382 cycles on the RTL | Ottawa has one healthy motor and no wear progression, so it cannot teach **deterioration** |
| 03 | `03_Paderborn_B01_first_bearing.pdf` | 1 Nov | Switch to the Paderborn run-to-failure bearings | the processing pipeline on the first bearing (B01), with data checks | a detector that needs no labels |
| 04 | `04_Paderborn_anomaly_detector_baseline.pdf` | 1 Nov | Label-free anomaly detector | each bearing calibrated on its own first 100 measurements; alarms before the stop on B01 and B03. It becomes **the reference every later model is compared with** | a network design that fits the hardware and can output both an alarm and a health index |
| 05 | `05_Multitask_MLP_architecture.pdf` | 1 Nov | The multi-task MLP | 8 inputs (one accelerometer, speed, temperature) → 32 → 16 → 2 outputs, **850 parameters**; INT8 and RTL verified; deliberately left untrained | the network needs honest labels |
| 06 | `06_Dataset_validation_and_training_plan.pdf` | 2 Nov | Dataset validation | what the Paderborn documents really say (damage type only at the end); the **locked test set** (B06, B07, B13, B17); the 42-kHz input profile; the rule "no invented labels" | label only the documented healthy start and damaged end |
| 07 | `07_B02_B04_processing_and_labels.pdf` | 2 Nov | Labels | B02 and B04 processed; healthy = first 100, end stage = last 5 before a documented stop, the rest unlabelled; B01 excluded; B04's speed logged at half scale (suspected) | the first training run |
| 07a–e | `supporting_label_review/` | 2 Nov | Label review records | the 15-item review packet, the reviewing instructions, and the records of each review step and wording change | – |
| 08 | `08_Training_run1.pdf` | 3 Nov | Run 1 | the first trained network, on B02–B04: no false alarms and every end stage caught, but the alarm flickered and came later than the anomaly detector | a steadier alarm |
| 09 | `09_Training_run2.pdf` | 3 Nov | Run 2 | the alarm is latched (flicker removed); the scores proved over-confident; first trained network through INT8 and RTL | more bearings and regularisation |
| 10 | `10_Training_run3.pdf` | 3 Nov | Run 3 | 7 bearings (4 new), 5 configurations, nested leave-one-bearing-out; **configuration E chosen**; much steadier; 6 of 7 bearings caught; still not earlier than the anomaly detector | the current model (00) |
| 11 | `11_Development_history_Ottawa_to_Run3.pdf` | 3 Nov | Full history | one long document covering 01–10 | – |

## In one paragraph

We began with a healthy/faulty motor classifier on the University of Ottawa dataset (01). We reduced it to the single
accelerometer the final hardware will have (02). Ottawa contains no bearing that wears out over time, so we moved to the
Paderborn run-to-failure bearings (03) and built a label-free anomaly detector as a reference (04). We designed an
850-parameter multi-task network that fits our 8 × 8 accelerator (05). Then we checked what the dataset documents
actually prove, locked away four test bearings (06), and labelled only what the documents support: a healthy start and
a damaged end (07). Three training runs followed. Run 1 worked but flickered (08). Run 2 latched the alarm (09). Run 3
added four bearings, regularisation and log-compressed inputs, and produced the current model (10, summarised in 00).
That model is stable, runs in 1.78 µs on the accelerator in simulation and catches 6 of 7 bearings, but it does not yet
warn earlier than the anomaly detector.

## Other folders

| Folder | Contents |
|---|---|
| `supporting_label_review/` | 07a review packet, 07b review step report, 07c wording revision, 07d review instructions, 07e instructions report |
| `superseded/` | version 1 of the development history (Ottawa to Run 2), replaced by 11. Kept as a record |

## Where the old file names went (9 Nov reorganisation)

Older reports and source files still mention the former names.

| Former path | Now |
|---|---|
| `docs/Machine_Guardian_model_report.pdf` | `docs/Model/01_Ottawa_three_accelerometer_model_E0-E3.pdf` |
| `docs/Machine_Guardian_single_accel_report.pdf` | `docs/Model/02_Ottawa_single_accelerometer_model.pdf` |
| `docs/Paderborn_B01_report.pdf` | `docs/Model/03_Paderborn_B01_first_bearing.pdf` |
| `docs/Paderborn_baseline_report.pdf` | `docs/Model/04_Paderborn_anomaly_detector_baseline.pdf` |
| `docs/Multitask_MLP_reports/Multitask_architecture_report.pdf` | `docs/Model/05_Multitask_MLP_architecture.pdf` |
| `docs/Multitask_MLP_reports/Dataset_validation_report.pdf` | `docs/Model/06_Dataset_validation_and_training_plan.pdf` |
| `docs/Multitask_MLP_reports/Label_review_report.pdf` | `docs/Model/07_B02_B04_processing_and_labels.pdf` |
| `docs/Multitask_MLP_reports/Label_review_packet.pdf` | `docs/Model/supporting_label_review/07a_Label_review_packet.pdf` |
| `docs/Multitask_MLP_reports/Review_step_report.pdf` | `docs/Model/supporting_label_review/07b_Review_step_report.pdf` |
| `docs/Multitask_MLP_reports/Wording_revision_report.pdf` | `docs/Model/supporting_label_review/07c_Wording_revision_report.pdf` |
| `docs/Multitask_MLP_reports/Label_review_instructions.pdf` | `docs/Model/supporting_label_review/07d_Label_review_instructions.pdf` |
| `docs/Multitask_MLP_reports/Review_instructions_report.pdf` | `docs/Model/supporting_label_review/07e_Review_instructions_report.pdf` |
| `docs/Multitask_MLP_reports/Training_run1_report.pdf` | `docs/Model/08_Training_run1.pdf` |
| `docs/Multitask_MLP_reports/Training_run2_report.pdf` | `docs/Model/09_Training_run2.pdf` |
| `docs/Multitask_MLP_reports/Machine_Guardian_Training_Run3_Report.md` / `.pdf` | `docs/Model/10_Training_run3.md` / `.pdf` |
| `docs/Multitask_MLP_reports/Machine_Guardian_ML_Development_and_Training_Results_v2.md` / `.pdf` | `docs/Model/11_Development_history_Ottawa_to_Run3.md` / `.pdf` |
| `docs/Multitask_MLP_reports/Machine_Guardian_ML_Development_and_Training_Results.md` / `.pdf` | `docs/Model/superseded/Development_history_v1_Ottawa_to_Run2.md` / `.pdf` |

## Rebuilding

The builder scripts in `model/report/` now write to these names:

| Document | Builder |
|---|---|
| 00 | `make_current_model_report.py` |
| 01 | `make_report.py` |
| 02 | `make_single_accel_report.py` |
| 03 | `make_b01_report.py` |
| 04 | `make_paderborn_baseline_report.py` |
| 05 | `make_multitask_report.py` |
| 06 | `make_phase2_report.py` |
| 07 | `make_label_review_report.py` |
| 07a–e | `make_review_docs.py` |
| 08 | `make_training_run1_report.py` |
| 09 and the superseded v1 | `make_run2_reports.py` |
| 10 and 11 | `make_run3_reports.py` and `make_dev_report_v2.py` |
