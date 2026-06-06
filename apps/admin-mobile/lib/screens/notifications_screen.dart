import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../models/ai_job_model.dart';
import '../providers/dashboard_provider.dart';

class NotificationsScreen extends StatefulWidget {
  final String currentRoute;
  final void Function(String route) onNavigate;

  const NotificationsScreen({
    super.key,
    required this.currentRoute,
    required this.onNavigate,
  });

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().fetchNotifications(refresh: true);
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
      context.read<DashboardProvider>().fetchNotifications();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        actions: [
          Consumer<DashboardProvider>(
            builder: (context, dp, _) {
              if (dp.unreadNotifications == 0) {
                return const SizedBox.shrink();
              }
              return TextButton(
                onPressed: () => dp.markAllNotificationsRead(),
                child: const Text(
                  'Mark all read',
                  style: TextStyle(
                    fontSize: 12,
                    color: AdminColors.primary,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      drawer: DrawerWidget(
        currentRoute: widget.currentRoute,
        onNavigate: widget.onNavigate,
      ),
      body: Consumer<DashboardProvider>(
        builder: (context, dp, _) {
          if (dp.isLoadingNotifications && dp.notifications.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (dp.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.notifications_off,
                      size: 48, color: AdminColors.textLow),
                  const SizedBox(height: 12),
                  const Text(
                    'No notifications',
                    style: TextStyle(
                      fontSize: 15,
                      color: AdminColors.textMedium,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'You\'re all caught up',
                    style: TextStyle(
                      fontSize: 12,
                      color: AdminColors.textLow,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => dp.fetchNotifications(refresh: true),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount:
                  dp.notifications.length + (dp.hasMoreNotifications ? 1 : 0),
              itemBuilder: (_, i) {
                if (i >= dp.notifications.length) {
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
                return _NotificationCard(
                  item: dp.notifications[i],
                  onTap: () => dp.markNotificationRead(
                      dp.notifications[i].id),
                );
              },
            ),
          );
        },
      ),
    );
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
          _item(Icons.auto_awesome, 'AI Factory', '/ai-factory'),
          _item(Icons.notifications, 'Notifications', '/notifications',
              selected: true),
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

class _NotificationCard extends StatelessWidget {
  final NotificationItem item;
  final VoidCallback onTap;

  const _NotificationCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.read ? null : onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: item.read ? AdminColors.background : AdminColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: item.read
                ? AdminColors.border
                : AdminColors.primary.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _typeColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_typeIcon, size: 17, color: _typeColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: item.read
                                ? FontWeight.w400
                                : FontWeight.w600,
                            color: AdminColors.textHigh,
                          ),
                        ),
                      ),
                      if (!item.read)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AdminColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.body,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AdminColors.textMedium,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.timeAgo,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AdminColors.textLow,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color get _typeColor {
    switch (item.type) {
      case 'alert':
      case 'warning':
        return AdminColors.warning;
      case 'error':
        return AdminColors.error;
      case 'success':
        return AdminColors.success;
      default:
        return AdminColors.primary;
    }
  }

  IconData get _typeIcon {
    switch (item.type) {
      case 'alert':
      case 'warning':
        return Icons.warning_amber;
      case 'error':
        return Icons.error_outline;
      case 'success':
        return Icons.check_circle_outline;
      default:
        return Icons.notifications_outlined;
    }
  }
}
