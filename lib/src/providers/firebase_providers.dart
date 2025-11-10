import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/chart_time_range.dart';

// Extend provider value to include both sensor values and timestamp
class SensorReading {
  final Map<String, double> values;
  final DateTime timestamp;

  const SensorReading(this.values, this.timestamp);
}

// Helper to validate sensor values and handle sentinel values
double? validateSensorValue(String type, dynamic value) {
  if (value == null) return null;

  try {
    final number = (value is num)
        ? value.toDouble()
        : double.parse(value.toString());

    // Apply sensor-specific validation
    switch (type) {
      case 'temperature':
        // Ignore common temperature sentinel (-127) or extreme values
        if (number <= -200 || number > 50) return null;
        break;
      case 'ph':
        // pH is typically 0-14
        if (number < 0 || number > 14) return null;
        break;
      case 'tds':
        // TDS shouldn't be negative
        if (number < 0) return null;
        break;
      case 'turbidity':
        // Turbidity shouldn't be negative
        if (number < 0) return null;
        break;
    }

    return number;
  } catch (_) {
    return null;
  }
}

// Provider that streams the latest validated sensor values from Realtime Database.
// Now includes timestamp and handles sentinel values
final realtimeSensorProvider = StreamProvider<SensorReading>((ref) {
  // Updated to use the project's RTDB path 'sensorData' as provided
  // Example node: https://trasi-app-default-rtdb.asia-southeast1.firebasedatabase.app/
  // Path: /sensorData
  final dbRef = FirebaseDatabase.instance.ref('sensorData');

  return dbRef.onValue.map((event) {
    final val = event.snapshot.value;

    if (val == null) return SensorReading(<String, double>{}, DateTime.now());

    // Try to parse map values robustly
    final Map<String, double> parsed = {};
    if (val is Map) {
      // Skip handling timestamp here as it's handled later
      // Parse sensor values with validation
      final validKeys = ['ph', 'temperature', 'tds', 'turbidity'];
      for (final key in validKeys) {
        if (!val.containsKey(key)) continue;
        final validated = validateSensorValue(key, val[key]);
        if (validated != null) {
          parsed[key] = validated;
        }
      }
    }

    // Create timestamp, using the RTDB timestamp or fallback to now
    final now = DateTime.now();
    final ts = (val is Map && val['timestamp'] != null)
        ? DateTime.fromMillisecondsSinceEpoch((val['timestamp'] as num).toInt())
        : now;

    return SensorReading(parsed, ts);
  });
});

// Provider to fetch chart points from Firestore for a given parameter and time range.
// ASSUMPTION: Firestore has a collection 'charts' where each document ID is the
// parameter name (e.g. 'ph', 'temperature', 'tds', 'turbidity'). Each document
// contains fields 'day', 'week', 'month'. Each field may be either:
//  - an array of objects: [{"x": 0, "y": 7.1}, ...]
//  - an array of numbers: [7.1, 7.3, ...] (x will be index)
// Adjust your Firestore layout or adapt this code accordingly.
final chartDataProvider =
    FutureProvider.family<List<FlSpot>, Map<String, dynamic>>((
      ref,
      params,
    ) async {
      // params can contain:
      // - 'docPath' (full Firestore document path) OR
      // - 'collection' and 'doc' (collection/doc) OR
      // - 'parameter' (fallback to older behavior)
      final parameter = params['parameter'] as String? ?? 'ph';
      final range = params['range'] as ChartTimeRange? ?? ChartTimeRange.day;
      final docPath = params['docPath'] as String?;

      DocumentSnapshot<Map<String, dynamic>> docSnap;

      if (docPath != null && docPath.isNotEmpty) {
        // docPath expected like: 'riwayat/device_01/data_1004421/mR5ZrgGHxDhBFNVWPceU'
        docSnap = await FirebaseFirestore.instance.doc(docPath).get();
      } else if (params['collection'] != null && params['doc'] != null) {
        docSnap = await FirebaseFirestore.instance
            .collection(params['collection'] as String)
            .doc(params['doc'] as String)
            .get();
      } else {
        // fallback old behavior: collection 'charts', doc parameter
        docSnap = await FirebaseFirestore.instance
            .collection('charts')
            .doc(parameter)
            .get();
      }

      if (!docSnap.exists) return <FlSpot>[];

      final data = docSnap.data() ?? <String, dynamic>{};
      final fieldName = range.name; // 'day' | 'week' | 'month'

      dynamic raw;

      // Try multiple common layouts
      // 1) data[parameter] is Map with keys 'day','week','month'
      if (data.containsKey(parameter) &&
          data[parameter] is Map &&
          (data[parameter] as Map).containsKey(fieldName)) {
        raw = (data[parameter] as Map)[fieldName];
      }

      // 2) data has field like 'ph_day'
      raw ??= data['${parameter}_${fieldName}'];

      // 3) data has field 'day' which contains map per parameter
      if (raw == null &&
          data.containsKey(fieldName) &&
          data[fieldName] is Map &&
          (data[fieldName] as Map).containsKey(parameter)) {
        raw = (data[fieldName] as Map)[parameter];
      }

      // 4) data[parameter] is directly a List
      raw ??= data[parameter];

      // 5) data[fieldName] is a List (maybe single-parameter document)
      raw ??= data[fieldName];

      if (raw == null) return <FlSpot>[];

      final List<FlSpot> spots = [];

      if (raw is List) {
        for (var i = 0; i < raw.length; i++) {
          final item = raw[i];
          if (item is Map && (item.containsKey('x') || item.containsKey('y'))) {
            final xRaw = item['x'];
            final yRaw = item['y'];
            try {
              final x = (xRaw is num)
                  ? xRaw.toDouble()
                  : double.parse(xRaw.toString());
              final y = (yRaw is num)
                  ? yRaw.toDouble()
                  : double.parse(yRaw.toString());
              spots.add(FlSpot(x, y));
            } catch (_) {}
          } else {
            try {
              final y = (item is num)
                  ? item.toDouble()
                  : double.parse(item.toString());
              spots.add(FlSpot(i.toDouble(), y));
            } catch (_) {}
          }
        }
      }

      return spots;
    });
