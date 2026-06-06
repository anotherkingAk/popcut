import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';

class LoadingSkeleton extends StatefulWidget {
  final int lines;
  final double height;

  const LoadingSkeleton({super.key, this.lines = 4, this.height = 16});

  @override
  State<LoadingSkeleton> createState() => _LoadingSkeletonState();
}

class _LoadingSkeletonState extends State<LoadingSkeleton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat();
    _animation = Tween<double>(begin: 0.3, end: 0.6).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
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
      builder: (context, _) {
        return Column(
          children: List.generate(widget.lines, (i) {
            final width = i == widget.lines - 1 ? 0.6 : 1.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                width: double.infinity,
                height: widget.height,
                decoration: BoxDecoration(
                  color: AdminColors.surfaceHover.withValues(alpha: _animation.value),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

class SkeletonCard extends StatelessWidget {
  final double height;

  const SkeletonCard({super.key, this.height = 120});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AdminColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminColors.border),
      ),
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }
}
