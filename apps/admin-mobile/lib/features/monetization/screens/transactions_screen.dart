import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/status_badge.dart';

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(title: const Text('Transactions'), leading: Builder(builder: (ctx) => IconButton(icon: const Icon(Icons.menu), onPressed: () => Scaffold.of(ctx).openDrawer()))),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 10,
        itemBuilder: (_, i) {
          final status = i % 3 == 0 ? 'completed' : i % 3 == 1 ? 'pending' : 'failed';
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AdminColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AdminColors.border.withValues(alpha: 0.5))),
            child: Row(children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: AdminColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.receipt, size: 18, color: AdminColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Transaction #${100000 + i}', style: AppTypography.titleMedium.copyWith(color: AdminColors.textPrimary)),
                Text('user${i + 1}@example.com', style: AppTypography.caption.copyWith(color: AdminColors.textMuted)),
              ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(Formatters.currency((i + 1) * 9.99), style: AppTypography.titleMedium.copyWith(color: AdminColors.textPrimary)),
                const SizedBox(height: 4),
                StatusBadge.fromString(status),
              ]),
            ]),
          );
        },
      ),
    );
  }
}
