import 'package:flutter/material.dart';
import '../ui/theme/app_color.dart';
import '../constants/app_strings.dart';
import '../ui/components/default_accordion.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  // Lista de perguntas frequentes (dados mockados)
  final List<Map<String, String>> _faqs = [
    {
      'question': 'Como criar uma prova de estudo?',
      'answer':
          'Para criar uma prova de estudo, acesse a tela inicial e clique no botão "Criar Prova". Selecione a matéria, o número de questões e o nível de dificuldade desejado.'
    },
    {
      'question': 'Como visualizar meu histórico de provas?',
      'answer':
          'Você pode acessar seu histórico de provas através do menu principal. Lá você encontrará todas as provas realizadas, com suas respectivas notas e estatísticas de desempenho.'
    },
    {
      'question': 'Como funciona o sistema de pontuação?',
      'answer':
          'Cada questão tem um valor específico. Ao responder corretamente, você ganha pontos. Ao final da prova, sua pontuação é calculada e você pode comparar com suas tentativas anteriores.'
    },
    {
      'question': 'Posso refazer uma prova?',
      'answer':
          'Sim! Você pode refazer qualquer prova quantas vezes quiser. Cada tentativa ficará registrada no seu histórico para acompanhamento da sua evolução.'
    },
    {
      'question': 'Como escolher as matérias de estudo?',
      'answer':
          'Na tela de explorar, você encontrará todas as matérias disponíveis. Selecione as que deseja estudar e elas ficarão disponíveis para criar provas personalizadas.'
    },
    {
      'question': 'O app funciona offline?',
      'answer':
          'Algumas funcionalidades estão disponíveis offline, mas para criar novas provas e sincronizar seu progresso, é necessário estar conectado à internet.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: Stack(
        children: [
          // Imagem de fundo
          Positioned.fill(
            child: Image.asset(
              'assets/images/FundoWhiteHome.png',
              fit: BoxFit.cover,
            ),
          ),
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(
                  Icons.chevron_left,
                  color: AppColors.green,
                  size: 32,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              title: Text(
                AppStrings.helpTitle,
                style: TextStyle(
                  color: AppColors.green,
                  fontSize: 24,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),

                    // Subtítulo
                    Text(
                      'Perguntas Frequentes',
                      style: TextStyle(
                        color: AppColors.secondaryDark,
                        fontSize: 16,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Lista de FAQs (Accordions)
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _faqs.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return DefaultAccordion(
                          title: _faqs[index]['question']!,
                          content: _faqs[index]['answer']!,
                          icon: Icons.help_outline,
                        );
                      },
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
