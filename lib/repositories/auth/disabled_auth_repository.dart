import 'auth_repository.dart';
import 'auth_repository_types.dart';

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

  @override
  Future<void> resetPasswordForEmail(String email) async {
    throw const AuthRepositoryException(
      'Recuperação de senha temporariamente indisponível. Verifique a configuração do Supabase.',
    );
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    throw const AuthRepositoryException(
      'Alteração de senha temporariamente indisponível. Verifique a configuração do Supabase.',
    );
  }
}
