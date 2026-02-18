---
name: Liquid Galaxy Flutter Project Initializer
description: Bootstrap a production-grade Flutter-based Liquid Galaxy application with correct architecture, rig configuration, and Gemini-compliant agent setup.
---

# 🚀 Liquid Galaxy Flutter Project Initializer

This is the **FIRST step** in the 6-stage Agentic Pipeline:

**Init → Brainstorm → Plan → Execute → Review → Quiz (Finale)**

This skill is responsible for creating a clean, scalable, production-ready Flutter Liquid Galaxy starter foundation.

---

# ⚠️ PROMINENT GUARDRAIL

The **Skeptical Mentor** (.agent\skills\core\lg-skeptical-mentor\SKILL.md) must be active at all times.

If the student:
- Rushes setup
- Skips architecture discussion
- Treats this as boilerplate generation
- Cannot explain LG rig constraints

→ Immediately activate `lg-skeptical-mentor`.

We are building engineers, not scaffolding machines.

---

# 🧠 LLM CONSTRAINT

- Must use **Gemini only**
- No external LLM calls
- All reasoning must be explainable
- No hidden automation
- Architecture decisions must be justified

---

# ⛓️ Phase 0 — Repository & Environment Verification

Before initialization, verify:

1. **Git is initialized**
   ```bash
   git status
   ```
2. **If not initialize:**
    ```bash
    run `git init`
    ```
3. **Confirm:**
    - Is this a new repositroy?
    - Or a fork of an LG Flutter StarterKit?
4. **Confirm Flutter is installed:**
    ```bash
    flutter doctor
    ```
5. **Ensure:**
    - Flutter stable channel
    - Dart enabled
    - Android toolchain working

# 🏁 Phase 1 — Requirement Gathering (MANDATORY)

Before generating anything, ask:

1. **Project Identity**
    - Project Name
    - One-line mission statement
    - Target demo impact on LG video wall
2. **LG Rig Configuration**
    - Screen count (3 / 5 / 7)
    - Confirm portrait (1080x1920)
    - Confirm identical screens
    - Confirm no heterogeneous layout
   
**Non-negotiabe:** Liquid Galaxy uses identical portrait screens forming one seamless panoramic window.
3. **Data Source**
    - External API?
    - Static KML?
    - Real-time updates?
    - AI-powered feature?
4. **Core Feature Type**
    - Geospatial Visualization?
    - Dashboard?
    - Interactive Explorer?
    - AI-assisted visualization?

# 🏗 Phase 2 — Flutter StarterKit Structure

If no Flutter StarterKit exists → generate one.

Follow this structure:
```text
/
├── .agent/
├── docs/
│   ├── plans/
│   ├── reviews/
│   └── architecture-map.md
│
├── lib/
│   ├── main.dart
│   │
│   ├── presentation/
│   │   ├── screens/
│   │   ├── widgets/
│   │   └── theme/
│   │
│   ├── domain/
│   │   ├── entities/
│   │   ├── repositories/
│   │   └── usecases/
│   │
│   ├── data/
│   │   ├── models/
│   │   ├── datasources/
│   │   └── repositories_impl/
│   │
│   ├── services/
│   │   ├── lg_connection_service.dart
│   │   ├── kml_service.dart
│   │   └── api_service.dart
│   │
│   └── core/
│       ├── constants/
│       ├── utils/
│       └── errors/
│
├── test/
├── pubspec.yaml
└── README.md
```
# 🛠 Phase 3 — Dependency Setup

Create:
```lib/core/constants/lg_config.dart```
```dart
class LGConfig {
  // Set this from user input during initialization  
  static int screenCount = 3; // dynamic from user
  static const int screenWidth = 1080;
  static const int screenHeight = 1920;

  static int get worldWidth => screenWidth * screenCount;
}
```
**Explain:**
    - WORLD_WIDTH = SCREEN_WIDTH × SCREENS
    - Treat rig as one panoramic canvas

# 📦 Phase 4 — pubspec.yaml Dependencies

Add to pubspec.yaml:

```yaml
dependencies:
  dartssh2: ^2.9.0
  xml: ^6.3.0

dev_dependencies:
  mockito: ^5.4.0
  build_runner: ^2.4.0
  flutter_test:
    sdk: flutter
```

Run: 
```bash
flutter pub get
```

# 🔐 Phase 5 — LG Connection & Overlay Service Scaffold

Create:

```lib/services/lg_connection_service.dart```

This service is responsible for communicating with the Liquid Galaxy master node via SSH.

**⚠️ Architectural Rule:**
There are TWO types of KML operations:

1. Geospatial KML (Placemarks, LookAt, Tours)
2. ScreenOverlay KML (Logos, persistent UI elements)

They are NOT interchangeable.

---

## Scaffold

```dart
class LGConnectionService {
  Future<void> connect(String host, String username, String password) async {}

  /// Sends geospatial KML (Placemarks, LookAt, Tours)
  Future<void> sendKML(String kml) async {}

  /// Clears existing KML layers
  Future<void> clearKML() async {}

  /// Sends persistent UI elements (Logo, watermark, HUD)
  /// This MUST generate a ScreenOverlay KML
  Future<void> sendScreenOverlay({
    required String imageUrl,
    required double overlayX,
    required double overlayY,
    double sizeX = 0.2,
    double sizeY = 0.2,
  }) async {}
}
```

**Explain:**
    - SSH to master node
    - KML injection via command
    - Clear layers before new push

# 🎓 Phase 6 — Golden Engineering Principles

- UI logic stays in presentation layer
- KML generation belongs in services
- All LG communication flows through LGConnectionService

# 📄 Documentation Required
Create:
```docs/project-overview.md```

**Include:**
    - Rig configuration
    - Architecture approach
    - Screen strategy
    - Data source
    - Engineering principles
    - Learning objectives

**Commit**
```bash
git add .
git commit -m "chore: initialize Flutter Liquid Galaxy project foundation"
```

# 🚦 Final Step

**Ask:** "Project foundation is ready. Are you ready to brainstorm your first feature?"

Then activate:
```lg-brainstormer```