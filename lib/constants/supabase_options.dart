import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseOptions {
  SupabaseOptions._();

  static String get url {
    // --dart-define=SUPABASE_URL=... vence primeiro. É passado pelo build web
    // de produção (CI) e pelos testes E2E (apontando para o Supabase local).
    // Builds nativos de produção não passam esse define, então caem no dotenv.
    const defineUrl = String.fromEnvironment('SUPABASE_URL');
    if (defineUrl.isNotEmpty) {
      return defineUrl;
    }

    // dotenv (mobile/desktop com assets/dotenv.env).
    try {
      final dotenvUrl = dotenv.env['SUPABASE_URL'] ?? '';
      if (dotenvUrl.isNotEmpty) {
        return dotenvUrl;
      }
    } catch (e) {
      // dotenv não foi carregado ou não está disponível
    }

    // Valor padrão (hardcoded para web) — último fallback de produção.
    if (kIsWeb) {
      return 'https://mrqovopbwfdffumhtcaz.supabase.co';
    }

    return '';
  }

  static String get anonKey {
    // --dart-define=SUPABASE_ANON_KEY=... vence primeiro (build web de produção
    // via CI e testes E2E locais). Builds nativos de produção caem no dotenv.
    const defineKey = String.fromEnvironment('SUPABASE_ANON_KEY');
    if (defineKey.isNotEmpty) {
      return defineKey;
    }

    // dotenv (mobile/desktop com assets/dotenv.env).
    try {
      final dotenvKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
      if (dotenvKey.isNotEmpty) {
        return dotenvKey;
      }
    } catch (e) {
      // dotenv não foi carregado ou não está disponível
    }

    // Valor padrão (hardcoded para web) — último fallback de produção.
    if (kIsWeb) {
      return 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1ycW92b3Bid2ZkZmZ1bWh0Y2F6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU2MjMxMzUsImV4cCI6MjA3MTE5OTEzNX0.b0dRbLEragykIlsBjtjzUk8FDt5SpuNspYY3-6bnOIc';
    }

    return '';
  }

  static String get appBaseUrl {
    const defineUrl = String.fromEnvironment('APP_BASE_URL');
    if (defineUrl.isNotEmpty) {
      return defineUrl;
    }
    return 'https://smartquiz.unicvtech.com.br';
  }

  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}
