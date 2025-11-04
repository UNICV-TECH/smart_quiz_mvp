import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unicv_tech_mvp/ui/components/default_feedback_dialog.dart';
import 'package:unicv_tech_mvp/ui/components/default_inline_message.dart';
import 'package:unicv_tech_mvp/ui/components/feedback_severity.dart';
import 'package:unicv_tech_mvp/ui/theme/app_color.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DefaultInlineMessage', () {
    testWidgets('renders message with severity icon and semantics label',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DefaultInlineMessage(
              message: 'Operação concluída com sucesso.',
              severity: FeedbackSeverity.success,
            ),
          ),
        ),
      );

      expect(find.text('Operação concluída com sucesso.'), findsOneWidget);
      final iconWidget = tester.widget<Icon>(find.byIcon(Icons.check_circle));
      expect(iconWidget.color, AppColors.green1);

      final semanticsWidget = tester.widget<Semantics>(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.label ==
                  'Success: Operação concluída com sucesso.',
        ),
      );
      expect(semanticsWidget.properties.liveRegion, isTrue);
    });

    testWidgets('invokes dismiss callback when close button is tapped',
        (tester) async {
      var dismissed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DefaultInlineMessage(
              message: 'Algo deu errado.',
              severity: FeedbackSeverity.error,
              onDismissed: () {
                dismissed = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(dismissed, isTrue);
    });
  });

  group('DefaultFeedbackDialog', () {
    testWidgets('shows dialog with default action and severity styling',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      DefaultFeedbackDialog.show<void>(
                        context,
                        title: 'Erro ao finalizar',
                        message: 'Não foi possível concluir a ação.',
                        severity: FeedbackSeverity.error,
                        barrierDismissible: false,
                      );
                    },
                    child: const Text('Abrir'),
                  ),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();

      expect(find.text('Erro ao finalizar'), findsOneWidget);
      expect(find.text('Não foi possível concluir a ação.'), findsOneWidget);

      final iconWidget = tester.widget<Icon>(find.byIcon(Icons.error_outline));
      expect(iconWidget.color, AppColors.error);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(find.text('Erro ao finalizar'), findsNothing);
    });
  });
}
