import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../constants/supabase_options.dart';
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

      // Supabase retorna sucesso falso para emails duplicados (proteção contra enumeração).
      // Quando isso acontece, a lista de identities vem vazia.
      if (response.user?.identities?.isEmpty == true) {
        throw const AuthRepositoryException(
          'Este e-mail já está cadastrado. Tente fazer login ou recuperar sua senha.',
          code: AuthRepositoryErrorCode.emailAlreadyRegistered,
        );
      }

      // Criar registro na tabela user após signup bem-sucedido
      final user = response.user;
      if (user != null) {
        try {
          // Separar nome em primeiro nome e sobrenome (se possível)
          final nameParts = name.trim().split(' ');
          final firstName = nameParts.isNotEmpty ? nameParts.first : name;
          final surname =
              nameParts.length > 1 ? nameParts.sublist(1).join(' ') : null;

          await _client.from('user').upsert({
            'id': user.id,
            'email': email,
            'first_name': firstName,
            'surename': surname,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          });

          debugPrint('Registro do usuário criado na tabela user: ${user.id}');
        } catch (e) {
          // Log do erro mas não falha o signup se não conseguir criar na tabela user
          debugPrint(
            'Erro ao criar registro na tabela user após signup: $e',
          );
        }
      }

      return AuthRepositorySignUpResponse(
        needsEmailConfirmation: response.session == null,
      );
    } on AuthRepositoryException {
      rethrow;
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
  Future<void> resetPasswordForEmail(String email) async {
    try {
      // Verificar se o e-mail existe na tabela user antes de enviar
      final existing = await _client
          .from('user')
          .select('id')
          .eq('email', email)
          .maybeSingle();

      if (existing == null) {
        throw const AuthRepositoryException(
          'E-mail não encontrado. Verifique o endereço informado.',
        );
      }

      await _client.auth.resetPasswordForEmail(
        email,
        redirectTo: '${SupabaseOptions.appBaseUrl}/reset-password/confirm',
      );
    } on AuthRepositoryException {
      rethrow;
    } on AuthException catch (error) {
      throw AuthRepositoryException(
        error.message.isNotEmpty
            ? error.message
            : 'Não foi possível enviar o e-mail de recuperação.',
      );
    } catch (_) {
      throw const AuthRepositoryException(
        'Não foi possível comunicar com o serviço de autenticação.',
      );
    }
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    try {
      await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } on AuthException catch (error) {
      throw AuthRepositoryException(
        error.message.isNotEmpty
            ? error.message
            : 'Não foi possível atualizar a senha.',
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

      // Garantir que o usuário existe na tabela user
      try {
        final existing = await _client
            .from('user')
            .select('id')
            .eq('id', user.id)
            .maybeSingle();

        if (existing == null) {
          // Separar nome em primeiro nome e sobrenome (se possível)
          final nameParts = (fullName ?? '').trim().split(' ');
          final firstName = nameParts.isNotEmpty ? nameParts.first : fullName;
          final surname =
              nameParts.length > 1 ? nameParts.sublist(1).join(' ') : null;

          await _client.from('user').upsert({
            'id': user.id,
            'email': user.email ?? email,
            'first_name': firstName,
            'surename': surname,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          });

          debugPrint(
            'Registro do usuário criado na tabela user durante login: ${user.id}',
          );
        }
      } catch (e) {
        // Log do erro mas não falha o login se não conseguir criar na tabela user
        debugPrint(
          'Erro ao garantir registro na tabela user durante login: $e',
        );
      }

      // Check if user account is active
      try {
        final userRecord = await _client
            .from('user')
            .select('is_active')
            .eq('id', user.id)
            .maybeSingle();

        if (userRecord != null && userRecord['is_active'] == false) {
          await _client.auth.signOut();
          throw const AuthRepositoryException(
            'Sua conta foi desativada. Entre em contato com o administrador.',
            code: AuthRepositoryErrorCode.accountDisabled,
          );
        }
      } catch (e) {
        if (e is AuthRepositoryException) rethrow;
        debugPrint('Erro ao verificar status do usuário: $e');
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
    } on AuthRepositoryException {
      rethrow;
    } catch (_) {
      throw const AuthRepositoryException(
        'Não foi possível comunicar com o serviço de autenticação.',
      );
    }
  }
}
