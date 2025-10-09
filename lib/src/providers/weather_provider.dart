import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

final weatherProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final apiKey = const String.fromEnvironment("OPENWEATHER_API_KEY");

  // === 1. Minta izin lokasi ===
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw Exception('Layanan lokasi tidak aktif.');
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      throw Exception('Izin lokasi ditolak.');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    throw Exception('Izin lokasi ditolak permanen.');
  }

  // === 2. Ambil koordinat pengguna ===
  final position = await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );
  final lat = position.latitude;
  final lon = position.longitude;

  // === 3. Panggil OpenWeatherMap API ===
  final currentWeatherUrl = Uri.parse(
    'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric&lang=id',
  );

  final forecastUrl = Uri.parse(
    'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric&lang=id&cnt=40',
  );

  final dailyForecastUrl = Uri.parse(
    'https://api.openweathermap.org/data/2.5/forecast/daily?lat=$lat&lon=$lon&appid=$apiKey&units=metric&lang=id&cnt=7',
  );

  // Get current weather
  final currentResponse = await http.get(currentWeatherUrl);
  if (currentResponse.statusCode != 200) {
    throw Exception(
      'Gagal mengambil data cuaca saat ini: ${currentResponse.statusCode}',
    );
  }

  // Get 5-day/3-hour forecast
  final forecastResponse = await http.get(forecastUrl);
  if (forecastResponse.statusCode != 200) {
    throw Exception(
      'Gagal mengambil data ramalan cuaca per 3 jam: ${forecastResponse.statusCode}',
    );
  }

  // Get daily forecast (requires paid plan)
  http.Response? dailyResponse;
  try {
    dailyResponse = await http.get(dailyForecastUrl);
  } catch (e) {
    // Daily forecast might not be available in free plan
    dailyResponse = null;
  }

  final currentWeather = json.decode(currentResponse.body);
  final forecast = json.decode(forecastResponse.body);
  final dailyForecast = dailyResponse != null && dailyResponse.statusCode == 200
      ? json.decode(dailyResponse.body)
      : null;

  // Combine all weather data
  return {
    'current': currentWeather,
    'forecast': forecast,
    'daily': dailyForecast,
  };
});

// Helper provider to get formatted weather data
final formattedWeatherProvider = Provider<Map<String, dynamic>?>((ref) {
  final weatherData = ref.watch(weatherProvider);

  return weatherData.when(
    data: (data) {
      final current = data['current'] as Map<String, dynamic>;
      final forecast = data['forecast'] as Map<String, dynamic>;
      final daily = data['daily'] as Map<String, dynamic>?;

      // Extract current weather data according to API documentation
      final currentFormatted = {
        'temperature': current['main']['temp'].round(),
        'feels_like': current['main']['feels_like'].round(),
        'temp_min': current['main']['temp_min'].round(),
        'temp_max': current['main']['temp_max'].round(),
        'humidity': current['main']['humidity'],
        'pressure': current['main']['pressure'],
        'sea_level':
            current['main']['sea_level'] ?? current['main']['pressure'],
        'grnd_level':
            current['main']['grnd_level'] ?? current['main']['pressure'],
        'description': current['weather'][0]['description'],
        'main': current['weather'][0]['main'],
        'icon': current['weather'][0]['icon'],
        'weather_id': current['weather'][0]['id'],
        'wind_speed': current['wind']?['speed'] ?? 0.0,
        'wind_direction': current['wind']?['deg'] ?? 0,
        'wind_gust': current['wind']?['gust'],
        'visibility':
            (current['visibility'] ?? 10000) / 1000.0, // Convert to km
        'cloudiness': current['clouds']?['all'] ?? 0,
        'sunrise': DateTime.fromMillisecondsSinceEpoch(
          (current['sys']['sunrise'] ?? 0) * 1000,
        ),
        'sunset': DateTime.fromMillisecondsSinceEpoch(
          (current['sys']['sunset'] ?? 0) * 1000,
        ),
        'timezone': current['timezone'] ?? 0,
        'rain_1h': current['rain']?['1h'],
        'snow_1h': current['snow']?['1h'],
      };

      // Extract 3-hourly forecast data
      final hourlyForecast = (forecast['list'] as List)
          .map(
            (item) => {
              'datetime': DateTime.fromMillisecondsSinceEpoch(
                item['dt'] * 1000,
              ),
              'temperature': item['main']['temp'].round(),
              'feels_like': item['main']['feels_like'].round(),
              'temp_min': item['main']['temp_min'].round(),
              'temp_max': item['main']['temp_max'].round(),
              'description': item['weather'][0]['description'],
              'main': item['weather'][0]['main'],
              'icon': item['weather'][0]['icon'],
              'weather_id': item['weather'][0]['id'],
              'humidity': item['main']['humidity'],
              'pressure': item['main']['pressure'],
              'wind_speed': item['wind']?['speed'] ?? 0.0,
              'wind_direction': item['wind']?['deg'] ?? 0,
              'wind_gust': item['wind']?['gust'],
              'cloudiness': item['clouds']?['all'] ?? 0,
              'pop': item['pop'] ?? 0.0, // Probability of precipitation
              'rain_3h': item['rain']?['3h'],
              'snow_3h': item['snow']?['3h'],
            },
          )
          .toList();

      // Extract daily forecast data if available (paid plan)
      List<Map<String, dynamic>>? dailyForecast;
      if (daily != null && daily['list'] != null) {
        dailyForecast = (daily['list'] as List)
            .map(
              (item) => {
                'date': DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000),
                'sunrise': DateTime.fromMillisecondsSinceEpoch(
                  item['sunrise'] * 1000,
                ),
                'sunset': DateTime.fromMillisecondsSinceEpoch(
                  item['sunset'] * 1000,
                ),
                'temp_day': item['temp']['day'].round(),
                'temp_night': item['temp']['night'].round(),
                'temp_eve': item['temp']['eve'].round(),
                'temp_morn': item['temp']['morn'].round(),
                'temp_min': item['temp']['min'].round(),
                'temp_max': item['temp']['max'].round(),
                'feels_like_day': item['feels_like']['day'].round(),
                'feels_like_night': item['feels_like']['night'].round(),
                'feels_like_eve': item['feels_like']['eve'].round(),
                'feels_like_morn': item['feels_like']['morn'].round(),
                'pressure': item['pressure'],
                'humidity': item['humidity'],
                'description': item['weather'][0]['description'],
                'main': item['weather'][0]['main'],
                'icon': item['weather'][0]['icon'],
                'weather_id': item['weather'][0]['id'],
                'wind_speed': item['speed'] ?? 0.0,
                'wind_direction': item['deg'] ?? 0,
                'wind_gust': item['gust'],
                'cloudiness': item['clouds'] ?? 0,
                'pop': item['pop'] ?? 0.0, // Probability of precipitation
                'rain': item['rain'],
                'snow': item['snow'],
              },
            )
            .toList();
      }

      return {
        'location': {
          'name': current['name'],
          'country': current['sys']['country'],
          'latitude': current['coord']['lat'],
          'longitude': current['coord']['lon'],
          'timezone': current['timezone'] ?? 0,
        },
        'current': currentFormatted,
        'hourly_forecast': hourlyForecast,
        'daily_forecast': dailyForecast,
        'last_updated': DateTime.now(),
      };
    },
    loading: () => null,
    error: (error, stack) => null,
  );
});
