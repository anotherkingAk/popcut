import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';

class AppPullToRefresh extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;

  const AppPullToRefresh({super.key, required this.child, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AdminColors.primary,
      backgroundColor: AdminColors.surface,
      onRefresh: onRefresh,
      child: child,
    );
  }
}
