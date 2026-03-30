import 'package:flutter/material.dart';

import '../../models/teacher_stats.dart';
import '../../repositories/teacher_repository.dart';

class TeacherDashboardViewModel extends ChangeNotifier {
  TeacherDashboardViewModel({
    required String teacherId,
    required TeacherRepository teacherRepository,
  })  : _teacherId = teacherId,
        _teacherRepository = teacherRepository;

  final String _teacherId;
  final TeacherRepository _teacherRepository;

  // State
  bool _isLoading = false;
  String? _errorMessage;

  // Data
  List<TeacherQuestionStats> _questionStats = [];
  List<TeacherExamStats> _examStats = [];

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<TeacherQuestionStats> get questionStats =>
      List.unmodifiable(_questionStats);
  List<TeacherExamStats> get examStats => List.unmodifiable(_examStats);

  TeacherDashboardStats get dashboardStats => TeacherDashboardStats(
        questionStats: _questionStats,
        examStats: _examStats,
      );

  // Computed stats
  int get totalQuestions =>
      _questionStats.fold(0, (sum, s) => sum + s.totalQuestions);

  int get activeQuestions =>
      _questionStats.fold(0, (sum, s) => sum + s.activeQuestions);

  int get totalTemplates =>
      _examStats.fold(0, (sum, s) => sum + s.totalTemplates);

  int get publishedTemplates =>
      _examStats.fold(0, (sum, s) => sum + s.publishedTemplates);

  int get totalExamsTaken =>
      _examStats.fold(0, (sum, s) => sum + s.totalExamsTaken);

  int get totalPassed => _examStats.fold(0, (sum, s) => sum + s.totalPassed);

  double get overallPassRate {
    if (totalExamsTaken == 0) return 0.0;
    return (totalPassed / totalExamsTaken) * 100;
  }

  double get overallAvgScore {
    if (_examStats.isEmpty) return 0.0;
    final total = _examStats.fold(0.0, (sum, s) => sum + s.avgScore);
    return total / _examStats.length;
  }

  int get coursesWithQuestions => _questionStats.length;
  int get coursesWithExams => _examStats.length;

  // Load data
  Future<void> loadStats() async {
    _setLoading(true);
    _clearError();

    try {
      final results = await Future.wait([
        _teacherRepository.getQuestionStats(_teacherId),
        _teacherRepository.getExamStats(_teacherId),
      ]);
      _questionStats = results[0] as List<TeacherQuestionStats>;
      _examStats = results[1] as List<TeacherExamStats>;
    } catch (error) {
      _setError('Erro ao carregar estatísticas: $error');
      _questionStats = [];
      _examStats = [];
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refresh() async {
    await loadStats();
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
