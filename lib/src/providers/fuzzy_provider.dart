// lib/src/providers/fuzzy_provider.dart
// Provider yang memanggil FuzzyEvaluator menggunakan data sensor RTDB real-time.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/fuzzy_evaluator.dart';
import 'sensor_rtdb_provider.dart';

/// Evaluates water quality risk using fuzzy logic based on real-time RTDB sensor data.
final fuzzyProvider = Provider<AsyncValue<Map<String, dynamic>>>((ref) {
  // Read latest sensor data from RTDB
  const deviceId = 'CQMyMNobhyZbfYSExmQjPkINOWC2';
  final sensorAsync = ref.watch(realtimeSensorProvider(deviceId));

  return sensorAsync.whenData((sensorData) {
    // If no sensor data available, return a default "unknown" result
    if (sensorData == null) {
      return {
        'input': {'ph': 0.0, 'temperature': 0.0, 'tds': 0.0, 'turbidity': 0.0},
        'result': {'label': 'N/A', 'score': 0.0},
      };
    }

    // Extract values with defaults if null
    final ph = sensorData.ph ?? 7.0;
    final temp = sensorData.temperature ?? 25.0;
    final tds = sensorData.tds ?? 100.0;
    final turb = sensorData.turbidity ?? 50.0;

    final result = FuzzyEvaluator.evaluate(ph: ph, tds: tds, turbidity: turb);

    // Return data with input values for debugging
    return {
      'input': {'ph': ph, 'temperature': temp, 'tds': tds, 'turbidity': turb},
      'result': result,
    };
  });
});
