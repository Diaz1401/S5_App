import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeviceScreen extends ConsumerWidget {
  const DeviceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Devices')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Device & Calibration',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),

              // Device info card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.device_hub),
                          const SizedBox(width: 8),
                          Text(
                            'Device Information',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      _buildInfoRow(
                        'Device Name',
                        '—',
                      ), // TODO: Get from deviceInfoProvider
                      _buildInfoRow(
                        'Battery Level',
                        '—%',
                      ), // TODO: Get from deviceInfoProvider
                      _buildInfoRow(
                        'Firmware',
                        '—',
                      ), // TODO: Get from deviceInfoProvider
                      _buildInfoRow(
                        'Last Sync',
                        '—',
                      ), // TODO: Get from deviceInfoProvider
                      _buildInfoRow(
                        'Status',
                        '—',
                      ), // TODO: Get connection status
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Calibration section
              Text(
                'Sensor Calibration',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Calibration Offsets',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),

                      _buildCalibrationField('pH Offset', '0.00'),
                      const SizedBox(height: 12),
                      _buildCalibrationField('Temperature Offset (°C)', '0.0'),
                      const SizedBox(height: 12),
                      _buildCalibrationField('TDS Offset (mg/L)', '0'),
                      const SizedBox(height: 12),
                      _buildCalibrationField('Turbidity Offset (NTU)', '0.0'),
                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO: Save calibration values
                          },
                          child: const Text('Save Calibration'),
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildCalibrationField(String label, String initialValue) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      controller: TextEditingController(text: initialValue),
      onChanged: (value) {
        // TODO: Store calibration value
      },
    );
  }
}
