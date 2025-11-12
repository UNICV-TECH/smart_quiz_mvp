import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../repositories/exam_attempt_repository_types.dart';
import '../repositories/supabase_exam_attempt_repository.dart';
import '../repositories/question_repository_types.dart';
import '../repositories/supabase_question_repository.dart';
import '../models/user_response.dart' as models;

class ExamDetailViewModel extends ChangeNotifier {
  final SupabaseExamAttemptRepository _attemptRepository;
  final SupabaseQuestionRepository _questionRepository;

  ExamDetailViewModel()
      : _attemptRepository = SupabaseExamAttemptRepository(
          client: Supabase.instance.client,
        ),
        _questionRepository = SupabaseQuestionRepository(
          client: Supabase.instance.client,
        );

  ExamAttemptHistory? _attempt;
  List<models.UserResponse> _responses = [];
  List<Question> _questions = [];
  Map<String, models.UserResponse> _responsesByQuestionId = {};
  bool _isLoading = false;
  String? _errorMessage;

  ExamAttemptHistory? get attempt => _attempt;
  List<Question> get questions => _questions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get correctAnswersCount {
    return _responses.where((response) => response.isCorrect == true).length;
  }

  models.UserResponse? getResponseForQuestion(String questionId) {
    return _responsesByQuestionId[questionId];
  }

  Future<void> loadExamDetails(String attemptId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Buscar tentativa
      final attempts = await _attemptRepository.fetchUserAttempts(
        userId: Supabase.instance.client.auth.currentUser!.id,
      );
      _attempt = attempts.firstWhere((a) => a.id == attemptId);

      // Buscar respostas
      _responses = await _attemptRepository.fetchAttemptResponses(
        attemptId: attemptId,
      );

      // Criar mapa de respostas por questão
      _responsesByQuestionId = {
        for (var response in _responses) response.questionId: response
      };

      // Buscar questões
      final questionIds = _responses.map((r) => r.questionId).toSet().toList();
      _questions = await _questionRepository.fetchQuestionsByIds(
        questionIds: questionIds,
      );

      // Ordenar questões pela ordem das respostas
      final questionOrder = <String, int>{};
      for (int i = 0; i < _responses.length; i++) {
        questionOrder[_responses[i].questionId] = i;
      }
      _questions.sort((a, b) {
        final orderA = questionOrder[a.id] ?? 999;
        final orderB = questionOrder[b.id] ?? 999;
        return orderA.compareTo(orderB);
      });

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Erro ao carregar detalhes da prova: ${e.toString()}';
      notifyListeners();
    }
  }
}
