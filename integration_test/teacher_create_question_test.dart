// Teste E2E: o PROFESSOR cria uma questao pela UI (RPC create_teacher_question).
//
// Loga como professor, navega Menu -> "Criar Questoes" -> "Nova Questao",
// seleciona o curso (unico obrigatorio; dificuldade='medio' e pontos=1.0 ja vem
// por padrao), preenche enunciado/pergunta + 2 alternativas (marca a correta) e
// salva. Valida:
//   1) banner de sucesso "Questao criada com sucesso!";
//   2) a questao aparece em public.question com id_teacher = o professor logado
//      (a RPC create_teacher_question gravou; RLS deixa o dono ler a propria).
//
// Pre-requisitos: `supabase start` + `bash scripts/e2e_setup.sh` (professor
// e2e-prof@test.dev + curso "Curso E2E").
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers.dart';

// Enunciado distintivo para localizar a questao no banco depois.
const _enunciado = 'Questao E2E criada pelo professor via UI';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('professor cria questao (RPC create_teacher_question)',
      (WidgetTester tester) async {
    // Janela larga: garante o menu lateral do professor sempre visivel (>=768),
    // evitando o Drawer mobile.
    await tester.binding.setSurfaceSize(const Size(1400, 1000));

    await bootELogar(tester, email: profEmail);
    await pumpUntil(tester, find.text('Templates de Prova'));

    // Menu -> acordeao "Criar Questoes" -> "Nova Questao".
    await tester.tap(find.text('Criar Questões'));
    await pumpUntil(tester, find.text('Nova Questão'));
    await tester.tap(find.text('Nova Questão'));

    // Espera o form de contexto carregar (enquanto isLoading, so aparece spinner;
    // o label "Curso" so existe apos os cursos carregarem).
    await pumpUntil(tester, find.text('Criar Nova Questão'));
    await pumpUntil(tester, find.text('Curso'));

    // Seleciona o curso: abre o SelectPesquisa e escolhe "Curso E2E".
    final abrirCurso = find.text('Selecione o curso');
    await tester.ensureVisible(abrirCurso);
    await tester.tap(abrirCurso);
    await pumpUntil(tester, find.text('Curso E2E'));
    await tester.tap(find.text('Curso E2E'));
    await tester.pump(const Duration(milliseconds: 400));

    // Enunciado e pergunta (ambos obrigatorios).
    await tester.enterText(
      find.widgetWithText(TextField, 'Digite o enunciado aqui...'),
      _enunciado,
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Digite a pergunta clara e objetiva'),
      'Qual a alternativa correta?',
    );

    // Alternativa A (correta) + alternativa B.
    await tester.enterText(
      find.widgetWithText(TextField, 'Digite o texto da alternativa A'),
      'CERTA E2E',
    );
    final addAlt = find.text('Adicionar Alternativa');
    await tester.ensureVisible(addAlt);
    await tester.tap(addAlt);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.enterText(
      find.widgetWithText(TextField, 'Digite o texto da alternativa B'),
      'ERRADA E2E',
    );

    // Marca A como correta (o toque no circulo da letra sobe pro GestureDetector).
    final circuloA = find.text('A');
    await tester.ensureVisible(circuloA);
    await tester.tap(circuloA);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Alternativa A (Correta)'), findsOneWidget,
        reason: 'a alternativa A deveria ficar marcada como correta');

    // Salva.
    final salvar = find.text('Salvar Questão');
    await tester.ensureVisible(salvar);
    await tester.tap(salvar);

    // Sucesso na UI (banner do ViewModel).
    await pumpUntil(tester, find.text('Questão criada com sucesso!'));

    // Reforco no banco: a questao existe para este professor.
    final qtd = await contarQuestoesDoProfessor('%professor via UI%');
    expect(qtd, greaterThanOrEqualTo(1),
        reason: 'create_teacher_question deveria ter gravado a questao do prof');
  });
}
