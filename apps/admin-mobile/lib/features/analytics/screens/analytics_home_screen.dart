import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/colors.dart';
import '../../../shared/widgets/chart_card.dart';
import '../../../shared/widgets/error_widget.dart';
import '../providers/analytics_provider.dart';

class AnalyticsHomeScreen extends ConsumerStatefulWidget {
  const AnalyticsHomeScreen({super.key});

  @override
  ConsumerState<AnalyticsHomeScreen> createState() => _AnalyticsHomeScreenState();
}

class _AnalyticsHomeScreenState extends ConsumerState<AnalyticsHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => ref.read(analyticsProvider.notifier).fetchAll());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(analyticsProvider);
    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(title: const Text('Analytics'), leading: Builder(builder: (ctx) => IconButton(icon: const Icon(Icons.menu), onPressed: () => Scaffold.of(ctx).openDrawer())), actions: [IconButton(icon: const Icon(Icons.refresh, size: 18), onPressed: () => ref.read(analyticsProvider.notifier).fetchAll())]),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? AppErrorWidget(message: state.error!, onRetry: () => ref.read(analyticsProvider.notifier).fetchAll())
              : RefreshIndicator(
                  onRefresh: () => ref.read(analyticsProvider.notifier).fetchAll(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(children: [
                      ChartCard(
                        title: 'Revenue Trend',
                        chart: LineChart(LineChartData(
                          gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (value) => FlLine(color: AdminColors.border, strokeWidth: 0.5)),
                          titlesData: FlTitlesData(topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 45, getTitlesWidget: (value, meta) => Text('\$${value.toInt()}', style: const TextStyle(fontSize: 9, color: AdminColors.textMuted)))), bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) => Text('${value.toInt() + 1}', style: const TextStyle(fontSize: 8, color: AdminColors.textMuted))))),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [LineChartBarData(spots: List.generate(12, (i) => FlSpot(i.toDouble(), (i * 1000 + 5000).toDouble())), isCurved: true, color: AdminColors.primary, barWidth: 2.5, dotData: const FlDotData(show: false), belowBarData: BarAreaData(show: true, color: AdminColors.primary.withValues(alpha: 0.1)))],
                        )),
                      ),
                      const SizedBox(height: 16),
                      ChartCard(
                        title: 'User Growth',
                        chart: BarChart(BarChartData(
                          gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (value) => FlLine(color: AdminColors.border, strokeWidth: 0.5)),
                          titlesData: FlTitlesData(topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) => Text('${value.toInt()}', style: const TextStyle(fontSize: 9, color: AdminColors.textMuted)))), bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) => Text('${value.toInt() + 1}', style: const TextStyle(fontSize: 8, color: AdminColors.textMuted))))),
                          borderData: FlBorderData(show: false),
                          barGroups: List.generate(12, (i) => BarChartGroupData(x: i, barRods: [BarChartRodData(toY: (i * 500 + 1000).toDouble(), color: AdminColors.secondary, width: 12, borderRadius: const BorderRadius.vertical(top: Radius.circular(4)))])),
                        )),
                      ),
                    ]),
                  ),
                ),
    );
  }
}
