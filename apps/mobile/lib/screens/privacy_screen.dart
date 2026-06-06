import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/haptic_service.dart';

class PrivacyScreen extends StatefulWidget {
  final VoidCallback onBack;
  final void Function(String route, {Map<String, dynamic>? args}) onNavigate;

  const PrivacyScreen({
    super.key,
    required this.onBack,
    required this.onNavigate,
  });

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  bool _profileVisible = true;
  bool _activityStatus = true;
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _marketingNotifications = false;
  bool _projectComments = true;
  bool _exportComplete = true;
  bool _usageData = true;
  bool _crashReports = true;
  bool _personalizedAds = false;
  bool _explicitContent = true;
  bool _autoGenLabel = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            HapticService.trigger(HapticLevel.light);
            widget.onBack();
          },
        ),
        title: const Text('Privacy & Security'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _buildSectionHeader('ACCOUNT'),
          _buildActionTile(
            icon: Icons.delete_forever_outlined,
            title: 'Delete Account',
            subtitle: 'Permanently delete your account and data',
            color: AppColors.error,
            onTap: () {
              HapticService.trigger(HapticLevel.light);
              widget.onNavigate('/delete-account');
            },
          ),
          _buildActionTile(
            icon: Icons.download_outlined,
            title: 'Download Your Data',
            subtitle: 'Export all your projects and account data',
            onTap: () {
              HapticService.trigger(HapticLevel.light);
            },
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('PRIVACY'),
          _buildSwitchTile(
            icon: Icons.visibility_outlined,
            title: 'Profile Visibility',
            subtitle: 'Allow others to see your profile',
            value: _profileVisible,
            onChanged: (v) {
              HapticService.trigger(HapticLevel.light);
              setState(() => _profileVisible = v);
            },
          ),
          _buildSwitchTile(
            icon: Icons.circle_outlined,
            title: 'Activity Status',
            subtitle: 'Show when you\'re active',
            value: _activityStatus,
            onChanged: (v) {
              HapticService.trigger(HapticLevel.light);
              setState(() => _activityStatus = v);
            },
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('NOTIFICATIONS'),
          _buildSwitchTile(
            icon: Icons.notifications_outlined,
            title: 'Push Notifications',
            subtitle: 'Receive push notifications',
            value: _pushNotifications,
            onChanged: (v) {
              HapticService.trigger(HapticLevel.light);
              setState(() => _pushNotifications = v);
            },
          ),
          _buildSwitchTile(
            icon: Icons.email_outlined,
            title: 'Email Notifications',
            subtitle: 'Receive email updates',
            value: _emailNotifications,
            onChanged: (v) {
              HapticService.trigger(HapticLevel.light);
              setState(() => _emailNotifications = v);
            },
          ),
          _buildSwitchTile(
            icon: Icons.campaign_outlined,
            title: 'Marketing',
            subtitle: 'Tips, offers, and product updates',
            value: _marketingNotifications,
            onChanged: (v) {
              HapticService.trigger(HapticLevel.light);
              setState(() => _marketingNotifications = v);
            },
          ),
          _buildSwitchTile(
            icon: Icons.comment_outlined,
            title: 'Project Comments',
            subtitle: 'Notify when someone comments on your project',
            value: _projectComments,
            onChanged: (v) {
              HapticService.trigger(HapticLevel.light);
              setState(() => _projectComments = v);
            },
          ),
          _buildSwitchTile(
            icon: Icons.check_circle_outline,
            title: 'Export Complete',
            subtitle: 'Notify when export finishes',
            value: _exportComplete,
            onChanged: (v) {
              HapticService.trigger(HapticLevel.light);
              setState(() => _exportComplete = v);
            },
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('DATA & ANALYTICS'),
          _buildSwitchTile(
            icon: Icons.analytics_outlined,
            title: 'Usage Data',
            subtitle: 'Help us improve with anonymous usage stats',
            value: _usageData,
            onChanged: (v) {
              HapticService.trigger(HapticLevel.light);
              setState(() => _usageData = v);
            },
          ),
          _buildSwitchTile(
            icon: Icons.bug_report_outlined,
            title: 'Crash Reports',
            subtitle: 'Auto-send crash reports to fix issues',
            value: _crashReports,
            onChanged: (v) {
              HapticService.trigger(HapticLevel.light);
              setState(() => _crashReports = v);
            },
          ),
          _buildSwitchTile(
            icon: Icons.ads_click_outlined,
            title: 'Personalized Ads',
            subtitle: 'Allow personalized advertisements',
            value: _personalizedAds,
            onChanged: (v) {
              HapticService.trigger(HapticLevel.light);
              setState(() => _personalizedAds = v);
            },
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('CONTENT'),
          _buildSwitchTile(
            icon: Icons.visibility_outlined,
            title: 'Explicit Content Filter',
            subtitle: 'Filter potentially sensitive content',
            value: _explicitContent,
            onChanged: (v) {
              HapticService.trigger(HapticLevel.light);
              setState(() => _explicitContent = v);
            },
          ),
          _buildSwitchTile(
            icon: Icons.auto_awesome,
            title: 'AI Content Label',
            subtitle: 'Auto-label AI-generated content',
            value: _autoGenLabel,
            onChanged: (v) {
              HapticService.trigger(HapticLevel.light);
              setState(() => _autoGenLabel = v);
            },
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.textLow,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Color? color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        leading: Icon(icon, size: 20, color: color ?? AppColors.textMedium),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: color ?? AppColors.textHigh,
          ),
        ),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textMedium)),
        trailing: const Icon(Icons.chevron_right, size: 18, color: AppColors.textLow),
        onTap: onTap,
        dense: true,
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 4),
        secondary: Icon(icon, size: 20, color: AppColors.textMedium),
        title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textHigh)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textMedium)),
        value: value,
        onChanged: onChanged,
        dense: true,
      ),
    );
  }
}
