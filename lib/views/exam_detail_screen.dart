import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../ui/theme/app_color.dart';
import '../viewmodels/exam_detail_view_model.dart';
import '../repositories/question_repository_types.dart';
import '../repositories/exam_attempt_repository_types.dart';
import '../models/user_response.dart' as models;

class ExamDetailScreen extends StatelessWidget {
  final String attemptId;

  const ExamDetailScreen({
    super.key,
    required this.attemptId,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ExamDetailViewModel()..loadExamDetails(attemptId),
      child: const _ExamDetailViewBody(),
    );
  }
}

class _ExamDetailViewBody extends StatelessWidget {
  const _ExamDetailViewBody();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ExamDetailViewModel>();

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
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: _buildContent(context, viewModel),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white.withAlpha((0.9 * 255).round()),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withAlpha((0.1 * 255).round()),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            color: AppColors.primaryDark,
            onPressed: () => context.pop(),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Detalhes da Prova',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDark,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, ExamDetailViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (viewModel.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            viewModel.errorMessage!,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.red,
              fontFamily: 'Poppins',
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (viewModel.questions.isEmpty) {
      return const Center(
        child: Text(
          'Nenhuma questão encontrada',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: Colors.black54,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (viewModel.attempt != null)
            _buildPerformanceCard(viewModel.attempt!, viewModel),
          const SizedBox(height: 16),
          if (viewModel.attempt != null)
            _buildStatsRow(viewModel.attempt!, viewModel),
          const SizedBox(height: 24),
          Row(
            children: [
              Icon(
                Icons.list_alt,
                color: AppColors.green,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                'Questões',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDark,
                  fontFamily: 'Poppins',
                ),
              ),
              const Spacer(),
              _buildQuestionSummaryChips(viewModel),
            ],
          ),
          const SizedBox(height: 16),
          ...viewModel.questions.asMap().entries.map((entry) {
            final index = entry.key;
            final question = entry.value;
            final response = viewModel.getResponseForQuestion(question.id);
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _QuestionAccordion(
                questionNumber: index + 1,
                question: question,
                userResponse: response,
              ),
            );
          }),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildPerformanceCard(
      ExamAttemptHistory attempt, ExamDetailViewModel viewModel) {
    final correctCount = viewModel.correctAnswersCount;
    final totalQuestions = attempt.questionCount;
    final percentage = attempt.percentageScore ?? 0;
    final performanceColor = _getPerformanceColor(percentage);
    final performanceMessage = _getMotivationalMessage(percentage);
    final performanceIcon = _getPerformanceIcon(percentage);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            performanceColor.withAlpha((0.08 * 255).round()),
            AppColors.white.withAlpha((0.85 * 255).round()),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: performanceColor.withAlpha((0.2 * 255).round()),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: performanceColor.withAlpha((0.1 * 255).round()),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Score ring
              _PerformanceRing(
                percentage: percentage,
                color: performanceColor,
                size: 80,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        if (attempt.isRetake)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.indigo
                                  .withAlpha((0.12 * 255).round()),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.replay,
                                  size: 12,
                                  color: AppColors.indigo,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  'Prova refeita',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.indigo,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ],
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
                                _getPerformanceBadge(percentage),
                                style: TextStyle(
                                  fontSize: 12,
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
                    const SizedBox(height: 8),
                    Text(
                      '$correctCount de $totalQuestions acertos',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDark,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      performanceMessage,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.secondaryDark
                            .withAlpha((0.8 * 255).round()),
                        fontFamily: 'Poppins',
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Correct/Incorrect bar
          _buildResultBar(correctCount, totalQuestions, performanceColor),
        ],
      ),
    );
  }

  Widget _buildResultBar(
      int correctCount, int totalQuestions, Color performanceColor) {
    final incorrectCount = totalQuestions - correctCount;
    return Column(
      children: [
        Row(
          children: [
            _buildBarLegend(
                Icons.check_circle, 'Corretas', correctCount, performanceColor),
            const SizedBox(width: 16),
            _buildBarLegend(
                Icons.cancel, 'Incorretas', incorrectCount, AppColors.red),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            height: 10,
            child: Row(
              children: [
                if (correctCount > 0)
                  Expanded(
                    flex: correctCount,
                    child: Container(color: performanceColor),
                  ),
                if (incorrectCount > 0)
                  Expanded(
                    flex: incorrectCount,
                    child: Container(
                        color: AppColors.red.withAlpha((0.6 * 255).round())),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBarLegend(
      IconData icon, String label, int count, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          '$count $label',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.secondaryDark,
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(
      ExamAttemptHistory attempt, ExamDetailViewModel viewModel) {
    final duration = attempt.durationSeconds != null
        ? _formatDuration(Duration(seconds: attempt.durationSeconds!))
        : 'N/A';
    final score = attempt.totalScore != null
        ? attempt.totalScore!.toStringAsFixed(1)
        : 'N/A';

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            Icons.timer_outlined,
            'Duração',
            duration,
            AppColors.indigo,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatCard(
            Icons.question_answer_outlined,
            'Questões',
            '${attempt.questionCount}',
            AppColors.orange,
          ),
        ),
        if (attempt.totalScore != null) ...[
          const SizedBox(width: 10),
          Expanded(
            child: _buildStatCard(
              Icons.star_outline,
              'Pontos',
              score,
              AppColors.green,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatCard(
      IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.white.withAlpha((0.75 * 255).round()),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withAlpha((0.15 * 255).round()),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
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
      ),
    );
  }

  Widget _buildQuestionSummaryChips(ExamDetailViewModel viewModel) {
    final correct = viewModel.correctAnswersCount;
    final total = viewModel.questions.length;
    final incorrect = total - correct;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50).withAlpha((0.12 * 255).round()),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$correct',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4CAF50),
              fontFamily: 'Poppins',
            ),
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.red.withAlpha((0.12 * 255).round()),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$incorrect',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.red,
              fontFamily: 'Poppins',
            ),
          ),
        ),
      ],
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
    if (percentage >= 80) return 'Ótimo!';
    if (percentage >= 70) return 'Aprovado';
    if (percentage >= 50) return 'Quase lá!';
    return 'Tente de novo';
  }

  IconData _getPerformanceIcon(double percentage) {
    if (percentage >= 90) return Icons.emoji_events;
    if (percentage >= 80) return Icons.star;
    if (percentage >= 70) return Icons.check_circle;
    if (percentage >= 50) return Icons.trending_up;
    return Icons.refresh;
  }

  String _getMotivationalMessage(double percentage) {
    if (percentage >= 90) return 'Performance incrível! Continue assim!';
    if (percentage >= 80) return 'Você está arrasando nos estudos!';
    if (percentage >= 70) return 'Bom trabalho! Você foi aprovado!';
    if (percentage >= 50) return 'Quase lá! Um pouco mais de estudo!';
    return 'Não desista! A prática leva à perfeição!';
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

class _PerformanceRing extends StatelessWidget {
  final double percentage;
  final Color color;
  final double size;

  const _PerformanceRing({
    required this.percentage,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
          percentage: percentage,
          color: color,
          backgroundColor:
              AppColors.primaryDark.withAlpha((0.08 * 255).round()),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${percentage.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: size * 0.22,
                  fontWeight: FontWeight.w800,
                  color: color,
                  fontFamily: 'Poppins',
                  height: 1,
                ),
              ),
              Text(
                'nota',
                style: TextStyle(
                  fontSize: size * 0.12,
                  color:
                      AppColors.secondaryDark.withAlpha((0.6 * 255).round()),
                  fontFamily: 'Poppins',
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double percentage;
  final Color color;
  final Color backgroundColor;

  _RingPainter({
    required this.percentage,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    const strokeWidth = 6.0;

    // Background ring
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress ring
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * (percentage / 100);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.percentage != percentage || oldDelegate.color != color;
  }
}

class _QuestionAccordion extends StatefulWidget {
  final int questionNumber;
  final Question question;
  final models.UserResponse? userResponse;

  const _QuestionAccordion({
    required this.questionNumber,
    required this.question,
    this.userResponse,
  });

  @override
  State<_QuestionAccordion> createState() => _QuestionAccordionState();
}

class _QuestionAccordionState extends State<_QuestionAccordion> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isCorrect = widget.userResponse?.isCorrect ?? false;
    final selectedChoiceKey = widget.userResponse?.selectedChoiceKey;
    final correctChoice = widget.question.answerChoices.firstWhere(
        (choice) => choice.isCorrect,
        orElse: () => widget.question.answerChoices.first);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white.withAlpha((0.85 * 255).round()),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCorrect
              ? AppColors.green.withAlpha((0.3 * 255).round())
              : AppColors.red.withAlpha((0.3 * 255).round()),
          width: 2,
        ),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        initiallyExpanded: false,
        onExpansionChanged: (expanded) {
          setState(() {
            _isExpanded = expanded;
          });
        },
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isCorrect
                ? AppColors.green.withAlpha((0.15 * 255).round())
                : AppColors.red.withAlpha((0.15 * 255).round()),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              isCorrect ? Icons.check : Icons.close,
              color: isCorrect ? AppColors.green : AppColors.red,
              size: 24,
            ),
          ),
        ),
        title: Text(
          'Questão ${widget.questionNumber}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryDark,
            fontFamily: 'Poppins',
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                size: 16,
                color: isCorrect ? AppColors.green : AppColors.red,
              ),
              const SizedBox(width: 4),
              Text(
                isCorrect ? 'Correta' : 'Incorreta',
                style: TextStyle(
                  fontSize: 13,
                  color: isCorrect ? AppColors.green : AppColors.red,
                  fontFamily: 'Poppins',
                ),
              ),
              if (selectedChoiceKey != null) ...[
                const SizedBox(width: 8),
                Text(
                  '• Você marcou: $selectedChoiceKey',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.secondaryDark
                        .withAlpha((0.7 * 255).round()),
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ],
          ),
        ),
        trailing: Icon(
          _isExpanded ? Icons.expand_less : Icons.expand_more,
          color: AppColors.primaryDark,
        ),
        children: [
          // Textos de apoio
          if (widget.question.supportingTexts.isNotEmpty) ...[
            ...widget.question.supportingTexts
                .map((supportingText) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryDark
                            .withAlpha((0.05 * 255).round()),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primaryDark
                              .withAlpha((0.1 * 255).round()),
                        ),
                      ),
                      child: Text(
                        supportingText.content,
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.primaryDark,
                          fontFamily: 'Poppins',
                          height: 1.5,
                        ),
                      ),
                    )),
            const SizedBox(height: 12),
          ],
          // Enunciado
          if (widget.question.enunciation.isNotEmpty) ...[
            Text(
              widget.question.enunciation,
              textAlign: TextAlign.justify,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.primaryDark,
                fontFamily: 'Poppins',
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
          ],
          // Pergunta
          if (widget.question.questionText.isNotEmpty) ...[
            Text(
              widget.question.questionText,
              textAlign: TextAlign.justify,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.primaryDark,
                fontFamily: 'Poppins',
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
          ],
          // Opcoes
          ...widget.question.answerChoices.map((choice) {
            final isSelected = selectedChoiceKey == choice.choiceKey;
            final isCorrectChoice = choice.isCorrect;

            Color backgroundColor = Colors.transparent;
            Color borderColor;
            IconData? icon;
            Color? iconColor;

            if (isCorrectChoice) {
              borderColor = AppColors.green;
              icon = Icons.check_circle;
              iconColor = AppColors.green;
            } else if (isSelected) {
              borderColor = AppColors.red;
              icon = Icons.cancel;
              iconColor = AppColors.red;
            } else {
              borderColor =
                  AppColors.primaryDark.withAlpha((0.2 * 255).round());
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: borderColor,
                  width: isSelected || isCorrectChoice ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: (isSelected || isCorrectChoice)
                          ? borderColor.withAlpha((0.2 * 255).round())
                          : Colors.transparent,
                      shape: BoxShape.circle,
                      border: (isSelected || isCorrectChoice)
                          ? null
                          : Border.all(
                              color: borderColor,
                              width: 1,
                            ),
                    ),
                    child: Center(
                      child: Text(
                        choice.choiceKey,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: borderColor,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      choice.choiceText,
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.primaryDark,
                        fontFamily: 'Poppins',
                        height: 1.4,
                      ),
                    ),
                  ),
                  if (icon != null) ...[
                    const SizedBox(width: 8),
                    Icon(
                      icon,
                      color: iconColor,
                      size: 20,
                    ),
                  ],
                ],
              ),
            );
          }),
          const SizedBox(height: 8),
          // Legenda
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isCorrect
                  ? AppColors.green.withAlpha((0.06 * 255).round())
                  : AppColors.red.withAlpha((0.06 * 255).round()),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isCorrect
                    ? AppColors.green.withAlpha((0.15 * 255).round())
                    : AppColors.red.withAlpha((0.15 * 255).round()),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isCorrect ? Icons.check_circle : Icons.info_outline,
                  size: 16,
                  color: isCorrect ? AppColors.green : AppColors.red,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isCorrect
                        ? 'Você acertou esta questão!'
                        : 'Resposta correta: ${correctChoice.choiceKey}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isCorrect ? AppColors.green : AppColors.red,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
