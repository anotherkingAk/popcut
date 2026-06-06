import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_widget.dart';
import '../providers/ai_factory_provider.dart';
import '../models/ai_job_model.dart';

class QueueScreen extends ConsumerStatefulWidget {
  const QueueScreen({super.key});

  @override
  ConsumerState<QueueScreen> createState() => _QueueScreenState();
}

class _QueueScreenState extends ConsumerState<QueueScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => ref.read(aiFactoryProvider.notifier).fetchJobs(refresh: true));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(aiFactoryProvider);
    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(title: const Text('AI Queue'), leading: Builder(builder: (ctx) => IconButton(icon: const Icon(Icons.menu), onPressed: () => Scaffold.of(ctx).openDrawer())), actions: [IconButton(icon: const Icon(Icons.refresh, size: 18), onPressed: () => ref.read(aiFactoryProvider.notifier).fetchJobs(refresh: true))]),
      body: state.isLoading && state.jobs.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : state.error != null && state.jobs.isEmpty
              ? AppErrorWidget(message: state.error!, onRetry: () => ref.read(aiFactoryProvider.notifier).fetchJobs(refresh: true))
              : state.jobs.isEmpty
                  ? const EmptyState(icon: Icons.queue, title: 'No jobs in queue')
                  : RefreshIndicator(
                      onRefresh: () => ref.read(aiFactoryProvider.notifier).fetchJobs(refresh: true),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.jobs.length,
                        itemBuilder: (_, i) => _JobTile(job: state.jobs[i], onRetry: () => ref.read(aiFactoryProvider.notifier).retryJob(state.jobs[i].id)),
                      ),
                    ),
    );
  }
}

class _JobTile extends StatelessWidget {
  final AiJob job;
  final VoidCallback? onRetry;
  const _JobTile({required this.job, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AdminColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AdminColors.border.withValues(alpha: 0.5))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: AdminColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.auto_awesome, size: 18, color: AdminColors.primary),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(job.typeLabel, style: AppTypography.titleMedium.copyWith(color: AdminColors.textPrimary)),
            Text(job.userEmail ?? 'Unknown', style: AppTypography.caption.copyWith(color: AdminColors.textMuted)),
          ])),
          StatusBadge(label: job.statusLabel, color: job.isCompleted ? AdminColors.success : job.isFailed ? AdminColors.error : job.isRunning ? AdminColors.primary : AdminColors.warning),
        ]),
        if (job.prompt != null && job.prompt!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(job.prompt!, style: AppTypography.bodySmall.copyWith(color: AdminColors.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
        const SizedBox(height: 8),
        Row(children: [
          Text(Formatters.timeAgo(job.createdAt), style: AppTypography.caption.copyWith(color: AdminColors.textMuted)),
          const Spacer(),
          if (job.isRunning) ...[
            Text('${(job.progress * 100).toInt()}%', style: AppTypography.caption.copyWith(color: AdminColors.primary)),
          ],
          if (job.isFailed && job.isRetryable && onRetry != null) ...[
            TextButton.icon(icon: const Icon(Icons.refresh, size: 14), onPressed: onRetry, label: const Text('Retry', style: TextStyle(fontSize: 11))),
          ],
        ]),
        if (job.isRunning) ...[
          const SizedBox(height: 8),
          ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: job.progress, backgroundColor: AdminColors.border, color: AdminColors.primary)),
        ],
      ]),
    );
  }
}
