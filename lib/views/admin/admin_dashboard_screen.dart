import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/admin/admin_dashboard_view_model.dart';
import '../../ui/components/admin_charts/admin_line_chart.dart';
import '../../ui/components/admin_charts/admin_bar_chart.dart';
import '../../ui/components/admin_charts/admin_pie_chart.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  static const _goldColor = Color(0xFFB8860B);

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AdminDashboardViewModel>();

    return Container(
      color: const Color(0xFFF5F5F5),
      child: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : viewModel.errorMessage != null
              ? _buildError(viewModel)
              : RefreshIndicator(
                  onRefresh: viewModel.refresh,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(viewModel),
                        const SizedBox(height: 24),
                        _buildSummaryCards(viewModel),
                        const SizedBox(height: 24),
                        _buildChartsRow(viewModel),
                        const SizedBox(height: 24),
                        _buildCourseStatsSection(viewModel),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildError(AdminDashboardViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            viewModel.errorMessage!,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: viewModel.refresh,
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(AdminDashboardViewModel viewModel) {
    return Row(
      children: [
        const Text(
          'Dashboard',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: _goldColor,
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: viewModel.refresh,
          icon: const Icon(Icons.refresh),
          tooltip: 'Atualizar',
        ),
      ],
    );
  }

  Widget _buildSummaryCards(AdminDashboardViewModel viewModel) {
    final stats = viewModel.platformStats;
    final cards = [
      _SummaryCard(
        title: 'Total Usuários',
        value: stats.totalUsers.toString(),
        icon: Icons.people,
        color: const Color(0xFF42A5F5),
      ),
      _SummaryCard(
        title: 'Questões',
        value: stats.totalQuestions.toString(),
        icon: Icons.quiz,
        color: const Color(0xFF66BB6A),
      ),
      _SummaryCard(
        title: 'Provas Realizadas',
        value: stats.totalAttempts.toString(),
        icon: Icons.assignment,
        color: const Color(0xFFFF7043),
      ),
      _SummaryCard(
        title: 'Taxa Aprovação',
        value: '${viewModel.overallPassRate.toStringAsFixed(1)}%',
        icon: Icons.check_circle,
        color: const Color(0xFF9575CD),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 500) {
          // Mobile: 2 columns
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: cards.map((card) => SizedBox(
              width: (constraints.maxWidth - 12) / 2,
              child: card,
            )).toList(),
          );
        }
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: cards,
        );
      },
    );
  }

  Widget _buildChartsRow(AdminDashboardViewModel viewModel) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 800) {
          return Column(
            children: [
              _buildChartCard(
                title: 'Atividade Mensal',
                height: 300,
                child: AdminLineChart(data: viewModel.monthlyActivity),
              ),
              const SizedBox(height: 16),
              _buildChartCard(
                title: 'Distribuição de Papéis',
                height: 250,
                child: AdminPieChart(stats: viewModel.platformStats),
              ),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: _buildChartCard(
                title: 'Atividade Mensal',
                subtitle: 'Provas realizadas e usuários ativos',
                height: 300,
                child: AdminLineChart(data: viewModel.monthlyActivity),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: _buildChartCard(
                title: 'Distribuição de Papéis',
                height: 300,
                child: AdminPieChart(stats: viewModel.platformStats),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCourseStatsSection(AdminDashboardViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Desempenho por Curso',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        _buildChartCard(
          title: 'Nota Média por Curso',
          height: 300,
          child: AdminBarChart(data: viewModel.courseStats),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth >= 700 ? 2 : 1;
            final spacing = 20.0;
            final cardWidth = (constraints.maxWidth - (crossAxisCount - 1) * spacing) / crossAxisCount;
            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              alignment: WrapAlignment.center,
              children: viewModel.courseStats.map((course) {
                return SizedBox(
                  width: cardWidth,
                  child: _CourseStatsCard(stats: course),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildChartCard({
    required String title,
    String? subtitle,
    required double height,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(height: height, child: child),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

class _CourseStatsCard extends StatelessWidget {
  const _CourseStatsCard({required this.stats});

  static const _goldColor = Color(0xFFB8860B);

  final dynamic stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            stats.courseName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: _goldColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _statChip('Questões', stats.totalQuestions.toString()),
              _statChip('Templates', stats.totalTemplates.toString()),
              _statChip('Provas', stats.totalAttempts.toString()),
              _statChip('Média', '${stats.avgScore.toStringAsFixed(1)}%'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statChip(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }
}
