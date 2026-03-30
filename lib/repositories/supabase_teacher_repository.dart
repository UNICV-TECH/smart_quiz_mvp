import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/exam_template.dart';
import '../models/exam_template_category.dart';
import '../models/exam_template_question.dart';
import '../models/question_category.dart';
import '../models/subject.dart';
import '../models/teacher_question.dart';
import '../models/teacher_stats.dart';
import 'teacher_repository.dart';
import 'teacher_repository_types.dart';

class SupabaseTeacherRepository implements TeacherRepository {
  SupabaseTeacherRepository({required SupabaseClient client}) : _client = client;

  final SupabaseClient _client;

  // ============================================
  // Subjects (Matérias)
  // ============================================

  @override
  Future<List<Subject>> fetchSubjects({String? courseId}) async {
    try {
      var query = _client.from('subject').select();

      if (courseId != null) {
        query = query.eq('id_course', courseId);
      }

      final response = await query.eq('is_active', true).order('name');

      return (response as List)
          .map((json) => Subject.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (error) {
      throw TeacherRepositoryException(
        'Erro ao carregar matérias: ${error.toString()}',
      );
    }
  }

  @override
  Future<Subject> createSubject(Subject subject) async {
    try {
      final response = await _client
          .from('subject')
          .insert(subject.toInsertJson())
          .select()
          .single();

      return Subject.fromJson(response);
    } catch (error) {
      throw TeacherRepositoryException(
        'Erro ao criar matéria: ${error.toString()}',
      );
    }
  }

  @override
  Future<void> updateSubject(Subject subject) async {
    try {
      await _client
          .from('subject')
          .update({
            'name': subject.name,
            'description': subject.description,
            'is_active': subject.isActive,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', subject.id);
    } catch (error) {
      throw TeacherRepositoryException(
        'Erro ao atualizar matéria: ${error.toString()}',
      );
    }
  }

  @override
  Future<void> deleteSubject(String subjectId) async {
    try {
      await _client
          .from('subject')
          .update({
            'is_active': false,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', subjectId);
    } catch (error) {
      throw TeacherRepositoryException(
        'Erro ao deletar matéria: ${error.toString()}',
      );
    }
  }

  // ============================================
  // Question Categories
  // ============================================

  @override
  Future<List<QuestionCategory>> fetchCategories({String? courseId, String? subjectId}) async {
    try {
      var query = _client.from('question_category').select();

      if (courseId != null) {
        query = query.eq('id_course', courseId);
      }

      if (subjectId != null) {
        query = query.eq('id_subject', subjectId);
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
      final params = <String, dynamic>{};
      if (filter.teacherId != null) params['p_teacher_id'] = filter.teacherId;
      if (filter.courseId != null) params['p_course_id'] = filter.courseId;
      if (filter.categoryId != null) params['p_category_id'] = filter.categoryId;
      if (filter.subjectId != null) params['p_subject_id'] = filter.subjectId;
      if (filter.activeOnly != null) params['p_active_only'] = filter.activeOnly;
      if (filter.origin != null) params['p_origin'] = filter.origin;
      final response = await _client.rpc('get_teacher_questions', params: params);

      return (response as List)
          .map((json) => TeacherQuestion.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (error) {
      throw TeacherRepositoryException(
        'Erro ao carregar questões: ${error.toString()}',
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
        'Erro ao criar questão: ${error.toString()}',
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
        'Erro ao atualizar questão: ${error.toString()}',
      );
    }
  }

  @override
  Future<QuestionDetail> fetchQuestionDetail(String questionId) async {
    try {
      final questionResponse = await _client
          .from('question')
          .select('id, enunciation, difficulty_level, points, id_course, id_subject, id_category')
          .eq('id', questionId)
          .single();

      final answerChoicesResponse = await _client
          .from('answerchoice')
          .select()
          .eq('idquestion', questionId)
          .order('letter');

      final supportingTextsResponse = await _client
          .from('supportingtext')
          .select()
          .eq('id_question', questionId)
          .order('display_order');

      final answerChoices = (answerChoicesResponse as List)
          .map((json) =>
              AnswerChoiceDetail.fromJson(json as Map<String, dynamic>))
          .toList();

      final supportingTexts = (supportingTextsResponse as List)
          .map((json) =>
              SupportingTextDetail.fromJson(json as Map<String, dynamic>))
          .toList();

      return QuestionDetail(
        id: questionResponse['id'] as String,
        enunciation: questionResponse['enunciation'] as String? ?? '',
        difficultyLevel: questionResponse['difficulty_level'] as String?,
        points: (questionResponse['points'] as num?)?.toDouble() ?? 1.0,
        courseId: questionResponse['id_course'] as String,
        subjectId: questionResponse['id_subject'] as String?,
        categoryId: questionResponse['id_category'] as String?,
        answerChoices: answerChoices,
        supportingTexts: supportingTexts,
      );
    } catch (error) {
      throw TeacherRepositoryException(
        'Erro ao carregar detalhes da questão: ${error.toString()}',
      );
    }
  }

  @override
  Future<void> updateQuestionFull(FullUpdateQuestionRequest request) async {
    try {
      await _client.rpc(
        'update_teacher_question',
        params: request.toRpcParams(),
      );
    } catch (error) {
      throw TeacherRepositoryException(
        'Erro ao atualizar questão: ${error.toString()}',
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
        'Erro ao deletar questão: ${error.toString()}',
      );
    }
  }

  @override
  Future<void> toggleQuestionActive(String questionId, bool isActive) async {
    try {
      await _client
          .from('question')
          .update({
            'is_active': isActive,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', questionId);
    } catch (error) {
      throw TeacherRepositoryException(
        'Erro ao alterar status da questao: ${error.toString()}',
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
        'Erro ao carregar questões do template: ${error.toString()}',
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
        'Erro ao adicionar questão ao template: ${error.toString()}',
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
        'Erro ao remover questão do template: ${error.toString()}',
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
        'Erro ao atualizar ordem da questão: ${error.toString()}',
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
        'Erro ao carregar estatísticas de questões: ${error.toString()}',
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
        'Erro ao carregar estatísticas de provas: ${error.toString()}',
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
