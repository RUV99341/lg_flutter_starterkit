abstract class ILGConnectionService {
  bool get isConnected;

  Future<void> connect({
    required String host,
    required int port,
    required String username,
    required String password,
    required int screenCount,
  });

  Future<void> disconnect();

  Future<void> execute(String command);

  /// Clears all geospatial KML content from the rig.
  Future<void> clearKML();

  /// Sends a full KML document as a geospatial layer (Placemarks, Polygons).
  Future<void> sendKML(String kml);

  /// Sends a full KML document as a screen-space overlay (logos, HUD).
  Future<void> sendOverlay(String kml);

  /// Commands the LG camera. [lookAtXml] is a raw <LookAt>...</LookAt> string.
  Future<void> flyToView(String lookAtXml);

  /// Blanks the overlay slave screen.
  Future<void> clearOverlay();
}