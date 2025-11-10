// lib/src/providers/fuzzy_provider.dart
// Provider yang memanggil FuzzyEvaluator menggunakan DummyData (default).
// Ganti sumber data di bagian "DATA SOURCE" untuk menggunakan sensor nyata.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/fuzzy_evaluator.dart';
import 'firebase_providers.dart';
import 'package:firebase_database/firebase_database.dart';

// Map Realtime Database values directly to fuzzy evaluation results.
final fuzzyProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final dbRef = FirebaseDatabase.instance.ref('SensorData');

  return dbRef.onValue.map((event) {
    final val = event.snapshot.value;
    double ph = 0.0, temp = 0.0, tds = 0.0, turb = 0.0;

    if (val is Map) {
      try {
        final p = val['ph'];
        final t = val['temperature'] ?? val['temp'];
        final d = val['tds'];
        final b = val['turbidity'] ?? val['turb'];

        ph = (p is num)
            ? p.toDouble()
            : (double.tryParse(p?.toString() ?? '') ?? 0.0);
        temp = (t is num)
            ? t.toDouble()
            : (double.tryParse(t?.toString() ?? '') ?? 0.0);
        tds = (d is num)
            ? d.toDouble()
            : (double.tryParse(d?.toString() ?? '') ?? 0.0);
        turb = (b is num)
            ? b.toDouble()
            : (double.tryParse(b?.toString() ?? '') ?? 0.0);
      } catch (_) {}
    }

    final result = FuzzyEvaluator.evaluate(
      ph: ph,
      temperature: temp,
      tds: tds,
      turbidity: turb,
    );

    return {
      'input': {'ph': ph, 'temperature': temp, 'tds': tds, 'turbidity': turb},
      'result': result,
    };
  });
});
