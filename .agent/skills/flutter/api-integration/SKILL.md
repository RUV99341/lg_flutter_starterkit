---
name: Liquid Galaxy Flutter API Integration
description: External API data ingestion layer. Responsible for fetching, validating, and mapping remote data into domain models. No geometry. No transport. No visualization.
---

# 🌐 API Integration Layer

This skill defines how external APIs are integrated into the system.

Responsibilities:

- Perform HTTP requests
- Validate JSON schema
- Map JSON → Domain Model
- Handle network errors
- Enforce rate limiting / caching
- Prevent UI blocking

It is NOT responsible for:

- Building KML
- Sending data to LG
- Deciding how visuals are rendered
- Managing screen orchestration

It produces structured data only.

---

# 🎯 Architectural Role

Layer: `data/remote/`

Clean Architecture:

- Depends on `http` or `dio`
- Returns domain entities
- No Flutter imports
- No KML knowledge
- No SSH knowledge
- No visualization logic

Single Responsibility: External data access only.

---

# 📜 Policy Mapping

| Policy ID | Title | Enforcement |
|-----------|-------|-------------|
| SAF-034 | API Rate Limiting | Throttle or cache API calls to prevent abuse |
| SAF-020 | Async Safety | All network calls awaited |
| SAF-033 | Network Timeout | HTTP requests must timeout (e.g., 5s) |
| SAF-022 | API Error Boundary | Convert HTTP and schema failures into domain-safe exceptions |
| FA-001 | Clean Layer Boundaries | No UI imports; return pure models |

Note:

This layer enforces SAF-020 (Dart async safety) but must never reference or trigger LG-020 (Clear Before Inject), as it has no knowledge of Liquid Galaxy transport or sequencing rules.

---

# 🏗 File Structure

```lib/data/remote/api_service.dart```
```lib/data/models/api_response_model.dart```

```kotlin

Primary class:

```dart
class ApiService {
  final http.Client _client;

  ApiService(this._client);

  Future<List<PointOfInterest>> fetchPoints();
}
```

Domain model:
```bash
lib/domain/entities/point_of_interest.dart
```
No geometry fields beyond what API provides.

# ⚙️ Implementation Rules
## 1️⃣ Timeout Enforcement (SAF-033)

Every request must specify timeout:
```dart
final response = await _client
    .get(Uri.parse(endpoint))
    .timeout(const Duration(seconds: 5));
```

No unbounded requests allowed.

## 2️⃣ Async Safety (SAF-020)

All calls must:

- Use await
- Not block UI
- Return Future types

No synchronous network access.

## 3️⃣ Rate Limiting / Caching (SAF-034)

Basic caching mechanism required.

Example:
```dart
DateTime? _lastFetch;
List<PointOfInterest>? _cached;

Future<List<PointOfInterest>> fetchPoints() async {
  if (_cached != null &&
      _lastFetch != null &&
      DateTime.now().difference(_lastFetch!) <
          const Duration(minutes: 5)) {
    return _cached!;
  }

  final data = await _fetchFromApi();
  _cached = data;
  _lastFetch = DateTime.now();
  return data;
}
```

Prevents API abuse during kiosk mode.

## 4️⃣ JSON Schema Validation

Before mapping:

- Validate required keys
- Throw descriptive exception if missing

Example:
```dart
if (!json.containsKey("latitude") ||
    !json.containsKey("longitude")) {
  throw ApiSchemaException("Missing coordinates.");
}
```

Do NOT silently ignore malformed data.

## 5️⃣ Error Handling

Handle:

- 4xx errors
- 5xx errors
- TimeoutException
- SocketException

Convert to domain-safe exceptions.

Do NOT propagate raw HTTP exceptions upward.

# 🧩 Reference Implementation

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final http.Client _client;

  ApiService(this._client);

  Future<List<PointOfInterest>> fetchPoints() async {
    final response = await _client
        .get(Uri.parse("https://example.com/api"))
        .timeout(const Duration(seconds: 5));

    if (response.statusCode != 200) {
      throw Exception("API request failed.");
    }

    final List<dynamic> decoded = jsonDecode(response.body);

    return decoded.map((json) {
      if (!json.containsKey("lat") ||
          !json.containsKey("lon")) {
        throw Exception("Invalid API schema.");
      }

      return PointOfInterest(
        latitude: json["lat"],
        longitude: json["lon"],
        title: json["title"] ?? "",
      );
    }).toList();
  }
}
```

# 🧪 Test Requirements

File:
```bash
test/data/remote/api_service_test.dart
```

Must verify:

- Timeout occurs properly
- Non-200 throws exception
- Schema validation triggers error
- Caching prevents redundant calls
- No unawaited futures
- JSON correctly mapped to domain entity

Use mocked http.Client.

# 🚫 What This Skill Does NOT Do

❌ Does NOT loop and build KML
❌ Does NOT call LGConnectionService
❌ Does NOT orchestrate visualization
❌ Does NOT calculate geometry
❌ Does NOT manipulate rig screens

It returns data only.

# 🔎 Code Review Expectations

```lg-code-reviewer``` will check:

- No Flutter imports
- No KML string creation
- No LGConnectionService usage
- Timeout enforced
- Rate limiting implemented
- Exceptions handled properly
- Await usage enforced

Violation → BLOCKING DEFECT

# 🧭 Design Philosophy

This layer knows:
- HOW to fetch data

It does NOT know:
- HOW it will be visualized
- HOW many screens exist
- HOW geometry is built
- HOW data is sent to LG

Strict separation maintained.

# 🏁 Definition of Done

- Compiles
- No UI imports
- Timeout enforced
- Rate limiting active
- Schema validated
- Tests passing
- Analyzer clean

# 📝 Commit Convention

Commit format must follow:

feat(data): implement ApiService with timeout and caching

Any inclusion of services/, kml/, or visualization logic in this commit violates FA-001 and will be treated as a BLOCKING DEFECT.

Scope MUST be data.
No multi-layer commits allowed.

---