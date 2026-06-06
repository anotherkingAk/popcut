import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';

class ChartCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget chart;
  final List<Widget>? actions;

  const ChartCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.chart,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTypography.titleSmall.copyWith(color: AdminColors.textPrimary)),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(subtitle!, style: AppTypography.caption.copyWith(color: AdminColors.textMuted)),
                    ],
                  ],
                ),
              ),
              if (actions != null) ...actions!,
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(height: 200, child: chart),
        ],
      ),
    );
  }
}
