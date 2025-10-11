import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unicv_tech_mvp/models/exam_history.dart';
import 'package:unicv_tech_mvp/services/repositorie/exam_history_repository.dart';
import 'package:unicv_tech_mvp/ui/components/default_button_orange.dart';
import 'package:unicv_tech_mvp/viewmodels/exam_history_view_model.dart';

const _backgroundGradient = LinearGradient(
  colors: [
    Color(0xFFEAF5EF),
    Color(0xFFF7E9D2),
  ],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);

const _deepGreen = Color(0xFF2F4A2B);
const _accentGreen = Color(0xFF3A6B3F);
const _dividerColor = Color(0xFFD3D9CF);
const _cardFill = Color(0xFFEFF4EA);

class ExamHistoryAccordion extends StatelessWidget {
  final ExamHistoryRepository service;
  final Map<String, IconData> iconByKey;
  final void Function(SubjectExamHistory subject, ExamAttempt attempt)?
      onExpandExam;

  const ExamHistoryAccordion({
    super.key,
    required this.service,
    this.iconByKey = const {},
    this.onExpandExam,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: _backgroundGradient),
      child: SafeArea(
        top: true,
        bottom: false,
        child: ChangeNotifierProvider<ExamHistoryViewModel>(
          create: (_) => ExamHistoryViewModel(service: service)..load(),
          child: Consumer<ExamHistoryViewModel>(
            builder: (context, viewModel, _) {
              if (viewModel.loading && viewModel.subjects.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (viewModel.error != null && viewModel.subjects.isEmpty) {
                return _ErrorState(
                  message: 'Não foi possível carregar o histórico.',
                  onRetry: viewModel.load,
                );
              }

              if (viewModel.subjects.isEmpty) {
                return const _EmptyState();
              }

              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
                children: [
                  for (final subject in viewModel.subjects)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _SubjectHistoryTile(
                        subject: subject,
                        icon: iconByKey[subject.iconKey] ??
                            subject.fallbackIcon ??
                            Icons.book_outlined,
                        onExpandExam: onExpandExam,
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SubjectHistoryTile extends StatefulWidget {
  final SubjectExamHistory subject;
  final IconData icon;
  final void Function(SubjectExamHistory subject, ExamAttempt attempt)?
      onExpandExam;

  const _SubjectHistoryTile({
    required this.subject,
    required this.icon,
    this.onExpandExam,
  });

  @override
  State<_SubjectHistoryTile> createState() => _SubjectHistoryTileState();
}

class _SubjectHistoryTileState extends State<_SubjectHistoryTile>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;

  void _toggle() {
    setState(() {
      _expanded = !_expanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.85),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 10,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: _toggle,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                child: Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _dividerColor, width: 1.4),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        widget.icon,
                        size: 30,
                        color: _deepGreen,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Prova ',
                              style: TextStyle(
                                color: _deepGreen.withValues(alpha: 0.9),
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            TextSpan(
                              text: widget.subject.subjectName,
                              style: const TextStyle(
                                color: _deepGreen,
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 250),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: _accentGreen,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: _expanded
                  ? Container(
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Divider(
                              color: _dividerColor.withValues(alpha: 0.6),
                              thickness: 1),
                          const SizedBox(height: 16),
                          _SubjectTotals(subject: widget.subject),
                          const SizedBox(height: 20),
                          for (int i = 0;
                              i < widget.subject.attempts.length;
                              i++) ...[
                            if (i > 0)
                              Divider(
                                color: _dividerColor.withValues(alpha: 0.5),
                                height: 32,
                              ),
                            _AttemptBlock(
                              subject: widget.subject,
                              attempt: widget.subject.attempts[i],
                              onExpandExam: widget.onExpandExam,
                            ),
                          ],
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubjectTotals extends StatelessWidget {
  final SubjectExamHistory subject;

  const _SubjectTotals({required this.subject});

  @override
  Widget build(BuildContext context) {
    const labelStyle = TextStyle(
      color: Color(0xFF516448),
      fontSize: 14,
      fontWeight: FontWeight.w600,
    );

    const valueStyle = TextStyle(
      color: Color(0xFF8B9486),
      fontSize: 18,
      fontWeight: FontWeight.w700,
    );

    Widget buildRow(String label, int value) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: labelStyle),
            Text('$value', style: valueStyle),
          ],
        ),
      );
    }

    return Column(
      children: [
        buildRow('Total de Provas', subject.totalExams),
        buildRow('Total de Questões', subject.totalQuestions),
        buildRow('Total de Acertos', subject.totalCorrect),
      ],
    );
  }
}

class _AttemptBlock extends StatelessWidget {
  final SubjectExamHistory subject;
  final ExamAttempt attempt;
  final void Function(SubjectExamHistory subject, ExamAttempt attempt)?
      onExpandExam;

  const _AttemptBlock({
    required this.subject,
    required this.attempt,
    this.onExpandExam,
  });

  @override
  Widget build(BuildContext context) {
    const labelStyle = TextStyle(
      color: _deepGreen,
      fontSize: 13,
      fontWeight: FontWeight.w600,
    );

    const valueStyle = TextStyle(
      color: _deepGreen,
      fontSize: 15,
      fontWeight: FontWeight.w700,
    );

    return Container(
      decoration: BoxDecoration(
        color: _cardFill,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Dia', style: labelStyle),
                    const SizedBox(height: 4),
                    Text(_formatDate(attempt.date), style: valueStyle),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Tempo gasto', style: labelStyle),
                  const SizedBox(height: 4),
                  Text(_formatDuration(attempt.duration), style: valueStyle),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _QuestionTimeline(attempt: attempt),
          const SizedBox(height: 20),
          DefaultButtonOrange(
            texto: 'Expandir',
            onPressed: onExpandExam == null
                ? () {}
                : () => onExpandExam!(subject, attempt),
            altura: 52,
            largura: double.infinity,
            tipo: BotaoTipo.primario,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = (date.year % 100).toString().padLeft(2, '0');
    return '$day/$month/$year';
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes min $seconds seg';
  }
}

class _QuestionTimeline extends StatelessWidget {
  final ExamAttempt attempt;

  const _QuestionTimeline({required this.attempt});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      runAlignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 10,
      children: [
        for (final question in attempt.questions)
          _QuestionDot(
            number: question.number,
            outcome: question.outcome,
          ),
      ],
    );
  }
}

class _QuestionDot extends StatelessWidget {
  final int number;
  final QuestionOutcome outcome;

  const _QuestionDot({
    required this.number,
    required this.outcome,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _colorsForOutcome(outcome);

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.background,
        border: colors.borderColor == null
            ? null
            : Border.all(color: colors.borderColor!, width: 2),
      ),
      child: Center(
        child: Text(
          '$number',
          style: TextStyle(
            color: colors.textColor,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  _DotColors _colorsForOutcome(QuestionOutcome outcome) {
    switch (outcome) {
      case QuestionOutcome.correct:
        return const _DotColors(
          background: Color(0xFF3F8B3A),
          textColor: Colors.white,
        );
      case QuestionOutcome.incorrect:
        return const _DotColors(
          background: Color(0xFFD9503F),
          textColor: Colors.white,
        );
      case QuestionOutcome.unanswered:
        return _DotColors(
          background: Colors.transparent,
          textColor: _deepGreen.withValues(alpha: 0.6),
          borderColor: _deepGreen.withValues(alpha: 0.4),
        );
    }
  }
}

class _DotColors {
  final Color background;
  final Color textColor;
  final Color? borderColor;

  const _DotColors({
    required this.background,
    required this.textColor,
    this.borderColor,
  });
}

class _ErrorState extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          message,
          style: const TextStyle(color: Colors.redAccent),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        DefaultButtonOrange(
          texto: 'Tentar novamente',
          onPressed: onRetry,
          altura: 44,
          largura: 180,
          tipo: BotaoTipo.secundario,
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Center(
        child: Text(
          'Nenhum histórico de provas encontrado.',
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}