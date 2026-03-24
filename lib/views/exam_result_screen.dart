import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unicv_tech_mvp/models/gamification_level.dart';
import 'package:unicv_tech_mvp/services/gamification_calculator.dart';
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
  int get _durationSeconds {
    final duration = widget.results['durationSeconds'];
    if (duration == null) return 0;
    if (duration is int) return duration;
    if (duration is double) return duration.round();
    if (duration is num) return duration.toInt();
    return 0;
  }

  int get _incorrectCount => _totalQuestions - _correctCount - _unansweredCount;

  int get _unansweredCount => _questionsBreakdown
      .where((q) => !(q['isAnswered'] as bool? ?? false))
      .length;

  // Gamification getters
  bool get _gamificationSaved =>
      widget.results['gamificationSaved'] as bool? ?? false;
  double get _gamificationBasePoints =>
      (widget.results['gamificationBasePoints'] as num?)?.toDouble() ?? 0;
  double get _gamificationTimeBonus =>
      (widget.results['gamificationTimeBonus'] as num?)?.toDouble() ?? 0;
  double get _gamificationTotalPoints =>
      (widget.results['gamificationTotalPoints'] as num?)?.toDouble() ?? 0;
  bool get _gamificationHasTimeBonus =>
      widget.results['gamificationHasTimeBonus'] as bool? ?? false;
  double get _gamificationAccumulatedPoints =>
      (widget.results['gamificationAccumulatedPoints'] as num?)?.toDouble() ??
      0;
  double get _gamificationPreviousPoints =>
      (widget.results['gamificationPreviousPoints'] as num?)?.toDouble() ?? 0;
  bool get _gamificationDidImprove =>
      widget.results['gamificationDidImprove'] as bool? ?? false;

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

    // Debug: verificar se o tempo está sendo recebido
    debugPrint('=== RESULTADO DA PROVA ===');
    debugPrint('durationSeconds raw: ${widget.results['durationSeconds']}');
    debugPrint('durationSeconds processed: $_durationSeconds');
    debugPrint('duration formatted: ${_formatDuration(_durationSeconds)}');
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _formatDuration(int totalSeconds) {
    if (totalSeconds <= 0) return '00:00';
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

    debugPrint('=== REFAZER PROVA ===');
    debugPrint('examId: $examId');
    debugPrint('userId: $userId');
    debugPrint('courseId: $courseId');
    debugPrint('questionCount: $questionCount');
    debugPrint('isRetake: true');

    // Obter os IDs das questões da prova anterior
    final previousQuestionIds = widget.results['questionIds'] as List<dynamic>?;
    final questionIdsList =
        previousQuestionIds?.map((id) => id.toString()).toList();
    debugPrint('Previous question IDs: $questionIdsList');

    context.pushReplacement(
      '/exam/$examId?courseId=${Uri.encodeComponent(courseId)}&questionCount=$questionCount&isRetake=true',
      extra: {'previousQuestionIds': questionIdsList},
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
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Row(
                    children: [
                      DefaultButtonArrowBack(
                        onPressed: () => context.go('/home'),
                      ),
                      Expanded(
                        child: Center(
                          child: logo.AppLogoWidget.asset(
                            size: logo.AppLogoSize.small,
                            logoPath: 'assets/images/SmartQuiz.png',
                          ),
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
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
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              SliverToBoxAdapter(
                child: Padding(
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
              ),
              // Gamification: Level Up Card
              if (_gamificationSaved) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _LevelUpCard(
                      previousPoints: _gamificationPreviousPoints,
                      accumulatedPoints: _gamificationAccumulatedPoints,
                    ),
                  ),
                ),
              ],
              // Gamification: Feedback Card
              if (_gamificationSaved || _gamificationTotalPoints > 0) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: _GamificationFeedbackCard(
                      basePoints: _gamificationBasePoints,
                      timeBonus: _gamificationTimeBonus,
                      totalPoints: _gamificationTotalPoints,
                      hasTimeBonus: _gamificationHasTimeBonus,
                      accumulatedPoints: _gamificationAccumulatedPoints,
                      percentageScore: _percentageScore,
                      didImprove: _gamificationDidImprove,
                      gamificationSaved: _gamificationSaved,
                      questionCount: _totalQuestions,
                    ),
                  ),
                ),
              ],
              const SliverToBoxAdapter(child: SizedBox(height: 8)),
              if (_questionsBreakdown.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: const Center(
                      child: Text(
                        'Nenhuma questão registrada para este simulado.',
                        style: TextStyle(color: AppColors.secondaryDark),
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = _questionsBreakdown[index];
                        final isCorrect = item['isCorrect'] as bool? ?? false;
                        final isAnswered =
                            item['isAnswered'] as bool? ?? false;
                        final isLast =
                            index == _questionsBreakdown.length - 1;
                        return Padding(
                          padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
                          child: Container(
                            key: _tileKeys[index],
                            child: ResultQuestionTile(
                              questionNumber: index + 1,
                              enunciation: item['enunciation'] as String? ?? '',
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
                          ),
                        );
                      },
                      childCount: _questionsBreakdown.length,
                    ),
                  ),
                ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                  child: Row(
                    children: [
                      Expanded(
                        child: DefaultButtonOrange(
                          texto: 'Voltar ao início',
                          onPressed: () {
                            context.go('/home');
                          },
                          largura: double.infinity,
                          altura: 54,
                          tipo: BotaoTipo.secundario,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DefaultButtonOrange(
                          texto: 'Refazer prova',
                          onPressed: _canRetake()
                              ? () => _handleRetake(context)
                              : null,
                          largura: double.infinity,
                          altura: 54,
                          tipo: _canRetake()
                              ? BotaoTipo.primario
                              : BotaoTipo.desabilitado,
                        ),
                      ),
                    ],
                  ),
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

class _LevelUpCard extends StatefulWidget {
  const _LevelUpCard({
    required this.previousPoints,
    required this.accumulatedPoints,
  });

  final double previousPoints;
  final double accumulatedPoints;

  @override
  State<_LevelUpCard> createState() => _LevelUpCardState();
}

class _LevelUpCardState extends State<_LevelUpCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final GamificationLevel _previousLevel;
  late final GamificationLevel _currentLevel;

  @override
  void initState() {
    super.initState();
    _previousLevel = GamificationLevel.fromPoints(widget.previousPoints);
    _currentLevel = GamificationLevel.fromPoints(widget.accumulatedPoints);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    if (_previousLevel != _currentLevel) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_previousLevel == _currentLevel) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          final value = _scaleAnimation.value;
          return Transform.scale(
            scale: value,
            child: Opacity(
              opacity: value.clamp(0.0, 1.0),
              child: child,
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFF8E1), Color(0xFFFFF3E0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFFD54F), width: 2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x30FFD54F),
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              const Icon(
                Icons.emoji_events,
                color: Color(0xFFFFA000),
                size: 52,
              ),
              const SizedBox(height: 12),
              Text(
                'Parabéns! Você alcançou o nível ${_currentLevel.label}!',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5D4037),
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x30FFD54F),
                      blurRadius: 16,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Image.asset(
                  _currentLevel.medalAsset,
                  width: 120,
                  height: 120,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.military_tech,
                    size: 120,
                    color: Color(0xFFFFA000),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GamificationFeedbackCard extends StatelessWidget {
  const _GamificationFeedbackCard({
    required this.basePoints,
    required this.timeBonus,
    required this.totalPoints,
    required this.hasTimeBonus,
    required this.accumulatedPoints,
    required this.percentageScore,
    required this.didImprove,
    required this.gamificationSaved,
    required this.questionCount,
  });

  final double basePoints;
  final double timeBonus;
  final double totalPoints;
  final bool hasTimeBonus;
  final double accumulatedPoints;
  final double percentageScore;
  final bool didImprove;
  final bool gamificationSaved;
  final int questionCount;

  @override
  Widget build(BuildContext context) {
    if (!gamificationSaved && totalPoints <= 0) return const SizedBox.shrink();

    final level = GamificationLevel.fromPoints(accumulatedPoints);
    final message = GamificationCalculator.getMotivationalMessage(
      percentageScore: percentageScore,
      hasTimeBonus: hasTimeBonus,
      didImprove: didImprove,
      gamificationSaved: gamificationSaved,
    );

    final recordTimeMinutes =
        GamificationCalculator.recordTimeSeconds(questionCount) / 60;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5ED),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFC8E6C9), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Motivational message
          Row(
            children: [
              const Icon(Icons.star, color: Color(0xFFFFA000), size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E7D32),
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Points breakdown (only show when save succeeded)
          if (didImprove && gamificationSaved) ...[
            _buildPointRow(
              'Pontos base',
              '+${basePoints.toStringAsFixed(1)} pts',
              Icons.check_circle_outline,
            ),
            if (hasTimeBonus)
              _buildPointRow(
                'Bônus de tempo',
                '+${timeBonus.toStringAsFixed(0)} pts!',
                Icons.timer,
                highlight: true,
              ),
            if (!hasTimeBonus && totalPoints > 0 && questionCount > 0)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Complete em menos de ${recordTimeMinutes.toStringAsFixed(0)} min para ganhar bônus!',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF558B2F),
                    fontFamily: 'Poppins',
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            const Divider(height: 20, color: Color(0xFFC8E6C9)),
            _buildPointRow(
              'Total ganho',
              '+${totalPoints.toStringAsFixed(1)} pts',
              Icons.emoji_events,
              bold: true,
            ),
          ],

          // Level progress (only if saved)
          if (gamificationSaved) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x18000000),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    level.medalAsset,
                    width: 56,
                    height: 56,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.military_tech,
                      size: 56,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        level.label,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2E7D32),
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        level.pointsLabel(accumulatedPoints),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF558B2F),
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: level.progressInLevel(accumulatedPoints),
                minHeight: 10,
                backgroundColor: const Color(0xFFC8E6C9),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.green),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPointRow(
    String label,
    String value,
    IconData icon, {
    bool highlight = false,
    bool bold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color:
                highlight ? const Color(0xFFFFA000) : const Color(0xFF4CAF50),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
                color: const Color(0xFF2E7D32),
                fontFamily: 'Poppins',
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: highlight
                  ? const Color(0xFFFFA000)
                  : const Color(0xFF2E7D32),
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}
