import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unicv_tech_mvp/models/course.dart';
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
    DateTime createdAt = DateTime.now();
    final dynamic createdAtValue = course['created_at'];
    if (createdAtValue is DateTime) {
      createdAt = createdAtValue;
    } else if (createdAtValue is String) {
      createdAt = DateTime.tryParse(createdAtValue) ?? DateTime.now();
    }

    final courseModel = Course(
      id: course['id'] as String,
      courseKey:
          course['course_key'] as String? ?? course['courseId'] as String? ?? '',
      title: course['title'] as String? ?? 'Curso',
      description: course['description'] as String?,
      iconKey: course['icon_key'] as String?,
      iconData: course['icon'] as IconData?,
      isActive: course['is_active'] as bool? ?? true,
      createdAt: createdAt,
    );

    return ChangeNotifierProvider(
      create: (_) => QuizConfigViewModel(course: courseModel),
      child: QuizConfigScreen(course: course),
    );
  }
}
