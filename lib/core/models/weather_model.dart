class WeatherModel {
  final double latitude;
  final double longitude;
  final double temperatureC;
  final int weatherCode;
  final double windspeedKmh;

  const WeatherModel({
    required this.latitude,
    required this.longitude,
    required this.temperatureC,
    required this.weatherCode,
    required this.windspeedKmh,
  });
}