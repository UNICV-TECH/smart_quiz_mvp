import 'package:flutter/material.dart';
import 'package:unicv_tech_mvp/services/repositorie/question_repository.dart';
import 'package:unicv_tech_mvp/ui/components/default_radio_group.dart';
import 'package:unicv_tech_mvp/ui/components/default_button_back.dart';
import 'package:unicv_tech_mvp/ui/components/default_button_forward.dart';
import 'package:unicv_tech_mvp/ui/components/default_question_navigation.dart';
import 'package:unicv_tech_mvp/ui/components/default_Logo.dart' as logo;
import 'package:unicv_tech_mvp/ui/components/default_button_arrow_back.dart';
import 'package:unicv_tech_mvp/ui/theme/app_color.dart';

class ExamScreen extends StatefulWidget {
  const ExamScreen({super.key});

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  // Estado para armazenar respostas selecionadas: questionId -> option (A, B, C, etc)
  Map<int, String> selectedAnswers = {};
  
  // Estado da questão atual
  int currentQuestionIndex = 0;
  
  // ScrollController para controlar a rolagem da barra de questões
  final ScrollController _questionScrollController = ScrollController();

  // Questões do simulado
  final Exam exam = Exam(
    questions: [
      Question(
        id: 1,
        enunciation: 
            'Uma empresa de e-commerce notou que seus usuários estão abandonando o '
            'carrinho de compras no checkout, especialmente quando a página exige '
            'muitos campos de preenchimento. O time de design foi chamado para propor '
            'melhorias de UX. Qual das seguintes ações seria a mais eficaz para resolver '
            'esse problema?',
        alternatives: [
          'Aumentar a quantidade de campos obrigatórios para coleta de mais dados.',
          'Implementar um indicador de progresso da página e reduzir a quantidade de campos obrigatórios ao mínimo.',
          'Substituir o formulário por um texto explicativo sobre a importância de completar o cadastro.',
          'Incluir pop-ups adicionais para orientar o usuário sobre o preenchimento.',
          'Exigir que o usuário crie uma conta antes de visualizar qualquer produto no site.',
        ],
        correctAnswer: 'B',
      ),
      Question(
        id: 2,
        enunciation: 
            'Em uma interface mobile, qual princípio de design é mais importante para '
            'garantir uma boa experiência do usuário?',
        alternatives: [
          'Usar a maior quantidade possível de cores para tornar a interface mais atrativa.',
          'Deixar textos pequenos para caber mais informações na tela.',
          'Garantir que botões e áreas clicáveis tenham tamanho mínimo de 44x44 pixels.',
          'Eliminar todos os espaços em branco para maximizar o conteúdo.',
          'Utilizar fonte serifada para melhorar a legibilidade em telas pequenas.',
        ],
      ),
      Question(
        id: 3,
        enunciation: 
            'Uma aplicação web está com problemas de performance. O usuário reclama '
            'que as páginas demoram muito para carregar. Qual é a primeira ação que deve '
            'ser tomada?',
        alternatives: [
          'Adicionar mais imagens e animações para tornar a página mais atraente.',
          'Otimizar o código, minimizar recursos e usar técnicas de carregamento assíncrono.',
          'Aumentar o tamanho dos arquivos para garantir melhor qualidade.',
          'Adicionar mais plugins e widgets à página.',
          'Reduzir a quantidade de conteúdo visível na primeira visualização.',
        ],
      ),
      Question(
        id: 4,
        enunciation: 
            'No contexto de acessibilidade web, o que significa o termo "contraste de cores"?',
        alternatives: [
          'A diferença de cores entre elementos para criar uma aparência mais bonita.',
          'A diferença de luminosidade entre texto e fundo, necessária para legibilidade.',
          'O uso de cores complementares no círculo cromático.',
          'A variação de tons de uma mesma cor.',
          'O número de cores diferentes usadas em uma interface.',
        ],
      ),
      Question(
        id: 5,
        enunciation: 
            'Qual é o objetivo principal de realizar testes de usabilidade?',
        alternatives: [
          'Verificar se o código está sem bugs e funcionando perfeitamente.',
          'Testar a velocidade de carregamento das páginas.',
          'Identificar problemas de navegação e experiência do usuário antes do lançamento.',
          'Garantir que todos os recursos estão implementados.',
          'Verificar se a paleta de cores está harmoniosa.',
        ],
      ),
      Question(
        id: 6,
        enunciation: 
            'Em desenvolvimento web, o que significa o termo "responsividade"?',
        alternatives: [
          'Garantir que a aplicação funciona apenas em dispositivos móveis.',
          'Adaptar o layout e funcionalidades para diferentes tamanhos de tela.',
          'Criar versões separadas para cada dispositivo.',
          'Usar apenas fontes grandes para garantir legibilidade.',
          'Limitar o conteúdo para caber em qualquer tela.',
        ],
      ),
      Question(
        id: 7,
        enunciation: 
            'Qual é a função principal de um wireframe em design?',
        alternatives: [
          'Mostrar a paleta de cores final da interface.',
          'Definir a estrutura e layout básico sem detalhes visuais.',
          'Criar animações e transições.',
          'Implementar a versão final da aplicação.',
          'Testar o desempenho da página.',
        ],
      ),
      Question(
        id: 8,
        enunciation: 
            'O que é feedback visual em interfaces?',
        alternatives: [
          'Mensagens de erro apenas.',
          'Informações fornecidas ao usuário sobre ações e estados do sistema.',
          'Alertas sonoros quando há erro.',
          'Notificações via email.',
          'Logs de sistema para desenvolvedores.',
        ],
      ),
      Question(
        id: 9,
        enunciation: 
            'Qual técnica é mais eficaz para reduzir a taxa de rejeição em páginas web?',
        alternatives: [
          'Aumentar o tempo de carregamento com mais imagens.',
          'Melhorar o tempo de carregamento e oferecer conteúdo relevante rapidamente.',
          'Reduzir a quantidade de conteúdo.',
          'Remover todas as animações.',
          'Usar pop-ups para prender atenção.',
        ],
      ),
      Question(
        id: 10,
        enunciation: 
            'No design de formulários, qual é a melhor prática para campos obrigatórios?',
        alternatives: [
          'Não sinalizar, deixar o usuário descobrir ao tentar enviar.',
          'Marcar com asterisco (*) e manter consistência em todo formulário.',
          'Usar cores muito chamativas que distraem.',
          'Colocar todos os campos obrigatórios no topo.',
          'Ocultar campos não obrigatórios completamente.',
        ],
      ),
      Question(
        id: 11,
        enunciation: 
            'O que significa "progressive disclosure" em UX?',
        alternatives: [
          'Mostrar todas as informações de uma vez.',
          'Apresentar informações gradualmente conforme o usuário precisa.',
          'Ocultar funcionalidades avançadas permanentemente.',
          'Sobrecarregar o usuário com opções.',
          'Nunca revelar funcionalidades extras.',
        ],
      ),
      Question(
        id: 12,
        enunciation: 
            'Qual é o tamanho recomendado para áreas clicáveis em interfaces mobile?',
        alternatives: [
          'Menor que 20x20 pixels.',
          'Mínimo de 44x44 pixels para facilitar o toque.',
          'Qualquer tamanho, desde que seja bonito.',
          'Apenas texto clicável.',
          'Conforme o tamanho da tela.',
        ],
      ),
      Question(
        id: 13,
        enunciation: 
            'O que é "above the fold" em design web?',
        alternatives: [
          'A parte da página que requer scroll para ser vista.',
          'A área visível sem rolar a página, considerada mais importante.',
          'O rodapé do site.',
          'A versão mobile apenas.',
          'O menu de navegação.',
        ],
      ),
      Question(
        id: 14,
        enunciation: 
            'Qual é o objetivo das hierarquias visuais em design?',
        alternatives: [
          'Criar confusão visual.',
          'Guiar o olho do usuário e priorizar informações importantes.',
          'Usar apenas uma cor.',
          'Remover todo o destaque.',
          'Deixar tudo do mesmo tamanho.',
        ],
      ),
      Question(
        id: 15,
        enunciation: 
            'O que significa "affordance" em design de interfaces?',
        alternatives: [
          'Criar elementos que sugerem sua função através da aparência.',
          'Adicionar instruções textuais para tudo.',
          'Usar apenas ícones sem texto.',
          'Fazer elementos parecerem clicáveis quando não são.',
          'Ocultar funcionalidades para parecer moderno.',
        ],
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final currentQuestion = exam.questions[currentQuestionIndex];
    final currentAnswer = selectedAnswers[currentQuestion.id];
    final isFirstQuestion = currentQuestionIndex == 0;
    final isLastQuestion = currentQuestionIndex == exam.questions.length - 1;

    // Margem horizontal padrão para toda a tela
    const horizontalPadding = 24.0;
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE8F5ED), // Verde claro pastel uniforme
              Color(0xFFE8F5ED),
              Color(0xFFE8F5ED),
            ],
          ),
        ),
        child: Column(
          children: [
            _buildAppBar(horizontalPadding),
            
            // Indicador de progresso de questões
            _buildProgressIndicator(horizontalPadding),
            
            // Conteúdo da questão
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título da questão
                    _buildQuestionTitle(currentQuestionIndex + 1),
                    
                    const SizedBox(height: 16),
                    
                    // Enunciado com justificação de texto
                    _buildEnunciation(currentQuestion.enunciation),
                    
                    const SizedBox(height: 24),
                    
                    // Alternativas (Radio Group)
                    AlternativeSelectorVertical(
                      labels: currentQuestion.alternatives,
                      selectedOption: currentAnswer,
                      onChanged: (option) {
                        setState(() {
                          selectedAnswers[currentQuestion.id] = option;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            // Botões de navegação
            _buildNavigationButtons(
              isFirstQuestion: isFirstQuestion,
              isLastQuestion: isLastQuestion,
              horizontalPadding: horizontalPadding,
            ),
          ],
        ),
      ),
    );
  }

  // AppBar com logo e botão voltar
  Widget _buildAppBar(double horizontalPadding) {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8.0),
        child: Row(
          children: [
            DefaultButtonArrowBack(
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            Expanded(
              child: Center(
                child: logo.AppLogoWidget.asset(
                  size: logo.AppLogoSize.small,
                  logoPath: 'assets/images/logo_color.png',
                ),
              ),
            ),
            // Espaço balanceado para o leading
            const SizedBox(width: 40),
          ],
        ),
      ),
    );
  }

  // Indicador de progresso de questões
  Widget _buildProgressIndicator(double horizontalPadding) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16.0),
          child: SingleChildScrollView(
            controller: _questionScrollController,
            scrollDirection: Axis.horizontal,
            child: QuestionNavigation(
              totalQuestions: exam.questions.length,
              currentQuestion: currentQuestionIndex + 1,
              onQuestionSelected: (questionNumber) {
                setState(() {
                  currentQuestionIndex = questionNumber - 1;
                  // Scroll automático após mudança de questão
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollToQuestion();
                  });
                });
              },
              answeredQuestions: selectedAnswers.keys.toSet(),
            ),
          ),
        ),
        // Divider com margem
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Container(
            height: 1.0,
            color: AppColors.green,
          ),
        ),
      ],
    );
  }

  // Título da questão
  Widget _buildQuestionTitle(int questionNumber) {
    return Text(
      'Questão $questionNumber',
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryDark,
      ),
    );
  }

  // Enunciado com justificação de texto
  Widget _buildEnunciation(String enunciation) {
    return Text(
      enunciation,
      style: const TextStyle(
        fontSize: 16,
        height: 1.5,
        color: AppColors.primaryDark,
      ),
      textAlign: TextAlign.justify,
    );
  }

  // Botões de navegação
  Widget _buildNavigationButtons({
    required bool isFirstQuestion,
    required bool isLastQuestion,
    required double horizontalPadding,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16.0),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Botão Anterior
            if (!isFirstQuestion)
              DefaultButtonBack(
                text: 'Anterior',
                icon: Icons.arrow_back_ios,
                onPressed: () {
                  if (currentQuestionIndex > 0) {
                    setState(() {
                      currentQuestionIndex--;
                    });
                    // Scroll automático após mudança de questão
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _scrollToQuestion();
                    });
                  }
                },
              )
            else
              const SizedBox(width: 90), // Espaço vazio para manter layout

            // Botão Próxima
            DefaultButtonForward(
              text: isLastQuestion ? 'Finalizar' : 'Próxima',
              icon: Icons.arrow_forward_ios,
              onPressed: () {
                if (isLastQuestion) {
                  // Finalizar simulado
                  _showFinishDialog();
                } else {
                  // Próxima questão com scroll automático
                  if (currentQuestionIndex < exam.questions.length - 1) {
                    setState(() {
                      currentQuestionIndex++;
                    });
                    // Scroll automático após mudança de questão
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _scrollToQuestion();
                    });
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // Dialog de finalização
  void _showFinishDialog() {
    final answeredCount = selectedAnswers.length;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Finalizar Simulado'),
          content: Text(
            'Você respondeu $answeredCount de ${exam.questions.length} questões. '
            'Deseja finalizar o simulado?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Enviar as respostas ao backend
                _submitExam();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                foregroundColor: AppColors.white,
              ),
              child: const Text('Finalizar'),
            ),
          ],
        );
      },
    );
  }

  // Enviar respostas (mock)
  void _submitExam() {
    // Apenas navegar de volta
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Simulado finalizado com sucesso!'),
        backgroundColor: AppColors.green,
      ),
    );
    Navigator.pop(context);
  }

  // Método para rolar até a questão atual
  void _scrollToQuestion() {
    if (_questionScrollController.hasClients) {
      // Calcula a posição baseada na questão atual
      // Cada questão tem 40px (largura) + 6px (margem 3px de cada lado) = 46px
      final double targetPosition = (currentQuestionIndex * 46.0) - 100.0;
      _questionScrollController.animateTo(
        targetPosition.clamp(0.0, _questionScrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _questionScrollController.dispose();
    super.dispose();
  }
}

