import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AdminColors.surfaceHover,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, size: 28, color: AdminColors.textMuted),
            ),
            const SizedBox(height: 16),
            Text(title, style: AppTypography.titleMedium.copyWith(color: AdminColors.textSecondary)),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(subtitle!, style: AppTypography.bodySmall.copyWith(color: AdminColors.textMuted), textAlign: TextAlign.center),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              ElevatedButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
