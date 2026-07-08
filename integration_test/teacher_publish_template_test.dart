// Teste E2E: o PROFESSOR publica um template de prova pela UI.
//
// Loga como professor (o router leva direto a /teacher/templates), encontra o
// template semeado em RASCUNHO ("Template C E2E"), toca "Publicar" e valida que:
//   1) o card passa a exibir o badge "Publicado" (e o botao vira "Despublicar");
//   2) exam_template.is_published virou true no banco (update REST + RLS de dono
//      "Teachers can manage their templates" = id_teacher = auth.uid()).
//
// Pre-requisitos: `supabase start` + `bash scripts/e2e_setup.sh` (semeia o
// template rascunho do professor e2e-prof@test.dev).
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers.dart';

// Id do template semeado por scripts/e2e_setup.sh (is_published=false).
const _templateId = 'e2eddddd-0000-0000-0000-000000000000';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('professor publica template (is_published -> true, RLS de dono)',
      (WidgetTester tester) async {
    await bootELogar(tester, email: profEmail);

    // Cai na area do professor: tela de templates carrega o card do rascunho.
    await pumpUntil(tester, find.text('Templates de Prova'));
    await pumpUntil(tester, find.text('Template C E2E'));

    // Estado inicial: rascunho, ainda nao publicado no banco.
    expect(find.text('Rascunho'), findsWidgets,
        reason: 'template deve comecar como rascunho');
    expect(await templatePublicado(_templateId), isFalse,
        reason: 'seed deve criar o template com is_published=false');

    // Publica.
    final botaoPublicar = find.text('Publicar');
    await tester.ensureVisible(botaoPublicar);
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(botaoPublicar);

    // A lista recarrega apos publicar -> o card passa a "Publicado".
    await pumpUntil(tester, find.text('Publicado'));
    expect(find.text('Despublicar'), findsWidgets,
        reason: 'apos publicar, a acao do card deve virar "Despublicar"');

    // Reforco no banco: o update REST persistiu (RLS de dono permitiu).
    expect(await templatePublicado(_templateId), isTrue,
        reason: 'exam_template.is_published deveria ser true apos publicar');
  });
}
