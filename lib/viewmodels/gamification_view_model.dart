import 'package:flutter/foundation.dart';

import '../models/gamification_level.dart';
import '../models/gamification_season.dart';
import '../models/ranking_entry.dart';
import '../models/exam_template.dart';
import '../repositories/gamification_repository.dart';

class GamificationViewModel extends ChangeNotifier {
  GamificationViewModel({required GamificationRepository repository})
      : _repository = repository;

  final GamificationRepository _repository;

  // State
  bool _loading = false;
  String? _error;
  GamificationSeason? _activeSeason;
  double _userPoints = 0;
  GamificationLevel _userLevel = GamificationLevel.iniciante;

  // Rankings
  List<RankingEntry> _globalRanking = [];
  RankingEntry? _userGlobalRank;
  List<RankingEntry> _courseRanking = [];
  List<RankingEntry> _templateRanking = [];

  // Templates
  List<ExamTemplate> _publishedTemplates = [];
  Set<String> _attemptedTemplateIds = {};

  // Season history
  List<SeasonHistoryEntry> _seasonHistory = [];

  // Getters
  bool get loading => _loading;
  String? get error => _error;
  GamificationSeason? get activeSeason => _activeSeason;
  double get userPoints => _userPoints;
  GamificationLevel get userLevel => _userLevel;
  List<RankingEntry> get globalRanking => _globalRanking;
  RankingEntry? get userGlobalRank => _userGlobalRank;
  List<RankingEntry> get courseRanking => _courseRanking;
  List<RankingEntry> get templateRanking => _templateRanking;
  List<ExamTemplate> get publishedTemplates => _publishedTemplates;
  Set<String> get attemptedTemplateIds => _attemptedTemplateIds;
  List<SeasonHistoryEntry> get seasonHistory => _seasonHistory;

  // ── Load user gamification data ─────────────────────────

  Future<void> loadUserGamification(String userId) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _activeSeason = await _repository.getOrCreateActiveSeason();
      _userPoints = await _repository.getUserSeasonPoints(
        userId: userId,
        seasonId: _activeSeason!.id,
      );
      _userLevel = GamificationLevel.fromPoints(_userPoints);
      _userGlobalRank = await _repository.getUserGlobalRank(
        userId: userId,
        seasonId: _activeSeason!.id,
      );
    } catch (e) {
      _error = e.toString();
      debugPrint('Failed to load user gamification: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // ── Rankings ────────────────────────────────────────────

  Future<void> loadGlobalRanking() async {
    if (_activeSeason == null) {
      _error = 'Temporada não carregada';
      notifyListeners();
      return;
    }
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _globalRanking = await _repository.getGlobalRanking(
        seasonId: _activeSeason!.id,
      );
    } catch (e) {
      _error = e.toString();
      debugPrint('Failed to load global ranking: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadCourseRanking(String courseId) async {
    if (_activeSeason == null) {
      _error = 'Temporada não carregada';
      notifyListeners();
      return;
    }
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _courseRanking = await _repository.getCourseRanking(
        seasonId: _activeSeason!.id,
        courseId: courseId,
      );
    } catch (e) {
      _error = e.toString();
      debugPrint('Failed to load course ranking: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadTemplateRanking(String templateId) async {
    if (_activeSeason == null) {
      _error = 'Temporada não carregada';
      notifyListeners();
      return;
    }
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _templateRanking = await _repository.getTemplateRanking(
        templateId: templateId,
        seasonId: _activeSeason!.id,
      );
    } catch (e) {
      _error = e.toString();
      debugPrint('Failed to load template ranking: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // ── Templates ───────────────────────────────────────────

  Future<void> loadPublishedTemplates(String userId) async {
    try {
      _publishedTemplates = await _repository.getPublishedTemplates();

      // Check which templates the user attempted
      _attemptedTemplateIds = {};
      for (final template in _publishedTemplates) {
        final attempted = await _repository.hasUserAttemptedTemplate(
          userId: userId,
          templateId: template.id,
        );
        if (attempted) {
          _attemptedTemplateIds.add(template.id);
        }
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      debugPrint('Failed to load published templates: $e');
      notifyListeners();
    }
  }

  // ── Season History ──────────────────────────────────────

  Future<void> loadSeasonHistory(String userId) async {
    try {
      _seasonHistory = await _repository.getUserSeasonHistory(userId: userId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      debugPrint('Failed to load season history: $e');
      notifyListeners();
    }
  }
}
