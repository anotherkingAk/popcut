import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';

class AppErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const AppErrorWidget({super.key, required this.message, this.onRetry});

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
                color: AdminColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.cloud_off, size: 28, color: AdminColors.error),
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: AppTypography.headlineSmall.copyWith(color: AdminColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTypography.bodySmall.copyWith(color: AdminColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Try Again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
