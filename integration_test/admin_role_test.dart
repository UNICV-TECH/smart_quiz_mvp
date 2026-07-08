// Teste E2E: o ADMIN promove um usuario (student -> teacher) pela UI.
//
// Loga como admin (cai em /admin), abre "Usuarios", busca o usuario-alvo
// descartavel pelo e-mail (filtra a lista para 1 linha), muda o papel no
// dropdown para "Professor", confirma e valida:
//   1) banner "Papel do usuario atualizado com sucesso";
//   2) user.role do alvo virou "teacher" no banco (RPC admin_update_user_role;
//      RLS/guard so deixam admin agir sobre OUTRA conta).
//
// Usa um alvo dedicado (e2e-target@test.dev) para NAO tocar nas contas de login
// dos outros E2E. Pre-requisitos: `supabase start` + `bash scripts/e2e_setup.sh`.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers.dart';

const _alvoEmail = 'e2e-target@test.dev';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('admin promove usuario a professor (admin_update_user_role)',
      (WidgetTester tester) async {
    // Janela larga: menu lateral do admin sempre visivel (>=768), sem Drawer.
    await tester.binding.setSurfaceSize(const Size(1400, 1000));

    await bootELogar(tester, email: adminEmail);

    // Cai no painel admin (Dashboard) -> abre "Usuarios".
    await pumpUntil(tester, find.text('Usuários'));
    await tester.tap(find.text('Usuários'));
    await pumpUntil(tester, find.text('Gerenciar Usuários'));

    // Estado inicial no banco: alvo e student.
    final antes = await usuarioPorEmail(_alvoEmail);
    expect(antes?['role'], 'student',
        reason: 'seed deve criar o alvo como student');

    // Busca pelo e-mail do alvo -> a lista re-consulta (RPC admin_list_users com
    // p_search) e sobra 1 linha, entao ha um unico dropdown "Aluno".
    await tester.enterText(
      find.widgetWithText(TextField, 'Buscar por nome ou e-mail...'),
      _alvoEmail,
    );
    for (var i = 0;
        i < 24 && find.text('Aluno').evaluate().length != 1;
        i++) {
      await tester.pump(const Duration(milliseconds: 250));
    }
    expect(find.text('Aluno'), findsOneWidget,
        reason: 'apos buscar pelo alvo deve sobrar so a linha dele (1 dropdown)');

    // Abre o dropdown de papel e escolhe "Professor".
    final dropdownAluno = find.text('Aluno');
    await tester.ensureVisible(dropdownAluno);
    await tester.tap(dropdownAluno);
    await pumpUntil(tester, find.text('Professor').hitTestable());
    await tester.tap(find.text('Professor').hitTestable());
    await tester.pump(const Duration(milliseconds: 300));

    // Confirma no dialog "Alterar papel".
    await pumpUntil(tester, find.text('Confirmar'));
    await tester.tap(find.text('Confirmar'));

    // O banner de sucesso nao serve de sinal: loadUsers() chama _clearMessages()
    // logo apos _setSuccess(), sem frame no meio. Assere no banco (fonte de
    // verdade), bombeando frames ate a RPC admin_update_user_role refletir.
    Map<String, dynamic>? depois;
    for (var i = 0; i < 24; i++) {
      await tester.pump(const Duration(milliseconds: 250));
      depois = await usuarioPorEmail(_alvoEmail);
      if (depois?['role'] == 'teacher') break;
    }
    expect(depois?['role'], 'teacher',
        reason: 'admin_update_user_role deveria ter promovido o alvo a teacher');
  });
}
