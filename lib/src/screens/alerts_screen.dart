import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/alert_card.dart';
import '../providers/alerts_provider.dart';

class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerts = ref.watch(alertsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Alerts')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Alerts & Logs',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      _showAddInterventionModal(context);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Intervention'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Expanded(
                child: alerts.isEmpty
                    ? const Center(child: Text('No alerts yet'))
                    : ListView.builder(
                        itemCount: alerts.length,
                        itemBuilder: (context, index) {
                          final alert = alerts[index];
                          return AlertCard(
                            title: alert.title,
                            description: alert.description,
                            severity: alert.severity,
                            timestamp: alert.timestamp,
                            onTap: () {
                              ref
                                  .read(alertsProvider.notifier)
                                  .markAsRead(alert.id);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddInterventionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add Intervention',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),

              TextField(
                decoration: const InputDecoration(
                  labelText: 'Intervention Type',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  // TODO: Store intervention type
                },
              ),
              const SizedBox(height: 16),

              TextField(
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                onChanged: (value) {
                  // TODO: Store intervention notes
                },
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Save intervention
                      Navigator.pop(context);
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
