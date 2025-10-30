import 'package:flutter/material.dart';
import '../models/question.dart';
import '../models/exam.dart';
import '../models/course.dart';
import '../models/user_exam_attempt.dart';
import '../models/user_response.dart';

class ExamViewModel extends ChangeNotifier {
  final Exam exam;
  final Course course;
  final int questionCount;

  ExamViewModel({
    required this.exam,
    required this.course,
    required this.questionCount,
  });

  List<Question> _questions = [];
  UserExamAttempt? _currentAttempt;
  int _currentQuestionIndex = 0;
  Map<String, String> _selectedAnswers = {};
  Map<String, DateTime> _answerTimestamps = {};
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  DateTime? _startTime;
  DateTime? _endTime;

  List<Question> get questions => List.unmodifiable(_questions);
  UserExamAttempt? get currentAttempt => _currentAttempt;
  int get currentQuestionIndex => _currentQuestionIndex;
  Map<String, String> get selectedAnswers => Map.unmodifiable(_selectedAnswers);
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  
  Question? get currentQuestion {
    if (_questions.isEmpty || _currentQuestionIndex >= _questions.length) {
      return null;
    }
    return _questions[_currentQuestionIndex];
  }

  String? get currentAnswer {
    final question = currentQuestion;
    if (question == null) return null;
    return _selectedAnswers[question.id];
  }
  
  int get totalQuestions => _questions.length;
  int get answeredCount => _selectedAnswers.length;
  int get unansweredCount => totalQuestions - answeredCount;
  
  bool get isFirstQuestion => _currentQuestionIndex == 0;
  bool get isLastQuestion => _currentQuestionIndex == _questions.length - 1;
  bool get hasAnsweredCurrent {
    final question = currentQuestion;
    if (question == null) return false;
    return _selectedAnswers.containsKey(question.id);
  }
  
  Set<String> get answeredQuestionIds => _selectedAnswers.keys.toSet();
  
  Duration? get elapsedTime {
    if (_startTime == null) return null;
    final endTime = _endTime ?? DateTime.now();
    return endTime.difference(_startTime!);
  }

  Future<void> initialize() async {
    _setLoading(true);
    _clearError();

    try {
      _startTime = DateTime.now();
      
      _currentAttempt = UserExamAttempt(
        id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
        userId: 'temp_user',
        examId: exam.id,
        courseId: course.id,
        questionCount: questionCount,
        startedAt: _startTime!,
        status: 'in_progress',
        createdAt: DateTime.now(),
      );

      await _loadQuestions();

      _currentQuestionIndex = 0;
      _selectedAnswers = {};
      _answerTimestamps = {};
      _setLoading(false);
    } catch (error) {
      _setError('Erro ao inicializar simulado. Tente novamente.');
      _setLoading(false);
    }
  }

  Future<void> _loadQuestions() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    _questions = List.generate(questionCount, (index) {
      return Question(
        id: 'question_${index + 1}',
        examId: exam.id,
        enunciation: 'Esta é a questão ${index + 1} do simulado de ${course.title}.',
        questionOrder: index + 1,
        difficultyLevel: 'medium',
        points: 1.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        answerChoices: _generateAnswerChoices(index),
      );
    });
  }

  List<AnswerChoice> _generateAnswerChoices(int questionIndex) {
    final choices = ['A', 'B', 'C', 'D', 'E'];
    return List.generate(5, (index) {
      return AnswerChoice(
        id: 'choice_${questionIndex}_${index}',
        questionId: 'question_${questionIndex + 1}',
        choiceKey: choices[index],
        choiceText: 'Alternativa ${choices[index]}',
        isCorrect: index == 1,
        choiceOrder: index,
        createdAt: DateTime.now(),
      );
    });
  }

  void selectAnswer(String choiceKey) {
    final question = currentQuestion;
    if (question == null) return;

    _selectedAnswers[question.id] = choiceKey;
    _answerTimestamps[question.id] = DateTime.now();
    _clearError();
    notifyListeners();
  }

  void clearAnswer(String questionId) {
    if (_selectedAnswers.containsKey(questionId)) {
      _selectedAnswers.remove(questionId);
      _answerTimestamps.remove(questionId);
      notifyListeners();
    }
  }

  void goToQuestion(int index) {
    if (index < 0 || index >= _questions.length) return;
    if (_currentQuestionIndex == index) return;
    
    _currentQuestionIndex = index;
    _clearError();
    notifyListeners();
  }

  void goToNextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      _currentQuestionIndex++;
      _clearError();
      notifyListeners();
    }
  }

  void goToPreviousQuestion() {
    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex--;
      _clearError();
      notifyListeners();
    }
  }

  Future<UserExamAttempt?> submitExam() async {
    if (_isSubmitting || _currentAttempt == null) return null;

    _isSubmitting = true;
    _clearError();
    notifyListeners();

    try {
      _endTime = DateTime.now();
      final durationSeconds = _endTime!.difference(_startTime!).inSeconds;

      final responses = _buildUserResponses();
      final score = _calculateScore(responses);
      final percentageScore = (score / totalQuestions) * 100;

      final completedAttempt = _currentAttempt!.copyWith(
        completedAt: _endTime,
        durationSeconds: durationSeconds,
        totalScore: score.toDouble(),
        percentageScore: percentageScore,
        status: 'completed',
      );

      await Future.delayed(const Duration(seconds: 1));
      
      _isSubmitting = false;
      notifyListeners();
      return completedAttempt;
    } catch (error) {
      _setError('Erro ao enviar simulado. Tente novamente.');
      _isSubmitting = false;
      notifyListeners();
      return null;
    }
  }

  List<UserResponse> _buildUserResponses() {
    return _questions.map((question) {
      final selectedChoice = _selectedAnswers[question.id];
      final answerChoice = selectedChoice != null
          ? question.answerChoices.firstWhere(
              (choice) => choice.choiceKey == selectedChoice,
              orElse: () => question.answerChoices.first,
            )
          : null;

      final isCorrect = answerChoice?.isCorrect ?? false;
      final pointsEarned = isCorrect ? question.points : 0.0;

      return UserResponse(
        id: 'response_${question.id}',
        attemptId: _currentAttempt!.id,
        questionId: question.id,
        answerChoiceId: answerChoice?.id,
        selectedChoiceKey: selectedChoice,
        isCorrect: isCorrect,
        pointsEarned: pointsEarned,
        answeredAt: _answerTimestamps[question.id],
        createdAt: DateTime.now(),
      );
    }).toList();
  }

  int _calculateScore(List<UserResponse> responses) {
    return responses.where((r) => r.isCorrect == true).length;
  }

  int calculateScore() {
    int correctCount = 0;
    for (var entry in _selectedAnswers.entries) {
      final question = _questions.firstWhere((q) => q.id == entry.key);
      final answerChoice = question.answerChoices.firstWhere(
        (choice) => choice.choiceKey == entry.value,
        orElse: () => question.answerChoices.first,
      );
      if (answerChoice.isCorrect) {
        correctCount++;
      }
    }
    return correctCount;
  }

  void setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }

  void _clearError() {
    if (_errorMessage == null) return;
    
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _setLoading(bool value) {
    if (_isLoading == value) return;
    
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
