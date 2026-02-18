---
name: Flutter Architecture Enforcer
description: Structural integrity validator for the Flutter Liquid Galaxy project. Enforces Clean Architecture boundaries and prevents cross-layer violations.
---

# 🏗 Flutter Architecture Enforcer

This skill ensures that the project adheres strictly to Clean Architecture principles.

It validates:

- Layer separation
- Import discipline
- Dependency direction
- File placement correctness
- Commit scope alignment

It does NOT validate:

- Business logic correctness
- Geometry math
- SSH sequencing
- API schema correctness

It enforces structure only.

---

# 🎯 Architectural Principles Enforced

## SOLID (Macro Level)

- Single Responsibility per layer
- Dependency Inversion enforced
- No circular dependencies
- No cross-layer contamination

## DRY

- No duplicate services across layers
- No duplicated transport logic
- No duplicated geometry builders

## YAGNI

- No premature abstraction
- No unused interfaces
- No dead feature scaffolding

---

# 📜 Policy Mapping

| Policy ID | Title | Enforcement |
|-----------|-------|-------------|
| FA-001 | Clean Layer Boundaries | No cross-layer imports |
| SAF-020 | Async Safety Awareness | No blocking calls in UI layer |
| SAF-003 | No Hardcoded Credentials | No credentials outside config |
| LG-060 | KML Payload Size Limit | Verify payload validation exists only in KmlBuilder and is not duplicated in other layers |

This skill enforces structural alignment with policies.

It does NOT enforce their runtime logic.

---

# 🏗 Allowed Dependency Flow

UI Layer
↓
Application / Feature Layer
↓
Data Layer
↓
Core Utilities (KmlBuilder)
↓
Transport Layer (LGConnectionService)


Rules:

- UI cannot import data/remote directly.
- Application cannot import dartssh2.
- Data layer cannot import services/.
- KmlBuilder cannot import services/.
- LGConnectionService cannot import KmlBuilder.

Any violation = BLOCKING DEFECT.

---

# 🔎 Enforcement Checklist

## 1️⃣ Import Discipline

Search for:

- `dartssh2` imports outside `lib/services/`
- `http` imports outside `lib/data/`
- Flutter UI imports inside `lib/application/`, `lib/data/`, or `lib/core/`
- KmlBuilder imported inside `lib/services/lg_connection_service.dart`

Violation → BLOCKING DEFECT (FA-001)

---

## 2️⃣ Layer Purity

Ensure:

- Feature layer only orchestrates
- Data layer only fetches
- Transport layer only sends
- KML builder only builds geometry

No mixing of responsibilities.

---

## 3️⃣ Circular Dependency Check

Ensure:

- No file in data imports application
- No file in services imports application
- No file in core imports services

Violation → FAIL

---

## 4️⃣ Directory Compliance

Ensure files are placed correctly:

- lib/data/remote/
- lib/core/kml/
- lib/services/
- lib/application/

Misplaced file → CONDITIONAL PASS (requires refactor)

---

## 5️⃣ Commit Scope Alignment

Allowed scopes:

- data
- services
- core
- application
- presentation
- architecture (for structural enforcement only)

Any other scope (e.g., feat(logic), feat(utils), feat(api))  
→ BLOCKING DEFECT

Scope must match modified directory.
Mixed-layer commits → BLOCKING DEFECT.

---

## 6️⃣ Credential Injection Enforcement (SAF-003)

Verify:

- No hardcoded IP, username, or password inside services
- Credentials must be injected via constructor
- No credentials stored in source code outside config layer

Hardcoded credentials → BLOCKING DEFECT

---

# 🚫 What This Skill Does NOT Do

❌ Does NOT inspect KML strings  
❌ Does NOT check sequencing order  
❌ Does NOT check timeout values  
❌ Does NOT test API logic  
❌ Does NOT validate UI widgets  

Structural validation only.

---

# 🧪 Execution Mode

When activated:

1. Scan project structure.
2. Validate import graph.
3. Validate dependency direction.
4. Validate file placement.
5. Validate commit scope.
6. Produce deterministic report.

Report format:

- PASS
- CONDITIONAL PASS
- FAIL

Each violation must cite Policy ID.

---

# 🧭 Definition of Done

- No cross-layer imports
- No circular dependencies
- No mixed commit scopes
- No misplaced files
- All layers structurally clean

---

# 📝 Commit Convention

Commit format must follow:

chore(architecture): enforce clean architecture boundaries

Scope MUST be `architecture`.
No logic changes allowed in this commit.
