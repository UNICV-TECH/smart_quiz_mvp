import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../repositories/exam_attempt_repository_types.dart';
import '../repositories/supabase_exam_attempt_repository.dart';

class ExamHistoryViewModel extends ChangeNotifier {
  final SupabaseExamAttemptRepository _repository;

  ExamHistoryViewModel()
      : _repository = SupabaseExamAttemptRepository(
          client: Supabase.instance.client,
        );

  List<ExamAttemptHistory> _attempts = [];
  Map<String, String> _courseNames = {};
  bool _isLoading = false;
  String? _errorMessage;

  List<ExamAttemptHistory> get attempts => _attempts;
  Map<String, String> get courseNames => _courseNames;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadHistory({String? userId, String? courseId}) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) {
        _errorMessage = 'Usuário não autenticado';
        _isLoading = false;
        notifyListeners();
        return;
      }

      _attempts = await _repository.fetchUserAttempts(
        userId: userId ?? currentUser.id,
        courseId: courseId,
      );

      // Buscar nomes dos cursos
      final courseIds = _attempts.map((a) => a.courseId).toSet().toList();
      if (courseIds.isNotEmpty) {
        try {
          final coursesResponse = await Supabase.instance.client
              .from('course')
              .select('id, name, title')
              .inFilter('id', courseIds);

          _courseNames = {};
          for (var course in coursesResponse as List) {
            final courseId = course['id'] as String;
            final courseName = (course['title'] as String?) ??
                (course['name'] as String?) ??
                'Curso';
            _courseNames[courseId] = courseName;
          }
        } catch (e) {
          debugPrint('Erro ao buscar nomes dos cursos: $e');
        }
      }

      debugPrint(
          'ExamHistoryViewModel: Carregadas ${_attempts.length} tentativas');
      for (var attempt in _attempts) {
        debugPrint(
            '  - Tentativa ${attempt.id}: examId=${attempt.examId}, completedAt=${attempt.completedAt}');
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Erro ao carregar histórico: ${e.toString()}';
      notifyListeners();
    }
  }
}
