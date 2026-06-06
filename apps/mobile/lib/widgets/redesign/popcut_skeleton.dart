import 'package:flutter/material.dart';
import '../../theme/popcut_theme.dart';

class PopCutSkeleton extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;
  final Color? baseColor;
  final Color? highlightColor;

  const PopCutSkeleton({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
    this.baseColor,
    this.highlightColor,
  });

  @override
  State<PopCutSkeleton> createState() => _PopCutSkeletonState();
}

class _PopCutSkeletonState extends State<PopCutSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutSine,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(_animation.value, 0),
              end: const Alignment(0.5, 0),
              colors: [
                widget.baseColor ?? PopCutColors.shimmerBase,
                widget.highlightColor ?? PopCutColors.shimmerHighlight,
                widget.baseColor ?? PopCutColors.shimmerBase,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

class PopCutSkeletonCard extends StatelessWidget {
  final double height;
  final double? width;

  const PopCutSkeletonCard({
    super.key,
    this.height = 180,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PopCutColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PopCutColors.border.withValues(alpha: 0.3)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PopCutSkeleton(width: double.infinity, height: 80, borderRadius: 8),
          SizedBox(height: 12),
          PopCutSkeleton(width: 140, height: 14, borderRadius: 4),
          SizedBox(height: 8),
          PopCutSkeleton(width: 80, height: 12, borderRadius: 4),
        ],
      ),
    );
  }
}
