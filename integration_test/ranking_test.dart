// Teste E2E: o ranking reflete os pontos gravados (SQL view ranking_global_view).
//
// O aluno faz um simulado (gera pontos), abre a aba Ranking e ve seu nome
// (first_name "AlunoE2E", semeado por scripts/e2e_setup.sh) na aba "Geral".
//
// Pre-requisitos: `supabase start` + `bash scripts/e2e_setup.sh`.
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('ranking global mostra o aluno com seus pontos',
      (WidgetTester tester) async {
    await bootAndReachHome(tester);

    // Garante que o aluno tem pontos na temporada.
    await fazerSimulado(tester, corretas: 5);
    await pumpUntil(tester, find.text('100%'));
    await voltarParaHome(tester);

    // Abre a aba Ranking (item da navbar) — a aba "Geral" carrega sozinha.
    await tester.tap(find.text('Ranking'));
    await pumpUntil(tester, find.text('AlunoE2E'));
    expect(find.text('AlunoE2E'), findsWidgets);
  });
}
