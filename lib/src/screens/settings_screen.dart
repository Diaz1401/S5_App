import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherEnabled = ref.watch(weatherEnabledProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pond selection
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pond Selection',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: 'main_pond', // TODO: get from provider
                        decoration: const InputDecoration(
                          labelText: 'Current Pond',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'main_pond',
                            child: Text('Main Pond'),
                          ),
                          DropdownMenuItem(
                            value: 'pond_2',
                            child: Text('Pond 2'),
                          ),
                          DropdownMenuItem(
                            value: 'pond_3',
                            child: Text('Pond 3'),
                          ),
                        ], // TODO: get pond list from provider
                        onChanged: (value) {
                          // TODO: update selected pond in provider
                        },
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          // TODO: add new pond
                        },
                        child: const Text('Add New Pond'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Theme settings
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Theme Settings',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Consumer(
                        builder: (context, ref, child) {
                          final themeMode = ref.watch(themeModeProvider);
                          return DropdownButtonFormField<ThemeMode>(
                            initialValue: themeMode,
                            decoration: const InputDecoration(
                              labelText: 'Theme Mode',
                              border: OutlineInputBorder(),
                              helperText:
                                  'Choose how the app appearance follows your system settings',
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: ThemeMode.system,
                                child: Text('System Default'),
                              ),
                              DropdownMenuItem(
                                value: ThemeMode.light,
                                child: Text('Light Mode'),
                              ),
                              DropdownMenuItem(
                                value: ThemeMode.dark,
                                child: Text('Dark Mode'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                ref.read(themeModeProvider.notifier).state =
                                    value;
                              }
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Weather settings
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Weather Integration',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('Enable Weather Data'),
                        subtitle: const Text(
                          'Show weather information on dashboard',
                        ),
                        value: weatherEnabled,
                        onChanged: (value) {
                          ref.read(weatherEnabledProvider.notifier).state =
                              value;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Data management
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Data Management',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // TODO: Export database
                          },
                          icon: const Icon(Icons.download),
                          label: const Text('Export Database'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            _showClearDataDialog(context);
                          },
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Clear All Data'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This action will permanently delete all water quality data, alerts, and settings. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Clear all data
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
