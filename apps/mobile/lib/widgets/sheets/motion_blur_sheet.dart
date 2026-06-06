import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_motion.dart';
import '../../services/haptic_service.dart';
import '../../widgets/common/app_bottom_sheet.dart';

class MotionBlurSheet extends StatelessWidget {
  const MotionBlurSheet({super.key});

  static void show(BuildContext context) {
    AppBottomSheet.show(
      context: context,
      title: 'Motion Blur',
      icon: Icons.blur_on,
      body: const MotionBlurSheet(),
      maxHeightFactor: 0.85,
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
              const Text('Enable Motion Blur', style: AppTypography.titleSm),
              const Spacer(),
              Switch(value: true, onChanged: (v) {
                HapticService.trigger(HapticLevel.light);
              }),
            ],
          ),
          const SizedBox(height: 20),
          Text('Blur Amount', style: AppTypography.label),
          Row(
            children: [
              const Text('0', style: AppTypography.bodySm),
              Expanded(
                child: Slider(value: 8, min: 0, max: 20, divisions: 20, onChanged: (_) {}),
              ),
              const Text('20', style: AppTypography.bodySm),
            ],
          ),
          const SizedBox(height: 14),
          Text('Shutter Angle', style: AppTypography.label),
          Row(
            children: [
              const Text('0°', style: AppTypography.bodySm),
              Expanded(
                child: Slider(value: 180, min: 0, max: 360, divisions: 36, onChanged: (_) {}),
              ),
              const Text('360°', style: AppTypography.bodySm),
            ],
          ),
          const SizedBox(height: 14),
          Text('Samples', style: AppTypography.label),
          Row(
            children: [
              const Text('4', style: AppTypography.bodySm),
              Expanded(
                child: Slider(value: 16, min: 4, max: 32, divisions: 7, onChanged: (_) {}),
              ),
              const Text('32', style: AppTypography.bodySm),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Text('Adaptive Blur', style: AppTypography.bodyMd),
                    const Spacer(),
                    Switch(value: true, onChanged: (v) {
                      HapticService.trigger(HapticLevel.light);
                    }),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Text('Preview', style: AppTypography.bodyMd),
                    const Spacer(),
                    Switch(value: false, onChanged: (v) {
                      HapticService.trigger(HapticLevel.light);
                    }),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                HapticService.trigger(HapticLevel.light);
                Navigator.pop(context);
              },
              child: const Text('Apply'),
            ),
          ),
        ],
      ),
    );
  }
}
