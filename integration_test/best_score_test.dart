// Teste E2E: best-score-only "de verdade" em prova de TEMPLATE publicado.
//
// A regra (supabase_gamification_repository) compara a pontuacao por
// exam_template_id e so grava se melhorou o melhor score anterior. Simulados
// avulsos nao exercitam isso (cada um tem exam_id unico); por isso usamos a
// "Prova E2E" (template publicado semeado por scripts/e2e_setup.sh).
//
// Cenario (3 tentativas do MESMO template):
//   1. 4/5 (80%)  -> grava 1 registro.
//   2. 2/5 (40%)  -> PIOR que o melhor anterior -> NAO grava (regra chave).
//   3. 5/5 (100%) -> MELHOR -> grava o delta (novo registro).
// De brinde: valida o formato da season ativa ("YYYY.S").
//
// Pre-requisitos: `supabase start` + `bash scripts/e2e_setup.sh`.
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('best-score-only por template: pior nao soma, melhor soma delta',
      (WidgetTester tester) async {
    await bootAndReachHome(tester);

    // ── Tentativa 1: 4/5 = 80% -> grava ────────────────────────────────────
    await fazerProvaTemplate(tester, corretas: 4);
    await pumpUntil(tester, find.text('80%'));
    await voltarParaHome(tester);
    final apos1 = await pontosDoTemplate();
    expect(apos1.length, 1, reason: '1a tentativa deveria gravar 1 registro');

    // Season ativa no formato YYYY.S (RPC get_or_create_active_season).
    final season = await nomeSeasonAtiva();
    expect(RegExp(r'^\d{4}\.\d$').hasMatch(season), isTrue,
        reason: 'season deveria ser YYYY.S, veio "$season"');

    // ── Tentativa 2: 2/5 = 40% (pior) -> NAO grava ─────────────────────────
    await fazerProvaTemplate(tester, corretas: 2);
    await pumpUntil(tester, find.text('40%'));
    await voltarParaHome(tester);
    final apos2 = await pontosDoTemplate();
    expect(apos2.length, 1,
        reason: 'tentativa pior nao pode gravar (best-score-only)');

    // ── Tentativa 3: 5/5 = 100% (melhor) -> grava o delta ──────────────────
    await fazerProvaTemplate(tester, corretas: 5);
    await pumpUntil(tester, find.text('100%'));
    final apos3 = await pontosDoTemplate();
    expect(apos3.length, 2, reason: 'tentativa melhor deveria gravar o delta');

    final somaApos1 = comoDouble(apos1.first['total_points']);
    final somaApos3 =
        apos3.fold<double>(0, (s, r) => s + comoDouble(r['total_points']));
    expect(somaApos3 > somaApos1, isTrue,
        reason: 'o acumulado deve crescer apos a tentativa melhor');
  });
}
