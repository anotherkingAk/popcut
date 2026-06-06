import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../shared/widgets/status_badge.dart';

class AdminUsersScreen extends ConsumerWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(title: const Text('Admin Users'), leading: Builder(builder: (ctx) => IconButton(icon: const Icon(Icons.menu), onPressed: () => Scaffold.of(ctx).openDrawer())), actions: [IconButton(icon: const Icon(Icons.add, size: 18), onPressed: () {})]),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 4,
        itemBuilder: (_, i) {
          final admins = [
            {'name': 'Admin User', 'email': 'admin@popcut.com', 'role': 'owner'},
            {'name': 'Moderator One', 'email': 'mod1@popcut.com', 'role': 'moderator'},
            {'name': 'Support Agent', 'email': 'support@popcut.com', 'role': 'support'},
            {'name': 'Analyst', 'email': 'analyst@popcut.com', 'role': 'analyst'},
          ];
          final admin = admins[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AdminColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AdminColors.border.withValues(alpha: 0.5))),
            child: Row(children: [
              CircleAvatar(radius: 18, backgroundColor: AdminColors.primary.withValues(alpha: 0.15), child: Text(admin['name']![0], style: const TextStyle(color: AdminColors.primary, fontSize: 14))),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(admin['name']!, style: AppTypography.titleMedium.copyWith(color: AdminColors.textPrimary)),
                Text(admin['email']!, style: AppTypography.caption.copyWith(color: AdminColors.textMuted)),
              ])),
              StatusBadge(label: admin['role']!.toUpperCase(), color: AdminColors.secondary),
            ]),
          );
        },
      ),
    );
  }
}
