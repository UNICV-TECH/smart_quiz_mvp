import 'package:unicv_tech_mvp/models/question.dart' as models;
import 'package:unicv_tech_mvp/services/repositorie/exam_repository.dart';

/// Mock implementation of ExamRepository for development/testing
class MockExamRepository implements ExamRepository {
  @override
  Future<ExamMetadata?> getExamMetadata(String courseId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Return mock data
    return ExamMetadata(
      id: 'mock-exam-id-$courseId',
      title: 'Simulado de Teste',
      description: 'Exame de teste para desenvolvimento',
      totalQuestions: 20,
    );
  }
  
  @override
  Future<int> getAvailableQuestionCount(String examId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return 20;
  }
  
  @override
  Future<String> createExamAttempt({
    required String userId,
    required String examId,
    required String courseId,
    required int questionCount,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return 'mock-attempt-${DateTime.now().millisecondsSinceEpoch}';
  }
  
  @override
  Future<List<ExamQuestion>> fetchExamQuestions({
    required String examId,
    required int questionCount,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    final now = DateTime.now();
    
    // Return mock questions
    return List.generate(questionCount, (index) {
      final question = models.Question(
        id: 'question-${index + 1}',
        examId: examId,
        enunciation: 'Esta é a questão ${index + 1} de teste. '
            'O conteúdo real será carregado do Supabase quando conectado.',
        questionOrder: index + 1,
        difficultyLevel: 'medium',
        points: 1.0,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );
      
      final choices = [
        models.AnswerChoice(
          id: 'choice-a-$index',
          questionId: question.id,
          choiceKey: 'A',
          choiceText: 'Alternativa A',
          isCorrect: index % 4 == 0,
          choiceOrder: 0,
          createdAt: now,
        ),
        models.AnswerChoice(
          id: 'choice-b-$index',
          questionId: question.id,
          choiceKey: 'B',
          choiceText: 'Alternativa B',
          isCorrect: index % 4 == 1,
          choiceOrder: 1,
          createdAt: now,
        ),
        models.AnswerChoice(
          id: 'choice-c-$index',
          questionId: question.id,
          choiceKey: 'C',
          choiceText: 'Alternativa C',
          isCorrect: index % 4 == 2,
          choiceOrder: 2,
          createdAt: now,
        ),
        models.AnswerChoice(
          id: 'choice-d-$index',
          questionId: question.id,
          choiceKey: 'D',
          choiceText: 'Alternativa D',
          isCorrect: index % 4 == 3,
          choiceOrder: 3,
          createdAt: now,
        ),
      ];
      
      return ExamQuestion(
        question: question,
        answerChoices: choices,
        supportingTexts: [],
      );
    });
  }
}
