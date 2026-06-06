import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_widget.dart';
import '../providers/notifications_provider.dart';

class NotificationsListScreen extends ConsumerStatefulWidget {
  const NotificationsListScreen({super.key});

  @override
  ConsumerState<NotificationsListScreen> createState() => _NotificationsListScreenState();
}

class _NotificationsListScreenState extends ConsumerState<NotificationsListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => ref.read(notificationsProvider.notifier).fetchNotifications());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationsProvider);
    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: Builder(builder: (ctx) => IconButton(icon: const Icon(Icons.menu), onPressed: () => Scaffold.of(ctx).openDrawer())),
        actions: [
          if (state.unreadCount > 0)
            TextButton(onPressed: () => ref.read(notificationsProvider.notifier).markAllRead(), child: const Text('Mark All Read', style: TextStyle(fontSize: 12))),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? AppErrorWidget(message: state.error!, onRetry: () => ref.read(notificationsProvider.notifier).fetchNotifications())
              : state.notifications.isEmpty
                  ? const EmptyState(icon: Icons.notifications_off, title: 'No notifications')
                  : RefreshIndicator(
                      onRefresh: () => ref.read(notificationsProvider.notifier).fetchNotifications(),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.notifications.length,
                        itemBuilder: (_, i) {
                          final n = state.notifications[i];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: InkWell(
                              onTap: () {
                                if (!n.read) ref.read(notificationsProvider.notifier).markRead(n.id);
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: n.read ? AdminColors.surface : AdminColors.surfaceHover,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AdminColors.border.withValues(alpha: 0.5)),
                                ),
                                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Container(
                                    width: 8, height: 8, margin: const EdgeInsets.only(top: 6),
                                    decoration: BoxDecoration(color: n.read ? AdminColors.textMuted : AdminColors.primary, shape: BoxShape.circle),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Text(n.title, style: AppTypography.titleMedium.copyWith(color: AdminColors.textPrimary, fontWeight: n.read ? FontWeight.w400 : FontWeight.w600)),
                                    const SizedBox(height: 4),
                                    Text(n.body, style: AppTypography.bodySmall.copyWith(color: AdminColors.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 6),
                                    Text(n.timeAgo, style: AppTypography.caption.copyWith(color: AdminColors.textMuted)),
                                  ])),
                                  Icon(_iconForType(n.type), size: 18, color: _colorForType(n.type)),
                                ]),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'info': return Icons.info_outline;
      case 'warning': return Icons.warning_amber;
      case 'error': return Icons.error_outline;
      case 'success': return Icons.check_circle_outline;
      default: return Icons.notifications;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'info': return AdminColors.primary;
      case 'warning': return AdminColors.warning;
      case 'error': return AdminColors.error;
      case 'success': return AdminColors.success;
      default: return AdminColors.textMuted;
    }
  }
}
