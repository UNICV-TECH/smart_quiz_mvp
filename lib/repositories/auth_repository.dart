import 'package:supabase_flutter/supabase_flutter.dart';

enum AuthRepositoryErrorCode {
  emailNotConfirmed,
  invalidCredentials,
  unknown,
}

class AuthRepositoryException implements Exception {
  const AuthRepositoryException(
    this.message, {
    this.code = AuthRepositoryErrorCode.unknown,
  });

  final String message;
  final AuthRepositoryErrorCode code;
}

class AuthRepositoryUser {
  const AuthRepositoryUser({
    required this.id,
    required this.email,
    this.name,
  });

  final String id;
  final String email;
  final String? name;
}

class AuthRepositorySignUpResponse {
  const AuthRepositorySignUpResponse({required this.needsEmailConfirmation});

  final bool needsEmailConfirmation;
}

class AuthRepositorySignInResponse {
  const AuthRepositorySignInResponse({
    required this.user,
  });

  final AuthRepositoryUser user;
}

abstract class AuthRepository {
  Future<AuthRepositorySignUpResponse> signUp({
    required String email,
    required String password,
    required String name,
  });

  Future<AuthRepositorySignInResponse> signIn({
    required String email,
    required String password,
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

  @override
  Future<AuthRepositorySignInResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw const AuthRepositoryException(
          'Não foi possível recuperar as informações do usuário.',
        );
      }

      return AuthRepositorySignInResponse(
        user: AuthRepositoryUser(
          id: user.id,
          email: user.email ?? email,
          name: user.userMetadata?['full_name'] as String?,
        ),
      );
    } on AuthException catch (error) {
      final normalizedMessage = error.message.toLowerCase();
      final errorCode = (error.code ?? '').toLowerCase();
      final statusCode = error.statusCode;

      if (errorCode == 'email_not_confirmed' ||
          normalizedMessage.contains('email not confirmed')) {
        throw const AuthRepositoryException(
          'Seu e-mail ainda não foi confirmado.',
          code: AuthRepositoryErrorCode.emailNotConfirmed,
        );
      }

      if (errorCode == 'invalid_credentials' ||
          statusCode == '400' ||
          normalizedMessage.contains('invalid login credentials') ||
          normalizedMessage.contains('invalid login')) {
        throw const AuthRepositoryException(
          'Credenciais inválidas. Verifique e tente novamente.',
          code: AuthRepositoryErrorCode.invalidCredentials,
        );
      }

      throw AuthRepositoryException(
        error.message.isNotEmpty
            ? error.message
            : 'Não foi possível concluir o login.',
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

  @override
  Future<AuthRepositorySignInResponse> signIn({
    required String email,
    required String password,
  }) async {
    throw const AuthRepositoryException(
      'Login temporariamente indisponível. Verifique a configuração do Supabase.',
    );
  }
}
