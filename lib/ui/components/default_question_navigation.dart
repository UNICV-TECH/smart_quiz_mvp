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

  const QuestionNavigation({
    super.key,
    required this.totalQuestions,
    required this.currentQuestion,
    required this.onQuestionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(15, (index) {
        final questionNumber = index + 1;
        final isActive = questionNumber <= totalQuestions; 

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 3.0), 
          child: GestureDetector(
            onTap: isActive ? () => onQuestionSelected(questionNumber) : null,
            child: Container(
              width: 40.0, 
              height: 40.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive 
                    ? AppColors.green  
                    : const Color(0xFFE0E0E0), 
              ),
              child: Center(
                child: Text(
                  isActive ? questionNumber.toString() : '-', 
                  style: TextStyle(
                    color: isActive 
                        ? AppColors.white  
                        : const Color(0xFF666666), 
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