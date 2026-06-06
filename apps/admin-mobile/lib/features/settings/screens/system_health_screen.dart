import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../shared/widgets/stat_row.dart';

class SystemHealthScreen extends ConsumerWidget {
  const SystemHealthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(title: const Text('System Health'), leading: Builder(builder: (ctx) => IconButton(icon: const Icon(Icons.menu), onPressed: () => Scaffold.of(ctx).openDrawer())), actions: [IconButton(icon: const Icon(Icons.refresh, size: 18), onPressed: () {})]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AdminColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AdminColors.border.withValues(alpha: 0.5))),
            child: Column(children: [
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(color: AdminColors.success.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(36)),
                child: const Icon(Icons.check_circle, size: 36, color: AdminColors.success),
              ),
              const SizedBox(height: 12),
              Text('All Systems Operational', style: AppTypography.headlineSmall.copyWith(color: AdminColors.textPrimary)),
              const SizedBox(height: 24),
              StatRow(label: 'Server Uptime', value: '99.97%', valueColor: AdminColors.success),
              StatRow(label: 'API Response Time', value: '142ms', valueColor: AdminColors.success),
              StatRow(label: 'Error Rate', value: '0.03%', valueColor: AdminColors.success),
              StatRow(label: 'Active Connections', value: '1,247', valueColor: AdminColors.primary),
              StatRow(label: 'Database', value: 'Healthy', valueColor: AdminColors.success),
              StatRow(label: 'Cache', value: 'Healthy', valueColor: AdminColors.success),
              StatRow(label: 'Storage', value: '68% Used', valueColor: AdminColors.warning),
              StatRow(label: 'Memory', value: '45% Used', valueColor: AdminColors.success),
            ]),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AdminColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AdminColors.border.withValues(alpha: 0.5))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Services', style: AppTypography.titleSmall.copyWith(color: AdminColors.textPrimary)),
              const Divider(height: 24),
              _serviceRow('Web Server', 'Running', AdminColors.success),
              _serviceRow('AI Engine', 'Running', AdminColors.success),
              _serviceRow('Database', 'Healthy', AdminColors.success),
              _serviceRow('Redis Cache', 'Healthy', AdminColors.success),
              _serviceRow('Queue Worker', 'Running', AdminColors.success),
              _serviceRow('WebSocket', 'Connected', AdminColors.success),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _serviceRow(String name, String status, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 10),
        Expanded(child: Text(name, style: AppTypography.bodySmall.copyWith(color: AdminColors.textSecondary))),
        Text(status, style: AppTypography.labelLarge.copyWith(color: color)),
      ]),
    );
  }
}
