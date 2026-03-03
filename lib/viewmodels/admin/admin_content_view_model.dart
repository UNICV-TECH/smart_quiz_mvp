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

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<AdminQuestionEntry> get questions => List.unmodifiable(_questions);
  List<ExamTemplate> get templates => List.unmodifiable(_templates);
  List<AdminCourseEntry> get courses => List.unmodifiable(_courses);

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
      _setError('Erro ao carregar conteúdo: $error');
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
