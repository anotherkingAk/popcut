import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/status_badge.dart';

class CouponsScreen extends ConsumerWidget {
  const CouponsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(title: const Text('Coupons'), leading: Builder(builder: (ctx) => IconButton(icon: const Icon(Icons.menu), onPressed: () => Scaffold.of(ctx).openDrawer())), actions: [IconButton(icon: const Icon(Icons.add, size: 18), onPressed: () {})]),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 6,
        itemBuilder: (_, i) {
          final codes = ['SAVE20', 'SUMMER24', 'WELCOME10', 'PRO50', 'FLASH25', 'VIP30'];
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AdminColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AdminColors.border.withValues(alpha: 0.5))),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: AdminColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(codes[i], style: AppTypography.mono.copyWith(color: AdminColors.primary, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${(i + 1) * 10}% OFF', style: AppTypography.titleMedium.copyWith(color: AdminColors.textPrimary)),
                Text('${(i + 1) * 50} used', style: AppTypography.caption.copyWith(color: AdminColors.textMuted)),
              ])),
              StatusBadge(label: 'Active', color: AdminColors.success),
            ]),
          );
        },
      ),
    );
  }
}
