import 'dart:async';
import 'package:dartssh2/dartssh2.dart';

import 'connection_state.dart';
import '../../core/interfaces/i_lg_connection_service.dart';

/// LGConnectionService
/// -------------------
/// Single SSH authority for all Liquid Galaxy rig communication.
///
/// ╔══════════════════════════════════════════════════════════════╗
/// ║  HOW LIQUID GALAXY ACTUALLY WORKS (critical knowledge)      ║
/// ╠══════════════════════════════════════════════════════════════╣
/// ║  /tmp/query.txt  →  COMMAND file. Accepts text directives:  ║
/// ║    search=<place>          → fly to named location          ║
/// ║    flytoview=<LookAt xml>  → move camera to coordinates     ║
/// ║    exittour=true           → stop any running tour          ║
/// ║    refresh                 → force NetworkLink reload       ║
/// ║                                                             ║
/// ║  KML CONTENT never goes into /tmp/query.txt directly.       ║
/// ║                                                             ║
/// ║  Geospatial KML  → /var/www/html/kmls.txt  (URL registry)   ║
/// ║                    GE polls this file and loads listed URLs  ║
/// ║                                                             ║
/// ║  Overlay KML     → /var/www/html/kml/slave_X.kml           ║
/// ║                    X = leftmost screen index                ║
/// ║                    Then send 'refresh' to /tmp/query.txt    ║
/// ╚══════════════════════════════════════════════════════════════╝
class LGConnectionService implements ILGConnectionService {
  LGConnectionService(this._state);

  final LGConnectionState _state;
  SSHClient? _client;

  static const Duration _timeout = Duration(seconds: 10);

  bool get isConnected => _state.isConnected;

  // ─────────────────────────────────────────
  // CONNECT
  // ─────────────────────────────────────────
  @override
  Future<void> connect({
    required String host,
    required int port,
    required String username,
    required String password,
    required int screenCount,
  }) async {
    if (_state.isConnected) return;

    final socket = await SSHSocket.connect(host, port).timeout(_timeout);

    _client = SSHClient(
      socket,
      username: username,
      onPasswordRequest: () => password,
    );

    _state.updateConnection(
      host: host,
      port: port,
      username: username,
      screenCount: screenCount,
      connected: true,
    );
  }

  // ─────────────────────────────────────────
  // DISCONNECT
  // ─────────────────────────────────────────
  @override
  Future<void> disconnect() async {
    if (_client == null) return;
    _client!.close();
    _client = null;
    _state.markDisconnected();
  }

  // ─────────────────────────────────────────
  // EXECUTE RAW COMMAND
  // ─────────────────────────────────────────
  /// Executes a single shell command on the LG master node.
  /// dartssh2 client.execute() works directly for simple commands
  /// (echo, cat, redirection). No bash wrapper needed.
  @override
  Future<void> execute(String command) async {
    _ensureConnected();
    final session = await _client!.execute(command).timeout(_timeout);
    await session.done.timeout(_timeout);
  }

  // ─────────────────────────────────────────
  // CLEAR KML
  // ─────────────────────────────────────────
  /// Stops any running tour, clears the KML URL registry, and resets
  /// the geospatial content on all screens.
  @override
  Future<void> clearKML() async {
    _ensureConnected();
    // 1. Tell GE to exit any active tour/content
    await execute("echo 'exittour=true' > /tmp/query.txt");
    // 2. Empty the KML URL registry so GE stops loading registered files
    await execute('> /var/www/html/kmls.txt');
  }

  // ─────────────────────────────────────────
  // SEND KML  (geospatial: Placemarks, Polygons)
  // ─────────────────────────────────────────
  /// Writes a KML document to the web server, registers its URL in
  /// kmls.txt so Google Earth polls and loads it, then moves the camera.
  ///
  /// Protocol (from working reference):
  ///   1. Write KML file to /var/www/html/<name>.kml via heredoc
  ///   2. Register URL in /var/www/html/kmls.txt
  ///   3. Camera handled separately via flyToView()
  @override
  Future<void> sendKML(String kml) async {
    _ensureConnected();
    const remotePath = '/var/www/html/kml/query.kml';
    const kmlUrl = 'http://localhost:81/kml/query.kml';

    // Write KML using heredoc — this is the proven pattern from reference code.
    // heredoc does NOT require base64 or pipes; it handles multiline content safely.
    await execute("cat << 'KMLEOF' > $remotePath\n$kml\nKMLEOF");

    // Register the file URL so GE's NetworkLink picks it up
    await execute("echo '$kmlUrl' > /var/www/html/kmls.txt");
  }

  // ─────────────────────────────────────────
  // SEND LOGO / OVERLAY  (screen-space KML)
  // ─────────────────────────────────────────
  /// Writes overlay KML to the designated slave screen's KML file.
  /// Overlays live on the leftmost screen (slave_X.kml).
  /// After writing, sends 'refresh' so GE reloads the NetworkLink.
  Future<void> sendOverlay(String kml) async {
    _ensureConnected();
    final int screenCount = _state.screenCount ?? 3;
    final int leftMost = screenCount == 1 ? 1 : (screenCount / 2).floor() + 2;
    final String remotePath = '/var/www/html/kml/slave_$leftMost.kml';

    await execute("cat << 'KMLEOF' > $remotePath\n$kml\nKMLEOF");
    await execute("echo 'refresh' > /tmp/query.txt");
  }

  // ─────────────────────────────────────────
  // FLY TO VIEW  (camera command)
  // ─────────────────────────────────────────
  /// Sends a flytoview directive to /tmp/query.txt.
  /// [lookAtXml] must be a raw <LookAt>...</LookAt> XML string
  /// (NOT a full KML document — just the inner element).
  Future<void> flyToView(String lookAtXml) async {
    _ensureConnected();
    await execute("echo 'flytoview=$lookAtXml' > /tmp/query.txt");
  }

  // ─────────────────────────────────────────
  // CLEAR OVERLAY  (blank the slave screen)
  // ─────────────────────────────────────────
  Future<void> clearOverlay() async {
    _ensureConnected();
    final int screenCount = _state.screenCount ?? 3;
    final int leftMost = screenCount == 1 ? 1 : (screenCount / 2).floor() + 2;
    final String remotePath = '/var/www/html/kml/slave_$leftMost.kml';

    const blankKml = '''<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">
  <Document></Document>
</kml>''';

    await execute("cat << 'KMLEOF' > $remotePath\nKMLEOF");
    // Rewrite a blank valid KML so GE renders nothing (not an error)
    await execute("cat << 'KMLEOF' > $remotePath\n$blankKml\nKMLEOF");
    await execute("echo 'refresh' > /tmp/query.txt");
  }

  // ─────────────────────────────────────────
  // PRIVATE
  // ─────────────────────────────────────────
  void _ensureConnected() {
    if (_client == null || !_state.isConnected) {
      throw Exception('Liquid Galaxy is not connected.');
    }
  }
}