// Teste E2E: login redireciona conforme o papel (role) e trata credencial invalida.
//
// Cenarios:
//   1. Professor -> tela de Templates de Prova (/teacher/templates).
//   2. Admin     -> Painel Admin (/admin).
//   3. Senha errada -> mensagem de erro, permanece no login.
//
// Pre-requisitos: `supabase start` + `bash scripts/e2e_setup.sh`
// (contas e2e-prof@ [teacher] e e2e-admin@ [admin]).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('professor cai na tela de Templates de Prova',
      (WidgetTester tester) async {
    await deslogar();
    await bootELogar(tester, email: profEmail);

    await pumpUntil(tester, find.text('Templates de Prova'));
    expect(find.text('Templates de Prova'), findsWidgets);
  });

  testWidgets('admin cai no Painel Admin', (WidgetTester tester) async {
    await deslogar();
    await bootELogar(tester, email: adminEmail);

    await pumpUntil(tester, find.text('Painel Admin'));
    expect(find.text('Painel Admin'), findsWidgets);
  });

  testWidgets('senha errada mostra erro e permanece no login',
      (WidgetTester tester) async {
    await deslogar();
    await bootELogar(tester, email: alunoEmail, senha: 'senha-errada');

    await pumpUntil(tester, find.textContaining('Verifique suas credenciais'));
    expect(find.textContaining('Verifique suas credenciais'), findsWidgets);
    // Nao redirecionou: os campos de login continuam na tela.
    expect(find.byType(TextFormField), findsWidgets);
  });
}
