import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../widgets/parameter_tile.dart';
import 'charts_screen.dart';
import 'alerts_screen.dart';
import 'device_screen.dart';
import 'settings_screen.dart';
import '../providers/dummy_data.dart';
import '../providers/weather_provider.dart';
import '../providers/fuzzy_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () {
              /* TODO: sync */
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              // decoration: BoxDecoration(color: Colors.green),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TRASI',
                    style: TextStyle(
                      // color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Current Pond: Main Pond', // TODO: get from provider
                    style: TextStyle(
                      // color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              selected: true,
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.show_chart),
              title: const Text('Charts'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChartsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.warning),
              title: const Text('Alerts'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AlertsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.device_hub),
              title: const Text('Device'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DeviceScreen()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // WQ Score Card
              // WQ Score Card (Fuzzy Mamdani)
              Consumer(
                builder: (context, ref, _) {
                  final fuzzy = ref.watch(fuzzyProvider);
                  final label = fuzzy['result']['label'];
                  final score = fuzzy['result']['score'];

                  return Card(
                    color: _labelColor(label).withOpacity(0.1),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Status Kualitas Air',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Text(
                                    'Kategori: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    _labelText(label),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: _labelColor(label),
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                'Skor: ${score.toStringAsFixed(1)} / 100',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: _labelColor(label),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                label,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Parameter tiles
              Text(
                'Water Parameters',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ParameterTile(
                      icon: Icons.water_drop,
                      title: 'pH',
                      value: DummyData.ph.toStringAsFixed(1),
                      unit: '',
                      trend: DummyData.phTrend,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ParameterTile(
                      icon: Icons.thermostat,
                      title: 'Temperature',
                      value: DummyData.temperature.toStringAsFixed(1),
                      unit: '°C',
                      trend: DummyData.tempTrend,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ParameterTile(
                      icon: Icons.opacity,
                      title: 'TDS',
                      value: DummyData.tds.toStringAsFixed(1),
                      unit: 'mg/L',
                      trend: DummyData.tdsTrend,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ParameterTile(
                      icon: Icons.visibility,
                      title: 'Turbidity',
                      value: DummyData.turbidity.toStringAsFixed(1),
                      unit: 'NTU',
                      trend: DummyData.turbidityTrend,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Quick actions
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ref.refresh(formattedWeatherProvider);
                      },
                      icon: const Icon(Icons.sync),
                      label: const Text('Sync'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Add intervention
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Intervention'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Export data
                      },
                      icon: const Icon(Icons.download),
                      label: const Text('Export'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Weather card
              _buildWeatherCard(context, ref),
            ],
          ),
        ),
      ),
    );
  }
  // pastikan file provider kamu diimpor

  Widget _buildWeatherCard(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(formattedWeatherProvider);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: weatherAsync == null
            ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
            : _buildWeatherContent(context, weatherAsync),
      ),
    );
  }

  Widget _buildWeatherContent(
    BuildContext context,
    Map<String, dynamic> weatherData,
  ) {
    String formatTanggal(String date) {
      final dateTime = DateTime.parse(date);
      final formatter = DateFormat('EEEE, d MMMM yyyy', 'id_ID');
      return formatter.format(dateTime);
    }

    final current = weatherData['current'];
    final location = weatherData['location'];
    final hourlyForecast =
        weatherData['hourly_forecast'] as List<dynamic>? ?? [];

    // Group hourly forecast by days (take first entry of each day for daily summary)
    final Map<String, dynamic> dailyData = {};
    for (var item in hourlyForecast) {
      final date = (item['datetime'] as DateTime).toIso8601String().split(
        'T',
      )[0];
      if (!dailyData.containsKey(date)) {
        dailyData[date] = item;
      }
    }
    final forecastDays = dailyData.values.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header lokasi
        Row(
          children: [
            const Icon(Icons.location_on, color: Colors.blueAccent),
            const SizedBox(width: 8),
            Text(
              '${location['name']}, ${location['country']}',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Cuaca saat ini
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${current['temperature']}°C',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  current['description'] ?? 'Tidak ada data',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text('Kelembapan: ${current['humidity']}%'),
                Text('Angin: ${(current['wind_speed'] * 3.6).round()} km/jam'),
                Text('Terasa seperti: ${current['feels_like']}°C'),
              ],
            ),
            Image.network(
              'https://openweathermap.org/img/wn/${current['icon']}@2x.png',
              width: 70,
              height: 70,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.cloud_off, size: 48),
            ),
          ],
        ),

        const SizedBox(height: 24),
        Text(
          'Prakiraan Cuaca ${forecastDays.length} Hari ke Depan',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        // Daftar prakiraan cuaca
        Column(
          children: forecastDays.map((day) {
            final date = formatTanggal(
              (day['datetime'] as DateTime).toIso8601String().split('T')[0],
            );
            final description = day['description'] ?? 'Tidak ada data';
            final temp = day['temperature'];
            final humidity = day['humidity'];
            final tempMax = day['temp_max'] ?? temp;
            final tempMin = day['temp_min'] ?? temp;

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              color: const Color.fromARGB(255, 2, 70, 119),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 4,
                  horizontal: 8,
                ),
                leading: Image.network(
                  'https://openweathermap.org/img/wn/${day['icon']}@2x.png',
                  width: 40,
                  height: 40,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.cloud, size: 32),
                ),
                title: Text(
                  date,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                subtitle: Text(
                  '$description\n'
                  'Suhu: ${tempMin}°C - ${tempMax}°C • '
                  'Kelembapan: ${humidity}%',
                ),
                trailing: Text(
                  '${temp}°C',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Color _labelColor(String label) {
    switch (label) {
      case 'RSR':
        return Colors.green;
      case 'RR':
        return Colors.lightGreen;
      case 'RS':
        return Colors.amber;
      case 'RT':
        return Colors.orange;
      case 'RST':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Konversi singkatan fuzzy ke label lengkap
  String _labelText(String label) {
    switch (label) {
      case 'RSR':
        return 'Risiko Sangat Rendah';
      case 'RR':
        return 'Risiko Rendah';
      case 'RS':
        return 'Risiko Sedang';
      case 'RT':
        return 'Risiko Tinggi';
      case 'RST':
        return 'Risiko Sangat Tinggi';
      default:
        return 'Tidak Diketahui';
    }
  }
}
