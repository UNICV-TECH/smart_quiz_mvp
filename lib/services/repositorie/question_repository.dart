class Question {
  final int id;
  final String enunciation;
  final List<String> alternatives;
  final String? correctAnswer;

  Question({
    required this.id,
    required this.enunciation,
    required this.alternatives,
    this.correctAnswer,
  });
}

class Exam {
  final List<Question> questions;
  final int totalQuestions;

  Exam({
    required this.questions,
  }) : totalQuestions = questions.length;
}

