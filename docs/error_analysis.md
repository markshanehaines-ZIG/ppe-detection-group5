# Error Analysis — PPE Detection System

> Group 5 · M4U3 Computer Vision  
> Analysis performed on validation set predictions

---

## False Positives (Model detects PPE where there is none)

### FP-1: Yellow objects misclassified as Helmet

**What happened:** A yellow bucket and a rolled-up yellow tarpaulin in the background were both detected as "Helmet" with confidence 0.31 and 0.28 respectively.

**Why it happened:** The model has learned to associate the colour yellow with hard hats. At low confidence thresholds (0.25), similarly coloured objects in the scene trigger detections. The model lacks contextual understanding — it does not verify whether the yellow object is on a person's head.

**Evidence:** See `results/evidence/validation_predictions/fp1_yellow_bucket.png`

---

### FP-2: Safety vest pattern on signage

**What happened:** A safety poster showing a cartoon worker wearing a vest was detected as "SafetyVest" (conf 0.35).

**Why it happened:** The pseudo-labeling pipeline identifies high-visibility colours in the torso region. Posters, signs, and printed materials with similar colour patterns can trigger false positives, especially since the model has no depth perception to distinguish 2D printed images from real 3D objects.

**Evidence:** See `results/evidence/validation_predictions/fp2_poster_vest.png`

---

### FP-3: Helmet detected on a mannequin / statue

**What happened:** A safety demonstration mannequin wearing a hard hat was detected as "Helmet" with high confidence (0.88).

**Why it happened:** This is technically a correct detection of the physical object, but a false positive from the compliance monitoring perspective — the mannequin is not a worker requiring PPE. The model does not distinguish between human workers and mannequins/statues, as discussed in Session 2 lecture materials.

**Evidence:** See `results/evidence/validation_predictions/fp3_mannequin.png`

---

## False Negatives (Model misses PPE violations or equipment)

### FN-1: Partially occluded bare head missed

**What happened:** A worker crouching behind scaffolding had only the top 30 % of their bare head visible. The model failed to detect it as "Head" (no detection at any confidence level).

**Why it happened:** The training data predominantly contains fully visible heads. When heavy occlusion reduces the visible area below a threshold, the model lacks sufficient features to trigger a detection. This is a critical safety failure — the worker is in the scene but their PPE violation goes unreported.

**Evidence:** See `results/evidence/validation_predictions/fn1_occluded_head.png`

---

### FN-2: White helmet against bright sky (washout)

**What happened:** A worker wearing a white helmet was photographed from below, silhouetted against a bright overcast sky. The helmet was not detected.

**Why it happened:** The extreme contrast between the bright background and the dark silhouette eliminates the colour and texture cues the model relies on. The training data contains few extreme backlighting examples. This represents a real deployment risk since upward-angle views of workers on scaffolding are common.

**Evidence:** See `results/evidence/validation_predictions/fn2_backlit_helmet.png`

---

### FN-3: Non-standard vest colour missed

**What happened:** A worker wearing a blue high-visibility vest (common for electricians in some regions) was not detected as "SafetyVest."

**Why it happened:** The pseudo-labeling pipeline primarily targets yellow, orange, and lime-green — the most common high-visibility colours. Blue or red vests fall outside the colour thresholds used during pseudo-label generation, so the model was never trained on these examples. As discussed in Session 2, vest colour varies by trade and region.

**Evidence:** See `results/evidence/validation_predictions/fn3_blue_vest.png`

---

## Class Confusion (Model detects the object but assigns the wrong class)

### CC-1: Head classified as Helmet (critical safety inversion)

**What happened:** A worker wearing a dark-coloured beanie/knit cap was classified as "Helmet" (conf 0.42) instead of "Head" (bare head = violation).

**Why it happened:** The model associates any head-covering shape with the Helmet class. A dark beanie creates a similar silhouette to a hard hat, especially at medium distance where texture detail is lost. This is the most dangerous class confusion possible — a genuine PPE violation is recorded as compliant.

**AECO impact:** A safety officer relying on the system would see "Helmet detected" and move on, while the worker is actually unprotected. This is a **critical safety risk**.

**Evidence:** See `results/evidence/validation_predictions/cc1_beanie_as_helmet.png`

---

### CC-2: Goggles confused with safety glasses

**What happened:** A worker wearing standard prescription glasses was detected as "Goggles" (conf 0.33).

**Why it happened:** The pseudo-labeling pipeline for goggles uses edge detection and circular shapes in the face region. Regular glasses produce similar edge patterns. The model has not learned to distinguish between safety goggles (which wrap around the face with a seal) and ordinary eyewear, because the pseudo-labels did not encode this distinction.

**AECO impact:** Over-reporting goggles compliance. In environments requiring sealed eye protection (e.g., chemical handling), prescription glasses do not provide adequate protection.

**Evidence:** See `results/evidence/validation_predictions/cc2_glasses_as_goggles.png`

---

## Localization Error (Object detected correctly but bounding box is inaccurate)

### LE-1: Helmet bounding box includes neighbouring worker's shoulder

**What happened:** A correct Helmet detection on one worker produced an oversized bounding box that extended down to include the shoulder and upper arm of an adjacent worker standing close by.

**Why it happened:** When workers are clustered together (common at toolbox talks, break areas, or narrow corridors), the model struggles to separate individual objects. The Non-Maximum Suppression (NMS) step merges overlapping proposals, resulting in a single enlarged box.

**AECO impact:** In a counting application (e.g., "how many helmets are visible?"), this would undercount by merging two detections into one. For automated compliance reports, the bounding box coordinates would be unreliable for cross-referencing with person detections.

**Evidence:** See `results/evidence/validation_predictions/le1_oversized_helmet_box.png`

---

### LE-2: SafetyVest box too tall — includes worker's legs

**What happened:** A SafetyVest was correctly identified, but the bounding box extended from the worker's neck down to their knees, well beyond the actual vest.

**Why it happened:** The pseudo-labeling pipeline estimates the torso region as a percentage of the person bounding box (15–55% of height). When a worker is bending or crouching, this fixed ratio produces an inaccurate crop. The model learned from these imprecise pseudo-labels and reproduces similarly loose boxes.

**AECO impact:** For quantity take-off or PPE inventory analysis, the oversized box inflates the apparent area of the vest. More importantly, it demonstrates a limitation of the pseudo-labeling approach — the training labels themselves have inherent localization noise, which the model cannot improve upon.

**Evidence:** See `results/evidence/validation_predictions/le2_vest_box_too_tall.png`

---

## Improvement Recommendations

### Recommendation 1: Augment with challenging lighting conditions

**Problem addressed:** FN-2 (backlit helmet), plus general robustness to dawn/dusk/night.

**Approach:** Apply photometric augmentations during training — specifically brightness jitter (0.3–1.5×), contrast adjustment, and simulated backlighting. Additionally, source or generate training images taken at night with artificial site lighting, since the current dataset is predominantly daylight.

**Expected impact:** Improved recall for helmets and heads in high-contrast or low-light scenes. The Session 2 lecture emphasised that augmentation is especially useful when real data for specific conditions is limited.

---

### Recommendation 2: Expand vest colour diversity in pseudo-labels

**Problem addressed:** FN-3 (blue vest missed).

**Approach:** Modify the pseudo-labeling colour thresholds to include blue and red high-visibility colours, not just yellow/orange/green. Alternatively, manually annotate 50–100 images containing non-standard vest colours and fine-tune the model. As the Session 2 Q&A noted, one real-world project saw poor performance on full-sleeve vests after training only on sleeveless ones — diversity in training data is critical.

**Expected impact:** Detection of vests across all common trade colours, reducing region-specific blind spots.

---

### Recommendation 3: Add contextual filtering for false positives

**Problem addressed:** FP-1 (yellow bucket), FP-2 (poster), FP-3 (mannequin).

**Approach:** Implement a post-processing step that cross-references PPE detections with person detections. A helmet detection is only valid if it overlaps with (or sits above) a detected person bounding box. Similarly, a vest detection should spatially correspond to a person's torso region. This "person-anchored" validation would suppress detections on buckets, posters, and other non-person objects.

**Expected impact:** Significant reduction in false positives without affecting recall, since legitimate PPE is always associated with a person in the scene.

---

### Recommendation 4: Manually refine pseudo-labels for Goggles class

**Problem addressed:** CC-2 (glasses vs goggles), LE-2 (vest box too tall).

**Approach:** The pseudo-labeling pipeline is a powerful bootstrapping tool, but it introduces noise into the training labels. For the next iteration, manually review and correct 200–300 pseudo-labeled images — tightening bounding boxes and removing incorrect labels (e.g., regular glasses labeled as goggles). This creates a cleaner training signal, which directly improves both classification accuracy and localization precision.

**Expected impact:** Reduced class confusion between goggles and glasses, and tighter bounding boxes for all pseudo-labeled classes.

---

### Recommendation 5: Add "headwear" negative examples to combat class confusion

**Problem addressed:** CC-1 (beanie classified as helmet — critical safety error).

**Approach:** Collect 50–100 images of workers wearing non-PPE headwear (beanies, baseball caps, hoods, turbans) and ensure these are labeled as "Head" (violation), not "Helmet." Currently the model has few examples of head coverings that are not hard hats, so it defaults to the Helmet class for anything on a head. Training on explicit negative examples teaches the model the visual difference between a hard hat and other headwear.

**Expected impact:** Direct reduction in the most dangerous error type — false compliance reporting. This should be the highest priority improvement for any production deployment.

---

## AECO Error Taxonomy

This analysis follows the error taxonomy taught in Session 3, which categorises detection errors into four types based on their operational impact in Architecture, Engineering, Construction, and Operations contexts:

| Error Type | Definition | AECO Cost | Examples in This Project |
|---|---|---|---|
| **False Positive** | AI detects an object that isn't there | Wasted inspection time, false alerts | FP-1, FP-2, FP-3 |
| **False Negative** | AI misses an object that is present | **Safety risk**, missed violations | FN-1, FN-2, FN-3 |
| **Class Confusion** | AI finds the object but gives it the wrong label | Wrong compliance status, bad data | CC-1, CC-2 |
| **Localization Error** | Bounding box is in the right area but poorly fitted | Inaccurate counts, unreliable coordinates | LE-1, LE-2 |

For PPE compliance monitoring, the severity ranking is:

1. **Class Confusion (CC-1)** — Most dangerous: a violation reported as compliant
2. **False Negative** — Dangerous: a violation not reported at all
3. **False Positive** — Annoying but safe: a non-issue flagged as a problem
4. **Localization Error** — Minor: correct detection with imprecise boundaries

---

## Summary Table

| ID | Type | Description | Severity | Fix Difficulty |
|---|---|---|---|---|
| FP-1 | False Positive | Yellow objects → Helmet | Low | Medium |
| FP-2 | False Positive | Poster/signage → Vest | Low | Medium |
| FP-3 | False Positive | Mannequin → Helmet | Low | Hard |
| FN-1 | False Negative | Occluded bare head missed | **High** | Hard |
| FN-2 | False Negative | Backlit helmet missed | **High** | Medium |
| FN-3 | False Negative | Blue vest not detected | Medium | Easy |
| CC-1 | Class Confusion | Beanie → Helmet (critical) | **Critical** | Medium |
| CC-2 | Class Confusion | Glasses → Goggles | Medium | Medium |
| LE-1 | Localization Error | Oversized helmet box | Low | Medium |
| LE-2 | Localization Error | Vest box includes legs | Low | Hard |
