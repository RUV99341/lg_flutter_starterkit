import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/interfaces/i_api_service.dart';
import '../../core/models/weather_model.dart';

/// Domain-safe exception for API errors
class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

/// ApiService
/// ----------
/// Pure networking layer.
/// Responsible ONLY for HTTP communication.
/// 
/// Does NOT:
/// - Build KML
/// - Talk to LG
/// - Manage UI
/// - Store state
///
/// Fully testable via injected http.Client.
class ApiService implements IApiService {
  final http.Client _client;

  static const Duration _timeout = Duration(seconds: 5);

  ApiService({http.Client? client})
      : _client = client ?? http.Client();

  /// ----------------------------------------------------------
  /// Generic GET Request
  /// ----------------------------------------------------------
  Future<Map<String, dynamic>> getJson(String url) async {
    try {
      final response = await _client
          .get(Uri.parse(url))
          .timeout(_timeout);

      if (response.statusCode != 200) {
        throw ApiException(
          'Request failed with status: ${response.statusCode}',
        );
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw ApiException('Unexpected JSON structure.');
      }

      return decoded;
    } on TimeoutException {
      throw ApiException('Request timed out (5s limit reached).');
    } on FormatException {
      throw ApiException('Invalid JSON response.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  Future<WeatherModel> fetchWeather({
    required double latitude,
    required double longitude,
  }) async {
    const baseUrl = 'https://api.open-meteo.com/v1/forecast';
    final url = '$baseUrl?latitude=$latitude&longitude=$longitude'
      '&current=temperature_2m,weathercode,windspeed_10m';

    final json = await getJson(url);

    // Parse safely:
    final current = json['current'] as Map<String, dynamic>?;
    if (current == null) throw ApiException('Missing current weather data.');

    return WeatherModel(
      temperatureC: (current['temperature_2m'] as num).toDouble(),
      weatherCode: current['weathercode'] as int,
      windspeedKmh: (current['windspeed_10m'] as num).toDouble(),
      latitude: latitude,
      longitude: longitude,
    );
  }

  /// ----------------------------------------------------------
  /// Dispose client
  /// ----------------------------------------------------------
  void dispose() {
    _client.close();
  }
}
