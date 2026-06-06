import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String? cancelLabel;
  final Color confirmColor;
  final IconData? icon;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Confirm',
    this.cancelLabel,
    this.confirmColor = AdminColors.primary,
    this.icon,
  });

  static Future<bool> show(BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String? cancelLabel,
    Color confirmColor = AdminColors.primary,
    IconData? icon,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        confirmColor: confirmColor,
        icon: icon,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AdminColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: confirmColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: confirmColor, size: 24),
            ),
            const SizedBox(height: 16),
          ],
          Text(title, style: AppTypography.headlineSmall.copyWith(color: AdminColors.textPrimary)),
          const SizedBox(height: 8),
          Text(message, style: AppTypography.bodySmall.copyWith(color: AdminColors.textSecondary), textAlign: TextAlign.center),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelLabel ?? 'Cancel', style: const TextStyle(color: AdminColors.textSecondary)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: confirmColor),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    );
  }
}
