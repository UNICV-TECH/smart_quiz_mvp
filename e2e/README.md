# Smart Quiz - E2E Tests

End-to-end tests for the Smart Quiz Flutter web application using [Playwright](https://playwright.dev/).

## Prerequisites

- Node.js >= 18
- npm or pnpm

## Setup

```bash
cd e2e
npm install
npx playwright install chromium
```

## Environment Variables

Copy the example file and fill in your test credentials:

```bash
cp .env.example .env
```

| Variable | Description | Default |
|----------|-------------|---------|
| `BASE_URL` | URL of the Flutter web app | `http://localhost:8080` |
| `STUDENT_EMAIL` | Student test account email | `aluno.teste@unicv.edu.br` |
| `STUDENT_PASSWORD` | Student test account password | `Test@123` |
| `TEACHER_EMAIL` | Teacher test account email | `professor.teste@unicv.edu.br` |
| `TEACHER_PASSWORD` | Teacher test account password | `Test@123` |
| `ADMIN_EMAIL` | Admin test account email | `admin.teste@unicv.edu.br` |
| `ADMIN_PASSWORD` | Admin test account password | `Test@123` |

## Running Tests

### Run all tests locally (against local Flutter server)

First, start the Flutter web app:

```bash
# From the project root
flutter run -d chrome --web-port=8080
```

Then run the tests:

```bash
cd e2e
npx playwright test --reporter=list
```

### Run against production

```bash
BASE_URL=https://smartquiz.unicvtech.com.br npx playwright test --reporter=list
```

### Run specific test suite

```bash
# Student flow only
npx playwright test tests/01-student-flow.spec.ts

# Teacher flow only
npx playwright test tests/02-teacher-flow.spec.ts

# Admin flow only
npx playwright test tests/03-admin-flow.spec.ts
```

### Run in headed mode (see the browser)

```bash
npx playwright test --headed
```

### Run in debug mode (step through tests)

```bash
npx playwright test --debug
```

## Screenshots

After running the tests, screenshots are saved to `e2e/screenshots/`.

```bash
open screenshots/
```

Screenshot naming convention:

| File | Description |
|------|-------------|
| `01-splash-screen.png` | App splash screen |
| `02-welcome-screen.png` | Welcome screen |
| `03-login-screen.png` | Login form |
| `04-home-screen.png` | Student home (courses) |
| `05-cursos-disponiveis.png` | Available courses list |
| `06-quiz-config.png` | Quiz configuration |
| `07-exam-questao.png` | Exam question view |
| `08-exam-questao-2.png` | Second exam question |
| `09-exam-resultado.png` | Exam results |
| `10-ranking-global.png` | Global ranking |
| `11-historico.png` | Exam history |
| `12-perfil-aluno.png` | Student profile |
| `13-logout.png` | After logout |
| `14-teacher-home.png` | Teacher main screen |
| `15-teacher-menu.png` | Teacher side menu |
| `16-teacher-nova-questao.png` | Create question form |
| `17-teacher-lista-questoes.png` | Question list |
| `18-teacher-templates.png` | Exam templates |
| `19-teacher-dashboard.png` | Teacher stats dashboard |
| `20-teacher-gamificacao.png` | Teacher gamification view |
| `21-teacher-logout.png` | Teacher logout |
| `22-admin-home.png` | Admin main screen |
| `23-admin-dashboard.png` | Admin dashboard |
| `24-admin-usuarios.png` | User management |
| `25-admin-conteudo.png` | Content management |
| `26-admin-logout.png` | Admin logout |

## Test Reports

After running tests, an HTML report is generated:

```bash
npx playwright show-report
```

## Flutter Web Testing Notes

- Flutter web can render via **CanvasKit** (default, renders to `<canvas>`) or **HTML renderer** (renders real DOM elements).
- CanvasKit mode makes traditional DOM-based selectors difficult. The tests use multiple strategies: ARIA roles, text selectors, `<input>` elements, and keyboard fallbacks.
- For best E2E testability, run Flutter with the HTML renderer: `flutter run -d chrome --web-renderer html --web-port=8080`
- The splash screen has a 2.5-second animation delay before navigation.
- All tests include generous timeouts to account for Flutter's initial load time.

## Test Structure

```
e2e/
├── playwright.config.ts         # Playwright configuration
├── package.json                 # Node dependencies
├── tsconfig.json                # TypeScript config
├── .env.example                 # Environment variables template
├── screenshots/                 # Test screenshots output
├── test-results/                # Playwright artifacts
└── tests/
    ├── helpers.ts               # Shared utilities (login, nav, screenshots)
    ├── 01-student-flow.spec.ts  # Student module E2E tests (12 tests)
    ├── 02-teacher-flow.spec.ts  # Teacher module E2E tests (8 tests)
    └── 03-admin-flow.spec.ts    # Admin module E2E tests (5 tests)
```
