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

  int get totalCorrect => questions.where((q) => q.outcome == QuestionOutcome.correct).length;
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

  int get totalQuestions => attempts.fold<int>(0, (acc, attempt) => acc + attempt.totalQuestions);

  int get totalCorrect => attempts.fold<int>(0, (acc, attempt) => acc + attempt.totalCorrect);
}