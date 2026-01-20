import 'package:flutter/material.dart';
import 'package:unicv_tech_mvp/ui/components/default_button_orange.dart';
import 'package:unicv_tech_mvp/ui/components/default_input.dart';
import 'package:unicv_tech_mvp/ui/theme/app_color.dart';

class Preview {
  final String name;
  final Size? size;
  final Brightness? brightness;

  const Preview({required this.name, this.size, this.brightness});
}

const Size tamanhoPadraoPreview = Size(450, 800);

// --- PREVIEWS ---

@Preview(
  name: 'Criar Questão - Padrão',
  size: tamanhoPadraoPreview,
  brightness: Brightness.light,
)
Widget componenteCriarQuestaoPadraoPreview() {
  return Scaffold(
    backgroundColor: Colors.grey.shade100,
    body: DefaultCreateQuestion(
      onSave: ({
        required String question,
        required List<AlternativeModel> alternatives,
        String? supportingText,
        String? statement,
      }) {
        debugPrint('Preview: Questão salva com sucesso!');
      },
    ),
  );
}

/// Modelo de dados para uma alternativa
class AlternativeModel {
  final String id;
  String text;
  bool isCorrect;

  AlternativeModel({
    required this.id,
    this.text = '',
    this.isCorrect = false,
  });
}

/// Componente de criação de questões
///
/// Permite criar questões com:
/// - Texto de apoio (opcional)
/// - Pergunta (obrigatório)
/// - Lista de alternativas com seleção de resposta correta
/// - Validação de campos obrigatórios
class DefaultCreateQuestion extends StatefulWidget {
  /// Callback chamado ao salvar a questão com sucesso
  final Function({
    required String question,
    required List<AlternativeModel> alternatives,
    String? supportingText,
    String? statement,
  })? onSave;

  /// Texto inicial do campo de texto de apoio
  final String? initialSupportingText;

  /// Texto inicial do enunciado
  final String? initialStatementText;

  /// Texto inicial da pergunta
  final String? initialQuestion;

  /// Alternativas iniciais (opcional)
  final List<AlternativeModel>? initialAlternatives;

  const DefaultCreateQuestion({
    super.key,
    this.onSave,
    this.initialSupportingText,
    this.initialStatementText,
    this.initialQuestion,
    this.initialAlternatives,
  });

  @override
  State<DefaultCreateQuestion> createState() => _DefaultCreateQuestionState();
}

class _DefaultCreateQuestionState extends State<DefaultCreateQuestion> {
  // Controllers para os campos de texto
  late TextEditingController _supportingTextController;
  late TextEditingController _statementController;
  late TextEditingController _questionController;

  // Lista de alternativas
  final List<AlternativeModel> _alternatives = [];

  // Mensagens de erro
  String? _questionError;
  String? _correctAnswerError;

  // Contador para gerar IDs únicos
  int _alternativeIdCounter = 0;

  @override
  void initState() {
    super.initState();

    // Inicializa controllers
    _supportingTextController = TextEditingController(
      text: widget.initialSupportingText ?? '',
    );
    _statementController = TextEditingController(
      text: widget.initialStatementText ?? '',
    );
    _questionController = TextEditingController(
      text: widget.initialQuestion ?? '',
    );

    // Inicializa alternativas
    if (widget.initialAlternatives != null &&
        widget.initialAlternatives!.isNotEmpty) {
      _alternatives.addAll(widget.initialAlternatives!);
      _alternativeIdCounter = _alternatives.length;
    } else {
      // Adiciona primeira alternativa por padrão
      _addAlternative();
    }
  }

  @override
  void dispose() {
    _supportingTextController.dispose();
    _statementController.dispose();
    _questionController.dispose();
    super.dispose();
  }

  /// Adiciona uma nova alternativa à lista
  void _addAlternative() {
    setState(() {
      _alternatives.add(
        AlternativeModel(
          id: 'alt_${_alternativeIdCounter++}',
          text: '',
          isCorrect: false,
        ),
      );
    });
  }

  /// Remove uma alternativa da lista
  void _removeAlternative(String id) {
    if (_alternatives.length <= 1) {
      _showMessage('É necessário ter pelo menos uma alternativa');
      return;
    }

    setState(() {
      _alternatives.removeWhere((alt) => alt.id == id);
    });
  }

  /// Marca uma alternativa como correta
  void _setCorrectAlternative(String id) {
    setState(() {
      for (var alt in _alternatives) {
        alt.isCorrect = alt.id == id;
      }
      _correctAnswerError = null;
    });
  }

  /// Atualiza o texto de uma alternativa
  void _updateAlternativeText(String id, String text) {
    final alt = _alternatives.firstWhere((a) => a.id == id);
    alt.text = text;
  }

  /// Valida os campos antes de salvar
  bool _validate() {
    bool isValid = true;

    setState(() {
      // Valida pergunta
      if (_questionController.text.trim().isEmpty) {
        _questionError = 'A pergunta é obrigatória';
        isValid = false;
      } else {
        _questionError = null;
      }

      // Valida resposta correta
      final hasCorrectAnswer = _alternatives.any((alt) => alt.isCorrect);
      if (!hasCorrectAnswer) {
        _correctAnswerError = 'Selecione uma resposta correta';
        isValid = false;
      } else {
        _correctAnswerError = null;
      }

      // Valida se alternativas têm texto
      final hasEmptyAlternative = _alternatives.any(
        (alt) => alt.text.trim().isEmpty,
      );
      if (hasEmptyAlternative) {
        _showMessage('Todas as alternativas devem ter texto');
        isValid = false;
      }
    });

    return isValid;
  }

  /// Salva a questão
  void _save() {
    if (!_validate()) return;

    if (widget.onSave != null) {
      widget.onSave!(
        question: _questionController.text.trim(),
        alternatives: _alternatives,
        supportingText: _supportingTextController.text.trim().isEmpty
            ? null
            : _supportingTextController.text.trim(),
        statement: _statementController.text.trim().isEmpty
            ? null
            : _statementController.text.trim(),
      );
    }

    _showMessage('Questão salva com sucesso!');
  }

  /// Exibe mensagem ao usuário
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título
          const Text(
            'Criar Nova Questão',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.webNeutral900,
            ),
          ),
          const SizedBox(height: 24),

          // Texto de Apoio (opcional)
          _buildSectionTitle('Texto de Apoio (opcional)'),
          const SizedBox(height: 8),
          const Text(
            'Adicione um contexto ou um texto complementar',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.webNeutral600,
            ),
          ),
          const SizedBox(height: 12),
          _buildTextArea(
            controller: _supportingTextController,
            hintText: 'Digite o texto de apoio aqui...',
            maxLines: 4,
          ),
          const SizedBox(height: 32),

          // Enunciado
          _buildSectionTitle('Enunciado'),
          const SizedBox(height: 8),
          const Text(
            'Descreva o enunciado principal da questão',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.webNeutral600,
            ),
          ),
          const SizedBox(height: 12),
          _buildTextArea(
            controller: _statementController,
            hintText: 'Digite o enunciado aqui...',
            maxLines: 4,
          ),
          const SizedBox(height: 32),

          // Pergunta (obrigatório)
          _buildSectionTitle('Pergunta*'),
          const SizedBox(height: 12),
          ComponenteInput(
            controller: _questionController,
            labelText: 'Pergunta obrigatória',
            hintText: 'Digite a pergunta clara e objetiva',
            errorMessage: _questionError,
            onChanged: (value) {
              if (_questionError != null) {
                setState(() {
                  _questionError = null;
                });
              }
            },
          ),
          const SizedBox(height: 32),

          // Alternativas
          _buildSectionTitle('Alternativas'),
          const SizedBox(height: 8),
          const Text(
            'Adicione as opções de resposta e marque a correta',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.webNeutral600,
            ),
          ),
          const SizedBox(height: 16),

          // Lista de alternativas
          ..._buildAlternativesList(),

          const SizedBox(height: 16),

          // Botão adicionar alternativa
          _buildAddAlternativeButton(),

          const SizedBox(height: 16),

          // Mensagem de erro de resposta correta
          if (_correctAnswerError != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _correctAnswerError!,
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          const SizedBox(height: 32),

          // Botão Salvar
          DefaultButtonOrange(
            texto: 'Salvar Questão',
            onPressed: _save,
            tipo: BotaoTipo.primario,
          ),
        ],
      ),
    );
  }

  /// Constrói o título de uma seção
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.webNeutral900,
      ),
    );
  }

  /// Constrói um campo de texto multilinhas
  Widget _buildTextArea({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 3,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.webNeutral300),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: AppColors.webNeutral400,
            fontSize: 14,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  /// Constrói a lista de alternativas
  List<Widget> _buildAlternativesList() {
    return _alternatives.asMap().entries.map((entry) {
      final index = entry.key;
      final alternative = entry.value;
      final letter = String.fromCharCode(65 + index); // A, B, C, D...

      return Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: _buildAlternativeItem(
          alternative: alternative,
          letter: letter,
          canRemove: _alternatives.length > 1,
        ),
      );
    }).toList();
  }

  /// Constrói um item de alternativa
  Widget _buildAlternativeItem({
    required AlternativeModel alternative,
    required String letter,
    required bool canRemove,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: alternative.isCorrect
            ? AppColors.green.withValues(alpha: 0.1)
            : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color:
              alternative.isCorrect ? AppColors.green : AppColors.webNeutral300,
          width: alternative.isCorrect ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Radio button para marcar como correta
              GestureDetector(
                onTap: () => _setCorrectAlternative(alternative.id),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: alternative.isCorrect
                        ? AppColors.green
                        : AppColors.webNeutral400,
                    border: Border.all(
                      color: alternative.isCorrect
                          ? AppColors.green
                          : AppColors.webNeutral300,
                      width: 2,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    letter,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Label
              Expanded(
                child: Text(
                  alternative.isCorrect
                      ? 'Alternativa $letter (Correta)'
                      : 'Alternativa $letter',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: alternative.isCorrect
                        ? FontWeight.bold
                        : FontWeight.w500,
                    color: alternative.isCorrect
                        ? AppColors.green
                        : AppColors.webNeutral900,
                  ),
                ),
              ),

              // Botão remover
              if (canRemove)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.red.shade400,
                  onPressed: () => _removeAlternative(alternative.id),
                  tooltip: 'Remover alternativa',
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Campo de texto da alternativa
          TextField(
            onChanged: (value) => _updateAlternativeText(alternative.id, value),
            controller: TextEditingController(text: alternative.text)
              ..selection = TextSelection.collapsed(
                offset: alternative.text.length,
              ),
            decoration: InputDecoration(
              hintText: 'Digite o texto da alternativa $letter',
              hintStyle: TextStyle(
                color: AppColors.webNeutral400,
                fontSize: 14,
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.webNeutral300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.webNeutral300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.green, width: 2),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  /// Constrói o botão de adicionar alternativa
  Widget _buildAddAlternativeButton() {
    return OutlinedButton.icon(
      onPressed: _addAlternative,
      icon: const Icon(Icons.add_circle_outline),
      label: const Text('Adicionar Alternativa'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.green,
        side: BorderSide(color: AppColors.green),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
