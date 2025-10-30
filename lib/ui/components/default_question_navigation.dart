import 'package:flutter/material.dart';
import '../theme/app_color.dart';

@Preview(name: 'Navegação de Questões')
Widget questionNavigationPreview() {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(20.0),
      child: QuestionNavigation(
        totalQuestions: 10,
        currentQuestion: 3,
        onQuestionSelected: (questionNumber) {
          debugPrint('Questão selecionada: $questionNumber');
        },
        answeredQuestions: const {1, 2},
      ),
    ),
  );
}

class Preview {
  const Preview({required String name});
}

class QuestionNavigation extends StatelessWidget {
  final int totalQuestions;
  final int currentQuestion;
  final Function(int) onQuestionSelected;
  final Set<int> answeredQuestions;

  const QuestionNavigation({
    super.key,
    required this.totalQuestions,
    required this.currentQuestion,
    required this.onQuestionSelected,
    required this.answeredQuestions,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(15, (index) {
        final questionNumber = index + 1;
        final isActive = questionNumber <= totalQuestions;
        final isAnswered = isActive && answeredQuestions.contains(questionNumber);
        final isCurrent = questionNumber == currentQuestion;

        // Define cores baseado no estado
        Color circleColor;
        Color textColor;
        Color borderColor;
        double borderWidth;

        if (isCurrent || isAnswered) {
          // Questão atual ou respondida - verde com texto branco
          circleColor = AppColors.green;
          textColor = AppColors.white;
          borderColor = AppColors.green;
          borderWidth = 0;
        } else if (isActive) {
          // Questão ativa mas não respondida - branco com borda cinza
          circleColor = AppColors.white;
          textColor = AppColors.green;
          borderColor = AppColors.greyLight;
          borderWidth = 1.5;
        } else {
          // Questão inativa
          circleColor = AppColors.greyLight;
          textColor = AppColors.greyText;
          borderColor = AppColors.greyLight;
          borderWidth = 1.5;
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 3.0),
          child: GestureDetector(
            onTap: isActive ? () => onQuestionSelected(questionNumber) : null,
            child: Container(
              width: 40.0,
              height: 40.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: circleColor,
                border: Border.all(
                  color: borderColor,
                  width: borderWidth,
                ),
              ),
              child: Center(
                child: Text(
                  isActive ? questionNumber.toString() : '-',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
