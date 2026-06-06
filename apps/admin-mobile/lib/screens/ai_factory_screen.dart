import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../models/ai_job_model.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/status_badge.dart';

class AiFactoryScreen extends StatefulWidget {
  final String currentRoute;
  final void Function(String route) onNavigate;

  const AiFactoryScreen({
    super.key,
    required this.currentRoute,
    required this.onNavigate,
  });

  @override
  State<AiFactoryScreen> createState() => _AiFactoryScreenState();
}

class _AiFactoryScreenState extends State<AiFactoryScreen> {
  final _scrollController = ScrollController();
  String _statusFilter = 'All';

  final _filters = ['All', 'Running', 'Completed', 'Failed', 'Pending'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().fetchAiJobs(refresh: true);
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<DashboardProvider>().fetchAiJobs();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(
        title: const Text('AI Factory'),
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
      ),
      drawer: DrawerWidget(
        currentRoute: widget.currentRoute,
        onNavigate: widget.onNavigate,
      ),
      body: Column(
        children: [
          _buildStatsOverview(),
          _buildFilterChips(),
          Expanded(child: _buildJobList()),
        ],
      ),
    );
  }

  Widget _buildStatsOverview() {
    return Consumer<DashboardProvider>(
      builder: (context, dp, _) {
        final jobs = dp.aiJobs;
        final running = jobs.where((j) => j.isRunning).length;
        final failed = jobs.where((j) => j.isFailed).length;
        final completed = jobs.where((j) => j.isCompleted).length;
        final pending = jobs.where((j) => j.status == AiJobStatus.pending).length;

        return Container(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AdminColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AdminColors.border),
          ),
          child: Row(
            children: [
              _miniStat('Running', running.toString(), AdminColors.info),
              _miniStat('Failed', failed.toString(), AdminColors.error),
              _miniStat(
                  'Completed', completed.toString(), AdminColors.success),
              _miniStat('Pending', pending.toString(), AdminColors.warning),
            ],
          ),
        );
      },
    );
  }

  Widget _miniStat(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AdminColors.textLow,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filters.length,
        itemBuilder: (_, i) {
          final isSelected = _statusFilter == _filters[i];
          return GestureDetector(
            onTap: () => setState(() => _statusFilter = _filters[i]),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? AdminColors.primary
                    : AdminColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color:
                      isSelected ? AdminColors.primary : AdminColors.border,
                ),
              ),
              child: Text(
                _filters[i],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? AdminColors.textHigh
                      : AdminColors.textMedium,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildJobList() {
    return Consumer<DashboardProvider>(
      builder: (context, dp, _) {
        if (dp.isLoadingJobs && dp.aiJobs.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final filtered = dp.aiJobs.where((j) {
          if (_statusFilter == 'All') return true;
          return j.statusLabel == _statusFilter;
        }).toList();

        if (filtered.isEmpty) {
          return const Center(
            child: Text(
              'No AI jobs found',
              style: TextStyle(color: AdminColors.textMedium),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => dp.fetchAiJobs(refresh: true),
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: filtered.length + (dp.hasMoreJobs ? 1 : 0),
            itemBuilder: (_, i) {
              if (i >= filtered.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                );
              }
              return _JobCard(
                job: filtered[i],
                onRetry: filtered[i].isRetryable
                    ? () => _handleRetry(context, filtered[i])
                    : null,
              );
            },
          ),
        );
      },
    );
  }

  void _handleRetry(BuildContext context, AiJob job) async {
    final success =
        await context.read<DashboardProvider>().retryAiJob(job.id);
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Retrying job ${job.id.substring(0, 8)}...'),
        ),
      );
    }
  }
}

class DrawerWidget extends StatelessWidget {
  final String currentRoute;
  final void Function(String route) onNavigate;

  const DrawerWidget({
    super.key,
    required this.currentRoute,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AdminColors.background,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AdminColors.primaryDim, AdminColors.primary],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                Icon(Icons.admin_panel_settings,
                    size: 32, color: Colors.white),
                SizedBox(height: 12),
                Text('PopCut Admin',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700)),
                Text('Control your ecosystem',
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          _item(Icons.dashboard, 'Dashboard', '/dashboard'),
          _item(Icons.group, 'Users', '/users'),
          _item(Icons.checklist, 'Approvals', '/approvals'),
          _item(Icons.auto_awesome, 'AI Factory', '/ai-factory',
              selected: true),
          _item(Icons.notifications, 'Notifications', '/notifications'),
          _item(Icons.analytics, 'Analytics', '/analytics'),
          _item(Icons.settings, 'Settings', '/settings'),
        ],
      ),
    );
  }

  ListTile _item(IconData icon, String label, String route,
      {bool selected = false}) {
    return ListTile(
      leading: Icon(icon,
          size: 20,
          color: selected ? AdminColors.primary : AdminColors.textMedium),
      title: Text(label,
          style: TextStyle(
              fontSize: 14,
              color:
                  selected ? AdminColors.primary : AdminColors.textHigh)),
      onTap: () => onNavigate(route),
    );
  }
}

class _JobCard extends StatelessWidget {
  final AiJob job;
  final VoidCallback? onRetry;

  const _JobCard({required this.job, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AdminColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _typeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(_typeIcon, size: 16, color: _typeColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.typeLabel,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AdminColors.textHigh,
                      ),
                    ),
                    if (job.userEmail != null)
                      Text(
                        job.userEmail!,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AdminColors.textMedium,
                        ),
                      ),
                  ],
                ),
              ),
              StatusBadge.fromStatus(job.statusLabel),
            ],
          ),
          if (job.prompt != null && job.prompt!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              job.prompt!,
              style: const TextStyle(
                fontSize: 12,
                color: AdminColors.textLow,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (job.isRunning) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: job.progress,
                backgroundColor: AdminColors.border,
                valueColor: const AlwaysStoppedAnimation(AdminColors.primary),
                minHeight: 4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${(job.progress * 100).toStringAsFixed(0)}%',
              style: const TextStyle(
                fontSize: 10,
                color: AdminColors.textLow,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                job.duration,
                style: const TextStyle(
                  fontSize: 10,
                  color: AdminColors.textLow,
                ),
              ),
              const Spacer(),
              Text(
                'Retries: ${job.retryCount}',
                style: const TextStyle(
                  fontSize: 10,
                  color: AdminColors.textLow,
                ),
              ),
            ],
          ),
          if (job.isFailed && job.errorMessage != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AdminColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline,
                      size: 12, color: AdminColors.error),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      job.errorMessage!,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AdminColors.error,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (onRetry != null) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 14),
                label: const Text('Retry Job',
                    style: TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AdminColors.warning,
                  side: BorderSide(
                      color: AdminColors.warning.withValues(alpha: 0.3)),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color get _typeColor {
    switch (job.type) {
      case AiJobType.textToVideo:
        return AdminColors.primary;
      case AiJobType.imageToVideo:
        return AdminColors.success;
      case AiJobType.videoEditing:
        return AdminColors.info;
      case AiJobType.audioGeneration:
        return AdminColors.warning;
      case AiJobType.unknown:
        return AdminColors.textLow;
    }
  }

  IconData get _typeIcon {
    switch (job.type) {
      case AiJobType.textToVideo:
        return Icons.text_fields;
      case AiJobType.imageToVideo:
        return Icons.image;
      case AiJobType.videoEditing:
        return Icons.movie_creation;
      case AiJobType.audioGeneration:
        return Icons.audiotrack;
      case AiJobType.unknown:
        return Icons.help_outline;
    }
  }
}
