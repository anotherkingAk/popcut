import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/haptic_service.dart';

class AdminDashboard extends StatelessWidget {
  final void Function(String route) onNavigate;
  final VoidCallback onBack;
  const AdminDashboard({super.key, required this.onNavigate, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () { HapticService.trigger(HapticLevel.light); onBack(); }),
        title: const Text('Admin'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StatRow(),
            const SizedBox(height: 24),
            _buildGrid(context),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(BuildContext context) {
    final items = [
      _AdminItem('Users', '2,847 total', Icons.group, () => onNavigate('/admin/users')),
      _AdminItem('Effects', '142 active', Icons.auto_awesome, () => onNavigate('/admin/effects')),
      _AdminItem('Templates', '856 total', Icons.bookmark, () {}),
      _AdminItem('Exports', '12.4k today', Icons.file_upload, () {}),
      _AdminItem('Revenue', '₹1.2L', Icons.trending_up, () {}),
      _AdminItem('AI Usage', '8.3k calls', Icons.auto_fix_high, () {}),
    ];

    return Expanded(
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.3, crossAxisSpacing: 10, mainAxisSpacing: 10),
        itemCount: items.length,
        itemBuilder: (context, i) => _buildCard(items[i]),
      ),
    );
  }

  Widget _buildCard(_AdminItem item) {
    return GestureDetector(
      onTap: () { HapticService.trigger(HapticLevel.light); item.onTap(); },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.icon, size: 22, color: AppColors.primary),
            const Spacer(),
            Text(item.value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
            Text(item.label, style: const TextStyle(fontSize: 12, color: AppColors.foregroundSecondary)),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primary]),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem('Users', '2.8K'),
          _StatItem('Exports', '12.4K'),
          _StatItem('Revenue', '₹1.2L'),
          _StatItem('Pro%', '12%'),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.7))),
      ],
    );
  }
}

class _AdminItem {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;
  _AdminItem(this.label, this.value, this.icon, this.onTap);
}
