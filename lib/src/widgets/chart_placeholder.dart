import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/chart_time_range.dart';
import '../models/sample.dart';

class ChartPlaceholder extends StatelessWidget {
  final ChartTimeRange timeRange;
  final List<WaterQualitySample> samples;

  const ChartPlaceholder({
    super.key,
    required this.timeRange,
    required this.samples,
  });

  @override
  Widget build(BuildContext context) {
    final bars = _buildLines();
    if (bars.isEmpty) {
      return const Center(child: Text('Tidak ada data dalam 1 menit terakhir'));
    }

    return LineChart(LineChartData(lineBarsData: bars));
  }

  List<LineChartBarData> _buildLines() {
    if (samples.isEmpty) return [];

    final now = DateTime.now();
    final oneMinuteAgo = now.subtract(const Duration(minutes: 1));

    final recent =
        samples.where((s) => s.timestamp.isAfter(oneMinuteAgo)).toList()
          ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    if (recent.isEmpty) return [];

    final baseMs = recent.first.timestamp.millisecondsSinceEpoch.toDouble();

    List<FlSpot> buildSpots(double? Function(WaterQualitySample) selector) {
      return recent
          .map((s) {
            final v = selector(s);
            if (v == null) return null;
            final t =
                (s.timestamp.millisecondsSinceEpoch.toDouble() - baseMs) /
                1000.0; // seconds since first sample
            return FlSpot(t, v);
          })
          .whereType<FlSpot>()
          .toList();
    }

    final phSpots = buildSpots((s) => s.ph);
    final tempSpots = buildSpots((s) => s.temperature);
    final tdsSpots = buildSpots((s) => s.tds);
    final turbSpots = buildSpots((s) => s.turbidity);

    final bars = <LineChartBarData>[];

    if (phSpots.isNotEmpty) {
      bars.add(_buildLine(phSpots, Colors.blue));
    }
    if (tempSpots.isNotEmpty) {
      bars.add(_buildLine(tempSpots, Colors.red));
    }
    if (tdsSpots.isNotEmpty) {
      bars.add(_buildLine(tdsSpots, Colors.green));
    }
    if (turbSpots.isNotEmpty) {
      bars.add(_buildLine(turbSpots, Colors.orange));
    }

    return bars;
  }

  LineChartBarData _buildLine(List<FlSpot> spots, Color color) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: color,
      dotData: const FlDotData(show: true),
    );
  }
}
