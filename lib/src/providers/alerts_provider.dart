import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/alert.dart';
import 'fuzzy_provider.dart';
import '../services/notification_service.dart';

class AlertsNotifier extends Notifier<List<Alert>> {
  @override
  List<Alert> build() {
    return [];
  }

  void addAlert(Alert alert) {
    state = [alert, ...state];
  }

  void markAsRead(String id) {
    state = [
      for (final alert in state)
        if (alert.id == id) alert.copyWith(isRead: true) else alert,
    ];
  }

  void clearAll() {
    state = [];
  }
}

final alertsProvider = NotifierProvider<AlertsNotifier, List<Alert>>(
  AlertsNotifier.new,
);

// Logic to monitor fuzzy status and trigger alerts
final alertMonitorProvider = Provider<void>((ref) {
  final fuzzyAsync = ref.watch(fuzzyProvider);

  fuzzyAsync.whenData((data) async {
    final result = data['result'] as Map<String, dynamic>;
    final label = result['label'] as String;

    // Check if high risk
    if (label == 'RT' || label == 'RST') {
      // Logic to prevent duplicate alerts
      final alerts = ref.read(alertsProvider);
      final now = DateTime.now();

      bool shouldAdd = true;
      if (alerts.isNotEmpty) {
        final lastAlert = alerts.first;
        // If last alert was less than 1 hour ago and is the same type, don't add
        if (lastAlert.title.contains(label) &&
            now.difference(lastAlert.timestamp).inMinutes < 60) {
          shouldAdd = false;
        }
      }

      if (shouldAdd) {
        final severity = label == 'RST' ? 'critical' : 'warning';
        final description = label == 'RST'
            ? 'Kualitas air sangat buruk! Segera lakukan tindakan.'
            : 'Kualitas air buruk. Perlu perhatian.';

        final alert = Alert(
          id: now.millisecondsSinceEpoch.toString(),
          title: 'Peringatan Kualitas Air ($label)',
          description: description,
          severity: severity,
          timestamp: now,
        );

        // Use Future.microtask to avoid modifying provider during build
        Future.microtask(() {
          ref.read(alertsProvider.notifier).addAlert(alert);
        });

        // Show local notification
        try {
          await NotificationService().showNotification(
            id: now.millisecondsSinceEpoch ~/ 1000, // Unique ID
            title: alert.title,
            body: alert.description,
          );
        } catch (_) {}
      }
    }
  });
});
