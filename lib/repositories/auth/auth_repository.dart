import 'auth_repository_types.dart';

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
