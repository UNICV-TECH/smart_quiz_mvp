import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/gamification_level.dart';
import '../repositories/gamification_repository.dart';
import '../services/session_manager.dart';
import '../ui/theme/app_color.dart';
import '../constants/app_strings.dart';
import '../ui/components/avatar_with_medal.dart';
import '../viewmodels/gamification_view_model.dart';
import '../viewmodels/profile_view_model.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileViewModel _profileVm;
  GamificationViewModel? _gamVm;

  @override
  void initState() {
    super.initState();
    _profileVm = ProfileViewModel()..loadUserProfile();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_gamVm == null) {
      final gamRepo = context.read<GamificationRepository?>();
      if (gamRepo != null) {
        final userId = context.read<SessionManager>().currentUser?.id;
        _gamVm = GamificationViewModel(repository: gamRepo);
        if (userId != null) {
          _gamVm!.loadUserGamification(userId);
          _gamVm!.loadSeasonHistory(userId);
        }
      }
    }
  }

  @override
  void dispose() {
    _profileVm.dispose();
    _gamVm?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ProfileViewModel>.value(value: _profileVm),
        if (_gamVm != null)
          ChangeNotifierProvider<GamificationViewModel>.value(value: _gamVm!),
      ],
      child: const _ProfileViewBody(),
    );
  }
}

class _ProfileViewBody extends StatefulWidget {
  const _ProfileViewBody();

  @override
  State<_ProfileViewBody> createState() => _ProfileViewBodyState();
}

class _ProfileViewBodyState extends State<_ProfileViewBody>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  // Name editing state
  bool _isEditingName = false;
  bool _isSavingName = false;
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  void _startEditing(String currentName) {
    setState(() {
      _isEditingName = true;
      _nameController.text = currentName;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _nameFocusNode.requestFocus();
      _nameController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _nameController.text.length,
      );
    });
  }

  void _cancelEditing() {
    setState(() => _isEditingName = false);
    _nameFocusNode.unfocus();
  }

  Future<void> _saveName(ProfileViewModel viewModel) async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) {
      _showSnackBar('Nome não pode estar vazio', isError: true);
      return;
    }
    if (newName == viewModel.user?.name) {
      _cancelEditing();
      return;
    }
    setState(() => _isSavingName = true);
    try {
      final success = await viewModel.updateUserName(newName);
      if (success) {
        setState(() => _isEditingName = false);
        _showSnackBar('Nome atualizado com sucesso!');
      } else {
        _showSnackBar('Erro ao atualizar nome.', isError: true);
      }
    } catch (_) {
      _showSnackBar('Erro ao atualizar nome.', isError: true);
    } finally {
      setState(() => _isSavingName = false);
      _nameFocusNode.unfocus();
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.red : AppColors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ProfileViewModel>();

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      body: Builder(
        builder: (context) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (viewModel.errorMessage != null) {
            return Center(
              child: Text(
                viewModel.errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          final user = viewModel.user;
          if (user == null) {
            return const Center(
              child: Text(
                'Usuário não encontrado.',
                style: TextStyle(fontFamily: 'Poppins', color: Colors.black54),
              ),
            );
          }

          return FadeTransition(
            opacity: _fadeIn,
            child: SlideTransition(
              position: _slideUp,
              child: CustomScrollView(
                slivers: [
                  // Header com gradiente
                  SliverToBoxAdapter(
                    child: _buildHeader(context, viewModel),
                  ),
                  // Stats cards
                  SliverToBoxAdapter(
                    child: _buildStatsRow(context),
                  ),
                  // Level progress
                  SliverToBoxAdapter(
                    child: _buildLevelProgress(context),
                  ),
                  // Season history
                  SliverToBoxAdapter(
                    child: _buildSeasonHistory(context),
                  ),
                  // Menu items
                  SliverToBoxAdapter(
                    child: _buildMenuSection(context),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 100),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ProfileViewModel viewModel) {
    final user = viewModel.user!;
    final gamVm = context.watch<GamificationViewModel?>();
    final medalAsset = gamVm != null && gamVm.userPoints > 0
        ? gamVm.userLevel.medalAsset
        : null;
    final level = gamVm?.userLevel;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.headerGradientStart,
            AppColors.headerGradientMid,
            AppColors.headerGradientEnd,
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
          child: _isEditingName
              ? Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AvatarWithMedal(
                          avatarUrl: user.avatarUrl,
                          medalAsset: medalAsset,
                          size: 80,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildNameEditor(viewModel),
                  ],
                )
              : Column(
                  children: [
                    // Avatar + Nome/Email lado a lado, centralizado
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        AvatarWithMedal(
                          avatarUrl: user.avatarUrl,
                          medalAsset: medalAsset,
                          size: 80,
                        ),
                        const SizedBox(width: 18),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Nome com botao editar
                              GestureDetector(
                                onTap: () => _startEditing(user.name),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        user.name,
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontFamily: 'Poppins',
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.white.withValues(alpha: 0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.edit,
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Email
                              Text(
                                user.email,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontFamily: 'Poppins',
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              // Badge do nivel abaixo do email
                              if (level != null) ...[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color:
                                          Colors.white.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.military_tech,
                                        size: 16,
                                        color: AppColors.goldLight,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        level.label,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildNameEditor(ProfileViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _nameController,
              focusNode: _nameFocusNode,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              enabled: !_isSavingName,
              onSubmitted: (_) => _saveName(viewModel),
            ),
          ),
          const SizedBox(width: 8),
          _isSavingName
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : IconButton(
                  onPressed: () => _saveName(viewModel),
                  icon:
                      const Icon(Icons.check_circle, color: Color(0xFF81C784)),
                  iconSize: 28,
                ),
          IconButton(
            onPressed: _cancelEditing,
            icon:
                Icon(Icons.cancel, color: Colors.white.withValues(alpha: 0.7)),
            iconSize: 28,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    final gamVm = context.watch<GamificationViewModel?>();
    if (gamVm == null || gamVm.activeSeason == null) {
      return const SizedBox.shrink();
    }

    final points = gamVm.userPoints;
    final rank = gamVm.userGlobalRank;
    final totalAttempts = rank?.totalAttempts ?? 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              icon: Icons.star_rounded,
              iconColor: AppColors.statGold,
              label: 'Pontos',
              value: points.toStringAsFixed(0),
              bgColor: AppColors.goldBgStart,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: Icons.emoji_events_rounded,
              iconColor: AppColors.green1,
              label: 'Ranking',
              value: rank != null ? '#${rank.rankPosition}' : '-',
              bgColor: AppColors.gamificationBgLight,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: Icons.quiz_rounded,
              iconColor: AppColors.statBlue,
              label: 'Provas',
              value: '$totalAttempts',
              bgColor: AppColors.statBgBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 24, color: iconColor),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textMediumGrey,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelProgress(BuildContext context) {
    final gamVm = context.watch<GamificationViewModel?>();
    if (gamVm == null || gamVm.activeSeason == null) {
      return const SizedBox.shrink();
    }

    final level = gamVm.userLevel;
    final points = gamVm.userPoints;
    final progress = level.progressInLevel(points);
    final nextLevel = _getNextLevel(level);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.gamificationBgLight, AppColors.gamificationBgPale],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.gamificationBorder),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Medalha atual
                Image.asset(
                  level.medalAsset,
                  width: 56,
                  height: 56,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.military_tech,
                    size: 56,
                    color: AppColors.green1,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        level.label,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.gamificationDark,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        level.pointsLabel(points),
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.gamificationOlive,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
                // Medalha proxima (se houver)
                if (nextLevel != null) ...[
                  Column(
                    children: [
                      Opacity(
                        opacity: 0.4,
                        child: Image.asset(
                          nextLevel.medalAsset,
                          width: 40,
                          height: 40,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.military_tech,
                            size: 40,
                            color: AppColors.greyShade400,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        nextLevel.label,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textGrey,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            // Barra de progresso customizada
            Stack(
              children: [
                Container(
                  height: 14,
                  decoration: BoxDecoration(
                    color: AppColors.gamificationBorder,
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: progress.clamp(0.02, 1.0),
                  child: Container(
                    height: 14,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.gamificationBright, AppColors.gamificationDark],
                      ),
                      borderRadius: BorderRadius.circular(7),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.shadowGreen,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(progress * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gamificationDark,
                    fontFamily: 'Poppins',
                  ),
                ),
                Text(
                  'Temporada ${gamVm.activeSeason!.name}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.gamificationOlive,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  GamificationLevel? _getNextLevel(GamificationLevel current) {
    switch (current) {
      case GamificationLevel.iniciante:
        return GamificationLevel.explorador;
      case GamificationLevel.explorador:
        return GamificationLevel.mestreDoConteudo;
      case GamificationLevel.mestreDoConteudo:
        return GamificationLevel.lendario;
      case GamificationLevel.lendario:
        return null;
    }
  }

  Widget _buildSeasonHistory(BuildContext context) {
    final gamVm = context.watch<GamificationViewModel?>();
    if (gamVm == null || gamVm.seasonHistory.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.history_rounded, size: 20, color: AppColors.gamificationOlive),
              SizedBox(width: 8),
              Text(
                'Histórico de Temporadas',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...gamVm.seasonHistory.map((entry) {
            final entryLevel = GamificationLevel.fromPoints(entry.totalPoints);
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: entry.isActive
                    ? Border.all(color: AppColors.green, width: 1.5)
                    : Border.all(color: AppColors.borderLight),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadowSmall,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Image.asset(
                    entryLevel.medalAsset,
                    width: 44,
                    height: 44,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.military_tech,
                      size: 44,
                      color: AppColors.green1,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Temporada ${entry.seasonName}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded,
                                size: 14, color: AppColors.statGold),
                            const SizedBox(width: 4),
                            Text(
                              '${entry.totalPoints.toStringAsFixed(0)} pts',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.greyText,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Icon(Icons.leaderboard_rounded,
                                size: 14, color: AppColors.statBlue),
                            const SizedBox(width: 4),
                            Text(
                              '#${entry.rankPosition}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.greyText,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (entry.isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.gamificationBgLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Atual',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.gamificationDark,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.help_outline_rounded,
            title: AppStrings.help,
            subtitle: 'Dúvidas e suporte',
            onTap: () => context.push('/help'),
          ),
          const SizedBox(height: 10),
          _buildMenuItem(
            icon: Icons.info_outline_rounded,
            title: AppStrings.about,
            subtitle: 'Sobre o aplicativo',
            onTap: () => context.push('/about'),
          ),
          const SizedBox(height: 20),
          _buildLogoutButton(context),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadowMedium,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.green, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontSize: 15,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textSubtle,
                        fontSize: 12,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.greyShade400,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => _handleLogout(context),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.red.withValues(alpha: 0.2)),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadowMedium,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.logout_rounded,
                    color: AppColors.red, size: 22),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Text(
                  'Sair da conta',
                  style: TextStyle(
                    color: AppColors.red,
                    fontSize: 15,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final authService = context.read<AuthService>();

    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text(
            'Confirmar saída',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Tem certeza que deseja sair?',
            style: TextStyle(fontFamily: 'Poppins'),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancelar',
                style: TextStyle(
                  color: AppColors.secondaryDark,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await authService.signOut();
              },
              child: const Text(
                'Sair',
                style: TextStyle(
                  color: AppColors.red,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
