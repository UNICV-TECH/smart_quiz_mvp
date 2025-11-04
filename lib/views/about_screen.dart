import 'package:flutter/material.dart';
import '../ui/theme/app_color.dart';
import '../constants/app_strings.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

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
                AppStrings.aboutTitle,
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

                    // Logo do app
                    Center(
                      child: Image.asset(
                        'assets/images/logo_color.png',
                        width: 120,
                        height: 50,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 120,
                            height: 50,
                            decoration: BoxDecoration(
                              color: AppColors.green,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Center(
                              child: Text(
                                'Smart Quiz',
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Versão
                    Center(
                      child: Text(
                        'Versão 1.0.0',
                        style: TextStyle(
                          color: AppColors.secondaryDark,
                          fontSize: 14,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Título da seção
                    Text(
                      'Sobre o Desenvolvimento',
                      style: TextStyle(
                        color: AppColors.green,
                        fontSize: 20,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Conteúdo
                    _buildContentCard(
                      icon: Icons.lightbulb_outline,
                      iconColor: AppColors.orange,
                      title: 'A Ideia',
                      content:
                          'O Smart Quiz nasceu da necessidade de ajudar estudantes a se prepararem melhor para suas provas. A ideia era criar uma plataforma simples, mas eficiente, onde os alunos pudessem praticar e acompanhar sua evolução.',
                    ),

                    const SizedBox(height: 16),

                    _buildContentCard(
                      icon: Icons.code,
                      iconColor: AppColors.green,
                      title: 'Tecnologias',
                      content:
                          'Desenvolvido com Flutter, o app foi construído pensando em performance e experiência do usuário. A arquitetura foi planejada para ser escalável e fácil de manter, utilizando as melhores práticas do mercado.',
                    ),

                    const SizedBox(height: 16),

                    _buildContentCard(
                      icon: Icons.people_outline,
                      iconColor: AppColors.indigo,
                      title: 'O Processo',
                      content:
                          'Foi um desafio emocionante! Desde o design das telas até a implementação das funcionalidades, cada etapa foi pensada para proporcionar a melhor experiência de estudo. O foco sempre foi na simplicidade e eficiência.',
                    ),

                    const SizedBox(height: 16),

                    _buildContentCard(
                      icon: Icons.rocket_launch,
                      iconColor: AppColors.red,
                      title: 'Próximos Passos',
                      content:
                          'O projeto continua em evolução! Estamos trabalhando em novas funcionalidades, mais matérias e recursos que vão tornar sua experiência de estudo ainda melhor. Fique ligado nas atualizações!',
                    ),

                    const SizedBox(height: 30),

                    // Rodapé
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'Feito com',
                            style: TextStyle(
                              color: AppColors.secondaryDark,
                              fontSize: 14,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.favorite,
                                color: AppColors.red,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'e muito',
                                style: TextStyle(
                                  color: AppColors.secondaryDark,
                                  fontSize: 14,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.coffee,
                                color: AppColors.orange,
                                size: 20,
                              ),
                            ],
                          ),
                        ],
                      ),
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

  Widget _buildContentCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String content,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: AppColors.primaryDark,
                    fontSize: 18,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              color: AppColors.secondaryDark,
              fontSize: 14,
              fontFamily: 'Poppins',
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
