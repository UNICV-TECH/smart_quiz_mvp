// Teste E2E: regras de scoring que faltavam no happy-path, num unico fluxo.
//
// Cenarios:
//   1. Reprovado (< 70%): 2/5 = 40% -> sem bonus de tempo (time_bonus == 0).
//   2. Faixa de pontos por quantidade: 10 acertos de 10 -> base = 10 * 1.25 = 12.5
//      (a faixa 6-10 questoes vale 1.25 por acerto, contra 1.0 na faixa <= 5).
//
// Pre-requisitos: `supabase start` + `bash scripts/e2e_setup.sh` (12 questoes).
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('reprovado (<70%) sem bonus de tempo; faixa 10q = 1.25/acerto',
      (WidgetTester tester) async {
    await bootAndReachHome(tester);

    // ── Cenario 1: 2/5 = 40% -> reprovado, sem bonus de tempo ──────────────
    await fazerSimulado(tester, corretas: 2);
    await pumpUntil(tester, find.text('40%'));
    expect(find.text('40%'), findsOneWidget);
    expect(find.textContaining('acertou 2 de 5'), findsOneWidget);

    final regReprovado = await ultimoRegistroDePontos();
    expect(comoDouble(regReprovado['percentage_score']), 40.0);
    expect(regReprovado['correct_count'], 2);
    expect(comoDouble(regReprovado['time_bonus']), 0.0,
        reason: 'prova reprovada (<70%) nao pode ganhar bonus de tempo');

    await voltarParaHome(tester);

    // ── Cenario 2: 10/10 = 100% -> faixa 6-10 questoes vale 1.25/acerto ─────
    await fazerSimulado(tester, corretas: 10, total: 10);
    await pumpUntil(tester, find.text('100%'));
    expect(find.text('100%'), findsOneWidget);

    final regFaixa = await ultimoRegistroDePontos();
    expect(regFaixa['question_count'], 10);
    expect(regFaixa['correct_count'], 10);
    expect(comoDouble(regFaixa['base_points']), 12.5,
        reason: 'faixa 6-10 questoes deve valer 1.25 por acerto');
  });
}
