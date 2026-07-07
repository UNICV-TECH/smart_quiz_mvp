// Teste E2E: dirige o app real (login -> curso -> simulado -> resultado) contra o
// Supabase LOCAL, validando as regras de negocio de scoring de ponta a ponta.
//
// Pre-requisitos (feitos pelo CI / manualmente):
//   1. `supabase start` no ar.
//   2. `bash scripts/e2e_setup.sh` (cria aluno e2e@test.dev e o curso "Curso E2E").
//   3. Rodar via `flutter drive` apontando o app pro local:
//      flutter drive \
//        --driver=test_driver/integration_test.dart \
//        --target=integration_test/exam_flow_test.dart \
//        -d chrome --headless \
//        --dart-define=SUPABASE_URL=http://127.0.0.1:54321 \
//        --dart-define=SUPABASE_ANON_KEY=<anon local>
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:unicv_tech_mvp/main.dart' as app;

/// Bombeia frames ate `finder` aparecer (ou estourar o timeout). Evita
/// pumpAndSettle, que trava com o ConfettiWidget da tela de resultado e com
/// loaders/animacoes contínuas.
Future<void> pumpUntil(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 30),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 250));
    if (finder.evaluate().isNotEmpty) return;
  }
  throw TestFailure('Timeout esperando por: $finder');
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('aluno faz simulado de 5 questoes e ve 80% no resultado',
      (WidgetTester tester) async {
    app.main();
    await tester.pump(const Duration(seconds: 2));

    // --- Splash -> Welcome: tocar em "Entrar" abre /login ---
    await pumpUntil(tester, find.text('Bem-vindo'));
    await tester.tap(find.text('Entrar'));
    await tester.pump(const Duration(milliseconds: 500));

    // --- Login (os dois campos so existem aqui) ---
    await pumpUntil(tester, find.byType(TextFormField));
    final campos = find.byType(TextFormField);
    await tester.enterText(campos.at(0), 'e2e@test.dev');
    await tester.enterText(campos.at(1), 'pass1234');
    await tester.pump(const Duration(milliseconds: 300));
    // Submete via acao "done" do campo senha (onFieldSubmitted -> _handleLogin),
    // evitando depender do botao estar visivel na viewport do teste.
    await tester.testTextInput.receiveAction(TextInputAction.done);

    // --- Home: escolher o curso ---
    await pumpUntil(tester, find.text('Curso E2E'));
    await tester.tap(find.text('Curso E2E'));

    // --- QuizConfig: 5 questoes -> Iniciar ---
    await pumpUntil(tester, find.byKey(const ValueKey('5')));
    await tester.tap(find.byKey(const ValueKey('5')));
    await tester.pump(const Duration(milliseconds: 300));
    await pumpUntil(tester, find.text('Iniciar'));
    await tester.tap(find.text('Iniciar'));

    // --- Exame: 4 corretas (CERTA) + 1 errada (ERRADA A) = 80% ---
    for (var q = 1; q <= 5; q++) {
      await pumpUntil(tester, find.text('CERTA'));
      if (q <= 4) {
        await tester.tap(find.text('CERTA'));
      } else {
        await tester.tap(find.text('ERRADA A').first);
      }
      await tester.pump(const Duration(milliseconds: 300));

      if (q < 5) {
        await pumpUntil(tester, find.text('Próxima'));
        await tester.tap(find.text('Próxima'));
      } else {
        await pumpUntil(tester, find.text('Finalizar'));
        await tester.tap(find.text('Finalizar')); // abre o dialogo
        await pumpUntil(tester, find.byKey(const Key('dialog_finish')));
        await tester.tap(find.byKey(const Key('dialog_finish')));
      }
    }

    // --- Resultado: scoring correto (regra de negocio) ---
    await pumpUntil(tester, find.text('80%'));
    expect(find.text('80%'), findsOneWidget);
    expect(find.textContaining('acertou 4 de 5'), findsOneWidget);
  });
}
