import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/status_badge.dart';

class ContentCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? previewUrl;
  final String? status;
  final DateTime? createdAt;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final IconData icon;

  const ContentCard({
    super.key,
    required this.title,
    this.subtitle,
    this.previewUrl,
    this.status,
    this.createdAt,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.icon = Icons.article,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AdminColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AdminColors.border.withValues(alpha: 0.5))),
          child: Row(children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(color: AdminColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: previewUrl != null
                  ? ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(previewUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(icon, color: AdminColors.primary, size: 22)))
                  : Icon(icon, color: AdminColors.primary, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: AppTypography.titleMedium.copyWith(color: AdminColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!, style: AppTypography.caption.copyWith(color: AdminColors.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
                if (createdAt != null) ...[
                  const SizedBox(height: 4),
                  Row(children: [
                    Text(Formatters.timeAgo(createdAt!), style: AppTypography.caption.copyWith(color: AdminColors.textMuted, fontSize: 10)),
                    if (status != null) ...[
                      const SizedBox(width: 8),
                      StatusBadge.fromString(status!),
                    ],
                  ]),
                ],
              ]),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 16, color: AdminColors.textMuted),
              onSelected: (v) {
                if (v == 'edit') onEdit?.call();
                if (v == 'delete') onDelete?.call();
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 16), SizedBox(width: 8), Text('Edit')])),
                const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 16, color: AdminColors.error), SizedBox(width: 8), Text('Delete', style: TextStyle(color: AdminColors.error))])),
              ],
            ),
          ]),
        ),
      ),
    );
  }
}
