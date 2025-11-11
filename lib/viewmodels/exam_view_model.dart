import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unicv_tech_mvp/models/exam_history.dart';

class ExamViewModel extends ChangeNotifier {
  ExamViewModel({
    SupabaseClient? supabase,
    required this.userId,
    required this.examId,
    required this.courseId,
    required this.questionCount,
    ExamRemoteDataSource? dataSource,
    this.isRetake = false, // Flag para indicar se é uma retomada
    this.previousQuestionIds, // IDs das questões da prova anterior (para retake)
  })  : assert(
          supabase != null || dataSource != null,
          'Provide either a SupabaseClient or an ExamRemoteDataSource',
        ),
        _dataSource = dataSource ?? SupabaseExamDataSource(supabase!);

  final ExamRemoteDataSource _dataSource;
  final String userId;
  final String examId;
  final String courseId;
  final int questionCount;
  final bool isRetake; // Flag para indicar se é uma retomada
  final List<String>? previousQuestionIds; // IDs das questões da prova anterior

  List<ExamQuestion> _examQuestions = [];
  final Map<String, String> _selectedAnswers = {};
  bool _loading = false;
  String? _error;
  String? _attemptId;
  DateTime? _startedAt;

  List<ExamQuestion> get examQuestions => _examQuestions;
  Map<String, String> get selectedAnswers => _selectedAnswers;
  bool get loading => _loading;
  String? get error => _error;
  String? get attemptId => _attemptId;

  Future<void> initialize() async {
    _setLoading(true);
    try {
      // Se não for retake, criar nova tentativa; caso contrário, apenas carregar questões
      if (!isRetake) {
        debugPrint('Inicializando prova normal - criando nova tentativa');
        await _createAttempt();
      } else {
        // Para retake, resetar o estado mas não criar nova tentativa
        debugPrint(
            'Inicializando prova REFEITA (isRetake=true) - NÃO criando nova tentativa');
        _selectedAnswers.clear();
        _startedAt = DateTime.now();
        _attemptId = null; // Garantir que não há tentativa anterior
      }
      await _loadQuestions();
      _error = null;
    } catch (err, stack) {
      _error = err.toString();
      debugPrint('Failed to initialize exam: $err');
      debugPrintStack(stackTrace: stack);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _createAttempt() async {
    // Preservar o _startedAt se já existir (para retake), senão criar novo
    final startTime = _startedAt ?? DateTime.now();
    debugPrint('Criando nova tentativa para examId: $examId, userId: $userId');
    debugPrint('StartedAt: $startTime');
    _attemptId = await _dataSource.createAttempt(
      userId: userId,
      examId: examId,
      courseId: courseId,
      questionCount: questionCount,
      startedAt: startTime,
    );
    // Só atualizar _startedAt se ainda não estava setado
    _startedAt ??= startTime;
    debugPrint('Nova tentativa criada: $_attemptId');
  }

  Future<void> _loadQuestions() async {
    List<Map<String, dynamic>> questionsData;

    // Se for retake e tiver questionIds anteriores, usar essas questões específicas
    if (isRetake &&
        previousQuestionIds != null &&
        previousQuestionIds!.isNotEmpty) {
      debugPrint('Retake: Carregando as mesmas questões da prova anterior');
      debugPrint('Question IDs: ${previousQuestionIds!.join(", ")}');

      // Buscar apenas as questões específicas que foram usadas anteriormente
      final allQuestionsData =
          await _dataSource.fetchQuestions(examId: examId, courseId: courseId);

      // Filtrar apenas as questões que foram usadas antes
      questionsData = allQuestionsData
          .where((q) => previousQuestionIds!.contains(q['id'] as String))
          .toList();

      // Manter a ordem original das questões
      final questionOrderMap = <String, int>{};
      for (var i = 0; i < previousQuestionIds!.length; i++) {
        questionOrderMap[previousQuestionIds![i]] = i;
      }
      questionsData.sort((a, b) {
        final orderA = questionOrderMap[a['id'] as String] ?? 999;
        final orderB = questionOrderMap[b['id'] as String] ?? 999;
        return orderA.compareTo(orderB);
      });
    } else {
      // Comportamento normal: buscar todas as questões e embaralhar
      final List<Map<String, dynamic>> allQuestionsData =
          await _dataSource.fetchQuestions(examId: examId, courseId: courseId);

      // Only shuffle when we actually need to sample a subset; otherwise keep the
      // original order so deterministic tests don't become flaky.
      if (allQuestionsData.length > questionCount) {
        allQuestionsData.shuffle();
      }
      questionsData = allQuestionsData.take(questionCount).toList();
    }

    final questionIds = questionsData.map((q) => q['id'] as String).toList();

    final List<Map<String, dynamic>> answerChoicesData =
        await _dataSource.fetchAnswerChoices(questionIds);
    final List<Map<String, dynamic>> supportingTextsData =
        await _dataSource.fetchSupportingTexts(questionIds);

    final Map<String, List<AnswerChoice>> answerChoicesByQuestion = {};
    for (final ac in answerChoicesData) {
      final answerChoice = AnswerChoice.fromJson(ac);
      answerChoicesByQuestion
          .putIfAbsent(answerChoice.questionId, () => [])
          .add(answerChoice);
    }

    final Map<String, List<SupportingText>> supportingTextsByQuestion = {};
    for (final st in supportingTextsData) {
      final supportingText = SupportingText.fromJson(st);
      supportingTextsByQuestion
          .putIfAbsent(supportingText.questionId, () => [])
          .add(supportingText);
    }

    _examQuestions = questionsData.map((q) {
      final question = Question.fromJson(q);
      return ExamQuestion(
        question: question,
        answerChoices: answerChoicesByQuestion[question.id] ?? [],
        supportingTexts: supportingTextsByQuestion[question.id] ?? [],
      );
    }).toList();

    // Se não for retake, inserir os registros na tabela examquestion
    if (!isRetake) {
      await _linkQuestionsToExam(questionIds);
    }
  }

  Future<void> _linkQuestionsToExam(List<String> questionIds) async {
    try {
      debugPrint('Linking ${questionIds.length} questions to exam $examId');

      // Verificar se já existem registros para este exame
      final existingRecords = await _dataSource.checkExamQuestions(examId);

      if (existingRecords.isNotEmpty) {
        debugPrint('Exam questions already linked for exam $examId, skipping');
        return;
      }

      // Criar registros na tabela examquestion com question_order
      final examQuestionRecords = questionIds.asMap().entries.map((entry) {
        return {
          'id_exam': examId,
          'id_question': entry.value,
          'question_order': entry.key + 1, // Começar do 1, não do 0
        };
      }).toList();

      await _dataSource.insertExamQuestions(examQuestionRecords);
      debugPrint(
          'Successfully linked ${questionIds.length} questions to exam $examId');
    } catch (err, stack) {
      debugPrint('Failed to link questions to exam: $err');
      debugPrintStack(stackTrace: stack);
      // Não lançar erro para não interromper o fluxo, apenas logar
    }
  }

  void selectAnswer(String questionId, String choiceKey) {
    _selectedAnswers[questionId] = choiceKey;
    notifyListeners();
  }

  Future<Map<String, dynamic>> finalize() async {
    // Se for retake e ainda não tiver tentativa criada, criar uma agora
    if (_attemptId == null) {
      if (isRetake) {
        debugPrint('Finalizando prova REFEITA - criando nova tentativa agora');
        await _createAttempt();
      } else {
        throw Exception('No attempt ID available');
      }
    } else {
      debugPrint('Finalizando prova usando tentativa existente: $_attemptId');
    }

    _setLoading(true);
    try {
      final responses = <Map<String, dynamic>>[];
      final questionsBreakdown = <Map<String, dynamic>>[];
      int correctCount = 0;
      double totalScore = 0.0;

      for (var examQuestion in _examQuestions) {
        final questionId = examQuestion.question.id;
        final selectedChoiceKey = _selectedAnswers[questionId];

        // Log para debug das alternativas
        debugPrint('=== Processando questão $questionId ===');
        debugPrint('Enunciation: ${examQuestion.question.enunciation}');
        debugPrint('Alternativas disponíveis:');
        for (var ac in examQuestion.answerChoices) {
          debugPrint(
              '  - ${ac.choiceKey}: ${ac.choiceText} (isCorrect: ${ac.isCorrect}, id: ${ac.id})');
        }

        final selectedChoice = selectedChoiceKey != null
            ? () {
                // Normalizar a chave selecionada
                final normalizedSelected =
                    selectedChoiceKey.trim().toUpperCase();

                // Tentar encontrar por comparação normalizada
                for (final ac in examQuestion.answerChoices) {
                  final normalizedAcKey = ac.choiceKey.trim().toUpperCase();
                  if (normalizedAcKey == normalizedSelected) {
                    return ac;
                  }
                }

                // Fallback: tentar comparação exata
                for (final ac in examQuestion.answerChoices) {
                  if (ac.choiceKey == selectedChoiceKey) {
                    return ac;
                  }
                }

                // Se não encontrou, retornar null
                return null;
              }()
            : null;

        final correctChoice = examQuestion.answerChoices.firstWhere(
          (ac) => ac.isCorrect == true,
          orElse: () {
            // Log todas as alternativas para debug
            debugPrint(
                'AVISO: Nenhuma alternativa marcada como correta para questão $questionId');
            debugPrint('Alternativas disponíveis:');
            for (var ac in examQuestion.answerChoices) {
              debugPrint(
                  '  - ${ac.choiceKey}: ${ac.choiceText} (isCorrect: ${ac.isCorrect})');
            }

            // Se não encontrar nenhuma alternativa correta e houver alternativas disponíveis,
            // usar a primeira como fallback (mas isso indica um problema nos dados)
            if (examQuestion.answerChoices.isNotEmpty) {
              debugPrint(
                  'USANDO PRIMEIRA ALTERNATIVA COMO FALLBACK (dados incorretos no banco)');
              return examQuestion.answerChoices.first;
            }

            throw Exception('Question $questionId has no answer choices');
          },
        );

        // Determinar se a resposta está correta comparando diretamente com a alternativa correta
        // Primeiro tentar por ID (mais confiável)
        bool isCorrect = false;
        if (selectedChoice != null) {
          isCorrect = selectedChoice.id == correctChoice.id;
        }

        // Se não corresponder por ID ou selectedChoice for null, comparar por choiceKey normalizado
        if (!isCorrect && selectedChoiceKey != null) {
          final normalizedSelected = selectedChoiceKey.trim().toUpperCase();
          final normalizedCorrect =
              correctChoice.choiceKey.trim().toUpperCase();
          isCorrect = normalizedSelected == normalizedCorrect;
        }

        // Log para debug
        debugPrint('Question $questionId:');
        debugPrint('  Selected choiceKey: $selectedChoiceKey');
        debugPrint(
            '  Selected choice: ${selectedChoice?.choiceKey} (id: ${selectedChoice?.id})');
        debugPrint(
            '  Correct choice: ${correctChoice.choiceKey} (id: ${correctChoice.id})');
        debugPrint('  Selected isCorrect flag: ${selectedChoice?.isCorrect}');
        debugPrint('  Final isCorrect: $isCorrect');

        final pointsEarned = isCorrect ? examQuestion.question.points : 0.0;

        if (isCorrect) correctCount++;
        totalScore += pointsEarned;

        responses.add({
          'attempt_id': _attemptId,
          'exam_id': examId,
          'question_id': questionId,
          'answer_choice_id': selectedChoice?.id,
          'selected_choice_key': selectedChoiceKey,
          'is_correct': isCorrect,
          'points_earned': pointsEarned,
          'answered_at': DateTime.now().toIso8601String(),
        });

        questionsBreakdown.add({
          'questionId': questionId,
          'enunciation': examQuestion.question.enunciation.isNotEmpty
              ? examQuestion.question.enunciation
              : 'Questão sem enunciado',
          'selectedChoiceKey': selectedChoiceKey,
          'selectedChoiceText': selectedChoice?.choiceText,
          'correctChoiceKey': correctChoice.choiceKey,
          'correctChoiceText': correctChoice.choiceText,
          'isCorrect': isCorrect,
          'isAnswered': selectedChoiceKey != null,
        });
      }

      await _dataSource.insertResponses(responses);

      final percentageScore = (_examQuestions.isNotEmpty
          ? (correctCount / _examQuestions.length) * 100
          : 0.0);
      final completedAt = DateTime.now();
      final durationSeconds = _startedAt != null
          ? completedAt.difference(_startedAt!).inSeconds
          : 0;

      debugPrint('=== CALCULANDO TEMPO DA PROVA ===');
      debugPrint('StartedAt: $_startedAt');
      debugPrint('CompletedAt: $completedAt');
      debugPrint('DurationSeconds: $durationSeconds');
      debugPrint(
          'DurationFormat: ${durationSeconds ~/ 60}:${durationSeconds % 60}');

      await _dataSource.updateAttempt(
        _attemptId!,
        {
          'completed_at': completedAt.toIso8601String(),
          'duration_seconds': durationSeconds,
          'total_score': totalScore,
          'percentage_score': percentageScore,
          'status': 'completed',
        },
      );

      // Garantir que o usuário existe antes de atualizar o exame
      await _dataSource.ensureUserRecord(userId);

      // Atualizar também a tabela exam com os dados do resultado
      await _dataSource.updateExam(
        examId,
        {
          'is_completed': true,
          'id_user': userId,
          'total_score': correctCount.toDouble(), // Quantidade de acertos
          'percentage_score': percentageScore,
          'passing_score_percentage': 70.0, // Pode ser configurável no futuro
          'update_at': completedAt.toIso8601String(),
        },
      );

      debugPrint('=== ATUALIZANDO TABELA EXAM ===');
      debugPrint('ExamId: $examId');
      debugPrint('UserId: $userId');
      debugPrint('IsCompleted: true');
      debugPrint('TotalScore (acertos): $correctCount');
      debugPrint('PercentageScore: $percentageScore');
      debugPrint('PassingScorePercentage: 70.0');

      _error = null;
      return {
        'attemptId': _attemptId,
        'userId': userId,
        'examId': examId,
        'courseId': courseId,
        'questionCount': questionCount,
        'totalQuestions': _examQuestions.length,
        'correctCount': correctCount,
        'totalScore': totalScore,
        'percentageScore': percentageScore,
        'durationSeconds': durationSeconds,
        'startedAt': _startedAt?.toIso8601String(),
        'completedAt': completedAt.toIso8601String(),
        'questionsBreakdown': questionsBreakdown,
        'questionIds': _examQuestions
            .map((eq) => eq.question.id)
            .toList(), // Salvar IDs das questões usadas
      };
    } catch (err, stack) {
      _error = err.toString();
      debugPrint('Failed to finalize exam: $err');
      debugPrintStack(stackTrace: stack);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }
}

abstract class ExamRemoteDataSource {
  Future<String> createAttempt({
    required String userId,
    required String examId,
    required String courseId,
    required int questionCount,
    required DateTime startedAt,
  });

  Future<void> ensureUserRecord(String userId);

  Future<List<Map<String, dynamic>>> fetchQuestions({
    required String examId,
    required String courseId,
  });

  Future<List<Map<String, dynamic>>> fetchAnswerChoices(
    List<String> questionIds,
  );

  Future<List<Map<String, dynamic>>> fetchSupportingTexts(
    List<String> questionIds,
  );

  Future<void> insertResponses(List<Map<String, dynamic>> responses);

  Future<void> updateAttempt(
    String attemptId,
    Map<String, dynamic> updates,
  );

  Future<List<String>> checkExamQuestions(String examId);

  Future<void> insertExamQuestions(List<Map<String, dynamic>> examQuestions);

  Future<void> updateExam(String examId, Map<String, dynamic> updates);
}

class SupabaseExamDataSource implements ExamRemoteDataSource {
  SupabaseExamDataSource(SupabaseClient client) : _client = client;

  final SupabaseClient _client;

  @override
  Future<String> createAttempt({
    required String userId,
    required String examId,
    required String courseId,
    required int questionCount,
    required DateTime startedAt,
  }) async {
    await _ensureUserRecord(userId);

    final response = await _client
        .from('user_exam_attempts')
        .insert({
          'user_id': userId,
          'exam_id': examId,
          'course_id': courseId,
          'question_count': questionCount,
          'started_at': startedAt.toIso8601String(),
          'status': 'in_progress',
        })
        .select('id')
        .single();

    return response['id'] as String;
  }

  @override
  Future<List<Map<String, dynamic>>> fetchQuestions({
    required String examId,
    required String courseId,
  }) async {
    List<dynamic> response;
    try {
      response = await _client
          .from('question')
          .select(
              'id, enunciation, question_text, difficulty_level, points, is_active, created_at, updated_at')
          .eq('id_course', courseId)
          .eq('is_active', true)
          .order('created_at');
    } on PostgrestException catch (error) {
      if (error.code != '42703') {
        rethrow;
      }
      response = await _client
          .from('question')
          .select(
              'id, enunciation, question_text, difficulty_level, points, is_active, created_at, update_at')
          .eq('id_course', courseId)
          .eq('is_active', true)
          .order('created_at');
    }

    final mapped = <Map<String, dynamic>>[];
    for (var i = 0; i < response.length; i++) {
      final item = response[i] as Map<String, dynamic>;
      final normalized = Map<String, dynamic>.from(item);
      normalized['updated_at'] ??= normalized['update_at'];
      normalized.remove('update_at');
      normalized['question_text'] ??= normalized['question'];
      normalized['exam_id'] = examId;
      normalized['question_order'] ??= i;
      mapped.add(normalized);
    }
    return mapped;
  }

  @override
  Future<List<Map<String, dynamic>>> fetchAnswerChoices(
    List<String> questionIds,
  ) async {
    if (questionIds.isEmpty) return const [];

    final List<dynamic> response = await _client
        .from('answerchoice')
        .select(
            'id, idquestion, letter, content, correctanswer, created_at, upload_at')
        .inFilter('idquestion', questionIds);

    final mapped = <Map<String, dynamic>>[];
    for (final item in response) {
      final map = Map<String, dynamic>.from(item as Map<String, dynamic>);
      final letterRaw = (map['letter'] as String?)?.trim() ?? '';
      final letter = letterRaw.toUpperCase();

      // Mapear correctanswer de forma mais robusta
      final correctAnswerRaw = map['correctanswer'];
      bool isCorrect = false;
      if (correctAnswerRaw is bool) {
        isCorrect = correctAnswerRaw;
      } else if (correctAnswerRaw is String) {
        isCorrect =
            correctAnswerRaw.toLowerCase() == 'true' || correctAnswerRaw == '1';
      } else if (correctAnswerRaw is int) {
        isCorrect = correctAnswerRaw == 1;
      }

      final normalized = <String, dynamic>{
        'id': map['id'],
        'question_id': map['idquestion'],
        'choice_key': letter.isNotEmpty ? letter : letterRaw,
        'choice_text': map['content'],
        'is_correct': isCorrect,
        'choice_order': letter.isNotEmpty ? letter.codeUnitAt(0) - 64 : 0,
        'created_at': map['created_at'] ?? map['upload_at'],
      };
      mapped.add(normalized);
    }

    mapped.sort((a, b) => a['choice_order'].compareTo(b['choice_order']));
    return mapped;
  }

  @override
  Future<List<Map<String, dynamic>>> fetchSupportingTexts(
    List<String> questionIds,
  ) async {
    if (questionIds.isEmpty) return const [];

    List<dynamic> response;
    try {
      response = await _client
          .from('supportingtext')
          .select(
              'id, id_question, content_type, content, display_order, created_at')
          .inFilter('id_question', questionIds)
          .order('display_order');
    } on PostgrestException catch (error) {
      if (error.code != '42703') {
        rethrow;
      }
      response = await _client
          .from('supportingtext')
          .select(
              'id, idquestion, content_type, content, display_order, created_at')
          .inFilter('idquestion', questionIds)
          .order('display_order');
    }

    final mapped = <Map<String, dynamic>>[];
    for (final item in response) {
      final map = Map<String, dynamic>.from(item as Map<String, dynamic>);
      final questionId = map['id_question'] ?? map['idquestion'];
      mapped.add({
        'id': map['id'],
        'question_id': questionId,
        'content_type': map['content_type'],
        'content': map['content'],
        'display_order': map['display_order'] ?? 0,
        'created_at': map['created_at'],
      });
    }

    return mapped;
  }

  @override
  Future<void> insertResponses(List<Map<String, dynamic>> responses) async {
    await _client.from('user_responses').insert(responses);
  }

  @override
  Future<void> updateAttempt(
    String attemptId,
    Map<String, dynamic> updates,
  ) async {
    await _client
        .from('user_exam_attempts')
        .update(updates)
        .eq('id', attemptId);
  }

  @override
  Future<List<String>> checkExamQuestions(String examId) async {
    try {
      final response = await _client
          .from('examquestion')
          .select('id_question')
          .eq('id_exam', examId);

      return (response as List)
          .map((item) => item['id_question'] as String)
          .toList();
    } catch (e) {
      // Se a tabela não existir ou houver erro, retornar lista vazia
      debugPrint('Error checking exam questions: $e');
      return [];
    }
  }

  @override
  Future<void> insertExamQuestions(
      List<Map<String, dynamic>> examQuestions) async {
    if (examQuestions.isEmpty) return;

    await _client.from('examquestion').insert(examQuestions
        .map((eq) => {
              'id_exam': eq['id_exam'],
              'id_question': eq['id_question'],
              'question_order': eq['question_order'],
              'created_at': DateTime.now().toIso8601String(),
              'update_at': DateTime.now().toIso8601String(),
            })
        .toList());
  }

  @override
  Future<void> updateExam(String examId, Map<String, dynamic> updates) async {
    try {
      // Tentar atualizar com update_at primeiro
      await _client.from('exam').update(updates).eq('id', examId);
    } catch (e) {
      // Se falhar, tentar com updated_at
      final updatedData = Map<String, dynamic>.from(updates);
      if (updatedData.containsKey('update_at')) {
        updatedData['updated_at'] = updatedData.remove('update_at');
      }
      await _client.from('exam').update(updatedData).eq('id', examId);
    }
  }

  @override
  Future<void> ensureUserRecord(String userId) async {
    return _ensureUserRecord(userId);
  }

  Future<void> _ensureUserRecord(String userId) async {
    final existing =
        await _client.from('user').select('id').eq('id', userId).maybeSingle();

    if (existing != null) {
      return;
    }

    final authUser = _client.auth.currentUser;
    final email = authUser?.email;

    if (email == null) {
      throw Exception(
        'Impossível registrar tentativa: usuário autenticado sem e-mail disponível.',
      );
    }

    final firstName = authUser?.userMetadata?['full_name'] as String? ??
        authUser?.userMetadata?['first_name'] as String?;
    final surname = authUser?.userMetadata?['last_name'] as String?;

    await _client.from('user').upsert({
      'id': userId,
      'email': email,
      'first_name': firstName,
      'surename': surname,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
}
