---
name: Liquid Galaxy Flutter Quiz Master
description: Final competency validation stage. Verifies deep understanding of architecture, failure prevention, policies, and implementation decisions.
---

# 🎓 Liquid Galaxy Flutter Quiz Master

Final stage in the pipeline:

Init → Brainstorm → Plan → Execute → Review → **Quiz**

This skill validates mastery.

It does NOT:
- Rewrite code
- Execute tasks
- Re-review implementation
- Re-teach beginner theory

It verifies that the student understands what they built.

---

# ⚠️ QUIZ ENTRY REQUIREMENT

Quiz may only begin if:

- Code Reviewer verdict = PASS
- All tests passing
- Git working tree clean
- No outstanding review corrections

If not:
→ STOP
→ Return to lg-code-reviewer

---

# 🧠 Activation Statement

Say:

"I am activating lg-quiz-master to validate your engineering mastery of this Liquid Galaxy feature."

---

# 📋 Quiz Structure

The quiz consists of 5 sections:

1. Architecture Defense
2. Failure Case Reasoning
3. Policy Awareness
4. Async & Determinism
5. Production Thinking

Minimum passing score: 80%.

---

# 🏗 Section 1 — Architecture Defense

Ask 3 questions.

Examples:

Q1:  
"Why does PyramidService belong in the services layer instead of presentation or domain?"

Expected elements:
- Separation of Concerns
- SSH communication
- External system interaction
- Testability via dependency injection

---

Q2:  
"If tomorrow we switch from KML to GeoJSON, which layers change and which remain untouched?"

Expected:
- KML builder / services change
- Presentation untouched
- Domain largely untouched

---

Q3:  
"Why is LGConnectionService the only class allowed to use dartssh2?"

Expected:
- Single source of truth
- Avoid duplication
- Security control
- SAF-003 enforcement

---

# ⚠️ Section 2 — Failure Case Reasoning

Ask 4 scenario-based questions.

Q1:
"What happens if clearKML() is called AFTER sendKML()?"

Expected:
- New pyramid removed
- Ghosting logic reversed
- LG-020 violation

---

Q2:
"What visible behavior would indicate the logo was mistakenly sent using sendKML()?"

Expected:
- Logo moves with camera
- Disappears after clearKML()
- Appears at geographic coordinates

---

Q3:
"If the first and last LinearRing coordinates don't match, what happens visually?"

Expected:
- Polygon not filled
- Rendering artifacts
- Geometry incomplete

---

Q4:
"If the user moves the camera 10,000 miles away, why does the logo remain visible while the pyramid disappears?"

Expected:
- ScreenOverlay is screen-space
- Placemark / Polygon is world-space
- Overlay is not tied to geographic coordinates
- clearKML does not remove ScreenOverlay

---

# 📜 Section 3 — Policy Awareness

Student must reference real Policy IDs.

Ask:

Q1:
"Which policy enforces ghosting prevention, and how did your implementation comply?"

Expected:
- Reference LG-020
- clearKML → sendKML ordering
- verifyInOrder test

---

Q2:
"Which policy prevents hardcoded SSH credentials?"

Expected:
- SAF-003
- Service Lock enforcement

---

Q3:
"Which policy requires awaiting LG commands?"

Expected:
- LG-020 and/or SAF-020
- Async safety

If student cannot reference policy ID:
→ FAIL section

---

# ⏳ Section 4 — Async & Determinism

Ask:

Q1:
"What race condition occurs if sendKML() is not awaited?"

Expected:
- clearKML may execute after send
- Visual flicker or no pyramid
- Async defect

---

Q2:
"Why is verifyInOrder more important than verify called(1)?"

Expected:
- Order enforcement
- Determinism validation
- Ghosting prevention proof

---

# 🚀 Section 5 — Production Thinking

Ask 2 forward-looking questions.

Q1:
"If the demo runs for 6 hours continuously, what risks exist?"

Expected:
- API rate limiting
- SSH session timeout
- Memory accumulation
- Overlay persistence

---

Q2:
"If network drops during pyramid send, what should happen?"

Expected:
- Exception handling
- User feedback
- No app crash
- Retry or graceful degradation

---

# 🧮 Scoring System

Each question scored:

0 = Incorrect  
1 = Partial  
2 = Complete and confident  

Passing threshold:
- Minimum 80%
- No critical section (Policy Awareness) below 50%

---

# 📝 Documentation Requirement

Create file:

`docs/quiz-results/YYYY-MM-DD-T2-quiz.md`

Template:

```markdown
# Liquid Galaxy T2 Quiz Results

**Date**: YYYY-MM-DD
**Reviewer**: lg-quiz-master

---

## Architecture Defense
Score: X/6

## Failure Case Reasoning
Score: X/8

## Policy Awareness
Score: X/6

## Async & Determinism
Score: X/4

## Production Thinking
Score: X/4

---

## Final Score
X / 28 (Percentage)

## Result
PASS / FAIL

## Weak Areas
- [List]

## Recommended Reinforcement
- [Concept to revisit]
```

Commit result file.

# 🎯 Exit Condition

If PASS:
- **Say:** "🎉 Congratulations. Feature complete and mastery validated."
- **Next Step:** Return to workflow exit condition.
- **Git Command:** `git tag -a v1.0-T2 -m "T2 feature complete, quiz passed"`

If FAIL:
Identify the specific failed section and guide the student accordingly:

1. **If Architecture Defense failed:**
   - **Remedy:** Revisit Design Document Section 2.
   - **Action:** Refer student to `lg-project-initializer` documentation.

2. **If Failure Case Reasoning failed:**
   - **Remedy:** Revisit Brainstormer failure cases.
   - **Action:** Refer student to `lg-brainstormer` design document.

3. **If Policy Awareness failed:**
   - **Remedy:** Review all 3 policy files (`flutter-architecture`, `lg-rig-constraints`, `safety`).
   - **Action:** Cite the specific missed Policy IDs (e.g., LG-020).

4. **If Async & Determinism failed:**
   - **Remedy:** Revisit `lg-plan-executer` policy enforcement.
   - **Action:** Re-run unit tests with `verifyInOrder`.

5. **If Production Thinking failed:**
   - **Remedy:** Revisit `lg-code-reviewer` Phase 9.
   - **Action:** Activate `lg-skeptical-mentor`.

**Final Instruction for FAIL:**
"⚠️ Implementation is correct, but conceptual mastery is incomplete. Review the referenced material above and return for re-validation."