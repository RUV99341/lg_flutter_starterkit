import '../../core/interfaces/i_api_service.dart';
import '../../core/interfaces/i_kml_builder.dart';
import '../../core/models/weather_model.dart';
import '../../services/visualization/multi_screen_visualization_service.dart';

class WeatherFeatureService {
  final IApiService _api;
  final IKmlBuilder _kmlBuilder;
  final MultiScreenVisualizationService _visualization;

  static const String _cityName  = 'Delhi';
  static const double _latitude  = 28.6139;
  static const double _longitude = 77.2090;

  WeatherFeatureService({
    required IApiService api,
    required IKmlBuilder kmlBuilder,
    required MultiScreenVisualizationService visualization,
  })  : _api = api,
        _kmlBuilder = kmlBuilder,
        _visualization = visualization;

  Future<void> showWeather() async {
    final WeatherModel weather = await _api.fetchWeather(
      latitude: _latitude,
      longitude: _longitude,
    );

    final kml = _kmlBuilder.buildWeatherPlacemark(
      cityName: _cityName,
      latitude: weather.latitude,
      longitude: weather.longitude,
      temperatureC: weather.temperatureC,
      weatherCode: weather.weatherCode,
      windspeedKmh: weather.windspeedKmh,
    );

    await _visualization.sendKml(kml);

    // Then move the camera to the location
    await _visualization.flyTo(
      latitude: _latitude,
      longitude: _longitude,
      range: 5000, // Adjusted range for better visibility of the placemark
      tilt: 0,
      bearing: 0,
    );
  }
}