import 'package:flutter/material.dart';

import '../../models/exam_template.dart';
import '../../repositories/admin_repository.dart';
import '../../repositories/admin_repository_types.dart';

class AdminContentViewModel extends ChangeNotifier {
  AdminContentViewModel({
    required AdminRepository adminRepository,
  }) : _adminRepository = adminRepository;

  final AdminRepository _adminRepository;

  // State
  bool _isLoading = false;
  String? _errorMessage;

  // Data
  List<AdminQuestionEntry> _questions = [];
  List<ExamTemplate> _templates = [];
  List<AdminCourseEntry> _courses = [];

  // Sort state for questions
  int _sortColumnIndex = 0;
  bool _sortAscending = true;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<AdminQuestionEntry> get questions => List.unmodifiable(_questions);
  List<ExamTemplate> get templates => List.unmodifiable(_templates);
  List<AdminCourseEntry> get courses => List.unmodifiable(_courses);
  int get sortColumnIndex => _sortColumnIndex;
  bool get sortAscending => _sortAscending;

  // Load all content
  Future<void> loadContent() async {
    _setLoading(true);
    _clearError();

    try {
      final results = await Future.wait([
        _adminRepository.listQuestions(const AdminQuestionsFilter()),
        _adminRepository.listTemplates(),
        _adminRepository.listCourses(),
      ]);
      _questions = results[0] as List<AdminQuestionEntry>;
      _templates = results[1] as List<ExamTemplate>;
      _courses = results[2] as List<AdminCourseEntry>;
    } catch (error) {
      _setError('$error');
      _questions = [];
      _templates = [];
      _courses = [];
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refresh() async {
    await loadContent();
  }

  void sortQuestions(int columnIndex, bool ascending) {
    _sortColumnIndex = columnIndex;
    _sortAscending = ascending;

    _questions.sort((a, b) {
      int result;
      switch (columnIndex) {
        case 0: // Enunciado
          result = a.enunciation.toLowerCase().compareTo(b.enunciation.toLowerCase());
        case 1: // Curso
          result = a.courseName.toLowerCase().compareTo(b.courseName.toLowerCase());
        case 2: // Professor
          final nameA = a.teacherName.isEmpty ? a.teacherEmail : a.teacherName;
          final nameB = b.teacherName.isEmpty ? b.teacherEmail : b.teacherName;
          result = nameA.toLowerCase().compareTo(nameB.toLowerCase());
        case 3: // Dificuldade
          result = (a.difficultyLevel ?? '').compareTo(b.difficultyLevel ?? '');
        case 4: // Respostas
          result = a.answerCount.compareTo(b.answerCount);
        case 5: // Status
          result = (a.isActive ? 1 : 0).compareTo(b.isActive ? 1 : 0);
        default:
          result = 0;
      }
      return ascending ? result : -result;
    });

    notifyListeners();
  }

  // Helper methods
  void _setLoading(bool value) {
    if (_isLoading == value) return;
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }
}
