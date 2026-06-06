import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/app_motion.dart';
import '../../../services/haptic_service.dart';

class CanvasPanel extends StatelessWidget {
  final AnimationController staggerController;
  const CanvasPanel({super.key, required this.staggerController});

  final _presets = const [
    _CanvasPreset('Original', null),
    _CanvasPreset('1:1', 1.0),
    _CanvasPreset('9:16', 9 / 16),
    _CanvasPreset('16:9', 16 / 9),
    _CanvasPreset('4:5', 4 / 5),
    _CanvasPreset('4:3', 4 / 3),
    _CanvasPreset('21:9', 21 / 9),
  ];
  static const _fills = ['Blur', 'Color', 'Stretch', 'Fit', 'Crop'];

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
                _buildPresetRow(),
                const SizedBox(height: 16),
                _buildCustomSize(),
                const SizedBox(height: 16),
                _buildFillSelector(),
                const SizedBox(height: 16),
                _buildLabeledSlider('Position X', 0, -1000, 1000),
                _buildLabeledSlider('Position Y', 0, -1000, 1000),
                _buildLabeledSlider('Scale', 1.0, 0.1, 5.0),
                _buildLabeledSlider('Rotation', 0, -180, 180),
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
      child: const Text('Canvas', style: AppTypography.titleSm),
    );
  }

  Widget _buildPresetRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Canvas Size', style: AppTypography.bodySm),
        const SizedBox(height: 8),
        Row(
          children: _presets.map((p) => Expanded(
            child: GestureDetector(
              onTap: () => HapticService.trigger(HapticLevel.light),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: p.name == '1:1' ? AppColors.brand500.withValues(alpha: 0.15) : AppColors.bgSurface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: p.name == '1:1' ? AppColors.brand500 : AppColors.border),
                ),
                child: Center(child: Text(p.name, style: TextStyle(fontSize: 8, color: p.name == '1:1' ? AppColors.brand500 : AppColors.textMedium))),
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildCustomSize() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(color: AppColors.bgSurface, borderRadius: BorderRadius.circular(6), border: Border.all(color: AppColors.border)),
            child: const TextField(
              style: TextStyle(fontSize: 13, color: AppColors.textHigh),
              decoration: InputDecoration.collapsed(hintText: 'Width', hintStyle: TextStyle(color: AppColors.textLow)),
              keyboardType: TextInputType.number,
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text('x', style: TextStyle(color: AppColors.textLow)),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(color: AppColors.bgSurface, borderRadius: BorderRadius.circular(6), border: Border.all(color: AppColors.border)),
            child: const TextField(
              style: TextStyle(fontSize: 13, color: AppColors.textHigh),
              decoration: InputDecoration.collapsed(hintText: 'Height', hintStyle: TextStyle(color: AppColors.textLow)),
              keyboardType: TextInputType.number,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFillSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Background Fill', style: AppTypography.bodySm),
        const SizedBox(height: 6),
        Row(
          children: _fills.map((f) => Expanded(
            child: GestureDetector(
              onTap: () => HapticService.trigger(HapticLevel.light),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.symmetric(vertical: 7),
                decoration: BoxDecoration(
                  color: f == 'Blur' ? AppColors.brand500.withValues(alpha: 0.15) : AppColors.bgSurface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: f == 'Blur' ? AppColors.brand500 : AppColors.border),
                ),
                child: Center(child: Text(f, style: TextStyle(fontSize: 9, color: f == 'Blur' ? AppColors.brand500 : AppColors.textMedium))),
              ),
            ),
          )).toList(),
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
            child: Text('Reset Canvas', style: TextStyle(fontSize: 13, color: AppColors.error, fontWeight: FontWeight.w600)),
          ),
        ),
      ),
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
          child: Slider(value: value, min: min, max: max, onChanged: (_) => HapticService.trigger(HapticLevel.light)),
        ),
      ],
    );
  }
}

class _CanvasPreset {
  final String name;
  final double? ratio;
  const _CanvasPreset(this.name, this.ratio);
}
