import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/auth/auth_provider.dart';
import '../../core/rbac/permissions.dart';
import '../../core/rbac/rbac_guard.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : 'A';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateProvider);
    final user = auth.user;
    final role = user != null ? AdminRole.fromString(user.role) : AdminRole.analyst;

    return Drawer(
      backgroundColor: AdminColors.background,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 16, bottom: 16, left: 20, right: 20),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AdminColors.border, width: 0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AdminColors.primary, AdminColors.secondary]),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      _getInitials(user?.displayName ?? 'A'),
                      style: AppTypography.headlineMedium.copyWith(color: AdminColors.textPrimary),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(user?.displayName ?? 'Admin', style: AppTypography.titleMedium.copyWith(color: AdminColors.textPrimary)),
                const SizedBox(height: 2),
                Text(user?.role.toUpperCase() ?? '', style: AppTypography.caption.copyWith(color: AdminColors.primary)),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _DrawerSection('Main'),
                _DrawerItem(icon: Icons.dashboard, label: 'Dashboard', route: AppRoutes.dashboard, role: role, permission: Permission.viewDashboard),
                _DrawerItem(icon: Icons.trending_up, label: 'Revenue Dashboard', route: AppRoutes.revenueDashboard, role: role, permission: Permission.viewRevenueDashboard),
                _DrawerItem(icon: Icons.auto_awesome, label: 'AI Dashboard', route: AppRoutes.aiDashboard, role: role, permission: Permission.viewAiDashboard),
                if (RBACGuard.hasPermission(role, Permission.viewUsers)) ...[
                  _DrawerSection('Management'),
                  _DrawerItem(icon: Icons.group, label: 'Users', route: AppRoutes.users, role: role, permission: Permission.viewUsers),
                ],
                if (RBACGuard.hasPermission(role, Permission.viewContent)) ...[
                  _DrawerSection('Content'),
                  _DrawerItem(icon: Icons.dashboard_customize, label: 'Templates', route: AppRoutes.templates, role: role, permission: Permission.viewTemplates),
                  _DrawerItem(icon: Icons.auto_fix_high, label: 'Effects', route: AppRoutes.effects, role: role, permission: Permission.viewEffects),
                  _DrawerItem(icon: Icons.filter_alt, label: 'Filters', route: AppRoutes.filters, role: role, permission: Permission.viewFilters),
                  _DrawerItem(icon: Icons.text_fields, label: 'Fonts', route: AppRoutes.fonts, role: role, permission: Permission.viewFonts),
                  _DrawerItem(icon: Icons.music_note, label: 'Audio', route: AppRoutes.audio, role: role, permission: Permission.viewAudio),
                  _DrawerItem(icon: Icons.swap_horiz, label: 'Transitions', route: AppRoutes.transitions, role: role, permission: Permission.viewTransitions),
                  _DrawerItem(icon: Icons.palette, label: 'Color Grades', route: AppRoutes.colorGrades, role: role, permission: Permission.viewColorGrades),
                ],
                if (RBACGuard.hasPermission(role, Permission.viewAiFactory)) ...[
                  _DrawerSection('AI Factory'),
                  _DrawerItem(icon: Icons.auto_awesome, label: 'Generate', route: AppRoutes.aiGenerate, role: role, permission: Permission.viewAiFactory),
                  _DrawerItem(icon: Icons.queue, label: 'Queue', route: AppRoutes.aiQueue, role: role, permission: Permission.viewAiQueue),
                  _DrawerItem(icon: Icons.rate_review, label: 'Review', route: AppRoutes.aiReview, role: role, permission: Permission.viewAiReview),
                ],
                if (RBACGuard.hasPermission(role, Permission.viewMonetization)) ...[
                  _DrawerSection('Monetization'),
                  _DrawerItem(icon: Icons.subscriptions, label: 'Plans', route: AppRoutes.plans, role: role, permission: Permission.viewPlans),
                  _DrawerItem(icon: Icons.card_giftcard, label: 'Coupons', route: AppRoutes.coupons, role: role, permission: Permission.viewCoupons),
                  _DrawerItem(icon: Icons.attach_money, label: 'Revenue', route: AppRoutes.revenue, role: role, permission: Permission.viewRevenue),
                  _DrawerItem(icon: Icons.receipt, label: 'Transactions', route: AppRoutes.transactions, role: role, permission: Permission.viewTransactions),
                ],
                if (RBACGuard.hasPermission(role, Permission.viewAnalytics)) ...[
                  _DrawerSection('Analytics'),
                  _DrawerItem(icon: Icons.analytics, label: 'Overview', route: AppRoutes.analytics, role: role, permission: Permission.viewAnalytics),
                  _DrawerItem(icon: Icons.people, label: 'Retention', route: AppRoutes.retention, role: role, permission: Permission.viewRetention),
                ],
                if (RBACGuard.hasPermission(role, Permission.viewNotifications)) ...[
                  _DrawerSection('Communication'),
                  _DrawerItem(icon: Icons.notifications, label: 'Notifications', route: AppRoutes.notifications, role: role, permission: Permission.viewNotifications),
                  _DrawerItem(icon: Icons.campaign, label: 'Broadcast', route: AppRoutes.broadcast, role: role, permission: Permission.broadcastNotifications),
                ],
                if (RBACGuard.hasPermission(role, Permission.viewSupport)) ...[
                  _DrawerSection('Support'),
                  _DrawerItem(icon: Icons.support, label: 'Tickets', route: AppRoutes.support, role: role, permission: Permission.viewSupport),
                ],
                if (RBACGuard.hasPermission(role, Permission.viewSettings)) ...[
                  _DrawerSection('Settings'),
                  _DrawerItem(icon: Icons.settings, label: 'Settings', route: AppRoutes.settings, role: role, permission: Permission.viewSettings),
                  _DrawerItem(icon: Icons.admin_panel_settings, label: 'Admin Users', route: AppRoutes.adminUsers, role: role, permission: Permission.manageAdminUsers),
                  _DrawerItem(icon: Icons.flag, label: 'Feature Flags', route: AppRoutes.featureFlags, role: role, permission: Permission.manageFeatureFlags),
                  _DrawerItem(icon: Icons.history, label: 'Audit Logs', route: AppRoutes.auditLogs, role: role, permission: Permission.viewAuditLogs),
                  _DrawerItem(icon: Icons.monitor_heart, label: 'System Health', route: AppRoutes.systemHealth, role: role, permission: Permission.viewSystemHealth),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AdminColors.border, width: 0.5)),
            ),
            child: SafeArea(
              top: false,
              child: InkWell(
                onTap: () async {
                  Navigator.of(context).pop();
                  await ref.read(authStateProvider.notifier).logout();
                  if (context.mounted) context.go(AppRoutes.login);
                },
                child: Row(
                  children: [
                    const Icon(Icons.logout, size: 18, color: AdminColors.textMuted),
                    const SizedBox(width: 12),
                    Text('Sign Out', style: AppTypography.bodyMedium.copyWith(color: AdminColors.textMuted)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerSection extends StatelessWidget {
  final String title;
  const _DrawerSection(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
      child: Text(title, style: AppTypography.caption.copyWith(color: AdminColors.textMuted, letterSpacing: 1)),
    );
  }
}

class _DrawerItem extends ConsumerWidget {
  final IconData icon;
  final String label;
  final String route;
  final AdminRole role;
  final Permission permission;

  const _DrawerItem({required this.icon, required this.label, required this.route, required this.role, required this.permission});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!RBACGuard.hasPermission(role, permission)) return const SizedBox.shrink();
    final isActive = GoRouterState.of(context).matchedLocation == route;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isActive ? AdminColors.primary.withValues(alpha: 0.1) : null,
      ),
      child: ListTile(
        dense: true,
        leading: Icon(icon, size: 18, color: isActive ? AdminColors.primary : AdminColors.textMuted),
        title: Text(label, style: AppTypography.bodyMedium.copyWith(
          color: isActive ? AdminColors.primary : AdminColors.textSecondary,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
        )),
        onTap: () {
          Navigator.of(context).pop();
          context.go(route);
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
