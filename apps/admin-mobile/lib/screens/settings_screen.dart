import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';

class SettingsScreen extends StatefulWidget {
  final String currentRoute;
  final void Function(String route) onNavigate;
  final VoidCallback? onLogout;

  const SettingsScreen({
    super.key,
    required this.currentRoute,
    required this.onNavigate,
    this.onLogout,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _themeToggle = false;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(
        title: const Text('Settings'),
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildProfileSection(user?.displayName ?? 'Admin',
              user?.email ?? ''),
          const SizedBox(height: 24),
          _buildSectionTitle('Preferences'),
          const SizedBox(height: 8),
          _buildSettingTile(
            icon: Icons.dark_mode,
            title: 'Dark Theme',
            subtitle: 'Always enabled',
            trailing: Switch(
              value: _themeToggle,
              onChanged: (v) => setState(() => _themeToggle = v),
            ),
          ),
          _buildSettingTile(
            icon: Icons.notifications,
            title: 'Push Notifications',
            subtitle: 'Admin alerts and updates',
            trailing: Switch(
              value: true,
              onChanged: (v) {},
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Account'),
          const SizedBox(height: 8),
          _buildSettingTile(
            icon: Icons.person,
            title: 'Profile',
            subtitle: 'View and edit profile',
            onTap: () {},
            showArrow: true,
          ),
          _buildSettingTile(
            icon: Icons.security,
            title: 'Security',
            subtitle: 'Password and 2FA',
            onTap: () {},
            showArrow: true,
          ),
          _buildSettingTile(
            icon: Icons.api,
            title: 'API Access',
            subtitle: 'Manage API keys',
            onTap: () {},
            showArrow: true,
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Support'),
          const SizedBox(height: 8),
          _buildSettingTile(
            icon: Icons.help_outline,
            title: 'Help Center',
            subtitle: 'Documentation and guides',
            onTap: () {},
            showArrow: true,
          ),
          _buildSettingTile(
            icon: Icons.feedback_outlined,
            title: 'Send Feedback',
            subtitle: 'Report issues or suggest features',
            onTap: () {},
            showArrow: true,
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('About'),
          const SizedBox(height: 8),
          _buildSettingTile(
            icon: Icons.info_outline,
            title: 'Version',
            subtitle: '1.0.0 (build 1)',
          ),
          _buildSettingTile(
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            onTap: () {},
            showArrow: true,
          ),
          _buildSettingTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            onTap: () {},
            showArrow: true,
          ),
          const SizedBox(height: 32),
          Consumer<AuthProvider>(
            builder: (context, auth, _) {
              return SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _handleLogout(context),
                  icon: const Icon(Icons.logout, size: 16),
                  label: const Text('Sign Out'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AdminColors.error,
                    side: BorderSide(
                        color: AdminColors.error.withValues(alpha: 0.3)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildProfileSection(String name, String email) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AdminColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AdminColors.primaryDim, AdminColors.primary],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Icon(Icons.admin_panel_settings,
                  size: 28, color: Colors.white),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AdminColors.textHigh,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AdminColors.textMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AdminColors.textLow,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    bool showArrow = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: AdminColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AdminColors.border),
      ),
      child: ListTile(
        leading: Icon(icon, size: 20, color: AdminColors.textMedium),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AdminColors.textHigh,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: AdminColors.textLow,
                ),
              )
            : null,
        trailing: trailing ??
            (showArrow
                ? const Icon(Icons.chevron_right,
                    size: 18, color: AdminColors.textLow)
                : null),
        onTap: onTap,
        dense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AdminColors.surface,
        title: const Text('Sign Out',
            style: TextStyle(color: AdminColors.textHigh)),
        content: const Text(
          'Are you sure you want to sign out?',
          style: TextStyle(color: AdminColors.textMedium),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminColors.error,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final dp = context.read<DashboardProvider>();
      dp.clearError();
      await context.read<AuthProvider>().logout();
      widget.onLogout?.call();
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
          _item(Icons.auto_awesome, 'AI Factory', '/ai-factory'),
          _item(Icons.notifications, 'Notifications', '/notifications'),
          _item(Icons.analytics, 'Analytics', '/analytics'),
          _item(Icons.settings, 'Settings', '/settings', selected: true),
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
