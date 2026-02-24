import 'package:flutter/foundation.dart';

import '../../models/exam_template.dart';
import '../../models/gamification_season.dart';
import '../../models/ranking_entry.dart';
import '../../repositories/gamification_repository.dart';
import '../../repositories/teacher_repository.dart';

class TeacherGamificationViewModel extends ChangeNotifier {
  TeacherGamificationViewModel({
    required GamificationRepository gamificationRepository,
    required TeacherRepository teacherRepository,
    required this.teacherId,
  })  : _gamificationRepo = gamificationRepository,
        _teacherRepo = teacherRepository;

  final GamificationRepository _gamificationRepo;
  final TeacherRepository _teacherRepo;
  final String teacherId;

  // State
  bool _loading = false;
  String? _error;
  GamificationSeason? _activeSeason;
  List<ExamTemplate> _templates = [];
  ExamTemplate? _selectedTemplate;
  List<RankingEntry> _templateRanking = [];

  // Statistics
  int _totalParticipants = 0;
  double _averagePoints = 0;
  double _bestScore = 0;
  double _worstScore = 0;

  // Getters
  bool get loading => _loading;
  String? get error => _error;
  List<ExamTemplate> get templates => _templates;
  ExamTemplate? get selectedTemplate => _selectedTemplate;
  List<RankingEntry> get templateRanking => _templateRanking;
  int get totalParticipants => _totalParticipants;
  double get averagePoints => _averagePoints;
  double get bestScore => _bestScore;
  double get worstScore => _worstScore;

  Future<void> initialize() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _activeSeason = await _gamificationRepo.getOrCreateActiveSeason();
      _templates = await _teacherRepo.fetchTemplates(teacherId: teacherId);
    } catch (e) {
      _error = e.toString();
      debugPrint('Failed to initialize teacher gamification: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> selectTemplate(ExamTemplate template) async {
    if (_activeSeason == null) return;

    _selectedTemplate = template;
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _templateRanking = await _gamificationRepo.getTemplateRanking(
        templateId: template.id,
        seasonId: _activeSeason!.id,
      );

      // Calculate statistics
      _totalParticipants = _templateRanking.length;
      if (_templateRanking.isNotEmpty) {
        final points =
            _templateRanking.map((e) => e.seasonPoints).toList();
        _averagePoints = points.reduce((a, b) => a + b) / points.length;
        _bestScore = points.reduce((a, b) => a > b ? a : b);
        _worstScore = points.reduce((a, b) => a < b ? a : b);
      } else {
        _averagePoints = 0;
        _bestScore = 0;
        _worstScore = 0;
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Failed to load template ranking: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
