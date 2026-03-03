import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../models/admin_stats.dart';

class AdminPieChart extends StatelessWidget {
  const AdminPieChart({
    super.key,
    required this.stats,
  });

  final AdminPlatformStats stats;

  @override
  Widget build(BuildContext context) {
    final total = stats.totalStudents + stats.totalTeachers + stats.totalAdmins;

    if (total == 0) {
      return const Center(
        child: Text(
          'Sem dados de usuários',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: [
                PieChartSectionData(
                  value: stats.totalStudents.toDouble(),
                  title: '${_percentage(stats.totalStudents, total)}%',
                  color: const Color(0xFF42A5F5),
                  radius: 50,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                PieChartSectionData(
                  value: stats.totalTeachers.toDouble(),
                  title: '${_percentage(stats.totalTeachers, total)}%',
                  color: const Color(0xFF66BB6A),
                  radius: 50,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                PieChartSectionData(
                  value: stats.totalAdmins.toDouble(),
                  title: '${_percentage(stats.totalAdmins, total)}%',
                  color: const Color(0xFF3F51B5),
                  radius: 50,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _LegendItem(
                color: const Color(0xFF42A5F5),
                label: 'Alunos',
                count: stats.totalStudents,
              ),
              const SizedBox(height: 8),
              _LegendItem(
                color: const Color(0xFF66BB6A),
                label: 'Professores',
                count: stats.totalTeachers,
              ),
              const SizedBox(height: 8),
              _LegendItem(
                color: const Color(0xFF3F51B5),
                label: 'Admins',
                count: stats.totalAdmins,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _percentage(int value, int total) {
    if (total == 0) return '0';
    return ((value / total) * 100).round().toString();
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
    required this.count,
  });

  final Color color;
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '$label ($count)',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
      ],
    );
  }
}
