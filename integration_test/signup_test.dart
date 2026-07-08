// Teste E2E: cadastro (signup) pela UI valida o trigger handle_new_user.
//
// Um novo aluno se cadastra em /signup; o trigger deve criar public.user com
// role='student'. Como o stack local tem confirmacao de e-mail ligada (o novo
// usuario nao loga na hora), a verificacao e feita logando como ADMIN (que pela
// policy user_select_own_or_staff pode ler todos os usuarios) e checando o role.
//
// Pre-requisitos: `supabase start` + `bash scripts/e2e_setup.sh` (conta admin).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('signup cria public.user como student (trigger handle_new_user)',
      (WidgetTester tester) async {
    const novoEmail = 'signup-e2e@test.dev';

    await irParaLogin(tester);

    // /login -> /signup.
    await tester.tap(find.text('Cadastre-se'));
    // O botao (nao o titulo, que tambem e "Cadastrar") desambiguado pelo tipo.
    final botaoCadastrar = find.widgetWithText(ElevatedButton, 'Cadastrar');
    await pumpUntil(tester, botaoCadastrar);

    // Campos na ordem: Nome, E-mail, Senha, Confirmar Senha.
    final campos = find.byType(TextFormField);
    await tester.enterText(campos.at(0), 'Aluno Signup');
    await tester.enterText(campos.at(1), novoEmail);
    await tester.enterText(campos.at(2), 'Senha1234');
    await tester.enterText(campos.at(3), 'Senha1234');
    await tester.pump(const Duration(milliseconds: 300));

    // Aceita os termos (obrigatorio) e cadastra.
    await tester.ensureVisible(find.byType(Checkbox));
    await tester.tap(find.byType(Checkbox));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.ensureVisible(botaoCadastrar);
    await tester.tap(botaoCadastrar);

    // Pos-cadastro: dialog "Ir para login" (confirmacao ligada) OU ja navegou
    // direto para /login (confirmacao desligada). Tolera os dois.
    final idx = await pumpUntilAny(
      tester,
      [find.text('Ir para login'), find.text('Cadastre-se')],
    );
    if (idx == 0) {
      await tester.tap(find.text('Ir para login'));
    }

    // Verifica via ADMIN que o novo usuario nasceu student.
    await preencherELogar(tester, email: adminEmail);
    await pumpUntil(tester, find.text('Painel Admin'));

    final novo = await usuarioPorEmail(novoEmail);
    expect(novo, isNotNull,
        reason: 'o trigger handle_new_user deveria criar public.user no signup');
    expect(novo!['role'], 'student',
        reason: 'todo novo usuario deve nascer com role student');
  });
}
