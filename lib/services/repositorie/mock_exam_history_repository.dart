import 'dart:async';
import 'package:flutter/material.dart';
import 'package:unicv_tech_mvp/models/exam_history.dart';
import 'package:unicv_tech_mvp/services/repositorie/exam_history_repository.dart';

/// Simple in-memory repository used for previews and local development.
class MockExamHistoryRepository implements ExamHistoryRepository {
  @override
  Future<List<SubjectExamHistory>> fetchSubjectExamHistories() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));

    return [
      SubjectExamHistory(
        subjectId: 'psicologia',
        subjectName: 'Psicologia',
        iconKey: 'psychology',
        fallbackIcon: Icons.psychology_alt_outlined,
        attempts: [
          _attempt(
            id: 'psi-001',
            date: DateTime(2025, 9, 8),
            duration: const Duration(minutes: 10, seconds: 32),
            outcomes: [
              QuestionOutcome.correct,
              QuestionOutcome.correct,
              QuestionOutcome.incorrect,
              QuestionOutcome.correct,
              QuestionOutcome.correct,
              QuestionOutcome.correct,
            ],
          ),
          _attempt(
            id: 'psi-002',
            date: DateTime(2025, 9, 16),
            duration: const Duration(minutes: 11, seconds: 12),
            outcomes: [
              QuestionOutcome.correct,
              QuestionOutcome.incorrect,
              QuestionOutcome.correct,
              QuestionOutcome.correct,
              QuestionOutcome.correct,
              QuestionOutcome.unanswered,
            ],
          ),
        ],
      ),
      SubjectExamHistory(
        subjectId: 'ciencias_sociais',
        subjectName: 'Ciências Sociais',
        iconKey: 'social_sciences',
        fallbackIcon: Icons.groups_2_outlined,
        attempts: [
          _attempt(
            id: 'soc-001',
            date: DateTime(2025, 8, 28),
            duration: const Duration(minutes: 9, seconds: 45),
            outcomes: [
              QuestionOutcome.correct,
              QuestionOutcome.correct,
              QuestionOutcome.correct,
              QuestionOutcome.correct,
            ],
          ),
        ],
      ),
      SubjectExamHistory(
        subjectId: 'gestao_financeira',
        subjectName: 'Gestão financeira',
        iconKey: 'financial',
        fallbackIcon: Icons.request_quote_outlined,
        attempts: [
          _attempt(
            id: 'fin-001',
            date: DateTime(2025, 8, 5),
            duration: const Duration(minutes: 12, seconds: 5),
            outcomes: [
              QuestionOutcome.correct,
              QuestionOutcome.incorrect,
              QuestionOutcome.correct,
              QuestionOutcome.correct,
              QuestionOutcome.incorrect,
            ],
          ),
        ],
      ),
      SubjectExamHistory(
        subjectId: 'administracao',
        subjectName: 'Administração',
        iconKey: 'administration',
        fallbackIcon: Icons.settings_suggest_outlined,
        attempts: [
          _attempt(
            id: 'adm-001',
            date: DateTime(2025, 7, 24),
            duration: const Duration(minutes: 8, seconds: 41),
            outcomes: [
              QuestionOutcome.correct,
              QuestionOutcome.correct,
              QuestionOutcome.correct,
              QuestionOutcome.unanswered,
              QuestionOutcome.correct,
            ],
          ),
        ],
      ),
      SubjectExamHistory(
        subjectId: 'pedagogia',
        subjectName: 'Pedagogia',
        iconKey: 'pedagogy',
        fallbackIcon: Icons.school_outlined,
        attempts: [
          _attempt(
            id: 'ped-001',
            date: DateTime(2025, 7, 3),
            duration: const Duration(minutes: 7, seconds: 55),
            outcomes: [
              QuestionOutcome.correct,
              QuestionOutcome.correct,
              QuestionOutcome.correct,
              QuestionOutcome.correct,
            ],
          ),
        ],
      ),
      SubjectExamHistory(
        subjectId: 'design_grafico',
        subjectName: 'Design Gráfico',
        iconKey: 'design',
        fallbackIcon: Icons.design_services_outlined,
        attempts: [
          _attempt(
            id: 'des-001',
            date: DateTime(2025, 6, 25),
            duration: const Duration(minutes: 9, seconds: 18),
            outcomes: [
              QuestionOutcome.correct,
              QuestionOutcome.correct,
              QuestionOutcome.incorrect,
              QuestionOutcome.correct,
            ],
          ),
        ],
      ),
      SubjectExamHistory(
        subjectId: 'direito',
        subjectName: 'Direito',
        iconKey: 'law',
        fallbackIcon: Icons.balance_outlined,
        attempts: [
          _attempt(
            id: 'dir-001',
            date: DateTime(2025, 5, 30),
            duration: const Duration(minutes: 11, seconds: 2),
            outcomes: [
              QuestionOutcome.correct,
              QuestionOutcome.correct,
              QuestionOutcome.correct,
              QuestionOutcome.correct,
              QuestionOutcome.correct,
            ],
          ),
        ],
      ),
    ];
  }

  ExamAttempt _attempt({
    required String id,
    required DateTime date,
    required Duration duration,
    required List<QuestionOutcome> outcomes,
  }) {
    return ExamAttempt(
      id: id,
      date: date,
      duration: duration,
      questions: _buildSequence(outcomes: outcomes),
    );
  }

  List<ExamQuestionResult> _buildSequence(
      {required List<QuestionOutcome> outcomes}) {
    return [
      for (int i = 0; i < outcomes.length; i++)
        ExamQuestionResult(
          number: i + 1,
          outcome: outcomes[i],
        )
    ];
  }

  @override
  Future loadExamHistory() {
    throw UnimplementedError();
  }
}
