---
name: Liquid Galaxy Flutter Feature Extension
description: Orchestrates new feature development by coordinating API data, KML generation, and multi-screen visualization without violating architectural boundaries.
---

# 🧩 Feature Extension Orchestrator

This skill defines how new features are added to the system.

It is responsible for:

- Coordinating data retrieval
- Transforming domain data into visualization intent
- Calling KmlBuilder
- Calling MultiScreenVisualizationService
- Maintaining strict layer separation

It is NOT responsible for:

- Building geometry (KmlBuilder handles this)
- Opening SSH connections (LGConnectionService handles this)
- Managing HTTP directly (ApiService handles this)
- Implementing UI widgets

This layer orchestrates feature logic only.

---

# 🎯 Architectural Role

Layer: `application/feature/`

Clean Architecture:

- Depends on:
  - ApiService
  - KmlBuilder
  - MultiScreenVisualizationService
- Does NOT depend on dartssh2
- Does NOT depend on http
- Does NOT import Flutter UI widgets

Single Responsibility:
Feature coordination.

---

# 📜 Policy Mapping

| Policy ID | Title | Enforcement |
|-----------|-------|-------------|
| FA-001 | Clean Layer Boundaries | No cross-layer contamination |
| LG-020 | Clear Before Inject | Enforced via MultiScreenVisualizationService (never directly implemented here) |
| SAF-020 | Async Safety | All feature calls awaited |
| SAF-022 | Error Boundary | Catch and transform service-level exceptions |
| SAF-033 | Network Timeout Awareness | Handle TimeoutException from lower layers deterministically |
| SAF-034 | Rate Limiting | Delegated to ApiService |

Note:

This layer does NOT implement LG-020 sequencing logic itself.
It delegates all clearKML → sendKML ordering to MultiScreenVisualizationService.
Implementing sequencing here would violate FA-001 (Clean Layer Boundaries).

---

# 🏗 File Structure

```lib/application/features/poi_feature_service.dart```

Example structure:

```dart
class PoiFeatureService {
  final ApiService _apiService;
  final MultiScreenVisualizationService _visualService;
  final KmlBuilder _kmlBuilder;

  PoiFeatureService(
    this._apiService,
    this._visualService,
    this._kmlBuilder,
  );

  Future<void> displayPointsOfInterest();
}
```
No additional public methods unless required by feature.

YAGNI enforced.

# ⚙️ Implementation Pattern
Example: displayPointsOfInterest()

Steps:

1. Fetch domain data via ApiService.
2. Map domain → visualization parameters.
3. Generate KML using KmlBuilder.
4. Delegate rendering to MultiScreenVisualizationService.
5. Await all async operations.

Example:
```dart
Future<void> displayPointsOfInterest() async {
  try {
    final points = await _apiService.fetchPoints();

    final placemarks = points.map((p) {
      return _kmlBuilder.buildPyramid(
        latitude: p.latitude,
        longitude: p.longitude,
        baseSizeMeters: 50,
        heightMeters: 100,
      );
    }).toList();

    final document = _kmlBuilder.wrapDocument(placemarks);

    await _visualService.displayPyramidDocument(document);

  } on TimeoutException {
    // SAF-033: deterministic timeout handling
    throw FeatureTimeoutException(
      "Rig or API did not respond within 5 seconds."
    );
  } catch (e) {
    // SAF-022: convert to domain-safe error
    throw FeatureExecutionException(
      "Failed to render Points of Interest."
    );
  }
}
```


Note:

- No HTTP here.
- No SSH here.
- No UI here.

# 🚫 What This Skill Does NOT Do

❌ Does NOT construct raw XML strings manually
❌ Does NOT open SSH connections
❌ Does NOT import dartssh2
❌ Does NOT import http
❌ Does NOT calculate world width
❌ Does NOT manage screen count

It orchestrates dependencies only.

# 🧪 Test Requirements

File:
```bash
test/application/features/poi_feature_service_test.dart
```

Must verify:

- ApiService called exactly once
- VisualizationService called exactly once
- No direct SSH usage
- No direct HTTP usage
- All calls awaited
- Errors from ApiService properly handled
- TimeoutException from dependencies is converted into FeatureTimeoutException
- LG-020 ordering preserved via visualization service (verifyInOrder)

Use Mockito for all dependencies.

# 🔎 Code Review Expectations

```lg-code-reviewer``` will check:

- No geometry duplication
- No transport duplication
- No HTTP duplication
- Dependency injection used
- No UI imports
- Await usage enforced
- Clear orchestration logic

Violation → BLOCKING DEFECT

# 🧭 Design Philosophy

This layer knows:

- WHY a feature exists
- WHEN to fetch data
- HOW to coordinate services

It does NOT know:

- HOW KML is built
- HOW SSH works
- HOW many screens exist
- HOW rig hardware operates

Strict separation maintained.

# 🏁 Definition of Done

- Compiles
- No direct transport logic
- No direct HTTP logic
- Dependencies injected
- Async safe
- Tests passing
- Analyzer clean

# 📝 Commit Convention

Commit format must follow:

feat(application): implement POI feature orchestration

Scope MUST be ```application```.
No multi-layer commits allowed.


---

# 🧠 Strategic Question

If someone injects `http.Client` directly into `PoiFeatureService` to “optimize performance”,

is that a:

PASS  
CONDITIONAL PASS  
or FAIL?

Think strictly in terms of layer violation and FA-001.