# Governance Checklist — PPE Detection System

> Group 5 · M4U3 Computer Vision  
> Zigurat Institute of Technology — MAICEN 1125

---

## 1 · Data Privacy & Collection

| Item | Status | Notes |
|---|---|---|
| Training images sourced from public, openly-licensed dataset | ✅ | MAICEN dataset from GitHub (public repo) |
| No personally identifiable information (PII) in training data | ✅ | Faces are incidental; no facial recognition performed |
| No facial recognition or individual identification | ✅ | Model detects PPE objects, not individual identity |
| Data minimisation: only bounding box coordinates stored | ✅ | Raw images are not retained after detection |
| GDPR considerations documented | ✅ | See Section 3 below |
| No confidential or client-owned imagery used | ✅ | Public dataset only |

---

## 2 · Model Transparency & Limitations

| Item | Status | Notes |
|---|---|---|
| Model architecture documented (YOLOv8m) | ✅ | See README Section 4 |
| Training parameters fully disclosed | ✅ | Epochs, LR, batch size, threshold in README |
| Performance metrics reported per class | ✅ | See README Section 5 |
| Confidence threshold justified | ✅ | 0.25 for safety-critical recall |
| Known failure modes documented | ✅ | See `error_analysis.md` |
| Pseudo-label methodology disclosed | ✅ | README Section 3 — not hidden as "real" labels |

### Known Limitations

1. **Lighting:** Trained primarily on daylight images. Performance degrades in low light, night, or extreme backlighting conditions.

2. **Vest diversity:** Pseudo-labels target yellow/orange/green high-visibility colours. Blue, red, or non-standard vest colours may be missed.

3. **Occlusion:** Heavily occluded workers (< 30 % visible) are frequently missed. The model requires sufficient visible features to trigger detection.

4. **Camera angle:** Training data is predominantly eye-level. Overhead or steep upward angles may reduce accuracy.

5. **Geographic bias:** Dataset reflects specific construction site contexts. PPE styles, worker demographics, and site layouts in other regions may differ.

6. **Not a replacement for human safety officers.** This system is a supplementary monitoring tool. Critical safety decisions should always involve human judgement.

---

## 3 · Ethical Considerations

### Worker Surveillance

This system monitors **equipment presence**, not worker identity or behaviour. However, deployment in a workplace raises ethical concerns:

- **Worker consent:** Workers should be informed that PPE monitoring is in operation. Signage should be clearly visible on site.
- **Data retention:** Detection logs should be retained only as long as operationally necessary. No long-term tracking of individual workers.
- **Union/representative engagement:** Where applicable, worker representatives should be consulted before deployment.
- **Purpose limitation:** The system must only be used for PPE compliance. Repurposing for productivity monitoring, attendance tracking, or disciplinary action would be an ethical violation.

### Bias & Fairness

- The model detects PPE objects, not people. There is no classification by gender, ethnicity, age, or other protected characteristics.
- However, if certain worker groups systematically wear non-standard PPE (e.g., different vest styles by trade), the model may have unequal detection rates across groups. Regular auditing of per-group recall is recommended.

### Automation Bias Risk

- Site managers may over-rely on the system and reduce manual inspections. The system should be positioned as **additional** coverage, not a replacement.
- False negatives mean the system can never guarantee 100 % detection. A "no alerts" status does not mean all workers are compliant.

---

## 4 · Regulatory Alignment

| Regulation | Relevance | Compliance Notes |
|---|---|---|
| **GDPR** (EU) | Applies if deployed on EU sites | No personal data processed; bounding boxes only. If system is extended to track individuals, a Data Protection Impact Assessment (DPIA) would be required. |
| **OSHA** (US) / **EU-OSHA** | PPE requirements | System supports compliance monitoring but is not a certified inspection method. |
| **ISO 45001** | Occupational H&S management | System provides continuous monitoring data that supports ISO 45001 objectives. |
| **AI Act** (EU) | AI system classification | Workplace monitoring AI may be classified as "high risk" under the EU AI Act. If deployed commercially, conformity assessment may be required. |

---

## 5 · Licensing

| Component | License | Commercial Use |
|---|---|---|
| This project | MIT | ✅ Permitted |
| MAICEN dataset | See original repo | Check original terms |
| YOLOv8 (Ultralytics) | AGPL-3.0 | Requires enterprise license for closed-source commercial use |
| Roboflow (annotations) | Roboflow terms | Free tier for educational use |
| Google Colab | Google ToS | Free tier used; no commercial API calls |

---

## 6 · Risk Register

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Missed bare head → injury | Medium | **Critical** | Low conf threshold (0.25); two-tier alert system |
| False alarm fatigue | Medium | Medium | Supervisor review queue for medium-confidence detections |
| Model drift over time | Medium | Medium | Retrain quarterly with new site imagery |
| Adversarial evasion (e.g., modified PPE) | Low | High | Out of scope for this prototype; flag for future work |
| Privacy complaint from workers | Medium | Medium | Clear signage; no PII stored; consult worker representatives |

---

## 7 · Responsible Deployment Recommendations

1. **Pilot before production.** Test on one site zone for 2 weeks before full deployment.
2. **Human-in-the-loop.** All medium-confidence alerts should be reviewed by a supervisor.
3. **Regular auditing.** Compare model detections with manual spot-checks monthly.
4. **Retraining schedule.** Update model weights quarterly with new site conditions.
5. **Incident logging.** Record all confirmed false negatives to improve future training data.
6. **Transparent reporting.** Publish detection rates and false alarm rates to site management and worker representatives.
