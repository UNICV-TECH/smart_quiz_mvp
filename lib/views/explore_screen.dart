import 'dart:ui';

import 'package:flutter/material.dart';
import '../ui/theme/app_color.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

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
          SafeArea(
            bottom: false,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ranking',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Compare seu desempenho com a comunidade UNICV',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.secondaryDark
                          .withAlpha((0.7 * 255).round()),
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 32),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Container(
                          constraints: const BoxConstraints.expand(),
                          decoration: BoxDecoration(
                            color:
                                AppColors.white.withAlpha((0.65 * 255).round()),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: AppColors.primaryDark
                                  .withAlpha((0.08 * 255).round()),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: AppColors.green
                                          .withAlpha((0.15 * 255).round()),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.emoji_events_outlined,
                                      color: AppColors.green,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      'Ranking em construção',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primaryDark,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Estamos preparando uma experiência completa de ranking, com medalhas, conquistas e desafios semanais. Até lá, confira como será:',
                                style: TextStyle(
                                  fontSize: 13,
                                  height: 1.45,
                                  color: AppColors.secondaryDark
                                      .withAlpha((0.85 * 255).round()),
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              const SizedBox(height: 32),
                              Expanded(
                                child: Opacity(
                                  opacity: 0.55,
                                  child: ListView.separated(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) {
                                      final positions = [1, 2, 3];
                                      final widths = [0.95, 0.8, 0.68];
                                      return _RankingSkeletonItem(
                                        position: positions[index],
                                        barWidthFactor: widths[index],
                                      );
                                    },
                                    separatorBuilder: (context, index) =>
                                        const SizedBox(height: 16),
                                    itemCount: 3,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryDark
                                      .withAlpha((0.08 * 255).round()),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.lock_outline,
                                      color: AppColors.primaryDark,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Mantenha seus estudos em dia para desbloquear o ranking e competir com outros alunos.',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: AppColors.primaryDark
                                              .withAlpha((0.85 * 255).round()),
                                          fontFamily: 'Poppins',
                                        ),
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
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RankingSkeletonItem extends StatelessWidget {
  final int position;
  final double barWidthFactor;

  const _RankingSkeletonItem({
    required this.position,
    required this.barWidthFactor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.primaryDark.withAlpha((0.14 * 255).round()),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            position.toString(),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDark,
              fontFamily: 'Poppins',
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  AppColors.secondaryDark.withAlpha((0.12 * 255).round()),
                  AppColors.secondaryDark.withAlpha((0.05 * 255).round()),
                ],
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: barWidthFactor,
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppColors.green.withAlpha((0.7 * 255).round()),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
