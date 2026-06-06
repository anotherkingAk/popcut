import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../shared/widgets/stat_row.dart';
import '../../../shared/widgets/loading_skeleton.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../models/user_model.dart';
import '../providers/users_provider.dart';

final _userDetailProvider = FutureProvider.family<AdminUser, String>((ref, userId) async {
  final dio = ref.watch(authDioProvider);
  final response = await dio.get(ApiEndpoints.user(userId));
  final data = response.data['data'] as Map<String, dynamic>? ?? response.data as Map<String, dynamic>;
  return AdminUser.fromJson(data);
});

class UserDetailScreen extends ConsumerWidget {
  final String userId;
  const UserDetailScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(_userDetailProvider(userId));
    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(title: const Text('User Details')),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AppErrorWidget(message: e.toString(), onRetry: () => ref.invalidate(_userDetailProvider(userId))),
        data: (user) => _UserDetailContent(user: user, userId: userId),
      ),
    );
  }
}

class _UserDetailContent extends ConsumerWidget {
  final AdminUser user;
  final String userId;
  const _UserDetailContent({required this.user, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: AdminColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AdminColors.border.withValues(alpha: 0.5))),
          child: Column(children: [
            CircleAvatar(radius: 32, backgroundColor: AdminColors.primary.withValues(alpha: 0.15), child: Text(user.initials, style: const TextStyle(color: AdminColors.primary, fontSize: 20, fontWeight: FontWeight.w600))),
            const SizedBox(height: 12),
            Text(user.displayName, style: AppTypography.headlineSmall.copyWith(color: AdminColors.textPrimary)),
            const SizedBox(height: 4),
            Text(user.email, style: AppTypography.bodyMedium.copyWith(color: AdminColors.textSecondary)),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              StatusBadge.fromString(user.status),
              const SizedBox(width: 8),
              StatusBadge(label: user.plan.toUpperCase(), color: user.isPro ? AdminColors.warning : AdminColors.textMuted),
            ]),
          ]),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AdminColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AdminColors.border.withValues(alpha: 0.5))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Account Info', style: AppTypography.titleSmall.copyWith(color: AdminColors.textPrimary)),
            const Divider(height: 24),
            StatRow(label: 'Member Since', value: Formatters.date(user.createdAt)),
            StatRow(label: 'Last Active', value: Formatters.timeAgo(user.lastActive)),
            StatRow(label: 'Email Verified', value: user.emailVerified ? 'Yes' : 'No', valueColor: user.emailVerified ? AdminColors.success : AdminColors.error),
            StatRow(label: 'Phone', value: user.phoneNumber ?? 'Not set'),
          ]),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AdminColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AdminColors.border.withValues(alpha: 0.5))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Usage', style: AppTypography.titleSmall.copyWith(color: AdminColors.textPrimary)),
            const Divider(height: 24),
            StatRow(label: 'Projects', value: Formatters.compactNumber(user.projectsCount)),
            StatRow(label: 'Storage Used', value: Formatters.fileSize((user.storageUsed * 1073741824).toInt()), valueColor: user.storageUsed > user.storageLimit * 0.8 ? AdminColors.warning : AdminColors.textPrimary),
            StatRow(label: 'Storage Limit', value: Formatters.fileSize((user.storageLimit * 1073741824).toInt())),
          ]),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () async {
              final confirmed = await ConfirmDialog.show(context, title: user.isActive ? 'Suspend User' : 'Unsuspend User', message: 'Are you sure you want to ${user.isActive ? 'suspend' : 'unsuspend'} ${user.displayName}?', confirmLabel: user.isActive ? 'Suspend' : 'Unsuspend', confirmColor: user.isActive ? AdminColors.error : AdminColors.success, icon: user.isActive ? Icons.block : Icons.check_circle);
              if (confirmed) {
                final success = await ref.read(usersProvider.notifier).toggleSuspend(userId);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(success ? 'User ${user.isActive ? 'suspended' : 'unsuspended'}' : 'Failed'), backgroundColor: success ? AdminColors.success : AdminColors.error));
                }
              }
            },
            style: OutlinedButton.styleFrom(side: BorderSide(color: user.isActive ? AdminColors.error : AdminColors.success)),
            icon: Icon(user.isActive ? Icons.block : Icons.check_circle, size: 16, color: user.isActive ? AdminColors.error : AdminColors.success),
            label: Text(user.isActive ? 'Suspend User' : 'Unsuspend User', style: TextStyle(color: user.isActive ? AdminColors.error : AdminColors.success)),
          ),
        ),
      ]),
    );
  }
}
