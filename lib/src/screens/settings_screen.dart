import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherEnabled = ref.watch(weatherEnabledProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pond selection TODO: implement pond management
              // Card(
              //   child: Padding(
              //     padding: const EdgeInsets.all(16.0),
              //     child: Column(
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: [
              //         Text(
              //           'Pond Selection',
              //           style: Theme.of(context).textTheme.titleMedium,
              //         ),
              //         const SizedBox(height: 12),
              //         DropdownButtonFormField<String>(
              //           value: 'main_pond', // TODO: get from provider
              //           decoration: const InputDecoration(
              //             labelText: 'Current Pond',
              //             border: OutlineInputBorder(),
              //           ),
              //           items: const [
              //             DropdownMenuItem(
              //               value: 'main_pond',
              //               child: Text('Main Pond'),
              //             ),
              //             DropdownMenuItem(
              //               value: 'pond_2',
              //               child: Text('Pond 2'),
              //             ),
              //             DropdownMenuItem(
              //               value: 'pond_3',
              //               child: Text('Pond 3'),
              //             ),
              //           ], // TODO: get pond list from provider
              //           onChanged: (value) {
              //             // TODO: update selected pond in provider
              //           },
              //         ),
              //         const SizedBox(height: 8),
              //         ElevatedButton(
              //           onPressed: () {
              //             // TODO: add new pond
              //           },
              //           child: const Text('Add New Pond'),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
              // const SizedBox(height: 16),

              // Theme settings
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pengaturan Tema',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Consumer(
                        builder: (context, ref, child) {
                          final currentTheme = ref.watch(themeProvider);
                          return DropdownButtonFormField<AppThemeType>(
                            value: currentTheme,
                            decoration: const InputDecoration(
                              labelText: 'Mode Warna',
                              border: OutlineInputBorder(),
                              helperText: 'Pilih tema warna visual',
                            ),
                            items: AppThemeType.values.map((theme) {
                              String label;
                              switch (theme) {
                                case AppThemeType.rose:
                                  label = 'Mawar';
                                  break;
                                case AppThemeType.leaves:
                                  label = 'Daun';
                                  break;
                              }
                              return DropdownMenuItem(
                                value: theme,
                                child: Text(label),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                ref
                                    .read(themeProvider.notifier)
                                    .setTheme(value);
                              }
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      Consumer(
                        builder: (context, ref, child) {
                          final themeMode = ref.watch(themeModeProvider);
                          return DropdownButtonFormField<ThemeMode>(
                            value: themeMode,
                            decoration: const InputDecoration(
                              labelText: 'Mode Tema',
                              border: OutlineInputBorder(),
                              helperText:
                                  'Pilih Terang, Gelap, atau Default Sistem',
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: ThemeMode.system,
                                child: Text('Default Sistem'),
                              ),
                              DropdownMenuItem(
                                value: ThemeMode.light,
                                child: Text('Mode Terang'),
                              ),
                              DropdownMenuItem(
                                value: ThemeMode.dark,
                                child: Text('Mode Gelap'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                ref
                                    .read(themeModeProvider.notifier)
                                    .setMode(value);
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
                        'Integrasi Cuaca',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('Aktifkan Data Cuaca'),
                        subtitle: const Text(
                          'Tampilkan informasi cuaca di dasbor',
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
                        'Manajemen Data',
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
                          label: const Text('Ekspor Database'),
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
                          label: const Text('Hapus Semua Data'),
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
        title: const Text('Hapus Semua Data'),
        content: const Text(
          'Tindakan ini akan menghapus semua data kualitas air, peringatan, dan pengaturan secara permanen. Ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Clear all data
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
