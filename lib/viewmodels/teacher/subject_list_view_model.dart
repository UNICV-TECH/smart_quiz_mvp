import 'package:flutter/material.dart';

import '../../models/course.dart';
import '../../models/subject.dart';
import '../../repositories/course_repository.dart';
import '../../repositories/course_repository_types.dart' as course_repo;
import '../../repositories/teacher_repository.dart';
import '../../repositories/teacher_repository_types.dart';

class SubjectListViewModel extends ChangeNotifier {
  SubjectListViewModel({
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
  String? _selectedCourseId;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  List<Course> get courses => List.unmodifiable(_courses);
  List<Subject> get subjects => List.unmodifiable(_subjects);
  String? get selectedCourseId => _selectedCourseId;

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
    _subjects = [];
    _clearMessages();
    notifyListeners();

    if (courseId != null) {
      loadSubjects();
    }
  }

  Future<void> loadSubjects() async {
    if (_selectedCourseId == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _subjects = await _teacherRepository.fetchSubjects(
        courseId: _selectedCourseId,
      );
    } catch (error) {
      _errorMessage = 'Erro ao carregar matérias: $error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createSubject({
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
      final subject = Subject(
        id: '',
        name: name,
        description: description,
        courseId: _selectedCourseId!,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _teacherRepository.createSubject(subject);
      _successMessage = 'Matéria criada com sucesso!';
      notifyListeners();
      await loadSubjects();
      return true;
    } on TeacherRepositoryException catch (error) {
      _errorMessage = error.message;
      notifyListeners();
      return false;
    } catch (error) {
      _errorMessage = 'Erro ao criar matéria: $error';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateSubject({
    required String subjectId,
    required String name,
    String? description,
  }) async {
    _clearMessages();

    try {
      final existing = _subjects.firstWhere((s) => s.id == subjectId);
      final updated = existing.copyWith(name: name, description: description);

      await _teacherRepository.updateSubject(updated);
      _successMessage = 'Matéria atualizada com sucesso!';
      notifyListeners();
      await loadSubjects();
      return true;
    } on TeacherRepositoryException catch (error) {
      _errorMessage = error.message;
      notifyListeners();
      return false;
    } catch (error) {
      _errorMessage = 'Erro ao atualizar matéria: $error';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteSubject(String subjectId) async {
    _clearMessages();

    try {
      await _teacherRepository.deleteSubject(subjectId);
      _successMessage = 'Matéria excluída com sucesso!';
      notifyListeners();
      await loadSubjects();
      return true;
    } on TeacherRepositoryException catch (error) {
      _errorMessage = error.message;
      notifyListeners();
      return false;
    } catch (error) {
      _errorMessage = 'Erro ao excluir matéria: $error';
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
