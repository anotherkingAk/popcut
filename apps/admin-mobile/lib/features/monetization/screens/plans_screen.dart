import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../shared/widgets/status_badge.dart';

class PlansScreen extends ConsumerWidget {
  const PlansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(title: const Text('Plans'), leading: Builder(builder: (ctx) => IconButton(icon: const Icon(Icons.menu), onPressed: () => Scaffold.of(ctx).openDrawer())), actions: [IconButton(icon: const Icon(Icons.add, size: 18), onPressed: () {})]),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 4,
        itemBuilder: (_, i) {
          final plans = [
            {'name': 'Free', 'price': '\$0', 'users': 125000, 'color': AdminColors.textMuted},
            {'name': 'Pro', 'price': '\$9.99', 'users': 45000, 'color': AdminColors.primary},
            {'name': 'Business', 'price': '\$29.99', 'users': 12000, 'color': AdminColors.secondary},
            {'name': 'Enterprise', 'price': '\$99.99', 'users': 3000, 'color': AdminColors.warning},
          ];
          final plan = plans[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AdminColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AdminColors.border.withValues(alpha: 0.5)),
            ),
            child: Row(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: (plan['color'] as Color).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.subscriptions, color: plan['color'] as Color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(plan['name'] as String, style: AppTypography.titleMedium.copyWith(color: AdminColors.textPrimary)),
                  Text('${plan['price']}/mo', style: AppTypography.bodySmall.copyWith(color: AdminColors.textSecondary)),
                ]),
              ),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('${plan['users']}', style: AppTypography.titleMedium.copyWith(color: AdminColors.textPrimary)),
                Text('users', style: AppTypography.caption.copyWith(color: AdminColors.textMuted)),
              ]),
            ]),
          );
        },
      ),
    );
  }
}
