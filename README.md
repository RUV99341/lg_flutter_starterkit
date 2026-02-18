# 🌍 LG Flutter Starter Kit

A production-ready Flutter starter kit for building **Liquid Galaxy** controller applications — designed for hackathons, rapid prototyping, and educational use.

---

## 📌 Overview

This starter kit gives you a clean, layered Flutter app that communicates with a **Liquid Galaxy rig** over SSH. Out of the box it supports:

- 🛰️ Flying the camera to geographic coordinates
- 🔺 Rendering 3D KML geometry (pyramid demo)
- 🖼️ Displaying screen overlays (logo injection)
- 🌤️ Fetching and visualising live weather data via [Open-Meteo](https://open-meteo.com/)
- 🔌 SSH connection management with persistent settings

It follows a strict **Clean Architecture** pattern so each layer is independently testable and easy to extend during a hackathon sprint.

---

## 🏗️ Architecture

```
lib/
├── core/
│   ├── interfaces/          # Abstract contracts (IApiService, IKmlBuilder, ILGConnectionService)
│   ├── kml/                 # KmlBuilder — pure KML XML factory, zero side-effects
│   └── models/              # Domain models (WeatherModel)
│
├── services/
│   ├── connection/          # SSH layer (LGConnectionService, LGConnectionState)
│   └── visualization/       # Orchestration (MultiScreenVisualizationService)
│
├── application/
│   └── features/            # Use-case services (DemoFeatureService, WeatherFeatureService)
│
├── data/
│   └── remote/              # HTTP networking (ApiService → Open-Meteo)
│
└── presentation/
    ├── screens/             # HomeScreen, SettingsScreen
    └── widgets/             # ConnectionIndicator
```

**Dependency flow:** `Presentation → Application → Services → Core`  
No layer ever imports upward.

---

## 🚀 Getting Started

### Prerequisites

| Tool | Version |
|------|---------|
| Flutter SDK | ≥ 3.2.0 |
| Dart SDK | ≥ 3.2.0 |
| A running Liquid Galaxy rig | SSH accessible |

### Installation

```bash
git clone <your-repo-url>
cd lg_flutter_starterkit
flutter pub get
flutter run
```

### Connecting to a Liquid Galaxy Rig

1. Open the app and tap the **Settings** icon (top-right).
2. Enter your rig's **Master IP**, **SSH port** (default `22`), **username**, **password**, and **screen count**.
3. Tap **Connect** — the indicator turns green when the SSH session is established.
4. Settings are persisted locally via `shared_preferences` so you only need to enter them once.

> ⚠️ **Security note:** The starter kit stores the SSH password in `SharedPreferences` (plaintext) for convenience. Replace with `flutter_secure_storage` before any production deployment.

---

## 🎮 Features

### Demo Actions (HomeScreen)

| Button | What it does |
|--------|-------------|
| **Send LG Logo** | Injects a `ScreenOverlay` KML with the LG logo onto the rig |
| **Show 3D Pyramid** | Flies camera to Delhi + renders a coloured 3D polygon pyramid |
| **Fly to Home City** | Camera `LookAt` animation to the configured demo coordinates |
| **Show Weather** | Fetches live weather from Open-Meteo and places a KML Placemark |
| **Clear Logo** | Wipes the overlay slot |
| **Clear KML** | Wipes the geospatial KML slot |

### Extending for Your Hackathon Feature

1. **Add a new use-case** — create a class in `application/features/`.
2. **Add new KML geometry** — add a method to `IKmlBuilder` and implement it in `KmlBuilder`.
3. **Add a new API** — extend `IApiService` or create a new interface in `core/interfaces/`.
4. **Wire it up** — instantiate in `main.dart` and inject into `HomeScreen`.

You should rarely need to touch `services/` or `core/` — the architecture keeps your hackathon changes contained to `application/` and `presentation/`.

---

## ⚠️ Known Starter Kit Limitations

| Limitation | Detail |
|-----------|--------|
| **Single KML slot** | Both overlays and geospatial data share `/tmp/query.txt`. Sending one overwrites the other. |
| **No NetworkLinks** | Production rigs should use separate KML files + NetworkLinks for persistence. |
| **Hardcoded city** | `DemoFeatureService` and `WeatherFeatureService` default to Delhi (28.6139°N, 77.2090°E). Change the constants for your demo city. |
| **Plaintext password** | SSH password stored unencrypted — fine for a hackathon, not for production. |

---

## 📦 Dependencies

| Package | Purpose |
|---------|---------|
| [`dartssh2`](https://pub.dev/packages/dartssh2) | SSH client for communicating with the LG master node |
| [`shared_preferences`](https://pub.dev/packages/shared_preferences) | Persistent local storage for connection settings |
| [`http`](https://pub.dev/packages/http) | HTTP client for external API calls (Open-Meteo weather) |
| [`cupertino_icons`](https://pub.dev/packages/cupertino_icons) | iOS-style icons for Flutter |

---

## 🧪 Testing

The architecture is designed for testability. Every service depends on an abstract interface, making it straightforward to inject mocks:

```dart
// Example: testing WeatherFeatureService
final mockApi = MockApiService();
final mockKml = MockKmlBuilder();
final mockViz = MockVisualizationService();

final service = WeatherFeatureService(
  api: mockApi,
  kmlBuilder: mockKml,
  visualization: mockViz,
);
```

Run tests with:

```bash
flutter test
```

---

## 🗺️ Customising Your Demo Location

Both the demo actions and the weather feature default to **Delhi, India**. To change this, update the constants in:

- `lib/application/features/demo_feature_service.dart` → `_demoLatitude`, `_demoLongitude`
- `lib/application/features/weather_feature_service.dart` → `_cityName`, `_latitude`, `_longitude`

---

## 📄 License

This starter kit is provided for hackathon and educational use. See individual package licenses for third-party dependencies.

---

## 🙌 Resources

- [Liquid Galaxy Project](https://www.liquidgalaxy.eu/)
- [Flutter Documentation](https://docs.flutter.dev/)
- [Open-Meteo API](https://open-meteo.com/en/docs)
- [KML Reference (Google)](https://developers.google.com/kml/documentation/kmlreference)
- [dartssh2 on pub.dev](https://pub.dev/packages/dartssh2)