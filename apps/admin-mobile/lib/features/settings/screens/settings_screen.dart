import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(title: const Text('Settings'), leading: Builder(builder: (ctx) => IconButton(icon: const Icon(Icons.menu), onPressed: () => Scaffold.of(ctx).openDrawer()))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SettingTile(icon: Icons.person, label: 'Profile', subtitle: 'Manage your account'),
          _SettingTile(icon: Icons.security, label: 'Security', subtitle: 'Password, 2FA'),
          _SettingTile(icon: Icons.notifications, label: 'Notifications', subtitle: 'Email, push preferences'),
          _SettingTile(icon: Icons.language, label: 'Localization', subtitle: 'Language, region, timezone'),
          _SettingTile(icon: Icons.palette, label: 'Appearance', subtitle: 'Theme, dark mode'),
          _SettingTile(icon: Icons.storage, label: 'Storage', subtitle: 'Cache, data management'),
          _SettingTile(icon: Icons.api, label: 'API Configuration', subtitle: 'Endpoints, keys'),
        ],
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  const _SettingTile({required this.icon, required this.label, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: AdminColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AdminColors.border.withValues(alpha: 0.5))),
      child: ListTile(
        leading: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: AdminColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 18, color: AdminColors.primary),
        ),
        title: Text(label, style: AppTypography.titleMedium.copyWith(color: AdminColors.textPrimary)),
        subtitle: Text(subtitle, style: AppTypography.caption.copyWith(color: AdminColors.textMuted)),
        trailing: const Icon(Icons.chevron_right, size: 16, color: AdminColors.textMuted),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
