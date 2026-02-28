# Reproducibility Checklist

## PPE Compliance Detection System — Group 5 (MAICEN-1125)

### Run Details

| Field | Value |
|-------|-------|
| **Date** | 1 March 2026 |
| **Author** | Group 5 |
| **GPU** | NVIDIA RTX 4000 Ada Generation Laptop GPU (12GB VRAM) |
| **OS** | Windows |
| **Training Time** | ~35 minutes |
| **Total Pipeline Time** | ~45 minutes (pseudo-labeling + training) |

### Software Versions

| Package | Version |
|---------|---------|
| Python | 3.11.9 |
| PyTorch | 2.6.0+cu124 |
| CUDA | 12.4 |
| Ultralytics | 8.4.18 |
| albumentations | (latest via pip) |
| scikit-learn | (latest via pip) |
| opencv-python-headless | (latest via pip) |

### Dataset

| Field | Value |
|-------|-------|
| **Source** | MAICEN XML annotations (Pascal VOC format) |
| **Total Images** | 5,000 |
| **Train Split** | 4,696 images (with oversampling) |
| **Val Split** | 750 images |
| **Test Split** | 750 images |
| **Split Method** | Stratified 80/20, no data leakage verified |
| **Total Labels** | 28,460 |
| **Helmet Labels** | 16,195 (XML) |
| **Head Labels** | 4,850 (XML) |
| **SafetyVest Labels** | 3,206 (pseudo-labeled) |
| **Goggles Labels** | 4,209 (pseudo-labeled) |
| **Roboflow** | [ppe-detection-group5](https://app.roboflow.com/mark-shane-haines-zigurat/ppe-detection-group5) |

### Training Configuration

| Parameter | Value |
|-----------|-------|
| **Model** | YOLOv8m (25.9M params) |
| **Pre-trained** | COCO |
| **Epochs** | 30 |
| **Batch Size** | 16 |
| **Image Size** | 640 x 640 |
| **Optimizer** | Auto (SGD) |
| **Learning Rate** | 0.01 (cosine decay to 0.01) |
| **Patience** | 7 (early stopping) |
| **Augmentation** | Mosaic, RandAugment, horizontal flip, HSV jitter |
| **Confidence Threshold** | 0.25 |
| **Seed** | 0 (deterministic) |

### Results (Best Epoch: 30)

| Metric | Value |
|--------|-------|
| **mAP50** | 0.742 |
| **mAP50-95** | 0.470 |
| **Precision** | 0.735 |
| **Recall** | 0.729 |

### Per-Class Performance

| Class | Precision | Recall | F1 Score | mAP50 | Source |
|-------|-----------|--------|----------|-------|--------|
| Helmet | 0.923 | 0.941 | 0.932 | 0.970 | XML |
| Head | 0.880 | 0.919 | 0.899 | 0.930 | XML |
| SafetyVest | 0.553 | 0.778 | 0.647 | 0.714 | Pseudo-labeled |
| Goggles | 0.474 | 0.354 | 0.405 | 0.332 | Pseudo-labeled |

### Artifacts

| Artifact | Location |
|----------|----------|
| **Notebook** | `notebooks/MAICEN_1125_M4_U4_Group_5_Assignment.ipynb` |
| **Model Weights** | [GitHub Release v1.0](https://github.com/markshanehaines-ZIG/ppe-detection-group5/releases/tag/v1.0) |
| **Training Plots** | `results/training_plots/` |
| **Dataset (Roboflow)** | [ppe-detection-group5](https://app.roboflow.com/mark-shane-haines-zigurat/ppe-detection-group5) |

### How to Reproduce

1. Clone the repository
2. Download the dataset from Roboflow or place XML annotations and images in `./ppe_dataset/annotations/` and `./ppe_dataset/images/`
3. Open the notebook in VS Code (with Jupyter + Python extensions) or Google Colab
4. Install dependencies: run the Setup cell
5. Install PyTorch with CUDA: `pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu124`
6. Run all cells sequentially — pseudo-labeling generates SafetyVest and Goggles labels at runtime
7. Training will produce `best.pt` in `runs/detect/models/multi_ppe_detector/weights/`
