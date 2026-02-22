# AECO Governance Checklist — PPE Detection System

> Group 5 · M4U3 Computer Vision  
> Zigurat Institute of Technology — MAICEN 1125

---

## 1. Data Provenance

**Source:** MAICEN public dataset ([github.com/docilio/MAICEN](https://github.com/docilio/MAICEN)) — Pascal VOC XML annotations for Helmet and Head classes. SafetyVest and Goggles classes were added via our pseudo-labeling pipeline (see README Section 3).

**Roboflow Version:** `[TODO — INSERT YOUR ROBOFLOW LINK HERE]` (YOLOv8 format, 640×640, v1)

**Date Collected:** Original dataset published 2023. Pseudo-labels generated January 2026.

**Owner:** MAICEN dataset is publicly available under its repository terms. Pseudo-labels and model weights are owned by Group 5 (Zigurat MAICEN 1125).

---

## 2. PII Handling (Privacy)

**Faces / License Plates:** Faces are incidentally visible in some training images. No facial recognition is performed — the model detects PPE equipment and head outlines only.

**Protection Strategy:** No PII is collected, stored, or processed by the detection system. The model outputs bounding box coordinates and class labels only. Raw images are not retained after inference.

**Deployment Recommendation:** If deployed on a live construction site, clear signage should inform workers that PPE monitoring is in operation. If identity tracking is ever added (not part of this project), a signed Data Processing Agreement (DPA) with every subcontractor would be required, and faces must be blurred in any stored imagery.

**GDPR Status:** Current system processes no personal data. If extended to include worker identification, a Data Protection Impact Assessment (DPIA) would be required under GDPR Article 35.

---

## 3. Risk Statement

**High-Impact False Negative:** A bare head (PPE violation) goes undetected. The worker is at risk of head injury from falling objects. This is the most dangerous failure mode — someone could be seriously injured or killed because the system reported "all clear."

**High-Impact False Positive:** A yellow bucket or poster is flagged as a helmet/vest, generating a false alert. Cost: wasted supervisor time investigating a non-issue. If false alarms are frequent, site staff may begin ignoring alerts entirely (alert fatigue), which indirectly increases safety risk.

**Class Confusion Risk (Critical):** A beanie or baseball cap is classified as "Helmet" — the system reports compliance when the worker is actually unprotected. This is worse than a false negative because it actively provides false reassurance. See `error_analysis.md` CC-1.

**Environmental Risks:**
- **Low light / night:** Model trained predominantly on daylight images. Recall drops significantly in poor lighting.
- **Heavy rain / fog:** Water droplets on camera lens degrade image quality, reducing detection confidence below usable thresholds.
- **Extreme backlighting:** Workers silhouetted against bright sky may not be detected (see `error_analysis.md` FN-2).
- **Non-standard PPE:** Blue or red vests, full-sleeve vests, and non-standard goggle types may be missed (see `error_analysis.md` FN-3).

---

## 4. Human-in-the-Loop

**Review Process:** This model is for **screening only**. It is not a certified safety inspection system. A qualified Safety Officer must verify all detections before any compliance action is taken.

**Two-Tier Alert System:**
- **High confidence (> 0.7):** Automatic site alert — still requires human acknowledgement
- **Medium confidence (0.25–0.7):** Queued for supervisor review before any action

**Final Authority:** The human Safety Officer is always the final decision-maker. The model assists by providing continuous coverage between manual inspections, but it does not replace the professional judgement of a qualified safety officer.

**Audit Frequency:** Model detections should be compared against manual spot-checks at least monthly. Any confirmed false negatives must be logged and fed back into the next retraining cycle.

---

## 5. License

**Type:** MIT License (Open Source)

**Rationale:** This is a student portfolio / academic project. MIT License allows anyone to use, modify, and distribute the code freely. No proprietary site data is included.

| Component | License | Notes |
|---|---|---|
| This project (code + docs) | MIT | See `LICENSE` file |
| MAICEN dataset | Public repository | Check original repo for terms |
| YOLOv8 (Ultralytics) | AGPL-3.0 | Enterprise license needed for closed-source commercial use |
| Roboflow (annotations) | Roboflow ToS | Free tier for educational use |
| Google Colab | Google ToS | Free tier used |

---

## 6. Disclaimer

> **⚠️ This model is an assistive tool for preliminary screening only. It produces False Negatives. It must NOT be used as the sole verifier for life-safety decisions.**

This system is designed to supplement — not replace — manual PPE inspections conducted by qualified safety professionals. The developers accept no liability for incidents arising from reliance on model outputs without human verification.

---

## 7. Deployment Recommendations

1. **Pilot before production.** Test on one site zone for 2 weeks before full deployment.
2. **Human-in-the-loop always.** All medium-confidence alerts must be reviewed by a supervisor.
3. **Regular auditing.** Compare model detections with manual spot-checks monthly.
4. **Retraining schedule.** Update model weights quarterly with new site conditions.
5. **Incident logging.** Record all confirmed false negatives to improve future training data.
6. **Transparent reporting.** Publish detection rates and false alarm rates to site management and worker representatives.
7. **Worker communication.** Inform all site workers that PPE monitoring is in operation. Consult worker representatives where applicable.

---

## Regulatory Reference

| Regulation | Relevance |
|---|---|
| **GDPR** (EU) | No personal data currently processed. DPIA required if extended to identity tracking. |
| **EU AI Act** | Workplace safety monitoring may be classified as "high risk." Conformity assessment may be required for commercial deployment. |
| **OSHA / EU-OSHA** | System supports PPE compliance monitoring but is not a certified inspection method. |
| **ISO 45001** | Continuous monitoring data supports occupational health & safety management objectives. |
| **ISO/IEC 42001:2023** | AI management system standard — framework for responsible AI development and deployment. |
