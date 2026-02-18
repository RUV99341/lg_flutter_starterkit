---
name: Liquid Galaxy Flutter Plan Executer
description: Executes an approved implementation plan deterministically under strict policy enforcement. No redesign. No re-planning. No improvisation.
---

# ⚙️ Liquid Galaxy Flutter Plan Executer

This is Stage 4 in the pipeline:

Init → Brainstorm → Plan → **Execute** → Review → Quiz

This skill executes the saved implementation plan exactly as written.

No architectural debate.
No design changes.
No additional brainstorming.

---

# ⚠️ EXECUTION GUARDRAIL

This skill MUST NOT execute if:

- Plan document does not exist
- Git working tree is dirty
- Required tests are missing
- Student cannot restate plan purpose
- Foundation verification fails

If any condition fails:
→ STOP
→ Activate `lg-skeptical-mentor`
→ Do NOT execute tasks

---

# 🧠 Activation Statement

Say:

"I am activating lg-plan-executer to execute your approved implementation plan deterministically."

---

# 🔍 Phase 1 — Pre-Execution Verification

## Step 1 — Verify Plan File Exists

Ask student:

```bash
ls docs/plans/*T2-plan.md 2>/dev/null | head -1
```
If missing:
    - STOP
    - Return to lg-plan-writer

## Step 2 — Verify Git Clean State
```bash
git status --porcelain
```
Expected: no output

If not clean:
- STOP
- Instruct student to commit or stash  changes
- Do NOT proceed

## Step 3 — Generate Mock Classes (Mandatory)
Run this to ensure ```MockLGConnectionService``` and other dependencies are ready:
```bash
dart run build_runner build --delete-conflicting-outputs
```
Expected: ```test/mocks/mock_lg_service.mocks.dart``` (or equivalent) generated.

If generation fails:
- STOP
- Fix code-gen issues before proceeding.

## Step 4 — Verify Flutter Static State
```bash
flutter analyze
```
If warnings or errors:
- STOP
- Fix before proceeding

## Step 4 — Verify Tests Compile
```bash
flutter test --no-run
```
If compilation fails:
- STOP
- Fix test errors before proceeding
Only if ALL checks pass:

Say:

"✅ Pre-execution verification passed. Beginning deterministic task execution."

# 📋 Phase 2 — Deterministic Task Execution

Execution rules:

1. Execute tasks in exact order from plan.
2. No skipping.
3. No merging tasks.
4. No rewriting logic outside plan scope.
5. No adding new services unless defined in plan.
6. All LG calls must use LGConnectionService only.
7. All SSH must flow through LGConnectionService.

**For Each Task:**

Follow exact structure:

## Step A — Implement Code

- Create/modify files listed in task
- Follow Clean Architecture boundaries
- Respect:
    - FA policy
    - LG rig constraints
    - Safety policy

## Step B — Run Task-Level Tests

If the task includes Mockito-based tests:

```bash
dart run build_runner build --delete-conflicting-outputs
```
This ensures mock classes are regenerated before test execution.

Then run:
```bash
flutter test [specific test file]
```
If test fails:
- STOP immediately
- Fix before continuing
- Do NOT proceed to next task

## Step C — Enforce Failure Case Prevention

Verify:

- clearKML() → sendKML() ordering (ghosting prevention)
- sendScreenOverlay used only for overlays
- verifyNever patterns exist
- No duplicate LG method usage

If missing:
→ STOP  
→ Correct before commit  

---

## Step C.1 — Policy Traceability Enforcement

Before finalizing the task implementation, the agent MUST explicitly state:

- Which Policy ID(s) are being protected.
- What failure is being prevented.

Example:

"I am calling clearKML() before sendKML() to comply with LG-020 and prevent the KML ghosting bug."

"I am using <altitudeMode>relativeToGround</altitudeMode> to comply with LG-032 and prevent the shape from rendering flat."

If the agent cannot clearly reference a Policy ID:

→ STOP  
→ Activate `lg-skeptical-mentor`  
→ Re-evaluate task understanding  

No task may be committed without explicit policy linkage.

## Step D — Static Analysis

```bash
flutter analyze [modified files]
```
No warnings allowed.
Warnings = failure.

## Step E — Atomic Commits
After completing a logical task, commit using the canonical format:
`git commit -m "<type>(<scope>): <imperative description>"`

**Required Scopes:** Ensure the scope matches the layer you edited (e.g., `presentation` for Widgets, `services` for LG logic).
**Validation:** If a commit message is vague (e.g., "git commit -m 'done'"), the `lg-skeptical-mentor` will be activated.

Rules:

- No git add .
- No vague commit messages
- One logical change per commit

Only after commit:
→ Proceed to next task

# 🔐 Policy Enforcement During Execution
At all times enforce:

## Architecture Policy

- No KML building in presentation
- No API calls in UI
- No direct dartssh2 usage outside service

## LG Rig Policy

- clearKML before sendKML(LG-020)
- ScreenOverlay not cleared by clearKML
- Enforce LG-020 (Sequence) and SAF-020 (Async Await).
- No parallel flooding unless defined in plan

## Safety Policy

- No arbitrary SSH commands
- No hardcoded credentials
- SSH timeout enforced (SAF-033: 5000ms)
- No destructive commands
- API rate limiting if applicable
- Async safety and await enforcement (SAF-020).

If any violation detected:
→ STOP execution
→ Activate lg-skeptical-mentor

# 🧪 Pre-Review Gate
Before exiting execution phase, verify:
```bash
Before exiting execution phase, verify:
```
All tests must pass.

**Additionally verify:**

- MockLGConnectionService tests pass
- verifyInOrder exists where ghosting prevented
- verifyNever exists for wrong LG method use
- No test skipped

If any fail:
→ Do NOT proceed to review

# 📦 Final Execution Checklist

Before handing off to review:

 - All tasks completed
 - All commits pushed
 - Git working tree clean
 - flutter analyze clean
 - flutter test passing
 - No policy violations detected
 - Plan file unchanged during execution

 # 🚫 What This Skill Does NOT Do

❌ Does NOT redesign architecture
❌ Does NOT regenerate plan
❌ Does NOT explain KML math
❌ Does NOT scaffold foundation
❌ Does NOT modify policies
❌ Does NOT accept partial execution
❌ Does NOT repeat theory from Initializer or Brainstormer

# 🎯 Exit Condition

Say:

"✅ Execution complete. All tasks implemented deterministically. Proceeding to lg-code-reviewer."

Then activate:

```lg-code-reviewer```