import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';

class AdminDrawer extends StatelessWidget {
  final String currentRoute;
  final void Function(String route) onNavigate;

  const AdminDrawer({
    super.key,
    required this.currentRoute,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Drawer(
      backgroundColor: AdminColors.background,
      child: Column(
        children: [
          _buildHeader(user?.displayName ?? 'Admin', user?.email ?? ''),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _DrawerItem(
                  icon: Icons.dashboard,
                  label: 'Dashboard',
                  route: '/dashboard',
                  isSelected: currentRoute == '/dashboard',
                  onTap: () => _navigate(context, '/dashboard'),
                ),
                _DrawerItem(
                  icon: Icons.group,
                  label: 'Users',
                  route: '/users',
                  isSelected: currentRoute == '/users',
                  onTap: () => _navigate(context, '/users'),
                ),
                _DrawerItem(
                  icon: Icons.checklist,
                  label: 'Approvals',
                  route: '/approvals',
                  isSelected: currentRoute == '/approvals',
                  onTap: () => _navigate(context, '/approvals'),
                  badge: null,
                ),
                _DrawerItem(
                  icon: Icons.auto_awesome,
                  label: 'AI Factory',
                  route: '/ai-factory',
                  isSelected: currentRoute == '/ai-factory',
                  onTap: () => _navigate(context, '/ai-factory'),
                ),
                _DrawerItem(
                  icon: Icons.notifications,
                  label: 'Notifications',
                  route: '/notifications',
                  isSelected: currentRoute == '/notifications',
                  onTap: () => _navigate(context, '/notifications'),
                  badge: null,
                ),
                _DrawerItem(
                  icon: Icons.analytics,
                  label: 'Analytics',
                  route: '/analytics',
                  isSelected: currentRoute == '/analytics',
                  onTap: () => _navigate(context, '/analytics'),
                ),
                _DrawerItem(
                  icon: Icons.settings,
                  label: 'Settings',
                  route: '/settings',
                  isSelected: currentRoute == '/settings',
                  onTap: () => _navigate(context, '/settings'),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AdminColors.border),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AdminColors.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        user?.initials ?? 'A',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AdminColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.displayName ?? 'Admin',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AdminColors.textHigh,
                          ),
                        ),
                        Text(
                          user?.email ?? '',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AdminColors.textLow,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigate(BuildContext context, String route) {
    Navigator.of(context).pop();
    onNavigate(route);
  }

  Widget _buildHeader(String name, String email) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQueryData.fromView(
          WidgetsBinding.instance.platformDispatcher.views.single,
        ).padding.top +
            20,
        bottom: 20,
        left: 20,
        right: 20,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AdminColors.primaryDim, AdminColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.admin_panel_settings,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'PopCut Admin',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Control your ecosystem',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final bool isSelected;
  final VoidCallback onTap;
  final int? badge;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.isSelected,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
      decoration: BoxDecoration(
        color: isSelected
            ? AdminColors.primary.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          size: 20,
          color: isSelected ? AdminColors.primary : AdminColors.textMedium,
        ),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? AdminColors.primary : AdminColors.textHigh,
          ),
        ),
        trailing: badge != null && badge! > 0
            ? Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AdminColors.error,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$badge',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              )
            : null,
        onTap: onTap,
        dense: true,
        horizontalTitleGap: 12,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      ),
    );
  }
}
