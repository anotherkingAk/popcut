import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_motion.dart';
import '../../services/haptic_service.dart';
import '../../widgets/common/app_bottom_sheet.dart';

class ClipPropertiesSheet extends StatelessWidget {
  const ClipPropertiesSheet({super.key});

  static void show(BuildContext context) {
    AppBottomSheet.show(
      context: context,
      title: 'Clip Properties',
      icon: Icons.videocam_outlined,
      body: const ClipPropertiesSheet(),
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
                width: 80, height: 56,
                decoration: BoxDecoration(
                  color: AppColors.bgOverlay,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.movie, size: 28, color: AppColors.textMedium),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Clip_001.mp4', style: AppTypography.titleMd),
                    const SizedBox(height: 2),
                    const Text('Source: Camera Roll', style: AppTypography.bodySm),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => HapticService.trigger(HapticLevel.light),
                child: const Icon(Icons.favorite_border, size: 22, color: AppColors.textLow),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _InfoRow('Position', '00:12:05'),
          _InfoRow('Duration', '00:03:20'),
          _InfoRow('Speed', '1.0×'),
          _InfoRow('Volume', '100%'),
          const SizedBox(height: 16),
          Text('Trim', style: AppTypography.label),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('00:00', style: AppTypography.bodySm),
              Expanded(
                child: RangeSlider(
                  values: const RangeValues(0, 0.8),
                  min: 0, max: 1,
                  divisions: 100,
                  onChanged: (_) {},
                ),
              ),
              const Text('03:20', style: AppTypography.bodySm),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                HapticService.trigger(HapticLevel.light);
              },
              icon: const Icon(Icons.swap_horiz, size: 18),
              label: const Text('Replace Clip'),
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
                HapticService.delete();
              },
              icon: const Icon(Icons.delete_outline, size: 18),
              label: const Text('Delete Clip'),
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
