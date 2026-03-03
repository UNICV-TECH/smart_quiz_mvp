import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../models/admin_stats.dart';

class AdminLineChart extends StatelessWidget {
  const AdminLineChart({
    super.key,
    required this.data,
  });

  final List<AdminMonthlyActivity> data;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(
        child: Text(
          'Sem dados de atividade',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: _calculateInterval(),
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey[200]!,
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= data.length) return const SizedBox();
                final parts = data[index].month.split('-');
                return Text(
                  parts.length >= 2 ? '${parts[1]}/${parts[0].substring(2)}' : '',
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          // Attempts line
          LineChartBarData(
            spots: data.asMap().entries.map((entry) {
              return FlSpot(
                entry.key.toDouble(),
                entry.value.totalAttempts.toDouble(),
              );
            }).toList(),
            isCurved: true,
            color: const Color(0xFFB8860B),
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0xFFB8860B).withValues(alpha: 0.1),
            ),
          ),
          // Active users line
          LineChartBarData(
            spots: data.asMap().entries.map((entry) {
              return FlSpot(
                entry.key.toDouble(),
                entry.value.activeUsers.toDouble(),
              );
            }).toList(),
            isCurved: true,
            color: const Color(0xFF4CAF50),
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final color = spot.barIndex == 0
                    ? const Color(0xFFB8860B)
                    : const Color(0xFF4CAF50);
                final label = spot.barIndex == 0 ? 'Provas' : 'Usuários';
                return LineTooltipItem(
                  '$label: ${spot.y.toInt()}',
                  TextStyle(color: color, fontWeight: FontWeight.bold),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  double _calculateInterval() {
    if (data.isEmpty) return 1;
    final maxVal = data.fold<int>(
      0,
      (max, item) => item.totalAttempts > max ? item.totalAttempts : max,
    );
    if (maxVal <= 5) return 1;
    return (maxVal / 5).ceilToDouble();
  }
}
