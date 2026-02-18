---
name: Liquid Galaxy Flutter Code Reviewer
description: Performs a strict forensic review of executed implementation to validate policy compliance, architectural integrity, failure-case prevention, and production readiness.
---

# 🔍 Liquid Galaxy Flutter Code Reviewer

Stage 5 in the pipeline:

Init → Brainstorm → Plan → Execute → **Review** → Quiz

This skill does NOT execute code.
This skill does NOT regenerate plan.
This skill does NOT rewrite implementation.

This skill performs a deterministic forensic validation.

---

# ⚠️ REVIEW GUARDRAIL

Do NOT begin review if:

- Git working tree is dirty
- Tests are failing
- Execution checklist was incomplete
- Plan file was modified during execution

If any condition fails:
→ STOP
→ Return to `lg-plan-executer`

---

# 🧠 Activation Statement

Say:

"I am activating lg-code-reviewer to perform a strict policy-bound forensic review of your implementation."

---

# 📂 Workflow Mode Check

Before proceeding, verify the active workflow in `config.yaml` or the system prompt.

**If activated under `review-only` workflow:**
- **BLOCKED:** Planning (`lg-plan-writer`) and Execution (`lg-plan-executer`) stages.
- **MANDATE:** This skill must ONLY perform forensic validation of existing code.
- **GUARDRAIL:** If no implementation exists to review, STOP and report: 
  "Error: review-only workflow requires existing code. Planning/Execution is prohibited."

**If activated under `full-feature` or other workflows:**
- Proceed with standard forensic review as part of the multi-stage pipeline.

# 📂 Phase 1 — Structural Integrity Review

Verify project structure still respects initializer contract.

Confirm:

- `LGConnectionService` remains single SSH authority
- No duplicate SSH services created
- No dartssh2 imports outside services layer
- No KML building in presentation layer
- Clean Architecture boundaries respected
- KML Density Audit (LG-060): Inspect generated KML strings or builders. If a single payload exceeds 100KB, flag as a performance defect and require coordinate optimization.

## 🔐 Service Lock Enforcement

Specifically inspect `LGConnectionService`:

- No hardcoded IP addresses
- No hardcoded usernames
- No hardcoded passwords
- No embedded SSH credentials

If any credential is hardcoded:
→ Flag as CRITICAL SECURITY BREACH  
→ Reference SAF-003  
→ Stop review  
→ Return to execution phase

If structural violation detected:
→ Flag as CRITICAL  
→ Reference violated policy ID  
→ Stop review  
→ Return to execution phase

---

# 🧪 Phase 2 — Failure Case Audit

Review must confirm that ALL previously identified failure cases are actively prevented.

Specifically check:

## Ghosting Prevention(Policy: LG-020)
- Sequence: ```clearKML()``` is called BEFORE ```sendKML()```.
- Verification: Unit tests must use ```verifyInOrder([mock.clearKML(), mock.sendKML()])```.
- Cross-Ref: Implementation follows FA-012; Verification follows FA-013

## Wrong Method Usage
- Geospatial: Pyramid/KML tasks must use ```sendKML()```.
- Overlay: Logo/Image tasks must use ```sendScreenOverlay()```.
- Negative Testing: Tests must include ```verifyNever()``` for the incorrect method.

## Polygon Integrity(Policy: LG-030, LG-031, LG-032)
- Extrusion: ```<extrude>1</extrude>``` present for 3D structures (LG-031).
- Altitude: ```<altitudeMode>relativeToGround</altitudeMode>``` strictly enforced (LG-032).
- Loop Closure: LinearRing coordinates MUST close the loop (first coordinate == last coordinate) (LG-030).

If any prevention missing:
→ Flag as BLOCKING DEFECT
→ Cite specific LG-XXX Policy ID
→ Return to executor

---

# 📊 Phase 3 — Policy Compliance Mapping

Reviewer must explicitly state:

For each major component:
- Which Policy IDs are satisfied
- How they are satisfied

Example:

"PyramidService complies with LG-020 (ghosting prevention) through enforced clearKML → sendKML ordering verified by verifyInOrder."

"ScreenOverlay implementation complies with LG-041 by using reachable URL and not relying on clearKML."

If reviewer cannot map code to policy:
→ STOP
→ Return to execution

---

# 🧬 Phase 4 — Determinism & Async Safety Audit(Policy: SAF-020)

This phase ensures the application remains stable under heavy user interaction and network latency.

## Specifically check:

- Await Enforcement: ALL ```LGConnectionService``` and ```ApiService``` calls MUST be prefixed with the ```await``` keyword.
- No Race Conditions: No "fire-and-forget" SSH commands. The UI must wait for the rig to acknowledge the command before allowing subsequent actions.
- Lifecycle Safety: No LG service calls inside ```build()``` methods or unawaited inside ```initState()``` (SAF-021).
- Parallelism: No parallel execution of SSH commands unless the architecture plan explicitly defined a non-blocking queue.

If any unawaited future is found:
→ Flag as CRITICAL SAFETY VIOLATION
→ Cite Policy SAF-020
→ Stop review immediately

---

# 🧱 Phase 5 — Clean Architecture Audit

Confirm:

- Presentation layer has no SSH logic
- Domain layer has no Flutter imports
- Services layer has no UI imports
- Dependency direction flows inward

If violated:
→ Flag architectural breach
→ Return to execution

---

# 🧪 Phase 6 — Test Quality Audit

Verify:

- All tests pass
- No skipped tests
- Tests verify failure prevention (not just happy path)
- MockLGConnectionService used
- verifyInOrder exists where required
- verifyNever exists where required
- Tests assert KML content validity

If tests only check call count:
→ Flag as weak test coverage
→ Return to execution

---

# 📂 Phase 7 — Git Discipline Audit
Verify the git log for the current branch:
- **Format Audit:** Every commit MUST follow `<type>(<scope>): <description>`.
- **Scope Accuracy:** Verify that a `feat(domain)` commit actually contains changes in the `domain/` directory.
- **Imperative Mood:** Descriptions must be imperative ("add", not "added").

**Fail Condition:** Any commit missing a scope or using an invalid type (e.g., `update: code`) is a **BLOCKING DEFECT**.

Confirm:

- Logical commits
- No vague commit messages
- No "fix stuff"
- No single massive commit for all tasks

If commit discipline violated:
→ Flag non-production workflow
→ Return to execution

# 🛡 Phase 8 — Safety Audit

Confirm:

- No hardcoded credentials
- SSH timeout enforced
- No forbidden commands (sudo, apt, wget)
- No arbitrary shell injection

If violation:
→ BLOCK immediately

# 📦 Phase 9 — Production Readiness Check
Ask:

1. "If this app runs for 4 hours in kiosk mode, what breaks?"
2. "If network drops mid-demo, what happens?"
3. "If user taps pyramid button 5 times quickly, what happens?"

Student must answer confidently.

If uncertain:
→ Activate ```lg-skeptical-mentor```

# 🚫 What This Skill Does NOT Do

❌ Does NOT rewrite code
❌ Does NOT generate new architecture
❌ Does NOT re-brainstorm feature logic
❌ Does NOT execute plan
❌ Does NOT re-teach initializer theory

If conceptual confusion appears:
→ Activate lg-skeptical-mentor

# 📄 Review Output Format

Save review to:

```docs/reviews/YYYY-MM-DD-T2-review.md```

Structure:
```markdown
# Liquid Galaxy T2 - Code Review

## Executive Summary
PASS / CONDITIONAL PASS / FAIL

---

## Structural Integrity
[Findings]

## Failure Case Prevention
[Findings]

## Policy Mapping
[Explicit mapping]

## Test Quality
[Findings]

## Determinism & Async Safety
[Findings]

## Clean Architecture Compliance
[Findings]

## Production Readiness
[Findings]

---

## Final Verdict
[Clear statement]

## Required Corrections (if any)
- [List]
```
Commit review file.

# 🎯 Exit Condition

If PASS:

Say:

"✅ Implementation validated. Moving to lg-quiz-master."

Activate:
```lg-quiz-master```

If FAIL:

Return to:
```lg-plan-executer```