import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../shared/widgets/empty_state.dart';

class SupportDashboardScreen extends ConsumerWidget {
  const SupportDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(title: const Text('Support Tickets'), leading: Builder(builder: (ctx) => IconButton(icon: const Icon(Icons.menu), onPressed: () => Scaffold.of(ctx).openDrawer()))),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 8,
        itemBuilder: (_, i) {
          final statuses = ['open', 'open', 'in_progress', 'open', 'resolved', 'in_progress', 'open', 'resolved'];
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () => context.go('${AppRoutes.support}/ticket_${i + 1}'),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AdminColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AdminColors.border.withValues(alpha: 0.5))),
                child: Row(children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: AdminColors.warning.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.support_agent, size: 18, color: AdminColors.warning),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Issue #${100 + i}', style: AppTypography.titleMedium.copyWith(color: AdminColors.textPrimary)),
                      const SizedBox(height: 2),
                      Text('user${i + 1}@example.com', style: AppTypography.caption.copyWith(color: AdminColors.textMuted)),
                      const SizedBox(height: 4),
                      Text(Formatters.timeAgo(DateTime.now().subtract(Duration(hours: i * 3))), style: AppTypography.caption.copyWith(color: AdminColors.textMuted, fontSize: 10)),
                    ]),
                  ),
                  StatusBadge.fromString(statuses[i]),
                ]),
              ),
            ),
          );
        },
      ),
    );
  }
}
