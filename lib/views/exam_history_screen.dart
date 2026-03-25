import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../ui/theme/app_color.dart';
import '../viewmodels/exam_history_view_model.dart';
import '../repositories/exam_attempt_repository_types.dart';

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
                        Row(
                          children: [
                            Icon(
                              Icons.emoji_events_outlined,
                              color: AppColors.green,
                              size: 28,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Historico de Provas',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryDark,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Acompanhe sua evolucao e conquistas',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.secondaryDark
                                .withAlpha((0.7 * 255).round()),
                            fontFamily: 'Poppins',
                          ),
                        ),
                        if (!viewModel.isLoading &&
                            viewModel.errorMessage == null &&
                            viewModel.attempts.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          _buildOverallStats(viewModel.attempts),
                        ],
                        const SizedBox(height: 24),
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

  Widget _buildOverallStats(List<ExamAttemptHistory> attempts) {
    final totalExams = attempts.length;
    final completedExams =
        attempts.where((a) => a.percentageScore != null).toList();
    final avgScore = completedExams.isNotEmpty
        ? completedExams.fold<double>(
                0, (sum, a) => sum + (a.percentageScore ?? 0)) /
            completedExams.length
        : 0.0;
    final approvedCount =
        completedExams.where((a) => (a.percentageScore ?? 0) >= 70).length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.green.withAlpha((0.12 * 255).round()),
            AppColors.green.withAlpha((0.05 * 255).round()),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.green.withAlpha((0.2 * 255).round()),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildMiniStat(
              Icons.assignment_turned_in_outlined,
              '$totalExams',
              'Provas',
              AppColors.green,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.green.withAlpha((0.2 * 255).round()),
          ),
          Expanded(
            child: _buildMiniStat(
              Icons.trending_up,
              '${avgScore.toStringAsFixed(0)}%',
              'Media',
              AppColors.orange,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.green.withAlpha((0.2 * 255).round()),
          ),
          Expanded(
            child: _buildMiniStat(
              Icons.check_circle_outline,
              '$approvedCount',
              'Aprovado',
              const Color(0xFF4CAF50),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(
      IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryDark,
            fontFamily: 'Poppins',
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppColors.secondaryDark.withAlpha((0.7 * 255).round()),
            fontFamily: 'Poppins',
          ),
        ),
      ],
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
              Icons.rocket_launch_outlined,
              size: 64,
              color: AppColors.green.withAlpha((0.5 * 255).round()),
            ),
            const SizedBox(height: 16),
            Text(
              'Comece sua jornada!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryDark,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Complete provas para desbloquear seu historico e acompanhar sua evolucao',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color:
                    AppColors.secondaryDark.withAlpha((0.7 * 255).round()),
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
        context.push('/history/${attempt.id}');
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
        : 'Data nao disponivel';

    final duration = attempt.durationSeconds != null
        ? _formatDuration(Duration(seconds: attempt.durationSeconds!))
        : 'N/A';

    final percentage = attempt.percentageScore ?? 0;
    final correctCount =
        ((percentage / 100 * attempt.questionCount).round());

    final score = attempt.totalScore != null
        ? attempt.totalScore!.toStringAsFixed(1)
        : 'N/A';

    final performanceColor = _getPerformanceColor(percentage);
    final performanceBadge = _getPerformanceBadge(percentage);
    final performanceIcon = _getPerformanceIcon(percentage);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white.withAlpha((0.75 * 255).round()),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: performanceColor.withAlpha((0.25 * 255).round()),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withAlpha((0.08 * 255).round()),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              children: [
                // Score circle
                _buildScoreCircle(percentage, performanceColor),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              courseName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryDark,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: performanceColor
                                  .withAlpha((0.12 * 255).round()),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  performanceIcon,
                                  size: 14,
                                  color: performanceColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  performanceBadge,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: performanceColor,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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
          ),
          const SizedBox(height: 14),
          // Progress bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$correctCount/${attempt.questionCount} acertos',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.secondaryDark,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    Text(
                      '${percentage.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: performanceColor,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor:
                        AppColors.primaryDark.withAlpha((0.06 * 255).round()),
                    valueColor:
                        AlwaysStoppedAnimation<Color>(performanceColor),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Stats row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatChip(
                    Icons.timer_outlined,
                    duration,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatChip(
                    Icons.question_answer_outlined,
                    '${attempt.questionCount} questoes',
                  ),
                ),
                if (attempt.totalScore != null) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatChip(
                      Icons.star_outline,
                      '$score pts',
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Bottom action
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primaryDark.withAlpha((0.03 * 255).round()),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Ver detalhes',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.green,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
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
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCircle(double percentage, Color color) {
    return SizedBox(
      width: 52,
      height: 52,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 52,
            height: 52,
            child: CircularProgressIndicator(
              value: percentage / 100,
              strokeWidth: 4,
              backgroundColor:
                  AppColors.primaryDark.withAlpha((0.08 * 255).round()),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          Text(
            '${percentage.toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryDark.withAlpha((0.04 * 255).round()),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 14,
            color: AppColors.secondaryDark.withAlpha((0.7 * 255).round()),
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.secondaryDark,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Color _getPerformanceColor(double percentage) {
    if (percentage >= 80) return const Color(0xFF4CAF50);
    if (percentage >= 70) return AppColors.green;
    if (percentage >= 50) return AppColors.orange;
    return AppColors.red;
  }

  String _getPerformanceBadge(double percentage) {
    if (percentage >= 90) return 'Excelente!';
    if (percentage >= 80) return 'Otimo!';
    if (percentage >= 70) return 'Aprovado';
    if (percentage >= 50) return 'Quase la!';
    return 'Tente de novo';
  }

  IconData _getPerformanceIcon(double percentage) {
    if (percentage >= 90) return Icons.emoji_events;
    if (percentage >= 80) return Icons.star;
    if (percentage >= 70) return Icons.check_circle;
    if (percentage >= 50) return Icons.trending_up;
    return Icons.refresh;
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
