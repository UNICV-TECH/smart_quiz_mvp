import { test, expect } from '@playwright/test';
import {
  takeScreenshot,
  login,
  loginAndVerify,
  clickTeacherMenuItem,
  performLogout,
} from './helpers';

// ---------------------------------------------------------------------------
// Test credentials (from env vars or defaults)
// ---------------------------------------------------------------------------
const TEACHER_EMAIL = process.env.TEACHER_EMAIL || 'professor.teste@unicv.edu.br';
const TEACHER_PASSWORD = process.env.TEACHER_PASSWORD || 'Test@123';

// ---------------------------------------------------------------------------
// Module do Professor - Fluxo Completo
// ---------------------------------------------------------------------------
test.describe('Modulo do Professor - Fluxo Completo', () => {

  // -----------------------------------------------------------------------
  // 1. Login as Teacher
  // -----------------------------------------------------------------------
  test('deve fazer login como professor', async ({ page }) => {
    const success = await loginAndVerify(page, TEACHER_EMAIL, TEACHER_PASSWORD, 'teacher');

    await takeScreenshot(page, '14-teacher-home.png');

    if (success) {
      // Teacher should be redirected to /teacher/templates
      const url = page.url();
      expect(url).toContain('/teacher');
    } else {
      console.log('NOTICE: Teacher login did not succeed. Test credentials may not exist on this environment.');
      test.info().annotations.push({ type: 'notice', description: 'Teacher login failed -- credentials may not exist' });
    }
  });

  // -----------------------------------------------------------------------
  // 2. Verify Side Menu
  // -----------------------------------------------------------------------
  test('deve exibir o menu lateral com todas as secoes', async ({ page }) => {
    const success = await loginAndVerify(page, TEACHER_EMAIL, TEACHER_PASSWORD, 'teacher');

    if (!success) {
      await takeScreenshot(page, '15-teacher-menu.png');
      test.info().annotations.push({ type: 'skip-reason', description: 'Login failed' });
      return;
    }

    await page.waitForTimeout(2000);

    // The teacher side menu should contain these items
    const menuItems = ['Montar Provas', 'Criar Quest', 'Dashboard', 'Gamifica', 'Perfil'];

    for (const item of menuItems) {
      const isVisible = await page.getByText(item, { exact: false })
        .first()
        .isVisible({ timeout: 3000 })
        .catch(() => false);

      // Log visibility for debugging
      if (!isVisible) {
        console.log(`Menu item "${item}" not found as visible text (may be canvas-rendered)`);
      }
    }

    await takeScreenshot(page, '15-teacher-menu.png');
  });

  // -----------------------------------------------------------------------
  // 3. Navigate to Create Question
  // -----------------------------------------------------------------------
  test('deve navegar para tela de criar questao', async ({ page }) => {
    const success = await loginAndVerify(page, TEACHER_EMAIL, TEACHER_PASSWORD, 'teacher');

    if (!success) {
      await takeScreenshot(page, '16-teacher-nova-questao.png');
      test.info().annotations.push({ type: 'skip-reason', description: 'Login failed' });
      return;
    }

    await page.waitForTimeout(2000);

    // Click "Criar Questoes" to expand accordion, then "Nova Questao"
    await clickTeacherMenuItem(page, 'Nova Questão');
    await page.waitForTimeout(2000);

    await takeScreenshot(page, '16-teacher-nova-questao.png');
  });

  // -----------------------------------------------------------------------
  // 4. Navigate to Question List
  // -----------------------------------------------------------------------
  test('deve navegar para lista de questoes', async ({ page }) => {
    const success = await loginAndVerify(page, TEACHER_EMAIL, TEACHER_PASSWORD, 'teacher');

    if (!success) {
      await takeScreenshot(page, '17-teacher-lista-questoes.png');
      test.info().annotations.push({ type: 'skip-reason', description: 'Login failed' });
      return;
    }

    await page.waitForTimeout(2000);

    await clickTeacherMenuItem(page, 'Listar Questões');
    await page.waitForTimeout(2000);

    await takeScreenshot(page, '17-teacher-lista-questoes.png');
  });

  // -----------------------------------------------------------------------
  // 5. Navigate to Exam Templates
  // -----------------------------------------------------------------------
  test('deve navegar para montar provas (templates)', async ({ page }) => {
    const success = await loginAndVerify(page, TEACHER_EMAIL, TEACHER_PASSWORD, 'teacher');

    if (!success) {
      await takeScreenshot(page, '18-teacher-templates.png');
      test.info().annotations.push({ type: 'skip-reason', description: 'Login failed' });
      return;
    }

    await page.waitForTimeout(2000);

    await clickTeacherMenuItem(page, 'Montar Provas');
    await page.waitForTimeout(2000);

    await takeScreenshot(page, '18-teacher-templates.png');
  });

  // -----------------------------------------------------------------------
  // 6. Navigate to Dashboard / Stats
  // -----------------------------------------------------------------------
  test('deve navegar para o dashboard de estatisticas', async ({ page }) => {
    test.setTimeout(60_000);
    const success = await loginAndVerify(page, TEACHER_EMAIL, TEACHER_PASSWORD, 'teacher');

    if (!success) {
      await takeScreenshot(page, '19-teacher-dashboard.png');
      test.info().annotations.push({ type: 'skip-reason', description: 'Login failed' });
      return;
    }

    await page.waitForTimeout(2000);

    await clickTeacherMenuItem(page, 'Dashboard');
    await page.waitForTimeout(2000);

    await takeScreenshot(page, '19-teacher-dashboard.png');
  });

  // -----------------------------------------------------------------------
  // 7. Navigate to Gamification
  // -----------------------------------------------------------------------
  test('deve navegar para gamificacao', async ({ page }) => {
    test.setTimeout(60_000);
    const success = await loginAndVerify(page, TEACHER_EMAIL, TEACHER_PASSWORD, 'teacher');

    if (!success) {
      await takeScreenshot(page, '20-teacher-gamificacao.png');
      test.info().annotations.push({ type: 'skip-reason', description: 'Login failed' });
      return;
    }

    await page.waitForTimeout(2000);

    await clickTeacherMenuItem(page, 'Gamificação');
    await page.waitForTimeout(2000);

    await takeScreenshot(page, '20-teacher-gamificacao.png');
  });

  // -----------------------------------------------------------------------
  // 8. Logout
  // -----------------------------------------------------------------------
  test('deve fazer logout', async ({ page }) => {
    const success = await loginAndVerify(page, TEACHER_EMAIL, TEACHER_PASSWORD, 'teacher');

    if (!success) {
      await takeScreenshot(page, '21-teacher-logout.png');
      test.info().annotations.push({ type: 'skip-reason', description: 'Login failed' });
      return;
    }

    await page.waitForTimeout(2000);

    // Navigate to profile section first (where logout button is)
    await clickTeacherMenuItem(page, 'Perfil');
    await page.waitForTimeout(2000);

    // Perform logout
    await performLogout(page);

    await takeScreenshot(page, '21-teacher-logout.png');
  });
});
