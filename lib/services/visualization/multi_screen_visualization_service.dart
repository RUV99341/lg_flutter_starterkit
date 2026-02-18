import '../connection/connection_state.dart';
import '../../core/interfaces/i_lg_connection_service.dart';
import '../../core/interfaces/i_kml_builder.dart';

/// Domain-specific exception
class RigNotConnectedException implements Exception {
  final String message;
  RigNotConnectedException([this.message = 'Liquid Galaxy is not connected.']);

  @override
  String toString() => message;
}

/// MultiScreenVisualizationService
/// ─────────────────────────────────
/// Orchestrates all visual output on the Liquid Galaxy rig.
///
/// LG COMMAND PROTOCOL (how this service maps to the rig):
/// ┌─────────────────┬──────────────────────────────────────────────────┐
/// │ Action          │ LG Mechanism                                     │
/// ├─────────────────┼──────────────────────────────────────────────────┤
/// │ Camera flyto    │ echo 'flytoview=<LookAt/>' > /tmp/query.txt      │
/// │ Geospatial KML  │ Write to /var/www/html/kml/query.kml             │
/// │                 │ Register URL in /var/www/html/kmls.txt           │
/// │ Screen overlay  │ Write to /var/www/html/kml/slave_X.kml           │
/// │                 │ echo 'refresh' > /tmp/query.txt                  │
/// │ Clear all       │ echo 'exittour=true' > /tmp/query.txt            │
/// │                 │ Empty /var/www/html/kmls.txt                     │
/// └─────────────────┴──────────────────────────────────────────────────┘
class MultiScreenVisualizationService {
  final LGConnectionState _state;
  final ILGConnectionService _connection;
  final IKmlBuilder _kmlBuilder;

  MultiScreenVisualizationService({
    required ILGConnectionService connection,
    required LGConnectionState state,
    required IKmlBuilder kmlBuilder,
  })  : _connection = connection,
        _state = state,
        _kmlBuilder = kmlBuilder;

  // ───────────────────────────────────────────
  // SHOW LOGO  (screen-space overlay)
  // ───────────────────────────────────────────
  /// Sends a ScreenOverlay KML to the leftmost slave screen.
  /// Uses sendOverlay() which writes to slave_X.kml and triggers
  /// a refresh — the only correct way to display persistent overlays on LG.
  Future<void> showLogo(String imageUrl) async {
    _ensureConnected();

    final kml = _kmlBuilder.buildScreenOverlay(
      imageUrl: imageUrl,
      x: 0.02,
      y: 0.95,
      width: 0.3,
      height: 0.3,
    );

    await _connection.sendOverlay(kml);
  }

  // ───────────────────────────────────────────
  // SHOW PYRAMID  (geospatial + camera)
  // ───────────────────────────────────────────
  /// Sends a 3D pyramid KML and moves the camera to its location.
  ///
  /// Protocol:
  ///   1. clearKML() — stop existing content (LG-020)
  ///   2. sendKML()  — write KML file + register in kmls.txt
  ///   3. flyToView() — move camera via flytoview= directive
  ///
  /// Camera is sent AFTER KML registration so GE loads the geometry
  /// before the camera arrives, preventing a blank-then-appear flicker.
  Future<void> showPyramid({
    required double latitude,
    required double longitude,
    required double height,
    double range = 500,
    double tilt = 60,
    double bearing = 0,
  }) async {
    _ensureConnected();

    final kml = _kmlBuilder.buildColoredPyramid(
      latitude: latitude,
      longitude: longitude,
      height: height,
    );

    final lookAt = _kmlBuilder.buildFlyTo(
      latitude: latitude,
      longitude: longitude,
      zoom: range,
      tilt: tilt,
      bearing: bearing,
    );

    await _connection.clearKML();       // LG-020: clear before inject
    await _connection.sendKML(kml);     // register geometry
    await _connection.flyToView(lookAt); // move camera
  }

  // ───────────────────────────────────────────
  // FLY TO LOCATION  (camera only)
  // ───────────────────────────────────────────
  Future<void> flyTo({
    required double latitude,
    required double longitude,
    double range = 12000,
    double tilt = 45,
    double bearing = 0,
  }) async {
    _ensureConnected();

    final lookAt = _kmlBuilder.buildFlyTo(
      latitude: latitude,
      longitude: longitude,
      zoom: range,
      tilt: tilt,
      bearing: bearing,
    );

    await _connection.flyToView(lookAt);
  }

  // ───────────────────────────────────────────
  // SHOW WEATHER DATA  (geospatial + camera)
  // ───────────────────────────────────────────
  /// The weather KML from KmlBuilder already embeds its own LookAt
  /// coordinates, so we split: first register the KML content,
  /// then send the camera instruction separately.
  Future<void> showWeatherData(String kml) async {
    _ensureConnected();
    await _connection.clearKML();
    await _connection.sendKML(kml);
  }

  // ───────────────────────────────────────────
  // CLEAR GEOSPATIAL KML
  // ───────────────────────────────────────────
  Future<void> clearKml() async {
    _ensureConnected();
    await _connection.clearKML();
  }

  // ───────────────────────────────────────────
  // CLEAR OVERLAY
  // ───────────────────────────────────────────
  Future<void> clearOverlay() async {
    _ensureConnected();
    await _connection.clearOverlay();
  }

  // ───────────────────────────────────────────
  // INTERNAL GUARD
  // ───────────────────────────────────────────
  void _ensureConnected() {
    if (!_state.isConnected) {
      throw RigNotConnectedException();
    }
  }
}