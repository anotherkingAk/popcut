import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_provider.dart';
import '../services/haptic_service.dart';

class SettingsScreen extends StatelessWidget {
  final VoidCallback onBack;
  final void Function(String route) onNavigate;

  const SettingsScreen({super.key, required this.onBack, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final user = appProvider.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () { HapticService.trigger(HapticLevel.light); onBack(); }),
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          const SizedBox(height: 8),
          _ProfileCard(
            displayName: user?.displayName ?? 'User',
            email: user?.email ?? '',
            tier: user?.tier.name ?? 'Free',
            onUpgrade: () => onNavigate('/subscription'),
          ),
          const SizedBox(height: 24),
          _buildSection('LANGUAGE'),
          _SettingTile(icon: Icons.translate, title: 'App Language', subtitle: 'English', onTap: () {}),
          _SettingTile(icon: Icons.closed_caption, title: 'Caption Language', subtitle: 'Hindi, English + 8 more', onTap: () {}),
          const SizedBox(height: 20),
          _buildSection('ACCOUNT'),
          _SettingTile(icon: Icons.person_outline, title: 'Profile', subtitle: 'Edit name, photo', onTap: () {}),
          _SettingTile(icon: Icons.card_membership_outlined, title: 'Subscription', subtitle: '${user?.tier.name} plan · Upgrade', onTap: () => onNavigate('/subscription')),
          _SettingTile(icon: Icons.cloud_outlined, title: 'Cloud Sync', subtitle: 'Last sync: 2h ago', onTap: () {}),
          const SizedBox(height: 20),
          _buildSection('EDITOR'),
          _SettingTile(icon: Icons.video_settings_outlined, title: 'Canvas', subtitle: '1920 × 1080 · 30fps', onTap: () {}),
          _SettingTile(icon: Icons.save_outlined, title: 'Auto-Save', subtitle: 'Every 30 seconds', onTap: () {}),
          _SettingTile(icon: Icons.storage_outlined, title: 'Storage', subtitle: '1.2 GB used', onTap: () {}),
          const SizedBox(height: 20),
          _buildSection('CONTENT'),
          _SettingTile(icon: Icons.language, title: 'Regional Content', subtitle: 'Hindi, Tamil, Telugu templates', onTap: () {}),
          _SettingTile(icon: Icons.music_note_outlined, title: 'Music Preferences', subtitle: 'Bollywood, Regional, Indie', onTap: () {}),
          const SizedBox(height: 20),
          _buildSection('TEAM'),
          _SettingTile(icon: Icons.workspaces_outlined, title: 'Workspace', subtitle: 'Personal', onTap: () {}),
          _SettingTile(icon: Icons.group_outlined, title: 'Team Members', subtitle: '1/5 Pro seats', onTap: () {}),
          _SettingTile(icon: Icons.palette_outlined, title: 'Brand Kit', subtitle: 'No brand kit', onTap: () {}),
          const SizedBox(height: 20),
          _buildSection('ABOUT'),
          _SettingTile(icon: Icons.info_outline, title: 'Version', subtitle: '1.0.0 (Build 1)', onTap: () {}),
          _SettingTile(icon: Icons.description_outlined, title: 'Licenses', subtitle: 'Open source licenses', onTap: () {}),
          _SettingTile(icon: Icons.privacy_tip_outlined, title: 'Privacy Policy', subtitle: 'Last updated Dec 2025', onTap: () {}),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                HapticService.trigger(HapticLevel.medium);
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: AppColors.surface,
                    title: const Text('Sign Out', style: TextStyle(color: Colors.white)),
                    content: const Text('Are you sure you want to sign out?', style: TextStyle(color: AppColors.foregroundSecondary)),
                    actions: [
                      TextButton(onPressed: () { HapticService.trigger(HapticLevel.light); Navigator.pop(ctx); }, child: const Text('Cancel')),
                      TextButton(
                        onPressed: () {
                          HapticService.trigger(HapticLevel.heavy);
                          Navigator.pop(ctx);
                          context.read<AppProvider>().signOut();
                        },
                        child: const Text('Sign Out', style: TextStyle(color: AppColors.destructive)),
                      ),
                    ],
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.destructive,
                side: BorderSide(color: AppColors.destructive.withValues(alpha: 0.3)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Sign Out', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.foregroundMuted, letterSpacing: 1)),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final String displayName;
  final String? email;
  final String tier;
  final VoidCallback onUpgrade;

  const _ProfileCard({
    required this.displayName,
    this.email,
    required this.tier,
    required this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
      child: Row(
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primary]),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(child: Text(
              (displayName.isNotEmpty ? displayName[0] : 'U').toUpperCase(),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white),
            )),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(displayName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                Text('$tier Plan', style: const TextStyle(fontSize: 12, color: AppColors.foregroundSecondary)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () { HapticService.trigger(HapticLevel.light); onUpgrade(); },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primary]),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('Upgrade', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _SettingTile({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5))),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        leading: Icon(icon, size: 20, color: AppColors.foregroundSecondary),
        title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.foregroundSecondary)),
        trailing: const Icon(Icons.chevron_right, size: 18, color: AppColors.foregroundMuted),
        onTap: () { HapticService.trigger(HapticLevel.light); onTap(); },
        dense: true,
      ),
    );
  }
}
