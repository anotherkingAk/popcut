import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_motion.dart';
import '../../services/haptic_service.dart';
import '../../widgets/common/app_bottom_sheet.dart';

class ChromaKeySettingsSheet extends StatelessWidget {
  const ChromaKeySettingsSheet({super.key});

  static void show(BuildContext context) {
    AppBottomSheet.show(
      context: context,
      title: 'Chroma Key',
      icon: Icons.video_settings,
      body: const ChromaKeySettingsSheet(),
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Key Color', style: AppTypography.label),
                    const SizedBox(height: 6),
                    Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00FF00),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: AppColors.bgElevated,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(Icons.colorize, size: 20, color: AppColors.textMedium),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SliderRow('Tolerance', 0, 100, 45),
          _SliderRow('Edge Feather', 0, 100, 15),
          _SliderRow('Opacity', 0, 100, 100),
          _SliderRow('Spill Reduction', 0, 100, 50),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('Invert Mask', style: AppTypography.bodyMd),
              const Spacer(),
              Switch(value: false, onChanged: (v) {
                HapticService.trigger(HapticLevel.light);
              }),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Preview Mode', style: AppTypography.bodyMd),
              const Spacer(),
              Switch(value: true, onChanged: (v) {
                HapticService.trigger(HapticLevel.light);
              }),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    HapticService.trigger(HapticLevel.light);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textMedium,
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Reset'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    HapticService.trigger(HapticLevel.light);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  final String label;
  final double min;
  final double max;
  final double initial;
  const _SliderRow(this.label, this.min, this.max, this.initial);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label, style: AppTypography.label),
              const Spacer(),
              Text('${initial.round()}', style: AppTypography.bodySm),
            ],
          ),
          Slider(value: initial, min: min, max: max, divisions: 100, onChanged: (_) {}),
        ],
      ),
    );
  }
}
