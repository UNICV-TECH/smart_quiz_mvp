class ExamAutoSaveService {
  static void saveState({
    required String examId,
    required Map<String, String> selectedAnswers,
    required int currentQuestionIndex,
    required String? attemptId,
    required String startedAt,
  }) {
    // No-op on non-web platforms
  }

  static Map<String, dynamic>? loadState(String examId) {
    return null;
  }

  static void clearState(String examId) {
    // No-op on non-web platforms
  }

  static bool hasSavedState(String examId) {
    return false;
  }

  static void clearAllExamStates() {
    // No-op on non-web platforms
  }
}
