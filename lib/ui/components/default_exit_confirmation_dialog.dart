import 'package:flutter/material.dart';
import '../theme/app_color.dart';

enum ExitConfirmationResult {
  continueWork,
  exitAndLose,
  finalizeNow,
}

class DefaultExitConfirmationDialog extends StatelessWidget {
  const DefaultExitConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.showFinalizeOption = false,
    this.finalizeMessage,
    this.answeredCount,
    this.totalQuestions,
  });

  final String title;
  final String message;
  final bool showFinalizeOption;
  final String? finalizeMessage;
  final int? answeredCount;
  final int? totalQuestions;

  static Future<ExitConfirmationResult?> show(
    BuildContext context, {
    required String title,
    required String message,
    bool showFinalizeOption = false,
    String? finalizeMessage,
    int? answeredCount,
    int? totalQuestions,
  }) {
    return showDialog<ExitConfirmationResult>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => DefaultExitConfirmationDialog(
        title: title,
        message: message,
        showFinalizeOption: showFinalizeOption,
        finalizeMessage: finalizeMessage,
        answeredCount: answeredCount,
        totalQuestions: totalQuestions,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      title: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AppColors.orange,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryDark,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.primaryDark,
              height: 1.5,
            ),
          ),
          if (showFinalizeOption &&
              answeredCount != null &&
              totalQuestions != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.blueShade,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.indigo, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Você respondeu $answeredCount de $totalQuestions questões.',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.indigo,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        // Continuar
        TextButton(
          onPressed: () =>
              Navigator.of(context).pop(ExitConfirmationResult.continueWork),
          child: const Text(
            'Continuar',
            style: TextStyle(
              color: AppColors.green,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        // Finalizar agora (opcional)
        if (showFinalizeOption)
          OutlinedButton(
            onPressed: () =>
                Navigator.of(context).pop(ExitConfirmationResult.finalizeNow),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.indigo,
              side: const BorderSide(color: AppColors.indigo),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Finalizar agora',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        // Sair e perder progresso
        ElevatedButton(
          onPressed: () => _confirmExit(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Sair',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmExit(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: AppColors.error, size: 28),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Tem certeza?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        content: const Text(
          'Essa ação não pode ser desfeita. Todo o seu progresso será perdido.',
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Sim, sair e perder progresso'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      Navigator.of(context).pop(ExitConfirmationResult.exitAndLose);
    }
  }
}
