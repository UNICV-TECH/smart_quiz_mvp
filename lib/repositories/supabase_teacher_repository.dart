import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/exam_template.dart';
import '../models/exam_template_category.dart';
import '../models/exam_template_question.dart';
import '../models/question_category.dart';
import '../models/teacher_question.dart';
import '../models/teacher_stats.dart';
import 'teacher_repository.dart';
import 'teacher_repository_types.dart';

class SupabaseTeacherRepository implements TeacherRepository {
  SupabaseTeacherRepository({required SupabaseClient client}) : _client = client;

  final SupabaseClient _client;

  // ============================================
  // Question Categories
  // ============================================

  @override
  Future<List<QuestionCategory>> fetchCategories({String? courseId}) async {
    try {
      var query = _client.from('question_category').select();

      if (courseId != null) {
        query = query.eq('id_course', courseId);
      }

      final response = await query.eq('is_active', true).order('name');

      return (response as List)
          .map((json) => QuestionCategory.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (error) {
      throw TeacherRepositoryException(
        'Erro ao carregar categorias: ${error.toString()}',
      );
    }
  }

  @override
  Future<QuestionCategory> createCategory(QuestionCategory category) async {
    try {
      final response = await _client
          .from('question_category')
          .insert(category.toInsertJson())
          .select()
          .single();

      return QuestionCategory.fromJson(response);
    } catch (error) {
      throw TeacherRepositoryException(
        'Erro ao criar categoria: ${error.toString()}',
      );
    }
  }

  @override
  Future<void> updateCategory(QuestionCategory category) async {
    try {
      await _client
          .from('question_category')
          .update({
            'name': category.name,
            'description': category.description,
            'is_active': category.isActive,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', category.id);
    } catch (error) {
      throw TeacherRepositoryException(
        'Erro ao atualizar categoria: ${error.toString()}',
      );
    }
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    try {
      await _client
          .from('question_category')
          .update({
            'is_active': false,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', categoryId);
    } catch (error) {
      throw TeacherRepositoryException(
        'Erro ao deletar categoria: ${error.toString()}',
      );
    }
  }

  // ============================================
  // Teacher Questions
  // ============================================

  @override
  Future<List<TeacherQuestion>> fetchTeacherQuestions(
      TeacherQuestionsFilter filter) async {
    try {
      final response = await _client.rpc('get_teacher_questions', params: {
        'p_teacher_id': filter.teacherId,
        'p_course_id': filter.courseId,
        'p_category_id': filter.categoryId,
        'p_active_only': filter.activeOnly,
      });

      return (response as List)
          .map((json) => TeacherQuestion.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (error) {
      throw TeacherRepositoryException(
        'Erro ao carregar questoes: ${error.toString()}',
      );
    }
  }

  @override
  Future<String> createQuestion(CreateQuestionRequest request) async {
    try {
      final response = await _client.rpc(
        'create_teacher_question',
        params: request.toRpcParams(),
      );

      return response as String;
    } catch (error) {
      throw TeacherRepositoryException(
        'Erro ao criar questao: ${error.toString()}',
      );
    }
  }

  @override
  Future<void> updateQuestion(UpdateQuestionRequest request) async {
    try {
      await _client
          .from('question')
          .update(request.toJson())
          .eq('id', request.questionId);
    } catch (error) {
      throw TeacherRepositoryException(
        'Erro ao atualizar questao: ${error.toString()}',
      );
    }
  }

  @override
  Future<void> deleteQuestion(String questionId) async {
    try {
      await _client
          .from('question')
          .update({
            'is_active': false,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', questionId);
    } catch (error) {
      throw TeacherRepositoryException(
        'Erro ao deletar questao: ${error.toString()}',
      );
    }
  }

  // ============================================
  // Exam Templates
  // ============================================

  @override
  Future<List<ExamTemplate>> fetchTemplates({required String teacherId}) async {
    try {
      final response = await _client
          .from('exam_template')
          .select('*, course:id_course(title, name)')
          .eq('id_teacher', teacherId)
          .eq('is_active', true)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => ExamTemplate.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (error) {
      throw TeacherRepositoryException(
        'Erro ao carregar templates: ${error.toString()}',
      );
    }
  }

  @override
  Future<ExamTemplate> fetchTemplate(String templateId) async {
    try {
      final response = await _client
          .from('exam_template')
          .select('*, course:id_course(title, name)')
          .eq('id', templateId)
          .single();

      return ExamTemplate.fromJson(response);
    } catch (error) {
      throw TeacherRepositoryException(
        'Erro ao carregar template: ${error.toString()}',
      );
    }
  }

  @override
  Future<ExamTemplate> createTemplate(ExamTemplate template) async {
    try {
      final response = await _client
          .from('exam_template')
          .insert(template.toInsertJson())
          .select('*, course:id_course(title, name)')
          .single();

      return ExamTemplate.fromJson(response);
    } catch (error) {
      throw TeacherRepositoryException(
        'Erro ao criar template: ${error.toString()}',
      );
    }
  }

  @override
  Future<void> updateTemplate(ExamTemplate template) async {
    try {
      await _client
          .from('exam_template')
          .update({
            'name': template.name,
            'description': template.description,
            'time_limit_minutes': template.timeLimitMinutes,
            'question_count': template.questionCount,
            'passing_score_percentage': template.passingScorePercentage,
            'shuffle_questions': template.shuffleQuestions,
            'shuffle_choices': template.shuffleChoices,
            'show_correct_answers': template.showCorrectAnswers,
            'allow_review': template.allowReview,
            'max_attempts': template.maxAttempts,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', template.id);
    } catch (error) {
      throw TeacherRepositoryException(
        'Erro ao atualizar template: ${error.toString()}',
      );
    }
  }

  @override
  Future<void> deleteTemplate(String templateId) async {
    try {
      await _client
          .from('exam_template')
          .update({
            'is_active': false,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', templateId);
    } catch (error) {
      throw TeacherRepositoryException(
        'Erro ao deletar template: ${error.toString()}',
      );
    }
  }

  @override
  Future<void> publishTemplate(String templateId) async {
    try {
      await _client
          .from('exam_template')
          .update({
            'is_published': true,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', templateId);
    } catch (error) {
      throw TeacherRepositoryException(
        'Erro ao publicar template: ${error.toString()}',
      );
    }
  }

  @override
  Future<void> unpublishTemplate(String templateId) async {
    try {
      await _client
          .from('exam_template')
          .update({
            'is_published': false,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', templateId);
    } catch (error) {
      throw TeacherRepositoryException(
        'Erro ao despublicar template: ${error.toString()}',
      );
    }
  }

  // ============================================
  // Exam Template Questions
  // ============================================

  @override
  Future<List<ExamTemplateQuestion>> fetchTemplateQuestions(
      String templateId) async {
    try {
      final response = await _client
          .from('exam_template_question')
          .select('*, question:id_question(enunciation)')
          .eq('id_exam_template', templateId)
          .order('question_order');

      return (response as List)
          .map((json) =>
              ExamTemplateQuestion.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (error) {
      throw TeacherRepositoryException(
        'Erro ao carregar questoes do template: ${error.toString()}',
      );
    }
  }

  @override
  Future<ExamTemplateQuestion> addQuestionToTemplate(
      ExamTemplateQuestion templateQuestion) async {
    try {
      final response = await _client
          .from('exam_template_question')
          .insert(templateQuestion.toInsertJson())
          .select('*, question:id_question(enunciation)')
          .single();

      return ExamTemplateQuestion.fromJson(response);
    } catch (error) {
      throw TeacherRepositoryException(
        'Erro ao adicionar questao ao template: ${error.toString()}',
      );
    }
  }

  @override
  Future<void> removeQuestionFromTemplate(String templateQuestionId) async {
    try {
      await _client
          .from('exam_template_question')
          .delete()
          .eq('id', templateQuestionId);
    } catch (error) {
      throw TeacherRepositoryException(
        'Erro ao remover questao do template: ${error.toString()}',
      );
    }
  }

  @override
  Future<void> updateTemplateQuestionOrder(
      String templateQuestionId, int newOrder) async {
    try {
      await _client
          .from('exam_template_question')
          .update({'question_order': newOrder})
          .eq('id', templateQuestionId);
    } catch (error) {
      throw TeacherRepositoryException(
        'Erro ao atualizar ordem da questao: ${error.toString()}',
      );
    }
  }

  // ============================================
  // Exam Template Categories
  // ============================================

  @override
  Future<List<ExamTemplateCategory>> fetchTemplateCategories(
      String templateId) async {
    try {
      final response = await _client
          .from('exam_template_category')
          .select('*, category:id_category(name)')
          .eq('id_exam_template', templateId);

      return (response as List)
          .map((json) =>
              ExamTemplateCategory.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (error) {
      throw TeacherRepositoryException(
        'Erro ao carregar categorias do template: ${error.toString()}',
      );
    }
  }

  @override
  Future<ExamTemplateCategory> addCategoryToTemplate(
      ExamTemplateCategory templateCategory) async {
    try {
      final response = await _client
          .from('exam_template_category')
          .insert(templateCategory.toInsertJson())
          .select('*, category:id_category(name)')
          .single();

      return ExamTemplateCategory.fromJson(response);
    } catch (error) {
      throw TeacherRepositoryException(
        'Erro ao adicionar categoria ao template: ${error.toString()}',
      );
    }
  }

  @override
  Future<void> removeCategoryFromTemplate(String templateCategoryId) async {
    try {
      await _client
          .from('exam_template_category')
          .delete()
          .eq('id', templateCategoryId);
    } catch (error) {
      throw TeacherRepositoryException(
        'Erro ao remover categoria do template: ${error.toString()}',
      );
    }
  }

  // ============================================
  // Statistics
  // ============================================

  @override
  Future<List<TeacherQuestionStats>> getQuestionStats(String teacherId) async {
    try {
      final response = await _client
          .from('teacher_question_stats')
          .select()
          .eq('id_teacher', teacherId);

      return (response as List)
          .map((json) =>
              TeacherQuestionStats.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (error) {
      throw TeacherRepositoryException(
        'Erro ao carregar estatisticas de questoes: ${error.toString()}',
      );
    }
  }

  @override
  Future<List<TeacherExamStats>> getExamStats(String teacherId) async {
    try {
      final response = await _client
          .from('teacher_exam_stats')
          .select()
          .eq('id_teacher', teacherId);

      return (response as List)
          .map(
              (json) => TeacherExamStats.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (error) {
      throw TeacherRepositoryException(
        'Erro ao carregar estatisticas de provas: ${error.toString()}',
      );
    }
  }

  // ============================================
  // Exam Generation
  // ============================================

  @override
  Future<String> generateExamFromTemplate(
      String templateId, String userId) async {
    try {
      final response = await _client.rpc(
        'generate_exam_from_template',
        params: {
          'p_template_id': templateId,
          'p_user_id': userId,
        },
      );

      return response as String;
    } catch (error) {
      throw TeacherRepositoryException(
        'Erro ao gerar prova a partir do template: ${error.toString()}',
      );
    }
  }
}
