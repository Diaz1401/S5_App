import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/chart_time_range.dart';
import '../models/sample.dart';

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
          if (sample.ph != null) _buildLine('pH', sample.ph!, Colors.blue),
          if (sample.temperature != null)
            _buildLine('Temp', sample.temperature!, Colors.red),
          if (sample.tds != null) _buildLine('TDS', sample.tds!, Colors.green),
          if (sample.turbidity != null)
            _buildLine('Turbidity', sample.turbidity!, Colors.orange),
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
