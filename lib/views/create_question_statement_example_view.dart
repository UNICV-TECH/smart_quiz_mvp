import 'package:flutter/material.dart';
import 'package:unicv_tech_mvp/ui/components/default_create_question-statement.dart';

/// Exemplo de tela que utiliza o componente DefaultCreateQuestion
///
/// Esta tela demonstra como integrar o componente de criação de questões
/// em uma view completa do aplicativo
class CreateQuestionExampleView extends StatelessWidget {
  const CreateQuestionExampleView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Questão'),
        backgroundColor: const Color.fromRGBO(239, 153, 45, 1.0),
      ),
      body: DefaultCreateQuestion(
        // Callback quando a questão for salva
        onSave: ({
          required String question,
          required List<AlternativeModel> alternatives,
          String? supportingText,
          String? statement,
        }) {
          // Aqui você pode:
          // 1. Salvar no banco de dados via repository
          // 2. Atualizar um ViewModel
          // 3. Navegar para outra tela

          debugPrint('=== Questão Salva ===');
          debugPrint('Pergunta: $question');

          if (supportingText != null && supportingText.isNotEmpty) {
            debugPrint('Texto de apoio: $supportingText');
          }

          if (statement != null && statement.isNotEmpty) {
            debugPrint('Enunciado: $statement');
          }

          debugPrint('\nAlternativas:');
          for (int i = 0; i < alternatives.length; i++) {
            final alt = alternatives[i];
            final letter = String.fromCharCode(65 + i);
            debugPrint('$letter) ${alt.text} ${alt.isCorrect ? '✓' : ''}');
          }

          // Exemplo: navegando de volta após salvar
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
