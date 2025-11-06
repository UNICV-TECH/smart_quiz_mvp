import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseOptions {
  SupabaseOptions._();

  static String get url {
    // Tentar usar dotenv primeiro (para mobile/desktop)
    try {
      final dotenvUrl = dotenv.env['SUPABASE_URL'] ?? '';
      if (dotenvUrl.isNotEmpty) {
        return dotenvUrl;
      }
    } catch (e) {
      // dotenv não foi carregado ou não está disponível
    }

    // Valores padrão (hardcoded para desenvolvimento web)
    // Para produção, use --dart-define=SUPABASE_URL=... no build
    // e defina como const
    if (kIsWeb) {
      return 'https://mrqovopbwfdffumhtcaz.supabase.co';
    }

    return '';
  }

  static String get anonKey {
    // Tentar usar dotenv primeiro (para mobile/desktop)
    try {
      final dotenvKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
      if (dotenvKey.isNotEmpty) {
        return dotenvKey;
      }
    } catch (e) {
      // dotenv não foi carregado ou não está disponível
    }

    // Valores padrão (hardcoded para desenvolvimento web)
    // Para produção, use --dart-define=SUPABASE_ANON_KEY=... no build
    // e defina como const
    if (kIsWeb) {
      return 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1ycW92b3Bid2ZkZmZ1bWh0Y2F6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU2MjMxMzUsImV4cCI6MjA3MTE5OTEzNX0.b0dRbLEragykIlsBjtjzUk8FDt5SpuNspYY3-6bnOIc';
    }

    return '';
  }

  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}
