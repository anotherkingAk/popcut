import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../shared/widgets/chart_card.dart';

class RetentionScreen extends ConsumerWidget {
  const RetentionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(title: const Text('Retention'), leading: Builder(builder: (ctx) => IconButton(icon: const Icon(Icons.menu), onPressed: () => Scaffold.of(ctx).openDrawer()))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Row(children: [
            _RetentionCard(label: 'D1 Retention', value: '42%', color: AdminColors.primary),
            const SizedBox(width: 10),
            _RetentionCard(label: 'D7 Retention', value: '28%', color: AdminColors.success),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            _RetentionCard(label: 'D30 Retention', value: '15%', color: AdminColors.warning),
            const SizedBox(width: 10),
            _RetentionCard(label: 'Churn Rate', value: '5.2%', color: AdminColors.error),
          ]),
          const SizedBox(height: 16),
          ChartCard(
            title: 'Cohort Retention',
            chart: BarChart(BarChartData(
              gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (value) => FlLine(color: AdminColors.border, strokeWidth: 0.5)),
              titlesData: FlTitlesData(topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) => Text('${value.toInt()}%', style: const TextStyle(fontSize: 9, color: AdminColors.textMuted)))), bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) {
                final weeks = ['W1', 'W2', 'W3', 'W4', 'W5', 'W6', 'W7', 'W8'];
                final idx = value.toInt();
                return Padding(padding: const EdgeInsets.only(top: 4), child: Text(idx < weeks.length ? weeks[idx] : '', style: const TextStyle(fontSize: 8, color: AdminColors.textMuted)));
              }))),
              borderData: FlBorderData(show: false),
              barGroups: List.generate(8, (i) => BarChartGroupData(x: i, barRods: [
                BarChartRodData(toY: [42, 35, 28, 22, 18, 15, 12, 10][i].toDouble(), color: AdminColors.primary, width: 16, borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
                BarChartRodData(toY: [38, 30, 24, 19, 15, 12, 10, 8][i].toDouble(), color: AdminColors.secondary, width: 16, borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
              ])),
            )),
          ),
        ]),
      ),
    );
  }
}

class _RetentionCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _RetentionCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AdminColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AdminColors.border.withValues(alpha: 0.5))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: AppTypography.statValue.copyWith(color: color)),
          const SizedBox(height: 4),
          Text(label, style: AppTypography.caption.copyWith(color: AdminColors.textSecondary)),
        ]),
      ),
    );
  }
}
