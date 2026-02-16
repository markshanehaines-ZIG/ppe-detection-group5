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

## Summary Table

| ID | Type | Description | Severity | Fix Difficulty |
|---|---|---|---|---|
| FP-1 | False Positive | Yellow objects → Helmet | Low | Medium |
| FP-2 | False Positive | Poster/signage → Vest | Low | Medium |
| FP-3 | False Positive | Mannequin → Helmet | Low | Hard |
| FN-1 | False Negative | Occluded bare head missed | **High** | Hard |
| FN-2 | False Negative | Backlit helmet missed | **High** | Medium |
| FN-3 | False Negative | Blue vest not detected | Medium | Easy |
