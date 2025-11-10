import 'package:cloud_firestore/cloud_firestore.dart'; // <- perlu supaya Timestamp dikenali

import 'package:http/http.dart' as http;
import 'dart:convert';

class WaterQualitySample {
  final double turbidity;
  final double tds;
  final double temperature;
  final double ph;
  final int timestamp;

  WaterQualitySample({
    required this.turbidity,
    required this.tds,
    required this.temperature,
    required this.ph,
    required this.timestamp,
  });

  factory WaterQualitySample.fromFirestore(Map<String, dynamic> data) {
    return WaterQualitySample(
      turbidity: (data['turbidity'] ?? 0).toDouble(),
      tds: (data['tds'] ?? 0).toDouble(),
      temperature: (data['temperature'] ?? 0).toDouble(),
      ph: (data['ph'] ?? 0).toDouble(),
      timestamp: (data['timestamp'] ?? 0).toInt(),
    );
  }
}

/// Fungsi ambil daftar subcollection dari Firebase Admin Server
Future<void> getCollections(String deviceId) async {
  try {
    // Ganti localhost dengan IP lokal PC kamu kalau pakai emulator Android
    final response = await http.get(
      Uri.parse('http://localhost:3000/collections/$deviceId'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('📁 Subcollections dari $deviceId: ${data['subcollections']}');
    } else {
      print('❌ Error HTTP ${response.statusCode}');
    }
  } catch (e) {
    print('⚠️ Gagal ambil subcollections: $e');
  }
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
