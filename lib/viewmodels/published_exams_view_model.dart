import 'package:flutter/foundation.dart';

import '../models/exam_template.dart';
import '../repositories/published_exam_repository.dart';

class PublishedExamsViewModel extends ChangeNotifier {
  PublishedExamsViewModel({
    required PublishedExamRepository repository,
    required String courseId,
  })  : _repository = repository,
        _courseId = courseId;

  final PublishedExamRepository _repository;
  final String _courseId;

  List<ExamTemplate> _templates = [];
  List<ExamTemplate> get templates => _templates;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> loadTemplates() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _templates = await _repository.fetchPublishedTemplates(
        courseId: _courseId,
      );
    } catch (e) {
      _error = 'Erro ao carregar provas disponíveis.';
      debugPrint('PublishedExamsViewModel.loadTemplates error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> startExam({
    required String templateId,
    required String userId,
  }) async {
    _error = null;

    try {
      final examId = await _repository.startExamFromTemplate(
        templateId: templateId,
        userId: userId,
      );
      return examId;
    } catch (e) {
      _error = 'Erro ao iniciar a prova. Tente novamente.';
      debugPrint('PublishedExamsViewModel.startExam error: $e');
      notifyListeners();
      return null;
    }
  }
}
