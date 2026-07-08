// Teste E2E: dirige o app real (login -> curso -> simulado -> resultado) contra
// o Supabase LOCAL, validando as regras de negocio de scoring e gamificacao de
// ponta a ponta, num unico fluxo continuo (sem reiniciar o app entre cenarios).
//
// Cenarios cobertos:
//   1. Scoring parcial: 5 questoes, 4 certas -> 80% na tela de resultado.
//   2. Persistencia: cada prova grava 1 registro de pontos no banco
//      (public.user_gamification_points).
//   3. Scoring cheio: 5 questoes, 5 certas -> 100%.
//   4. Retake nao pontua: refazer a prova NAO grava novo registro de pontos.
//
// Pre-requisitos (feitos pelo CI / manualmente):
//   1. `supabase start` no ar (aplica migrations: baseline + RLS).
//   2. `bash scripts/e2e_setup.sh` (cria aluno e2e@test.dev e o curso "Curso E2E").
//   3. Rodar em Linux desktop (CI) ou macOS (local):
//      flutter test integration_test/exam_flow_test.dart -d linux \
//        --dart-define=SUPABASE_URL=http://127.0.0.1:54321 \
//        --dart-define=SUPABASE_ANON_KEY=<anon local>
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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

/// Retorna o indice do primeiro finder de `finders` que aparecer (ou timeout).
/// Usado para tolerar dois estados iniciais possiveis (welcome vs home).
Future<int> pumpUntilAny(
  WidgetTester tester,
  List<Finder> finders, {
  Duration timeout = const Duration(seconds: 30),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 250));
    for (var i = 0; i < finders.length; i++) {
      if (finders[i].evaluate().isNotEmpty) return i;
    }
  }
  throw TestFailure('Timeout esperando por qualquer um de: $finders');
}

/// Sobe o app, garante login como o aluno de teste e para na Home. Tolera uma
/// sessao ja persistida em disco (nesse caso o app cai direto na Home).
Future<void> bootAndReachHome(WidgetTester tester) async {
  app.main();
  await tester.pump(const Duration(seconds: 2));

  // Ou cai na Welcome (precisa logar) ou ja na Home (sessao persistida).
  final idx = await pumpUntilAny(
    tester,
    [find.text('Bem-vindo'), find.text('Curso E2E')],
  );

  if (idx == 0) {
    // Welcome -> Login (os dois campos so existem na tela de login).
    await tester.tap(find.text('Entrar'));
    await tester.pump(const Duration(milliseconds: 500));
    await pumpUntil(tester, find.byType(TextFormField));
    final campos = find.byType(TextFormField);
    await tester.enterText(campos.at(0), 'e2e@test.dev');
    await tester.enterText(campos.at(1), 'pass1234');
    await tester.pump(const Duration(milliseconds: 300));
    // Submete via acao "done" do campo senha (onFieldSubmitted -> _handleLogin),
    // evitando depender do botao estar visivel na viewport do teste.
    await tester.testTextInput.receiveAction(TextInputAction.done);
  }

  await pumpUntil(tester, find.text('Curso E2E'));
}

/// Responde as 5 questoes da prova (as `corretas` primeiras com "CERTA", o
/// resto com "ERRADA A") e finaliza pelo dialogo. Assume estar na tela do exame.
Future<void> responderExame(WidgetTester tester, {required int corretas}) async {
  for (var q = 1; q <= 5; q++) {
    await pumpUntil(tester, find.text('CERTA'));
    if (q <= corretas) {
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
}

/// Da a Home, inicia um simulado de 5 questoes e responde `corretas` certas.
/// Deixa na tela de resultado.
Future<void> fazerSimulado(WidgetTester tester, {required int corretas}) async {
  await tester.tap(find.text('Curso E2E'));
  await pumpUntil(tester, find.byKey(const ValueKey('5')));
  await tester.tap(find.byKey(const ValueKey('5')));
  await tester.pump(const Duration(milliseconds: 300));
  await pumpUntil(tester, find.text('Iniciar'));
  await tester.tap(find.text('Iniciar'));
  await responderExame(tester, corretas: corretas);
}

/// Rola a tela de resultado (CustomScrollView lazy) ate o `alvo` ser construido
/// e o toca. Drag manual (pump, nao pumpAndSettle) por causa do confetti; os
/// botoes do rodape so entram na arvore ao rolar ate o fim.
Future<void> scrollAteTocar(WidgetTester tester, Finder alvo) async {
  for (var i = 0; i < 30 && alvo.evaluate().isEmpty; i++) {
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
    await tester.pump(const Duration(milliseconds: 200));
  }
  await tester.ensureVisible(alvo);
  await tester.pump(const Duration(milliseconds: 300));
  await tester.tap(alvo);
}

/// Volta da tela de resultado para a Home.
Future<void> voltarParaHome(WidgetTester tester) async {
  await scrollAteTocar(tester, find.text('Voltar ao início'));
  await pumpUntil(tester, find.text('Curso E2E'));
}

/// Quantos registros de pontos o aluno logado ja tem no banco (via cliente
/// autenticado do proprio app — RLS permite ler os proprios pontos).
Future<int> contarRegistrosDePontos() async {
  final client = Supabase.instance.client;
  final uid = client.auth.currentUser!.id;
  final rows = await client
      .from('user_gamification_points')
      .select('total_points')
      .eq('user_id', uid);
  return (rows as List).length;
}

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
