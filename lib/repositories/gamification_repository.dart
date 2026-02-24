import '../models/gamification_season.dart';
import '../models/gamification_points.dart';
import '../models/ranking_entry.dart';
import '../models/exam_template.dart';

abstract class GamificationRepository {
  // Season
  Future<GamificationSeason> getOrCreateActiveSeason();

  // Points
  Future<SavePointsResult> saveAttemptPoints({
    required String userId,
    required String seasonId,
    required String attemptId,
    required String examId,
    required String courseId,
    required int questionCount,
    required int correctCount,
    required double percentageScore,
    required int durationSeconds,
    required double basePoints,
    required double timeBonus,
    required double totalPoints,
  });

  // User gamification data
  Future<double> getUserSeasonPoints({
    required String userId,
    required String seasonId,
  });

  // Rankings
  Future<List<RankingEntry>> getGlobalRanking({
    required String seasonId,
    int limit = 50,
  });

  Future<RankingEntry?> getUserGlobalRank({
    required String userId,
    required String seasonId,
  });

  Future<List<RankingEntry>> getCourseRanking({
    required String seasonId,
    required String courseId,
    int limit = 50,
  });

  Future<List<RankingEntry>> getTemplateRanking({
    required String templateId,
    required String seasonId,
    int limit = 50,
  });

  // Templates (published)
  Future<List<ExamTemplate>> getPublishedTemplates();

  Future<bool> hasUserAttemptedTemplate({
    required String userId,
    required String templateId,
  });

  // Season history
  Future<List<SeasonHistoryEntry>> getUserSeasonHistory({
    required String userId,
  });
}

class SeasonHistoryEntry {
  final String seasonId;
  final String seasonName;
  final double totalPoints;
  final int rankPosition;
  final bool isActive;

  const SeasonHistoryEntry({
    required this.seasonId,
    required this.seasonName,
    required this.totalPoints,
    required this.rankPosition,
    required this.isActive,
  });
}
