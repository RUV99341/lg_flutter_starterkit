import 'package:flutter/material.dart';

import 'services/connection/connection_state.dart';
import 'services/connection/lg_connection_service.dart';
import 'core/kml/kml_builder.dart';
import 'services/visualization/multi_screen_visualization_service.dart';
import 'application/features/demo_feature_service.dart';
import 'application/features/weather_feature_service.dart';
import 'data/remote/api_service.dart';
import 'presentation/screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // ----------------------------
  // Infrastructure Layer
  // ----------------------------
  final connectionState = LGConnectionState();

  final connectionService = LGConnectionService(connectionState);

  final kmlBuilder = KmlBuilder();

  final visualizationService = MultiScreenVisualizationService(
    connection: connectionService,
    state: connectionState,
    kmlBuilder: kmlBuilder,
  );

  // ----------------------------
  // Application Layer
  // ----------------------------
  final demoFeatureService = DemoFeatureService(
    visualization: visualizationService,
  );

  final apiService = ApiService();

  final weatherFeatureService = WeatherFeatureService(
    api: apiService,
    kmlBuilder: kmlBuilder,
    visualization: visualizationService,
  );

  runApp(
    LGStarterKitApp(
      connectionState: connectionState,
      connectionService: connectionService,
      demoFeatureService: demoFeatureService,
      weatherFeatureService: weatherFeatureService,
    ),
  );
}

class LGStarterKitApp extends StatelessWidget {
  final LGConnectionState connectionState;
  final LGConnectionService connectionService;
  final DemoFeatureService demoFeatureService;
  final WeatherFeatureService weatherFeatureService;

  const LGStarterKitApp({
    super.key,
    required this.connectionState,
    required this.connectionService,
    required this.demoFeatureService,
    required this.weatherFeatureService,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LG Flutter Starter Kit',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
      ),
      home: HomeScreen(
        demoService: demoFeatureService,
        connectionService: connectionService,
        connectionState: connectionState,
        weatherService: weatherFeatureService,
      ),
    );
  }
}
