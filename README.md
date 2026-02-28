# PPE Compliance Detection System — Group 5

**Module 4 · Unit 4 — Computer Vision**
**Zigurat Institute of Technology — MAICEN 1125**
**Submitted: 2 March 2026**

An AI-powered construction-site safety system that detects four classes of PPE-related objects in real time using YOLOv8. The model identifies helmets, bare heads (violations), safety vests, and goggles — enabling continuous, automated compliance monitoring that replaces manual spot-checks.

---

## 1 · Problem Statement

Construction sites suffer approximately 150,000 non-fatal injuries per year in the EU alone (Eurostat, 2023). Manual PPE inspections happen weekly at best, leaving dangerous gaps in coverage. A single missed bare-head incident can result in fatality, regulatory fines, and project shutdowns.

**Our goal:** Build an object detection model that monitors PPE compliance continuously, prioritising recall over precision — because a false alarm is an inconvenience, but a missed violation is a potential tragedy.

### Problem Framing

| Component | Detail |
|-----------|--------|
| Objects of Interest | Helmet, Head (bare = violation), SafetyVest, Goggles |
| Environment | Indoor/outdoor construction sites, daylight & artificial light |
| Critical Metric | Recall — minimise missed violations |
| Success Criteria | Detect bare heads at ≥ 85% recall with conf ≥ 0.25 |
| Key Failure Mode | Confusing a yellow hard hat with a yellow bucket; missing partially occluded heads |

---

## 2 · Dataset

| Item | Detail |
|------|--------|
| Source | MAICEN dataset (Pascal VOC XML annotations) |
| Roboflow | [PPE-Detection-Group5](https://app.roboflow.com/mark-shane-haines-zigurat/ppe-detection-group5) |
| Original classes | Helmet, Head (+ Person — dropped as non-informative) |
| Added via pseudo-labeling | SafetyVest, Goggles |
| Total images | ~4,250 (after augmentation and oversampling) |
| Train split | 4,696 images |
| Val split | 750 images |
| Export format | YOLOv8, 640 × 640 |

### Class Distribution

| Class | Labels | Source |
|-------|--------|--------|
| Helmet | 16,195 | Original XML annotations |
| Head | 4,850 | Original XML annotations |
| SafetyVest | 3,206 | Pseudo-labeled (HSV color segmentation) |
| Goggles | 4,209 | Pseudo-labeled (Canny edge detection) |
| **Total** | **28,460** | |

> **Note:** SafetyVest and Goggles were not in the original dataset. They were generated using our pseudo-labeling pipeline — this is the key innovation of this project (see Section 3). Full class definitions and label rules are documented in [`docs/class_definitions.md`](docs/class_definitions.md).

---

## 3 · Key Innovation — Pseudo-Labeling

The original MAICEN dataset only contains Helmet and Head annotations. To extend detection to SafetyVest and Goggles without manual annotation of thousands of images, we developed a pseudo-labeling pipeline:

**SafetyVest detection algorithm:**
1. Identify person bounding boxes from existing annotations
2. Extract the torso region (15–55% of person bounding box height)
3. Convert to HSV color space — high-visibility colours (yellow, orange, green) above threshold (0.15) trigger a SafetyVest label
4. Generate a bounding box covering the torso region

**Goggles detection algorithm:**
1. From detected heads, extract the eye region (top portion of head box)
2. Apply Canny edge detection to find circular patterns characteristic of safety goggles
3. Validate against expected size ratios relative to the head (threshold: 0.45)

This approach enables 4-class detection from a 2-class dataset, generating 7,415 additional labels without any manual annotation.

### SAM Exploration

We explored Meta's Segment Anything Model (SAM) as a potential tool for improving pseudo-label quality. SAM produced cleaner vest segmentation masks but could not classify objects (helmet vs head vs other), making it unsuitable as a standalone detector. Runtime on Colab was also prohibitive (~2s per image). See [`docs/sam_exploration.md`](docs/sam_exploration.md) for full notes on what helped and what failed.

---

## 4 · Model Architecture & Training

| Parameter | Value |
|-----------|-------|
| Model | YOLOv8m (medium, 25.9M parameters) |
| Pre-trained weights | COCO (yolov8m.pt) |
| Input size | 640 × 640 |
| Epochs | 30 |
| Confidence threshold | 0.25 (low — prioritises recall for safety) |
| Early stopping | patience = 7 |
| Batch size | 16 |
| Optimizer | Auto (SGD with cosine LR decay) |
| Class imbalance handling | Oversampling of images containing bare heads |
| GPU | NVIDIA RTX 4000 Ada Generation (12GB VRAM) |
| Training time | ~35 minutes |

### Why conf = 0.25?

In safety-critical applications, recall is king. A low confidence threshold means more detections (including some false positives), but critically fewer missed violations. The system uses a two-tier alert:

- **High confidence (> 0.7):** Automatic site alert
- **Medium confidence (0.25–0.7):** Queue for supervisor review

---

## 5 · Results

### Overall Metrics

| Metric | Value |
|--------|-------|
| mAP50 | 0.742 |
| mAP50-95 | 0.470 |
| Precision | 0.735 |
| Recall | 0.729 |

### Per-Class Performance

| Class | Precision | Recall | F1 Score | mAP50 | Source |
|-------|-----------|--------|----------|-------|--------|
| Helmet | 0.923 | 0.941 | 0.932 | 0.970 | XML annotations |
| Head | 0.880 | 0.919 | 0.899 | 0.930 | XML annotations |
| SafetyVest | 0.553 | 0.778 | 0.647 | 0.714 | Pseudo-labeled |
| Goggles | 0.474 | 0.354 | 0.405 | 0.332 | Pseudo-labeled |

**Key takeaways:**

1. XML-annotated classes (Helmet, Head) achieve strong F1 > 0.89 and mAP50 > 0.93, exceeding our success criteria for Head recall (0.919 > 0.85 target).
2. Pseudo-labeled classes show promising results given zero manual annotation — SafetyVest achieves mAP50 of 0.714, while Goggles (0.332) reflects the difficulty of detecting small objects from edge-based heuristics.
3. The safety-critical Head class achieves 91.9% recall, meaning the model catches over 9 in 10 bare-head violations.

### Training Curves

See `results/training_plots/` for loss curves, P/R curves, F1 curves, and confusion matrices.

---

## 6 · Repository Structure

```
├── README.md                         ← You are here
├── LICENSE                           ← MIT License
├── notebooks/
│   └── MAICEN_1125_M4_U4_Group_5_Assignment.ipynb  ← Full training + eval notebook
├── docs/
│   ├── class_definitions.md          ← Class list + label rules
│   ├── error_analysis.md             ← FP/FN analysis & improvements
│   ├── governance_checklist.md       ← Privacy, ethics, limitations
│   ├── reproducibility_checklist.md  ← Exact versions, hardware, metrics
│   └── sam_exploration.md            ← SAM exploration notes
├── results/
│   ├── evidence/
│   │   ├── annotation_examples/      ← 5 annotated training images
│   │   ├── validation_predictions/   ← 10 val prediction screenshots
│   │   └── new_image_predictions/    ← 5 new-image prediction screenshots
│   └── training_plots/
│       ├── results.png               ← Loss & metric curves
│       ├── confusion_matrix.png
│       ├── confusion_matrix_normalized.png
│       ├── BoxF1_curve.png
│       ├── BoxPR_curve.png
│       ├── BoxP_curve.png
│       ├── BoxR_curve.png
│       ├── labels.jpg
│       ├── predictions_4class.png
│       ├── confusion_matrix_4class.png
│       └── samples_groundtruth.png
├── slides/
│   ├── PPE_Detection_Slides.pptx     ← 8-slide presentation
│   ├── PPE_Detection_Slides.pdf      ← Slides exported as PDF
│   └── PPE_Detection_Report.pdf      ← 2-page summary report
└── releases/
    └── v1.0                          ← best.pt model weights (GitHub Release)
```

---

## 7 · How to Reproduce

### Option A: Google Colab (Recommended for reviewers)

1. Open the notebook from GitHub: [`notebooks/MAICEN_1125_M4_U4_Group_5_Assignment.ipynb`](notebooks/MAICEN_1125_M4_U4_Group_5_Assignment.ipynb)
2. Click **"Open in Colab"** (badge at top of notebook) or paste the GitHub URL into [colab.research.google.com](https://colab.research.google.com)
3. Go to **Runtime → Change runtime type → T4 GPU**
4. Run the **Setup** cell to install all dependencies (`ultralytics`, `albumentations`, etc.)
5. **Full training path** (~2–3 hours on T4): Run all cells sequentially. The notebook handles pseudo-labeling, dataset creation, training, and evaluation.
6. **Verification path** (~10 minutes, if GPU unavailable or time-limited):
   - Download `best.pt` from [GitHub Releases v1.0](https://github.com/markshanehaines-ZIG/ppe-detection-group5/releases/tag/v1.0)
   - Upload to the Colab session files panel
   - Skip the training cell — the notebook auto-detects existing weights and loads them
   - Run evaluation + inference cells to verify metrics and predictions

### Option B: Local Setup (VS Code + Jupyter)

1. Clone this repository:
   ```bash
   git clone https://github.com/markshanehaines-ZIG/ppe-detection-group5.git
   ```
2. Download the dataset from [Roboflow](https://app.roboflow.com/mark-shane-haines-zigurat/ppe-detection-group5) or place XML annotations and images in `./ppe_dataset/annotations/` and `./ppe_dataset/images/`
3. Install PyTorch with CUDA:
   ```bash
   pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu124
   ```
4. Open the notebook in VS Code with Jupyter + Python extensions
5. Run all cells sequentially (~45 minutes total on RTX 4000 Ada)

### Reproducibility Checklist (Summary)

| Parameter | Value |
|-----------|-------|
| Dataset version | Roboflow PPE-Detection-Group5 (4-class, 640×640) |
| Dataset link | [app.roboflow.com/mark-shane-haines-zigurat/ppe-detection-group5](https://app.roboflow.com/mark-shane-haines-zigurat/ppe-detection-group5) |
| Model variant | YOLOv8m (yolov8m.pt) |
| Epochs | 30 |
| Batch size | 16 |
| Image size | 640 × 640 |
| Ultralytics | 8.4.18 |
| PyTorch | 2.6.0+cu124 |
| Python | 3.11.9 |
| Seed | 0 (deterministic) |

Full checklist with all versions and hardware specs: [`docs/reproducibility_checklist.md`](docs/reproducibility_checklist.md)

---

## 8 · Reproducibility Proof

| Field | Value |
|-------|-------|
| **Date of last successful run** | 1 March 2026, 14:30 NZDT |
| **GPU used** | NVIDIA RTX 4000 Ada Generation Laptop GPU (12GB VRAM) |
| **CUDA version** | 12.4 |
| **Training runtime** | ~35 minutes (30 epochs, full training) |
| **Total pipeline runtime** | ~45 minutes (pseudo-labeling + training) |
| **Expected Colab runtime** | ~2–3 hours on T4 GPU (full training); ~10 min (verification with pre-trained weights) |
| **Status** | ✅ All cells execute without error. Metrics match reported values. |

> **Note:** If Colab GPU is unavailable, you may run a short 5-epoch verification run to confirm the pipeline functions correctly, then load our pre-trained `best.pt` weights from GitHub Releases v1.0 for full evaluation and inference. This approach is documented in the notebook with clear cell-level instructions.

---

## 9 · Error Analysis

Full analysis in [`docs/error_analysis.md`](docs/error_analysis.md).

Summary (following the AECO Error Taxonomy):

- **3 False Positives** — e.g., yellow objects mistaken for helmets, safety poster triggering detection
- **3 False Negatives** — e.g., partially occluded bare heads missed, backlit helmets undetected
- **2 Class Confusions** — e.g., beanie misclassified as helmet (critical safety inversion)
- **2 Localization Errors** — e.g., oversized bounding boxes merging adjacent workers
- **5 Improvement Recommendations** prioritised by safety impact

---

## 10 · Governance & Ethics

Full checklist in [`docs/governance_checklist.md`](docs/governance_checklist.md).

Key points:

- **Privacy:** No facial recognition — system detects PPE equipment and head outlines only. All training images are from public, openly-licensed datasets.
- **Data minimisation:** Bounding box detections are stored, not raw video. No personal identification is performed or stored.
- **Limitations:** Model trained on daylight imagery — reduced performance expected at night or in heavy rain. Not a replacement for human safety officers.
- **Bias:** Dataset reflects specific construction contexts. Performance may degrade on unfamiliar PPE styles (e.g., full-sleeve vests, non-standard colours).

---

## 11 · Short PDF Pack

Both documents are available in the `slides/` folder and linked here:

- **Slides (PDF):** [`slides/PPE_Detection_Slides.pdf`](slides/PPE_Detection_Slides.pdf) — 8 slides covering problem, method, results, and conclusions
- **Mini Report (PDF):** [`slides/PPE_Detection_Report.pdf`](slides/PPE_Detection_Report.pdf) — 2-page executive summary with results and limitations

---

## 12 · Disclaimer

> ⚠️ This model is an assistive tool for preliminary screening only. It produces False Negatives. It must **NOT** be used as the sole verifier for life-safety decisions.

This system is designed to **supplement — not replace** — manual PPE inspections conducted by qualified safety professionals.

---

## 13 · License

This project is licensed under the **MIT License** — see `LICENSE` for details.

- **Dataset:** The MAICEN dataset is sourced from [github.com/docilio/MAICEN](https://github.com/docilio/MAICEN). Please refer to the original repository for dataset licensing terms.
- **YOLOv8:** Ultralytics YOLOv8 is licensed under AGPL-3.0. Academic and research use is permitted. For commercial deployment, consult the [Ultralytics licensing page](https://ultralytics.com/license).

---

## 14 · Team

| Member | Role |
|--------|------|
| Mark Shane Haines | Project Lead |
| Letícia Cristovam Clemente | Dataset & Annotation Lead |
| Malak Yaseen | Model Training Lead |
| Marc Azzam | Error Analysis & Evidence Lead |
| Osama Ata | Governance & Presentation Lead |

**Group 5** — Zigurat Institute of Technology, MAICEN 1125

---

## 15 · References

- Ultralytics YOLOv8 — [github.com/ultralytics/ultralytics](https://github.com/ultralytics/ultralytics)
- MAICEN Dataset — [github.com/docilio/MAICEN](https://github.com/docilio/MAICEN)
- Roboflow Annotation Platform — [roboflow.com](https://roboflow.com/)
- Segment Anything Model (SAM) — [github.com/facebookresearch/segment-anything](https://github.com/facebookresearch/segment-anything)
- Redmon, J. et al. (2016). *You Only Look Once: Unified, Real-Time Object Detection.* [arxiv.org/abs/1506.02640](https://arxiv.org/abs/1506.02640)
- Eurostat (2023). *Accidents at work statistics.* [ec.europa.eu/eurostat](https://ec.europa.eu/eurostat)

---

## License

**Code:** MIT License — see [LICENSE](LICENSE)

**Dataset:** [Safety Helmet Detection (SHD)](https://www.kaggle.com/datasets/andrewmvd/hard-hat-detection) by Andrew Maranhão, released under [CC0 1.0](https://creativecommons.org/publicdomain/zero/1.0/) (public domain). SafetyVest and Goggles pseudo-labels were generated by our pipeline.

**Model weights:** Released under MIT License.
