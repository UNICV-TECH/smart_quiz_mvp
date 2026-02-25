class RankingEntry {
  final String userId;
  final String seasonId;
  final String userName;
  final String? avatarUrl;
  final double seasonPoints;
  final int totalAttempts;
  final int rankPosition;
  final String? courseId;
  final String? courseName;
  final String? examTemplateId;
  final String? templateName;

  const RankingEntry({
    required this.userId,
    required this.seasonId,
    required this.userName,
    this.avatarUrl,
    required this.seasonPoints,
    required this.totalAttempts,
    required this.rankPosition,
    this.courseId,
    this.courseName,
    this.examTemplateId,
    this.templateName,
  });

  factory RankingEntry.fromJson(Map<String, dynamic> json) {
    return RankingEntry(
      userId: json['user_id'] as String? ?? '',
      seasonId: json['season_id'] as String? ?? '',
      userName: json['user_name'] as String? ?? 'Aluno',
      avatarUrl: json['avatar_url'] as String?,
      seasonPoints: (json['season_points'] as num).toDouble(),
      totalAttempts: (json['total_attempts'] as num).toInt(),
      rankPosition: (json['rank_position'] as num).toInt(),
      courseId: json['course_id'] as String?,
      courseName: json['course_name'] as String?,
      examTemplateId: json['exam_template_id'] as String?,
      templateName: json['template_name'] as String?,
    );
  }

  factory RankingEntry.fromGlobalJson(Map<String, dynamic> json) =>
      RankingEntry.fromJson(json);

  factory RankingEntry.fromCourseJson(Map<String, dynamic> json) =>
      RankingEntry.fromJson(json);

  factory RankingEntry.fromTemplateJson(Map<String, dynamic> json) =>
      RankingEntry.fromJson(json);
}
