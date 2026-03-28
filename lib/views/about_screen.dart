import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../ui/theme/app_color.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen>
    with TickerProviderStateMixin {
  final Set<int> _revealedCards = {};
  late List<AnimationController> _controllers;
  late List<Animation<double>> _scaleAnimations;

  final List<_AchievementCard> _cards = [
    _AchievementCard(
      icon: Icons.lightbulb,
      color: Color(0xFFEF992D),
      badge: 'ORIGEM',
      title: 'A Ideia',
      teaser: 'Toque para descobrir como tudo começou...',
      revealed:
          'O Smart Quiz nasceu da vontade de transformar a preparação para provas em algo mais dinâmico e divertido. Chega de PDFs infinitos!',
    ),
    _AchievementCard(
      icon: Icons.school,
      color: Color(0xFF3B5C34),
      badge: 'MISSÃO',
      title: 'Projeto UniCV',
      teaser: 'Toque para conhecer nossa missão...',
      revealed:
          'Projeto de extensão do Centro Universitário UniCV, feito para conectar professores e alunos através de quizzes inteligentes.',
    ),
    _AchievementCard(
      icon: Icons.emoji_events,
      color: Color(0xFFD9503F),
      badge: 'GAMIFICAÇÃO',
      title: 'Mais que um Quiz',
      teaser: 'Toque para ver o que te espera...',
      revealed:
          'Pontos, níveis, medalhas e ranking! Do Iniciante ao Lendário — cada prova te aproxima do topo. Será que você chega lá?',
    ),
    _AchievementCard(
      icon: Icons.auto_awesome,
      color: Color(0xFF3F51B5),
      badge: 'CURIOSIDADE',
      title: 'Você Sabia?',
      teaser: 'Toque para uma curiosidade secreta...',
      revealed:
          'O primeiro protótipo do Smart Quiz tinha apenas 3 telas. Hoje são mais de 20 telas, 14 models e um sistema completo de gamificação!',
    ),
    _AchievementCard(
      icon: Icons.rocket_launch,
      color: Color(0xFFEF992D),
      badge: 'FUTURO',
      title: 'Próximos Níveis',
      teaser: 'Toque para espiar o que vem por aí...',
      revealed:
          'Novos cursos, modo desafio entre amigos e conquistas especiais estão no radar. A evolução não para!',
    ),
    _AchievementCard(
      icon: Icons.favorite,
      color: Color(0xFFD9503F),
      badge: 'CRÉDITOS',
      title: 'Quem Fez?',
      teaser: 'Toque para conhecer o time...',
      revealed:
          'Desenvolvido com dedicação pelo time UniCV Tech — estudantes e professores unidos pela inovação na educação.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      _cards.length,
      (i) => AnimationController(
        duration: const Duration(milliseconds: 500),
        vsync: this,
      ),
    );
    _scaleAnimations = _controllers.map((c) {
      return Tween<double>(begin: 0.95, end: 1.0).animate(
        CurvedAnimation(parent: c, curve: Curves.elasticOut),
      );
    }).toList();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _toggleCard(int index) {
    setState(() {
      if (_revealedCards.contains(index)) {
        _revealedCards.remove(index);
      } else {
        _revealedCards.add(index);
        _controllers[index].forward(from: 0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final unlockedCount = _revealedCards.length;
    final totalCount = _cards.length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: Stack(
        children: [
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
                  // Header
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
                                errorBuilder: (context, error, stackTrace) {
                                  return Text(
                                    'Smart Quiz',
                                    style: TextStyle(
                                      color: AppColors.green,
                                      fontSize: 24,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                    ),
                  ),

                  // Progresso de descoberta
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.shadow,
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  unlockedCount == totalCount
                                      ? 'Tudo desbloqueado!'
                                      : 'Descubra o Smart Quiz',
                                  style: TextStyle(
                                    color: AppColors.primaryDark,
                                    fontSize: 15,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: unlockedCount == totalCount
                                        ? AppColors.green
                                            .withValues(alpha: 0.1)
                                        : AppColors.orange
                                            .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '$unlockedCount/$totalCount',
                                    style: TextStyle(
                                      color: unlockedCount == totalCount
                                          ? AppColors.green
                                          : AppColors.orange,
                                      fontSize: 13,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: unlockedCount / totalCount,
                                backgroundColor: AppColors.greyLight,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  unlockedCount == totalCount
                                      ? AppColors.green
                                      : AppColors.orange,
                                ),
                                minHeight: 8,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              unlockedCount == totalCount
                                  ? 'Parabéns! Você descobriu tudo sobre o Smart Quiz 🎉'
                                  : 'Toque nos cards abaixo para revelar cada conquista',
                              style: TextStyle(
                                color: AppColors.secondaryDark,
                                fontSize: 12,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 20)),

                  // Cards de achievement
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildAchievementCard(index),
                          );
                        },
                        childCount: _cards.length,
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 20)),

                  // Rodapé
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                      child: Column(
                        children: [
                          Text(
                            'Versão 1.0.0',
                            style: TextStyle(
                              color: AppColors.secondaryDark,
                              fontSize: 13,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Feito com',
                                style: TextStyle(
                                  color: AppColors.secondaryDark,
                                  fontSize: 14,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(Icons.favorite,
                                  color: AppColors.red, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                'e muito',
                                style: TextStyle(
                                  color: AppColors.secondaryDark,
                                  fontSize: 14,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(Icons.coffee,
                                  color: AppColors.orange, size: 18),
                            ],
                          ),
                        ],
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

  Widget _buildAchievementCard(int index) {
    final card = _cards[index];
    final isRevealed = _revealedCards.contains(index);

    return GestureDetector(
      onTap: () => _toggleCard(index),
      child: ScaleTransition(
        scale: isRevealed
            ? _scaleAnimations[index]
            : const AlwaysStoppedAnimation(1.0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isRevealed
                ? card.color.withValues(alpha: 0.06)
                : AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isRevealed
                  ? card.color.withValues(alpha: 0.3)
                  : AppColors.greyLight,
              width: isRevealed ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isRevealed
                    ? card.color.withValues(alpha: 0.12)
                    : AppColors.shadow,
                blurRadius: isRevealed ? 12 : 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Ícone
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isRevealed
                          ? card.color.withValues(alpha: 0.15)
                          : AppColors.greyShade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      card.icon,
                      color: isRevealed
                          ? card.color
                          : AppColors.secondaryDark,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Badge
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 300),
                          style: TextStyle(
                            color: isRevealed
                                ? card.color
                                : AppColors.secondaryDark,
                            fontSize: 10,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                          child: Text(card.badge),
                        ),
                        const SizedBox(height: 2),
                        // Título
                        Text(
                          card.title,
                          style: TextStyle(
                            color: AppColors.primaryDark,
                            fontSize: 16,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Indicador
                  AnimatedRotation(
                    turns: isRevealed ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.expand_more,
                      color: isRevealed
                          ? card.color
                          : AppColors.secondaryDark,
                      size: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Conteúdo
              AnimatedCrossFade(
                firstChild: Text(
                  card.teaser,
                  style: TextStyle(
                    color: AppColors.secondaryDark,
                    fontSize: 13,
                    fontFamily: 'Poppins',
                    fontStyle: FontStyle.italic,
                  ),
                ),
                secondChild: Text(
                  card.revealed,
                  style: TextStyle(
                    color: AppColors.primaryDark,
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    height: 1.5,
                  ),
                ),
                crossFadeState: isRevealed
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 300),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AchievementCard {
  final IconData icon;
  final Color color;
  final String badge;
  final String title;
  final String teaser;
  final String revealed;

  const _AchievementCard({
    required this.icon,
    required this.color,
    required this.badge,
    required this.title,
    required this.teaser,
    required this.revealed,
  });
}
