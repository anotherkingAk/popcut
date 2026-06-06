import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../services/haptic_service.dart';

class Zoom3DPanel extends StatelessWidget {
  final AnimationController staggerController;
  const Zoom3DPanel({super.key, required this.staggerController});

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
                _buildLabeledSlider('Zoom', 1.0, 1.0, 5.0),
                const SizedBox(height: 12),
                _buildLabeledSlider('Rotation X', 0, -45, 45),
                const SizedBox(height: 12),
                _buildLabeledSlider('Rotation Y', 0, -45, 45),
                const SizedBox(height: 12),
                _buildLabeledSlider('Perspective Depth', 50, 0, 100),
                const SizedBox(height: 16),
                _buildEasingSelector(),
                const SizedBox(height: 16),
                _buildLabeledSlider('Motion Blur Intensity', 5, 0, 10),
                const SizedBox(height: 12),
                _buildToggleRow('Motion Blur', true),
                const SizedBox(height: 16),
                _buildKeyframeTypeSelector(),
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
      child: const Text('Zoom / 3D', style: AppTypography.titleSm),
    );
  }

  Widget _buildEasingSelector() {
    final easings = ['Linear', 'Ease In', 'Ease Out', 'Ease In-Out', 'Bounce'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Easing Curve', style: AppTypography.bodySm),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: easings.map((e) => GestureDetector(
            onTap: () => HapticService.trigger(HapticLevel.light),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: e == 'Ease In-Out' ? AppColors.brand500.withValues(alpha: 0.15) : AppColors.bgSurface,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: e == 'Ease In-Out' ? AppColors.brand500 : AppColors.border),
              ),
              child: Text(e, style: TextStyle(fontSize: 11, color: e == 'Ease In-Out' ? AppColors.brand500 : AppColors.textMedium)),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildKeyframeTypeSelector() {
    final types = ['In', 'Out', 'In-Out'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Keyframe Type', style: AppTypography.bodySm),
        const SizedBox(height: 8),
        Row(
          children: types.map((t) => Expanded(
            child: GestureDetector(
              onTap: () => HapticService.trigger(HapticLevel.light),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: t == 'In-Out' ? AppColors.brand500.withValues(alpha: 0.15) : AppColors.bgSurface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: t == 'In-Out' ? AppColors.brand500 : AppColors.border),
                ),
                child: Center(child: Text(t, style: TextStyle(fontSize: 11, color: t == 'In-Out' ? AppColors.brand500 : AppColors.textMedium))),
              ),
            ),
          )).toList(),
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

  Widget _buildLabeledSlider(String label, double value, double min, double max) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: AppTypography.bodySm),
            const Spacer(),
            Text(value is int ? '${value.toInt()}' : value.toStringAsFixed(1), style: const TextStyle(fontSize: 12, color: AppColors.textHigh)),
          ],
        ),
        SliderTheme(
          data: const SliderThemeData(
            trackHeight: 3, activeTrackColor: AppColors.brand500, inactiveTrackColor: AppColors.timelineGrid, thumbColor: AppColors.brand500,
          ),
          child: Slider(value: value, min: min, max: max, divisions: max == 5.0 ? 40 : null, onChanged: (_) => HapticService.trigger(HapticLevel.light)),
        ),
      ],
    );
  }
}
