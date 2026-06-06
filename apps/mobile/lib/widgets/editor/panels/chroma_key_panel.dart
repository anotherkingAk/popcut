import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../services/haptic_service.dart';

class ChromaKeyPanel extends StatelessWidget {
  final AnimationController staggerController;
  const ChromaKeyPanel({super.key, required this.staggerController});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgElevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildColorPresets(),
                const SizedBox(height: 16),
                _buildLabeledSlider('Tolerance', 50, 0, 100),
                const SizedBox(height: 12),
                _buildLabeledSlider('Edge Feather', 10, 0, 20),
                const SizedBox(height: 12),
                _buildLabeledSlider('Opacity', 100, 0, 100),
                const SizedBox(height: 16),
                _buildToggleRow('Spill Reduction', true),
                const SizedBox(height: 12),
                _buildToggleRow('Preview Before/After', false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerLeft,
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5))),
      child: const Row(
        children: [
          Text('Chroma Key', style: AppTypography.titleSm),
          Spacer(),
          Text('1.0x', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.brand500)),
        ],
      ),
    );
  }

  Widget _buildColorPresets() {
    final colors = [
      AppColors.textMedium, AppColors.textMedium, AppColors.textMedium,
      AppColors.textMedium, AppColors.textMedium, AppColors.textMedium,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Key Color', style: AppTypography.bodySm),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: colors.map((c) => GestureDetector(
            onTap: () => HapticService.trigger(HapticLevel.light),
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: c,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderLight, width: 2),
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildLabeledSlider(String label, double value, double min, double max) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: AppTypography.bodySm),
            const Spacer(),
            Text('${value.toInt()}', style: const TextStyle(fontSize: 12, color: AppColors.textHigh)),
          ],
        ),
        SliderTheme(
          data: const SliderThemeData(
            trackHeight: 3,
            activeTrackColor: AppColors.brand500,
            inactiveTrackColor: AppColors.timelineGrid,
            thumbColor: AppColors.brand500,
          ),
          child: Slider(value: value, min: min, max: max, onChanged: (_) => HapticService.trigger(HapticLevel.light)),
        ),
      ],
    );
  }

  Widget _buildToggleRow(String label, bool value) {
    return Row(
      children: [
        Text(label, style: AppTypography.bodySm),
        const Spacer(),
        Switch(value: value, onChanged: (_) => HapticService.trigger(HapticLevel.light)),
      ],
    );
  }
}
