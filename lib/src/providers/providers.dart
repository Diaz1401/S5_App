import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'chart_dummy_data.dart';
import '../models/chart_time_range.dart'; // tambahkan ini
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/sample.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// TODO: Implement state management with Riverpod

// Theme mode provider
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

// Pond providers
final pondsProvider = StateNotifierProvider<PondsNotifier, List<Pond>>((ref) {
  return PondsNotifier();
});

class PondsNotifier extends StateNotifier<List<Pond>> {
  PondsNotifier() : super([]);

  // TODO: Load ponds from local storage or API
  void loadPonds() {}

  // TODO: Add new pond
  void addPond(Pond pond) {}

  // TODO: Update pond status
  void updatePondStatus(String pondId, String status) {}
}

// Current pond provider
final currentPondProvider = StateProvider<String?>((ref) => null);

// Water quality samples provider
final samplesProvider =
    StateNotifierProvider.family<
      SamplesNotifier,
      List<WaterQualitySample>,
      String
    >((ref, pondId) {
      return SamplesNotifier(pondId);
    });

class SamplesNotifier extends StateNotifier<List<WaterQualitySample>> {
  final String pondId;

  SamplesNotifier(this.pondId) : super([]);

  // TODO: Load samples from local storage or API
  void loadSamples() {}

  // TODO: Add new sample
  void addSample(WaterQualitySample sample) {}
}

// Alerts provider
final alertsProvider = StateNotifierProvider<AlertsNotifier, List<Alert>>((
  ref,
) {
  return AlertsNotifier();
});

class AlertsNotifier extends StateNotifier<List<Alert>> {
  AlertsNotifier() : super([]);

  // TODO: Load alerts from local storage
  void loadAlerts() {}

  // TODO: Mark alert as read
  void markAsRead(String alertId) {}

  // TODO: Add new alert
  void addAlert(Alert alert) {}
}

// Device info provider
final deviceInfoProvider =
    StateNotifierProvider<DeviceInfoNotifier, DeviceInfo?>((ref) {
      return DeviceInfoNotifier();
    });

class DeviceInfoNotifier extends StateNotifier<DeviceInfo?> {
  DeviceInfoNotifier() : super(null);

  // TODO: Load device information from BLE or local storage
  void loadDeviceInfo() {}

  // TODO: Update device status
  void updateDeviceStatus(bool isConnected) {}
}

final firestoreSensorProvider =
    FutureProvider.family<WaterQualitySample?, String>((ref, deviceId) async {
      try {
        // 1️⃣ Ambil daftar subcollection dari server Node.js (Firebase Admin)
        final response = await http.get(
          Uri.parse('http://192.168.1.9:3000/collections/$deviceId'),
        ); // Ganti IP sesuai komputer kamu

        if (response.statusCode != 200) {
          throw Exception('HTTP Error: ${response.statusCode}');
        }

        final data = jsonDecode(response.body);
        final List subcollections = data['subcollections'] ?? [];

        if (subcollections.isEmpty) {
          debugPrint('⚠️ Tidak ada subcollection ditemukan untuk $deviceId');
          return null;
        }

        // 2️⃣ Ambil subcollection terakhir (biasanya terbaru)
        final subcollectionName = subcollections.last;
        debugPrint('📁 Subcollection aktif: $subcollectionName');

        // 3️⃣ Ambil data dari Firestore
        final collectionRef = FirebaseFirestore.instance
            .collection('riwayat')
            .doc(deviceId)
            .collection(subcollectionName);

        debugPrint(
          '📥 Fetching data from: riwayat/$deviceId/$subcollectionName',
        );

        // Ambil dokumen terbaru
        final latestDocs = await collectionRef
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();

        if (latestDocs.docs.isNotEmpty) {
          final sensorData = latestDocs.docs.first.data();
          debugPrint('✅ Data terbaru: $sensorData');
          return WaterQualitySample.fromFirestore(sensorData);
        } else {
          debugPrint('⚠️ Tidak ada data di $subcollectionName');
          return null;
        }
      } catch (e, stack) {
        debugPrint('❌ Firestore error: $e');
        debugPrintStack(stackTrace: stack);
        throw Exception("Firestore read failed: $e");
      }
    });
// Weather provider
final weatherProvider = StateNotifierProvider<WeatherNotifier, WeatherInfo?>((
  ref,
) {
  return WeatherNotifier();
});

class WeatherNotifier extends StateNotifier<WeatherInfo?> {
  WeatherNotifier() : super(null);

  // TODO: Fetch weather data from API
  void fetchWeather() {}
}

// Sync status provider
final syncStatusProvider =
    StateNotifierProvider<SyncStatusNotifier, SyncStatus>((ref) {
      return SyncStatusNotifier();
    });

enum SyncStatus { idle, syncing, success, error }

class SyncStatusNotifier extends StateNotifier<SyncStatus> {
  SyncStatusNotifier() : super(SyncStatus.idle);

  // TODO: Implement sync logic
  Future<void> syncData() async {
    state = SyncStatus.syncing;
    // TODO: Perform actual sync operation
    await Future.delayed(const Duration(seconds: 2));
    state = SyncStatus.success;
  }
}

// Settings providers
final weatherEnabledProvider = StateProvider<bool>((ref) => true);
final fuzzySensitivityProvider = StateProvider<double>((ref) => 0.5);

// Default: tampilan 24 jam
final chartTimeRangeProvider = StateProvider<ChartTimeRange>(
  (ref) => ChartTimeRange.day,
);
