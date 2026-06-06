import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/app_motion.dart';
import '../../../services/haptic_service.dart';

class AiColorMatch extends StatelessWidget {
  final AnimationController staggerController;
  const AiColorMatch({super.key, required this.staggerController});

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
                _buildClipSelectors(),
                const SizedBox(height: 16),
                _buildSideBySidePreview(),
                const SizedBox(height: 16),
                _buildLabeledSlider('Match Strength', 75, 0, 100),
                const SizedBox(height: 12),
                _buildMatchElements(),
                const SizedBox(height: 16),
                _buildAutoMatchButton(),
                const SizedBox(height: 12),
                _buildProcessingSteps(),
                const SizedBox(height: 16),
                _buildResultComparison(),
                const SizedBox(height: 16),
                _buildFineTuneSliders(),
                const SizedBox(height: 16),
                _buildSavePreset(),
                const SizedBox(height: 12),
                _buildToggleRow('Apply to all clips', false),
                const SizedBox(height: 12),
                _buildApplyButton(),
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
      child: const Text('Color Match', style: AppTypography.titleSm),
    );
  }

  Widget _buildClipSelectors() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Reference Clip', style: AppTypography.bodySm),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () => HapticService.trigger(HapticLevel.light),
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.bgSurface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.brand500),
                  ),
                  child: const Center(child: Icon(Icons.check_circle, size: 18, color: AppColors.brand500)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Target Clip', style: AppTypography.bodySm),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () => HapticService.trigger(HapticLevel.light),
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.bgSurface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Center(child: Icon(Icons.movie, size: 18, color: AppColors.textMedium)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSideBySidePreview() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(7), bottomLeft: Radius.circular(7)),
                color: AppColors.bgBase,
              ),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.movie, size: 20, color: AppColors.textDisabled),
                    SizedBox(height: 4),
                    Text('Reference', style: TextStyle(fontSize: 9, color: AppColors.textLow)),
                  ],
                ),
              ),
            ),
          ),
          Container(width: 1, color: AppColors.border),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(topRight: Radius.circular(7), bottomRight: Radius.circular(7)),
                color: AppColors.bgBase,
              ),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.movie, size: 20, color: AppColors.textDisabled),
                    const SizedBox(height: 4),
                    Text('Target', style: TextStyle(fontSize: 9, color: AppColors.textLow)),
                    SizedBox(height: 2),
                    Text('72%', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.brand500)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchElements() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Match Elements', style: AppTypography.bodySm),
        const SizedBox(height: 6),
        _buildToggleRow('Luminance', true),
        _buildToggleRow('Saturation', true),
        _buildToggleRow('White Balance', true),
        _buildToggleRow('Contrast', true),
        _buildToggleRow('Shadows', false),
        _buildToggleRow('Highlights', false),
      ],
    );
  }

  Widget _buildAutoMatchButton() {
    return GestureDetector(
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
            Icon(Icons.color_lens, size: 14, color: AppColors.brand500),
            SizedBox(width: 6),
            Text('Match Colors', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.brand500)),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessingSteps() {
    final steps = ['Analyzing reference...', 'Analyzing target...', 'Applying LUT...', 'Done'];
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: steps.asMap().entries.map((e) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Icon(e.value == 'Done' ? Icons.check_circle : (e.key < 2 ? Icons.check_circle : Icons.circle_outlined), size: 10, color: e.value == 'Done' || e.key < 2 ? AppColors.success : AppColors.textLow),
              const SizedBox(width: 4),
              Text(e.value, style: TextStyle(fontSize: 9, color: e.value == 'Done' || e.key < 2 ? AppColors.textHigh : AppColors.textMedium)),
              if (e.key == 2)
                const Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: SizedBox(width: 8, height: 8, child: CircularProgressIndicator(strokeWidth: 1.2, color: AppColors.textLow)),
                ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildResultComparison() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          const Icon(Icons.compare, size: 14, color: AppColors.success),
          const SizedBox(width: 6),
          const Text('Match Score: ', style: TextStyle(fontSize: 11, color: AppColors.textMedium)),
          const Text('89%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textHigh)),
          const Spacer(),
          GestureDetector(
            onTap: () => HapticService.trigger(HapticLevel.light),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.brand500.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text('Before/After', style: TextStyle(fontSize: 9, color: AppColors.brand500)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFineTuneSliders() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Fine Tune', style: AppTypography.bodySm),
        const SizedBox(height: 6),
        _buildLabeledSlider('Temperature', 0, -20, 20),
        _buildLabeledSlider('Tint', 0, -20, 20),
        _buildLabeledSlider('Contrast', 0, -20, 20),
      ],
    );
  }

  Widget _buildSavePreset() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: const TextField(
              style: TextStyle(fontSize: 12, color: AppColors.textHigh),
              decoration: InputDecoration.collapsed(hintText: 'Preset name...', hintStyle: TextStyle(color: AppColors.textLow)),
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => HapticService.trigger(HapticLevel.light),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.brand500.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.brand500),
            ),
            child: const Row(
              children: [
                Icon(Icons.save, size: 12, color: AppColors.brand500),
                SizedBox(width: 4),
                Text('Save', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.brand500)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildApplyButton() {
    return GestureDetector(
      onTap: () => HapticService.trigger(HapticLevel.light),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.brand500,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text('Apply', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black)),
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
