import 'package:flutter/material.dart';
import '../../theme/popcut_theme.dart';
import 'popcut_skeleton.dart';

class PopCutGrid extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final int crossAxisCount;
  final double childAspectRatio;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final bool isLoading;
  final int skeletonCount;

  const PopCutGrid({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.crossAxisCount = 2,
    this.childAspectRatio = 0.72,
    this.crossAxisSpacing = 12,
    this.mainAxisSpacing = 12,
    this.padding,
    this.physics,
    this.isLoading = false,
    this.skeletonCount = 6,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return GridView.builder(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: childAspectRatio,
          crossAxisSpacing: crossAxisSpacing,
          mainAxisSpacing: mainAxisSpacing,
        ),
        physics: physics ?? const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: skeletonCount,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: PopCutColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: PopCutColors.border.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: PopCutSkeleton(
                    width: double.infinity,
                    height: double.infinity,
                    borderRadius: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PopCutSkeleton(width: 100, height: 12, borderRadius: 4),
                      const SizedBox(height: 6),
                      PopCutSkeleton(width: 60, height: 10, borderRadius: 4),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    return GridView.builder(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
      ),
      physics: physics ?? const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );
  }
}
