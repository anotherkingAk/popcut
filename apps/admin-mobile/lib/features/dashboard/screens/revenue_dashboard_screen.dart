import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/stat_card.dart';
import '../../../shared/widgets/chart_card.dart';
import '../../../shared/widgets/error_widget.dart';
import '../providers/dashboard_provider.dart';

class RevenueDashboardScreen extends ConsumerStatefulWidget {
  const RevenueDashboardScreen({super.key});

  @override
  ConsumerState<RevenueDashboardScreen> createState() => _RevenueDashboardScreenState();
}

class _RevenueDashboardScreenState extends ConsumerState<RevenueDashboardScreen> {
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
      appBar: AppBar(title: const Text('Revenue Dashboard'), leading: Builder(builder: (ctx) => IconButton(icon: const Icon(Icons.menu), onPressed: () => Scaffold.of(ctx).openDrawer()))),
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
                        Expanded(child: StatCard(label: 'Revenue Today', value: Formatters.compactCurrency(state.stats.revenueToday), icon: Icons.today, color: AdminColors.primary)),
                        const SizedBox(width: 10),
                        Expanded(child: StatCard(label: 'This Month', value: Formatters.compactCurrency(state.stats.revenueThisMonth), icon: Icons.date_range, color: AdminColors.success)),
                      ]),
                      const SizedBox(height: 10),
                      Row(children: [
                        Expanded(child: StatCard(label: 'This Year', value: Formatters.compactCurrency(state.stats.revenueThisYear), icon: Icons.calendar_today, color: AdminColors.warning)),
                        const SizedBox(width: 10),
                        Expanded(child: StatCard(label: 'Avg Response', value: '${state.stats.avgResponseTime.toInt()}ms', icon: Icons.speed, color: AdminColors.secondary)),
                      ]),
                      const SizedBox(height: 16),
                      _buildRevenueChart(state),
                    ]),
                  ),
                ),
    );
  }

  Widget _buildRevenueChart(DashboardState state) {
    final points = state.chartData.revenueHistory;
    if (points.isEmpty) return const SizedBox.shrink();
    final maxY = points.fold<double>(0, (max, p) => p.amount > max ? p.amount : max);
    return ChartCard(
      title: 'Revenue History',
      chart: BarChart(BarChartData(
        gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (value) => FlLine(color: AdminColors.border, strokeWidth: 0.5)),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 45, getTitlesWidget: (value, meta) => Text('\$${value.toInt()}', style: const TextStyle(fontSize: 9, color: AdminColors.textMuted)))),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) {
            final idx = value.toInt();
            if (idx < 0 || idx >= points.length) return const SizedBox.shrink();
            return Padding(padding: const EdgeInsets.only(top: 4), child: Text('${points[idx].date.month}/${points[idx].date.day}', style: const TextStyle(fontSize: 8, color: AdminColors.textMuted)));
          })),
        ),
        borderData: FlBorderData(show: false),
        barGroups: points.asMap().entries.map((e) => BarChartGroupData(x: e.key, barRods: [BarChartRodData(toY: e.value.amount, color: AdminColors.primary, width: 12, borderRadius: const BorderRadius.vertical(top: Radius.circular(4)))])).toList(),
      )),
    );
  }
}
