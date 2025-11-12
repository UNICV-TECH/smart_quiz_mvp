import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../ui/theme/app_color.dart';
import '../viewmodels/exam_history_view_model.dart';
import '../repositories/exam_attempt_repository_types.dart';
import 'exam_detail_screen.dart';

class ExamHistoryScreen extends StatelessWidget {
  const ExamHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ExamHistoryViewModel()..loadHistory(),
      child: const _ExamHistoryViewBody(),
    );
  }
}

class _ExamHistoryViewBody extends StatelessWidget {
  const _ExamHistoryViewBody();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ExamHistoryViewModel>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: Stack(
        children: [
          // Imagem de fundo
          Positioned.fill(
            child: Image.asset(
              'assets/images/FundoWhiteHome.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            bottom: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32.0,
                    vertical: 40,
                  ),
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Histórico de Provas',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryDark,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Veja todas as suas provas realizadas',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.secondaryDark
                                .withAlpha((0.7 * 255).round()),
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 32),
                        if (viewModel.isLoading)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else if (viewModel.errorMessage != null)
                          _buildErrorCard(viewModel.errorMessage!)
                        else if (viewModel.attempts.isEmpty)
                          _buildEmptyState()
                        else
                          _buildHistoryList(context, viewModel.attempts),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.red.withAlpha((0.1 * 255).round()),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.red.withAlpha((0.3 * 255).round()),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: AppColors.red,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.red,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white.withAlpha((0.65 * 255).round()),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.primaryDark.withAlpha((0.08 * 255).round()),
          ),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 48,
        ),
        child: Column(
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 64,
              color: AppColors.secondaryDark.withAlpha((0.5 * 255).round()),
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhuma prova realizada ainda',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryDark,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Complete provas para ver seu histórico aqui',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.secondaryDark.withAlpha((0.7 * 255).round()),
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList(
      BuildContext context, List<ExamAttemptHistory> attempts) {
    return Column(
      children: attempts
          .map((attempt) => _buildHistoryCard(context, attempt))
          .toList(),
    );
  }

  Widget _buildHistoryCard(BuildContext context, ExamAttemptHistory attempt) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExamDetailScreen(attemptId: attempt.id),
          ),
        );
      },
      child: _buildHistoryCardContent(context, attempt),
    );
  }

  Widget _buildHistoryCardContent(
      BuildContext context, ExamAttemptHistory attempt) {
    final viewModel = context.watch<ExamHistoryViewModel>();
    final courseName = viewModel.courseNames[attempt.courseId] ?? 'Curso';

    final completedDate = attempt.completedAt != null
        ? _formatDateTime(attempt.completedAt!)
        : 'Data não disponível';

    final duration = attempt.durationSeconds != null
        ? _formatDuration(Duration(seconds: attempt.durationSeconds!))
        : 'N/A';

    final correctCount = attempt.percentageScore != null
        ? ((attempt.percentageScore! / 100 * attempt.questionCount).round())
        : 0;

    final score = attempt.totalScore != null
        ? attempt.totalScore!.toStringAsFixed(1)
        : 'N/A';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white.withAlpha((0.65 * 255).round()),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryDark.withAlpha((0.08 * 255).round()),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withAlpha((0.1 * 255).round()),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.green.withAlpha((0.15 * 255).round()),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.quiz_outlined,
                    color: AppColors.green,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        courseName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryDark,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        completedDate,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.secondaryDark
                              .withAlpha((0.7 * 255).round()),
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.question_answer_outlined,
                    label: 'Questões',
                    value: '${attempt.questionCount}',
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.timer_outlined,
                    label: 'Duração',
                    value: duration,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.check_circle_outline,
                    label: 'Nota',
                    value: '$correctCount/${attempt.questionCount}',
                  ),
                ),
              ],
            ),
            if (attempt.totalScore != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryDark.withAlpha((0.05 * 255).round()),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Pontuação: ',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.primaryDark
                            .withAlpha((0.7 * 255).round()),
                        fontFamily: 'Poppins',
                      ),
                    ),
                    Text(
                      score,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.green,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Toque para ver detalhes',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.green,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: AppColors.green,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.secondaryDark.withAlpha((0.7 * 255).round()),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryDark,
            fontFamily: 'Poppins',
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppColors.secondaryDark.withAlpha((0.6 * 255).round()),
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString();
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}
