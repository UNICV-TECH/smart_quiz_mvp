import 'package:flutter/material.dart';

import '../theme/app_color.dart';

enum FeedbackSeverity { success, error, warning, info }

class FeedbackVisuals {
  const FeedbackVisuals({
    required this.backgroundColor,
    required this.borderColor,
    required this.iconColor,
    required this.icon,
    required this.semanticsPrefix,
  });

  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;
  final IconData icon;
  final String semanticsPrefix;
}

FeedbackVisuals feedbackVisualsFor(FeedbackSeverity severity) {
  switch (severity) {
    case FeedbackSeverity.success:
      return const FeedbackVisuals(
        backgroundColor: Color(0xFFE8F5E9),
        borderColor: AppColors.green1,
        iconColor: AppColors.green1,
        icon: Icons.check_circle,
        semanticsPrefix: 'Success',
      );
    case FeedbackSeverity.error:
      return const FeedbackVisuals(
        backgroundColor: Color(0xFFFFEBEE),
        borderColor: AppColors.error,
        iconColor: AppColors.error,
        icon: Icons.error_outline,
        semanticsPrefix: 'Error',
      );
    case FeedbackSeverity.warning:
      return const FeedbackVisuals(
        backgroundColor: Color(0xFFFFF3E0),
        borderColor: AppColors.orange,
        iconColor: AppColors.orange,
        icon: Icons.warning_amber_rounded,
        semanticsPrefix: 'Warning',
      );
    case FeedbackSeverity.info:
      return const FeedbackVisuals(
        backgroundColor: Color(0xFFE3F2FD),
        borderColor: AppColors.indigo,
        iconColor: AppColors.indigo,
        icon: Icons.info_outline,
        semanticsPrefix: 'Info',
      );
  }
}
