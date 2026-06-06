import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;
  final GestureTapCallback? onTap;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AdminColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AdminColors.border.withValues(alpha: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18, color: color),
                ),
                const Spacer(),
                if (onTap != null)
                  Icon(Icons.chevron_right, size: 16, color: AdminColors.textMuted),
              ],
            ),
            const SizedBox(height: 12),
            Text(value, style: AppTypography.statValue.copyWith(color: AdminColors.textPrimary)),
            const SizedBox(height: 4),
            Text(label, style: AppTypography.statLabel.copyWith(color: AdminColors.textSecondary)),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(subtitle!, style: AppTypography.caption.copyWith(color: color)),
            ],
          ],
        ),
      ),
    );
  }
}
