---
name: Liquid Galaxy Flutter Multi-Screen Visualization
description: Rig-aware orchestration layer for controlling multi-screen Liquid Galaxy behavior. No geometry logic. No SSH logic. No UI logic.
---

# 🖥 Multi-Screen Visualization Engine

This skill manages how visual content is distributed across a Liquid Galaxy rig.

It is responsible for:

- Master-only vs parallel mode selection
- Screen index awareness
- Bezel-safe placement logic
- Overlay positioning normalization
- Screen-targeted command routing (via LGConnectionService)

It is NOT responsible for:

- Building KML geometry (KmlBuilder handles this)
- Opening SSH connections (LGConnectionService handles this)
- Managing Flutter UI
- Fetching API data

This layer orchestrates visual distribution only.

---

# 🎯 Architectural Role

Layer: `services/visualization/`

Purpose: Rig-aware command orchestration.

Clean Architecture:

- Depends on LGConnectionService
- Depends on KmlBuilder
- No Flutter imports
- No dartssh2 imports
- No direct socket handling

---

# 📜 Policy Mapping

| Policy ID | Title | Enforcement |
|-----------|-------|-------------|
| LG-040 | Bezel-Safe Placement | Centered visuals aligned to Master screen (screen 2 in 3-screen rig) |
| LG-031 | Extrusion Required | Ensured indirectly through KmlBuilder |
| LG-032 | Relative Altitude Required | Ensured indirectly through KmlBuilder |
| SAF-020 | Await All Network Operations | All LGConnectionService calls awaited |
| SAF-033 | 5s Timeout Enforcement | All orchestrated operations rely on LGConnectionService which enforces `Duration(seconds: 5)` on connect and execute. |

This layer does not duplicate geometry enforcement.

---

# 🧠 Core Responsibilities

## 1️⃣ Rig Mode Selection

Supported modes:

- MasterOnly
- Parallel

```dart
enum RigMode {
  masterOnly,
  parallel,
}
```
## 2️⃣ Master Screen Awareness

For 3-screen rig:

- Screen 1 → Left
- Screen 2 → Master (Center)
- Screen 3 → Right

Visual center = Screen 2

This aligns with LG-040 (Bezel-safe placement).

No hardcoded magic numbers outside this class.

## 3️⃣ Overlay Placement Strategy

Overlays must:

- Avoid bezel overlap
- Avoid extreme edges
- Default to center-top safe region

Example normalized placement:
```dart
const defaultOverlayX = 0.5;
const defaultOverlayY = 0.9;
```

Must remain within 0.0–1.0 range.

# 🏗 File Structure
```bash
lib/services/visualization/multi_screen_visualization_service.dart
```

Primary class:
```dart
class MultiScreenVisualizationService {
  final LGConnectionService _connectionService;
  final KmlBuilder _kmlBuilder;

  MultiScreenVisualizationService(
    this._connectionService,
    this._kmlBuilder,
  );

  Future<void> displayPyramid({
    required double latitude,
    required double longitude,
    required double baseSizeMeters,
    required double heightMeters,
    RigMode mode = RigMode.masterOnly,
  });

  Future<void> displayLogoOverlay({
    required String imageUrl,
    double overlayX = 0.5,
    double overlayY = 0.9,
  });
}
```
No additional public APIs unless required by plan.

# ⚙️ Implementation Guidelines
displayPyramid()

Steps:

1. Build geometry via KmlBuilder.
2. Wrap in Document if needed.
3. Enforce clearKML → sendKML ordering.
4. Await all operations.
5. Do NOT parallelize unless mode == parallel.

Example:
```dart
Future<void> displayPyramid(...) async {
  final kml = _kmlBuilder.buildPyramid(...);

  await _connectionService.clearKML();
  await _connectionService.sendKML(kml);
}
```

KML sequencing compliance (LG-020: clear before inject) enforced via orchestration logic and verified at execution layer.
Async enforcement is governed strictly by SAF-020.

displayLogoOverlay()

Steps:

1. Validate image URL (non-empty).
2. Normalize overlay coordinates.
3. Call sendScreenOverlay() only.
4. DO NOT call clearKML() (overlay persistence rule).

Example:
```dart
await _connectionService.sendScreenOverlay(
  imageUrl: imageUrl,
  overlayX: overlayX.clamp(0.0, 1.0),
  overlayY: overlayY.clamp(0.0, 1.0),
);
```

No geometry building inside this method.

# 🚫 What This Skill Does NOT Do

❌ Does NOT calculate polygon coordinates
❌ Does NOT validate LinearRing (KmlBuilder does)
❌ Does NOT enforce payload size (KmlBuilder does)
❌ Does NOT open SSH
❌ Does NOT hardcode IP
❌ Does NOT manage UI navigation

Strict orchestration only.

# 🧪 Test Requirements

File:
```bash
test/services/visualization/multi_screen_visualization_service_test.dart
```

Tests must verify:

- clearKML called before sendKML (verifyInOrder)
- sendScreenOverlay called exactly once
- overlay coordinates clamped to 0–1
- No unexpected additional calls
- MasterOnly mode does not trigger parallel logic

Mockito required for LGConnectionService.

# 🔎 Code Review Expectations

```lg-code-reviewer``` will check:

- No geometry inside visualization service
- No SSH import
- Await usage
- Correct clear/send ordering
- No UI imports
- Overlay not cleared unintentionally

Violation → BLOCKING DEFECT

# 🧭 Design Philosophy

This layer knows:

- HOW to distribute visuals across the rig

It does NOT know:

- HOW to build geometry (KmlBuilder)
- HOW to transport commands (LGConnectionService)
- WHY feature exists (Feature layer)

This separation preserves:

- SOLID
- DRY
- YAGNI

# 🏁 Definition of Done

- Compiles
- Uses dependency injection
- All calls awaited
- Correct call order verified in tests
- No geometry duplication
- No SSH logic
- Analyzer clean
- Tests passing

# 📝 Commit Convention

Commit format must follow:

feat(services): implement MultiScreenVisualizationService with master-only logic

Scope MUST be services.
No multi-layer commits allowed.

# 
---

# 🧠 Strategic Question

If you later support a 7-screen rig,

where should screen-count logic be extended?

A) KmlBuilder  
B) LGConnectionService  
C) MultiScreenVisualizationService  
D) Feature Service  

Think carefully about responsibility boundaries.
