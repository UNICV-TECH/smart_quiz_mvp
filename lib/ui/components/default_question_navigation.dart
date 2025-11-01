import 'package:flutter/material.dart';
import '../theme/app_color.dart';

@Preview(name: 'Navegação de Questões')
Widget questionNavigationPreview() {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(20.0),
      child: QuestionNavigation(
        totalQuestions: 18,
        currentQuestion: 6,
        onQuestionSelected: (questionNumber) {
          debugPrint('Questão selecionada: $questionNumber');
        },
        answeredQuestions: const {1, 2, 3, 5, 6},
      ),
    ),
  );
}

class Preview {
  const Preview({required String name});
}

class QuestionNavigation extends StatelessWidget {
  const QuestionNavigation({
    super.key,
    required this.totalQuestions,
    required this.currentQuestion,
    required this.onQuestionSelected,
    required this.answeredQuestions,
  });

  final int totalQuestions;
  final int currentQuestion;
  final Function(int) onQuestionSelected;
  final Set<int> answeredQuestions;

  static double indicatorSizeForCount(int totalQuestions) {
    if (totalQuestions <= 10) return 40.0;
    if (totalQuestions <= 20) return 36.0;
    if (totalQuestions <= 30) return 32.0;
    return 28.0;
  }

  static double indicatorSpacingForCount(int totalQuestions) {
    if (totalQuestions <= 10) return 12.0;
    if (totalQuestions <= 20) return 10.0;
    if (totalQuestions <= 30) return 8.0;
    return 6.0;
  }

  static double itemExtentForCount(int totalQuestions) {
    return indicatorSizeForCount(totalQuestions) +
        indicatorSpacingForCount(totalQuestions);
  }

  @override
  Widget build(BuildContext context) {
    final double indicatorSize = indicatorSizeForCount(totalQuestions);
    final double indicatorSpacing = indicatorSpacingForCount(totalQuestions);
    final answeredCount = answeredQuestions.length;

    return Semantics(
      container: true,
      label:
          'Navegação das questões. $answeredCount de $totalQuestions respondidas.',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(totalQuestions, (index) {
          final questionNumber = index + 1;
          final isAnswered = answeredQuestions.contains(questionNumber);
          final isCurrent = questionNumber == currentQuestion;

          final colors = _QuestionIndicatorColors.resolve(
            isCurrent: isCurrent,
            isAnswered: isAnswered,
          );

          final tooltipText = isCurrent
              ? 'Questão $questionNumber - atual'
              : isAnswered
                  ? 'Questão $questionNumber - respondida'
                  : 'Questão $questionNumber - não respondida';

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: indicatorSpacing / 2),
            child: Semantics(
              button: true,
              label: tooltipText,
              child: Tooltip(
                message: tooltipText,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    splashColor: AppColors.green.withValues(alpha: 0.15),
                    highlightColor: AppColors.green.withValues(alpha: 0.05),
                    onTap: () => onQuestionSelected(questionNumber),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      width: indicatorSize,
                      height: indicatorSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colors.fillColor,
                        border: Border.all(
                          color: colors.borderColor,
                          width: colors.borderWidth,
                        ),
                        boxShadow: colors.shadow,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 150),
                            style: TextStyle(
                              color: colors.textColor,
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                            ),
                            child: Text(questionNumber.toString()),
                          ),
                          if (isAnswered && !isCurrent)
                            Positioned(
                              right: indicatorSize * 0.18,
                              top: indicatorSize * 0.18,
                              child: Icon(
                                Icons.check_circle,
                                size: indicatorSize * 0.32,
                                color: AppColors.white,
                                semanticLabel: 'Questão respondida',
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _QuestionIndicatorColors {
  const _QuestionIndicatorColors({
    required this.fillColor,
    required this.borderColor,
    required this.textColor,
    required this.borderWidth,
    required this.shadow,
  });

  final Color fillColor;
  final Color borderColor;
  final Color textColor;
  final double borderWidth;
  final List<BoxShadow>? shadow;

  static _QuestionIndicatorColors resolve({
    required bool isCurrent,
    required bool isAnswered,
  }) {
    if (isCurrent) {
      return _QuestionIndicatorColors(
        fillColor: AppColors.white,
        borderColor: AppColors.green,
        textColor: AppColors.green,
        borderWidth: 3.0,
        shadow: [
          BoxShadow(
            color: AppColors.green.withValues(alpha: 0.25),
            blurRadius: 8.0,
            spreadRadius: 1.0,
            offset: const Offset(0, 2),
          ),
        ],
      );
    }

    if (isAnswered) {
      return _QuestionIndicatorColors(
        fillColor: AppColors.green,
        borderColor: AppColors.green,
        textColor: AppColors.white,
        borderWidth: 0,
        shadow: null,
      );
    }

    return _QuestionIndicatorColors(
      fillColor: AppColors.white,
      borderColor: AppColors.greyLight,
      textColor: AppColors.green,
      borderWidth: 1.5,
      shadow: null,
    );
  }
}
