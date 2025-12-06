import 'package:flutter/material.dart';
import '../utils/color_utils.dart';

class StatusCard extends StatelessWidget {
  final double? wqScore;
  final String? status;

  const StatusCard({super.key, this.wqScore, this.status});

  @override
  Widget build(BuildContext context) {
    final displayScore = wqScore?.toStringAsFixed(0) ?? '—';
    final displayStatus = status ?? 'Unknown';
    final statusColor = ColorUtils.getStatusColor(context, displayStatus);

    return SizedBox(
      width: double.infinity,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Text(
                'Water Quality Score',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),

              // Gauge-like display
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: statusColor.withOpacity(0.1),
                  border: Border.all(color: statusColor, width: 8),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        displayScore,
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        '/100',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: statusColor),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Chip(
                label: Text(
                  displayStatus.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: statusColor.withOpacity(0.1),
                side: BorderSide(color: statusColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
