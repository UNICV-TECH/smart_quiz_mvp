// Teste E2E: cadastro (signup) pela UI valida o trigger handle_new_user.
//
// Um novo aluno se cadastra em /signup. Com a confirmacao de e-mail desligada no
// stack local (config.toml), o signup ja retorna sessao: o app redireciona por
// papel -> como o trigger cria public.user com role='student', o novo usuario cai
// direto na Home. Alem do redirect, checamos o role lendo a propria linha (RLS
// permite ler o proprio registro).
//
// Pre-requisitos: `supabase start` + `bash scripts/e2e_setup.sh`.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

    // Aceita os termos (obrigatorio) — checa que realmente marcou.
    final marcou = await aceitarTermos(tester);
    expect(marcou, isTrue, reason: 'checkbox de termos precisa ficar marcado');

    await tester.ensureVisible(botaoCadastrar);
    await tester.tap(botaoCadastrar);

    // Diagnostico: apos submeter, o signUp (confirmacao off) deve ter criado
    // sessao para o novo usuario. Se nao houver, o signup falhou (confirmacao
    // ainda ligada no CI? email ja existente?).
    await tester.pump(const Duration(seconds: 5));
    final user = Supabase.instance.client.auth.currentUser;
    expect(user, isNotNull,
        reason: 'apos signup nao ha currentUser — signUp falhou (confirmacao?)');
    expect(user!.email, novoEmail);

    // Signup auto-loga (confirmacao off) e o redirect por papel leva o novo
    // aluno para a Home -> prova que o trigger o criou como student.
    await pumpUntil(tester, find.text('Curso E2E'));
    expect(find.text('Curso E2E'), findsWidgets);

    // Reforco: le a propria linha em public.user e confirma o role.
    final novo = await usuarioPorEmail(novoEmail);
    expect(novo, isNotNull,
        reason: 'o trigger handle_new_user deveria criar public.user no signup');
    expect(novo!['role'], 'student',
        reason: 'todo novo usuario deve nascer com role student');
  });
}
