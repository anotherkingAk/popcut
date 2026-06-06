import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/haptic_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  final void Function(String route, {Map<String, dynamic>? args}) onNavigate;
  final VoidCallback onBack;

  const AdminDashboardScreen({
    super.key,
    required this.onNavigate,
    required this.onBack,
  });

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _announcementController = TextEditingController();
  bool _showAnnouncementComposer = false;

  @override
  void dispose() {
    _announcementController.dispose();
    super.dispose();
  }

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
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.campaign_outlined),
            onPressed: () {
              HapticService.trigger(HapticLevel.light);
              setState(() => _showAnnouncementComposer = !_showAnnouncementComposer);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_showAnnouncementComposer) _buildAnnouncementComposer(),
            _buildStatsRow(),
            const SizedBox(height: 24),
            Text('Quick Access', style: AppTypography.titleSm),
            const SizedBox(height: 12),
            _buildQuickGrid(),
            const SizedBox(height: 24),
            Text('Content Moderation', style: AppTypography.titleSm),
            const SizedBox(height: 12),
            _buildModerationList(),
            const SizedBox(height: 24),
            Text('System Health', style: AppTypography.titleSm),
            const SizedBox(height: 12),
            _buildSystemHealth(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnouncementComposer() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.campaign, size: 18, color: AppColors.brand500),
              const SizedBox(width: 8),
              Text('Send Announcement', style: AppTypography.titleSm),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _announcementController,
            maxLines: 3,
            style: const TextStyle(color: AppColors.textHigh, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Write announcement message...',
              hintStyle: const TextStyle(color: AppColors.textLow),
              filled: true,
              fillColor: AppColors.bgElevated,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    HapticService.trigger(HapticLevel.light);
                    setState(() {
                      _showAnnouncementComposer = false;
                      _announcementController.clear();
                    });
                  },
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    HapticService.trigger(HapticLevel.medium);
                  },
                  child: const Text('Send to All'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return SizedBox(
      height: 100,
      child: Row(
        children: [
          _statCard('Total Users', '2,847', Icons.group, AppColors.brand500),
          const SizedBox(width: 10),
          _statCard('Active Today', '843', Icons.trending_up, AppColors.success),
          const SizedBox(width: 10),
          _statCard('Revenue', '\$12.4k', Icons.attach_money, AppColors.warning),
          const SizedBox(width: 10),
          _statCard('New Projects', '156', Icons.movie_creation, AppColors.info),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
            Text(label, style: const TextStyle(fontSize: 8, color: AppColors.textLow), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickGrid() {
    final items = [
      _AdminItem('Users', 'Manage users', Icons.group, () => widget.onNavigate('/admin/users'), AppColors.brand500),
      _AdminItem('Content', 'Moderation queue', Icons.content_paste, () => widget.onNavigate('/admin/content'), AppColors.success),
      _AdminItem('Analytics', 'View reports', Icons.analytics, () => widget.onNavigate('/admin/analytics'), AppColors.info),
      _AdminItem('Effects', 'Manage effects', Icons.auto_awesome, () => widget.onNavigate('/admin/effects'), AppColors.warning),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.5,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => _buildQuickCard(items[i]),
    );
  }

  Widget _buildQuickCard(_AdminItem item) {
    return GestureDetector(
      onTap: () {
        HapticService.trigger(HapticLevel.light);
        item.onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(item.icon, size: 20, color: item.color),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(item.label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textHigh)),
                  Text(item.subtitle, style: const TextStyle(fontSize: 10, color: AppColors.textLow)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 16, color: AppColors.textLow),
          ],
        ),
      ),
    );
  }

  Widget _buildModerationList() {
    final items = [
      {'label': 'Reported Projects', 'count': '12', 'color': AppColors.error},
      {'label': 'Flagged Content', 'count': '8', 'color': AppColors.warning},
      {'label': 'Review Queue', 'count': '23', 'color': AppColors.info},
    ];
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: items.map((item) {
          final color = item['color'] as Color;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item['count'] as String,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color),
                  ),
                ),
                const SizedBox(width: 12),
                Text(item['label'] as String, style: const TextStyle(fontSize: 13, color: AppColors.textHigh)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSystemHealth() {
    final metrics = [
      {'label': 'Server Status', 'value': 'Online', 'color': AppColors.success},
      {'label': 'API Usage', 'value': '68%', 'color': AppColors.warning},
      {'label': 'Error Rate', 'value': '0.3%', 'color': AppColors.success},
      {'label': 'Avg Response', 'value': '124ms', 'color': AppColors.success},
    ];
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: metrics.map((m) {
          final color = m['color'] as Color;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(m['label'] as String, style: const TextStyle(fontSize: 13, color: AppColors.textHigh)),
                ),
                Text(
                  m['value'] as String,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _AdminItem {
  final String label;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  _AdminItem(this.label, this.subtitle, this.icon, this.onTap, this.color);
}
