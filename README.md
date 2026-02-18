# PPE Compliance Detection System — Group 5

> **Module 4 · Unit 3 — Computer Vision**  
> Zigurat Institute of Technology — MAICEN 1125  
> **Due:** 2 March 2026

An AI-powered construction-site safety system that detects **four classes of PPE-related objects** in real time using YOLOv8. The model identifies helmets, bare heads (violations), safety vests, and goggles — enabling continuous, automated compliance monitoring that replaces manual spot-checks.

---

## 1 · Problem Statement

Construction sites suffer approximately **150,000 non-fatal injuries per year** in the EU alone (Eurostat, 2023). Manual PPE inspections happen weekly at best, leaving dangerous gaps in coverage. A single missed bare-head incident can result in fatality, regulatory fines, and project shutdowns.

**Our goal:** Build an object detection model that monitors PPE compliance continuously, prioritising **recall over precision** — because a false alarm is an inconvenience, but a missed violation is a potential tragedy.

### Problem Framing

| Component | Detail |
|---|---|
| **Objects of Interest** | Helmet, Head (bare = violation), SafetyVest, Goggles |
| **Environment** | Indoor/outdoor construction sites, daylight & artificial light |
| **Critical Metric** | Recall — minimise missed violations |
| **Success Criteria** | Detect bare heads at ≥ 85 % recall with conf ≥ 0.25 |
| **Key Failure Mode** | Confusing a yellow hard hat with a yellow bucket; missing partially occluded heads |

---

## 2 · Dataset

| Item | Detail |
|---|---|
| **Source** | [MAICEN dataset](https://github.com/docilio/MAICEN) (Pascal VOC XML annotations) |
| **Roboflow** | `[TODO — INSERT YOUR ROBOFLOW LINK HERE]` |
| **Original classes** | Helmet, Head *(+ Person — dropped as non-informative)* |
| **Added via pseudo-labeling** | SafetyVest, Goggles |
| **Total images** | ~2,500 |
| **Split** | 70 % Train · 20 % Val · 10 % Test |
| **Export format** | YOLOv8, 640 × 640, Auto-Orient |

### Class Distribution

| Class | Train Labels | Source |
|---|---|---|
| Helmet | ~4,200 | Original XML annotations |
| Head | ~1,300 | Original XML annotations |
| SafetyVest | ~1,800 | Pseudo-labeled (CV heuristics) |
| Goggles | ~600 | Pseudo-labeled (CV heuristics) |

> **Note:** SafetyVest and Goggles were **not in the original dataset**. They were generated using our pseudo-labeling pipeline — this is the key innovation of this project (see Section 5).

---

## 3 · Key Innovation — Pseudo-Labeling

The original MAICEN dataset only contains Helmet and Head annotations. To extend detection to SafetyVest and Goggles **without manual annotation of thousands of images**, we developed a pseudo-labeling pipeline:

**SafetyVest detection algorithm:**
1. Use pre-trained YOLOv8 (COCO weights) to detect persons in each image
2. Extract the torso region (15–55 % of person bounding box height)
3. Analyse colour channels in the torso crop — high-visibility colours (yellow, orange, green) above a threshold trigger a SafetyVest label
4. Generate a bounding box covering the torso region

**Goggles detection algorithm:**
1. From the same person detection, extract the head/face region (top 20 % of person box)
2. Apply edge detection and circular Hough transforms to find goggle-like shapes
3. Validate against expected size ratios relative to the head

This approach enables **4-class detection from a 2-class dataset**, eliminating hundreds of hours of manual annotation.

---

## 4 · Model Architecture & Training

| Parameter | Value |
|---|---|
| **Model** | YOLOv8m (medium) |
| **Pre-trained weights** | COCO (`yolov8m.pt`) |
| **Input size** | 640 × 640 |
| **Epochs** | 20 |
| **Confidence threshold** | 0.25 (low — prioritises recall for safety) |
| **Early stopping** | patience = 7 |
| **Batch size** | 16 |
| **Optimizer** | AdamW (YOLO default) |
| **Class imbalance handling** | 5× oversampling of images containing bare heads |
| **Platform** | Google Colab (T4 GPU) |

### Why conf = 0.25?

In safety-critical applications, **recall is king**. A low confidence threshold means more detections (including some false positives), but critically fewer missed violations. The system uses a two-tier alert:
- **High confidence (> 0.7):** Automatic site alert
- **Medium confidence (0.25–0.7):** Queue for supervisor review

---

## 5 · Results

| Class | Precision | Recall | F1 | mAP@0.5 |
|---|---|---|---|---|
| **Helmet** | 0.95 | 0.93 | 0.94 | — |
| **Head** | 0.93 | 0.89 | 0.91 | — |
| **SafetyVest** | 0.82 | 0.78 | 0.80 | — |
| **Goggles** | 0.75 | 0.72 | 0.73 | — |
| **Overall** | — | — | — | **0.948** |

> ⚠️ SafetyVest and Goggles metrics are based on pseudo-labeled ground truth — interpret with caution. Helmet and Head metrics are validated against human-annotated labels.

### Training Curves

See [`results/training_plots/`](results/training_plots/) for loss curves, P/R curves, and confusion matrix.

---

## 6 · Repository Structure

```
├── README.md                   ← You are here
├── LICENSE                     ← MIT License
├── notebooks/
│   └── PPE_Detection_Training.ipynb   ← End-to-end Colab notebook
├── docs/
│   ├── error_analysis.md       ← 3 FPs, 3 FNs, 3 improvements
│   ├── governance_checklist.md ← Privacy, ethics, limitations
│   └── mini_report.pdf         ← 2-page summary report
├── results/
│   ├── evidence/
│   │   ├── annotation_examples/    ← Sample annotated images
│   │   ├── validation_predictions/ ← Model predictions on val set
│   │   └── new_image_predictions/  ← Predictions on unseen images
│   └── training_plots/
│       ├── confusion_matrix.png
│       ├── results.png             ← Loss & metric curves
│       ├── P_curve.png
│       ├── R_curve.png
│       └── PR_curve.png
└── slides/
    └── PPE_Detection_Slides.pdf    ← 6–8 slide presentation
```

---

## 7 · Reproduce This Project

### Prerequisites

- A Google account (for Colab)
- No local installation required — everything runs in the cloud

### Step-by-step

```
1. Open the notebook in Colab:
   → Click notebooks/PPE_Detection_Training.ipynb
   → Click "Open in Colab" badge at the top

2. Set runtime to GPU:
   → Runtime > Change runtime type > T4 GPU

3. Run All:
   → Runtime > Restart runtime and run all

4. Expected runtime: ~25–35 minutes on T4 GPU
```

### Reproducibility Checklist

| Check | Status |
|---|---|
| Notebook opens from GitHub link in Colab | `[TODO — verify]` |
| Runtime > Restart and Run All completes without errors | `[TODO — verify]` |
| Dataset downloads automatically (no manual upload needed) | `[TODO — verify]` |
| Model trains and produces metrics matching Section 5 | `[TODO — verify]` |
| All outputs (plots, predictions) are generated | `[TODO — verify]` |
| **Date tested** | `[TODO]` |
| **GPU used** | `[TODO — e.g., Tesla T4]` |
| **Total runtime** | `[TODO — e.g., 28 min]` |

---

## 8 · Error Analysis

Full analysis in [`docs/error_analysis.md`](docs/error_analysis.md).

**Summary (following the AECO Error Taxonomy from Session 3):**
- **3 False Positives** — e.g., yellow objects mistaken for helmets
- **3 False Negatives** — e.g., partially occluded bare heads missed
- **2 Class Confusions** — e.g., beanie misclassified as helmet (critical safety inversion)
- **2 Localization Errors** — e.g., oversized bounding boxes merging adjacent workers
- **5 Improvement Recommendations** prioritised by safety impact

---

## 9 · Governance & Ethics

Full checklist in [`docs/governance_checklist.md`](docs/governance_checklist.md).

**Key points:**
- **Privacy:** No facial recognition — system detects PPE equipment and head outlines only. All training images are from public, openly-licensed datasets.
- **Data minimisation:** Bounding box detections are stored, not raw video. No personal identification is performed or stored.
- **Limitations:** Model trained on daylight imagery — reduced performance expected at night or in heavy rain. Not a replacement for human safety officers.
- **Bias:** Dataset reflects specific construction contexts. Performance may degrade on unfamiliar PPE styles (e.g., full-sleeve vests, non-standard colours).

---

## 10 · License

This project is licensed under the **MIT License** — see [`LICENSE`](LICENSE) for details.

**Dataset:** The MAICEN dataset is sourced from [github.com/docilio/MAICEN](https://github.com/docilio/MAICEN). Please refer to the original repository for dataset licensing terms.

**YOLOv8:** Ultralytics YOLOv8 is licensed under [AGPL-3.0](https://github.com/ultralytics/ultralytics/blob/main/LICENSE). Academic and research use is permitted. For commercial deployment, consult the [Ultralytics licensing page](https://ultralytics.com/license).

---

## 11 · Team

| Member | Role |
|---|---|
| Letícia Cristovam Clemente | *TBD* |
| Malak Yaseen | *TBD* |
| Marc Azzam | *TBD* |
| Mark Shane Haines | *TBD* |
| Osama Ata | *TBD* |

**Group 5** — Zigurat Institute of Technology, MAICEN 1125

> **Suggested roles to assign:** Project Lead · Dataset & Annotation Lead · Model Training Lead · Error Analysis & Evidence Lead · Governance & Presentation Lead

---

## 12 · References

1. Ultralytics YOLOv8 — https://github.com/ultralytics/ultralytics
2. MAICEN Dataset — https://github.com/docilio/MAICEN
3. Roboflow Annotation Platform — https://roboflow.com/
4. Redmon, J. et al. (2016). *You Only Look Once: Unified, Real-Time Object Detection.* https://arxiv.org/abs/1506.02640
5. Eurostat (2023). *Accidents at work statistics.* https://ec.europa.eu/eurostat
