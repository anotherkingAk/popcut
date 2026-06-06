import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../app.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/stat_card.dart';
import '../../../shared/widgets/chart_card.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/loading_skeleton.dart';
import '../providers/dashboard_provider.dart';

class ExecutiveDashboardScreen extends ConsumerStatefulWidget {
  const ExecutiveDashboardScreen({super.key});

  @override
  ConsumerState<ExecutiveDashboardScreen> createState() => _ExecutiveDashboardScreenState();
}

class _ExecutiveDashboardScreenState extends ConsumerState<ExecutiveDashboardScreen> {
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
      appBar: AppBar(
        title: const Text('Executive Dashboard'),
        leading: Builder(builder: (ctx) => IconButton(icon: const Icon(Icons.menu), onPressed: () => Scaffold.of(ctx).openDrawer())),
        actions: [
          IconButton(icon: const Icon(Icons.refresh, size: 18), onPressed: () => ref.read(dashboardProvider.notifier).fetchDashboard()),
        ],
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(DashboardState state) {
    if (state.isLoading && state.stats.totalUsers == 0) return const Center(child: CircularProgressIndicator());
    if (state.error != null && state.stats.totalUsers == 0) {
      return AppErrorWidget(message: state.error!, onRetry: () => ref.read(dashboardProvider.notifier).fetchDashboard());
    }
    return AppPullToRefresh(
      onRefresh: () => ref.read(dashboardProvider.notifier).fetchDashboard(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatsGrid(state),
            const SizedBox(height: 16),
            _buildRevenueChart(state),
            const SizedBox(height: 16),
            _buildSystemHealth(state),
            const SizedBox(height: 16),
            _buildQuickActions(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(DashboardState state) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: StatCard(label: 'Total Users', value: Formatters.compactNumber(state.stats.totalUsers), icon: Icons.group, color: AdminColors.primary, subtitle: '${Formatters.compactNumber(state.stats.newUsersToday)} today')),
            const SizedBox(width: 10),
            Expanded(child: StatCard(label: 'Active Today', value: Formatters.compactNumber(state.stats.activeToday), icon: Icons.trending_up, color: AdminColors.success)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: StatCard(label: 'Revenue (Month)', value: Formatters.compactCurrency(state.stats.revenueThisMonth), icon: Icons.attach_money, color: AdminColors.warning, subtitle: '${Formatters.compactCurrency(state.stats.revenueToday)} today')),
            const SizedBox(width: 10),
            Expanded(child: StatCard(label: 'Exports Today', value: Formatters.compactNumber(state.stats.exportsToday), icon: Icons.file_upload, color: AdminColors.secondary, subtitle: '${Formatters.compactNumber(state.stats.exportsThisMonth)} this month')),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: StatCard(label: 'Active AI Jobs', value: Formatters.compactNumber(state.stats.activeJobs), icon: Icons.auto_awesome, color: AdminColors.primary)),
            const SizedBox(width: 10),
            Expanded(child: StatCard(label: 'Pending', value: Formatters.compactNumber(state.stats.pendingApprovals + state.stats.openTickets), icon: Icons.checklist, color: AdminColors.warning, subtitle: '${state.stats.pendingApprovals} approvals, ${state.stats.openTickets} tickets')),
          ],
        ),
      ],
    );
  }

  Widget _buildRevenueChart(DashboardState state) {
    final points = state.chartData.revenueHistory;
    if (points.isEmpty) return const SizedBox.shrink();
    final maxY = points.fold<double>(0, (max, p) => p.amount > max ? p.amount : max);
    final minY = points.fold<double>(double.infinity, (min, p) => p.amount < min ? p.amount : min);
    final adjustedMin = minY == double.infinity ? 0 : minY * 0.9;
    final adjustedMax = maxY == 0 ? 1000 : maxY * 1.1;

    return ChartCard(
      title: 'Revenue (7 days)',
      chart: LineChart(
        LineChartData(
          gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: (adjustedMax - adjustedMin) / 4, getDrawingHorizontalLine: (value) => FlLine(color: AdminColors.border, strokeWidth: 0.5)),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 45, getTitlesWidget: (value, meta) => Text('\$${value.toInt()}', style: const TextStyle(fontSize: 9, color: AdminColors.textMuted)))),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 20, interval: 1, getTitlesWidget: (value, meta) {
              final idx = value.toInt();
              if (idx < 0 || idx >= points.length) return const SizedBox.shrink();
              return Padding(padding: const EdgeInsets.only(top: 4), child: Text(['Mon','Tue','Wed','Thu','Fri','Sat','Sun'][points[idx].date.weekday - 1], style: const TextStyle(fontSize: 9, color: AdminColors.textMuted)));
            })),
          ),
          borderData: FlBorderData(show: false),
          minX: 0, maxX: (points.length - 1).toDouble(), minY: adjustedMin.toDouble(), maxY: adjustedMax.toDouble(),
          lineBarsData: [
            LineChartBarData(
              spots: points.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.amount)).toList(),
              isCurved: true, color: AdminColors.primary, barWidth: 2.5, dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: true, color: AdminColors.primary.withValues(alpha: 0.1)),
            ),
          ],
          lineTouchData: LineTouchData(touchTooltipData: LineTouchTooltipData(getTooltipItems: (spots) => spots.map((spot) => LineTooltipItem('\$${spot.y.toStringAsFixed(0)}', const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600))).toList())),
        ),
      ),
    );
  }

  Widget _buildSystemHealth(DashboardState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AdminColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AdminColors.border.withValues(alpha: 0.5))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('System Health', style: AppTypography.titleSmall.copyWith(color: AdminColors.textPrimary)),
        const SizedBox(height: 16),
        _healthRow('Server Uptime', '${state.stats.serverUptime.toStringAsFixed(1)}%', state.stats.serverUptime > 99 ? AdminColors.success : AdminColors.warning),
        const SizedBox(height: 8),
        _healthRow('API Error Rate', '${state.stats.apiErrorRate.toStringAsFixed(2)}%', state.stats.apiErrorRate < 1 ? AdminColors.success : state.stats.apiErrorRate < 5 ? AdminColors.warning : AdminColors.error),
        const SizedBox(height: 8),
        _healthRow('Avg Response', '${state.stats.avgResponseTime.toStringAsFixed(0)}ms', state.stats.avgResponseTime < 200 ? AdminColors.success : state.stats.avgResponseTime < 500 ? AdminColors.warning : AdminColors.error),
        const SizedBox(height: 8),
        _healthRow('DAU / MAU', '${Formatters.compactNumber(state.stats.dau.toInt())} / ${Formatters.compactNumber(state.stats.mau.toInt())}', AdminColors.secondary),
      ]),
    );
  }

  Widget _healthRow(String label, String value, Color color) {
    return Row(children: [
      Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 10),
      Expanded(child: Text(label, style: const TextStyle(fontSize: 12, color: AdminColors.textSecondary))),
      Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
    ]);
  }

  Widget _buildQuickActions() {
    final actions = [
      _QuickAction(Icons.group, 'Users', AdminColors.primary, () => context.go(AppRoutes.users)),
      _QuickAction(Icons.auto_awesome, 'AI Factory', AdminColors.secondary, () => context.go(AppRoutes.aiFactory)),
      _QuickAction(Icons.analytics, 'Analytics', AdminColors.warning, () => context.go(AppRoutes.analytics)),
      _QuickAction(Icons.settings, 'Settings', AdminColors.success, () => context.go(AppRoutes.settings)),
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Quick Access', style: AppTypography.titleSmall.copyWith(color: AdminColors.textPrimary)),
      const SizedBox(height: 12),
      Row(children: actions.map((a) => Expanded(child: Padding(
        padding: const EdgeInsets.only(right: 8),
        child: GestureDetector(
          onTap: a.onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(color: a.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: a.color.withValues(alpha: 0.2))),
            child: Column(children: [Icon(a.icon, size: 22, color: a.color), const SizedBox(height: 6), Text(a.label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: a.color))]),
          ),
        ),
      ))).toList()),
    ]);
  }

}

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  _QuickAction(this.icon, this.label, this.color, this.onTap);
}

class AppPullToRefresh extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  const AppPullToRefresh({super.key, required this.child, required this.onRefresh});
  @override
  Widget build(BuildContext context) => RefreshIndicator(color: AdminColors.primary, backgroundColor: AdminColors.surface, onRefresh: onRefresh, child: child);
}
