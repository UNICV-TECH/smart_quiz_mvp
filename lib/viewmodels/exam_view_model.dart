import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unicv_tech_mvp/models/exam_history.dart';

class ExamViewModel extends ChangeNotifier {
  ExamViewModel({
    SupabaseClient? supabase,
    required this.userId,
    required this.examId,
    required this.courseId,
    required this.questionCount,
    ExamRemoteDataSource? dataSource,
  })  : assert(
          supabase != null || dataSource != null,
          'Provide either a SupabaseClient or an ExamRemoteDataSource',
        ),
        _dataSource =
            dataSource ?? SupabaseExamDataSource(supabase!);

  final ExamRemoteDataSource _dataSource;
  final String userId;
  final String examId;
  final String courseId;
  final int questionCount;

  List<ExamQuestion> _examQuestions = [];
  final Map<String, String> _selectedAnswers = {};
  bool _loading = false;
  String? _error;
  String? _attemptId;
  DateTime? _startedAt;

  List<ExamQuestion> get examQuestions => _examQuestions;
  Map<String, String> get selectedAnswers => _selectedAnswers;
  bool get loading => _loading;
  String? get error => _error;
  String? get attemptId => _attemptId;

  Future<void> initialize() async {
    _setLoading(true);
    try {
      await _createAttempt();
      await _loadQuestions();
      _error = null;
    } catch (err, stack) {
      _error = err.toString();
      debugPrint('Failed to initialize exam: $err');
      debugPrintStack(stackTrace: stack);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _createAttempt() async {
    _startedAt = DateTime.now();
    _attemptId = await _dataSource.createAttempt(
      userId: userId,
      examId: examId,
      courseId: courseId,
      questionCount: questionCount,
      startedAt: _startedAt!,
    );
  }

  Future<void> _loadQuestions() async {
    final List<Map<String, dynamic>> allQuestionsData =
        await _dataSource.fetchQuestions(examId);

    // Only shuffle when we actually need to sample a subset; otherwise keep the
    // original order so deterministic tests don't become flaky.
    if (allQuestionsData.length > questionCount) {
      allQuestionsData.shuffle();
    }
    final List<Map<String, dynamic>> questionsData =
        allQuestionsData.take(questionCount).toList();

    final questionIds = questionsData.map((q) => q['id'] as String).toList();

    final List<Map<String, dynamic>> answerChoicesData =
        await _dataSource.fetchAnswerChoices(questionIds);
    final List<Map<String, dynamic>> supportingTextsData =
        await _dataSource.fetchSupportingTexts(questionIds);

    final Map<String, List<AnswerChoice>> answerChoicesByQuestion = {};
    for (final ac in answerChoicesData) {
      final answerChoice = AnswerChoice.fromJson(ac);
      answerChoicesByQuestion
          .putIfAbsent(answerChoice.questionId, () => [])
          .add(answerChoice);
    }

    final Map<String, List<SupportingText>> supportingTextsByQuestion = {};
    for (final st in supportingTextsData) {
      final supportingText = SupportingText.fromJson(st);
      supportingTextsByQuestion
          .putIfAbsent(supportingText.questionId, () => [])
          .add(supportingText);
    }

    _examQuestions = questionsData.map((q) {
      final question = Question.fromJson(q);
      return ExamQuestion(
        question: question,
        answerChoices: answerChoicesByQuestion[question.id] ?? [],
        supportingTexts: supportingTextsByQuestion[question.id] ?? [],
      );
    }).toList();
  }

  void selectAnswer(String questionId, String choiceKey) {
    _selectedAnswers[questionId] = choiceKey;
    notifyListeners();
  }

  Future<Map<String, dynamic>> finalize() async {
    if (_attemptId == null) {
      throw Exception('No attempt ID available');
    }

    _setLoading(true);
    try {
      final responses = <Map<String, dynamic>>[];
      int correctCount = 0;
      double totalScore = 0.0;

      for (var examQuestion in _examQuestions) {
        final questionId = examQuestion.question.id;
        final selectedChoiceKey = _selectedAnswers[questionId];

        final selectedChoice = selectedChoiceKey != null
            ? examQuestion.answerChoices
                .where((ac) => ac.choiceKey == selectedChoiceKey)
                .firstOrNull
            : null;

        final isCorrect = selectedChoice?.isCorrect ?? false;
        final pointsEarned = isCorrect ? examQuestion.question.points : 0.0;

        if (isCorrect) correctCount++;
        totalScore += pointsEarned;

        responses.add({
          'attempt_id': _attemptId,
          'question_id': questionId,
          'answer_choice_id': selectedChoice?.id,
          'selected_choice_key': selectedChoiceKey,
          'is_correct': isCorrect,
          'points_earned': pointsEarned,
          'answered_at': DateTime.now().toIso8601String(),
        });
      }

      await _dataSource.insertResponses(responses);

      final percentageScore = (_examQuestions.isNotEmpty
          ? (correctCount / _examQuestions.length) * 100
          : 0.0);
      final durationSeconds = _startedAt != null
          ? DateTime.now().difference(_startedAt!).inSeconds
          : 0;

      await _dataSource.updateAttempt(
        _attemptId!,
        {
          'completed_at': DateTime.now().toIso8601String(),
          'duration_seconds': durationSeconds,
          'total_score': totalScore,
          'percentage_score': percentageScore,
          'status': 'completed',
        },
      );

      _error = null;
      return {
        'totalQuestions': _examQuestions.length,
        'correctCount': correctCount,
        'totalScore': totalScore,
        'percentageScore': percentageScore,
      };
    } catch (err, stack) {
      _error = err.toString();
      debugPrint('Failed to finalize exam: $err');
      debugPrintStack(stackTrace: stack);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }
}

abstract class ExamRemoteDataSource {
  Future<String> createAttempt({
    required String userId,
    required String examId,
    required String courseId,
    required int questionCount,
    required DateTime startedAt,
  });

  Future<List<Map<String, dynamic>>> fetchQuestions(String examId);

  Future<List<Map<String, dynamic>>> fetchAnswerChoices(
    List<String> questionIds,
  );

  Future<List<Map<String, dynamic>>> fetchSupportingTexts(
    List<String> questionIds,
  );

  Future<void> insertResponses(List<Map<String, dynamic>> responses);

  Future<void> updateAttempt(
    String attemptId,
    Map<String, dynamic> updates,
  );
}

class SupabaseExamDataSource implements ExamRemoteDataSource {
  SupabaseExamDataSource(SupabaseClient client) : _client = client;

  final SupabaseClient _client;

  @override
  Future<String> createAttempt({
    required String userId,
    required String examId,
    required String courseId,
    required int questionCount,
    required DateTime startedAt,
  }) async {
    final response = await _client
        .from('user_exam_attempts')
        .insert({
          'user_id': userId,
          'exam_id': examId,
          'course_id': courseId,
          'question_count': questionCount,
          'started_at': startedAt.toIso8601String(),
          'status': 'in_progress',
        })
        .select('id')
        .single();

    return response['id'] as String;
  }

  @override
  Future<List<Map<String, dynamic>>> fetchQuestions(String examId) async {
    final response = await _client
        .from('questions')
        .select('id, enunciation, difficulty_level, points')
        .eq('exam_id', examId)
        .eq('is_active', true);

    final data = response as List<dynamic>;
    return data
        .cast<Map<String, dynamic>>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  @override
  Future<List<Map<String, dynamic>>> fetchAnswerChoices(
    List<String> questionIds,
  ) async {
    final response = await _client
        .from('answer_choices')
        .select('*')
        .inFilter('question_id', questionIds)
        .order('choice_order');

    final data = response as List<dynamic>;
    return data
        .cast<Map<String, dynamic>>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  @override
  Future<List<Map<String, dynamic>>> fetchSupportingTexts(
    List<String> questionIds,
  ) async {
    final response = await _client
        .from('supporting_texts')
        .select('*')
        .inFilter('question_id', questionIds)
        .order('display_order');

    final data = response as List<dynamic>;
    return data
        .cast<Map<String, dynamic>>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  @override
  Future<void> insertResponses(List<Map<String, dynamic>> responses) async {
    await _client.from('user_responses').insert(responses);
  }

  @override
  Future<void> updateAttempt(
    String attemptId,
    Map<String, dynamic> updates,
  ) async {
    await _client
        .from('user_exam_attempts')
        .update(updates)
        .eq('id', attemptId);
  }
}
