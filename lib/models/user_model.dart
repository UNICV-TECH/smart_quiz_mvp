enum UserRole {
  student,
  teacher,
  admin;

  static UserRole fromString(String? value) {
    switch (value) {
      case 'teacher':
        return UserRole.teacher;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.student;
    }
  }

  String toJson() => name;
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? phone;
  final String? avatarUrl;
  final String? bio;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.role = UserRole.student,
    this.phone,
    this.avatarUrl,
    this.bio,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? json['first_name'] ?? '',
      email: json['email'] ?? '',
      role: UserRole.fromString(json['role'] as String?),
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.toJson(),
      'phone': phone,
      'avatar_url': avatarUrl,
      'bio': bio,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role,
    String? phone,
    String? avatarUrl,
    String? bio,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
    );
  }

  bool get isTeacher => role == UserRole.teacher || role == UserRole.admin;
  bool get isAdmin => role == UserRole.admin;
}
