import 'package:flutter/material.dart';
import 'package:unicv_tech_mvp/ui/components/default_button_arrow_back.dart';
import 'package:unicv_tech_mvp/ui/components/default_button_orange.dart';
import 'package:unicv_tech_mvp/ui/components/default_feedback_dialog.dart';
import 'package:unicv_tech_mvp/ui/components/default_scoreCard.dart';
import 'package:unicv_tech_mvp/ui/components/default_Logo.dart' as logo;
import 'package:unicv_tech_mvp/ui/components/feedback_severity.dart';
import 'package:unicv_tech_mvp/ui/components/result_question_tile.dart';
import 'package:unicv_tech_mvp/ui/theme/app_color.dart';
import 'package:unicv_tech_mvp/ui/theme/string_text.dart';

class ExamResultScreen extends StatefulWidget {
  const ExamResultScreen({
    super.key,
    required this.results,
  });

  final Map<String, dynamic> results;

  @override
  State<ExamResultScreen> createState() => _ExamResultScreenState();
}

class _ExamResultScreenState extends State<ExamResultScreen> {
  final ScrollController _scrollController = ScrollController();
  late final List<Map<String, dynamic>> _questionsBreakdown;
  late final List<GlobalKey> _tileKeys;

  int get _totalQuestions => widget.results['totalQuestions'] as int? ?? 0;
  int get _correctCount => widget.results['correctCount'] as int? ?? 0;
  double get _percentageScore =>
      (widget.results['percentageScore'] as num?)?.toDouble() ?? 0.0;
  int get _durationSeconds => widget.results['durationSeconds'] as int? ?? 0;

  int get _incorrectCount => _totalQuestions - _correctCount - _unansweredCount;

  int get _unansweredCount => _questionsBreakdown
      .where((q) => !(q['isAnswered'] as bool? ?? false))
      .length;

  @override
  void initState() {
    super.initState();
    _questionsBreakdown = List<Map<String, dynamic>>.from(
      (widget.results['questionsBreakdown'] as List?) ?? const [],
    );
    _tileKeys = List<GlobalKey>.generate(
      _questionsBreakdown.length,
      (_) => GlobalKey(),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  bool _canRetake() {
    final userId = widget.results['userId'];
    final examId = widget.results['examId'];
    final courseId = widget.results['courseId'];
    final questionCount = widget.results['questionCount'];

    return userId is String &&
        userId.isNotEmpty &&
        examId is String &&
        examId.isNotEmpty &&
        courseId is String &&
        courseId.isNotEmpty &&
        questionCount is int &&
        questionCount > 0;
  }

  Future<void> _handleRetake(BuildContext context) async {
    final userId = widget.results['userId'];
    final examId = widget.results['examId'];
    final courseId = widget.results['courseId'];
    final questionCount = widget.results['questionCount'];

    if (userId is! String ||
        examId is! String ||
        courseId is! String ||
        questionCount is! int) {
      await DefaultFeedbackDialog.show<void>(
        context,
        title: 'Não foi possível refazer',
        message: 'Não foi possível iniciar o simulado novamente.',
        severity: FeedbackSeverity.error,
      );
      return;
    }

    if (!mounted) return;

    await Navigator.pushReplacementNamed(
      context,
      '/exam',
      arguments: {
        'userId': userId,
        'examId': examId,
        'courseId': courseId,
        'questionCount': questionCount,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE8F5ED),
              Color(0xFFE8F5ED),
              Color(0xFFF4F9F1),
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Row(
                  children: [
                    DefaultButtonArrowBack(
                      onPressed: () => Navigator.pop(context, widget.results),
                    ),
                    Expanded(
                      child: Center(
                        child: logo.AppLogoWidget.asset(
                          size: logo.AppLogoSize.small,
                          logoPath: 'assets/images/logo_color.png',
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      AppText(
                        'Resultado do simulado',
                        style: AppTextStyle.titleSmall,
                        color: AppColors.primaryDark,
                      ),
                      SizedBox(height: 4),
                      AppText(
                        'Visualize seu desempenho e revise as questões',
                        style: AppTextStyle.subtitleMedium,
                        color: AppColors.secondaryDark,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _SummaryCard(
                  percentageScore: _percentageScore,
                  correctCount: _correctCount,
                  incorrectCount: _incorrectCount,
                  unansweredCount: _unansweredCount,
                  totalQuestions: _totalQuestions,
                  durationLabel: _formatDuration(_durationSeconds),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _questionsBreakdown.isEmpty
                      ? const Center(
                          child: Text(
                            'Nenhuma questão registrada para este simulado.',
                            style: TextStyle(color: AppColors.secondaryDark),
                          ),
                        )
                      : ListView.separated(
                          controller: _scrollController,
                          padding: const EdgeInsets.only(bottom: 24, top: 8),
                          itemCount: _questionsBreakdown.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = _questionsBreakdown[index];
                            final isCorrect =
                                item['isCorrect'] as bool? ?? false;
                            final isAnswered =
                                item['isAnswered'] as bool? ?? false;
                            return Container(
                              key: _tileKeys[index],
                              child: ResultQuestionTile(
                                questionNumber: index + 1,
                                enunciation:
                                    item['enunciation'] as String? ?? '',
                                selectedChoiceKey:
                                    item['selectedChoiceKey'] as String?,
                                selectedChoiceText:
                                    item['selectedChoiceText'] as String?,
                                correctChoiceKey:
                                    item['correctChoiceKey'] as String? ?? '',
                                correctChoiceText:
                                    item['correctChoiceText'] as String? ?? '',
                                isCorrect: isCorrect,
                                isAnswered: isAnswered,
                              ),
                            );
                          },
                        ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha((0.92 * 255).round()),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 20,
                      offset: Offset(0, -6),
                    ),
                  ],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DefaultButtonOrange(
                      texto: 'Refazer prova',
                      onPressed:
                          _canRetake() ? () => _handleRetake(context) : null,
                      largura: double.infinity,
                      altura: 54,
                      tipo: _canRetake()
                          ? BotaoTipo.primario
                          : BotaoTipo.desabilitado,
                    ),
                    const SizedBox(height: 12),
                    DefaultButtonOrange(
                      texto: 'Voltar ao início',
                      onPressed: () {
                        Navigator.popUntil(
                          context,
                          (route) =>
                              route.settings.name == '/main' || route.isFirst,
                        );
                      },
                      largura: double.infinity,
                      altura: 54,
                      tipo: BotaoTipo.secundario,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.percentageScore,
    required this.correctCount,
    required this.incorrectCount,
    required this.unansweredCount,
    required this.totalQuestions,
    required this.durationLabel,
  });

  final double percentageScore;
  final int correctCount;
  final int incorrectCount;
  final int unansweredCount;
  final int totalQuestions;
  final String durationLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E7DE), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 18,
            offset: Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF6AB37E), Color(0xFF3F8B3A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '${percentageScore.toStringAsFixed(0)}%',
                      maxLines: 1,
                      softWrap: false,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Você acertou $correctCount de $totalQuestions questões',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tempo total: $durationLabel',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.secondaryDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: DefaultScorecard(
                  icon: Icons.check_circle_outline,
                  score: correctCount,
                  iconColor: const Color(0xFF3F8B3A),
                  scoreColor: const Color(0xFF3F8B3A),
                  backgroundColor: const Color(0xFFE5F4E3),
                  height: 60,
                  iconSize: 24,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              Expanded(
                child: DefaultScorecard(
                  icon: Icons.cancel_outlined,
                  score: incorrectCount,
                  iconColor: const Color(0xFFD9503F),
                  scoreColor: const Color(0xFFD9503F),
                  backgroundColor: const Color(0xFFF9E5E3),
                  height: 60,
                  iconSize: 24,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              Expanded(
                child: DefaultScorecard(
                  icon: Icons.help_outline,
                  score: unansweredCount,
                  iconColor: AppColors.secondaryDark,
                  scoreColor: AppColors.secondaryDark,
                  backgroundColor: const Color(0xFFF1F3F0),
                  height: 60,
                  iconSize: 24,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
