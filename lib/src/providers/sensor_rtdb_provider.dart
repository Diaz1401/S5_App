import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/sample.dart';

/// Auto sign-in with hardcoded admin account on first use.
final firebaseAuthProvider = FutureProvider<User?>((ref) async {
  final auth = FirebaseAuth.instance;

  // If already signed in, reuse the current user.
  final current = auth.currentUser;
  if (current != null) return current;

  try {
    final credential = await auth.signInWithEmailAndPassword(
      email: 'admin@trasi.com',
      password: '88888888',
    );
    return credential.user;
  } catch (e) {
    throw Exception('Admin sign-in failed: $e');
  }
});

/// Fetch latest water quality sample for a given device from Firebase RTDB.
/// Polls the 'realtime' node every 10 seconds.
final realtimeSensorProvider = StreamProvider.autoDispose
    .family<WaterQualitySample?, String>((ref, deviceId) async* {
      // Ensure we are signed in as admin first.
      await ref.watch(firebaseAuthProvider.future);

      final db = FirebaseDatabase.instance;
      final refSensor = db.ref('sensorData/$deviceId/realtime');

      Future<WaterQualitySample?> fetch() async {
        final snapshot = await refSensor.get();
        if (!snapshot.exists || snapshot.value == null) {
          return null;
        }

        final data = Map<String, dynamic>.from(snapshot.value as Map);

        final ph = (data['ph'] as num?)?.toDouble();
        final tds = (data['tds'] as num?)?.toDouble();
        final temperature = (data['temperature'] as num?)?.toDouble();
        final turbidity = (data['turbidity'] as num?)?.toDouble();

        // Use provided timestamp or fallback to current time
        final timestampNum = (data['timestamp'] as num?)?.toInt();
        final timestamp = timestampNum != null
            ? DateTime.fromMillisecondsSinceEpoch(timestampNum * 1000)
            : DateTime.now();

        return WaterQualitySample(
          id: 'realtime',
          pondId: deviceId,
          timestamp: timestamp,
          ph: ph,
          tds: tds,
          temperature: temperature,
          turbidity: turbidity,
          status: 'good',
        );
      }

      yield await fetch();

      while (true) {
        await Future.delayed(const Duration(seconds: 10));
        yield await fetch();
      }
    });

/// History provider: reads all timestamped samples under sensorData/{deviceId}
/// and returns a continuously updating list filtered to the last 1 minute.
final historySensorProvider =
    StreamProvider.family<List<WaterQualitySample>, String>((
      ref,
      deviceId,
    ) async* {
      // Ensure we are signed in as admin first.
      await ref.watch(firebaseAuthProvider.future);

      final db = FirebaseDatabase.instance;
      final refSensor = db.ref('sensorData/$deviceId');

      // Listen to all changes under the device node.
      yield* refSensor.onValue.map((event) {
        if (!event.snapshot.exists || event.snapshot.value == null) {
          return <WaterQualitySample>[];
        }

        final raw = Map<String, dynamic>.from(event.snapshot.value as Map);

        final now = DateTime.now();
        final oneMinuteAgo = now.subtract(const Duration(minutes: 1));

        final samples = <WaterQualitySample>[];

        raw.forEach((key, value) {
          if (key == 'realtime') return; // skip realtime node

          final entry = Map<String, dynamic>.from(value as Map);

          final tsNum = (entry['timestamp'] as num?)?.toInt();
          if (tsNum == null) return;

          final ts = DateTime.fromMillisecondsSinceEpoch(tsNum * 1000);
          if (ts.isBefore(oneMinuteAgo)) return; // only last 1 minute

          final ph = (entry['ph'] as num?)?.toDouble();
          final tds = (entry['tds'] as num?)?.toDouble();
          final temperature = (entry['temperature'] as num?)?.toDouble();
          final turbidity = (entry['turbidity'] as num?)?.toDouble();

          samples.add(
            WaterQualitySample(
              id: key,
              pondId: deviceId,
              timestamp: ts,
              ph: ph,
              tds: tds,
              temperature: temperature,
              turbidity: turbidity,
              status: 'good',
            ),
          );
        });

        samples.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        return samples;
      });
    });
