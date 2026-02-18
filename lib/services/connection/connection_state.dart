import 'package:flutter/foundation.dart';

class LGConnectionState extends ChangeNotifier {
  String? _host;
  int? _port;
  String? _username;
  int? _screenCount;
  bool _isConnected = false;

  String? get host => _host;
  int? get port => _port;
  String? get username => _username;
  int? get screenCount => _screenCount;
  bool get isConnected => _isConnected;

  void updateConnection({
    required String host,
    required int port,
    required String username,
    required int screenCount,
    required bool connected,
  }) {
    _host = host;
    _port = port;
    _username = username;
    _screenCount = screenCount;
    _isConnected = connected;

    notifyListeners(); 
  }

  void markDisconnected() {
    _isConnected = false;
    notifyListeners(); 
  }

  void clear() {
    _host = null;
    _port = null;
    _username = null;
    _screenCount = null;
    _isConnected = false;

    notifyListeners();
  }
}
