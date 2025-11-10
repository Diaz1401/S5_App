import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chart_time_range.dart';
import '../providers/providers.dart';
import '../models/sample.dart'; // firestoreSensorProvider

class ChartPlaceholder extends StatelessWidget {
  final ChartTimeRange timeRange;
  final WaterQualitySample sample;

  const ChartPlaceholder({
    super.key,
    required this.timeRange,
    required this.sample,
  });

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        lineBarsData: [
          _buildLine('pH', sample.ph, Colors.blue),
          _buildLine('Temp', sample.temperature, Colors.red),
          _buildLine('TDS', sample.tds, Colors.green),
          _buildLine('Turbidity', sample.turbidity, Colors.orange),
        ],
      ),
    );
  }

  LineChartBarData _buildLine(String label, double value, Color color) {
    return LineChartBarData(
      spots: [FlSpot(0, value)], // cuma satu titik (terbaru)
      isCurved: true,
      color: color,
      dotData: const FlDotData(show: true),
    );
  }
}
