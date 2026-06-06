import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../shared/widgets/empty_state.dart';
import '../providers/ai_factory_provider.dart';
import '../models/ai_job_model.dart';

class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({super.key});

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => ref.read(aiFactoryProvider.notifier).fetchJobs(refresh: true));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(aiFactoryProvider);
    final pendingJobs = state.jobs.where((j) => j.isCompleted).toList();

    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(title: const Text('Review'), leading: Builder(builder: (ctx) => IconButton(icon: const Icon(Icons.menu), onPressed: () => Scaffold.of(ctx).openDrawer()))),
      body: state.isLoading && state.jobs.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : pendingJobs.isEmpty
              ? const EmptyState(icon: Icons.rate_review, title: 'No items to review')
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: pendingJobs.length,
                  itemBuilder: (_, i) => _ReviewTile(job: pendingJobs[i], onApprove: () => ref.read(aiFactoryProvider.notifier).approveReview(pendingJobs[i].id), onReject: () => ref.read(aiFactoryProvider.notifier).rejectReview(pendingJobs[i].id)),
                ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final AiJob job;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  const _ReviewTile({required this.job, this.onApprove, this.onReject});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AdminColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AdminColors.border.withValues(alpha: 0.5))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(radius: 16, backgroundColor: AdminColors.secondary.withValues(alpha: 0.15), child: Text('${job.userEmail?.isNotEmpty == true ? job.userEmail![0] : '?'}', style: const TextStyle(color: AdminColors.secondary, fontSize: 12, fontWeight: FontWeight.w600))),
          const SizedBox(width: 10),
          Expanded(child: Text(job.typeLabel, style: AppTypography.titleMedium.copyWith(color: AdminColors.textPrimary))),
          StatusBadge.completed(),
        ]),
        if (job.prompt != null) ...[
          const SizedBox(height: 8),
          Text(job.prompt!, style: AppTypography.bodySmall.copyWith(color: AdminColors.textSecondary)),
        ],
        const SizedBox(height: 8),
        Text('Completed in ${job.duration}', style: AppTypography.caption.copyWith(color: AdminColors.textMuted)),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: OutlinedButton.icon(icon: const Icon(Icons.close, size: 16), onPressed: onReject, label: const Text('Reject'), style: OutlinedButton.styleFrom(side: const BorderSide(color: AdminColors.error)),)),
          const SizedBox(width: 8),
          Expanded(child: ElevatedButton.icon(icon: const Icon(Icons.check, size: 16), onPressed: onApprove, label: const Text('Approve'), style: ElevatedButton.styleFrom(backgroundColor: AdminColors.success))),
        ]),
      ]),
    );
  }
}
