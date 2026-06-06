import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/app_motion.dart';
import '../../../services/haptic_service.dart';

class CropPanel extends StatelessWidget {
  final AnimationController staggerController;
  const CropPanel({super.key, required this.staggerController});

  static const _ratios = ['Free', '1:1', '9:16', '16:9', '4:3', '4:5'];

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
                _buildRatioRow(),
                const SizedBox(height: 16),
                _buildLabeledSlider('Rotation', 0, -180, 180),
                const SizedBox(height: 12),
                _buildFlipButtons(),
                const SizedBox(height: 12),
                _buildLabeledSlider('Straighten', 0, -45, 45),
                const SizedBox(height: 16),
                _buildToggleRow('Zoom to Fill', false),
                _buildToggleRow('Grid Overlay', true),
                const SizedBox(height: 16),
                _buildResetButton(),
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
      child: const Text('Crop', style: AppTypography.titleSm),
    );
  }

  Widget _buildRatioRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Aspect Ratio', style: AppTypography.bodySm),
        const SizedBox(height: 8),
        Row(
          children: _ratios.map((r) => Expanded(
            child: GestureDetector(
              onTap: () => HapticService.trigger(HapticLevel.light),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: r == 'Free' ? AppColors.brand500.withValues(alpha: 0.15) : AppColors.bgSurface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: r == 'Free' ? AppColors.brand500 : AppColors.border),
                ),
                child: Center(child: Text(r, style: TextStyle(fontSize: 10, color: r == 'Free' ? AppColors.brand500 : AppColors.textMedium))),
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildFlipButtons() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => HapticService.trigger(HapticLevel.light),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(color: AppColors.bgSurface, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.flip, size: 16, color: AppColors.textMedium),
                  SizedBox(width: 4),
                  Text('Flip H', style: TextStyle(fontSize: 11, color: AppColors.textMedium)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: () => HapticService.trigger(HapticLevel.light),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(color: AppColors.bgSurface, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.flip, size: 16, color: AppColors.textMedium),
                  SizedBox(width: 4),
                  Text('Flip V', style: TextStyle(fontSize: 11, color: AppColors.textMedium)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResetButton() {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: () => HapticService.trigger(HapticLevel.light),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
          ),
          child: const Center(
            child: Text('Reset Crop', style: TextStyle(fontSize: 13, color: AppColors.error, fontWeight: FontWeight.w600)),
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
            Text('${value.toInt()}°', style: const TextStyle(fontSize: 12, color: AppColors.textHigh)),
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
