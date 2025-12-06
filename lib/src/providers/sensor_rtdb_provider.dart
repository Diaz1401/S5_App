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
/// Listens to the 'realtime' node for continuous updates.
final realtimeSensorProvider =
    StreamProvider.family<WaterQualitySample?, String>((ref, deviceId) async* {
      // Ensure we are signed in as admin first.
      await ref.watch(firebaseAuthProvider.future);

      final db = FirebaseDatabase.instance;

      // Path: sensorData/{deviceId}/realtime
      final refSensor = db.ref('sensorData/$deviceId/realtime');

      // Listen to the stream of events
      yield* refSensor.onValue.map((event) {
        if (!event.snapshot.exists || event.snapshot.value == null) {
          return null;
        }

        final data = Map<String, dynamic>.from(event.snapshot.value as Map);

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
      });
    });
