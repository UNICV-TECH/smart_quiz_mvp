import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../repositories/teacher_repository.dart';
import '../../services/session_manager.dart';
import '../../ui/theme/app_color.dart';
import '../../viewmodels/teacher/teacher_dashboard_view_model.dart';

/// Tela de estatisticas do professor
class TeacherStatsScreen extends StatelessWidget {
  const TeacherStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sessionManager = context.watch<SessionManager>();
    final teacherId = sessionManager.currentUser?.id ?? '';
    final teacherRepo = context.read<TeacherRepository?>();

    if (teacherRepo == null) {
      return const Center(
        child: Text('Erro: conexao com o servidor nao disponivel'),
      );
    }

    return ChangeNotifierProvider(
      create: (context) => TeacherDashboardViewModel(
        teacherId: teacherId,
        teacherRepository: teacherRepo,
      )..loadStats(),
      child: const _StatsContent(),
    );
  }
}

class _StatsContent extends StatelessWidget {
  const _StatsContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TeacherDashboardViewModel>();

    return Container(
      color: const Color(0xFFF9F9F9),
      child: RefreshIndicator(
        onRefresh: viewModel.refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(
              MediaQuery.of(context).size.width < 800 ? 12 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Dashboard',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Visao geral das suas atividades',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),

              if (viewModel.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (viewModel.errorMessage != null)
                _buildErrorState(viewModel)
              else
                _buildStats(viewModel),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(TeacherDashboardViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              viewModel.errorMessage!,
              style: const TextStyle(color: AppColors.red),
            ),
          ),
          TextButton(
            onPressed: viewModel.refresh,
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(TeacherDashboardViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary cards
        _buildSummaryCards(viewModel),
        const SizedBox(height: 32),

        // Question stats by course
        if (viewModel.questionStats.isNotEmpty) ...[
          const Text(
            'Questoes por Curso',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildQuestionStatsList(viewModel),
          const SizedBox(height: 32),
        ],

        // Exam stats by course
        if (viewModel.examStats.isNotEmpty) ...[
          const Text(
            'Provas por Curso',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildExamStatsList(viewModel),
        ],
      ],
    );
  }

  Widget _buildSummaryCards(TeacherDashboardViewModel viewModel) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cards = [
          _SummaryCard(
            title: 'Total de Questoes',
            value: viewModel.totalQuestions.toString(),
            subtitle: '${viewModel.activeQuestions} ativas',
            icon: Icons.quiz_outlined,
            color: Colors.blue,
          ),
          _SummaryCard(
            title: 'Templates de Prova',
            value: viewModel.totalTemplates.toString(),
            subtitle: '${viewModel.publishedTemplates} publicados',
            icon: Icons.assignment_outlined,
            color: AppColors.green,
          ),
          _SummaryCard(
            title: 'Provas Realizadas',
            value: viewModel.totalExamsTaken.toString(),
            subtitle: '${viewModel.totalPassed} aprovados',
            icon: Icons.people_outlined,
            color: Colors.purple,
          ),
          _SummaryCard(
            title: 'Taxa de Aprovacao',
            value: '${viewModel.overallPassRate.toStringAsFixed(1)}%',
            subtitle: 'Media: ${viewModel.overallAvgScore.toStringAsFixed(1)} pts',
            icon: Icons.trending_up,
            color: Colors.orange,
          ),
        ];

        if (constraints.maxWidth < 600) {
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: cards
                .map((card) => SizedBox(
                      width: (constraints.maxWidth - 12) / 2,
                      child: card,
                    ))
                .toList(),
          );
        }

        return Row(
          children: cards
              .expand((card) => [Expanded(child: card), const SizedBox(width: 16)])
              .toList()
            ..removeLast(),
        );
      },
    );
  }

  Widget _buildQuestionStatsList(TeacherDashboardViewModel viewModel) {
    return Column(
      children: viewModel.questionStats.map((stats) {
        return _QuestionStatsCard(
          courseName: stats.courseName ?? 'Curso',
          totalQuestions: stats.totalQuestions,
          activeQuestions: stats.activeQuestions,
          categoriesUsed: stats.categoriesUsed,
          avgPoints: stats.avgPoints,
        );
      }).toList(),
    );
  }

  Widget _buildExamStatsList(TeacherDashboardViewModel viewModel) {
    return Column(
      children: viewModel.examStats.map((stats) {
        return _ExamStatsCard(
          courseName: stats.courseName ?? 'Curso',
          totalTemplates: stats.totalTemplates,
          publishedTemplates: stats.publishedTemplates,
          totalExamsTaken: stats.totalExamsTaken,
          avgScore: stats.avgScore,
          totalPassed: stats.totalPassed,
          passRate: stats.passRate,
        );
      }).toList(),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionStatsCard extends StatelessWidget {
  final String courseName;
  final int totalQuestions;
  final int activeQuestions;
  final int categoriesUsed;
  final double avgPoints;

  const _QuestionStatsCard({
    required this.courseName,
    required this.totalQuestions,
    required this.activeQuestions,
    required this.categoriesUsed,
    required this.avgPoints,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: const Border(
          left: BorderSide(color: Colors.blue, width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 500;
          final header = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                courseName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$categoriesUsed categorias utilizadas',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            ],
          );
          final stats = Row(
            mainAxisAlignment: isMobile
                ? MainAxisAlignment.spaceAround
                : MainAxisAlignment.end,
            mainAxisSize: isMobile ? MainAxisSize.max : MainAxisSize.min,
            children: [
              _buildStatColumn('Total', totalQuestions.toString()),
              _buildStatColumn('Ativas', activeQuestions.toString()),
              _buildStatColumn('Pontos', avgPoints.toStringAsFixed(1)),
            ],
          );

          if (isMobile) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                header,
                const SizedBox(height: 12),
                stats,
              ],
            );
          }

          return Row(
            children: [
              Expanded(flex: 2, child: header),
              stats,
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Container(
      width: 80,
      alignment: Alignment.center,
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExamStatsCard extends StatelessWidget {
  final String courseName;
  final int totalTemplates;
  final int publishedTemplates;
  final int totalExamsTaken;
  final double avgScore;
  final int totalPassed;
  final double passRate;

  const _ExamStatsCard({
    required this.courseName,
    required this.totalTemplates,
    required this.publishedTemplates,
    required this.totalExamsTaken,
    required this.avgScore,
    required this.totalPassed,
    required this.passRate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: const Border(
          left: BorderSide(color: AppColors.green, width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  courseName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '$publishedTemplates/$totalTemplates publicados',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.green,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final metrics = [
                _buildMetric(
                  'Provas realizadas',
                  totalExamsTaken.toString(),
                  Icons.assignment_turned_in_outlined,
                ),
                _buildMetric(
                  'Media de pontos',
                  avgScore.toStringAsFixed(1),
                  Icons.score_outlined,
                ),
                _buildMetric(
                  'Aprovados',
                  totalPassed.toString(),
                  Icons.check_circle_outline,
                ),
                _buildMetric(
                  'Taxa de aprovacao',
                  '${passRate.toStringAsFixed(1)}%',
                  Icons.trending_up,
                ),
              ];

              if (constraints.maxWidth < 500) {
                return Wrap(
                  spacing: 8,
                  runSpacing: 12,
                  children: metrics,
                );
              }
              return Row(children: metrics);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value, IconData icon) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
