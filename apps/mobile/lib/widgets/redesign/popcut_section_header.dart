import 'package:flutter/material.dart';
import '../../theme/popcut_theme.dart';

class PopCutSectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  const PopCutSectionHeader({
    super.key,
    required this.title,
    this.actionLabel = 'See All',
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: PopCutTypography.headline),
        if (onActionTap != null)
          GestureDetector(
            onTap: onActionTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: PopCutColors.glass(),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: PopCutColors.glassBorder(),
                  width: 0.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    actionLabel ?? 'See All',
                    style: PopCutTypography.captionBold.copyWith(
                      color: PopCutColors.primary,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 14,
                    color: PopCutColors.primary,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
