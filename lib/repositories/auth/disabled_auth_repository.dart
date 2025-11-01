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
  Future<AuthRepositoryUser> updateUserName({required String userId, required String newName}) {
    // TODO: implement updateUserName
    throw UnimplementedError();
  }
}
