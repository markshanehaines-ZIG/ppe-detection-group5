# Class Definitions & Label Rules — PPE Detection System

**Group 5 · M4U4 Computer Vision**

---

## 4-Class Detection System

| Class ID | Class Name | Label Rule | Source | Purpose |
|----------|-----------|------------|--------|---------|
| 0 | Helmet | Hard hat visible on a person's head | XML annotations | Detect workers wearing proper head protection |
| 1 | Head | Bare head visible (no hard hat) | XML annotations | Detect PPE violations — workers without head protection |
| 2 | SafetyVest | High-visibility vest on a person's torso | Pseudo-labeled | Detect workers wearing high-vis vests |
| 3 | Goggles | Safety goggles in the eye region of a head | Pseudo-labeled | Detect workers wearing eye protection |

---

## Detailed Label Rules

### Class 0: Helmet

**What to label:** Any rigid hard hat/safety helmet worn on a person's head in the image.

**Includes:** Standard construction hard hats (all colours — white, yellow, orange, blue, red), bump caps with visible brims, helmets with face shields or ear defenders attached.

**Excludes:** Baseball caps, beanies, hoods, turbans, and other non-protective headwear. These should be labeled as Head (Class 1) because they do not provide impact protection.

**Bounding box rule:** Enclose the entire helmet including the brim. If a chin strap is visible, include it within the box.

### Class 1: Head

**What to label:** Any visible human head that is NOT wearing a hard hat.

**Includes:** Bare heads (no headwear), heads with non-protective headwear (beanies, caps, hoods), partially visible heads where enough features are present to confirm it is a head (minimum ~30% visible).

**Excludes:** Heads that are wearing hard hats (these are Class 0). Heads that are so heavily occluded that they cannot be reliably identified as heads.

**Safety significance:** This is the critical violation class. A Head detection means a worker is on site without proper head protection, which is a safety violation requiring immediate attention.

**Bounding box rule:** Enclose the head from the top of the skull to the chin, including any non-protective headwear.

### Class 2: SafetyVest

**What to label:** Any high-visibility vest or jacket worn on a person's torso.

**Pseudo-labeling method:** Detected automatically using HSV colour segmentation within the torso region (15–55% of person bounding box height). High-visibility colours (yellow H:20–35, orange H:10–20, lime green H:35–85) with saturation > 100 and value > 100 are flagged when they cover > 15% of the torso region.

**Includes:** Standard high-visibility vests (yellow, orange, lime green), reflective jackets with high-vis panels, full-sleeve high-vis jackets.

**Known limitation:** Blue and red high-vis vests are NOT detected by the current pseudo-labeling pipeline because they fall outside the HSV thresholds. This is documented in the error analysis (FN-3).

**Bounding box rule:** Enclose the visible vest area on the torso, from shoulders to waist.

### Class 3: Goggles

**What to label:** Safety goggles worn over the eyes.

**Pseudo-labeling method:** Detected automatically using Canny edge detection in the eye region of detected heads. The algorithm looks for circular edge patterns characteristic of goggle frames, validated against expected size ratios relative to the head bounding box (threshold: 0.45).

**Includes:** Wrap-around safety goggles, splash goggles, welding goggles.

**Known limitation:** Regular prescription glasses and sunglasses can trigger false detections because they produce similar edge patterns. The model cannot distinguish sealed safety goggles from ordinary eyewear. This is documented in the error analysis (CC-2).

**Bounding box rule:** Enclose the goggle frames from temple to temple, including the strap if visible.

---

## Excluded Class: Person

The original MAICEN dataset includes Person annotations. We deliberately exclude Person from our detection system because it is too generic for PPE compliance monitoring — knowing a person is present without knowing their PPE status does not support safety decisions. Person bounding boxes are used internally during pseudo-labeling (to locate torso regions for vest detection) but are not part of the final 4-class model.

---

## Annotation Quality Notes

- **XML-sourced labels (Helmet, Head):** Human-annotated in Pascal VOC format. Label variations (e.g., "hard_hat", "Helmet", "helmet") are normalised during parsing. Coordinate errors (swapped min/max) are automatically corrected.
- **Pseudo-sourced labels (SafetyVest, Goggles):** Machine-generated at runtime. These labels contain inherent noise from the heuristic detection algorithms. Bounding boxes tend to be looser than human annotations. See the error analysis for detailed discussion of pseudo-label limitations.
