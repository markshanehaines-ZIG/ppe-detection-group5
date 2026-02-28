# SAM Exploration Notes — PPE Detection System

**Group 5 · M4U4 Computer Vision**

---

## What is SAM?

The Segment Anything Model (SAM), developed by Meta AI, is a foundation model for image segmentation. Unlike YOLOv8 which outputs bounding boxes, SAM produces pixel-level segmentation masks. We explored SAM as a potential tool for improving our pseudo-labeling pipeline and annotation quality.

---

## What We Tried

### 1. SAM for Refining Pseudo-Label Bounding Boxes

**Goal:** Use SAM to generate tighter bounding boxes for SafetyVest and Goggles pseudo-labels, since our HSV/Canny pipeline produces approximate boxes.

**Method:** Fed our pseudo-labeled bounding box centres as point prompts into SAM to obtain pixel-accurate segmentation masks, then derived tighter bounding boxes from the mask boundaries.

**Result:** SAM produced reasonable masks for SafetyVest regions where there was clear colour contrast between the vest and background. However, it struggled with goggles due to their small size and low contrast against skin/hair.

### 2. SAM for Annotation Quality Checking

**Goal:** Use SAM's automatic mask generation to cross-check whether our Helmet and Head bounding boxes aligned well with the actual objects.

**Method:** Ran SAM's automatic mask generator on a sample of 50 images and compared the generated masks with our XML-derived bounding boxes.

**Result:** SAM correctly segmented helmets in most cases (especially when they were brightly coloured and well-separated from the background). Head segmentation was less reliable because SAM often merged the head with the neck/shoulders into a single "person" mask.

### 3. SAM for Zero-Shot PPE Detection

**Goal:** Test whether SAM could detect PPE classes without any training data, using only text or point prompts.

**Method:** Used SAM with various prompt strategies (point prompts on known helmet locations, box prompts around person regions).

**Result:** SAM is a segmentation model, not a classification model. It can segment objects well but cannot classify them as "helmet" vs "head" vs "other headwear." This means SAM alone cannot replace a trained detector like YOLOv8 for our PPE compliance use case.

---

## What Helped

- **Vest segmentation quality:** SAM produced cleaner vest outlines than our HSV-based approach, especially when workers were standing against cluttered backgrounds. The pixel-level masks gave more precise boundaries.
- **Helmet isolation:** SAM could cleanly separate a helmet from the sky/scaffolding behind it, which is useful for generating training masks if we ever move to instance segmentation.
- **Annotation validation:** Comparing SAM masks against our bounding boxes helped identify 3–4 images where the XML annotations had incorrect coordinates (boxes shifted by several pixels).

## What Failed

- **Goggles detection:** SAM could not reliably segment goggles. The objects are too small (typically < 30×30 pixels) and blend with facial features. Point prompts on goggle regions often returned masks covering the entire face.
- **Classification capability:** SAM has no concept of PPE classes. It can outline an object but cannot tell you whether it is a helmet, a bucket, or a beanie. For compliance monitoring, classification is essential.
- **Runtime on Colab:** SAM (ViT-H variant) required significant GPU memory and took ~2 seconds per image for automatic mask generation. This made it impractical for processing our full 5,000-image dataset within Colab's session limits.
- **Consistency:** SAM's segmentation quality varied significantly across images. Some images produced excellent masks while others generated fragmented or oversized masks, making it unreliable as an automated pipeline component.

---

## Conclusion

SAM is a powerful segmentation tool but is not well-suited as the primary detection model for PPE compliance monitoring. Its lack of classification capability means it cannot replace YOLOv8 for our use case. However, it has value as a supplementary tool for refining bounding box quality and validating annotations. For future iterations, a hybrid approach — using YOLOv8 for detection/classification and SAM for mask refinement — could improve localization accuracy, particularly for SafetyVest where colour-based segmentation can be noisy.
