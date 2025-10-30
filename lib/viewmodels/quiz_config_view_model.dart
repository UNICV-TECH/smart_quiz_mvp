import 'package:flutter/material.dart';
import '../models/course.dart';
import '../models/exam.dart';

class QuizConfigViewModel extends ChangeNotifier {
  final Course course;

  QuizConfigViewModel({required this.course});

  Exam? _exam;
  String? _selectedQuantity;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  Exam? get exam => _exam;
  String? get selectedQuantity => _selectedQuantity;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get canStartQuiz => _selectedQuantity != null && !_isLoading && _exam != null;

  final List<String> _quantityOptions = ['5', '10', '15', '20'];
  List<String> get quantityOptions => _quantityOptions;

  String get courseTitle => course.title;
  String get courseId => course.id;

  Future<void> loadExamMetadata() async {
    _setLoading(true);
    _clearFeedback();

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      _exam = Exam(
        id: 'exam_${course.courseKey}',
        courseId: course.id,
        title: 'Simulado de ${course.title}',
        description: 'Simulado completo para preparação do curso de ${course.title}',
        totalAvailableQuestions: 100,
        timeLimitMinutes: 120,
        passingScorePercentage: 70.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      _setLoading(false);
    } catch (error) {
      _setFeedback(error: 'Erro ao carregar dados do exame. Tente novamente.');
      _setLoading(false);
    }
  }

  void selectQuantity(String quantity) {
    if (_selectedQuantity == quantity) return;
    
    _selectedQuantity = quantity;
    _clearFeedback();
    notifyListeners();
  }

  void clearSelection() {
    if (_selectedQuantity == null) return;
    
    _selectedQuantity = null;
    notifyListeners();
  }

  Future<Map<String, dynamic>?> startQuiz() async {
    if (_selectedQuantity == null || _isLoading || _exam == null) {
      return null;
    }

    _setLoading(true);
    _clearFeedback();

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      final int questionCount = int.parse(_selectedQuantity!);
      
      final result = {
        'exam': _exam,
        'questionCount': questionCount,
        'course': course,
      };
      
      _setFeedback(
        success: 'Simulado iniciado com $_selectedQuantity questões!',
      );
      _setLoading(false);
      return result;
    } catch (error) {
      _setFeedback(
        error: 'Erro ao iniciar simulado. Tente novamente.',
      );
      _setLoading(false);
      return null;
    }
  }

  void setError(String message) {
    _errorMessage = message;
    _successMessage = null;
    notifyListeners();
  }

  void clearFeedback() {
    _clearFeedback();
  }

  void _clearFeedback() {
    if (_errorMessage == null && _successMessage == null) return;
    
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  void _setFeedback({String? error, String? success}) {
    _errorMessage = error;
    _successMessage = success;
    notifyListeners();
  }

  void _setLoading(bool value) {
    if (_isLoading == value) return;
    
    _isLoading = value;
    notifyListeners();
  }
}
