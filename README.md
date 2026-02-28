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

> **Note:** SafetyVest and Goggles were not in the original dataset. They were generated using our pseudo-labeling pipeline — this is the key innovation of this project (see Section 3).

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

> **Note:** XML-annotated classes (Helmet, Head) achieve strong F1 > 0.89 and mAP50 > 0.93. Pseudo-labeled classes show promising results given zero manual annotation — SafetyVest achieves mAP50 of 0.714, while Goggles (0.332) reflects the difficulty of detecting small objects from edge-based heuristics.

### Training Curves

See `results/training_plots/` for loss curves, P/R curves, F1 curves, and confusion matrices.

---

## 6 · Repository Structure

```
├── README.md                         ← You are here
├── LICENSE                           ← MIT License
├── notebooks/
│   └── MAICEN_1125_M4_U4_Group_5_Assignment.ipynb  ← Full training notebook
├── docs/
│   ├── error_analysis.md             ← FP/FN analysis & improvements
│   ├── governance_checklist.md       ← Privacy, ethics, limitations
│   └── reproducibility_checklist.md  ← Exact versions, hardware, metrics
├── results/
│   ├── evidence/
│   │   ├── annotation_examples/      ← Sample annotated images
│   │   ├── validation_predictions/   ← Model predictions on val set
│   │   └── new_image_predictions/    ← Predictions on unseen images
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
│   └── PPE_Detection_Report.pdf      ← 2-page summary report
└── releases/
    └── v1.0                          ← best.pt model weights (GitHub Release)
```

---

## 7 · Reproduce This Project

### Prerequisites

- Python 3.11+
- NVIDIA GPU with CUDA support (tested on RTX 4000 Ada, 12GB VRAM)
- VS Code with Jupyter extension (or Google Colab with T4 GPU)

### Step-by-step

```
1. Clone this repository:
   git clone https://github.com/markshanehaines-ZIG/ppe-detection-group5.git

2. Download the dataset from Roboflow or place XML annotations and images in:
   ./ppe_dataset/annotations/
   ./ppe_dataset/images/

3. Open the notebook:
   notebooks/MAICEN_1125_M4_U4_Group_5_Assignment.ipynb

4. Install PyTorch with CUDA:
   pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu124

5. Run all cells sequentially:
   - Pseudo-labeling generates SafetyVest and Goggles labels at runtime (~60-90 min)
   - Training completes in ~35 minutes on RTX 4000 Ada

6. Model weights saved to:
   runs/detect/models/multi_ppe_detector/weights/best.pt
```

### Reproducibility Checklist

See `docs/reproducibility_checklist.md` for exact software versions, hardware specs, and verified metrics.

---

## 8 · Error Analysis

Full analysis in `docs/error_analysis.md`.

Summary (following the AECO Error Taxonomy from Session 3):

- **3 False Positives** — e.g., yellow objects mistaken for helmets
- **3 False Negatives** — e.g., partially occluded bare heads missed
- **2 Class Confusions** — e.g., beanie misclassified as helmet (critical safety inversion)
- **2 Localization Errors** — e.g., oversized bounding boxes merging adjacent workers
- **5 Improvement Recommendations** prioritised by safety impact

---

## 9 · Governance & Ethics

Full checklist in `docs/governance_checklist.md`.

Key points:

- **Privacy:** No facial recognition — system detects PPE equipment and head outlines only. All training images are from public, openly-licensed datasets.
- **Data minimisation:** Bounding box detections are stored, not raw video. No personal identification is performed or stored.
- **Limitations:** Model trained on daylight imagery — reduced performance expected at night or in heavy rain. Not a replacement for human safety officers.
- **Bias:** Dataset reflects specific construction contexts. Performance may degrade on unfamiliar PPE styles (e.g., full-sleeve vests, non-standard colours).

---

## 10 · Disclaimer

> ⚠️ This model is an assistive tool for preliminary screening only. It produces False Negatives. It must **NOT** be used as the sole verifier for life-safety decisions.

This system is designed to **supplement — not replace** — manual PPE inspections conducted by qualified safety professionals.

---

## 11 · License

This project is licensed under the **MIT License** — see `LICENSE` for details.

- **Dataset:** The MAICEN dataset is sourced from [github.com/docilio/MAICEN](https://github.com/docilio/MAICEN). Please refer to the original repository for dataset licensing terms.
- **YOLOv8:** Ultralytics YOLOv8 is licensed under AGPL-3.0. Academic and research use is permitted. For commercial deployment, consult the [Ultralytics licensing page](https://ultralytics.com/license).

---

## 12 · Team

| Member | Role |
|--------|------|
| Mark Shane Haines | Project Lead |
| Letícia Cristovam Clemente | *TBD* |
| Malak Yaseen | *TBD* |
| Marc Azzam | *TBD* |
| Osama Ata | *TBD* |

**Group 5** — Zigurat Institute of Technology, MAICEN 1125

> **Roles to assign:** Dataset & Annotation Lead · Model Training Lead · Error Analysis & Evidence Lead · Governance & Presentation Lead

---

## 13 · References

- Ultralytics YOLOv8 — [github.com/ultralytics/ultralytics](https://github.com/ultralytics/ultralytics)
- MAICEN Dataset — [github.com/docilio/MAICEN](https://github.com/docilio/MAICEN)
- Roboflow Annotation Platform — [roboflow.com](https://roboflow.com/)
- Redmon, J. et al. (2016). *You Only Look Once: Unified, Real-Time Object Detection.* [arxiv.org/abs/1506.02640](https://arxiv.org/abs/1506.02640)
- Eurostat (2023). *Accidents at work statistics.* [ec.europa.eu/eurostat](https://ec.europa.eu/eurostat)
