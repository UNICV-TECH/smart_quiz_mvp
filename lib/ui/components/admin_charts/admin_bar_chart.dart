import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../models/admin_stats.dart';

class AdminBarChart extends StatelessWidget {
  const AdminBarChart({
    super.key,
    required this.data,
  });

  final List<AdminCourseStats> data;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(
        child: Text(
          'Sem dados por curso',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: _maxY(),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final course = data[group.x.toInt()];
              return BarTooltipItem(
                '${course.courseName}\n${course.avgScore.toStringAsFixed(1)}%',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}%',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= data.length) return const SizedBox();
                final name = data[index].courseName;
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    name.length > 10 ? '${name.substring(0, 10)}...' : name,
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey[200]!,
              strokeWidth: 1,
            );
          },
        ),
        borderData: FlBorderData(show: false),
        barGroups: data.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.avgScore,
                color: const Color(0xFFB8860B),
                width: 20,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  double _maxY() {
    if (data.isEmpty) return 100;
    final maxScore = data.fold<double>(
      0,
      (max, item) => item.avgScore > max ? item.avgScore : max,
    );
    return (maxScore * 1.2).clamp(10, 100);
  }
}
