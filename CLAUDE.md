# CLAUDE.md

Flutter quiz app para preparação acadêmica (ENADE, OAB) — projeto de extensão da **UniCV**. Backend Supabase (auth + DB). 3 roles: `student`, `teacher`, `admin`.

> Schema completo do DB e roteiros longos vivem em `docs/DOCUMENTACAO_COMPLETA.md`. Este CLAUDE.md cobre só o essencial para sessões.

## Commands

```bash
flutter pub get
flutter run                                          # device/emulador
flutter run -d chrome                                # web
flutter run --dart-define-from-file=.vscode/dev.json # vars locais
flutter analyze
flutter test
flutter test --coverage
flutter build web --release                          # produção (vars via --dart-define)
dart run build_runner build                          # mocks
```

## Tech Stack

- Flutter SDK >=3.1.0 <4.0.0
- Supabase (PostgreSQL + Auth, Free tier)
- Provider + ChangeNotifier
- Google Fonts (Poppins), Material 3
- CI: GitHub Actions (Flutter 3.38.5) → Vercel

## Architecture (MVVM)

```
View (Screen) → ViewModel (ChangeNotifier) → Service → Repository (interface + Supabase impl)
```

Diretórios principais em `lib/`:

- `models/` — POJOs (UserModel, Question, Exam, RankingEntry, etc.)
- `viewmodels/` + `viewmodels/teacher/` — state per feature
- `views/` + `views/teacher/` — telas
- `repositories/` + `repositories/auth/` — interfaces + `SupabaseXRepository` impls
- `services/` — AuthService, SessionManager, GamificationCalculator
- `routes/app_routes.dart` — rotas registradas, protegidas via `ProtectedRoute`
- `ui/components/` — ~25 componentes reutilizáveis com prefixo `default_`
- `ui/theme/` — `app_color.dart`, `string_text.dart`

ViewModels nunca dependem de Repository direto, sempre via Service.
Repositórios Supabase-dependentes são nullable em DI — UI lida com `null` quando offline.

## Auth Flow

- `AuthService` → `SupabaseAuthRepository` → JWT
- `SessionManager` escuta `onAuthStateChange`, busca role na tabela `user`, detecta JWT expired/401/403 e força signOut
- Redirect: student → `/main` | teacher/admin → `/teacher`
- Recovery: dois passos (`/reset_password` → `/reset_password2` via `passwordRecovery` event)

## Gamification

| Level | Range | Medal asset |
|---|---|---|
| Iniciante | 0-100 | `medal_iniciante.png` |
| Explorador | 101-200 | `medal_explorador.png` |
| Mestre do Conteúdo | 201-300 | `medal_mestre.png` |
| Lendário | 301+ | `medal_lendario.png` |

Pontos: `1.0pt` (≤5q) / `1.25pt` (6-10q) / `1.50pt` (11+q) por acerto. Bonus de tempo = N questões se ≥70% corretas em ≤80% do tempo (2min/questão).
**Best Score Only**: só salva delta acima do anterior.
Seasons semestrais: `YYYY.S` (ex: `2026.1`), criadas via RPC `get_or_create_active_season()`.

Rankings via 3 SQL views: `ranking_global_view`, `ranking_course_view`, `ranking_template_view` (todas usam `RANK() OVER (PARTITION BY ... ORDER BY SUM(total_points) DESC)`).

## Env Setup

Web: `--dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...`
Native: `assets/dotenv.env` com `SUPABASE_URL` e `SUPABASE_ANON_KEY`.
Acesso via `lib/constants/supabase_options.dart`.

CI secrets (GitHub): `SUPABASE_URL`, `SUPABASE_ANON_KEY`.

## Migrations

`supabase/migrations/` aplicadas em ordem numérica via `supabase db push` ou Dashboard SQL.

Marcos:
- `20250204000001` — Teacher module
- `20260224000001` — Gamification
- `20260303000001` — Admin module

## Gotchas (legacy naming preservado)

| Quirk | Local |
|---|---|
| `answerchoice.idquestion` (sem underscore) | tabela answerchoice |
| `answerchoice.upload_at` (em vez de updated_at) | tabela answerchoice |
| `examquestion.update_at` (faltando d) | tabela examquestion |
| `user.surename` (typo de surname) | tabela user |
| `user_responses` antes era `userresponse` | renomeado em migration 006 |

**RLS**: ativo em `question_category`, `exam_template*`, `subject`, `gamification_*`. Demais tabelas sem RLS — checar no service layer.

## Conventions

- snake_case (arquivos), PascalCase (classes), camelCase (vars)
- Repositories sempre em par interface + impl Supabase
- Models com `fromJson`/`toJson` + `copyWith`
- UI components com prefixo `default_` em `lib/ui/components/`
- Rotas registradas em `app_routes.dart`, protegidas por `ProtectedRoute`
- Commits: `feat:`, `fix:`, `chore:`, `refactor:`, `docs:`, `test:`

## Pre-commit checklist

- [ ] Sem `.env` staged
- [ ] Sem chaves hardcoded
- [ ] `.gitignore` cobre: `.env`, `node_modules/`, `dist/`, `.dart_tool/`, `build/`
