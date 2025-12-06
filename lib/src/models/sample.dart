class WaterQualitySample {
  final String id;
  final String pondId;
  final DateTime timestamp;
  final double? ph;
  final double? temperature;
  final double? tds;
  final double? turbidity;
  final double? wqScore;
  final String status; // 'good', 'warning', 'critical'

  const WaterQualitySample({
    required this.id,
    required this.pondId,
    required this.timestamp,
    this.ph,
    this.temperature,
    this.tds,
    this.turbidity,
    this.wqScore,
    required this.status,
  });
}

class Pond {
  final String id;
  final String name;
  final String status;
  final DateTime? lastSeen;
  final WaterQualitySample? latestSample;

  const Pond({
    required this.id,
    required this.name,
    required this.status,
    this.lastSeen,
    this.latestSample,
  });
}

class Alert {
  final String id;
  final String title;
  final String description;
  final String severity; // 'info', 'warning', 'critical'
  final DateTime timestamp;
  final bool isRead;

  const Alert({
    required this.id,
    required this.title,
    required this.description,
    required this.severity,
    required this.timestamp,
    this.isRead = false,
  });
}

class DeviceInfo {
  final String id;
  final String name;
  final double batteryLevel;
  final String firmwareVersion;
  final DateTime? lastSync;
  final bool isConnected;

  const DeviceInfo({
    required this.id,
    required this.name,
    required this.batteryLevel,
    required this.firmwareVersion,
    this.lastSync,
    this.isConnected = false,
  });
}

class WeatherInfo {
  final double temperature;
  final String condition;
  final List<WeatherForecast> forecast;

  const WeatherInfo({
    required this.temperature,
    required this.condition,
    required this.forecast,
  });
}

class WeatherForecast {
  final DateTime date;
  final double temperature;
  final String condition;

  const WeatherForecast({
    required this.date,
    required this.temperature,
    required this.condition,
  });
}
