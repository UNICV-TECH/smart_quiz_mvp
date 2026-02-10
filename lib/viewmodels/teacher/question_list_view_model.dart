import 'package:flutter/material.dart';

import '../../models/course.dart';
import '../../models/question_category.dart';
import '../../models/teacher_question.dart';
import '../../repositories/course_repository.dart';
import '../../repositories/course_repository_types.dart' as course_repo;
import '../../repositories/teacher_repository.dart';
import '../../repositories/teacher_repository_types.dart';

class QuestionListViewModel extends ChangeNotifier {
  QuestionListViewModel({
    required String teacherId,
    required TeacherRepository teacherRepository,
    required CourseRepository courseRepository,
  })  : _teacherId = teacherId,
        _teacherRepository = teacherRepository,
        _courseRepository = courseRepository;

  final String _teacherId;
  final TeacherRepository _teacherRepository;
  final CourseRepository _courseRepository;

  // State
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  // Data
  List<TeacherQuestion> _questions = [];
  List<Course> _courses = [];
  List<QuestionCategory> _categories = [];

  // Filters
  String? _filterCourseId;
  String? _filterCategoryId;
  bool _showInactiveOnly = false;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  List<TeacherQuestion> get questions => List.unmodifiable(_questions);
  List<Course> get courses => List.unmodifiable(_courses);
  List<QuestionCategory> get categories => List.unmodifiable(_categories);

  String? get filterCourseId => _filterCourseId;
  String? get filterCategoryId => _filterCategoryId;
  bool get showInactiveOnly => _showInactiveOnly;

  int get totalQuestions => _questions.length;
  int get activeQuestions => _questions.where((q) => q.isActive).length;

  // Load data
  Future<void> loadInitialData() async {
    _setLoading(true);
    _clearMessages();

    try {
      await _loadCourses();
      await loadQuestions();
    } catch (error) {
      _setError('Erro ao carregar dados: $error');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadCourses() async {
    final repoCourses = await _courseRepository.fetchActiveCourses();
    _courses = repoCourses.map(_mapRepoCourse).toList();
  }

  Future<void> loadQuestions() async {
    _setLoading(true);
    _clearMessages();

    try {
      final filter = TeacherQuestionsFilter(
        teacherId: _teacherId,
        courseId: _filterCourseId,
        categoryId: _filterCategoryId,
        activeOnly: !_showInactiveOnly,
      );
      _questions = await _teacherRepository.fetchTeacherQuestions(filter);
    } catch (error) {
      _setError('Erro ao carregar questoes: $error');
      _questions = [];
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadCategories(String courseId) async {
    _categories = [];
    notifyListeners();

    try {
      _categories =
          await _teacherRepository.fetchCategories(courseId: courseId);
      notifyListeners();
    } catch (error) {
      debugPrint('Erro ao carregar categorias: $error');
    }
  }

  // Filters
  void setFilterCourse(String? courseId) {
    if (_filterCourseId == courseId) return;
    _filterCourseId = courseId;
    _filterCategoryId = null;
    _categories = [];
    notifyListeners();

    if (courseId != null) {
      loadCategories(courseId);
    }
    loadQuestions();
  }

  void setFilterCategory(String? categoryId) {
    if (_filterCategoryId == categoryId) return;
    _filterCategoryId = categoryId;
    notifyListeners();
    loadQuestions();
  }

  void toggleShowInactive() {
    _showInactiveOnly = !_showInactiveOnly;
    notifyListeners();
    loadQuestions();
  }

  void clearFilters() {
    _filterCourseId = null;
    _filterCategoryId = null;
    _showInactiveOnly = false;
    _categories = [];
    notifyListeners();
    loadQuestions();
  }

  // Actions
  Future<bool> deleteQuestion(String questionId) async {
    try {
      await _teacherRepository.deleteQuestion(questionId);
      _questions = _questions.where((q) => q.id != questionId).toList();
      _setSuccess('Questao removida com sucesso!');
      notifyListeners();
      return true;
    } catch (error) {
      _setError('Erro ao remover questao: $error');
      return false;
    }
  }

  // Helper methods
  void _setLoading(bool value) {
    if (_isLoading == value) return;
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _successMessage = null;
    notifyListeners();
  }

  void _setSuccess(String message) {
    _successMessage = message;
    _errorMessage = null;
    notifyListeners();
  }

  void _clearMessages() {
    if (_errorMessage == null && _successMessage == null) return;
    _errorMessage = null;
    _successMessage = null;
  }

  void clearMessages() {
    _clearMessages();
    notifyListeners();
  }

  Course _mapRepoCourse(course_repo.Course repo) {
    return Course(
      id: repo.id,
      courseKey: repo.courseKey,
      title: repo.title,
      description: repo.description.isNotEmpty ? repo.description : null,
      iconKey: repo.iconKey,
      createdAt: repo.createdAt,
    );
  }
}
