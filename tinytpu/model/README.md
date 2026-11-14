# RSCL Tiny-TPU: motor vibration MLP -> INT4 inference

**Engineering starter kit | 12 November 2026 | SKY130 Tiny Tapeout target**

This project is **executable and smoke-tested with synthetic vibration recordings**. It is **not yet validated on the University of Ottawa data**, and it does **not** contain finished FPGA RTL, Tiny Tapeout GPIO firmware, or an ASIC layout. Those depend on the team's PE protocol and physical tile allocation. Do not report demo accuracy as scientific results.

## 1. Architecture and division of work

```text
Motor + accelerometer -> acquisition MCU / ADC -> vibration window
                                            |
                                 8 deterministic features
                                            |
                         standardize with TRAINING statistics
                                            |
                        host MCU (RP2040 or equivalent):
                          model weights, bias, layer control
                                            |
                         CLEAR / MAC(a,w) / READ commands
                                            |
                     FPGA prototype OR SKY130 one-PE INT4 MAC
                                            |
                         16-bit signed accumulator result
                                            |
                     host: dequantize + bias + ReLU / argmax
                                            |
                                  healthy / fault suspected

Local PC: data -> features -> PyTorch train -> INT4 export -> golden vectors
```

The MLP is **8 -> 4 -> 2** by default. First layer: 32 weights; second: 8 weights; total 40 weights and 6 biases. The host stores weights; the chip is an arithmetic coprocessor, not a self-contained trained model.

## 2. Install (Windows PowerShell / Linux / macOS)

Python 3.10+ recommended. From the extracted project folder:

```bash
python -m venv .venv
# Windows PowerShell:
.venv\Scripts\Activate.ps1
# Linux / macOS:
# source .venv/bin/activate
python -m pip install --upgrade pip
python -m pip install -r requirements.txt
```

If PyTorch needs a platform-specific CPU/CUDA wheel, follow https://pytorch.org/get-started/locally/ . CUDA is optional; this project runs on CPU.

## 3. Prove the pipeline works BEFORE using real data

```bash
python src/make_demo_data.py --out data/demo_vibration.csv
python src/pipeline.py --csv data/demo_vibration.csv --fs 4000 --out outputs/demo
python src/check_package.py --package outputs/demo/int4_package.json --vectors outputs/demo/golden_vectors.json
python -m unittest discover -s tests -v
```

The generated synthetic signals have intentionally obvious differences and are for **software integration testing only**.

## 4. Obtain the University of Ottawa dataset

Start from the published dataset landing page: https://data.mendeley.com/datasets/msxs4vj48g . Download the actual recording files and inspect their headers, channel units, recording IDs, labels, and sampling frequency. The code **does not assume an unverified archive structure** or guess the exact file names. Choose one accelerometer axis and one consistent sampling rate for the first experiment. Keep the original recordings unchanged.

Create a CSV in `data/` with the following schema:

```csv
sample,run_id,label
0.012,healthy_motor01_run01,healthy
0.018,healthy_motor01_run01,healthy
-0.005,healthy_motor01_run01,healthy
...
0.023,fault_motor02_run01,faulty
```

**Each row is ONE time sample, not a whole vibration window.** `run_id` identifies an independent acquisition recording; all rows in that run must share a label. Avoid treating overlapping windows as independent runs. For the initial binary task, map healthy recordings to `healthy` and all selected fault recordings to `faulty` **only after checking dataset labels and study design**.

If each original recording is a CSV with a named accelerometer column, create `data/manifest.csv`:

```csv
path,run_id,label,column
raw/healthy_01.csv,healthy_01,healthy,accel_x
raw/fault_01.csv,fault_01,faulty,accel_x
```

Then convert:

```bash
python src/convert_recordings.py --manifest data/manifest.csv --out data/ottawa_long.csv
```

If recordings are MAT, WAV, HDF5, or another structure, first write a format-specific importer that preserves sample order and run IDs. **Do not pretend the supplied CSV converter can read those formats.** Confirm the actual sensor sampling frequency from dataset metadata; do not use the demo 4000 Hz value for Ottawa recordings.

## 5. Train with real recordings

```bash
python src/pipeline.py --csv data/ottawa_long.csv --fs YOUR_ACTUAL_HZ --window 2048 --hop 1024 --hidden 4 --epochs 150 --out outputs/ottawa_8_4_2
```

Replace `YOUR_ACTUAL_HZ` with the numeric frequency verified from the source. To compare an 8-8-2 model, change `--hidden 8` and output directory. For 42 kHz data, 2048 samples represent only ~49 ms; the team should compare larger windows (e.g. 8192 or 16384) because mechanical fault signatures depend on operating speed and acquisition duration. These are experiment choices, not fixed recommendations.

The code computes: RMS, standard deviation, peak absolute amplitude, crest factor, excess kurtosis, skewness, 10-500 Hz relative spectral energy, and 500-5000 Hz relative spectral energy (clipped at Nyquist). **These frequency bands are placeholders to tune for actual RPM, fault types, and sensor sampling rate.** The training split alone determines standardization statistics. Runs are grouped into train/validation/test, with no run shared between splits.

**Scientific limitation:** A run-wise split does not guarantee generalization to unseen motors if the dataset uses different physical motors for each fault. Record motor ID and operating condition separately; add leave-one-motor-out or held-out operating-condition evaluation wherever the dataset permits. Do not make generalization claims otherwise.

## 6. Output files and meaning

| File | Contents |
| --- | --- |
| `model.pt` | PyTorch floating-point weights and metadata |
| `metrics.json` | Held-out floating-point and custom INT4 accuracy, balanced accuracy, confusion matrix, agreement |
| `int4_package.json` | Signed INT4 weights, floating-point scales and biases, training feature means/stds, class labels |
| `golden_vectors.json` | Normalized test features, expected output logits and abstract `CLEAR/MAC/READ` operations |

Check the INT4 model's held-out balanced accuracy, minority-class recall, and false-negative rate. There is no universal acceptable threshold; agree on the intended diagnostic use before setting one. The `int4_package.json` format is **a reference deployment package, not a directly loadable hardware binary**.

## 7. Exact INT4 arithmetic contract (v1)

* Signed operand range **[-7,+7]**, reserving -8. This is symmetric quantization, not full two's-complement INT4 range.
* One activation scale per layer, one weight scale per layer; scales = max(abs(values))/7, floored at 1e-12.
* Quantization = clip(round-to-nearest, ties-to-even, value/scale), then integer cast.
* MAC = signed integer `acc <- acc + a_int4 * w_int4`, with signed **16-bit** accumulator; overflow is an error, not silent wrap.
* Host reconstructs neuron output as `acc * activation_scale * weight_scale + float_bias`, then applies ReLU after layer 1. Host requantizes hidden outputs before layer 2.
* Final class = argmax of the two host-reconstructed logits. Softmax is unnecessary for class selection.

**Important:** This first contract leaves scales, bias, and ReLU in host floating-point. It is NOT a completely integer-only TPU inference pipeline. A later version may move host math to fixed point, but must then update reference vectors and the arithmetic contract. For the initial ASIC, only the signed INT4 MAC and 16-bit accumulator need to be implemented in the PE.

## 8. Hardware team's RTL checklist

1. Implement `CLEAR` (ACC=0), `MAC(a,w)` (signed 4x4 multiplication, 16-bit accumulation), and `READ` (signed 16-bit ACC).
2. Expose a defined clock/reset, `busy`/`ready` or equivalent handshake, and a deterministic operand acceptance rule.
3. Decide how to transmit **both 4-bit operands**, commands, and 16-bit readback using Tiny Tapeout GPIO. This kit deliberately **does not invent a pin mapping**.
4. Specify whether a MAC completes in one cycle or multiple cycles; the host must wait for completion as required.
5. Match signed extension, reset behavior, arithmetic overflow, and transaction ordering against `golden_vectors.json`.
6. Reuse exactly the same PE RTL for FPGA and SKY130, with only platform-specific top wrappers.
7. Measure cell area, timing, power estimates, and host communication overhead. Test with post-synthesis and, where possible, post-layout simulation.
8. Verify the Tiny Tapeout project template, allocated tile size, and actual shuttle submission requirements before freezing the pinout.

### A typical neuron transaction

```text
HOST: CLEAR
HOST: MAC(a0,w0)   -> PE accumulates
HOST: MAC(a1,w1)   -> PE accumulates
... repeat for all inputs ...
HOST: READ         -> receives signed 16-bit integer sum
HOST: dequantize, add bias, apply ReLU (if hidden layer)
```

The command sequence in golden vectors is **abstract**, not serialized bytes. The FPGA/ASIC team must publish a byte-level or pin-level protocol specification and a matching driver.

## 9. Work packages / ownership

**Data team:** source metadata, sensor channel, fault labels, acquisition grouping, sampling frequency, feature validation.

**ML team:** PyTorch training, baseline comparison, split integrity, INT4 metrics, exported package and reproducibility.

**RTL team:** signed MAC, accumulator, handshake, command decoder, Cocotb or equivalent golden-vector checks.

**Integration team:** host firmware, operand streaming, model execution, end-to-end latency and power/area reporting.

**Tapeout lead:** run official Tiny Tapeout checks, freeze the interface, enforce design/verification signoff ahead of Nov 30.

## 10. Completion gates

- [ ] Synthetic smoke test and Python unit tests pass.
- [ ] Real Ottawa recordings converted with verified sampling frequency and labels.
- [ ] Group-safe evaluation and documented motor/run IDs.
- [ ] Floating-point and INT4 accuracy measured on untouched test recordings.
- [ ] All exported golden vectors reproduce exactly in Python.
- [ ] RTL matches each integer MAC and accumulator readback in the golden vectors.
- [ ] FPGA demonstration runs end-to-end with host-supplied weights.
- [ ] SKY130 area/timing and official shuttle checks pass.
- [ ] Final version/tag, data provenance, and model hashes archived.

## 11. References

- University of Ottawa motor dataset landing page: https://data.mendeley.com/datasets/msxs4vj48g
- PyTorch documentation: https://pytorch.org/docs/stable/index.html
- Tiny Tapeout documentation: https://tinytapeout.com/

**Version status:** working software starter kit, not verified motor-fault diagnostic system or tapeout-ready RTL.
