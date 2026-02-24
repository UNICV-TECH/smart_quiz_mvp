class GamificationSeason {
  final String id;
  final String name;
  final DateTime startsAt;
  final DateTime endsAt;
  final bool isActive;
  final DateTime createdAt;

  const GamificationSeason({
    required this.id,
    required this.name,
    required this.startsAt,
    required this.endsAt,
    required this.isActive,
    required this.createdAt,
  });

  factory GamificationSeason.fromJson(Map<String, dynamic> json) {
    return GamificationSeason(
      id: json['id'] as String,
      name: json['name'] as String,
      startsAt: DateTime.parse(json['starts_at'] as String),
      endsAt: DateTime.parse(json['ends_at'] as String),
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
