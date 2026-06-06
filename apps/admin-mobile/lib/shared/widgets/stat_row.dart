import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';

class StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final IconData? icon;

  const StatRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor = AdminColors.textPrimary,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: AdminColors.textMuted),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(label, style: AppTypography.bodySmall.copyWith(color: AdminColors.textSecondary)),
          ),
          const SizedBox(width: 8),
          Text(value, style: AppTypography.labelLarge.copyWith(color: valueColor)),
        ],
      ),
    );
  }
}
