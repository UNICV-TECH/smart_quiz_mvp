import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseOptions {
  SupabaseOptions._();

  static String get url {
    try {
      return dotenv.env['SUPABASE_URL'] ?? '';
    } catch (e) {
      // dotenv não foi carregado ou não está disponível
      return '';
    }
  }

  static String get anonKey {
    try {
      return dotenv.env['SUPABASE_ANON_KEY'] ?? '';
    } catch (e) {
      // dotenv não foi carregado ou não está disponível
      return '';
    }
  }

  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}
