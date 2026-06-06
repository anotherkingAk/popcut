import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/app_motion.dart';
import '../../../services/haptic_service.dart';

class MaskPanel extends StatelessWidget {
  final AnimationController staggerController;
  const MaskPanel({super.key, required this.staggerController});

  final _shapes = const [
    _ShapeDef('Circle', Icons.circle_outlined),
    _ShapeDef('Rectangle', Icons.rectangle_outlined),
    _ShapeDef('Heart', Icons.favorite_border),
    _ShapeDef('Star', Icons.star_border),
    _ShapeDef('Custom', Icons.edit),
  ];

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
                _buildShapeGrid(),
                const SizedBox(height: 16),
                _buildToggleRow('Invert Mask', false),
                const SizedBox(height: 12),
                _buildLabeledSlider('Feather', 25, 0, 50),
                const SizedBox(height: 16),
                _buildPreviewCanvas(),
                const SizedBox(height: 16),
                _buildAddKeyframeButton(),
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
      child: const Text('Mask', style: AppTypography.titleSm),
    );
  }

  Widget _buildShapeGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Shape', style: AppTypography.bodySm),
        const SizedBox(height: 8),
        Row(
          children: _shapes.map((s) => Expanded(
            child: GestureDetector(
              onTap: () => HapticService.trigger(HapticLevel.light),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: s.name == 'Circle' ? AppColors.brand500.withValues(alpha: 0.15) : AppColors.bgSurface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: s.name == 'Circle' ? AppColors.brand500 : AppColors.border),
                ),
                child: Column(
                  children: [
                    Icon(s.icon, size: 22, color: s.name == 'Circle' ? AppColors.brand500 : AppColors.textMedium),
                    const SizedBox(height: 4),
                    Text(s.name, style: TextStyle(fontSize: 9, color: s.name == 'Circle' ? AppColors.brand500 : AppColors.textLow)),
                  ],
                ),
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildPreviewCanvas() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.circle_outlined, size: 48, color: AppColors.brand500.withValues(alpha: 0.3)),
            const SizedBox(height: 8),
            const Text('Mask Preview', style: TextStyle(fontSize: 11, color: AppColors.textLow)),
          ],
        ),
      ),
    );
  }

  Widget _buildAddKeyframeButton() {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: () => HapticService.trigger(HapticLevel.light),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.brand500.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.brand500),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, size: 16, color: AppColors.brand500),
              SizedBox(width: 6),
              Text('Add Keyframe', style: TextStyle(fontSize: 12, color: AppColors.brand500, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
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
            Text('${value.toInt()}', style: const TextStyle(fontSize: 12, color: AppColors.textHigh)),
          ],
        ),
        SliderTheme(
          data: const SliderThemeData(
            trackHeight: 3, activeTrackColor: AppColors.brand500, inactiveTrackColor: AppColors.timelineGrid, thumbColor: AppColors.brand500,
          ),
          child: Slider(value: value, min: min, max: max, onChanged: (_) => HapticService.trigger(HapticLevel.light)),
        ),
      ],
    );
  }
}

class _ShapeDef {
  final String name;
  final IconData icon;
  const _ShapeDef(this.name, this.icon);
}
