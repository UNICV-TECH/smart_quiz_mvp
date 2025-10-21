import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepositoryException implements Exception {
  const AuthRepositoryException(this.message);

  final String message;
}

class AuthRepositorySignUpResponse {
  const AuthRepositorySignUpResponse({required this.needsEmailConfirmation});

  final bool needsEmailConfirmation;
}

abstract class AuthRepository {
  Future<AuthRepositorySignUpResponse> signUp({
    required String email,
    required String password,
    required String name,
  });
}

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository({required SupabaseClient client}) : _client = client;

  final SupabaseClient _client;

  @override
  Future<AuthRepositorySignUpResponse> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': name},
      );

      return AuthRepositorySignUpResponse(
        needsEmailConfirmation: response.session == null,
      );
    } on AuthException catch (error) {
      throw AuthRepositoryException(
        error.message.isNotEmpty
            ? error.message
            : 'Não foi possível concluir o cadastro.',
      );
    } catch (_) {
      throw const AuthRepositoryException(
        'Não foi possível comunicar com o serviço de autenticação.',
      );
    }
  }
}

class DisabledAuthRepository implements AuthRepository {
  const DisabledAuthRepository();

  @override
  Future<AuthRepositorySignUpResponse> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    throw const AuthRepositoryException(
      'Cadastro temporariamente indisponível. Verifique a configuração do Supabase.',
    );
  }
}
