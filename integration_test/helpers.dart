// Helpers compartilhados pelos integration_test E2E (dirigem o app real contra
// o Supabase LOCAL). Nao contem testes — so utilitarios de navegacao/consulta.
//
// Contas semeadas por scripts/e2e_setup.sh (senha=pass1234):
//   aluno     e2e@test.dev       (student, first_name "AlunoE2E")
//   professor e2e-prof@test.dev  (teacher)
//   admin     e2e-admin@test.dev (admin)
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unicv_tech_mvp/main.dart' as app;

const alunoEmail = 'e2e@test.dev';
const profEmail = 'e2e-prof@test.dev';
const adminEmail = 'e2e-admin@test.dev';
const senhaPadrao = 'pass1234';

/// Template publicado "Prova E2E" semeado por scripts/e2e_setup.sh.
const templateE2eId = 'e2e11111-1111-1111-1111-111111111111';

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

/// Preenche os campos de login (ja visiveis) e submete via acao "done" do campo
/// senha (onFieldSubmitted -> _handleLogin), sem depender do botao na viewport.
Future<void> preencherELogar(
  WidgetTester tester, {
  required String email,
  String senha = senhaPadrao,
}) async {
  await pumpUntil(tester, find.byType(TextFormField));
  final campos = find.byType(TextFormField);
  await tester.enterText(campos.at(0), email);
  await tester.enterText(campos.at(1), senha);
  await tester.pump(const Duration(milliseconds: 300));
  await tester.testTextInput.receiveAction(TextInputAction.done);
}

/// Sobe o app UMA vez e leva ate a tela de login (campos visiveis). Tolera
/// Welcome (toca "Entrar") e sessao ja persistida em disco (desloga -> /login).
///
/// IMPORTANTE: chame no maximo uma vez por teste. Um 2o `app.main()` no mesmo
/// processo re-dispara o dotenv.load e o erro vaza como falha — por isso cada
/// arquivo de teste deve ter um unico testWidgets. Para trocar de usuario no
/// meio do teste, use [relogar] (nao rebota o app).
Future<void> irParaLogin(WidgetTester tester) async {
  app.main();
  await tester.pump(const Duration(seconds: 2));

  // Se caiu logado (sessao persistida de outro arquivo), desloga -> vai a /login.
  for (var i = 0;
      i < 10 &&
          find.byType(TextFormField).evaluate().isEmpty &&
          find.text('Bem-vindo').evaluate().isEmpty;
      i++) {
    try {
      if (Supabase.instance.client.auth.currentUser != null) {
        await Supabase.instance.client.auth.signOut();
      }
    } catch (_) {}
    await tester.pump(const Duration(milliseconds: 500));
  }

  // Welcome -> Login.
  if (find.text('Bem-vindo').evaluate().isNotEmpty) {
    await tester.tap(find.text('Entrar'));
    await tester.pump(const Duration(milliseconds: 500));
  }
  await pumpUntil(tester, find.byType(TextFormField));
}

/// Sobe o app e faz login com a conta dada. Nao assere o destino — cada teste
/// verifica para onde o role redireciona.
Future<void> bootELogar(
  WidgetTester tester, {
  required String email,
  String senha = senhaPadrao,
}) async {
  await irParaLogin(tester);
  await preencherELogar(tester, email: email, senha: senha);
}

/// Troca de usuario SEM rebootar o app: desloga (redireciona para /login pela
/// regra do router) e loga com a nova conta.
Future<void> relogar(
  WidgetTester tester, {
  required String email,
  String senha = senhaPadrao,
}) async {
  await Supabase.instance.client.auth.signOut();
  await pumpUntil(tester, find.byType(TextFormField));
  await preencherELogar(tester, email: email, senha: senha);
}

/// Sobe o app, loga como o ALUNO e para na Home.
Future<void> bootAndReachHome(WidgetTester tester) async {
  await bootELogar(tester, email: alunoEmail);
  await pumpUntil(tester, find.text('Curso E2E'));
}

/// Responde as `total` questoes da prova (as `corretas` primeiras com "CERTA",
/// o resto com "ERRADA A") e finaliza pelo dialogo. Assume estar no exame.
Future<void> responderExame(
  WidgetTester tester, {
  required int corretas,
  int total = 5,
}) async {
  for (var q = 1; q <= total; q++) {
    await pumpUntil(tester, find.text('CERTA'));
    if (q <= corretas) {
      await tester.tap(find.text('CERTA'));
    } else {
      await tester.tap(find.text('ERRADA A').first);
    }
    await tester.pump(const Duration(milliseconds: 300));

    if (q < total) {
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

/// Da a Home, inicia um simulado com `total` questoes (5/10/15/20) e responde
/// `corretas` certas. Deixa na tela de resultado.
Future<void> fazerSimulado(
  WidgetTester tester, {
  required int corretas,
  int total = 5,
}) async {
  await tester.tap(find.text('Curso E2E'));
  await pumpUntil(tester, find.byKey(ValueKey('$total')));
  await tester.tap(find.byKey(ValueKey('$total')));
  await tester.pump(const Duration(milliseconds: 300));
  await pumpUntil(tester, find.text('Iniciar'));
  await tester.tap(find.text('Iniciar'));
  await responderExame(tester, corretas: corretas, total: total);
}

/// Da a Home, inicia a prova de TEMPLATE publicado "Prova E2E" (aba "Provas" do
/// QuizConfig -> RPC generate_exam_from_template) e responde `corretas` de 5.
/// Deixa na tela de resultado.
Future<void> fazerProvaTemplate(
  WidgetTester tester, {
  required int corretas,
}) async {
  await tester.tap(find.text('Curso E2E'));
  await pumpUntil(tester, find.text('Provas')); // aba do modo "Provas"
  await tester.tap(find.text('Provas'));
  await pumpUntil(tester, find.text('Iniciar Prova'));
  await tester.tap(find.text('Iniciar Prova'));
  await responderExame(tester, corretas: corretas, total: 5);
}

/// Registros de pontos do aluno logado para um template (best-score por
/// exam_template_id), em ordem cronologica.
Future<List<dynamic>> pontosDoTemplate([String templateId = templateE2eId]) async {
  final client = Supabase.instance.client;
  final uid = client.auth.currentUser!.id;
  final rows = await client
      .from('user_gamification_points')
      .select('total_points, created_at')
      .eq('user_id', uid)
      .eq('exam_template_id', templateId)
      .order('created_at', ascending: true);
  return rows as List;
}

/// Nome da temporada (season) ativa — deve seguir o formato "YYYY.S".
Future<String> nomeSeasonAtiva() async {
  final client = Supabase.instance.client;
  final rows = await client
      .from('gamification_season')
      .select('name')
      .eq('is_active', true)
      .limit(1);
  return ((rows as List).first as Map)['name'].toString();
}

/// Rola a tela de resultado (CustomScrollView lazy) ate o `alvo` ser construido
/// e o toca. Drag manual (pump, nao pumpAndSettle) por causa do confetti.
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

/// Quantos registros de pontos o aluno logado tem no banco (cliente autenticado
/// do proprio app — RLS permite ler os proprios pontos).
Future<int> contarRegistrosDePontos() async {
  final client = Supabase.instance.client;
  final uid = client.auth.currentUser!.id;
  final rows = await client
      .from('user_gamification_points')
      .select('total_points')
      .eq('user_id', uid);
  return (rows as List).length;
}

/// Ultimo registro de pontos gravado pelo aluno logado (para assertar base/bonus
/// de uma prova recem-finalizada). Colunas numericas voltam como num/String —
/// use double.parse(valor.toString()) ao comparar.
Future<Map<String, dynamic>> ultimoRegistroDePontos() async {
  final client = Supabase.instance.client;
  final uid = client.auth.currentUser!.id;
  final rows = await client
      .from('user_gamification_points')
      .select(
          'base_points, time_bonus, total_points, question_count, correct_count, percentage_score, created_at')
      .eq('user_id', uid)
      .order('created_at', ascending: false)
      .limit(1);
  return (rows as List).first as Map<String, dynamic>;
}

/// Converte um valor numerico do Supabase (num ou String) para double.
double comoDouble(dynamic v) => double.parse(v.toString());

/// Linha de public.user pelo e-mail (ou null). Requer estar logado como staff
/// (a policy user_select_own_or_staff permite teacher/admin lerem todos).
Future<Map<String, dynamic>?> usuarioPorEmail(String email) async {
  final rows = await Supabase.instance.client
      .from('user')
      .select('role, email, first_name')
      .eq('email', email);
  final list = rows as List;
  return list.isEmpty ? null : list.first as Map<String, dynamic>;
}

/// Marca o Checkbox de termos (do signup) de forma robusta: rola ate ele, toca e
/// verifica que ficou marcado, com algumas tentativas (tap pode "escorregar" na
/// borda apos ensureVisible). Retorna true se ficou marcado.
Future<bool> aceitarTermos(WidgetTester tester) async {
  final cb = find.byType(Checkbox);
  for (var i = 0; i < 4; i++) {
    await tester.ensureVisible(cb);
    await tester.pump(const Duration(milliseconds: 200));
    if (tester.widget<Checkbox>(cb).value == true) return true;
    await tester.tap(cb, warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 300));
  }
  return tester.widget<Checkbox>(cb).value == true;
}
