import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_provider.dart';
import '../services/project_service.dart';
import '../services/haptic_service.dart';

class HomeScreen extends StatefulWidget {
  final void Function(String route, {Map<String, dynamic>? args}) onNavigate;
  const HomeScreen({super.key, required this.onNavigate});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentPage = 0;

  final _greetings = ['Good morning', 'Good afternoon', 'Good evening'];

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return _greetings[0];
    if (h < 17) return _greetings[1];
    return _greetings[2];
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AppProvider>();
    final projects = context.watch<ProjectService>();
    final primary20 = AppColors.primary.withValues(alpha: 0.2);
    final primary30 = AppColors.primary.withValues(alpha: 0.3);
    final primary40 = AppColors.primary.withValues(alpha: 0.4);
    final primary50 = AppColors.primary.withValues(alpha: 0.5);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(auth),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text('${_greeting()}, ${auth.user?.displayName ?? 'Creator'}',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white)),
                    const Text('Ready to create?',
                        style: TextStyle(fontSize: 14, color: AppColors.foregroundSecondary)),
                    const SizedBox(height: 20),
                    _buildQuickActions(),
                    const SizedBox(height: 28),
                    _buildSectionHeader('Continue Editing', () => widget.onNavigate('/projects')),
                    const SizedBox(height: 12),
                    _buildProjectStrip(projects),
                    const SizedBox(height: 28),
                    _buildSectionHeader('Suggested for You', () => widget.onNavigate('/templates')),
                    const SizedBox(height: 12),
                    _buildTemplateStrip(),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildAppBar(AppProvider auth) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.menu, color: Colors.white), onPressed: () { HapticService.trigger(HapticLevel.light); widget.onNavigate('/settings'); }),
          const Text('CapCard', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white)),
          const Spacer(),
          CircleAvatar(
            radius: 20,
            backgroundColor: primary40,
            child: Text(
              (auth.user?.displayName ?? 'U')[0].toUpperCase(),
              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        _quickActionCard(Icons.add, 'New', AppColors.primary, () {
          HapticService.trigger(HapticLevel.medium);
          final projects = context.read<ProjectService>();
          final project = projects.createProject('Untitled Project');
          widget.onNavigate('/editor', args: {'projectId': project.id});
        }),
        const SizedBox(width: 12),
        _quickActionCard(Icons.folder_open_outlined, 'Import', null, () { HapticService.trigger(HapticLevel.light); widget.onNavigate('/projects'); }),
        const SizedBox(width: 12),
        _quickActionCard(Icons.auto_awesome, 'AI', AppColors.primary, () { HapticService.trigger(HapticLevel.light); widget.onNavigate('/ai-studio'); }),
        const SizedBox(width: 12),
        _quickActionCard(Icons.movie_creation_outlined, 'Templ', null, () { HapticService.trigger(HapticLevel.light); widget.onNavigate('/templates'); }),
      ],
    );
  }

  Widget _quickActionCard(IconData icon, String label, Color? accent, VoidCallback onTap) {
    final isAccented = accent != null;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: isAccented ? primary40 : AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: isAccented ? Border.all(color: primary50) : Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 28, color: isAccented ? accent : AppColors.foregroundSecondary),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: isAccented ? accent : AppColors.foregroundSecondary)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onSeeAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.white)),
        TextButton(
          onPressed: () { HapticService.trigger(HapticLevel.light); onSeeAll(); },
          child: const Text('See All', style: TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }

  Widget _buildProjectStrip(ProjectService projectService) {
    final projects = projectService.recentProjects;
    if (projects.isEmpty) {
      return Container(
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: const Center(
          child: Text('No recent projects', style: TextStyle(fontSize: 13, color: AppColors.foregroundMuted)),
        ),
      );
    }
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: projects.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final p = projects[i];
          return GestureDetector(
            onTap: () { HapticService.trigger(HapticLevel.light); widget.onNavigate('/editor', args: {'projectId': p.id}); },
            child: Container(
              width: 160,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(child: Icon(Icons.movie_outlined, color: AppColors.foregroundMuted.withValues(alpha: 0.5))),
                  ),
                  const SizedBox(height: 8),
                  Text(p.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const Spacer(),
                  Text('${p.duration.inSeconds}s', style: const TextStyle(fontSize: 11, color: AppColors.foregroundMuted)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTemplateStrip() {
    final templates = ['Wedding', 'Travel', 'Gaming', 'Tutorial', 'Vlog', 'Music'];
    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: templates.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final colors = [AppColors.primary, AppColors.trackAudio, AppColors.trackText, AppColors.textMedium, AppColors.textLow, AppColors.trackEffect];
          return Container(
            width: 120,
            decoration: BoxDecoration(
              color: colors[i % colors.length].withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 8, left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: colors[i % colors.length].withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(templates[i], style: TextStyle(fontSize: 10, color: colors[i % colors.length], fontWeight: FontWeight.w500)),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter, end: Alignment.bottomCenter,
                        colors: [Colors.transparent, AppColors.bgBase.withValues(alpha: 0.7)],
                      ),
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                    ),
                    child: Text('Template ${i + 1}', style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomNav() {
    final items = [Icons.home, Icons.movie_creation_outlined, Icons.auto_awesome, Icons.person_outline];
    final labels = ['Home', 'Projects', 'AI', 'Profile'];
    final routes = ['/home', '/projects', '/ai-studio', '/settings'];
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.borderLight)),
      ),
      child: Row(
        children: List.generate(items.length, (i) => Expanded(
          child: GestureDetector(
            onTap: () {
              HapticService.trigger(HapticLevel.light);
              setState(() => _currentPage = i);
              widget.onNavigate(routes[i]);
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(items[i], size: 22, color: _currentPage == i ? AppColors.primary : AppColors.foregroundMuted),
                Text(labels[i], style: TextStyle(fontSize: 10, color: _currentPage == i ? AppColors.primary : AppColors.foregroundMuted)),
              ],
            ),
          ),
        )),
      ),
    );
  }
}
