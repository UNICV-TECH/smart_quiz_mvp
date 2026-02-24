import '../models/exam_template.dart';
import '../models/exam_template_category.dart';
import '../models/exam_template_question.dart';
import '../models/question_category.dart';
import '../models/subject.dart';
import '../models/teacher_question.dart';
import '../models/teacher_stats.dart';
import 'teacher_repository_types.dart';

/// Repository interface for teacher-specific operations
abstract class TeacherRepository {
  // ============================================
  // Subjects (Matérias)
  // ============================================

  /// Fetch all subjects, optionally filtered by course
  Future<List<Subject>> fetchSubjects({String? courseId});

  /// Create a new subject
  Future<Subject> createSubject(Subject subject);

  /// Update an existing subject
  Future<void> updateSubject(Subject subject);

  /// Delete a subject (soft delete by setting is_active = false)
  Future<void> deleteSubject(String subjectId);

  // ============================================
  // Question Categories
  // ============================================

  /// Fetch all categories, optionally filtered by course and/or subject
  Future<List<QuestionCategory>> fetchCategories({String? courseId, String? subjectId});

  /// Create a new question category
  Future<QuestionCategory> createCategory(QuestionCategory category);

  /// Update an existing category
  Future<void> updateCategory(QuestionCategory category);

  /// Delete a category (soft delete by setting is_active = false)
  Future<void> deleteCategory(String categoryId);

  // ============================================
  // Teacher Questions
  // ============================================

  /// Fetch questions created by a teacher with optional filters
  Future<List<TeacherQuestion>> fetchTeacherQuestions(
      TeacherQuestionsFilter filter);

  /// Create a new question with supporting texts and answer choices
  Future<String> createQuestion(CreateQuestionRequest request);

  /// Update an existing question (basic fields only)
  Future<void> updateQuestion(UpdateQuestionRequest request);

  /// Fetch complete question detail (with answer choices and supporting texts)
  Future<QuestionDetail> fetchQuestionDetail(String questionId);

  /// Update a complete question (enunciation + answer choices + supporting texts)
  Future<void> updateQuestionFull(FullUpdateQuestionRequest request);

  /// Delete a question (soft delete by setting is_active = false)
  Future<void> deleteQuestion(String questionId);

  // ============================================
  // Exam Templates
  // ============================================

  /// Fetch exam templates for a teacher
  Future<List<ExamTemplate>> fetchTemplates({required String teacherId});

  /// Fetch a single template by ID
  Future<ExamTemplate> fetchTemplate(String templateId);

  /// Create a new exam template
  Future<ExamTemplate> createTemplate(ExamTemplate template);

  /// Update an existing template
  Future<void> updateTemplate(ExamTemplate template);

  /// Delete a template
  Future<void> deleteTemplate(String templateId);

  /// Publish a template (makes it available for students)
  Future<void> publishTemplate(String templateId);

  /// Unpublish a template
  Future<void> unpublishTemplate(String templateId);

  // ============================================
  // Exam Template Questions
  // ============================================

  /// Fetch questions assigned to a template
  Future<List<ExamTemplateQuestion>> fetchTemplateQuestions(String templateId);

  /// Add a question to a template
  Future<ExamTemplateQuestion> addQuestionToTemplate(
      ExamTemplateQuestion templateQuestion);

  /// Remove a question from a template
  Future<void> removeQuestionFromTemplate(String templateQuestionId);

  /// Update question order in a template
  Future<void> updateTemplateQuestionOrder(
      String templateQuestionId, int newOrder);

  // ============================================
  // Exam Template Categories
  // ============================================

  /// Fetch categories assigned to a template
  Future<List<ExamTemplateCategory>> fetchTemplateCategories(String templateId);

  /// Add a category to a template for auto-selection
  Future<ExamTemplateCategory> addCategoryToTemplate(
      ExamTemplateCategory templateCategory);

  /// Remove a category from a template
  Future<void> removeCategoryFromTemplate(String templateCategoryId);

  // ============================================
  // Statistics
  // ============================================

  /// Get question statistics for a teacher
  Future<List<TeacherQuestionStats>> getQuestionStats(String teacherId);

  /// Get exam statistics for a teacher
  Future<List<TeacherExamStats>> getExamStats(String teacherId);

  // ============================================
  // Exam Generation
  // ============================================

  /// Generate an exam from a template for a student
  Future<String> generateExamFromTemplate(String templateId, String userId);
}
