import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/gamification_level.dart';
import '../../models/ranking_entry.dart';
import '../../repositories/gamification_repository.dart';
import '../../repositories/teacher_repository.dart';
import '../../services/session_manager.dart';
import '../../ui/components/avatar_with_medal.dart';
import '../../ui/theme/app_color.dart';
import '../../viewmodels/teacher/teacher_gamification_view_model.dart';

class TeacherGamificationScreen extends StatelessWidget {
  const TeacherGamificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gamRepo = context.read<GamificationRepository?>();
    final teacherRepo = context.read<TeacherRepository?>();
    final userId = context.read<SessionManager>().currentUser?.id;

    if (gamRepo == null || teacherRepo == null || userId == null) {
      return const Center(
        child: Text(
          'Gamificação não disponível.',
          style: TextStyle(fontFamily: 'Poppins', fontSize: 16),
        ),
      );
    }

    return ChangeNotifierProvider(
      create: (_) => TeacherGamificationViewModel(
        gamificationRepository: gamRepo,
        teacherRepository: teacherRepo,
        teacherId: userId,
      )..initialize(),
      child: const _TeacherGamificationBody(),
    );
  }
}

class _TeacherGamificationBody extends StatelessWidget {
  const _TeacherGamificationBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TeacherGamificationViewModel>();

    return Container(
      color: const Color(0xFFF9F9F9),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Padding(
              padding: EdgeInsets.fromLTRB(32, 24, 32, 0),
              child: Text(
                'Gamificação',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(32, 4, 32, 16),
              child: Text(
                'Ranking e estatísticas dos seus templates',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.secondaryDark,
                  fontFamily: 'Poppins',
                ),
              ),
            ),

            // Template dropdown
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E7DE)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: vm.selectedTemplate?.id,
                    hint: const Text(
                      'Selecione um template',
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 14),
                    ),
                    isExpanded: true,
                    items: vm.templates.map((t) {
                      return DropdownMenuItem(
                        value: t.id,
                        child: Text(
                          t.name,
                          style: const TextStyle(
                              fontFamily: 'Poppins', fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        final template = vm.templates.firstWhere(
                          (t) => t.id == value,
                        );
                        vm.selectTemplate(template);
                      }
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Content
            Expanded(
              child: vm.loading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFF2E7D32)))
                  : vm.selectedTemplate == null
                      ? const Center(
                          child: Text(
                            'Selecione um template para ver as estatísticas.',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              color: AppColors.secondaryDark,
                            ),
                          ),
                        )
                      : _buildContent(context, vm),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, TeacherGamificationViewModel vm) {
    if (vm.templateRanking.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.emoji_events_outlined,
                size: 48, color: AppColors.secondaryDark),
            SizedBox(height: 16),
            Text(
              'Nenhum aluno realizou esta prova ainda.',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: AppColors.secondaryDark,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Statistics cards
          _buildStatsRow(vm),
          const SizedBox(height: 24),

          // Ranking list
          const Text(
            'Ranking dos Alunos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryDark,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 12),
          ...vm.templateRanking.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildRankingItem(entry),
              )),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildStatsRow(TeacherGamificationViewModel vm) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildStatCard(
          'Participantes',
          vm.totalParticipants.toString(),
          Icons.people,
          const Color(0xFF1565C0),
        ),
        _buildStatCard(
          'Média de Pontos',
          vm.averagePoints.toStringAsFixed(1),
          Icons.analytics,
          const Color(0xFF2E7D32),
        ),
        _buildStatCard(
          'Melhor Pontuação',
          vm.bestScore.toStringAsFixed(1),
          Icons.emoji_events,
          const Color(0xFFFFA000),
        ),
        _buildStatCard(
          'Menor Pontuação',
          vm.worstScore.toStringAsFixed(1),
          Icons.trending_down,
          const Color(0xFFD32F2F),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E7DE)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
              fontFamily: 'Poppins',
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.secondaryDark,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankingItem(RankingEntry entry) {
    final level = GamificationLevel.fromPoints(entry.seasonPoints);
    final isTop3 = entry.rankPosition <= 3;

    Color? positionColor;
    if (entry.rankPosition == 1) positionColor = const Color(0xFFFFD700);
    if (entry.rankPosition == 2) positionColor = const Color(0xFFC0C0C0);
    if (entry.rankPosition == 3) positionColor = const Color(0xFFCD7F32);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E7DE)),
      ),
      child: Row(
        children: [
          // Position
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isTop3
                  ? positionColor?.withAlpha(40)
                  : const Color(0xFFF5F5F5),
              shape: BoxShape.circle,
              border:
                  isTop3 ? Border.all(color: positionColor!, width: 2) : null,
            ),
            alignment: Alignment.center,
            child: Text(
              '${entry.rankPosition}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isTop3 ? positionColor : AppColors.primaryDark,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Avatar
          AvatarWithMedal(
            avatarUrl: entry.avatarUrl,
            medalAsset: level.medalAsset,
            size: 36,
          ),
          const SizedBox(width: 12),

          // Name
          Expanded(
            child: Text(
              entry.userName,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Points
          Text(
            '${entry.seasonPoints.toStringAsFixed(1)} pts',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isTop3 ? positionColor : AppColors.green,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}
