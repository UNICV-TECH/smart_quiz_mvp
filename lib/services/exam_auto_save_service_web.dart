import 'dart:convert';
import 'package:web/web.dart' as web;

class ExamAutoSaveService {
  static const _keyPrefix = 'smart_quiz_exam_';

  static void saveState({
    required String examId,
    required Map<String, String> selectedAnswers,
    required int currentQuestionIndex,
    required String? attemptId,
    required String startedAt,
  }) {
    final data = {
      'examId': examId,
      'selectedAnswers': selectedAnswers,
      'currentQuestionIndex': currentQuestionIndex,
      'attemptId': attemptId,
      'startedAt': startedAt,
      'savedAt': DateTime.now().toIso8601String(),
    };
    web.window.localStorage.setItem('$_keyPrefix$examId', jsonEncode(data));
  }

  static Map<String, dynamic>? loadState(String examId) {
    final raw = web.window.localStorage.getItem('$_keyPrefix$examId');
    if (raw == null) return null;

    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;

      // Check if saved state is older than 4 hours (exam likely expired)
      final savedAt = DateTime.tryParse(data['savedAt'] as String? ?? '');
      if (savedAt != null &&
          DateTime.now().difference(savedAt).inHours >= 4) {
        clearState(examId);
        return null;
      }

      return data;
    } catch (_) {
      clearState(examId);
      return null;
    }
  }

  static void clearState(String examId) {
    web.window.localStorage.removeItem('$_keyPrefix$examId');
  }

  static bool hasSavedState(String examId) {
    return web.window.localStorage.getItem('$_keyPrefix$examId') != null;
  }

  static void clearAllExamStates() {
    final storage = web.window.localStorage;
    final keysToRemove = <String>[];
    for (var i = 0; i < storage.length; i++) {
      final key = storage.key(i);
      if (key != null && key.startsWith(_keyPrefix)) {
        keysToRemove.add(key);
      }
    }
    for (final key in keysToRemove) {
      storage.removeItem(key);
    }
  }
}
