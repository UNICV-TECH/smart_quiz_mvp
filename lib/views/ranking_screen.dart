import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/gamification_level.dart';
import '../models/ranking_entry.dart';
import '../repositories/course_repository.dart';
import '../repositories/course_repository_types.dart';
import '../services/session_manager.dart';
import '../ui/components/avatar_with_medal.dart';
import '../ui/theme/app_color.dart';
import '../viewmodels/gamification_view_model.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasViewModel = context.read<GamificationViewModel?>() != null;

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
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 40, 32, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
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
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (!hasViewModel)
                  Expanded(
                    child: _buildEmptyState(
                        'Ranking indisponível no momento.'),
                  )
                else ...[
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x14000000),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: AppColors.green,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicatorPadding: const EdgeInsets.all(4),
                      tabAlignment: TabAlignment.fill,
                      labelColor: Colors.white,
                      unselectedLabelColor: AppColors.secondaryDark,
                      labelStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                      ),
                      labelPadding: EdgeInsets.zero,
                      splashBorderRadius: BorderRadius.circular(10),
                      dividerHeight: 0,
                      tabs: const [
                        Tab(height: 40, text: 'Geral'),
                        Tab(height: 40, text: 'Por Curso'),
                        Tab(height: 40, text: 'Por Prova'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: const [
                        _GlobalRankingTab(),
                        _CourseRankingTab(),
                        _TemplateRankingTab(),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Podium Widget ─────────────────────────────────────────

class _PodiumSection extends StatelessWidget {
  const _PodiumSection({
    required this.ranking,
    required this.currentUserId,
  });

  final List<RankingEntry> ranking;
  final String? currentUserId;

  @override
  Widget build(BuildContext context) {
    final first = ranking.isNotEmpty ? ranking[0] : null;
    final second = ranking.length > 1 ? ranking[1] : null;
    final third = ranking.length > 2 ? ranking[2] : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // 2nd place
            if (second != null)
              Expanded(
                child: _PodiumItem(
                  entry: second,
                  position: 2,
                  podiumHeight: 80,
                  color: const Color(0xFFC0C0C0),
                  isCurrentUser: second.userId == currentUserId,
                ),
              )
            else
              const Expanded(child: SizedBox()),
            const SizedBox(width: 6),
            // 1st place
            if (first != null)
              Expanded(
                child: _PodiumItem(
                  entry: first,
                  position: 1,
                  podiumHeight: 105,
                  color: const Color(0xFFFFD700),
                  isCurrentUser: first.userId == currentUserId,
                ),
              )
            else
              const Expanded(child: SizedBox()),
            const SizedBox(width: 6),
            // 3rd place
            if (third != null)
              Expanded(
                child: _PodiumItem(
                  entry: third,
                  position: 3,
                  podiumHeight: 60,
                  color: const Color(0xFFCD7F32),
                  isCurrentUser: third.userId == currentUserId,
                ),
              )
            else
              const Expanded(child: SizedBox()),
          ],
        ),
      ),
    );
  }
}

class _PodiumItem extends StatelessWidget {
  const _PodiumItem({
    required this.entry,
    required this.position,
    required this.podiumHeight,
    required this.color,
    required this.isCurrentUser,
  });

  final RankingEntry entry;
  final int position;
  final double podiumHeight;
  final Color color;
  final bool isCurrentUser;

  @override
  Widget build(BuildContext context) {
    final level = GamificationLevel.fromPoints(entry.seasonPoints);
    final firstName = entry.userName.split(' ').first;
    final avatarSize = position == 1 ? 52.0 : 44.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Crown for 1st place
        if (position == 1)
          Icon(
            Icons.auto_awesome,
            color: color,
            size: 22,
          ),
        if (position == 1) const SizedBox(height: 2),

        // Avatar
        AvatarWithMedal(
          avatarUrl: entry.avatarUrl,
          medalAsset: level.medalAsset,
          size: avatarSize,
        ),
        const SizedBox(height: 4),

        // Name
        Text(
          firstName,
          style: TextStyle(
            fontSize: position == 1 ? 14 : 13,
            fontWeight: isCurrentUser ? FontWeight.w700 : FontWeight.w600,
            color: isCurrentUser ? AppColors.green : AppColors.primaryDark,
            fontFamily: 'Poppins',
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),

        // Points
        Text(
          '${entry.seasonPoints.toStringAsFixed(0)} pts',
          style: TextStyle(
            fontSize: position == 1 ? 13 : 12,
            fontWeight: FontWeight.w700,
            color: color,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 4),

        // Podium block
        Container(
          width: double.infinity,
          height: podiumHeight,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                color.withAlpha(200),
                color.withAlpha(120),
              ],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            boxShadow: [
              BoxShadow(
                color: color.withAlpha(40),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Position number
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(230),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(20),
                      blurRadius: 4,
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  '$position',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: color,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              if (podiumHeight > 70) ...[
                const SizedBox(height: 2),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    level.label,
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withAlpha(220),
                      fontFamily: 'Poppins',
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ── Ranking List Builder (shared) ─────────────────────────

Widget _buildRankingContent({
  required List<RankingEntry> ranking,
  required String? currentUserId,
  required Future<void> Function() onRefresh,
  RankingEntry? userRankOutside,
}) {
  // Sort by rankPosition ascending (1st, 2nd, 3rd...)
  final sorted = List<RankingEntry>.from(ranking)
    ..sort((a, b) => a.rankPosition.compareTo(b.rankPosition));

  final top3 = sorted.take(3).toList();
  final rest = sorted.length > 3 ? sorted.sublist(3) : <RankingEntry>[];

  return RefreshIndicator(
    onRefresh: onRefresh,
    color: AppColors.green,
    child: CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        // User position card if outside ranking
        if (userRankOutside != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: _buildUserPositionCard(userRankOutside),
            ),
          ),

        // Podium
        if (top3.isNotEmpty)
          SliverToBoxAdapter(
            child: _PodiumSection(
              ranking: sorted,
              currentUserId: currentUserId,
            ),
          ),

        // Divider
        if (rest.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 1,
                      color: const Color(0xFFE2E7DE),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'Demais participantes',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.secondaryDark,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 1,
                      color: const Color(0xFFE2E7DE),
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Rest of the list (4th+)
        if (rest.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final entry = rest[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _RankingListItem(
                      entry: entry,
                      isCurrentUser: entry.userId == currentUserId,
                    ),
                  );
                },
                childCount: rest.length,
              ),
            ),
          ),

        // Bottom spacing if only podium (no rest)
        if (rest.isEmpty)
          const SliverToBoxAdapter(
            child: SizedBox(height: 120),
          ),
      ],
    ),
  );
}

Widget _buildUserPositionCard(RankingEntry entry) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: const Color(0xFFE8F5E9),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.green, width: 2),
    ),
    child: Row(
      children: [
        const Icon(Icons.person, color: AppColors.green, size: 20),
        const SizedBox(width: 8),
        Text(
          'Você: #${entry.rankPosition} — ${entry.seasonPoints.toStringAsFixed(0)} pts',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.green,
            fontFamily: 'Poppins',
          ),
        ),
      ],
    ),
  );
}

// ── Global Ranking Tab ────────────────────────────────────

class _GlobalRankingTab extends StatefulWidget {
  const _GlobalRankingTab();

  @override
  State<_GlobalRankingTab> createState() => _GlobalRankingTabState();
}

class _GlobalRankingTabState extends State<_GlobalRankingTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    final vm = context.read<GamificationViewModel?>();
    if (vm == null) return;
    final userId = context.read<SessionManager>().currentUser?.id;
    if (userId == null) return;

    await vm.loadUserGamification(userId);
    await vm.loadGlobalRanking();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final vm = context.watch<GamificationViewModel?>();
    if (vm == null) {
      return _buildEmptyState('Ranking indisponível.');
    }
    final userId = context.read<SessionManager>().currentUser?.id;

    if (vm.loading && vm.globalRanking.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.green),
      );
    }

    if (vm.error != null && vm.globalRanking.isEmpty) {
      return _buildErrorState(vm.error!, _loadData);
    }

    if (vm.globalRanking.isEmpty) {
      return _buildEmptyState('Nenhum aluno pontuou ainda nesta temporada.');
    }

    final userOutside = _isUserOutsideRanking(vm, userId)
        ? vm.userGlobalRank
        : null;

    return _buildRankingContent(
      ranking: vm.globalRanking,
      currentUserId: userId,
      onRefresh: _loadData,
      userRankOutside: userOutside,
    );
  }

  bool _isUserOutsideRanking(GamificationViewModel vm, String? userId) {
    if (userId == null || vm.userGlobalRank == null) return false;
    return !vm.globalRanking.any((e) => e.userId == userId);
  }
}

// ── Course Ranking Tab ────────────────────────────────────

class _CourseRankingTab extends StatefulWidget {
  const _CourseRankingTab();

  @override
  State<_CourseRankingTab> createState() => _CourseRankingTabState();
}

class _CourseRankingTabState extends State<_CourseRankingTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  List<Course> _courses = [];
  String? _selectedCourseId;
  bool _loadingCourses = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCourses());
  }

  Future<void> _loadCourses() async {
    final courseRepo = context.read<CourseRepository?>();
    if (courseRepo == null) {
      setState(() => _loadingCourses = false);
      return;
    }

    try {
      final courses = await courseRepo.fetchActiveCourses();
      if (mounted) {
        setState(() {
          _courses = courses;
          _loadingCourses = false;
        });
      }
    } catch (e) {
      debugPrint('Failed to load courses: $e');
      if (mounted) setState(() => _loadingCourses = false);
    }
  }

  Future<void> _onCourseSelected(String courseId) async {
    setState(() => _selectedCourseId = courseId);
    final vm = context.read<GamificationViewModel?>();
    if (vm == null) return;
    await vm.loadCourseRanking(courseId);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final vm = context.watch<GamificationViewModel?>();
    if (vm == null) {
      return _buildEmptyState('Ranking indisponível.');
    }
    final userId = context.read<SessionManager>().currentUser?.id;

    if (_loadingCourses) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.green),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E7DE)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCourseId,
                hint: const Text(
                  'Selecione um curso',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 14),
                ),
                isExpanded: true,
                items: _courses.map((c) {
                  return DropdownMenuItem(
                    value: c.id,
                    child: Text(
                      c.title,
                      style:
                          const TextStyle(fontFamily: 'Poppins', fontSize: 14),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) _onCourseSelected(value);
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: _selectedCourseId == null
              ? _buildEmptyState('Selecione um curso para ver o ranking')
              : vm.loading
                  ? const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.green))
                  : vm.courseRanking.isEmpty
                      ? _buildEmptyState(
                          'Nenhum aluno pontuou neste curso.')
                      : _buildRankingContent(
                          ranking: vm.courseRanking,
                          currentUserId: userId,
                          onRefresh: () =>
                              _onCourseSelected(_selectedCourseId!),
                        ),
        ),
      ],
    );
  }
}

// ── Template Ranking Tab ──────────────────────────────────

class _TemplateRankingTab extends StatefulWidget {
  const _TemplateRankingTab();

  @override
  State<_TemplateRankingTab> createState() => _TemplateRankingTabState();
}

class _TemplateRankingTabState extends State<_TemplateRankingTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  String? _selectedTemplateId;
  bool _loadingTemplates = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadTemplates());
  }

  Future<void> _loadTemplates() async {
    final vm = context.read<GamificationViewModel?>();
    if (vm == null) {
      if (mounted) setState(() => _loadingTemplates = false);
      return;
    }
    final userId = context.read<SessionManager>().currentUser?.id;
    if (userId == null) {
      if (mounted) setState(() => _loadingTemplates = false);
      return;
    }
    await vm.loadPublishedTemplates(userId);
    if (mounted) setState(() => _loadingTemplates = false);
  }

  Future<void> _onTemplateSelected(String templateId) async {
    setState(() => _selectedTemplateId = templateId);
    final vm = context.read<GamificationViewModel?>();
    if (vm == null) return;
    await vm.loadTemplateRanking(templateId);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final vm = context.watch<GamificationViewModel?>();
    if (vm == null) {
      return _buildEmptyState('Ranking indisponível.');
    }
    final userId = context.read<SessionManager>().currentUser?.id;

    if (_loadingTemplates) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.green),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E7DE)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedTemplateId,
                hint: const Text(
                  'Selecione uma prova',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 14),
                ),
                isExpanded: true,
                items: vm.publishedTemplates.map((t) {
                  final attempted = vm.attemptedTemplateIds.contains(t.id);
                  return DropdownMenuItem(
                    value: t.id,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            t.name,
                            style: const TextStyle(
                                fontFamily: 'Poppins', fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (attempted)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Participou',
                              style: TextStyle(
                                fontSize: 10,
                                color: Color(0xFF2E7D32),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) _onTemplateSelected(value);
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: _selectedTemplateId == null
              ? _buildEmptyState('Selecione uma prova para ver o ranking')
              : vm.loading
                  ? const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.green))
                  : vm.templateRanking.isEmpty
                      ? _buildEmptyState(
                          'Nenhum aluno pontuou nesta prova.')
                      : _buildRankingContent(
                          ranking: vm.templateRanking,
                          currentUserId: userId,
                          onRefresh: () =>
                              _onTemplateSelected(_selectedTemplateId!),
                        ),
        ),
      ],
    );
  }
}

// ── Shared Widgets ────────────────────────────────────────

class _RankingListItem extends StatelessWidget {
  const _RankingListItem({
    required this.entry,
    required this.isCurrentUser,
  });

  final RankingEntry entry;
  final bool isCurrentUser;

  @override
  Widget build(BuildContext context) {
    final level = GamificationLevel.fromPoints(entry.seasonPoints);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: isCurrentUser ? const Color(0xFFF5FBF5) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isCurrentUser
            ? Border.all(color: AppColors.green, width: 2)
            : Border.all(color: const Color(0xFFE2E7DE), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Position
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFFF5F5F5),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '${entry.rankPosition}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDark,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Avatar with medal
          AvatarWithMedal(
            avatarUrl: entry.avatarUrl,
            medalAsset: level.medalAsset,
            size: 44,
          ),
          const SizedBox(width: 12),

          // Name + level
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.userName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        isCurrentUser ? FontWeight.w700 : FontWeight.w500,
                    color: AppColors.primaryDark,
                    fontFamily: 'Poppins',
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  level.label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.secondaryDark,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),

          // Points
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.green.withAlpha(20),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${entry.seasonPoints.toStringAsFixed(0)} pts',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.green,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildEmptyState(String message) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 48,
            color: AppColors.secondaryDark.withAlpha((0.5 * 255).round()),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color:
                  AppColors.secondaryDark.withAlpha((0.7 * 255).round()),
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildErrorState(String error, VoidCallback onRetry) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.red),
          const SizedBox(height: 16),
          const Text(
            'Erro ao carregar ranking',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryDark,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: onRetry,
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    ),
  );
}
