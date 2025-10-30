import 'package:flutter/material.dart';

class Course {
  final String id;
  final String courseKey;
  final String title;
  final String? description;
  final String? iconKey;
  final IconData? iconData;
  final bool isActive;
  final DateTime createdAt;

  const Course({
    required this.id,
    required this.courseKey,
    required this.title,
    this.description,
    this.iconKey,
    this.iconData,
    this.isActive = true,
    required this.createdAt,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as String,
      courseKey: json['course_key'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      iconKey: json['icon_key'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course_key': courseKey,
      'title': title,
      'description': description,
      'icon_key': iconKey,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Course copyWith({
    String? id,
    String? courseKey,
    String? title,
    String? description,
    String? iconKey,
    IconData? iconData,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Course(
      id: id ?? this.id,
      courseKey: courseKey ?? this.courseKey,
      title: title ?? this.title,
      description: description ?? this.description,
      iconKey: iconKey ?? this.iconKey,
      iconData: iconData ?? this.iconData,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
