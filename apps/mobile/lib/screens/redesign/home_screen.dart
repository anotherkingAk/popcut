import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/popcut_theme.dart';
import '../../widgets/redesign/popcut_search_bar.dart';
import '../../widgets/redesign/popcut_card.dart';
import '../../widgets/redesign/popcut_section_header.dart';
import '../../widgets/redesign/popcut_horizontal_list.dart';
import '../../widgets/redesign/popcut_skeleton.dart';
import '../../widgets/redesign/popcut_scaffold.dart';
import '../../widgets/redesign/popcut_bottom_nav.dart';
import '../../services/project_service.dart';
import '../../providers/app_provider.dart';

class HomeScreenRedesign extends StatefulWidget {
  final void Function(String route, {Map<String, dynamic>? args}) onNavigate;

  const HomeScreenRedesign({super.key, required this.onNavigate});

  @override
  State<HomeScreenRedesign> createState() => _HomeScreenRedesignState();
}

class _HomeScreenRedesignState extends State<HomeScreenRedesign> {
  int _navIndex = 0;
  bool _isLoading = true;

  final _navItems = const [
    BottomNavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
      route: '/home',
    ),
    BottomNavItem(
      icon: Icons.grid_view_outlined,
      activeIcon: Icons.grid_view_rounded,
      label: 'Templates',
      route: '/templates',
    ),
    BottomNavItem(
      icon: Icons.add_rounded,
      activeIcon: Icons.add_rounded,
      label: '',
      route: 'create',
    ),
    BottomNavItem(
      icon: Icons.folder_outlined,
      activeIcon: Icons.folder_rounded,
      label: 'Projects',
      route: '/projects',
    ),
    BottomNavItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person_rounded,
      label: 'Profile',
      route: '/settings',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _simulateLoading();
  }

  Future<void> _simulateLoading() async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) setState(() => _isLoading = false);
  }

  void _onNavTap(int index) {
    setState(() => _navIndex = index);
    final item = _navItems[index];
    if (item.route == 'create') {
      final projects = context.read<ProjectService>();
      final project = projects.createProject('Untitled Project');
      widget.onNavigate('/editor', args: {'projectId': project.id});
    } else {
      widget.onNavigate(item.route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AppProvider>();
    final projects = context.watch<ProjectService>();

    return PopCutScaffold(
      currentNavIndex: _navIndex,
      onNavTap: _onNavTap,
      navItems: _navItems,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildAppBar(auth)),
          SliverToBoxAdapter(child: _buildHeroSearch()),
          SliverToBoxAdapter(child: const SizedBox(height: 24)),
          if (_isLoading)
            SliverToBoxAdapter(child: _buildSkeletons())
          else ...[
            SliverToBoxAdapter(
              child: _buildSection(
                title: 'Continue Editing',
                onSeeAll: () => widget.onNavigate('/projects'),
                child: _buildProjectStrip(projects),
              ),
            ),
            SliverToBoxAdapter(child: const SizedBox(height: 24)),
            SliverToBoxAdapter(
              child: _buildSection(
                title: 'Trending Templates',
                onSeeAll: () => widget.onNavigate('/templates'),
                child: _buildTemplateStrip(),
              ),
            ),
            SliverToBoxAdapter(child: const SizedBox(height: 24)),
            SliverToBoxAdapter(
              child: _buildSection(
                title: 'AI Tools',
                child: _buildAiToolsGrid(),
              ),
            ),
            SliverToBoxAdapter(child: const SizedBox(height: 24)),
            SliverToBoxAdapter(
              child: _buildSection(
                title: 'Popular Effects',
                child: _buildEffectsStrip(),
              ),
            ),
            SliverToBoxAdapter(child: const SizedBox(height: 24)),
            SliverToBoxAdapter(
              child: _buildSection(
                title: 'Recent Projects',
                onSeeAll: () => widget.onNavigate('/projects'),
                child: _buildRecentStrip(projects),
              ),
            ),
          ],
          SliverToBoxAdapter(child: const SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildAppBar(AppProvider auth) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [PopCutColors.primary, Color(0xFF00B4D8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                (auth.user?.displayName ?? 'U')[0].toUpperCase(),
                style: const TextStyle(
                  color: PopCutColors.background,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back,',
                style: PopCutTypography.caption.copyWith(fontSize: 11),
              ),
              Text(
                auth.user?.displayName ?? 'Creator',
                style: PopCutTypography.title,
              ),
            ],
          ),
          const Spacer(),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: PopCutColors.glass(),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: PopCutColors.glassBorder(),
                width: 0.5,
              ),
            ),
            child: IconButton(
              icon: const Icon(Icons.notifications_outlined, size: 20),
              color: PopCutColors.textSecondary,
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSearch() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: PopCutSearchBar(
        hintText: 'Search anything...',
        onTap: () {},
      ),
    );
  }

  Widget _buildSection({
    required String title,
    VoidCallback? onSeeAll,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 14),
          child: PopCutSectionHeader(
            title: title,
            actionLabel: 'See All',
            onActionTap: onSeeAll,
          ),
        ),
        child,
      ],
    );
  }

  Widget _buildProjectStrip(ProjectService projectService) {
    final projects = projectService.recentProjects;
    return PopCutHorizontalList(
      itemCount: projects.isEmpty ? 1 : projects.length,
      itemWidth: 180,
      itemHeight: 140,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, i) {
        if (projects.isEmpty) {
          return PopCutGlassCard(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.movie_creation_outlined,
                      size: 28, color: PopCutColors.textMuted),
                  const SizedBox(height: 8),
                  Text('No recent projects',
                      style: PopCutTypography.caption),
                ],
              ),
            ),
          );
        }
        final p = projects[i];
        return PopCutGlassCard(
          padding: EdgeInsets.zero,
          onTap: () => widget.onNavigate('/editor',
              args: {'projectId': p.id}),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: PopCutColors.primary.withValues(alpha: 0.08),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Center(
                    child: Icon(Icons.play_circle_outlined,
                        size: 32, color: PopCutColors.primary.withValues(alpha: 0.4)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.name,
                        style: PopCutTypography.captionBold,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text('${p.duration.inSeconds}s',
                        style: PopCutTypography.caption),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTemplateStrip() {
    final templates = [
      {'name': 'Wedding', 'color': PopCutColors.primary, 'emoji': '💍'},
      {'name': 'Travel', 'color': const Color(0xFF22C55E), 'emoji': '✈️'},
      {'name': 'Gaming', 'color': const Color(0xFF7C3AED), 'emoji': '🎮'},
      {'name': 'Tutorial', 'color': const Color(0xFFF59E0B), 'emoji': '📚'},
      {'name': 'Vlog', 'color': const Color(0xFFEF4444), 'emoji': '🎬'},
      {'name': 'Music', 'color': PopCutColors.primary, 'emoji': '🎵'},
    ];
    return PopCutHorizontalList(
      itemCount: templates.length,
      itemWidth: 200,
      itemHeight: 160,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, i) {
        final t = templates[i];
        return PopCutCard(
          padding: EdgeInsets.zero,
          hasGlow: true,
          glowColor: t['color'] as Color,
          backgroundColor: (t['color'] as Color).withValues(alpha: 0.08),
          onTap: () => widget.onNavigate('/templates'),
          child: Stack(
            children: [
              Positioned(
                top: 12,
                right: 12,
                child: Text(t['emoji'] as String, style: const TextStyle(fontSize: 28)),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        PopCutColors.background.withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius:
                        const BorderRadius.vertical(bottom: Radius.circular(16)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(t['name'] as String,
                          style: PopCutTypography.title.copyWith(fontSize: 16)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: (t['color'] as Color).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text('12 templates',
                            style: PopCutTypography.caption.copyWith(
                              color: t['color'] as Color,
                              fontWeight: FontWeight.w500,
                            )),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAiToolsGrid() {
    final tools = [
      {'icon': Icons.auto_awesome, 'label': 'AI Video', 'color': PopCutColors.primary, 'desc': 'Generate from text'},
      {'icon': Icons.dashboard_customize, 'label': 'AI Template', 'color': const Color(0xFF7C3AED), 'desc': 'Smart templates'},
      {'icon': Icons.bolt, 'label': 'AI Effect', 'color': const Color(0xFF22C55E), 'desc': 'Auto effects'},
      {'icon': Icons.record_voice_over, 'label': 'AI Voice', 'color': const Color(0xFFF59E0B), 'desc': 'Voice synthesis'},
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 0.85,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: tools.length,
        itemBuilder: (context, i) {
          final tool = tools[i];
          final color = tool['color'] as Color;
          return GestureDetector(
            onTap: () => widget.onNavigate('/ai-studio'),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: color.withValues(alpha: 0.15),
                  width: 0.5,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(tool['icon'] as IconData,
                        size: 18, color: color),
                  ),
                  const SizedBox(height: 6),
                  Text(tool['label'] as String,
                      style: PopCutTypography.captionBold.copyWith(fontSize: 10),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 2),
                  Text(tool['desc'] as String,
                      style: PopCutTypography.caption.copyWith(fontSize: 8),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEffectsStrip() {
    final effects = [
      {'name': 'Glitch', 'icon': Icons.flash_on, 'color': PopCutColors.primary},
      {'name': 'Neon', 'icon': Icons.light_mode, 'color': const Color(0xFF7C3AED)},
      {'name': 'Retro', 'icon': Icons.videocam, 'color': const Color(0xFFF59E0B)},
      {'name': 'VHS', 'icon': Icons.grain, 'color': const Color(0xFF22C55E)},
      {'name': 'Cinematic', 'icon': Icons.movie, 'color': const Color(0xFFEF4444)},
      {'name': 'Dream', 'icon': Icons.blur_on, 'color': PopCutColors.primary},
    ];
    return PopCutHorizontalList(
      itemCount: effects.length,
      itemWidth: 120,
      itemHeight: 100,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, i) {
        final e = effects[i];
        final color = e['color'] as Color;
        return PopCutGlassCard(
          padding: const EdgeInsets.all(12),
          onTap: () {},
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(e['icon'] as IconData, size: 24, color: color),
              const SizedBox(height: 6),
              Text(e['name'] as String,
                  style: PopCutTypography.captionBold.copyWith(fontSize: 11)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecentStrip(ProjectService projectService) {
    final projects = projectService.projects;
    return PopCutHorizontalList(
      itemCount: projects.length,
      itemWidth: 140,
      itemHeight: 120,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, i) {
        final p = projects[i];
        return PopCutCard(
          padding: const EdgeInsets.all(10),
          backgroundColor: PopCutColors.surface,
          onTap: () =>
              widget.onNavigate('/editor', args: {'projectId': p.id}),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Center(
                  child: Icon(Icons.movie_outlined,
                      size: 24, color: PopCutColors.textMuted.withValues(alpha: 0.5)),
                ),
              ),
              Text(p.name,
                  style: PopCutTypography.captionBold,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(Icons.access_time, size: 10, color: PopCutColors.textMuted),
                  const SizedBox(width: 4),
                  Text('${p.duration.inSeconds}s',
                      style: PopCutTypography.caption),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSkeletons() {
    return Column(
      children: [
        _buildSection(
          title: 'Continue Editing',
          child: SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 3,
              itemBuilder: (_, _) => Container(
                width: 180,
                margin: const EdgeInsets.only(right: 12),
                child: const PopCutSkeletonCard(height: 140),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildSection(
          title: 'Trending Templates',
          child: SizedBox(
            height: 160,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 3,
              itemBuilder: (_, _) => Container(
                width: 200,
                margin: const EdgeInsets.only(right: 12),
                child: const PopCutSkeletonCard(height: 160),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
