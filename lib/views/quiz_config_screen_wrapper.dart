import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unicv_tech_mvp/constants/supabase_options.dart';
import 'package:unicv_tech_mvp/services/repositorie/exam_repository.dart';
import 'package:unicv_tech_mvp/services/repositorie/mock_exam_repository.dart';
import 'package:unicv_tech_mvp/viewmodels/quiz_config_view_model.dart';
import 'package:unicv_tech_mvp/views/QuizConfig_screen.dart';

/// Wrapper that provides QuizConfigViewModel to QuizConfigScreen
class QuizConfigScreenWrapper extends StatelessWidget {
  final Map<String, dynamic> course;

  const QuizConfigScreenWrapper({
    super.key,
    required this.course,
  });

  @override
  Widget build(BuildContext context) {
    // Determine which repository to use
    final ExamRepository examRepository = SupabaseOptions.isConfigured
        ? SupabaseExamRepository(client: Supabase.instance.client)
        : MockExamRepository();

    return ChangeNotifierProvider(
      create: (_) => QuizConfigViewModel(examRepository: examRepository),
      child: QuizConfigScreen(course: course),
    );
  }
}
