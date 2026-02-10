import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// ViewModel para gerenciar templates de prova do professor
class TeacherExamTemplateViewModel extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  bool _isLoading = false;
  String? _errorMessage;

  // Dados do template
  String? _templateId;
  String _title = '';
  String _description = '';
  String? _courseId;
  final List<ExamQuestion> _questions = [];

  // Configurações da prova
  bool _showWrongQuestions = true;
  bool _showCorrectAnswers = true;
  bool _showScores = true;
  bool _requireInstitutionalLogin = true;
  bool _singleAttemptOnly = true;
  bool _useDefaultQuestionScore = true;
  int? _timeLimitMinutes;
  final double _passingScorePercentage = 60.0;

  // Respostas dos alunos (tentativas)
  List<StudentAttempt> _studentAttempts = [];

  // Questões disponíveis para importação
  List<QuestionBankItem> _availableQuestions = [];

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get templateId => _templateId;
  String get title => _title;
  String get description => _description;
  String? get courseId => _courseId;

  bool get showWrongQuestions => _showWrongQuestions;
  bool get showCorrectAnswers => _showCorrectAnswers;
  bool get showScores => _showScores;
  bool get requireInstitutionalLogin => _requireInstitutionalLogin;
  bool get singleAttemptOnly => _singleAttemptOnly;
  bool get useDefaultQuestionScore => _useDefaultQuestionScore;
  int? get timeLimitMinutes => _timeLimitMinutes;
  double get passingScorePercentage => _passingScorePercentage;

  List<ExamQuestion> get questions => _questions;
  List<StudentAttempt> get studentAttempts => _studentAttempts;
  List<QuestionBankItem> get availableQuestions => _availableQuestions;

  /// Atualizar título
  void updateTitle(String value) {
    _title = value;
    notifyListeners();
  }

  /// Atualizar descrição
  void updateDescription(String value) {
    _description = value;
    notifyListeners();
  }

  /// Atualizar curso
  void updateCourse(String? value) {
    _courseId = value;
    notifyListeners();
  }

  /// Atualizar configurações
  void updateShowWrongQuestions(bool value) {
    _showWrongQuestions = value;
    notifyListeners();
  }

  void updateShowCorrectAnswers(bool value) {
    _showCorrectAnswers = value;
    notifyListeners();
  }

  void updateShowScores(bool value) {
    _showScores = value;
    notifyListeners();
  }

  void updateRequireInstitutionalLogin(bool value) {
    _requireInstitutionalLogin = value;
    notifyListeners();
  }

  void updateSingleAttemptOnly(bool value) {
    _singleAttemptOnly = value;
    notifyListeners();
  }

  void updateUseDefaultQuestionScore(bool value) {
    _useDefaultQuestionScore = value;
    notifyListeners();
  }

  /// Carregar questões disponíveis do banco
  Future<void> loadAvailableQuestions({String? courseIdFilter}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final teacherId = _supabase.auth.currentUser?.id;
      if (teacherId == null) {
        throw Exception('Usuário não autenticado');
      }

      dynamic query = _supabase.from('question').select('''
            id,
            enunciation,
            difficulty_level,
            points,
            id_course,
            id_category,
            id_teacher,
            course:course(name),
            question_category:question_category(name),
            user:user(name)
          ''').eq('is_active', true);

      if (courseIdFilter != null) {
        query = query.eq('id_course', courseIdFilter);
      }

      final response = await query;

      _availableQuestions = (response as List).map((json) {
        return QuestionBankItem(
          id: json['id'] as String,
          enunciation: json['enunciation'] as String? ?? '',
          content: json['question_category']?['name'] as String? ?? '',
          subject: json['course']?['name'] as String? ?? '',
          professor: json['user']?['name'] as String? ?? 'Desconhecido',
          difficultyLevel: json['difficulty_level'] as String? ?? '',
          points: (json['points'] as num?)?.toDouble() ?? 1.0,
        );
      }).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erro ao carregar questões: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Importar questões selecionadas
  void importQuestions(List<String> selectedIds) {
    final questionsToImport =
        _availableQuestions.where((q) => selectedIds.contains(q.id)).toList();

    for (var item in questionsToImport) {
      final newQuestion = ExamQuestion(
        id: 'temp_${DateTime.now().millisecondsSinceEpoch}_${item.id}',
        questionId: item.id,
        enunciation: item.enunciation,
        options: [],
        order: _questions.length,
        score: item.points,
      );
      _questions.add(newQuestion);
    }

    notifyListeners();
  }

  /// Adicionar questão manualmente
  void addQuestion(ExamQuestion question) {
    _questions.add(question);
    notifyListeners();
  }

  /// Deletar questão
  void deleteQuestion(String questionId) {
    _questions.removeWhere((q) => q.id == questionId);
    // Reordenar
    for (int i = 0; i < _questions.length; i++) {
      _questions[i] = _questions[i].copyWith(order: i);
    }
    notifyListeners();
  }

  /// Duplicar questão
  void duplicateQuestion(String questionId) {
    final index = _questions.indexWhere((q) => q.id == questionId);
    if (index != -1) {
      final original = _questions[index];
      final duplicated = ExamQuestion(
        id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
        questionId: original.questionId,
        enunciation: original.enunciation,
        options: List.from(original.options),
        order: index + 1,
        score: original.score,
      );
      _questions.insert(index + 1, duplicated);

      // Reordenar
      for (int i = 0; i < _questions.length; i++) {
        _questions[i] = _questions[i].copyWith(order: i);
      }
      notifyListeners();
    }
  }

  /// Mover questão para cima
  void moveQuestionUp(String questionId) {
    final index = _questions.indexWhere((q) => q.id == questionId);
    if (index > 0) {
      final temp = _questions[index];
      _questions[index] = _questions[index - 1].copyWith(order: index);
      _questions[index - 1] = temp.copyWith(order: index - 1);
      notifyListeners();
    }
  }

  /// Mover questão para baixo
  void moveQuestionDown(String questionId) {
    final index = _questions.indexWhere((q) => q.id == questionId);
    if (index < _questions.length - 1) {
      final temp = _questions[index];
      _questions[index] = _questions[index + 1].copyWith(order: index);
      _questions[index + 1] = temp.copyWith(order: index + 1);
      notifyListeners();
    }
  }

  /// Atualizar enunciado de questão
  void updateQuestionEnunciation(String questionId, String enunciation) {
    final index = _questions.indexWhere((q) => q.id == questionId);
    if (index != -1) {
      _questions[index] = _questions[index].copyWith(enunciation: enunciation);
      notifyListeners();
    }
  }

  /// Atualizar pontuação de questão
  void updateQuestionScore(String questionId, double? score) {
    final index = _questions.indexWhere((q) => q.id == questionId);
    if (index != -1) {
      _questions[index] = _questions[index].copyWith(score: score);
      notifyListeners();
    }
  }

  /// Salvar template de prova
  Future<bool> saveTemplate() async {
    if (_title.isEmpty) {
      _errorMessage = 'O título da prova é obrigatório';
      notifyListeners();
      return false;
    }

    if (_courseId == null) {
      _errorMessage = 'Selecione um curso para a prova';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final teacherId = _supabase.auth.currentUser?.id;
      if (teacherId == null) {
        throw Exception('Usuário não autenticado');
      }

      // Salvar ou atualizar template
      if (_templateId == null) {
        // Criar novo template
        final response = await _supabase
            .from('exam_template')
            .insert({
              'name': _title,
              'description': _description,
              'id_course': _courseId,
              'id_teacher': teacherId,
              'time_limit_minutes': _timeLimitMinutes,
              'passing_score_percentage': _passingScorePercentage,
              'show_correct_answers': _showCorrectAnswers,
              'allow_review': _showWrongQuestions,
              'max_attempts': _singleAttemptOnly ? 1 : null,
              'is_published': false,
              'is_active': true,
            })
            .select()
            .single();

        _templateId = response['id'] as String;
      } else {
        // Atualizar template existente
        await _supabase.from('exam_template').update({
          'name': _title,
          'description': _description,
          'time_limit_minutes': _timeLimitMinutes,
          'passing_score_percentage': _passingScorePercentage,
          'show_correct_answers': _showCorrectAnswers,
          'allow_review': _showWrongQuestions,
          'max_attempts': _singleAttemptOnly ? 1 : null,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', _templateId!);
      }

      // Salvar questões do template
      if (_questions.isNotEmpty) {
        // Remover questões antigas
        await _supabase
            .from('exam_template_question')
            .delete()
            .eq('id_exam_template', _templateId!);

        // Inserir novas questões
        final questionsData = _questions.map((q) {
          return {
            'id_exam_template': _templateId,
            'id_question': q.questionId,
            'question_order': q.order,
            'points_override': q.score,
          };
        }).toList();

        await _supabase.from('exam_template_question').insert(questionsData);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Erro ao salvar prova: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Carregar tentativas dos alunos
  Future<void> loadStudentAttempts() async {
    if (_templateId == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _supabase
          .from('user_exam_attempts')
          .select('''
            id,
            user_id,
            completed_at,
            duration_seconds,
            total_score,
            percentage_score,
            question_count,
            user:user(name, email)
          ''')
          .eq('exam_id', _templateId!)
          .eq('status', 'completed')
          .order('completed_at', ascending: false);

      _studentAttempts = (response as List).map((json) {
        final duration = json['duration_seconds'] as int? ?? 0;
        final minutes = duration ~/ 60;
        final seconds = duration % 60;

        return StudentAttempt(
          id: json['id'] as String,
          studentName: json['user']?['name'] as String? ?? 'Desconhecido',
          studentEmail: json['user']?['email'] as String? ?? '',
          completedAt: DateTime.parse(json['completed_at'] as String),
          questionsAnswered: json['question_count'] as int? ?? 0,
          totalQuestions: json['question_count'] as int? ?? 0,
          durationMinutes: minutes,
          durationSeconds: seconds,
          score: (json['percentage_score'] as num? ?? 0).round(),
          totalScore: 100,
          points: (json['total_score'] as num?)?.toDouble() ?? 0.0,
        );
      }).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erro ao carregar respostas: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Limpar dados
  void clear() {
    _templateId = null;
    _title = '';
    _description = '';
    _courseId = null;
    _questions.clear();
    _studentAttempts.clear();
    _availableQuestions.clear();
    _errorMessage = null;
    notifyListeners();
  }
}

/// Modelo de questão no exame
class ExamQuestion {
  final String id;
  final String? questionId;
  final String enunciation;
  final List<String> options;
  final int order;
  final double? score;

  ExamQuestion({
    required this.id,
    this.questionId,
    required this.enunciation,
    required this.options,
    required this.order,
    this.score,
  });

  ExamQuestion copyWith({
    String? id,
    String? questionId,
    String? enunciation,
    List<String>? options,
    int? order,
    double? score,
  }) {
    return ExamQuestion(
      id: id ?? this.id,
      questionId: questionId ?? this.questionId,
      enunciation: enunciation ?? this.enunciation,
      options: options ?? this.options,
      order: order ?? this.order,
      score: score ?? this.score,
    );
  }
}

/// Modelo de questão do banco
class QuestionBankItem {
  final String id;
  final String enunciation;
  final String content;
  final String subject;
  final String professor;
  final String difficultyLevel;
  final double points;

  QuestionBankItem({
    required this.id,
    required this.enunciation,
    required this.content,
    required this.subject,
    required this.professor,
    required this.difficultyLevel,
    required this.points,
  });

  Map<String, String> get tagMap => {
        'Conteúdo': content,
        'Matéria': subject,
        'Professor': professor,
        'Dificuldade': difficultyLevel,
      };
}

/// Modelo de tentativa do aluno
class StudentAttempt {
  final String id;
  final String studentName;
  final String studentEmail;
  final DateTime completedAt;
  final int questionsAnswered;
  final int totalQuestions;
  final int durationMinutes;
  final int durationSeconds;
  final int score;
  final int totalScore;
  final double points;

  StudentAttempt({
    required this.id,
    required this.studentName,
    required this.studentEmail,
    required this.completedAt,
    required this.questionsAnswered,
    required this.totalQuestions,
    required this.durationMinutes,
    required this.durationSeconds,
    required this.score,
    required this.totalScore,
    required this.points,
  });
}
