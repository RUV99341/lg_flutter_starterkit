version: 1.1
name: add-screen
description: >
  Workflow for adding a new Flutter screen
  while preserving Clean Architecture,
  LG rig constraints, safety policies,
  and kiosk-grade usability.

entry_condition:
  - A new UI screen must be added.

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
  # STAGE 0 — Foundation Verification
  # ----------------------------------------

  - name: foundation-check
    skill: lg-project-initializer
    mode: verify-only
    required_outputs:
      - LGConnectionService exists
      - LGConfig exists
      - Project structure valid
    on_failure:
      - block_progress
      - message: "Run full-feature workflow first to initialize project foundation."

  # ----------------------------------------
  # STAGE 1 — UI Architecture & Ergonomics
  # ----------------------------------------

  - name: screen-brainstorm
    skill: lg-brainstormer
    mode: screen-only
    required_outputs:
      - Screen purpose defined
      - Navigation flow defined
      - Data dependencies identified
      - State management approach selected
      - LG interaction points identified (if any)
      - Interactive Zone Verification completed:
          - Buttons not placed at extreme center-bottom
          - Controls positioned to avoid blocking Master screen
    on_failure:
      - activate: lg-skeptical-mentor
      - block_progress

  # ----------------------------------------
  # STAGE 2 — Deterministic Planning
  # ----------------------------------------

  - name: screen-plan
    skill: lg-plan-writer
    mode: screen-only
    required_outputs:
      - Screen widget file defined
      - Route registration defined
      - ViewModel or Controller defined
      - Dependency injection plan defined
      - Widget test plan defined
      - Asset initialization plan (if overlays used)
      - git_status: clean
    on_failure:
      - activate: lg-skeptical-mentor
      - block_progress

  # ----------------------------------------
  # STAGE 3 — Implementation
  # ----------------------------------------

  - name: screen-execute
    skill: lg-plan-executer
    required_outputs:
      - New screen widget created
      - No business logic in UI (FA-001)
      - No LG calls inside build() (LG-051)
      - Portrait layout respected (LG-001)
      - Navigation registered correctly
      - Dependency injection configured
      - Asset pre-caching implemented (if ScreenOverlay used)
      - Ensure image asset loaded before sendScreenOverlay()
      - flutter analyze passes
      - flutter test passes
      - Widget tests pass
    on_policy_violation:
      - activate: lg-skeptical-mentor
      - block_progress
    on_failure:
      - block_progress

  # ----------------------------------------
  # STAGE 4 — Review
  # ----------------------------------------

  - name: screen-review
    skill: lg-code-reviewer
    required_outputs:
      - No UI-layer API calls (FA-001)
      - No UI-layer KML generation (FA-004)
      - No hardcoded credentials (SAF-003)
      - No unsafe lifecycle LG calls (SAF-021)
      - Overlay asset readiness verified (SAF-031)
      - Git working tree clean
    on_failure:
      - block_progress

exit_condition:
  - Screen added successfully
  - All tests passing
  - Policies not violated
  - Git working tree clean
