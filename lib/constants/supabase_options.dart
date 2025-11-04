class SupabaseOptions {
  SupabaseOptions._();
  static String get url => String.fromEnvironment('SUPABASE_URL');
  static String get anonKey => String.fromEnvironment('SUPABASE_ANON_KEY');

  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}
