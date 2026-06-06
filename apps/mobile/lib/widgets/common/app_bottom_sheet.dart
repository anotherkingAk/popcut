import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_motion.dart';
import '../../services/haptic_service.dart';

class AppBottomSheet extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Widget body;
  final Widget? trailing;
  final double maxHeightFactor;
  final double minHeightFactor;
  final bool showDragHandle;
  final VoidCallback? onClose;

  const AppBottomSheet({
    super.key,
    required this.title,
    this.icon,
    required this.body,
    this.trailing,
    this.maxHeightFactor = 0.85,
    this.minHeightFactor = 0.4,
    this.showDragHandle = true,
    this.onClose,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    IconData? icon,
    required Widget body,
    Widget? trailing,
    double maxHeightFactor = 0.85,
    bool showDragHandle = true,
  }) {
    HapticFeedback.lightImpact();
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: AppColors.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: maxHeightFactor,
        minChildSize: 0.4,
        maxChildSize: maxHeightFactor,
        expand: false,
        builder: (context, scrollController) => AppBottomSheet(
          title: title,
          icon: icon,
          body: body,
          trailing: trailing,
          showDragHandle: showDragHandle,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showDragHandle)
          Container(
            width: 32, height: 3,
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.textLow,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20, color: AppColors.textHigh),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(title, style: AppTypography.titleSm),
              ),
              if (trailing != null) trailing!,
              if (onClose != null)
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  color: AppColors.textLow,
                  onPressed: () { HapticService.trigger(HapticLevel.light); onClose!(); },
                ),
            ],
          ),
        ),
        const Divider(height: 0.5, color: AppColors.border),
        Expanded(
          child: body,
        ),
      ],
    );
  }
}
