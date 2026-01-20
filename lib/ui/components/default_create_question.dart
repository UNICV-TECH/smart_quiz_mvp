import 'package:flutter/material.dart';
import 'package:unicv_tech_mvp/ui/components/default_button_orange.dart';
import 'package:unicv_tech_mvp/ui/components/default_input_select.dart';
import 'package:unicv_tech_mvp/ui/theme/app_color.dart';

class Preview {
  final String name;
  final Size? size;
  final Brightness? brightness;

  const Preview({required this.name, this.size, this.brightness});
}


@Preview(
  name: 'Criar Questões - Formulário',
  size: Size(400, 800),
  brightness: Brightness.light,
)
Widget defaultCreateQuestionContextFormPreview() {
  return const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: _Preview(),
  );
}

/// Dados consolidados do formulário de criação de questões.
class QuestionContextFormData {
  final String courseId;
  final String professorId;
  final String yearId;
  final String? semesterId;
  final String subjectId;
  final String contentId;

  const QuestionContextFormData({
    required this.courseId,
    required this.professorId,
    required this.yearId,
    required this.subjectId,
    required this.contentId,
    this.semesterId,
  });
}

/// Formulário para criação de questões com campos padronizados.
///
/// Utiliza os selects existentes (SelectPesquisa) e aplica as dependências:
/// - Professor e Matéria habilitam após seleção do curso.
/// - Conteúdo habilita após seleção da matéria.
/// - Semestre habilita após seleção do ano.
class DefaultCreateQuestionContextForm extends StatefulWidget {
  final List<SelectOption> courseOptions;
  final List<SelectOption> professorOptions;
  final List<SelectOption> yearOptions;
  final List<SelectOption> semesterOptions;
  final List<SelectOption> subjectOptions;
  final List<SelectOption> contentOptions;

  /// Define se semestre é obrigatório conforme regra de negócio.
  final bool semesterRequired;

  /// Valor inicial para pré-preencher o formulário.
  final QuestionContextFormData? initialValue;

  /// Callback disparado ao enviar o formulário válido.
  final ValueChanged<QuestionContextFormData>? onSubmit;

  /// Callbacks para carregar listas dependentes no backend.
  final ValueChanged<String>? onCourseChanged;
  final ValueChanged<String>? onSubjectChanged;
  final ValueChanged<String>? onYearChanged;

  const DefaultCreateQuestionContextForm({
    super.key,
    required this.courseOptions,
    required this.professorOptions,
    required this.yearOptions,
    required this.semesterOptions,
    required this.subjectOptions,
    required this.contentOptions,
    this.semesterRequired = false,
    this.initialValue,
    this.onSubmit,
    this.onCourseChanged,
    this.onSubjectChanged,
    this.onYearChanged,
  });

  @override
  State<DefaultCreateQuestionContextForm> createState() =>
      _DefaultCreateQuestionContextFormState();
}

class _DefaultCreateQuestionContextFormState
    extends State<DefaultCreateQuestionContextForm> {
  String? _selectedCourse;
  String? _selectedProfessor;
  String? _selectedYear;
  String? _selectedSemester;
  String? _selectedSubject;
  String? _selectedContent;

  final Map<String, String?> _errors = {
    'course': null,
    'professor': null,
    'year': null,
    'semester': null,
    'subject': null,
    'content': null,
  };

  @override
  void initState() {
    super.initState();
    _hydrateInitialValues();
  }

  @override
  void didUpdateWidget(covariant DefaultCreateQuestionContextForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sanitizeSelections();
  }

  void _hydrateInitialValues() {
    final initial = widget.initialValue;
    if (initial == null) return;

    _selectedCourse = initial.courseId;
    _selectedProfessor = initial.professorId;
    _selectedYear = initial.yearId;
    _selectedSemester = initial.semesterId;
    _selectedSubject = initial.subjectId;
    _selectedContent = initial.contentId;
  }

  void _sanitizeSelections() {
    bool changed = false;

    String? course = _selectedCourse;
    if (course != null && !_hasOption(widget.courseOptions, course)) {
      course = null;
      changed = true;
    }

    String? professor = _selectedProfessor;
    if (professor != null && !_hasOption(widget.professorOptions, professor)) {
      professor = null;
      changed = true;
    }

    String? year = _selectedYear;
    if (year != null && !_hasOption(widget.yearOptions, year)) {
      year = null;
      changed = true;
    }

    String? semester = _selectedSemester;
    if (semester != null && !_hasOption(widget.semesterOptions, semester)) {
      semester = null;
      changed = true;
    }

    String? subject = _selectedSubject;
    if (subject != null && !_hasOption(widget.subjectOptions, subject)) {
      subject = null;
      changed = true;
    }

    String? content = _selectedContent;
    if (content != null && !_hasOption(widget.contentOptions, content)) {
      content = null;
      changed = true;
    }

    if (changed) {
      setState(() {
        _selectedCourse = course;
        _selectedProfessor = professor;
        _selectedYear = year;
        _selectedSemester = semester;
        _selectedSubject = subject;
        _selectedContent = content;
      });
    }
  }

  bool _hasOption(List<SelectOption> options, String value) {
    return options.any((option) => option.value == value);
  }

  void _setCourse(String? value) {
    setState(() {
      _selectedCourse = value;
      _selectedProfessor = null;
      _selectedSubject = null;
      _selectedContent = null;
      _errors['course'] = null;
      _errors['professor'] = null;
      _errors['subject'] = null;
      _errors['content'] = null;
    });

    if (value != null) {
      widget.onCourseChanged?.call(value);
    }
  }

  void _setProfessor(String? value) {
    setState(() {
      _selectedProfessor = value;
      _errors['professor'] = null;
    });
  }

  void _setYear(String? value) {
    setState(() {
      _selectedYear = value;
      _selectedSemester = null;
      _errors['year'] = null;
      _errors['semester'] = null;
    });

    if (value != null) {
      widget.onYearChanged?.call(value);
    }
  }

  void _setSemester(String? value) {
    setState(() {
      _selectedSemester = value;
      _errors['semester'] = null;
    });
  }

  void _setSubject(String? value) {
    setState(() {
      _selectedSubject = value;
      _selectedContent = null;
      _errors['subject'] = null;
      _errors['content'] = null;
    });

    if (value != null) {
      widget.onSubjectChanged?.call(value);
    }
  }

  void _setContent(String? value) {
    setState(() {
      _selectedContent = value;
      _errors['content'] = null;
    });
  }

  bool _validate() {
    bool isValid = true;

    setState(() {
      _errors['course'] = _selectedCourse == null ? 'Selecione um curso' : null;
      _errors['professor'] =
          _selectedProfessor == null ? 'Selecione o professor' : null;
      _errors['year'] = _selectedYear == null ? 'Selecione o ano' : null;
      _errors['semester'] = widget.semesterRequired && _selectedSemester == null
          ? 'Selecione o semestre'
          : null;
      _errors['subject'] =
          _selectedSubject == null ? 'Selecione a matéria' : null;
      _errors['content'] =
          _selectedContent == null ? 'Selecione o conteúdo' : null;

      isValid = _errors.values.every((error) => error == null);
    });

    return isValid;
  }

  void _submit() {
    if (!_validate()) return;

    final data = QuestionContextFormData(
      courseId: _selectedCourse!,
      professorId: _selectedProfessor!,
      yearId: _selectedYear!,
      semesterId: _selectedSemester,
      subjectId: _selectedSubject!,
      contentId: _selectedContent!,
    );

    widget.onSubmit?.call(data);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Criar Questões',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.webNeutral900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Preencha os campos padronizados para garantir o vínculo correto das questões.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.webNeutral600,
            ),
          ),
          const SizedBox(height: 24),
          _buildSelect(
            label: 'Curso',
            required: true,
            value: _selectedCourse,
            options: widget.courseOptions,
            placeholder: 'Selecione o curso',
            errorText: _errors['course'],
            enabled: true,
            onChanged: _setCourse,
          ),
          const SizedBox(height: 16),
          _buildSelect(
            label: 'Professor',
            required: true,
            value: _selectedProfessor,
            options: widget.professorOptions,
            placeholder: 'Selecione o professor',
            errorText: _errors['professor'],
            enabled: _selectedCourse != null,
            onChanged: _selectedCourse != null ? _setProfessor : null,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSelect(
                  label: 'Ano',
                  required: true,
                  value: _selectedYear,
                  options: widget.yearOptions,
                  placeholder: 'Selecione o ano',
                  errorText: _errors['year'],
                  enabled: true,
                  onChanged: _setYear,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSelect(
                  label: 'Semestre',
                  required: widget.semesterRequired,
                  value: _selectedSemester,
                  options: widget.semesterOptions,
                  placeholder: 'Selecione o semestre',
                  errorText: _errors['semester'],
                  enabled: _selectedYear != null,
                  onChanged: _selectedYear != null ? _setSemester : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSelect(
            label: 'Matéria',
            required: true,
            value: _selectedSubject,
            options: widget.subjectOptions,
            placeholder: 'Selecione a matéria',
            errorText: _errors['subject'],
            enabled: _selectedCourse != null,
            onChanged: _selectedCourse != null ? _setSubject : null,
          ),
          const SizedBox(height: 16),
          _buildSelect(
            label: 'Conteúdo',
            required: true,
            value: _selectedContent,
            options: widget.contentOptions,
            placeholder: 'Selecione o conteúdo',
            errorText: _errors['content'],
            enabled: _selectedSubject != null,
            onChanged: _selectedSubject != null ? _setContent : null,
          ),
        ],
      ),
    );
  }

  Widget _buildSelect({
    required String label,
    required bool required,
    required List<SelectOption> options,
    required String placeholder,
    required String? errorText,
    required bool enabled,
    required ValueChanged<String?>? onChanged,
    String? value,
  }) {
    return SelectPesquisa(
      label: label,
      required: required,
      options: options,
      value: value,
      placeholder: placeholder,
      errorText: errorText,
      enabled: enabled,
      onChanged: onChanged ?? (_) {},
    );
  }
}

/// Preview isolado para facilitar QA visual sem backend.
class _Preview extends StatelessWidget {
  const _Preview();

  @override
  Widget build(BuildContext context) {
    const options = [
      SelectOption(value: '1', label: 'Opção 1'),
      SelectOption(value: '2', label: 'Opção 2'),
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: DefaultCreateQuestionContextForm(
          courseOptions: const [
            SelectOption(value: 'curso-1', label: 'Engenharia'),
            SelectOption(value: 'curso-2', label: 'Direito'),
          ],
          professorOptions: options,
          yearOptions: const [
            SelectOption(value: '2024', label: '2024'),
            SelectOption(value: '2025', label: '2025'),
          ],
          semesterOptions: const [
            SelectOption(value: '1', label: '1º semestre'),
            SelectOption(value: '2', label: '2º semestre'),
          ],
          subjectOptions: const [
            SelectOption(value: 'mat-1', label: 'Cálculo I'),
            SelectOption(value: 'mat-2', label: 'Direito Civil'),
          ],
          contentOptions: options,
          semesterRequired: false,
          onSubmit: (data) {
            debugPrint('Curso: ${data.courseId}');
            debugPrint('Professor: ${data.professorId}');
            debugPrint('Ano: ${data.yearId}');
            debugPrint('Semestre: ${data.semesterId}');
            debugPrint('Matéria: ${data.subjectId}');
            debugPrint('Conteúdo: ${data.contentId}');
          },
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(home: _Preview()));
}
