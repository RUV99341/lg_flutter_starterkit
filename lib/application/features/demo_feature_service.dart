import '../../services/visualization/multi_screen_visualization_service.dart';

/// DemoFeatureService
/// ------------------
/// Application-level use case coordinator for demo actions.
/// UI-agnostic. Delegates all LG communication to the visualization service.
class DemoFeatureService {
  final MultiScreenVisualizationService _visualization;

  // Demo coordinates — Delhi, India
  static const double _demoLatitude  = 28.6139;
  static const double _demoLongitude = 77.2090;
  static const double _demoHeight    = 100;   // metres above ground
  static const double _demoRange     = 500;   // camera distance in metres
  static const double _demoTilt      = 60;    // camera tilt angle

  DemoFeatureService({
    required MultiScreenVisualizationService visualization,
  }) : _visualization = visualization;

  // ─────────────────────────────────
  // SHOW LG LOGO
  // ─────────────────────────────────
  Future<void> showLogo(String imageUrl) async {
    await _visualization.showLogo(imageUrl);
  }

  // ─────────────────────────────────
  // SHOW 3D PYRAMID
  // ─────────────────────────────────
  Future<void> showPyramid() async {
    await _visualization.showPyramid(
      latitude:  _demoLatitude,
      longitude: _demoLongitude,
      height:    _demoHeight,
      range:     _demoRange,
      tilt:      _demoTilt,
      bearing:   0,
    );
  }

  // ─────────────────────────────────
  // FLY TO HOME CITY
  // ─────────────────────────────────
  Future<void> flyToHomeCity() async {
    await _visualization.flyTo(
      latitude:  _demoLatitude,
      longitude: _demoLongitude,
      range:     12000,
      tilt:      45,
      bearing:   0,
    );
  }

  // ─────────────────────────────────
  // CLEAR LOGO (overlay)
  // ─────────────────────────────────
  Future<void> clearLogo() async {
    await _visualization.clearOverlay();
  }

  // ─────────────────────────────────
  // CLEAR KML (geospatial)
  // ─────────────────────────────────
  Future<void> clearKml() async {
    await _visualization.clearKml();
  }
}