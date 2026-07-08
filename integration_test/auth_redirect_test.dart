// Teste E2E: login redireciona conforme o papel (role) e trata credencial invalida.
// Um unico testWidgets (um app.main); troca de usuario via relogar() sem rebootar.
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

  testWidgets('redirect por role (professor/admin) e senha errada',
      (WidgetTester tester) async {
    // ── Professor -> Templates de Prova ────────────────────────────────────
    await bootELogar(tester, email: profEmail);
    await pumpUntil(tester, find.text('Templates de Prova'));
    expect(find.text('Templates de Prova'), findsWidgets);

    // ── Admin -> Painel Admin ──────────────────────────────────────────────
    await relogar(tester, email: adminEmail);
    await pumpUntil(tester, find.text('Painel Admin'));
    expect(find.text('Painel Admin'), findsWidgets);

    // ── Senha errada -> erro, permanece no login ───────────────────────────
    await relogar(tester, email: alunoEmail, senha: 'senha-errada');
    await pumpUntil(tester, find.textContaining('Credenciais inválidas'));
    expect(find.textContaining('Credenciais inválidas'), findsWidgets);
    expect(find.byType(TextFormField), findsWidgets);
  });
}
