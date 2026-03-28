import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unicv_tech_mvp/models/gamification_level.dart';
import 'package:unicv_tech_mvp/services/gamification_calculator.dart';
import 'package:unicv_tech_mvp/ui/components/default_button_arrow_back.dart';
import 'package:unicv_tech_mvp/ui/components/default_button_orange.dart';
import 'package:unicv_tech_mvp/ui/components/default_feedback_dialog.dart';
import 'package:unicv_tech_mvp/ui/components/default_scoreCard.dart';
import 'package:unicv_tech_mvp/ui/components/feedback_severity.dart';
import 'package:unicv_tech_mvp/ui/components/result_question_tile.dart';
import 'package:unicv_tech_mvp/ui/theme/app_color.dart';

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
  late final ConfettiController _confettiController;
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
  bool get _isRetake => widget.results['isRetake'] as bool? ?? false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: _percentageScore >= 70
          ? const Duration(seconds: 3)
          : const Duration(seconds: 1),
    );
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

    // Disparar confete apos build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _confettiController.play();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
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
      backgroundColor: AppColors.pageBg,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                // Header verde compacto
                SliverToBoxAdapter(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.headerGradientStart,
                          AppColors.headerGradientMid,
                          AppColors.headerGradientEnd,
                        ],
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(32),
                        bottomRight: Radius.circular(32),
                      ),
                    ),
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 8, 8, 24),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                DefaultButtonArrowBack(
                                  onPressed: () => context.go('/home'),
                                  iconColor: Colors.white,
                                ),
                                const Spacer(),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: _SummaryCard(
                                percentageScore: _percentageScore,
                                correctCount: _correctCount,
                                incorrectCount: _incorrectCount,
                                unansweredCount: _unansweredCount,
                                totalQuestions: _totalQuestions,
                                durationLabel: _formatDuration(_durationSeconds),
                              ),
                            ),
                          ],
                        ),
                      ),
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
                      isRetake: _isRetake,
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
                        final isAnswered = item['isAnswered'] as bool? ?? false;
                        final isLast = index == _questionsBreakdown.length - 1;
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
          // Confete overlay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              numberOfParticles: _percentageScore >= 70 ? 30 : 10,
              maxBlastForce: _percentageScore >= 70 ? 25 : 12,
              minBlastForce: 5,
              emissionFrequency: 0.05,
              gravity: 0.15,
              colors: _percentageScore >= 70
                  ? const [
                      AppColors.gold,
                      AppColors.goldDark,
                      AppColors.green1,
                      AppColors.orangeDeep,
                      AppColors.gamificationDark,
                      AppColors.goldYellow,
                    ]
                  : const [
                      AppColors.gamificationLight,
                      AppColors.gamificationLighter,
                      AppColors.greyShade400,
                    ],
            ),
          ),
        ],
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
    return Column(
      children: [
        // Porcentagem e frases centralizadas
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.2),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.5),
              width: 2,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            '${percentageScore.toStringAsFixed(0)}%',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Poppins',
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Voce acertou $correctCount de $totalQuestions questoes',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Tempo total: $durationLabel',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: Colors.white.withValues(alpha: 0.7),
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: DefaultScorecard(
                  icon: Icons.check_circle_outline,
                  score: correctCount,
                  iconColor: AppColors.scoreCorrect,
                  scoreColor: AppColors.scoreCorrect,
                  backgroundColor: AppColors.scoreBgCorrect,
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
                  iconColor: AppColors.scoreIncorrect,
                  scoreColor: AppColors.scoreIncorrect,
                  backgroundColor: AppColors.scoreBgIncorrect,
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
                  backgroundColor: AppColors.scoreBgUnanswered,
                  height: 60,
                  iconSize: 24,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
            ],
          ),
        ],
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
              colors: [AppColors.goldBgStart, AppColors.goldBgEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.goldLight, width: 2),
            boxShadow: const [
              BoxShadow(
                color: AppColors.goldShadow,
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              const Icon(
                Icons.emoji_events,
                color: AppColors.goldDark,
                size: 52,
              ),
              const SizedBox(height: 12),
              Text(
                'Parabéns! Você alcançou o nível ${_currentLevel.label}!',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.levelUpBrown,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.goldShadow,
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
                    color: AppColors.goldDark,
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
    this.isRetake = false,
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
  final bool isRetake;

  @override
  Widget build(BuildContext context) {
    if (!gamificationSaved && totalPoints <= 0) return const SizedBox.shrink();

    final level = GamificationLevel.fromPoints(accumulatedPoints);
    final message = GamificationCalculator.getMotivationalMessage(
      percentageScore: percentageScore,
      hasTimeBonus: hasTimeBonus,
      didImprove: didImprove,
      gamificationSaved: gamificationSaved,
      isRetake: isRetake,
    );

    final recordTimeMinutes =
        GamificationCalculator.recordTimeSeconds(questionCount) / 60;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgLightGreen,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gamificationBorder, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Motivational message
          Row(
            children: [
              const Icon(Icons.star, color: AppColors.goldDark, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gamificationDark,
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
                    color: AppColors.gamificationOlive,
                    fontFamily: 'Poppins',
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            const Divider(height: 20, color: AppColors.gamificationBorder),
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
                        color: AppColors.shadowDark,
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
                      color: AppColors.green1,
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
                          color: AppColors.gamificationDark,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        level.pointsLabel(accumulatedPoints),
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.gamificationOlive,
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
                backgroundColor: AppColors.gamificationBorder,
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
                highlight ? AppColors.goldDark : AppColors.green1,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
                color: AppColors.gamificationDark,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color:
                  highlight ? AppColors.goldDark : AppColors.gamificationDark,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}
