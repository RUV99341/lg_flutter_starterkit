---
name: Liquid Galaxy Flutter LG Connection Service
description: Implements the single authoritative SSH transport layer for communicating with the Liquid Galaxy Master node. No geometry logic. No UI logic. Transport only.
---

# 🔐 LG Connection Service

This skill defines and enforces the ONLY class allowed to:

- Open SSH connections
- Send commands to Liquid Galaxy
- Inject KML into `/tmp/query.txt`
- Send ScreenOverlay KML
- Clear geospatial content

It is a transport adapter.

It is NOT:

- A geometry builder
- A feature orchestrator
- A UI component
- A business logic layer

---

# 🎯 Architectural Role

Layer: `services/`

Purpose: External system communication (Liquid Galaxy Master Node)

Clean Architecture Principle:
- Single Responsibility (SRP)
- Dependency Inversion
- No upward dependencies

---

# 🚫 What This Skill Does NOT Do

❌ Does NOT build pyramid geometry  
❌ Does NOT calculate coordinates  
❌ Does NOT manage app state  
❌ Does NOT implement feature flows  
❌ Does NOT duplicate SSH logic elsewhere  
❌ Does NOT contain hardcoded credentials  

KML structure belongs in `core/utils` (e.g., KmlBuilder).

This class sends raw strings only.

---

# 🏗 Class Contract (MANDATORY)

File: ```lib/services/lg_connection_service.dart```


Required methods (from initializer contract :contentReference[oaicite:4]{index=4}):

```dart
Future<void> connect(String host, String username, String password);
Future<void> sendKML(String kml);
Future<void> clearKML();
Future<void> sendScreenOverlay({
  required String imageUrl,
  required double overlayX,
  required double overlayY,
  double sizeX = 0.2,
  double sizeY = 0.2,
});
```
No additional public methods unless explicitly required by plan.

YAGNI enforced.

# ⚙️ Implementation Rules

## 1. Single SSH Authority (SAF-003)

- Must use dartssh2
- Must NOT expose SSHClient outside this class
- Must NOT allow multiple connection classes
- Must NOT hardcode IP / username / password

Credentials must be passed via connect().

## 2. Async Safety (SAF-020)

All external calls MUST:

- Be awaited
- Not fire-and-forget
- Not return unhandled futures

Forbidden:
```dart
_sshClient.execute("command"); // ❌ no await
```

Required:
```dart
await _sshClient.execute("command"); // ✅
```

## 3. Timeout Enforcement (SAF-033)

All SSH operations must use a timeout.

Example:
```dart
await _sshClient
    .execute(command)
    .timeout(const Duration(seconds: 5));
```

No blocking UI thread.
No indefinite waits.

## 4. Command Whitelist (SAF-004)

Allowed commands:

- echo
- printf

Forbidden:

- sudo
- apt
- wget
- rm -rf
- systemctl

This class must never expose arbitrary shell execution.

# 📜 Policy Mapping

| Policy ID   | Title                         | Implementation Requirement |
|-------------|--------------------------------|-----------------------------|
| SAF-003     | No Hardcoded Credentials       | Credentials passed via `connect()` only. |
| SAF-020     | Async Safety                   | All SSH calls awaited. |
| SAF-033     | 5s Timeout Enforcement         | `Duration(seconds: 5)` applied to both `connect()` and `_executeSafeCommand()`. |
| SAF-004     | Command Whitelist              | `_containsForbiddenCommand()` blocks restricted binaries. |


# 🧠 Implementation (Reference)

```dart
import 'package:dartssh2/dartssh2.dart';

class LGConnectionService {
  SSHClient? _client;

  Future<void> connect(
    String host,
    String username,
    String password,
  ) async {
    final socket = await SSHSocket.connect(host, 22)
        .timeout(const Duration(seconds: 5));

    _client = SSHClient(
      socket,
      username: username,
      onPasswordRequest: () => password,
    );
  }

  Future<void> clearKML() async {
    _ensureConnected();
    await _executeSafeCommand('echo "" > /tmp/query.txt');
  }

  Future<void> sendKML(String kml) async {
    _ensureConnected();

    final escaped = kml.replaceAll('"', r'\"');
    await _executeSafeCommand('echo "$escaped" > /tmp/query.txt');
  }

  Future<void> sendScreenOverlay({
    required String imageUrl,
    required double overlayX,
    required double overlayY,
    double sizeX = 0.2,
    double sizeY = 0.2,
  }) async {
    _ensureConnected();

    final overlayKml = """
<ScreenOverlay>
  <name>Overlay</name>
  <Icon><href>$imageUrl</href></Icon>
  <overlayXY x="$overlayX" y="$overlayY" xunits="fraction" yunits="fraction"/>
  <screenXY x="$overlayX" y="$overlayY" xunits="fraction" yunits="fraction"/>
  <size x="$sizeX" y="$sizeY" xunits="fraction" yunits="fraction"/>
</ScreenOverlay>
""";

    final escaped = overlayKml.replaceAll('"', r'\"');
    await _executeSafeCommand('echo "$escaped" > /tmp/query.txt');
  }

  Future<void> _executeSafeCommand(String command) async {
    if (_client == null) {
      throw Exception("LGConnectionService not connected.");
    }

    if (_containsForbiddenCommand(command)) {
      throw Exception("Forbidden command detected.");
    }

    final session = await _client!.execute(command)
        .timeout(const Duration(seconds: 5));

    await session.done;
  }

  void _ensureConnected() {
    if (_client == null) {
      throw Exception("SSH connection not established.");
    }
  }

  bool _containsForbiddenCommand(String command) {
    const forbidden = ['sudo', 'apt', 'wget', 'rm -rf', 'systemctl'];
    return forbidden.any((f) => command.contains(f));
  }
}
```

# 🧪 Test Requirements (MANDATORY)

Must include:
```bash
test/services/lg_connection_service_test.dart
```

Tests must verify:

- Throws if not connected
- Rejects forbidden commands
- All methods are awaited
- No direct SSH usage outside this class (checked via code review)

Mockito allowed for upper-layer tests.
Real SSH connection not required in unit tests.

# 🔎 Code Review Alignment

```lg-code-reviewer``` will check:

- No hardcoded credentials
- No duplicate SSH logic
- No dartssh2 outside services layer
- Await enforced
- Timeout enforced
- No arbitrary shell injection

Violation → BLOCKING DEFECT.

# 🏁 Definition of Done

This skill is complete when:

- Class compiles
- All methods async-safe
- Timeout enforced
- Command whitelist enforced
- No geometry logic inside
- Tests written
- Analyzer clean
- Commit format correct

---

# 📝 Commit Convention

Commit format must follow:

feat(services): implement LGConnectionService with timeout and command whitelist

Scope MUST be `services`.
No multi-layer commits allowed.

---

# 🧭 Design Philosophy

This service knows:

- HOW to talk to LG

It does NOT know:

- WHAT to send
- WHY it is sent
- WHEN it is sent

That responsibility belongs to feature services (e.g., PyramidService, LogoService).

Separation is intentional.


---

# 🧠 Strategic Check

Answer this:

If tomorrow you switch from SSH to WebSocket-based LG control,

which layer changes?

A) Presentation  
B) Domain  
C) LGConnectionService  
D) KmlBuilder  

Think carefully.
