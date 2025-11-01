import 'package:flutter/material.dart';

import '../theme/app_color.dart';
import 'feedback_severity.dart';

class DefaultInlineMessage extends StatelessWidget {
  const DefaultInlineMessage({
    super.key,
    required this.message,
    required this.severity,
    this.title,
    this.onDismissed,
    this.padding,
    this.margin,
    this.showIcon = true,
  });

  final String message;
  final FeedbackSeverity severity;
  final String? title;
  final VoidCallback? onDismissed;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    final visuals = feedbackVisualsFor(severity);
    final theme = Theme.of(context);

    return Semantics(
      container: true,
      liveRegion: true,
      label: '${visuals.semanticsPrefix}: ${title ?? message}',
      child: Container(
        margin: margin ?? EdgeInsets.zero,
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: visuals.backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: visuals.borderColor),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showIcon)
              Icon(
                visuals.icon,
                color: visuals.iconColor,
                size: 24,
              ),
            if (showIcon) const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (title != null && title!.isNotEmpty)
                    Text(
                      title!,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: visuals.borderColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  Text(
                    message,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
            ),
            if (onDismissed != null)
              IconButton(
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.close),
                color: AppColors.secondaryDark,
                tooltip: 'Dismiss message',
                onPressed: onDismissed,
              ),
          ],
        ),
      ),
    );
  }
}
