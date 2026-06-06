import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_motion.dart';
import '../../services/haptic_service.dart';

class AppDialog extends StatelessWidget {
  final String title;
  final String? message;
  final Widget? content;
  final String? cancelLabel;
  final String? confirmLabel;
  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;
  final bool isDestructive;
  final IconData? icon;
  final Color? iconColor;
  final Widget? extra;

  const AppDialog({
    super.key,
    required this.title,
    this.message,
    this.content,
    this.cancelLabel,
    this.confirmLabel,
    this.onCancel,
    this.onConfirm,
    this.isDestructive = false,
    this.icon,
    this.iconColor,
    this.extra,
  });

  static Future<bool?> show(BuildContext context, {
    required String title,
    String? message,
    Widget? content,
    String? cancelLabel,
    String? confirmLabel,
    VoidCallback? onCancel,
    VoidCallback? onConfirm,
    bool isDestructive = false,
    IconData? icon,
    Color? iconColor,
    Widget? extra,
  }) {
    HapticService.trigger(HapticLevel.medium);
    return showDialog<bool>(
      context: context,
      builder: (_) => AppDialog(
        title: title,
        message: message,
        content: content,
        cancelLabel: cancelLabel,
        confirmLabel: confirmLabel,
        onCancel: onCancel,
        onConfirm: onConfirm,
        isDestructive: isDestructive,
        icon: icon,
        iconColor: iconColor,
        extra: extra,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.bgSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.8, end: 1.0),
        duration: AppMotion.normal,
        curve: SpringCurve(),
        builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 48, color: iconColor ?? AppColors.textHigh),
                const SizedBox(height: 16),
              ],
              Text(title, style: AppTypography.titleMd, textAlign: TextAlign.center),
              if (message != null) ...[
                const SizedBox(height: 8),
                Text(message!, style: AppTypography.bodyMd, textAlign: TextAlign.center),
              ],
              if (content != null) ...[
                const SizedBox(height: 12),
                content!,
              ],
              if (extra != null) ...[
                const SizedBox(height: 12),
                extra!,
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  if (cancelLabel != null)
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          onCancel?.call();
                          Navigator.pop(context, false);
                        },
                        child: Text(cancelLabel!, style: const TextStyle(color: AppColors.textMedium)),
                      ),
                    ),
                  if (cancelLabel != null && confirmLabel != null)
                    const SizedBox(width: 12),
                  if (confirmLabel != null)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          onConfirm?.call();
                          if (isDestructive) {
                            HapticService.delete();
                          }
                          Navigator.pop(context, true);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDestructive ? AppColors.error : AppColors.brand500,
                        ),
                        child: Text(confirmLabel!),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
