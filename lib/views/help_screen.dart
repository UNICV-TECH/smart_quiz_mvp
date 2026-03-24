import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../ui/theme/app_color.dart';
import '../ui/components/default_accordion.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final List<Map<String, String>> _faqs = [
    {
      'question': 'Como criar uma prova de estudo?',
      'answer':
          'Na tela inicial, selecione o curso desejado e toque em "Iniciar Prova". '
              'Escolha a quantidade de questões e o nível de dificuldade. '
              'O sistema irá montar uma prova personalizada para você.',
    },
    {
      'question': 'Como visualizar meu histórico de provas?',
      'answer': 'Acesse a aba "Histórico" na barra de navegação inferior. '
          'Lá você encontrará todas as provas realizadas, organizadas por curso, '
          'com notas, percentual de acerto e tempo gasto em cada tentativa.',
    },
    {
      'question': 'Como funciona o sistema de pontuação e gamificação?',
      'answer':
          'Cada questão correta vale pontos que variam conforme a quantidade de questões na prova:\n\n'
              '• 1 a 5 questões: 1,00 pt por acerto\n'
              '• 6 a 10 questões: 1,25 pts por acerto\n'
              '• 11+ questões: 1,50 pts por acerto\n\n'
              'Bônus de tempo: se você acertar 70% ou mais e terminar em até 80% do tempo normal, '
              'ganha pontos extras! Apenas sua melhor pontuação é registrada.',
    },
    {
      'question': 'O que são os níveis e medalhas?',
      'answer': 'Conforme você acumula pontos, sobe de nível:\n\n'
          '• Iniciante (0-100 pts)\n'
          '• Explorador (101-200 pts)\n'
          '• Mestre do Conteúdo (201-300 pts)\n'
          '• Lendário (301+ pts)\n\n'
          'Cada nível tem uma medalha exclusiva exibida no seu perfil e no ranking.',
    },
    {
      'question': 'Posso refazer uma prova?',
      'answer': 'Sim! Você pode refazer qualquer prova quantas vezes quiser. '
          'Cada tentativa fica registrada no seu histórico. '
          'O sistema só atualiza sua pontuação quando você supera o resultado anterior.',
    },
    {
      'question': 'Como funciona o ranking?',
      'answer': 'O ranking é dividido em três categorias:\n\n'
          '• Global: todos os alunos\n'
          '• Por Curso: alunos do mesmo curso\n'
          '• Por Prova: alunos que fizeram a mesma prova\n\n'
          'Os rankings são baseados na temporada atual (semestre letivo) e resetam a cada novo semestre.',
    },
    {
      'question': 'Como alterar meus dados de perfil?',
      'answer': 'Acesse a aba "Perfil" na barra de navegação inferior. '
          'Lá você pode editar seu nome, telefone, bio e foto de perfil.',
    },
    {
      'question': 'Esqueci minha senha. O que fazer?',
      'answer': 'Na tela de login, toque em "Esqueceu sua senha?". '
          'Informe seu e-mail cadastrado e você receberá um link para redefinir sua senha. '
          'Verifique também a pasta de spam.',
    },
    {
      'question': 'O app funciona offline?',
      'answer':
          'Não. O Smart Quiz precisa de conexão com a internet para funcionar, '
              'pois as questões, provas e seu progresso são armazenados no servidor.',
    },
    {
      'question': 'Quem pode criar questões e provas?',
      'answer':
          'Apenas professores e administradores têm permissão para criar questões e montar provas. '
              'Se você é professor e ainda não tem acesso, entre em contato com a administração da UniCV.',
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
            body: SafeArea(
              child: CustomScrollView(
                slivers: [
                  // Header com botão voltar e logo
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.chevron_left,
                              color: AppColors.green,
                              size: 32,
                            ),
                            onPressed: () => context.pop(),
                          ),
                          Expanded(
                            child: Center(
                              child: Image.asset(
                                'assets/images/SmartQuiz.png',
                                height: 200,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                    ),
                  ),

                  // Subtítulo da seção
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 20,
                            decoration: BoxDecoration(
                              color: AppColors.green,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Perguntas Frequentes',
                            style: TextStyle(
                              color: AppColors.primaryDark,
                              fontSize: 18,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: 30),
                  ),

                  // Lista de FAQs
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: DefaultAccordion(
                              title: _faqs[index]['question']!,
                              content: _faqs[index]['answer']!,
                              icon: _getFaqIcon(index),
                            ),
                          );
                        },
                        childCount: _faqs.length,
                      ),
                    ),
                  ),

                  // Rodapé com contato
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.cardFill,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.dividerColor,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.green.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.mail_outline_rounded,
                                color: AppColors.green,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Ainda tem dúvidas?',
                                    style: TextStyle(
                                      color: AppColors.primaryDark,
                                      fontSize: 14,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Entre em contato com a coordenação do seu curso na UniCV.',
                                    style: TextStyle(
                                      color: AppColors.secondaryDark,
                                      fontSize: 12,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getFaqIcon(int index) {
    const icons = [
      Icons.quiz_outlined,
      Icons.history_rounded,
      Icons.stars_rounded,
      Icons.military_tech_outlined,
      Icons.refresh_rounded,
      Icons.leaderboard_outlined,
      Icons.person_outline_rounded,
      Icons.lock_reset_rounded,
      Icons.wifi_off_rounded,
      Icons.school_outlined,
    ];
    return icons[index % icons.length];
  }
}
