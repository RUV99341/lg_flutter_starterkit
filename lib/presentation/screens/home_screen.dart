import 'package:flutter/material.dart';

import '../../application/features/demo_feature_service.dart';
import '../../application/features/weather_feature_service.dart';
import '../../services/connection/lg_connection_service.dart';
import '../../services/connection/connection_state.dart';
import 'setting_screen.dart';
import '../widgets/connection_indicator.dart';

class HomeScreen extends StatefulWidget {
  final DemoFeatureService demoService;
  final WeatherFeatureService weatherService;
  final LGConnectionService connectionService;
  final LGConnectionState connectionState;

  const HomeScreen({
    super.key,
    required this.demoService,
    required this.weatherService,
    required this.connectionService,
    required this.connectionState,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isActionRunning = false;

  Future<void> _runAction(
      BuildContext context, Future<void> Function() action) async {
    if (_isActionRunning) return;

    setState(() => _isActionRunning = true);

    try {
      await action();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => _isActionRunning = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.connectionState,
      builder: (context, _) {
        final isConnected = widget.connectionState.isConnected;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Liquid Galaxy Demo'),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SettingsScreen(
                        connectionService: widget.connectionService,
                        connectionState: widget.connectionState,
                      ),
                    ),
                  );
                },
              )
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                ConnectionIndicator(isConnected: isConnected),
                const SizedBox(height: 30),

                _buildActionButton(
                  context,
                  label: 'Send LG Logo',
                  icon: Icons.image,
                  color: Colors.blue,
                  onPressed: () => _runAction(
                    context,
                    () => widget.demoService.showLogo(
                      'https://liquidgalaxy.eu/wp-content/uploads/2020/04/LG-logo.png',
                    ),
                  ),
                ),

                _buildActionButton(
                  context,
                  label: 'Show 3D Pyramid',
                  icon: Icons.change_history,
                  color: Colors.deepPurple,
                  onPressed: () =>
                      _runAction(context, widget.demoService.showPyramid),
                ),

                _buildActionButton(
                  context,
                  label: 'Fly to Home City',
                  icon: Icons.flight_takeoff,
                  color: Colors.orange,
                  onPressed: () =>
                      _runAction(context, widget.demoService.flyToHomeCity),
                ),

                // --------------------------------------------------
                // WEATHER (External API Feature)
                // --------------------------------------------------
                _buildActionButton(
                  context,
                  label: 'Show Weather',
                  icon: Icons.wb_sunny_outlined,
                  color: Colors.teal,
                  onPressed: () =>
                      _runAction(context, widget.weatherService.showWeather),
                ),

                const Divider(height: 40),

                _buildActionButton(
                  context,
                  label: 'Clear Logo',
                  icon: Icons.layers_clear,
                  color: Colors.redAccent,
                  onPressed: () =>
                      _runAction(context, widget.demoService.clearLogo),
                ),

                _buildActionButton(
                  context,
                  label: 'Clear KML',
                  icon: Icons.delete,
                  color: Colors.red,
                  onPressed: () =>
                      _runAction(context, widget.demoService.clearKml),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 16),
          minimumSize: const Size.fromHeight(55),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: _isActionRunning
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(icon),
        label: Text(
          label,
          style: const TextStyle(fontSize: 16),
        ),
        onPressed: _isActionRunning ? null : onPressed,
      ),
    );
  }
}