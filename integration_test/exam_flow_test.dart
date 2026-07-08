// Teste E2E: fluxo do aluno (login -> curso -> simulado -> resultado) contra o
// Supabase LOCAL, validando scoring e gamificacao de ponta a ponta.
//
// Cenarios: 4/5 = 80% + persistencia; 5/5 = 100% + persistencia; retake nao pontua.
// Pre-requisitos: `supabase start` + `bash scripts/e2e_setup.sh`.
// Rodar: flutter test integration_test/ -d linux --dart-define=SUPABASE_URL=...
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('scoring (80% e 100%), persistencia e retake nao pontua',
      (WidgetTester tester) async {
    await bootAndReachHome(tester);

    // ── Cenario 1: 4/5 = 80% e grava 1 registro de pontos ──────────────────
    final c0 = await contarRegistrosDePontos();
    await fazerSimulado(tester, corretas: 4);
    await pumpUntil(tester, find.text('80%'));
    expect(find.text('80%'), findsOneWidget);
    expect(find.textContaining('acertou 4 de 5'), findsOneWidget);
    final c1 = await contarRegistrosDePontos();
    expect(c1, c0 + 1,
        reason: 'a prova deveria gravar 1 registro em user_gamification_points');

    await voltarParaHome(tester);

    // ── Cenario 2: 5/5 = 100% e grava mais 1 registro ──────────────────────
    await fazerSimulado(tester, corretas: 5);
    await pumpUntil(tester, find.text('100%'));
    expect(find.text('100%'), findsOneWidget);
    expect(find.textContaining('acertou 5 de 5'), findsOneWidget);
    final c2 = await contarRegistrosDePontos();
    expect(c2, c1 + 1, reason: 'a segunda prova tambem deveria gravar pontos');

    // ── Cenario 3: refazer a prova NAO grava novo registro ─────────────────
    await scrollAteTocar(tester, find.text('Refazer prova'));
    await responderExame(tester, corretas: 5);
    await pumpUntil(tester, find.text('100%'));
    final c3 = await contarRegistrosDePontos();
    expect(c3, c2, reason: 'retake nao deve gravar novos pontos');
  });
}
