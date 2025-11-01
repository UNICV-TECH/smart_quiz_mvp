class SupportingText {
  final String id;
  final String questionId;
  final String contentType;
  final String content;
  final int displayOrder;
  final DateTime createdAt;

  const SupportingText({
    required this.id,
    required this.questionId,
    required this.contentType,
    required this.content,
    this.displayOrder = 1,
    required this.createdAt,
  });

  factory SupportingText.fromJson(Map<String, dynamic> json) {
    return SupportingText(
      id: json['id'] as String,
      questionId: json['question_id'] as String,
      contentType: json['content_type'] as String,
      content: json['content'] as String,
      displayOrder: json['display_order'] as int? ?? 1,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question_id': questionId,
      'content_type': contentType,
      'content': content,
      'display_order': displayOrder,
      'created_at': createdAt.toIso8601String(),
    };
  }

  SupportingText copyWith({
    String? id,
    String? questionId,
    String? contentType,
    String? content,
    int? displayOrder,
    DateTime? createdAt,
  }) {
    return SupportingText(
      id: id ?? this.id,
      questionId: questionId ?? this.questionId,
      contentType: contentType ?? this.contentType,
      content: content ?? this.content,
      displayOrder: displayOrder ?? this.displayOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
