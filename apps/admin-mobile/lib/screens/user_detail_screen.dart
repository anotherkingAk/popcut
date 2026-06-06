import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../models/user_model.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/status_badge.dart';

class UserDetailScreen extends StatelessWidget {
  final String userId;

  const UserDetailScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, dp, _) {
        final user = dp.users.where((u) => u.id == userId).firstOrNull;
        if (user == null) {
          return Scaffold(
            backgroundColor: AdminColors.background,
            appBar: AppBar(title: const Text('User Details')),
            body: const Center(
              child: Text(
                'User not found',
                style: TextStyle(color: AdminColors.textMedium),
              ),
            ),
          );
        }
        return _UserDetailContent(
          user: user,
          onSuspend: () => _handleSuspend(context, user, dp),
        );
      },
    );
  }

  void _handleSuspend(
      BuildContext context, AdminUser user, DashboardProvider dp) async {
    if (user.isSuspended) {
      await dp.unsuspendUser(user.id);
    } else {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AdminColors.surface,
          title: const Text('Suspend User',
              style: TextStyle(color: AdminColors.textHigh)),
          content: Text(
            'Suspend ${user.displayName}? They will lose access until reinstated.',
            style: const TextStyle(color: AdminColors.textMedium),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AdminColors.error),
              child: const Text('Suspend'),
            ),
          ],
        ),
      );
      if (confirm == true && context.mounted) {
        await dp.suspendUser(user.id);
        Navigator.pop(context);
      }
    }
  }
}

class _UserDetailContent extends StatelessWidget {
  final AdminUser user;
  final VoidCallback onSuspend;

  const _UserDetailContent({
    required this.user,
    required this.onSuspend,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(
        title: const Text('User Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: AdminColors.surface,
                shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (ctx) => SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: Icon(
                          user.isSuspended
                              ? Icons.check_circle_outline
                              : Icons.block_outlined,
                          color: user.isSuspended
                              ? AdminColors.success
                              : AdminColors.error,
                        ),
                        title: Text(
                          user.isSuspended ? 'Unsuspend User' : 'Suspend User',
                        ),
                        onTap: () {
                          Navigator.pop(ctx);
                          onSuspend();
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.email_outlined,
                            color: AdminColors.primary),
                        title: const Text('Send Email'),
                        onTap: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 20),
            _buildInfoSection('Account Information', [
              _infoRow('User ID', user.id),
              _infoRow('Email', user.email),
              _infoRow('Phone', user.phoneNumber ?? 'Not provided'),
              _infoRow('Status', user.status.toUpperCase()),
              _infoRow('Plan', user.plan.toUpperCase()),
              _infoRow('Email Verified', user.emailVerified ? 'Yes' : 'No'),
              _infoRow('Roles', user.roles.isEmpty ? 'None' : user.roles.join(', ')),
            ]),
            const SizedBox(height: 16),
            _buildInfoSection('Usage', [
              _infoRow('Projects', user.projectsCount.toString()),
              _infoRow(
                'Storage',
                '${user.storageUsed.toStringAsFixed(1)} GB / ${user.storageLimit.toStringAsFixed(1)} GB',
              ),
            ]),
            const SizedBox(height: 16),
            _buildInfoSection('Timeline', [
              _infoRow('Joined', _formatDate(user.createdAt)),
              _infoRow('Last Active', _formatDate(user.lastActive)),
            ]),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, size: 16),
                    label: const Text('Back'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onSuspend,
                    icon: Icon(
                      user.isSuspended
                          ? Icons.check_circle_outline
                          : Icons.block_outlined,
                      size: 16,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: user.isSuspended
                          ? AdminColors.success
                          : AdminColors.error,
                    ),
                    label: Text(
                        user.isSuspended ? 'Unsuspend' : 'Suspend User'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AdminColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: user.isPro
                  ? const LinearGradient(
                      colors: [AdminColors.primaryDim, AdminColors.primary])
                  : null,
              color: user.isPro
                  ? null
                  : AdminColors.surfaceElevated,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                user.initials,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: user.isPro
                      ? Colors.white
                      : AdminColors.textMedium,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            user.displayName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AdminColors.textHigh,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            style: const TextStyle(
              fontSize: 13,
              color: AdminColors.textMedium,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              StatusBadge.fromStatus(user.status),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AdminColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  user.plan.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AdminColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> rows) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdminColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AdminColors.textHigh,
            ),
          ),
          const SizedBox(height: 12),
          ...rows,
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AdminColors.textLow,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AdminColors.textHigh,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }
}


