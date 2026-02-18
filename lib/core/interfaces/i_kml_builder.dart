abstract class IKmlBuilder {
  String buildColoredPyramid({
    required double latitude,
    required double longitude,
    required double height,
  });

  String buildScreenOverlay({
    required String imageUrl,
    required double x,
    required double y,
    required double width,
    required double height,
  });

  String buildFlyTo({
    required double latitude,
    required double longitude,
    required double zoom,
    required double tilt,
    required double bearing,
  });

  String buildWeatherPlacemark({
    required String cityName,
    required double latitude,
    required double longitude,
    required double temperatureC,
    required int weatherCode,
    required double windspeedKmh,
  });
}
