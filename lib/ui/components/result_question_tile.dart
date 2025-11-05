import 'package:flutter/material.dart';
import 'package:unicv_tech_mvp/ui/theme/app_color.dart';

class ResultQuestionTile extends StatefulWidget {
  const ResultQuestionTile({
    super.key,
    required this.questionNumber,
    required this.enunciation,
    required this.correctChoiceKey,
    required this.correctChoiceText,
    this.selectedChoiceKey,
    this.selectedChoiceText,
    this.isCorrect = false,
    this.isAnswered = false,
  });

  final int questionNumber;
  final String enunciation;
  final String correctChoiceKey;
  final String correctChoiceText;
  final String? selectedChoiceKey;
  final String? selectedChoiceText;
  final bool isCorrect;
  final bool isAnswered;

  @override
  State<ResultQuestionTile> createState() => _ResultQuestionTileState();
}

class _ResultQuestionTileState extends State<ResultQuestionTile> {
  bool _expanded = false;

  Color get _statusColor {
    if (!widget.isAnswered) {
      return AppColors.secondaryDark.withAlpha((0.4 * 255).round());
    }
    return widget.isCorrect ? const Color(0xFF3F8B3A) : const Color(0xFFD9503F);
  }

  Color get _statusBackground {
    if (!widget.isAnswered) {
      return Colors.transparent;
    }
    return widget.isCorrect ? const Color(0xFFE5F4E3) : const Color(0xFFF9E5E3);
  }

  IconData get _statusIcon {
    if (!widget.isAnswered) {
      return Icons.remove_circle_outline;
    }
    return widget.isCorrect ? Icons.check_circle : Icons.cancel_outlined;
  }

  String get _statusLabel {
    if (!widget.isAnswered) {
      return 'Não respondida';
    }
    return widget.isCorrect ? 'Correta' : 'Incorreta';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.titleMedium?.copyWith(
      color: AppColors.primaryDark,
      fontWeight: FontWeight.w700,
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: Colors.white.withAlpha((0.95 * 255).round()),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _statusColor.withAlpha((0.4 * 255).round())),
        boxShadow: _expanded
            ? [
                BoxShadow(
                  color: _statusColor.withAlpha((0.25 * 255).round()),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withAlpha((0.08 * 255).round()),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: _statusBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _statusColor, width: 1.5),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${widget.questionNumber}',
                          style: TextStyle(
                            color: _statusColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Questão ${widget.questionNumber}',
                                style: titleStyle),
                            const SizedBox(height: 4),
                            Text(
                              widget.enunciation,
                              maxLines: _expanded ? null : 2,
                              overflow: _expanded
                                  ? TextOverflow.visible
                                  : TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppColors.primaryDark
                                    .withAlpha((0.85 * 255).round()),
                                height: 1.45,
                              ),
                              textAlign: TextAlign.justify,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Icon(
                            _statusIcon,
                            color: _statusColor,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _statusLabel,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: _statusColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          AnimatedRotation(
                            duration: const Duration(milliseconds: 200),
                            turns: _expanded ? 0.5 : 0.0,
                            child: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (_expanded) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white.withAlpha((0.85 * 255).round()),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.secondaryDark
                              .withAlpha((0.2 * 255).round()),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text.rich(
                            TextSpan(
                              text: 'Sua resposta: ',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.w600,
                              ),
                              children: [
                                TextSpan(
                                  text: widget.isAnswered
                                      ? '${widget.selectedChoiceKey}) ${widget.selectedChoiceText ?? '-'}'
                                      : 'Não respondida',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: widget.isAnswered
                                        ? AppColors.primaryDark
                                        : AppColors.secondaryDark,
                                    fontWeight: widget.isAnswered
                                        ? FontWeight.w500
                                        : FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text.rich(
                            TextSpan(
                              text: 'Resposta correta: ',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.w600,
                              ),
                              children: [
                                TextSpan(
                                  text:
                                      '${widget.correctChoiceKey}) ${widget.correctChoiceText}',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: const Color(0xFF3F8B3A),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
