import 'package:flutter/material.dart';

import '../../models/course.dart';
import '../../models/question_category.dart';
import '../../models/subject.dart';
import '../../repositories/course_repository.dart';
import '../../repositories/course_repository_types.dart' as course_repo;
import '../../repositories/teacher_repository.dart';
import '../../repositories/teacher_repository_types.dart';

class CategoryListViewModel extends ChangeNotifier {
  CategoryListViewModel({
    required TeacherRepository teacherRepository,
    required CourseRepository courseRepository,
  })  : _teacherRepository = teacherRepository,
        _courseRepository = courseRepository;

  final TeacherRepository _teacherRepository;
  final CourseRepository _courseRepository;

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  List<Course> _courses = [];
  List<Subject> _subjects = [];
  List<QuestionCategory> _categories = [];
  String? _selectedCourseId;
  String? _selectedSubjectId;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  List<Course> get courses => List.unmodifiable(_courses);
  List<Subject> get subjects => List.unmodifiable(_subjects);
  List<QuestionCategory> get categories => List.unmodifiable(_categories);
  String? get selectedCourseId => _selectedCourseId;
  String? get selectedSubjectId => _selectedSubjectId;

  Future<void> loadInitialData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final repoCourses = await _courseRepository.fetchActiveCourses();
      _courses = repoCourses.map(_mapRepoCourse).toList();
    } catch (error) {
      _errorMessage = 'Erro ao carregar cursos: $error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setFilterCourse(String? courseId) {
    _selectedCourseId = courseId;
    _selectedSubjectId = null;
    _subjects = [];
    _categories = [];
    _clearMessages();
    notifyListeners();

    if (courseId != null) {
      _loadSubjects();
    }
  }

  void setFilterSubject(String? subjectId) {
    _selectedSubjectId = subjectId;
    _categories = [];
    _clearMessages();
    notifyListeners();

    if (subjectId != null) {
      loadCategories();
    }
  }

  Future<void> _loadSubjects() async {
    try {
      _subjects = await _teacherRepository.fetchSubjects(
        courseId: _selectedCourseId,
      );
      notifyListeners();
    } catch (error) {
      debugPrint('Erro ao carregar matérias: $error');
    }
  }

  Future<void> loadCategories() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _categories = await _teacherRepository.fetchCategories(
        courseId: _selectedCourseId,
        subjectId: _selectedSubjectId,
      );
    } catch (error) {
      _errorMessage = 'Erro ao carregar categorias: $error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createCategory({
    required String name,
    String? description,
  }) async {
    if (_selectedCourseId == null) {
      _errorMessage = 'Selecione um curso primeiro';
      notifyListeners();
      return false;
    }

    _clearMessages();

    try {
      final category = QuestionCategory(
        id: '',
        name: name,
        description: description,
        courseId: _selectedCourseId!,
        subjectId: _selectedSubjectId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _teacherRepository.createCategory(category);
      _successMessage = 'Categoria criada com sucesso!';
      notifyListeners();
      await loadCategories();
      return true;
    } on TeacherRepositoryException catch (error) {
      _errorMessage = error.message;
      notifyListeners();
      return false;
    } catch (error) {
      _errorMessage = 'Erro ao criar categoria: $error';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCategory({
    required String categoryId,
    required String name,
    String? description,
  }) async {
    _clearMessages();

    try {
      final existing = _categories.firstWhere((c) => c.id == categoryId);
      final updated = existing.copyWith(name: name, description: description);

      await _teacherRepository.updateCategory(updated);
      _successMessage = 'Categoria atualizada com sucesso!';
      notifyListeners();
      await loadCategories();
      return true;
    } on TeacherRepositoryException catch (error) {
      _errorMessage = error.message;
      notifyListeners();
      return false;
    } catch (error) {
      _errorMessage = 'Erro ao atualizar categoria: $error';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCategory(String categoryId) async {
    _clearMessages();

    try {
      await _teacherRepository.deleteCategory(categoryId);
      _successMessage = 'Categoria excluída com sucesso!';
      notifyListeners();
      await loadCategories();
      return true;
    } on TeacherRepositoryException catch (error) {
      _errorMessage = error.message;
      notifyListeners();
      return false;
    } catch (error) {
      _errorMessage = 'Erro ao excluir categoria: $error';
      notifyListeners();
      return false;
    }
  }

  void _clearMessages() {
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
