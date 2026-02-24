class Subject {
  final String id;
  final String name;
  final String? description;
  final String courseId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Subject({
    required this.id,
    required this.name,
    this.description,
    required this.courseId,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      courseId: json['id_course'] as String,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'id_course': courseId,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'name': name,
      'description': description,
      'id_course': courseId,
      'is_active': isActive,
    };
  }

  Subject copyWith({
    String? id,
    String? name,
    String? description,
    String? courseId,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Subject(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      courseId: courseId ?? this.courseId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
