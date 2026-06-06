import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/stat_card.dart';
import '../../../shared/widgets/stat_row.dart';
import '../../../shared/widgets/error_widget.dart';
import '../providers/dashboard_provider.dart';

class AiDashboardScreen extends ConsumerStatefulWidget {
  const AiDashboardScreen({super.key});

  @override
  ConsumerState<AiDashboardScreen> createState() => _AiDashboardScreenState();
}

class _AiDashboardScreenState extends ConsumerState<AiDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dashboardProvider.notifier).fetchDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardProvider);
    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(title: const Text('AI Dashboard'), leading: Builder(builder: (ctx) => IconButton(icon: const Icon(Icons.menu), onPressed: () => Scaffold.of(ctx).openDrawer()))),
      body: state.isLoading && state.stats.totalUsers == 0
          ? const Center(child: CircularProgressIndicator())
          : state.error != null && state.stats.totalUsers == 0
              ? AppErrorWidget(message: state.error!, onRetry: () => ref.read(dashboardProvider.notifier).fetchDashboard())
              : RefreshIndicator(
                  onRefresh: () => ref.read(dashboardProvider.notifier).fetchDashboard(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(children: [
                      Row(children: [
                        Expanded(child: StatCard(label: 'Active Jobs', value: Formatters.compactNumber(state.stats.activeJobs), icon: Icons.play_circle, color: AdminColors.primary)),
                        const SizedBox(width: 10),
                        Expanded(child: StatCard(label: 'Exports Today', value: Formatters.compactNumber(state.stats.exportsToday), icon: Icons.file_download, color: AdminColors.success)),
                      ]),
                      const SizedBox(height: 10),
                      Row(children: [
                        Expanded(child: StatCard(label: 'Exports (Month)', value: Formatters.compactNumber(state.stats.exportsThisMonth), icon: Icons.date_range, color: AdminColors.warning)),
                        const SizedBox(width: 10),
                        Expanded(child: StatCard(label: 'Pending Approvals', value: Formatters.compactNumber(state.stats.pendingApprovals), icon: Icons.pending, color: AdminColors.secondary)),
                      ]),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: AdminColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AdminColors.border.withValues(alpha: 0.5))),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Performance Metrics', style: AppTypography.titleSmall.copyWith(color: AdminColors.textPrimary)),
                          const SizedBox(height: 12),
                          StatRow(label: 'Server Uptime', value: '${state.stats.serverUptime.toStringAsFixed(1)}%', valueColor: state.stats.serverUptime > 99 ? AdminColors.success : AdminColors.warning),
                          StatRow(label: 'API Error Rate', value: '${state.stats.apiErrorRate.toStringAsFixed(2)}%', valueColor: state.stats.apiErrorRate < 1 ? AdminColors.success : AdminColors.error),
                          StatRow(label: 'Avg Response Time', value: '${state.stats.avgResponseTime.toStringAsFixed(0)}ms', valueColor: state.stats.avgResponseTime < 200 ? AdminColors.success : AdminColors.warning),
                          StatRow(label: 'DAU', value: Formatters.compactNumber(state.stats.dau.toInt()), valueColor: AdminColors.primary),
                          StatRow(label: 'MAU', value: Formatters.compactNumber(state.stats.mau.toInt()), valueColor: AdminColors.secondary),
                        ]),
                      ),
                    ]),
                  ),
                ),
    );
  }
}
