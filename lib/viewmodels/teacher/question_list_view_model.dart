import 'package:flutter/material.dart';

import '../../models/course.dart';
import '../../models/question_category.dart';
import '../../models/subject.dart';
import '../../models/teacher_question.dart';
import '../../repositories/course_repository.dart';
import '../../repositories/course_repository_types.dart' as course_repo;
import '../../repositories/teacher_repository.dart';
import '../../repositories/teacher_repository_types.dart';

class QuestionListViewModel extends ChangeNotifier {
  QuestionListViewModel({
    required TeacherRepository teacherRepository,
    required CourseRepository courseRepository,
  })  : _teacherRepository = teacherRepository,
        _courseRepository = courseRepository;

  final TeacherRepository _teacherRepository;
  final CourseRepository _courseRepository;

  // State
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  // Data
  List<TeacherQuestion> _allQuestions = [];
  List<Course> _courses = [];
  List<Subject> _subjects = [];
  List<QuestionCategory> _categories = [];

  // Filters
  String? _filterCourseId;
  String? _filterSubjectId;
  String? _filterCategoryId;
  bool _showInactiveOnly = false;
  /// null = all, 'enade', 'teacher'
  String? _filterOrigin;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  List<TeacherQuestion> get questions {
    if (_showInactiveOnly) {
      return List.unmodifiable(_allQuestions.where((q) => !q.isActive));
    }
    return List.unmodifiable(_allQuestions.where((q) => q.isActive));
  }

  List<Course> get courses => List.unmodifiable(_courses);
  List<Subject> get subjects => List.unmodifiable(_subjects);
  List<QuestionCategory> get categories => List.unmodifiable(_categories);

  String? get filterCourseId => _filterCourseId;
  String? get filterSubjectId => _filterSubjectId;
  String? get filterCategoryId => _filterCategoryId;
  bool get showInactiveOnly => _showInactiveOnly;
  String? get filterOrigin => _filterOrigin;

  int get totalQuestions => _allQuestions.length;
  int get activeQuestions => _allQuestions.where((q) => q.isActive).length;
  int get inactiveQuestions => _allQuestions.where((q) => !q.isActive).length;

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
        courseId: _filterCourseId,
        subjectId: _filterSubjectId,
        categoryId: _filterCategoryId,
        origin: _filterOrigin,
      );
      _allQuestions = await _teacherRepository.fetchTeacherQuestions(filter);
    } catch (error) {
      _setError('Erro ao carregar questões: $error');
      _allQuestions = [];
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadSubjects(String courseId) async {
    _subjects = [];
    notifyListeners();

    try {
      _subjects = await _teacherRepository.fetchSubjects(courseId: courseId);
      notifyListeners();
    } catch (error) {
      debugPrint('Erro ao carregar materias: $error');
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
    _filterSubjectId = null;
    _filterCategoryId = null;
    _subjects = [];
    _categories = [];
    notifyListeners();

    if (courseId != null) {
      loadSubjects(courseId);
      loadCategories(courseId);
    }
    loadQuestions();
  }

  void setFilterSubject(String? subjectId) {
    if (_filterSubjectId == subjectId) return;
    _filterSubjectId = subjectId;
    notifyListeners();
    loadQuestions();
  }

  void setFilterCategory(String? categoryId) {
    if (_filterCategoryId == categoryId) return;
    _filterCategoryId = categoryId;
    notifyListeners();
    loadQuestions();
  }

  void setFilterOrigin(String? origin) {
    if (_filterOrigin == origin) return;
    _filterOrigin = origin;
    notifyListeners();
    loadQuestions();
  }

  void toggleShowInactive() {
    _showInactiveOnly = !_showInactiveOnly;
    notifyListeners();
  }

  void clearFilters() {
    _filterCourseId = null;
    _filterSubjectId = null;
    _filterCategoryId = null;
    _filterOrigin = null;
    _showInactiveOnly = false;
    _subjects = [];
    _categories = [];
    notifyListeners();
    loadQuestions();
  }

  // Actions
  Future<bool> toggleQuestionActive(String questionId, bool currentActive) async {
    try {
      final newActive = !currentActive;
      await _teacherRepository.toggleQuestionActive(questionId, newActive);
      _allQuestions = _allQuestions.map((q) {
        if (q.id == questionId) {
          return TeacherQuestion(
            id: q.id,
            enunciation: q.enunciation,
            difficultyLevel: q.difficultyLevel,
            points: q.points,
            isActive: newActive,
            isEnade: q.isEnade,
            categoryName: q.categoryName,
            subjectName: q.subjectName,
            courseName: q.courseName,
            teacherName: q.teacherName,
            answerCount: q.answerCount,
            supportingTextCount: q.supportingTextCount,
            createdAt: q.createdAt,
          );
        }
        return q;
      }).toList();
      _setSuccess(newActive ? 'Questao ativada!' : 'Questao desativada!');
      notifyListeners();
      return true;
    } catch (error) {
      _setError('Erro ao alterar status: $error');
      return false;
    }
  }

  Future<bool> deleteQuestion(String questionId) async {
    try {
      await _teacherRepository.deleteQuestion(questionId);
      _allQuestions = _allQuestions.where((q) => q.id != questionId).toList();
      _setSuccess('Questão removida com sucesso!');
      notifyListeners();
      return true;
    } catch (error) {
      _setError('Erro ao remover questão: $error');
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
