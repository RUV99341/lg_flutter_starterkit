---
name: Liquid Galaxy Flutter KML Generation
description: Pure KML builder for Liquid Galaxy geometry. No transport. No UI. No SSH. Geometry-only responsibility.
---

# 🧭 KML Generation Engine

This skill defines how valid KML is constructed for Liquid Galaxy.

It is responsible for:

- Building Polygon geometry (e.g., 3D pyramid)
- Building Placemark wrappers
- Ensuring LinearRing closure
- Enforcing altitudeMode correctness
- Enforcing extrude behavior
- Enforcing payload size limits

It is NOT responsible for:

- Sending KML
- Managing SSH
- Managing app state
- Orchestrating feature flow

This layer builds strings only.

---

# 🎯 Architectural Role

Layer: `core/utils/` or `core/kml/`

Purpose: Geometry construction only.

Clean Architecture:

- Single Responsibility
- No external dependencies
- No Flutter imports
- No dartssh2 imports

---

# 🚫 What This Skill Does NOT Do

❌ Does NOT open SSH connections  
❌ Does NOT call LGConnectionService  
❌ Does NOT manage feature logic  
❌ Does NOT decide WHEN to send KML  
❌ Does NOT store state  

It builds valid KML strings.

Nothing else.

---

# 📜 Policy Mapping

| Policy ID | Title | Enforcement |
|-----------|-------|-------------|
| LG-030 | LinearRing Loop Closure | First and last coordinates must match |
| LG-031 | Extrusion Required | `<extrude>1</extrude>` enforced |
| LG-032 | Relative Altitude Required | `<altitudeMode>relativeToGround</altitudeMode>` enforced |
| LG-060 | KML Payload Size Limit | Reject payload > max_kml_payload_size_kb |

---

# 🏗 File Structure

```lib/core/kml/kml_builder.dart```


Primary class:

```dart
class KmlBuilder {
  String buildPyramid({
    required double latitude,
    required double longitude,
    required double baseSizeMeters,
    required double heightMeters,
  });

  String wrapPlacemark(String name, String geometryKml);

  String wrapDocument(List<String> placemarks);
}
```

Primary class:

```dart
class KmlBuilder {
  String buildPyramid({
    required double latitude,
    required double longitude,
    required double baseSizeMeters,
    required double heightMeters,
  });

  String wrapPlacemark(String name, String geometryKml);

  String wrapDocument(List<String> placemarks);
}
```

# 🧠 Geometry Rules (MANDATORY)
## 1. LinearRing Closure

The first and last coordinate must match.

Violation:
→ Throw InvalidGeometryException

## 2. Extrusion Required

Every 3D polygon must include:
```xml
<extrude>1</extrude>
```
No conditional logic.
Always enforced.

## 3. Altitude Mode

Must include:
```xml
<altitudeMode>relativeToGround</altitudeMode>
```

Absolute altitude not allowed unless explicitly required by plan.

## 4. Coordinate Optimization

Do NOT generate unnecessary coordinates.

For pyramid:

- 4 base corners
- 1 apex
- Minimal required faces

Do NOT oversample.

```optimize_coordinate_density = true``` enforced via config.

## 5. Payload Size Protection

Before returning KML string:
```dart
if (_kmlSizeExceedsLimit(kml)) {
  throw KmlSizeException(
    "KML payload exceeds max_kml_payload_size_kb"
  );
}
```

Max size derived from config (100 KB default).

# 🧩 Reference Implementation (Pyramid)

```dart
class KmlBuilder {

  static const int _maxKmlSizeKb = 100;

  String buildPyramid({
    required double latitude,
    required double longitude,
    required double baseSizeMeters,
    required double heightMeters,
  }) {
    final coords = _calculateBaseSquare(
      latitude,
      longitude,
      baseSizeMeters,
    );

    final apex = "$longitude,$latitude,$heightMeters";

    final polygon = """
<Placemark>
  <Polygon>
    <extrude>1</extrude>
    <altitudeMode>relativeToGround</altitudeMode>
    <outerBoundaryIs>
      <LinearRing>
        <coordinates>
          ${coords.join(" ")}
        </coordinates>
      </LinearRing>
    </outerBoundaryIs>
  </Polygon>
</Placemark>
""";

    _validateRingClosure(coords);
    _validatePayloadSize(polygon);

    return polygon;
  }

  void _validateRingClosure(List<String> coords) {
    if (coords.first != coords.last) {
      throw Exception("LinearRing not closed.");
    }
  }

  void _validatePayloadSize(String kml) {
    final sizeKb = kml.length / 1024;
    if (sizeKb > _maxKmlSizeKb) {
      throw Exception("KML exceeds allowed size.");
    }
  }

  List<String> _calculateBaseSquare(
    double lat,
    double lon,
    double size,
  ) {
    final delta = size / 111320; // rough meter-to-degree conversion

    final points = [
      "${lon - delta},${lat - delta},0",
      "${lon + delta},${lat - delta},0",
      "${lon + delta},${lat + delta},0",
      "${lon - delta},${lat + delta},0",
    ];

    points.add(points.first); // enforce closure

    return points;
  }
}
```

# 🧪 Test Requirements

File:
```bash
test/core/kml/kml_builder_test.dart
```

Tests must verify:

- Ring closure enforced
- extrude present
- altitudeMode present
- Payload size rejection works
- No duplicate coordinates
- Minimal coordinate generation

Tests must inspect actual returned string.

Mocking not required here.

# 🔎 Code Review Expectations

```lg-code-reviewer``` will:

- Inspect actual generated KML string
- Verify LinearRing closure
- Verify extrude tag
- Verify altitudeMode
- Verify payload size discipline
- Verify no transport logic inside
- Violation → BLOCKING DEFECT

# 🧭 Design Philosophy

This class knows:

- HOW to build valid KML

It does NOT know:

- HOW to send it
- WHEN to send it
- WHY it is sent

That belongs to:

- Feature services
- Use cases
- LGConnectionService

Strict separation maintained.

# 🏁 Definition of Done

- Geometry valid
- Policies enforced
- Payload limited
- Analyzer clean
- Tests passing
- No external dependencies
- No transport logic

# 📝 Commit Convention

Commit format must follow:

feat(core): implement KmlBuilder with extrusion and payload validation

Scope MUST be core.
No multi-layer commits allowed.


---

# 🧠 Strategic Question

If you later need to generate 500 dynamic placemarks from an API response,

should that loop live inside:

A) KmlBuilder  
B) Feature service  
C) LGConnectionService  

Think carefully.
