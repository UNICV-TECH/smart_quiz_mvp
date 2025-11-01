# AGENTS.md

## Commands

**Setup**: `flutter pub get` (ensure Flutter SDK is installed)  
**Build**: `flutter build apk` (Android) or `flutter build ios` (iOS)  
**Lint**: `flutter analyze`  
**Test**: `flutter test`  
**Dev Server**: `flutter run` (requires connected device/emulator)

## Tech Stack

- **Framework**: Flutter/Dart (SDK >=3.1.0)
- **State Management**: Provider
- **Backend**: Supabase (auth, database)
- **Key Dependencies**: supabase_flutter, flutter_dotenv, google_fonts, result_command

## Architecture

- **Pattern**: MVVM (Model-View-ViewModel)
- **Structure**: `/lib` contains models, repositories, services, viewmodels, views, widgets, ui/components, constants
- **Auth**: Repository pattern with Supabase implementation + disabled fallback

## Code Style

- Linter: `flutter_lints` with custom rules in `analysis_options.yaml`
- File naming: snake_case (enforced off)
- Const constructors: not required (disabled)
- Use Provider for dependency injection and state management
