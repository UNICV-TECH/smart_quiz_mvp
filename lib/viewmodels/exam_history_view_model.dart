import 'package:flutter/foundation.dart';
import 'package:unicv_tech_mvp/models/exam_history.dart';
import 'package:unicv_tech_mvp/services/repositorie/exam_history_repository.dart';

/// Holds the UI state for the exam history accordion component.
class ExamHistoryViewModel extends ChangeNotifier {
  final ExamHistoryRepository service;

  ExamHistoryViewModel({required this.service});

  List<SubjectExamHistory> _subjects = const [];
  bool _loading = false;
  String? _error;

  List<SubjectExamHistory> get subjects => _subjects;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> load() async {
    _setLoading(true);
    try {
      final results = await service.loadExamHistory();
      _subjects = results;
      _error = null;
    } catch (err, stack) {
      _error = err.toString();
      debugPrint('Failed to load exam history: $err');
      debugPrintStack(stackTrace: stack);
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }
}