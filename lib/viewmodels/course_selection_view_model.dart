import 'package:flutter/material.dart';
import '../models/course.dart';

class CourseSelectionViewModel extends ChangeNotifier {
  CourseSelectionViewModel({
    Duration loadDelay = const Duration(milliseconds: 500),
  }) : _loadDelay = loadDelay;

  String? _selectedCourseId;
  List<Course> _courses = [];
  bool _isLoading = false;
  String? _errorMessage;
  final Duration _loadDelay;

  String? get selectedCourseId => _selectedCourseId;
  List<Course> get courses => List.unmodifiable(_courses);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasSelection => _selectedCourseId != null;
  bool get hasCourses => _courses.isNotEmpty;

  Course? get selectedCourse {
    if (_selectedCourseId == null) return null;
    try {
      return _courses.firstWhere((course) => course.id == _selectedCourseId);
    } catch (_) {
      return null;
    }
  }

  Future<void> loadCourses() async {
    _setLoading(true);
    _clearError();

    try {
      if (_loadDelay > Duration.zero) {
        await Future.delayed(_loadDelay);
      }
      
      _courses = _getMockCourses();
      _setLoading(false);
    } catch (error) {
      _setError('Erro ao carregar cursos. Tente novamente.');
      _setLoading(false);
    }
  }

  void selectCourse(String courseId) {
    if (_selectedCourseId == courseId) return;
    
    _selectedCourseId = courseId;
    _clearError();
    notifyListeners();
  }

  void clearSelection() {
    if (_selectedCourseId == null) return;
    
    _selectedCourseId = null;
    notifyListeners();
  }

  void setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }

  void _clearError() {
    if (_errorMessage == null) return;
    
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _setLoading(bool value) {
    if (_isLoading == value) return;
    
    _isLoading = value;
    notifyListeners();
  }

  List<Course> _getMockCourses() {
    return [
      Course(
        id: 'psicologia',
        courseKey: 'psicologia',
        title: 'Psicologia',
        iconKey: 'psychology_outlined',
        iconData: Icons.psychology_outlined,
        createdAt: DateTime.now(),
      ),
      Course(
        id: 'ciencias_sociais',
        courseKey: 'ciencias_sociais',
        title: 'Ciências Sociais',
        iconKey: 'groups_outlined',
        iconData: Icons.groups_outlined,
        createdAt: DateTime.now(),
      ),
      Course(
        id: 'administracao',
        courseKey: 'administracao',
        title: 'Administração',
        iconKey: 'business_center_outlined',
        iconData: Icons.business_center_outlined,
        createdAt: DateTime.now(),
      ),
      Course(
        id: 'gestao_financeira',
        courseKey: 'gestao_financeira',
        title: 'Gestão Finan.',
        iconKey: 'monetization_on_outlined',
        iconData: Icons.monetization_on_outlined,
        createdAt: DateTime.now(),
      ),
      Course(
        id: 'pedagogia',
        courseKey: 'pedagogia',
        title: 'Pedagogia',
        iconKey: 'school_outlined',
        iconData: Icons.school_outlined,
        createdAt: DateTime.now(),
      ),
      Course(
        id: 'design_grafico',
        courseKey: 'design_grafico',
        title: 'Design Gráfico',
        iconKey: 'palette_outlined',
        iconData: Icons.palette_outlined,
        createdAt: DateTime.now(),
      ),
      Course(
        id: 'direito',
        courseKey: 'direito',
        title: 'Direito',
        iconKey: 'gavel_outlined',
        iconData: Icons.gavel_outlined,
        createdAt: DateTime.now(),
      ),
      Course(
        id: 'ciencias_contabeis',
        courseKey: 'ciencias_contabeis',
        title: 'Ciências Contábeis',
        iconKey: 'calculate_outlined',
        iconData: Icons.calculate_outlined,
        createdAt: DateTime.now(),
      ),
    ];
  }
}
