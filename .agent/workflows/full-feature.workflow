version: 1.1
name: full-feature
description: >
  End-to-end deterministic workflow for implementing
  a complete Liquid Galaxy Flutter feature.

entry_condition:
  - Feature idea provided by user.

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
  # STAGE 1 — Initialization Verification
  # ----------------------------------------

  - name: initialization-check
    skill: lg-project-initializer
    mode: verify-only
    required_outputs:
      - LGConnectionService exists
      - LGConfig exists
      - Project structure valid
    on_failure:
      - block_progress

  # ----------------------------------------
  # STAGE 2 — Brainstorm
  # ----------------------------------------

  - name: brainstorm
    skill: lg-brainstormer
    required_outputs:
      - Architecture decision
      - Failure case identification
      - LG method mapping
      - Geometry validation plan
      - Testing strategy defined
      - Design document created
    on_failure:
      - activate: lg-skeptical-mentor
      - block_progress

  # ----------------------------------------
  # STAGE 3 — Plan
  # ----------------------------------------

  - name: plan
    skill: lg-plan-writer
    preconditions:
      - Design document committed
    required_outputs:
      - Deterministic task breakdown
      - Prevention Notes per task
      - Mock service definition
      - verifyInOrder enforcement
      - git_status: clean
    on_failure:
      - activate: lg-skeptical-mentor
      - block_progress

  # ----------------------------------------
  # STAGE 4 — Execute
  # ----------------------------------------

  - name: execute
    skill: lg-plan-executer
    required_outputs:
      - Tasks completed sequentially
      - flutter analyze passes
      - flutter test passes
      - Mock Service Tests pass:
          - sendScreenOverlay() called exactly once
          - sendKML() called exactly once
          - verifyInOrder(clearKML → sendKML)
      - Policies not violated
    on_policy_violation:
      - activate: lg-skeptical-mentor
      - block_progress
    on_failure:
      - block_progress

  # ----------------------------------------
  # STAGE 5 — Review
  # ----------------------------------------

  - name: review
    skill: lg-code-reviewer
    required_outputs:
      - Clean architecture validation
      - Policy compliance validation
      - Geometry validation confirmation
      - No SSH duplication
      - No unsafe commands
      - Git working tree clean
    on_failure:
      - block_progress

  # ----------------------------------------
  # STAGE 6 — Knowledge Reinforcement
  # ----------------------------------------

  - name: quiz
    skill: lg-quiz-master
    required_outputs:
      - Student explains:
          - clearKML ordering
          - ScreenOverlay vs Placemark
          - Polygon loop closure
          - Master node authority
    on_failure:
      - activate: lg-skeptical-mentor
      - block_progress

exit_condition:
  - Feature fully implemented
  - All tests passing
  - No policy violations
  - Git working tree clean
  - Student demonstrates conceptual understanding
