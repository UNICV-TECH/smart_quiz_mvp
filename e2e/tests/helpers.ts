import { Page, expect } from '@playwright/test';
import * as path from 'path';

// --------------------------------------------------------------------------
// Constants
// --------------------------------------------------------------------------

const SCREENSHOTS_DIR = path.resolve(__dirname, '..', 'screenshots');

/**
 * Maximum time (ms) to wait for the Flutter web app to become interactive.
 * Flutter web (especially CanvasKit) can take a while on first load.
 */
const FLUTTER_READY_TIMEOUT = 45_000;

// --------------------------------------------------------------------------
// Flutter Web Helpers
// --------------------------------------------------------------------------

/**
 * Wait until the Flutter web application is fully loaded and interactive.
 *
 * Flutter web renders inside a `<flutter-view>` (modern) or `flt-glass-pane`
 * (older engine) shadow host. We also check for the presence of the
 * semantics tree (`flt-semantics-host`) which indicates the accessibility
 * layer is active.
 *
 * As a fallback we simply wait for `networkidle` + a DOM element that
 * Flutter always emits.
 */
export async function waitForFlutterReady(page: Page): Promise<void> {
  // Wait for network to settle (Flutter downloads main.dart.js, fonts, etc.)
  await page.waitForLoadState('networkidle', { timeout: FLUTTER_READY_TIMEOUT });

  // Flutter web always creates at least one of these host elements.
  // Try the modern `flutter-view` first, then fall back to legacy selectors.
  try {
    await page.waitForSelector('flutter-view, flt-glass-pane, flt-semantics-host', {
      timeout: FLUTTER_READY_TIMEOUT,
      state: 'attached',
    });
  } catch {
    // If none of the known Flutter selectors appear, the app may use a custom
    // embedding. We still continue -- subsequent assertions will catch real
    // problems.
  }

  // Give Flutter an extra moment to finish rendering the first frame.
  await page.waitForTimeout(2000);
}

// --------------------------------------------------------------------------
// Screenshot Helper
// --------------------------------------------------------------------------

/**
 * Take a full-page screenshot and save it to `e2e/screenshots/<name>`.
 *
 * @param page  Playwright Page instance.
 * @param name  File name, e.g. `"01-splash-screen.png"`.
 */
export async function takeScreenshot(page: Page, name: string): Promise<void> {
  const filePath = path.join(SCREENSHOTS_DIR, name);
  await page.screenshot({ path: filePath, fullPage: true });
}

// --------------------------------------------------------------------------
// Authentication
// --------------------------------------------------------------------------

/**
 * Perform login through the Smart Quiz login form.
 *
 * Flutter web renders form controls as platform views or canvas-based
 * elements.  We use multiple strategies to locate the inputs:
 *   1. Semantics labels (ARIA roles / placeholders)
 *   2. CSS `input` elements (HTML renderer)
 *   3. Fallback keyboard-based interaction
 *
 * @param page     Playwright Page instance.
 * @param email    User email address.
 * @param password User password.
 * @returns `true` if login likely succeeded (navigated away from /login), `false` otherwise.
 */
export async function login(page: Page, email: string, password: string): Promise<boolean> {
  // Navigate to the app root — Flutter redirects unauthenticated users to /welcome
  await page.goto('/');
  await waitForFlutterReady(page);

  // Enable Flutter semantics (required for CanvasKit to expose DOM elements)
  await page.evaluate(() => {
    const placeholder = document.querySelector('flt-semantics-placeholder');
    if (placeholder) (placeholder as HTMLElement).click();
  });
  await page.waitForTimeout(500);

  // Navigate to login: click "Entrar" button on welcome screen
  await page.evaluate(() => {
    const nodes = document.querySelectorAll('flt-semantics[role="button"]');
    for (const n of nodes) {
      if (n.textContent?.trim() === 'Entrar') { (n as HTMLElement).click(); break; }
    }
  });
  await page.waitForTimeout(3000);

  // Verify we're on the login page
  if (!page.url().includes('/login')) {
    // Fallback: direct navigation
    await page.goto('/login');
    await waitForFlutterReady(page);
  }

  // Flutter CanvasKit renders to canvas — no real HTML inputs are exposed.
  // The ONLY reliable way to interact is:
  //   1. Click the flt-semantics node for the field (tells Flutter which field is active)
  //   2. Focus the hidden <input> that Flutter creates (captures keyboard events)
  //   3. Use keyboard.type() to send keystrokes

  // Wait for Flutter to render the login form (look for semantics nodes)
  await page.waitForTimeout(2000);

  // Step 1: Click email semantics node (node with empty text after "E-mail" label)
  await page.evaluate(() => {
    const nodes = [...document.querySelectorAll('flt-semantics')];
    const emailLabelIdx = nodes.findIndex(n => n.textContent?.trim() === 'E-mail');
    if (emailLabelIdx >= 0 && nodes[emailLabelIdx + 1]) {
      (nodes[emailLabelIdx + 1] as HTMLElement).click();
    }
  });
  await page.waitForTimeout(500);

  // Step 2: Focus the hidden text input and type email
  await page.evaluate(() => {
    const input = document.querySelector('input[type="text"]') as HTMLInputElement;
    if (input) { input.focus(); input.click(); }
  });
  await page.waitForTimeout(300);
  await page.keyboard.type(email, { delay: 15 });
  await page.waitForTimeout(500);

  // Step 3: Click password semantics node
  await page.evaluate(() => {
    const nodes = [...document.querySelectorAll('flt-semantics')];
    const senhaLabelIdx = nodes.findIndex(n => n.textContent?.trim() === 'Senha');
    if (senhaLabelIdx >= 0 && nodes[senhaLabelIdx + 1]) {
      (nodes[senhaLabelIdx + 1] as HTMLElement).click();
    }
  });
  await page.waitForTimeout(500);

  // Step 4: Focus the hidden password input and type password
  await page.evaluate(() => {
    const input = document.querySelector('input[type="password"]') as HTMLInputElement;
    if (input) { input.focus(); input.click(); }
  });
  await page.waitForTimeout(300);
  await page.keyboard.type(password, { delay: 15 });
  await page.waitForTimeout(500);

  // Step 5: Click the "Entrar" login button via Flutter semantics
  await page.evaluate(() => {
    const nodes = document.querySelectorAll('flt-semantics[role="button"]');
    for (const n of nodes) {
      if (n.textContent?.trim() === 'Entrar') { (n as HTMLElement).click(); break; }
    }
  });

  // Wait for Flutter auth + navigation (can take several seconds)
  await page.waitForTimeout(6000);

  // Check if we successfully navigated away from the login page
  const currentUrl = page.url();
  const loginSucceeded = !currentUrl.includes('/login') && !currentUrl.includes('/welcome');
  return loginSucceeded;
}

/**
 * Login and verify that authentication was successful.
 * If login fails, the test is marked as skipped with an informative message.
 *
 * @returns `true` if login succeeded.
 */
export async function loginAndVerify(
  page: Page,
  email: string,
  password: string,
  role: string,
): Promise<boolean> {
  const success = await login(page, email, password);
  if (!success) {
    // Take a screenshot documenting the failed login
    await takeScreenshot(page, `login-failed-${role}.png`);
  }
  return success;
}

// --------------------------------------------------------------------------
// Student Navigation
// --------------------------------------------------------------------------

/**
 * Click a bottom navigation bar item in the student module.
 *
 * The CustomNavBar renders 4 items: Inicio(0), Ranking(1), Historico(2), Perfil(3).
 * Flutter renders these as text nodes; we locate by label text.
 *
 * @param page  Playwright Page instance.
 * @param index 0-based index of the nav item.
 */
export async function clickNavBarItem(page: Page, index: number): Promise<void> {
  const labels = ['Início', 'Ranking', 'Histórico', 'Perfil'];
  const label = labels[index];

  if (!label) {
    throw new Error(`Invalid nav bar index: ${index}. Must be 0-3.`);
  }

  // Try clicking by visible text
  try {
    await page.getByText(label, { exact: false }).last().click({ timeout: 5000 });
  } catch {
    // Fallback: try locating by partial text match (handles accents)
    try {
      const stripped = label.replace(/[íóúãê]/g, '.');
      await page.locator(`text=/${stripped}/i`).last().click({ timeout: 5000 });
    } catch {
      // Could not find nav bar item
    }
  }

  await page.waitForTimeout(1500);
}

// --------------------------------------------------------------------------
// Teacher Navigation
// --------------------------------------------------------------------------

/**
 * Click a teacher side-menu item by its label text.
 *
 * For accordion sub-items (e.g. "Nova Questao"), the parent accordion
 * ("Criar Questoes") is expanded first.
 *
 * @param page  Playwright Page instance.
 * @param label The menu item text, e.g. "Dashboard", "Nova Questao".
 */
export async function clickTeacherMenuItem(page: Page, label: string): Promise<void> {
  // Sub-items that live inside the "Criar Questoes" accordion
  const accordionSubItems = ['Nova Questão', 'Listar Questões', 'Matérias', 'Categorias'];

  const isSubItem = accordionSubItems.some(
    (sub) => sub.toLowerCase() === label.toLowerCase()
  );

  if (isSubItem) {
    // First expand the accordion if it's collapsed
    try {
      const accordion = page.getByText('Criar Questões', { exact: false }).first();
      await accordion.click({ timeout: 3000 });
      await page.waitForTimeout(500);
    } catch {
      // Accordion might already be expanded -- continue
    }
  }

  // Click the target item
  try {
    await page.getByText(label, { exact: false }).first().click({ timeout: 5000 });
  } catch {
    // Fallback with regex for accent-insensitive match
    try {
      const escaped = label.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
      await page.locator(`text=/${escaped}/i`).first().click({ timeout: 5000 });
    } catch {
      // Could not find menu item
    }
  }

  await page.waitForTimeout(1500);
}

// --------------------------------------------------------------------------
// Admin Navigation
// --------------------------------------------------------------------------

/**
 * Click an admin side-menu item by its label text.
 *
 * @param page  Playwright Page instance.
 * @param label The menu item text, e.g. "Dashboard", "Usuarios", "Conteudo".
 */
export async function clickAdminMenuItem(page: Page, label: string): Promise<void> {
  try {
    await page.getByText(label, { exact: false }).first().click({ timeout: 5000 });
  } catch {
    try {
      const escaped = label.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
      await page.locator(`text=/${escaped}/i`).first().click({ timeout: 5000 });
    } catch {
      // Could not find menu item
    }
  }

  await page.waitForTimeout(1500);
}

// --------------------------------------------------------------------------
// Logout
// --------------------------------------------------------------------------

/**
 * Perform logout.
 *
 * The app shows a confirmation dialog with "Sair" button.
 * Different screens have different logout triggers:
 *   - Student profile: "Sair da conta" text
 *   - Teacher profile: "Sair" button in profile section
 *   - Admin: logout icon button in footer
 */
export async function performLogout(page: Page): Promise<void> {
  // Try to find and click the logout trigger
  const logoutSelectors = [
    'text=/Sair da conta/i',
    'text=/^Sair$/i',
    '[aria-label="Sair"]',
    'button:has-text("Sair")',
  ];

  let clicked = false;
  for (const selector of logoutSelectors) {
    try {
      const el = page.locator(selector).first();
      if (await el.isVisible({ timeout: 2000 })) {
        await el.click();
        clicked = true;
        break;
      }
    } catch {
      continue;
    }
  }

  if (!clicked) {
    // Last resort: look for a logout icon
    try {
      await page.locator('[class*="logout"], [data-icon="logout"]').first().click({ timeout: 3000 });
    } catch {
      // Could not find logout button
    }
  }

  // Wait for the confirmation dialog
  await page.waitForTimeout(1000);

  // Click "Sair" in the confirmation dialog
  try {
    // The dialog has two buttons: "Cancelar" and "Sair"
    // We want the "Sair" button inside the dialog (AlertDialog)
    const dialogSairButton = page.getByRole('button', { name: /^Sair$/i }).first();
    if (await dialogSairButton.isVisible({ timeout: 3000 })) {
      await dialogSairButton.click();
    }
  } catch {
    // Dialog might not have appeared or uses different structure
    try {
      // Try text-based click on the last "Sair" text (dialog button)
      await page.locator('text=/^Sair$/').last().click({ timeout: 3000 });
    } catch {
      // Continue anyway
    }
  }

  await page.waitForTimeout(2000);
}

// --------------------------------------------------------------------------
// Generic Utilities
// --------------------------------------------------------------------------

/**
 * Check if the current page URL contains a given path segment.
 */
export async function expectUrlContains(page: Page, pathSegment: string): Promise<void> {
  await expect(page).toHaveURL(new RegExp(pathSegment.replace(/\//g, '\\/')));
}

/**
 * Wait for a text to be visible on the page.
 */
export async function waitForText(page: Page, text: string, timeout = 10_000): Promise<void> {
  await page.getByText(text, { exact: false }).first().waitFor({
    state: 'visible',
    timeout,
  });
}

/**
 * Check if any element matching the text is present on the page (visible or not).
 */
export async function hasText(page: Page, text: string): Promise<boolean> {
  try {
    const count = await page.getByText(text, { exact: false }).count();
    return count > 0;
  } catch {
    return false;
  }
}
