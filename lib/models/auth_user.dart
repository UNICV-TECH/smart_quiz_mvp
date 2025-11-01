class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    this.name,
  });

  final String id;
  final String email;
  final String? name;

   AuthUser copyWith({
    String? id,
    String? email,
    String? name,
  }) {
    return AuthUser(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
    );
  }
}
