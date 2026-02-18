import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/connection/lg_connection_service.dart';
import '../../services/connection/connection_state.dart';
import '../widgets/connection_indicator.dart';

class SettingsScreen extends StatefulWidget {
  final LGConnectionService connectionService;
  final LGConnectionState connectionState;

  const SettingsScreen({
    super.key,
    required this.connectionService,
    required this.connectionState,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _ipController = TextEditingController();
  final _portController = TextEditingController(text: '22');
  final _userController = TextEditingController();
  final _passwordController = TextEditingController();
  final _rigsController = TextEditingController(text: '3');

  SharedPreferences? _prefs;

  bool _isConnecting = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();

    setState(() {
      _ipController.text = _prefs?.getString('ip') ?? '';
      _portController.text = _prefs?.getString('port') ?? '22';
      _userController.text = _prefs?.getString('username') ?? '';
      _passwordController.text = _prefs?.getString('password') ?? '';
      _rigsController.text = _prefs?.getString('screens') ?? '3';
    });
  }

  Future<void> _connect() async {

    final ip = _ipController.text.trim();
    final portText = _portController.text.trim();
    final screensText = _rigsController.text.trim();

    final port = int.tryParse(portText);
    final screens = int.tryParse(screensText);

    if (ip.isEmpty) {
        _showError('IP Address is required.');
        return;
    }

    if (port == null || port <= 0 || port > 65535) {
        _showError('Enter a valid port number (1–65535).');
        return;
    }

    if (_userController.text.trim().isEmpty) {
        _showError('Username is required.');
        return;
    }

    if (screens == null || screens < 1) {
        _showError('Screen count must be at least 1.');
        return;
    }

    setState(() => _isConnecting = true);

    try {
        await widget.connectionService.connect(
        host: ip,
        port: port,
        username: _userController.text.trim(),
        password: _passwordController.text,
        screenCount: screens,
        );

        await _saveSettings();
    } catch (e) {
        _showError('Connection Failed: ${e.toString()}');
    } finally {
        if (mounted) {
        setState(() => _isConnecting = false);
        }
    }
    }


  Future<void> _disconnect() async {
    await widget.connectionService.disconnect();
    setState(() {});
  }

  Future<void> _saveSettings() async {
    await _prefs?.setString('ip', _ipController.text.trim());
    await _prefs?.setString('port', _portController.text.trim());
    await _prefs?.setString('username', _userController.text.trim());
    // ⚠️ SECURITY NOTE (Starter Kit):
    // Password is stored in SharedPreferences (plaintext).
    // For production apps, use flutter_secure_storage instead.
    await _prefs?.setString('password', _passwordController.text);
    await _prefs?.setString('screens', _rigsController.text.trim());
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    bool isPassword = false,
    bool isNumber = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ipController.dispose();
    _portController.dispose();
    _userController.dispose();
    _passwordController.dispose();
    _rigsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isConnected = widget.connectionState.isConnected;

    return Scaffold(
      appBar: AppBar(title: const Text('Liquid Galaxy Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _buildField('Master IP Address', _ipController),
            _buildField('SSH Port', _portController, isNumber: true),
            _buildField('Username', _userController),
            _buildField('Password', _passwordController, isPassword: true),
            _buildField('Number of Screens', _rigsController, isNumber: true),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _isConnecting
                  ? null
                  : (isConnected ? _disconnect : _connect),
              child: _isConnecting
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(isConnected ? 'Disconnect' : 'Connect'),
            ),

            const SizedBox(height: 24),

            ConnectionIndicator(
              isConnected: isConnected,
              fontWeight: FontWeight.w500,
            ),
          ],
        ),
      ),
    );
  }
}
