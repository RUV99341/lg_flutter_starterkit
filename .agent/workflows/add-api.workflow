version: 1.1
name: add-api
description: >
  Workflow for integrating a new external API
  into the Flutter Liquid Galaxy application
  while enforcing architecture and safety policies.

entry_condition:
  - A new API endpoint must be integrated.

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
  # STAGE 1 — Architecture & Contract Mapping
  # ----------------------------------------

  - name: api-brainstorm
    skill: lg-brainstormer
    mode: api-only
    required_outputs:
      - API endpoint defined
      - HTTP method defined
      - JSON sample or schema provided
      - Data contract identified
      - Domain model defined
      - Error cases listed
      - Testing strategy defined
    on_failure:
      - activate: lg-skeptical-mentor
      - block_progress

  # ----------------------------------------
  # STAGE 2 — Deterministic Planning
  # ----------------------------------------

  - name: api-plan
    skill: lg-plan-writer
    mode: api-only
    required_outputs:
      - Repository interface defined
      - ApiService implementation task
      - Error handling tasks
      - Mock API test definition
      - Rate limiting or caching strategy defined
      - git_status: clean
    on_failure:
      - activate: lg-skeptical-mentor
      - block_progress

  # ----------------------------------------
  # STAGE 3 — Implementation
  # ----------------------------------------

  - name: api-execute
    skill: lg-plan-executer
    required_outputs:
      - ApiService implemented
      - Repository implemented
      - Dependency injection configured
      - HTTP timeout implemented (SAF-033)
      - Error handling implemented (SAF-022)
      - Rate limiting or caching implemented (SAF-034)
      - flutter analyze passes
      - flutter test passes
      - Mock API tests pass
    on_policy_violation:
      - activate: lg-skeptical-mentor
      - block_progress
    on_failure:
      - block_progress

  # ----------------------------------------
  # STAGE 4 — Review
  # ----------------------------------------

  - name: api-review
    skill: lg-code-reviewer
    required_outputs:
      - No API calls in UI layer (FA-001)
      - No hardcoded credentials (SAF-003)
      - Proper service abstraction (FA-002)
      - Proper error handling coverage
      - Rate limiting or caching verified (SAF-034)
      - Git working tree clean
    on_failure:
      - block_progress

exit_condition:
  - API integrated
  - All tests passing
  - Policies not violated
  - Git working tree clean
