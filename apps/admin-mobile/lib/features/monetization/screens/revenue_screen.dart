import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/stat_card.dart';
import '../../../shared/widgets/stat_row.dart';
import '../../../shared/widgets/empty_state.dart';

class RevenueScreen extends ConsumerWidget {
  const RevenueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(title: const Text('Revenue'), leading: Builder(builder: (ctx) => IconButton(icon: const Icon(Icons.menu), onPressed: () => Scaffold.of(ctx).openDrawer()))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Row(children: [
            Expanded(child: StatCard(label: 'Revenue Today', value: Formatters.compactCurrency(12450), icon: Icons.today, color: AdminColors.primary)),
            const SizedBox(width: 10),
            Expanded(child: StatCard(label: 'Revenue Month', value: Formatters.compactCurrency(345000), icon: Icons.date_range, color: AdminColors.success)),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: StatCard(label: 'Revenue Year', value: Formatters.compactCurrency(4200000), icon: Icons.calendar_today, color: AdminColors.warning)),
            const SizedBox(width: 10),
            Expanded(child: StatCard(label: 'Avg Per User', value: Formatters.compactCurrency(12.50), icon: Icons.people, color: AdminColors.secondary)),
          ]),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AdminColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AdminColors.border.withValues(alpha: 0.5))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Revenue Breakdown', style: AppTypography.titleSmall.copyWith(color: AdminColors.textPrimary)),
              const Divider(height: 24),
              StatRow(label: 'Subscription Revenue', value: Formatters.compactCurrency(295000), valueColor: AdminColors.primary),
              StatRow(label: 'One-time Purchases', value: Formatters.compactCurrency(35000), valueColor: AdminColors.secondary),
              StatRow(label: 'AI Credits', value: Formatters.compactCurrency(15000), valueColor: AdminColors.warning),
            ]),
          ),
        ]),
      ),
    );
  }
}
