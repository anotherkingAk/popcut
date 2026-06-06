import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_motion.dart';
import '../../services/haptic_service.dart';
import '../../widgets/common/app_bottom_sheet.dart';

class ProjectInfoSheet extends StatelessWidget {
  const ProjectInfoSheet({super.key});

  static void show(BuildContext context) {
    AppBottomSheet.show(
      context: context,
      title: 'Project Info',
      icon: Icons.info_outline,
      body: const ProjectInfoSheet(),
      maxHeightFactor: 0.92,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 80, height: 60,
                decoration: BoxDecoration(
                  color: AppColors.bgOverlay,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.movie_outlined, size: 28, color: AppColors.textMedium),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.bgElevated,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: TextField(
                        style: AppTypography.titleSm,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          border: InputBorder.none,
                        ),
                        controller: TextEditingController(text: 'My Awesome Video'),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text('Created: Jan 15, 2026', style: AppTypography.bodySm),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _InfoRow('Last modified', 'Today, 3:45 PM'),
          _InfoRow('Duration', '3:42'),
          _InfoRow('Resolution', '1920 × 1080'),
          _InfoRow('File size', '124 MB'),
          _InfoRow('Tracks', '5'),
          _InfoRow('Clips', '12'),
          _InfoRow('Exports', '3'),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                HapticService.trigger(HapticLevel.light);
              },
              icon: const Icon(Icons.copy, size: 18),
              label: const Text('Duplicate Project'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textHigh,
                side: const BorderSide(color: AppColors.border),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                HapticService.trigger(HapticLevel.light);
              },
              icon: const Icon(Icons.delete_outline, size: 18),
              label: const Text('Delete Project'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: BorderSide(color: AppColors.error.withValues(alpha: 0.3)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(label, style: AppTypography.bodyMd),
          const Spacer(),
          Text(value, style: AppTypography.bodyLg),
        ],
      ),
    );
  }
}
