import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/gamification_season.dart';
import '../models/gamification_points.dart';
import '../models/ranking_entry.dart';
import '../models/exam_template.dart';
import 'gamification_repository.dart';

class SupabaseGamificationRepository implements GamificationRepository {
  SupabaseGamificationRepository({required SupabaseClient client})
      : _client = client;

  final SupabaseClient _client;

  // ── Season ──────────────────────────────────────────────

  @override
  Future<GamificationSeason> getOrCreateActiveSeason() async {
    final response = await _client.rpc('get_or_create_active_season');
    return GamificationSeason.fromJson(response as Map<String, dynamic>);
  }

  // ── Points ──────────────────────────────────────────────

  @override
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
  }) async {
    // 1. Resolve exam_template_id from exam table
    String? examTemplateId;
    try {
      final examRow = await _client
          .from('exam')
          .select('id_exam_template')
          .eq('id', examId)
          .maybeSingle();
      examTemplateId = examRow?['id_exam_template'] as String?;
    } catch (e) {
      debugPrint('Could not resolve exam_template_id: $e');
    }

    // 2. Check previous points for retake comparison
    double previousSum = 0;
    try {
      List<dynamic> previousRecords;
      if (examTemplateId != null) {
        // Template exam: compare by exam_template_id
        previousRecords = await _client
            .from('user_gamification_points')
            .select('total_points')
            .eq('user_id', userId)
            .eq('season_id', seasonId)
            .eq('exam_template_id', examTemplateId);
      } else {
        // Regular exam: compare by exam_id
        previousRecords = await _client
            .from('user_gamification_points')
            .select('total_points')
            .eq('user_id', userId)
            .eq('season_id', seasonId)
            .eq('exam_id', examId);
      }

      for (final record in previousRecords) {
        previousSum +=
            (record['total_points'] as num?)?.toDouble() ?? 0;
      }
    } catch (e) {
      debugPrint('Could not fetch previous points: $e');
    }

    // 3. Compare: only save if improved
    final previousPoints = previousSum;
    if (totalPoints <= previousSum) {
      // Did not improve — do not save new record
      return SavePointsResult(
        accumulatedPoints: previousSum,
        previousPoints: previousSum,
        didImprove: false,
        pointsSaved: 0,
      );
    }

    // 4. Save only the difference
    final difference = totalPoints - previousSum;
    await _client.from('user_gamification_points').insert({
      'user_id': userId,
      'season_id': seasonId,
      'attempt_id': attemptId,
      'exam_id': examId,
      'course_id': courseId,
      'exam_template_id': examTemplateId,
      'question_count': questionCount,
      'correct_count': correctCount,
      'percentage_score': percentageScore,
      'duration_seconds': durationSeconds,
      'base_points': basePoints,
      'time_bonus': timeBonus,
      'total_points': difference,
    });

    final accumulatedPoints = previousSum + difference;
    return SavePointsResult(
      accumulatedPoints: accumulatedPoints,
      previousPoints: previousPoints,
      didImprove: true,
      pointsSaved: difference,
    );
  }

  // ── User points ─────────────────────────────────────────

  @override
  Future<double> getUserSeasonPoints({
    required String userId,
    required String seasonId,
  }) async {
    final rows = await _client
        .from('user_gamification_points')
        .select('total_points')
        .eq('user_id', userId)
        .eq('season_id', seasonId);

    double sum = 0;
    for (final row in rows) {
      sum += (row['total_points'] as num?)?.toDouble() ?? 0;
    }
    return sum;
  }

  // ── Rankings ────────────────────────────────────────────

  @override
  Future<List<RankingEntry>> getGlobalRanking({
    required String seasonId,
    int limit = 50,
  }) async {
    final rows = await _client
        .from('ranking_global_view')
        .select()
        .eq('season_id', seasonId)
        .order('rank_position')
        .limit(limit);

    return rows
        .map((r) => RankingEntry.fromGlobalJson(r))
        .toList();
  }

  @override
  Future<RankingEntry?> getUserGlobalRank({
    required String userId,
    required String seasonId,
  }) async {
    final row = await _client
        .from('ranking_global_view')
        .select()
        .eq('season_id', seasonId)
        .eq('user_id', userId)
        .maybeSingle();

    if (row == null) return null;
    return RankingEntry.fromGlobalJson(row);
  }

  @override
  Future<List<RankingEntry>> getCourseRanking({
    required String seasonId,
    required String courseId,
    int limit = 50,
  }) async {
    final rows = await _client
        .from('ranking_course_view')
        .select()
        .eq('season_id', seasonId)
        .eq('course_id', courseId)
        .order('rank_position')
        .limit(limit);

    return rows
        .map((r) => RankingEntry.fromCourseJson(r))
        .toList();
  }

  @override
  Future<List<RankingEntry>> getTemplateRanking({
    required String templateId,
    required String seasonId,
    int limit = 50,
  }) async {
    final rows = await _client
        .from('ranking_template_view')
        .select()
        .eq('season_id', seasonId)
        .eq('exam_template_id', templateId)
        .order('rank_position')
        .limit(limit);

    return rows
        .map((r) => RankingEntry.fromTemplateJson(r))
        .toList();
  }

  // ── Templates ───────────────────────────────────────────

  @override
  Future<List<ExamTemplate>> getPublishedTemplates() async {
    final rows = await _client
        .from('exam_template')
        .select()
        .eq('is_published', true)
        .eq('is_active', true)
        .order('name');

    return rows
        .map((r) => ExamTemplate.fromJson(r))
        .toList();
  }

  @override
  Future<bool> hasUserAttemptedTemplate({
    required String userId,
    required String templateId,
  }) async {
    final row = await _client
        .from('user_gamification_points')
        .select('id')
        .eq('user_id', userId)
        .eq('exam_template_id', templateId)
        .limit(1)
        .maybeSingle();

    return row != null;
  }

  // ── Season History ──────────────────────────────────────

  @override
  Future<List<SeasonHistoryEntry>> getUserSeasonHistory({
    required String userId,
  }) async {
    // Get all seasons where the user has points
    final rows = await _client
        .from('ranking_global_view')
        .select('season_id, season_points, rank_position')
        .eq('user_id', userId);

    if (rows.isEmpty) return [];

    // Get season details
    final seasonIds =
        rows.map((r) => r['season_id'] as String).toSet().toList();

    final seasons = await _client
        .from('gamification_season')
        .select()
        .inFilter('id', seasonIds)
        .order('starts_at', ascending: false);

    final seasonMap = <String, Map<String, dynamic>>{};
    for (final s in seasons) {
      seasonMap[s['id'] as String] = s;
    }

    final history = <SeasonHistoryEntry>[];
    for (final row in rows) {
      final seasonId = row['season_id'] as String;
      final season = seasonMap[seasonId];
      if (season == null) continue;

      history.add(SeasonHistoryEntry(
        seasonId: seasonId,
        seasonName: season['name'] as String,
        totalPoints: (row['season_points'] as num).toDouble(),
        rankPosition: (row['rank_position'] as num).toInt(),
        isActive: season['is_active'] as bool,
      ));
    }

    // Sort: active first, then by season name descending
    history.sort((a, b) {
      if (a.isActive && !b.isActive) return -1;
      if (!a.isActive && b.isActive) return 1;
      return b.seasonName.compareTo(a.seasonName);
    });

    return history;
  }
}
