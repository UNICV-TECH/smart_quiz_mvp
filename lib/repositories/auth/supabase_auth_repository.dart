import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_repository.dart';
import 'auth_repository_types.dart';

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

      final rawFullName = user.userMetadata?['full_name'];
      final fullName = rawFullName is String ? rawFullName : null;

      if (rawFullName != null && fullName == null) {
        debugPrint(
          'SupabaseAuthRepository: unexpected full_name type '
          '(${rawFullName.runtimeType}). Ignorando valor.',
        );
      }

      return AuthRepositorySignInResponse(
        user: AuthRepositoryUser(
          id: user.id,
          email: user.email ?? email,
          name: fullName,
        ),
      );
    } on AuthException catch (error) {
      final normalizedMessage = error.message.toLowerCase();
      final errorCode = (error.code ?? '').toLowerCase();
      final statusCodeRaw = error.statusCode;
      final statusCode =
          statusCodeRaw != null ? int.tryParse(statusCodeRaw) : null;
      final isInvalidCredentialsStatusCode =
          statusCode == 400 || statusCode == 401;

      if (errorCode == 'email_not_confirmed' ||
          normalizedMessage.contains('email not confirmed')) {
        throw const AuthRepositoryException(
          'Seu e-mail ainda não foi confirmado.',
          code: AuthRepositoryErrorCode.emailNotConfirmed,
        );
      }

      if (errorCode == 'invalid_credentials' ||
          isInvalidCredentialsStatusCode ||
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
  @override
  Future<AuthRepositoryUser> updateUserName({
    required String userId,
    required String newName,
  }) async {
    try {
      // Atualiza o campo 'full_name' no user_metadata
      final response = await _client.auth.updateUser(
        UserAttributes(
          data: {'full_name': newName},
        ),
      );

      final user = response.user;
      if (user == null) {
        throw const AuthRepositoryException(
          'Não foi possível atualizar o nome do usuário.',
        );
      }

      final updatedName = user.userMetadata?['full_name'] as String?;

      return AuthRepositoryUser(
        id: user.id,
        email: user.email ?? '',
        name: updatedName,
      );
    } on AuthException catch (error) {
      throw AuthRepositoryException(
        error.message.isNotEmpty
            ? error.message
            : 'Erro ao atualizar nome do usuário.',
      );
    } catch (e) {
      throw const AuthRepositoryException(
        'Erro inesperado ao atualizar nome do usuário.',
      );
    }
  }

}
