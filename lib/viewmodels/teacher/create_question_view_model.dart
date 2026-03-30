import 'package:flutter/material.dart';

import '../../models/course.dart';
import '../../models/question_category.dart';
import '../../models/subject.dart';
import '../../repositories/course_repository.dart';
import '../../repositories/course_repository_types.dart' as course_repo;
import '../../repositories/teacher_repository.dart';
import '../../repositories/teacher_repository_types.dart';

class CreateQuestionViewModel extends ChangeNotifier {
  CreateQuestionViewModel({
    required String teacherId,
    required TeacherRepository teacherRepository,
    required CourseRepository courseRepository,
  })  : _teacherId = teacherId,
        _teacherRepository = teacherRepository,
        _courseRepository = courseRepository;

  final String _teacherId;
  final TeacherRepository _teacherRepository;
  final CourseRepository _courseRepository;

  // State
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;
  String? _successMessage;

  // Data
  List<Course> _courses = [];
  List<Subject> _subjects = [];
  List<QuestionCategory> _categories = [];

  // Selected values
  String? _selectedCourseId;
  String? _selectedSubjectId;
  String? _selectedCategoryId;

  // Form fields
  String _enunciation = '';
  String _difficultyLevel = 'medium';
  double _points = 1.0;
  List<SupportingTextInput> _supportingTexts = [];
  List<AnswerChoiceInput> _answerChoices = [
    const AnswerChoiceInput(letter: 'A', content: '', isCorrect: false),
    const AnswerChoiceInput(letter: 'B', content: '', isCorrect: false),
    const AnswerChoiceInput(letter: 'C', content: '', isCorrect: false),
    const AnswerChoiceInput(letter: 'D', content: '', isCorrect: false),
    const AnswerChoiceInput(letter: 'E', content: '', isCorrect: false),
  ];

  // Getters
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  List<Course> get courses => List.unmodifiable(_courses);
  List<Subject> get subjects => List.unmodifiable(_subjects);
  List<QuestionCategory> get categories => List.unmodifiable(_categories);

  String? get selectedCourseId => _selectedCourseId;
  String? get selectedSubjectId => _selectedSubjectId;
  String? get selectedCategoryId => _selectedCategoryId;

  String get enunciation => _enunciation;
  String get difficultyLevel => _difficultyLevel;
  double get points => _points;
  List<SupportingTextInput> get supportingTexts =>
      List.unmodifiable(_supportingTexts);
  List<AnswerChoiceInput> get answerChoices =>
      List.unmodifiable(_answerChoices);

  Course? get selectedCourse {
    if (_selectedCourseId == null) return null;
    try {
      return _courses.firstWhere((c) => c.id == _selectedCourseId);
    } catch (_) {
      return null;
    }
  }

  QuestionCategory? get selectedCategory {
    if (_selectedCategoryId == null) return null;
    try {
      return _categories.firstWhere((c) => c.id == _selectedCategoryId);
    } catch (_) {
      return null;
    }
  }

  bool get hasCorrectAnswer =>
      _answerChoices.any((choice) => choice.isCorrect);

  bool get isFormValid {
    return _selectedCourseId != null &&
        _difficultyLevel.trim().isNotEmpty &&
        _points > 0 &&
        _enunciation.trim().isNotEmpty &&
        _answerChoices.where((c) => c.content.trim().isNotEmpty).length >= 2 &&
        hasCorrectAnswer;
  }

  // Load data
  Future<void> loadInitialData() async {
    _setLoading(true);
    _clearMessages();

    try {
      await Future.wait([
        _loadCourses(),
      ]);
    } catch (error) {
      _setError('Erro ao carregar dados: $error');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadCourses() async {
    final repoCourses = await _courseRepository.fetchActiveCourses();
    _courses = repoCourses.map(_mapRepoCourse).toList();
  }

  Future<void> loadSubjects(String courseId) async {
    _subjects = [];
    notifyListeners();

    try {
      _subjects =
          await _teacherRepository.fetchSubjects(courseId: courseId);
      notifyListeners();
    } catch (error) {
      debugPrint('Erro ao carregar matérias: $error');
      _subjects = [];
      notifyListeners();
    }
  }

  Future<void> loadCategories({String? courseId, String? subjectId}) async {
    _categories = [];
    notifyListeners();

    try {
      _categories =
          await _teacherRepository.fetchCategories(courseId: courseId, subjectId: subjectId);
      notifyListeners();
    } catch (error) {
      debugPrint('Erro ao carregar categorias: $error');
      _categories = [];
      notifyListeners();
    }
  }

  // Setters
  void setCourse(String? courseId) {
    if (_selectedCourseId == courseId) return;
    _selectedCourseId = courseId;
    _selectedSubjectId = null;
    _selectedCategoryId = null;
    _subjects = [];
    _categories = [];
    _clearMessages();
    notifyListeners();

    if (courseId != null) {
      loadSubjects(courseId);
    }
  }

  void setSubject(String? subjectId) {
    if (_selectedSubjectId == subjectId) return;
    _selectedSubjectId = subjectId;
    _selectedCategoryId = null;
    _categories = [];
    _clearMessages();
    notifyListeners();

    if (subjectId != null) {
      loadCategories(subjectId: subjectId);
    }
  }

  void setCategory(String? categoryId) {
    if (_selectedCategoryId == categoryId) return;
    _selectedCategoryId = categoryId;
    _clearMessages();
    notifyListeners();
  }

  void setEnunciation(String value) {
    _enunciation = value;
    notifyListeners();
  }

  void setDifficultyLevel(String value) {
    _difficultyLevel = value;
    notifyListeners();
  }

  void setPoints(double value) {
    _points = value;
    notifyListeners();
  }

  void addSupportingText(SupportingTextInput text) {
    _supportingTexts = [..._supportingTexts, text];
    notifyListeners();
  }

  void removeSupportingText(int index) {
    if (index < 0 || index >= _supportingTexts.length) return;
    _supportingTexts = [
      ..._supportingTexts.sublist(0, index),
      ..._supportingTexts.sublist(index + 1),
    ];
    notifyListeners();
  }

  void updateSupportingText(int index, SupportingTextInput text) {
    if (index < 0 || index >= _supportingTexts.length) return;
    _supportingTexts = [
      ..._supportingTexts.sublist(0, index),
      text,
      ..._supportingTexts.sublist(index + 1),
    ];
    notifyListeners();
  }

  void updateAnswerChoice(int index, AnswerChoiceInput choice) {
    if (index < 0 || index >= _answerChoices.length) return;
    _answerChoices = [
      ..._answerChoices.sublist(0, index),
      choice,
      ..._answerChoices.sublist(index + 1),
    ];
    notifyListeners();
  }

  void setCorrectAnswer(int index) {
    _answerChoices = _answerChoices.asMap().entries.map((entry) {
      final current = entry.value;
      return AnswerChoiceInput(
        letter: current.letter,
        content: current.content,
        isCorrect: entry.key == index,
      );
    }).toList();
    notifyListeners();
  }

  // Validation
  String? validate() {
    if (_selectedCourseId == null) {
      return 'Selecione um curso';
    }
    if (_difficultyLevel.trim().isEmpty) {
      return 'Selecione a dificuldade';
    }
    if (_points <= 0) {
      return 'Selecione os pontos';
    }
    if (_enunciation.trim().isEmpty) {
      return 'Digite o enunciado da questão';
    }
    final filledChoices =
        _answerChoices.where((c) => c.content.trim().isNotEmpty).length;
    if (filledChoices < 2) {
      return 'Preencha pelo menos 2 alternativas';
    }
    if (!hasCorrectAnswer) {
      return 'Selecione a alternativa correta';
    }
    return null;
  }

  // Save
  Future<bool> saveQuestion() async {
    final validationError = validate();
    if (validationError != null) {
      _setError(validationError);
      return false;
    }

    _setSaving(true);
    _clearMessages();

    try {
      final filteredChoices = _answerChoices
          .where((c) => c.content.trim().isNotEmpty)
          .toList();

      final request = CreateQuestionRequest(
        teacherId: _teacherId,
        courseId: _selectedCourseId!,
        subjectId: _selectedSubjectId,
        categoryId: _selectedCategoryId,
        enunciation: _enunciation.trim(),
        difficultyLevel: _difficultyLevel,
        points: _points,
        supportingTexts: _supportingTexts,
        answerChoices: filteredChoices,
      );

      await _teacherRepository.createQuestion(request);

      _setSuccess('Questão criada com sucesso!');
      _resetForm();
      return true;
    } catch (error) {
      _setError('Erro ao salvar questão: $error');
      return false;
    } finally {
      _setSaving(false);
    }
  }

  void _resetForm() {
    _selectedSubjectId = null;
    _selectedCategoryId = null;
    _enunciation = '';
    _difficultyLevel = 'medium';
    _points = 1.0;
    _supportingTexts = [];
    _answerChoices = [
      const AnswerChoiceInput(letter: 'A', content: '', isCorrect: false),
      const AnswerChoiceInput(letter: 'B', content: '', isCorrect: false),
      const AnswerChoiceInput(letter: 'C', content: '', isCorrect: false),
      const AnswerChoiceInput(letter: 'D', content: '', isCorrect: false),
      const AnswerChoiceInput(letter: 'E', content: '', isCorrect: false),
    ];
    notifyListeners();
  }

  // Helper methods
  void _setLoading(bool value) {
    if (_isLoading == value) return;
    _isLoading = value;
    notifyListeners();
  }

  void _setSaving(bool value) {
    if (_isSaving == value) return;
    _isSaving = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _successMessage = null;
    notifyListeners();
  }

  void _setSuccess(String message) {
    _successMessage = message;
    _errorMessage = null;
    notifyListeners();
  }

  void _clearMessages() {
    if (_errorMessage == null && _successMessage == null) return;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  void clearMessages() => _clearMessages();

  Course _mapRepoCourse(course_repo.Course repo) {
    return Course(
      id: repo.id,
      courseKey: repo.courseKey,
      title: repo.title,
      description: repo.description.isNotEmpty ? repo.description : null,
      iconKey: repo.iconKey,
      createdAt: repo.createdAt,
    );
  }
}
