import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unicv_tech_mvp/models/exam.dart' as models;

/// Repository for exam-related operations
abstract class ExamRepository {
  /// Fetch exam metadata for a given course
  Future<ExamMetadata?> getExamMetadata(String courseId);
  
  /// Get available question count for an exam
  Future<int> getAvailableQuestionCount(String examId);
  
  /// Create a new exam attempt
  Future<String> createExamAttempt({
    required String userId,
    required String examId,
    required String courseId,
    required int questionCount,
  });
  
  /// Fetch questions for an exam attempt
  Future<List<ExamQuestion>> fetchExamQuestions({
    required String examId,
    required int questionCount,
  });
}

class ExamMetadata {
  final String id;
  final String title;
  final String? description;
  final int totalQuestions;
  
  ExamMetadata({
    required this.id,
    required this.title,
    this.description,
    required this.totalQuestions,
  });
  
  factory ExamMetadata.fromJson(Map<String, dynamic> json) {
    return ExamMetadata(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      totalQuestions: json['total_questions'] as int? ?? 0,
    );
  }
}

/// Wrapper class for question data used during exam
class ExamQuestion {
  final models.Question question;
  final List<models.AnswerChoice> answerChoices;
  final List<models.SupportingText> supportingTexts;
  
  ExamQuestion({
    required this.question,
    required this.answerChoices,
    required this.supportingTexts,
  });
  
  String get id => question.id;
  String get enunciation => question.enunciation;
  String? get difficultyLevel => question.difficultyLevel;
  double get points => question.points;
}



/// Supabase implementation of ExamRepository
class SupabaseExamRepository implements ExamRepository {
  final SupabaseClient _client;
  
  SupabaseExamRepository({required SupabaseClient client}) : _client = client;
  
  @override
  Future<ExamMetadata?> getExamMetadata(String courseId) async {
    try {
      final response = await _client
          .from('exams')
          .select('id, title, description, total_available_questions')
          .eq('course_id', courseId)
          .eq('is_active', true)
          .maybeSingle();
      
      if (response == null) return null;
      
      return ExamMetadata(
        id: response['id'] as String,
        title: response['title'] as String,
        description: response['description'] as String?,
        totalQuestions: response['total_available_questions'] as int? ?? 0,
      );
    } catch (e) {
      throw Exception('Failed to fetch exam metadata: $e');
    }
  }
  
  @override
  Future<int> getAvailableQuestionCount(String examId) async {
    try {
      final response = await _client
          .from('questions')
          .select('id', const FetchOptions(count: CountOption.exact))
          .eq('exam_id', examId)
          .eq('is_active', true);
      
      return response.count ?? 0;
    } catch (e) {
      throw Exception('Failed to fetch question count: $e');
    }
  }
  
  @override
  Future<String> createExamAttempt({
    required String userId,
    required String examId,
    required String courseId,
    required int questionCount,
  }) async {
    try {
      final response = await _client
          .from('user_exam_attempts')
          .insert({
            'user_id': userId,
            'exam_id': examId,
            'course_id': courseId,
            'question_count': questionCount,
            'status': 'in_progress',
          })
          .select('id')
          .single();
      
      return response['id'] as String;
    } catch (e) {
      throw Exception('Failed to create exam attempt: $e');
    }
  }
  
  @override
  Future<List<ExamQuestion>> fetchExamQuestions({
    required String examId,
    required int questionCount,
  }) async {
    try {
      // Fetch random questions using direct query instead of RPC
      final questionsResponse = await _client
          .from('questions')
          .select('id, enunciation, difficulty_level, points')
          .eq('exam_id', examId)
          .eq('is_active', true)
          .limit(questionCount);
      
      final List<models.Question> questions = [];
      final List<String> questionIds = [];
      
      for (final questionData in questionsResponse) {
        final question = models.Question.fromJson(questionData);
        questions.add(question);
        questionIds.add(question.id);
      }
      
      if (questionIds.isEmpty) {
        return [];
      }
      
      // Fetch answer choices for all questions
      final choicesResponse = await _client
          .from('answer_choices')
          .select()
          .inFilter('question_id', questionIds)
          .order('choice_order');
      
      final Map<String, List<models.AnswerChoice>> choicesByQuestion = {};
      for (final choiceData in choicesResponse) {
        final choice = models.AnswerChoice.fromJson(choiceData);
        choicesByQuestion.putIfAbsent(choiceData['question_id'], () => []);
        choicesByQuestion[choiceData['question_id']]!.add(choice);
      }
      
      // Fetch supporting texts
      final textsResponse = await _client
          .from('supporting_texts')
          .select()
          .inFilter('question_id', questionIds)
          .order('display_order');
      
      final Map<String, List<models.SupportingText>> textsByQuestion = {};
      for (final textData in textsResponse) {
        final text = models.SupportingText.fromJson(textData);
        textsByQuestion.putIfAbsent(textData['question_id'], () => []);
        textsByQuestion[textData['question_id']]!.add(text);
      }
      
      // Combine questions with their choices and texts
      final List<ExamQuestion> examQuestions = [];
      for (final question in questions) {
        examQuestions.add(ExamQuestion(
          question: question,
          answerChoices: choicesByQuestion[question.id] ?? [],
          supportingTexts: textsByQuestion[question.id] ?? [],
        ));
      }
      
      return examQuestions;
    } catch (e) {
      throw Exception('Failed to fetch exam questions: $e');
    }
  }
}
