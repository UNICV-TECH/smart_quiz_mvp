import 'package:flutter/material.dart';

import '../../models/course.dart';
import '../../models/exam_template.dart';
import '../../models/exam_template_question.dart';
import '../../models/teacher_question.dart';
import '../../repositories/course_repository.dart';
import '../../repositories/course_repository_types.dart' as course_repo;
import '../../repositories/teacher_repository.dart';
import '../../repositories/teacher_repository_types.dart';

class ExamTemplateViewModel extends ChangeNotifier {
  ExamTemplateViewModel({
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
  List<ExamTemplate> _templates = [];
  List<Course> _courses = [];
  ExamTemplate? _selectedTemplate;
  List<ExamTemplateQuestion> _templateQuestions = [];
  List<TeacherQuestion> _availableQuestions = [];

  // Form fields for creating/editing template
  String _templateName = '';
  String? _templateDescription;
  String? _selectedCourseId;
  int? _timeLimitMinutes;
  int _questionCount = 10;
  double _passingScorePercentage = 60.0;
  bool _shuffleQuestions = true;
  bool _shuffleChoices = true;
  bool _showCorrectAnswers = true;
  bool _allowReview = true;
  int? _maxAttempts = 1;

  // Getters
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  List<ExamTemplate> get templates => List.unmodifiable(_templates);
  List<Course> get courses => List.unmodifiable(_courses);
  ExamTemplate? get selectedTemplate => _selectedTemplate;
  List<ExamTemplateQuestion> get templateQuestions =>
      List.unmodifiable(_templateQuestions);
  List<TeacherQuestion> get availableQuestions =>
      List.unmodifiable(_availableQuestions);

  // Form field getters
  String get templateName => _templateName;
  String? get templateDescription => _templateDescription;
  String? get selectedCourseId => _selectedCourseId;
  int? get timeLimitMinutes => _timeLimitMinutes;
  int get questionCount => _questionCount;
  double get passingScorePercentage => _passingScorePercentage;
  bool get shuffleQuestions => _shuffleQuestions;
  bool get shuffleChoices => _shuffleChoices;
  bool get showCorrectAnswers => _showCorrectAnswers;
  bool get allowReview => _allowReview;
  int? get maxAttempts => _maxAttempts;

  int get publishedCount => _templates.where((t) => t.isPublished).length;
  int get draftCount => _templates.where((t) => !t.isPublished).length;

  bool get isFormValid {
    return _templateName.trim().isNotEmpty && _selectedCourseId != null;
  }

  // Load data
  Future<void> loadInitialData() async {
    _setLoading(true);
    _clearMessages();

    try {
      await Future.wait([
        _loadCourses(),
        loadTemplates(),
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

  Future<void> loadTemplates() async {
    try {
      _templates =
          await _teacherRepository.fetchTemplates(teacherId: _teacherId);
      notifyListeners();
    } catch (error) {
      _setError('Erro ao carregar templates: $error');
    }
  }

  Future<void> selectTemplate(String templateId) async {
    _setLoading(true);

    try {
      _selectedTemplate = await _teacherRepository.fetchTemplate(templateId);
      _templateQuestions =
          await _teacherRepository.fetchTemplateQuestions(templateId);
      _populateFormFromTemplate(_selectedTemplate!);
      notifyListeners();
    } catch (error) {
      _setError('Erro ao carregar template: $error');
    } finally {
      _setLoading(false);
    }
  }

  void clearSelection() {
    _selectedTemplate = null;
    _templateQuestions = [];
    _resetForm();
    notifyListeners();
  }

  Future<void> loadAvailableQuestions() async {
    if (_selectedCourseId == null) {
      _availableQuestions = [];
      notifyListeners();
      return;
    }

    try {
      final filter = TeacherQuestionsFilter(
        teacherId: _teacherId,
        courseId: _selectedCourseId,
        activeOnly: true,
      );
      _availableQuestions =
          await _teacherRepository.fetchTeacherQuestions(filter);
      notifyListeners();
    } catch (error) {
      debugPrint('Erro ao carregar questoes disponiveis: $error');
    }
  }

  // Form setters
  void setTemplateName(String value) {
    _templateName = value;
    notifyListeners();
  }

  void setTemplateDescription(String? value) {
    _templateDescription = value;
    notifyListeners();
  }

  void setCourse(String? courseId) {
    if (_selectedCourseId == courseId) return;
    _selectedCourseId = courseId;
    _availableQuestions = [];
    notifyListeners();

    if (courseId != null) {
      loadAvailableQuestions();
    }
  }

  void setTimeLimitMinutes(int? value) {
    _timeLimitMinutes = value;
    notifyListeners();
  }

  void setQuestionCount(int value) {
    _questionCount = value;
    notifyListeners();
  }

  void setPassingScorePercentage(double value) {
    _passingScorePercentage = value;
    notifyListeners();
  }

  void setShuffleQuestions(bool value) {
    _shuffleQuestions = value;
    notifyListeners();
  }

  void setShuffleChoices(bool value) {
    _shuffleChoices = value;
    notifyListeners();
  }

  void setShowCorrectAnswers(bool value) {
    _showCorrectAnswers = value;
    notifyListeners();
  }

  void setAllowReview(bool value) {
    _allowReview = value;
    notifyListeners();
  }

  void setMaxAttempts(int? value) {
    _maxAttempts = value;
    notifyListeners();
  }

  // CRUD operations
  Future<bool> saveTemplate() async {
    if (!isFormValid) {
      _setError('Preencha todos os campos obrigatorios');
      return false;
    }

    _setSaving(true);
    _clearMessages();

    try {
      final now = DateTime.now();

      final template = ExamTemplate(
        id: _selectedTemplate?.id ?? '',
        name: _templateName.trim(),
        description: _templateDescription?.trim(),
        courseId: _selectedCourseId!,
        teacherId: _teacherId,
        timeLimitMinutes: _timeLimitMinutes,
        questionCount: _questionCount,
        passingScorePercentage: _passingScorePercentage,
        shuffleQuestions: _shuffleQuestions,
        shuffleChoices: _shuffleChoices,
        showCorrectAnswers: _showCorrectAnswers,
        allowReview: _allowReview,
        maxAttempts: _maxAttempts,
        isPublished: _selectedTemplate?.isPublished ?? false,
        createdAt: _selectedTemplate?.createdAt ?? now,
        updatedAt: now,
      );

      if (_selectedTemplate == null) {
        final created = await _teacherRepository.createTemplate(template);
        _templates = [created, ..._templates];
        _selectedTemplate = created;
      } else {
        await _teacherRepository.updateTemplate(template);
        _templates = _templates.map((t) {
          return t.id == template.id ? template : t;
        }).toList();
        _selectedTemplate = template;
      }

      _setSuccess(_selectedTemplate == null
          ? 'Template criado com sucesso!'
          : 'Template atualizado com sucesso!');
      return true;
    } catch (error) {
      _setError('Erro ao salvar template: $error');
      return false;
    } finally {
      _setSaving(false);
    }
  }

  Future<bool> deleteTemplate(String templateId) async {
    try {
      await _teacherRepository.deleteTemplate(templateId);
      _templates = _templates.where((t) => t.id != templateId).toList();
      if (_selectedTemplate?.id == templateId) {
        _selectedTemplate = null;
        _templateQuestions = [];
        _resetForm();
      }
      _setSuccess('Template removido com sucesso!');
      notifyListeners();
      return true;
    } catch (error) {
      _setError('Erro ao remover template: $error');
      return false;
    }
  }

  Future<bool> publishTemplate(String templateId) async {
    try {
      await _teacherRepository.publishTemplate(templateId);
      _templates = _templates.map((t) {
        return t.id == templateId ? t.copyWith(isPublished: true) : t;
      }).toList();

      if (_selectedTemplate?.id == templateId) {
        _selectedTemplate = _selectedTemplate!.copyWith(isPublished: true);
      }

      _setSuccess('Template publicado com sucesso!');
      notifyListeners();
      return true;
    } catch (error) {
      _setError('Erro ao publicar template: $error');
      return false;
    }
  }

  Future<bool> unpublishTemplate(String templateId) async {
    try {
      await _teacherRepository.unpublishTemplate(templateId);
      _templates = _templates.map((t) {
        return t.id == templateId ? t.copyWith(isPublished: false) : t;
      }).toList();

      if (_selectedTemplate?.id == templateId) {
        _selectedTemplate = _selectedTemplate!.copyWith(isPublished: false);
      }

      _setSuccess('Template despublicado com sucesso!');
      notifyListeners();
      return true;
    } catch (error) {
      _setError('Erro ao despublicar template: $error');
      return false;
    }
  }

  // Template questions management
  Future<bool> addQuestionToTemplate(String questionId) async {
    if (_selectedTemplate == null) return false;

    try {
      final order = _templateQuestions.length + 1;
      final templateQuestion = ExamTemplateQuestion(
        id: '',
        examTemplateId: _selectedTemplate!.id,
        questionId: questionId,
        questionOrder: order,
        createdAt: DateTime.now(),
      );

      final created =
          await _teacherRepository.addQuestionToTemplate(templateQuestion);
      _templateQuestions = [..._templateQuestions, created];

      notifyListeners();
      return true;
    } catch (error) {
      _setError('Erro ao adicionar questao: $error');
      return false;
    }
  }

  Future<bool> removeQuestionFromTemplate(String templateQuestionId) async {
    try {
      await _teacherRepository.removeQuestionFromTemplate(templateQuestionId);
      _templateQuestions =
          _templateQuestions.where((q) => q.id != templateQuestionId).toList();
      notifyListeners();
      return true;
    } catch (error) {
      _setError('Erro ao remover questao: $error');
      return false;
    }
  }

  void reorderQuestions(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final item = _templateQuestions.removeAt(oldIndex);
    _templateQuestions.insert(newIndex, item);

    // Update order numbers
    _templateQuestions = _templateQuestions.asMap().entries.map((entry) {
      return entry.value.copyWith(questionOrder: entry.key + 1);
    }).toList();

    notifyListeners();

    // Persist order changes
    _persistQuestionOrder();
  }

  Future<void> _persistQuestionOrder() async {
    try {
      for (final question in _templateQuestions) {
        await _teacherRepository.updateTemplateQuestionOrder(
          question.id,
          question.questionOrder,
        );
      }
    } catch (error) {
      debugPrint('Erro ao persistir ordem: $error');
    }
  }

  // Helper methods
  void _populateFormFromTemplate(ExamTemplate template) {
    _templateName = template.name;
    _templateDescription = template.description;
    _selectedCourseId = template.courseId;
    _timeLimitMinutes = template.timeLimitMinutes;
    _questionCount = template.questionCount;
    _passingScorePercentage = template.passingScorePercentage;
    _shuffleQuestions = template.shuffleQuestions;
    _shuffleChoices = template.shuffleChoices;
    _showCorrectAnswers = template.showCorrectAnswers;
    _allowReview = template.allowReview;
    _maxAttempts = template.maxAttempts;
  }

  void _resetForm() {
    _templateName = '';
    _templateDescription = null;
    _selectedCourseId = null;
    _timeLimitMinutes = null;
    _questionCount = 10;
    _passingScorePercentage = 60.0;
    _shuffleQuestions = true;
    _shuffleChoices = true;
    _showCorrectAnswers = true;
    _allowReview = true;
    _maxAttempts = 1;
    _availableQuestions = [];
  }

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
    _errorMessage = null;
    _successMessage = null;
  }

  void clearMessages() {
    _clearMessages();
    notifyListeners();
  }

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
