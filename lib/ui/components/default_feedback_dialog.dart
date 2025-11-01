import 'package:flutter/material.dart';

import '../theme/app_color.dart';
import 'feedback_severity.dart';

class DefaultFeedbackDialog extends StatelessWidget {
  const DefaultFeedbackDialog({
    super.key,
    required this.title,
    required this.message,
    this.severity = FeedbackSeverity.info,
    this.actions,
  });

  final String title;
  final String message;
  final FeedbackSeverity severity;
  final List<Widget>? actions;

  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required String message,
    FeedbackSeverity severity = FeedbackSeverity.info,
    List<Widget>? actions,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (dialogContext) => DefaultFeedbackDialog(
        title: title,
        message: message,
        severity: severity,
        actions: actions,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visuals = feedbackVisualsFor(severity);
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            visuals.icon,
            color: visuals.iconColor,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                color: visuals.iconColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 280),
        child: Text(
          message,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.primaryDark,
          ),
        ),
      ),
      actions: actions ?? <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    );
  }
}
