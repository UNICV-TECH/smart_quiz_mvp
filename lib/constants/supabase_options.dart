import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseOptions {
  SupabaseOptions._();
  static String get url => dotenv.env['SUPABASE_URL'] ?? '';
  static String get anonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}
