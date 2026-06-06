import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/haptic_service.dart';

class CollabScreen extends StatefulWidget {
  final VoidCallback onBack;
  final void Function(String route, {Map<String, dynamic>? args}) onNavigate;

  const CollabScreen({
    super.key,
    required this.onBack,
    required this.onNavigate,
  });

  @override
  State<CollabScreen> createState() => _CollabScreenState();
}

class _CollabScreenState extends State<CollabScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedProjectIndex = -1;
  final TextEditingController _inviteCtl = TextEditingController();
  bool _showInviteScreen = false;

  final _sampleProjects = List.generate(
    4,
    (i) => CollabProject(
      title: 'Project ${i + 1}',
      collaborators: ['User A', 'User B', 'User C'].sublist(0, i % 3 + 2),
      lastActivity: '${i + 1}h ago',
    ),
  );

  final _sampleActivity = [
    CollabActivity('User A', 'trimmed clip "Intro"', '2h ago'),
    CollabActivity('User B', 'added transition to clip 3', '3h ago'),
    CollabActivity('User C', 'adjusted audio levels', '5h ago'),
    CollabActivity('User A', 'added text overlay', '1d ago'),
    CollabActivity('User B', 'exported draft v2', '2d ago'),
  ];

  final _sampleVersions = [
    VersionEntry('v1.2', 'User B', 'Adjusted color grade', DateTime.now().subtract(const Duration(hours: 2)), true),
    VersionEntry('v1.1', 'User A', 'Trimmed intro clip', DateTime.now().subtract(const Duration(hours: 5)), true),
    VersionEntry('v1.0', 'User A', 'Initial edit', DateTime.now().subtract(const Duration(days: 1)), true),
  ];

  final _sampleComments = [
    CommentEntry('User B', 'This clip needs color grading', DateTime.now().subtract(const Duration(hours: 3)), [
      CommentEntry('User A', 'Agreed, working on it', DateTime.now().subtract(const Duration(hours: 2)), []),
    ]),
    CommentEntry('User C', 'Audio is clipping here', DateTime.now().subtract(const Duration(hours: 6)), []),
  ];

  @override
  void dispose() {
    _tabController.dispose();
    _inviteCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_showInviteScreen) return _buildInviteScreen();
    if (_selectedProjectIndex >= 0) return _buildProjectDetail();
    return _buildProjectList();
  }

  Widget _buildProjectList() {
    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: AppBar(
        backgroundColor: AppColors.bgSurface,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () { HapticService.trigger(HapticLevel.light); widget.onBack(); }),
        title: const Text('Collaborations'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () { HapticService.trigger(HapticLevel.light); setState(() => _showInviteScreen = true); },
        backgroundColor: AppColors.brand500,
        child: const Icon(Icons.person_add, color: Colors.black),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _sampleProjects.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final p = _sampleProjects[i];
          return GestureDetector(
            onTap: () { HapticService.trigger(HapticLevel.light); setState(() => _selectedProjectIndex = i); },
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.title, style: AppTypography.titleSm),
                        const SizedBox(height: 6),
                        _buildAvatarStack(p.collaborators),
                        const SizedBox(height: 4),
                        Text('Last activity: ${p.lastActivity}', style: AppTypography.bodySm),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.textLow),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAvatarStack(List<String> users) {
    final display = users.take(4).toList();
    final overflow = users.length - 4;
    return SizedBox(
      height: 28,
      child: Stack(
        children: [
          for (int i = 0; i < display.length; i++)
            Positioned(
              left: i * 20.0,
              child: CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.bgOverlay,
                child: Text(
                  display[i][0],
                  style: const TextStyle(fontSize: 10, color: AppColors.textMedium, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          if (overflow > 0)
            Positioned(
              left: display.length * 20.0,
              child: CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.bgOverlay,
                child: Text('+$overflow', style: const TextStyle(fontSize: 9, color: AppColors.textMedium)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInviteScreen() {
    final suggested = ['User X', 'User Y', 'User Z', 'User W'];
    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: AppBar(
        backgroundColor: AppColors.bgSurface,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () { HapticService.trigger(HapticLevel.light); setState(() => _showInviteScreen = false); }),
        title: const Text('Invite Collaborators'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, size: 18, color: AppColors.textLow),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _inviteCtl,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: const InputDecoration.collapsed(
                        hintText: 'Search users...',
                        hintStyle: TextStyle(color: AppColors.textLow),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Suggested', style: AppTypography.titleSm),
                TextButton(
                  onPressed: () { HapticService.trigger(HapticLevel.light); },
                  child: const Text('See All', style: TextStyle(color: AppColors.brand500, fontSize: 12)),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: suggested.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.bgSurface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.bgOverlay,
                        child: Text(suggested[i][0], style: const TextStyle(color: AppColors.textMedium)),
                      ),
                      const SizedBox(width: 12),
                      Text(suggested[i], style: const TextStyle(color: Colors.white, fontSize: 14)),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.person_add, color: AppColors.brand500, size: 20),
                        onPressed: () { HapticService.trigger(HapticLevel.light); },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectDetail() {
    final project = _sampleProjects[_selectedProjectIndex];
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.bgBase,
        appBar: AppBar(
          backgroundColor: AppColors.bgSurface,
          leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () { HapticService.trigger(HapticLevel.light); setState(() => _selectedProjectIndex = -1); }),
          title: Text(project.title),
          bottom: const TabBar(
            indicatorColor: AppColors.brand500,
            labelColor: AppColors.brand500,
            unselectedLabelColor: AppColors.textLow,
            tabs: [
              Tab(text: 'Timeline'),
              Tab(text: 'Comments'),
              Tab(text: 'Versions'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildSharedTimeline(),
            _buildComments(),
            _buildVersionHistory(),
          ],
        ),
      ),
    );
  }

  Widget _buildSharedTimeline() {
    final tracks = ['Video', 'Audio', 'Text', 'Effect'];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Center(
            child: Text('Read-only view', style: AppTypography.bodySm),
          ),
        ),
        const SizedBox(height: 16),
        for (final track in tracks) ...[
          Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.bgElevated,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(Icons.circle, size: 8, color: _trackColor(track)),
                const SizedBox(width: 8),
                Text(track, style: AppTypography.bodySm),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  Color _trackColor(String track) {
    return switch (track) {
      'Video' => AppColors.trackVideo,
      'Audio' => AppColors.trackAudio,
      'Text' => AppColors.trackText,
      'Effect' => AppColors.trackEffect,
      _ => AppColors.textLow,
    };
  }

  Widget _buildComments() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _sampleComments.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final c = _sampleComments[i];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(c.author, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                  const SizedBox(width: 8),
                  Text(c.timeAgo, style: AppTypography.bodySm),
                ],
              ),
              const SizedBox(height: 4),
              Text(c.text, style: AppTypography.bodyMd),
              if (c.replies.isNotEmpty) ...[
                const SizedBox(height: 8),
                Divider(color: AppColors.border, height: 1),
                const SizedBox(height: 8),
                for (final r in c.replies) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 2, height: 14,
                        margin: const EdgeInsets.only(right: 8, top: 4),
                        color: AppColors.border,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(r.author, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMedium)),
                                const SizedBox(width: 6),
                                Text(r.timeAgo, style: AppTypography.bodySm),
                              ],
                            ),
                            Text(r.text, style: AppTypography.bodyMd),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                ],
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildVersionHistory() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _sampleVersions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final v = _sampleVersions[i];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(v.version, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                  const Spacer(),
                  Text(v.dateStr, style: AppTypography.bodySm),
                ],
              ),
              const SizedBox(height: 4),
              Text('by ${v.author}', style: AppTypography.bodySm),
              const SizedBox(height: 2),
              Text(v.description, style: AppTypography.bodyMd),
              const SizedBox(height: 8),
              Row(
                children: [
                  GestureDetector(
                    onTap: () { HapticService.trigger(HapticLevel.light); },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: v.accepted ? AppColors.success.withValues(alpha: 0.15) : AppColors.bgOverlay,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: v.accepted ? AppColors.success : AppColors.border),
                      ),
                      child: Text(v.accepted ? 'Accepted' : 'Pending',
                          style: TextStyle(fontSize: 10, color: v.accepted ? AppColors.success : AppColors.textMedium, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () { HapticService.trigger(HapticLevel.light); setState(() => v.accepted = !v.accepted); },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.bgOverlay,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(v.accepted ? 'Reject' : 'Accept',
                          style: const TextStyle(fontSize: 10, color: AppColors.textMedium, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class CollabProject {
  final String title;
  final List<String> collaborators;
  final String lastActivity;
  CollabProject({required this.title, required this.collaborators, required this.lastActivity});
}

class CollabActivity {
  final String user;
  final String action;
  final String timestamp;
  CollabActivity(this.user, this.action, this.timestamp);
}

class VersionEntry {
  final String version;
  final String author;
  final String description;
  final DateTime date;
  bool accepted;
  VersionEntry(this.version, this.author, this.description, this.date, this.accepted);
  String get dateStr {
    final d = DateTime.now().difference(date);
    if (d.inHours < 24) return '${d.inHours}h ago';
    return '${d.inDays}d ago';
  }
}

class CommentEntry {
  final String author;
  final String text;
  final DateTime time;
  final List<CommentEntry> replies;
  CommentEntry(this.author, this.text, this.time, this.replies);
  String get timeAgo {
    final d = DateTime.now().difference(time);
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    if (d.inHours < 24) return '${d.inHours}h ago';
    return '${d.inDays}d ago';
  }
}
