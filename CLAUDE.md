# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Smart Quiz - A Flutter quiz application for academic exam preparation (ENADE, OAB, etc.) built for UniCV university. Uses Supabase for backend services (auth, database).

## Commands

```bash
# Setup
flutter pub get

# Development
flutter run                              # Run on connected device/emulator
flutter run -d chrome                    # Run on Chrome (web)
flutter run --dart-define-from-file=.vscode/dev.json  # Run with local env vars

# Build
flutter build web --release              # Build for web (production uses --dart-define for secrets)
flutter build apk                        # Build Android APK
flutter build ios                        # Build iOS

# Quality
flutter analyze                          # Run static analysis
flutter test                             # Run all tests
flutter test test/integration_test.dart  # Run specific test file
flutter test --coverage                  # Run tests with coverage report

# Mock generation (if needed)
dart run build_runner build
```

## Architecture

**Pattern:** MVVM with Provider for state management

**Core Structure:**
- `lib/models/` - Data models (Course, Exam, Question, AnswerChoice, User, etc.)
- `lib/viewmodels/` - ViewModels extending ChangeNotifier (ExamViewModel, LoginViewModel, etc.)
- `lib/views/` - Screen widgets that consume ViewModels via Provider
- `lib/repositories/` - Repository pattern abstractions and Supabase implementations
- `lib/services/` - Business logic services (AuthService, SessionManager)
- `lib/ui/components/` - Reusable UI components (prefixed with `default_`)
- `lib/routes/app_routes.dart` - Centralized route definitions
- `lib/widgets/protected_route.dart` - Auth-protected route wrapper

**Authentication Flow:**
- `AuthRepository` interface with `SupabaseAuthRepository` and `DisabledAuthRepository` implementations
- `SessionManager` handles session state and navigation on auth changes
- `ProtectedRoute` widget guards authenticated screens

**Data Flow:**
Course selection → Quiz config → Exam screen → Results
- ViewModels fetch data via repositories
- Supabase tables: user, course, exam, question, answerchoice, examquestion, user_exam_attempts, user_responses

## Environment Configuration

- Web: Uses `--dart-define` for SUPABASE_URL and SUPABASE_ANON_KEY (set in CI/deploy)
- Native: Loads from `assets/dotenv.env` file
- Config accessed via `lib/constants/supabase_options.dart`

## Database Migrations

Located in `supabase/migrations/`. Apply in numerical order via Supabase CLI (`supabase db push`) or Dashboard SQL Editor.

## CI/CD

GitHub Actions workflow (`.github/workflows/deploy.yml`):
1. `analyze` - Runs `flutter analyze`
2. `test` - Runs `flutter test` (depends on analyze)
3. `build-and-deploy` - Builds web release on main branch push
