import 'user_model.dart';

class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    this.name,
    this.role = UserRole.student,
  });

  final String id;
  final String email;
  final String? name;
  final UserRole role;

  bool get isTeacher => role == UserRole.teacher || role == UserRole.admin;
  bool get isAdmin => role == UserRole.admin;

  AuthUser copyWith({
    String? id,
    String? email,
    String? name,
    UserRole? role,
  }) {
    return AuthUser(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
    );
  }
}
