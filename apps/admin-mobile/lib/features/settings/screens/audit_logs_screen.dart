import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';

class AuditLogsScreen extends ConsumerWidget {
  const AuditLogsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(title: const Text('Audit Logs'), leading: Builder(builder: (ctx) => IconButton(icon: const Icon(Icons.menu), onPressed: () => Scaffold.of(ctx).openDrawer()))),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 15,
        itemBuilder: (_, i) {
          final actions = ['User login', 'Template updated', 'User suspended', 'Plan changed', 'Content deleted', 'Notification sent', 'Settings changed', 'Coupon created', 'Support ticket closed', 'AI job retried', 'Feature flag toggled', 'Admin user added', 'Export completed', 'Payment processed', 'Review approved'];
          final users = ['admin@popcut.com', 'mod@popcut.com', 'system', 'admin@popcut.com', 'support@popcut.com', 'system', 'admin@popcut.com', 'admin@popcut.com', 'support@popcut.com', 'system', 'admin@popcut.com', 'owner@popcut.com', 'system', 'system', 'mod@popcut.com'];
          return Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(color: AdminColors.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: AdminColors.border.withValues(alpha: 0.3))),
            child: Row(children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(color: _colorForAction(actions[i]).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(_iconForAction(actions[i]), size: 14, color: _colorForAction(actions[i])),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(actions[i], style: AppTypography.bodySmall.copyWith(color: AdminColors.textPrimary)),
                  Text(users[i], style: AppTypography.caption.copyWith(color: AdminColors.textMuted, fontSize: 10)),
                ]),
              ),
              Text('${i + 1}m ago', style: AppTypography.caption.copyWith(color: AdminColors.textMuted, fontSize: 10)),
            ]),
          );
        },
      ),
    );
  }

  Color _colorForAction(String action) {
    if (action.contains('login') || action.contains('created') || action.contains('approved')) return AdminColors.success;
    if (action.contains('deleted') || action.contains('suspended') || action.contains('failed')) return AdminColors.error;
    if (action.contains('updated') || action.contains('changed') || action.contains('toggled') || action.contains('retried')) return AdminColors.warning;
    return AdminColors.primary;
  }

  IconData _iconForAction(String action) {
    if (action.contains('login')) return Icons.login;
    if (action.contains('created')) return Icons.add_circle;
    if (action.contains('deleted')) return Icons.delete;
    if (action.contains('suspended')) return Icons.block;
    if (action.contains('updated') || action.contains('changed')) return Icons.edit;
    if (action.contains('sent')) return Icons.send;
    if (action.contains('closed')) return Icons.check_circle;
    return Icons.info;
  }
}
