version: 1.1
name: review-only
description: >
  Standalone forensic review workflow for validating an
  already-implemented Liquid Galaxy Flutter feature.
  Includes remediation planning and runtime KML validation.

entry_condition:
  - Implementation already completed
  - Tests passing
  - Git working tree clean

policies_enforced:
  - name: flutter-architecture
    version: 1.1
  - name: lg-rig-constraints
    version: 1.1
  - name: safety
    version: 1.1

stage_order_enforced: true
parallel_execution_allowed: false
skip_stage_allowed: false

stages:

  # ----------------------------------------
  # STAGE 1 — Forensic Code Review
  # ----------------------------------------

  - name: review
    skill: lg-code-reviewer
    required_outputs:
      - Structural integrity validation
      - Policy compliance mapping
      - Async safety validation
      - Test quality audit
      - Git discipline audit
      - Production readiness evaluation
      - KML Trace Analysis:
          - Inspect actual generated KML string
          - Confirm LinearRing closure (first == last coordinate)
          - Confirm <extrude>1</extrude> present
          - Confirm <altitudeMode>relativeToGround</altitudeMode> present
    on_failure:
      - block_progress

  # ----------------------------------------
  # STAGE 2 — Remediation Planning (If Needed)
  # ----------------------------------------

  - name: remediation-plan
    condition: verdict == CONDITIONAL_PASS
    required_outputs:
      - Deterministic correction plan
      - Each defect mapped to Policy ID
      - Ordered remediation steps
      - Clear definition of success criteria
    on_failure:
      - block_progress

  # ----------------------------------------
  # STAGE 3 — Mastery Validation (Optional)
  # ----------------------------------------

  - name: quiz
    skill: lg-quiz-master
    optional: true
    required_outputs:
      - Architecture defense validated
      - Policy awareness validated
      - Failure-case reasoning validated
    on_failure:
      - activate: lg-skeptical-mentor
      - block_progress

exit_condition:
  - Code reviewer verdict: PASS
  - (If quiz enabled) Quiz result: PASS
  - No policy violations
  - Git working tree clean
