import 'package:flutter/material.dart';

/// Indicates the outcome of a question within an exam attempt.
enum QuestionOutcome { correct, incorrect, unanswered }

/// Holds the status for a single question inside an exam attempt.
class ExamQuestionResult {
  final int number;
  final QuestionOutcome outcome;

  const ExamQuestionResult({
    required this.number,
    required this.outcome,
  });
}

/// Represents a finished exam attempt for a subject.
class ExamAttempt {
  final String id;
  final DateTime date;
  final Duration duration;
  final List<ExamQuestionResult> questions;

  const ExamAttempt({
    required this.id,
    required this.date,
    required this.duration,
    required this.questions,
  });

  int get totalQuestions => questions.length;

  int get totalCorrect =>
      questions.where((q) => q.outcome == QuestionOutcome.correct).length;
}

/// Aggregates the exam history for a single subject.
class SubjectExamHistory {
  final String subjectId;
  final String subjectName;
  final String iconKey;
  final IconData? fallbackIcon;
  final List<ExamAttempt> attempts;

  const SubjectExamHistory({
    required this.subjectId,
    required this.subjectName,
    required this.iconKey,
    this.fallbackIcon,
    required this.attempts,
  });

  int get totalExams => attempts.length;

  int get totalQuestions =>
      attempts.fold<int>(0, (acc, attempt) => acc + attempt.totalQuestions);

  int get totalCorrect =>
      attempts.fold<int>(0, (acc, attempt) => acc + attempt.totalCorrect);
}

class Question {
  final String id;
  final String enunciation;
  final String? difficultyLevel;
  final double points;

  Question({
    required this.id,
    required this.enunciation,
    this.difficultyLevel,
    this.points = 1.0,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      enunciation: json['enunciation'] as String,
      difficultyLevel: json['difficulty_level'] as String?,
      points: (json['points'] as num?)?.toDouble() ?? 1.0,
    );
  }
}

class AnswerChoice {
  final String id;
  final String questionId;
  final String choiceKey;
  final String choiceText;
  final bool isCorrect;
  final int choiceOrder;

  AnswerChoice({
    required this.id,
    required this.questionId,
    required this.choiceKey,
    required this.choiceText,
    required this.isCorrect,
    required this.choiceOrder,
  });

  factory AnswerChoice.fromJson(Map<String, dynamic> json) {
    return AnswerChoice(
      id: json['id'] as String,
      questionId: json['question_id'] as String,
      choiceKey: json['choice_key'] as String,
      choiceText: json['choice_text'] as String,
      isCorrect: json['is_correct'] as bool,
      choiceOrder: json['choice_order'] as int,
    );
  }
}

class SupportingText {
  final String id;
  final String questionId;
  final String? contentType;
  final String content;
  final int displayOrder;

  SupportingText({
    required this.id,
    required this.questionId,
    this.contentType,
    required this.content,
    required this.displayOrder,
  });

  factory SupportingText.fromJson(Map<String, dynamic> json) {
    return SupportingText(
      id: json['id'] as String,
      questionId: json['question_id'] as String,
      contentType: json['content_type'] as String?,
      content: json['content'] as String,
      displayOrder: json['display_order'] as int,
    );
  }
}

class ExamQuestion {
  final Question question;
  final List<AnswerChoice> answerChoices;
  final List<SupportingText> supportingTexts;

  ExamQuestion({
    required this.question,
    required this.answerChoices,
    required this.supportingTexts,
  });
}
