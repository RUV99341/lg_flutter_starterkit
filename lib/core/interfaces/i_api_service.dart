import '../../core/models/weather_model.dart';

abstract class IApiService {
  Future<Map<String, dynamic>> getJson(String url);

  Future<WeatherModel> fetchWeather({
    required double latitude,
    required double longitude,
  });

  void dispose();
}