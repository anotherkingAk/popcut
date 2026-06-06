import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/project.dart';
import '../services/project_service.dart';
import '../services/haptic_service.dart';

class ProjectsScreen extends StatefulWidget {
  final VoidCallback onBack;
  final void Function(String route, {Map<String, dynamic>? args}) onNavigate;
  const ProjectsScreen({super.key, required this.onBack, required this.onNavigate});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  String _searchQuery = '';
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final projectService = context.watch<ProjectService>();
    final allProjects = _searchQuery.isEmpty
        ? projectService.projects
        : projectService.search(_searchQuery);
    final projects = _filter == 'All'
        ? allProjects
        : allProjects.where((p) {
            if (_filter == 'Video') return p.duration.inSeconds > 30;
            if (_filter == 'Draft') return p.status == ProjectStatus.draft;
            if (_filter == 'Done') return p.status == ProjectStatus.done;
            return true;
          }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () { HapticService.trigger(HapticLevel.light); widget.onBack(); }),
        title: const Text('Projects'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          HapticService.trigger(HapticLevel.medium);
          final p = context.read<ProjectService>().createProject('New Project');
          widget.onNavigate('/editor', args: {'projectId': p.id});
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          Expanded(
            child: projects.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.movie_creation_outlined, size: 48, color: AppColors.foregroundMuted),
                        const SizedBox(height: 16),
                        Text(_searchQuery.isEmpty ? 'No projects yet' : 'No matching projects',
                            style: const TextStyle(fontSize: 16, color: AppColors.foregroundSecondary)),
                        const SizedBox(height: 8),
                        Text('Tap + to create your first project',
                            style: const TextStyle(fontSize: 13, color: AppColors.foregroundMuted)),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.85,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: projects.length,
                    itemBuilder: (context, i) {
                      final project = projects[i];
                      return _ProjectCard(
                        project: project,
                        onTap: () => widget.onNavigate('/editor', args: {'projectId': project.id}),
                        onDelete: () {
                          context.read<ProjectService>().deleteProject(project.id);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, size: 18, color: AppColors.foregroundMuted),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                style: const TextStyle(fontSize: 13, color: Colors.white),
                decoration: const InputDecoration.collapsed(
                  hintText: 'Search projects...',
                  hintStyle: TextStyle(color: AppColors.foregroundMuted),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'Video', 'Draft', 'Done'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: filters.map((f) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () { HapticService.trigger(HapticLevel.light); setState(() => _filter = f); },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: _filter == f ? AppColors.activeOverlay : AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _filter == f ? AppColors.primary : AppColors.border),
              ),
              child: Text(f, style: TextStyle(
                fontSize: 12,
                color: _filter == f ? AppColors.primary : AppColors.foregroundSecondary,
                fontWeight: _filter == f ? FontWeight.w600 : FontWeight.normal,
              )),
            ),
          ),
        )).toList(),
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ProjectCard({required this.project, required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () { HapticService.trigger(HapticLevel.light); onTap(); },
      onLongPress: () {
        HapticService.trigger(HapticLevel.medium);
        showModalBottomSheet(
          context: context,
          backgroundColor: AppColors.surface,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          builder: (ctx) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 32, height: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.foregroundMuted,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                _SheetTile(icon: Icons.edit_outlined, label: 'Rename', onTap: () { HapticService.trigger(HapticLevel.light); Navigator.pop(ctx); }),
                _SheetTile(icon: Icons.copy_outlined, label: 'Duplicate', onTap: () { HapticService.trigger(HapticLevel.light); Navigator.pop(ctx); }),
                _SheetTile(icon: Icons.share_outlined, label: 'Share', onTap: () { HapticService.trigger(HapticLevel.light); Navigator.pop(ctx); }),
                _SheetTile(icon: Icons.file_upload_outlined, label: 'Export', onTap: () { HapticService.trigger(HapticLevel.light); Navigator.pop(ctx); }),
                _SheetTile(icon: Icons.delete_outline, label: 'Delete', onTap: () { HapticService.trigger(HapticLevel.heavy); Navigator.pop(ctx); onDelete(); }, isDestructive: true),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(Icons.movie_outlined, size: 32, color: AppColors.foregroundMuted.withValues(alpha: 0.5)),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(project.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Row(
              children: [
                _statusBadge(project.status),
                const Spacer(),
                Text('${project.duration.inSeconds}s', style: const TextStyle(fontSize: 11, color: AppColors.foregroundMuted)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(ProjectStatus status) {
    final data = switch (status) {
      ProjectStatus.draft => ('Draft', AppColors.caution),
      ProjectStatus.exporting => ('Exporting', AppColors.primary),
      ProjectStatus.done => ('Done', AppColors.constructive),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: data.$2.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(data.$1, style: TextStyle(fontSize: 9, color: data.$2, fontWeight: FontWeight.w600)),
    );
  }

}

class _SheetTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _SheetTile({required this.icon, required this.label, required this.onTap, this.isDestructive = false});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? AppColors.destructive : AppColors.foregroundSecondary, size: 20),
      title: Text(label, style: TextStyle(
        fontSize: 14,
        color: isDestructive ? AppColors.destructive : Colors.white,
      )),
      onTap: onTap,
    );
  }
}
