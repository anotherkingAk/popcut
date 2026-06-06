import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/app_motion.dart';
import '../../../services/haptic_service.dart';

class FreezePanel extends StatelessWidget {
  final AnimationController staggerController;
  const FreezePanel({super.key, required this.staggerController});

  static const _transitions = ['Instant', 'Crossfade', 'Dissolve', 'Zoom-In'];
  static const _types = ['Freeze Frame', 'Freeze + Motion Blur', 'Loop Section'];

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
                _buildPreviewThumbnail(),
                const SizedBox(height: 16),
                _buildLabeledSlider('Hold Duration', 2.0, 0.5, 10.0),
                const SizedBox(height: 16),
                _buildTransitionSelector(),
                const SizedBox(height: 16),
                _buildTypeSelector(),
                const SizedBox(height: 16),
                _buildLabeledSlider('Loop Section Duration', 1.0, 0.5, 5.0),
                const SizedBox(height: 20),
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
      child: const Text('Freeze Frame', style: AppTypography.titleSm),
    );
  }

  Widget _buildPreviewThumbnail() {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image, size: 36, color: AppColors.textLow.withValues(alpha: 0.5)),
            const SizedBox(height: 6),
            const Text('Freeze Frame at Playhead', style: TextStyle(fontSize: 11, color: AppColors.textLow)),
          ],
        ),
      ),
    );
  }

  Widget _buildTransitionSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Transition to Freeze', style: AppTypography.bodySm),
        const SizedBox(height: 8),
        Row(
          children: _transitions.map((t) => Expanded(
            child: GestureDetector(
              onTap: () => HapticService.trigger(HapticLevel.light),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: t == 'Crossfade' ? AppColors.brand500.withValues(alpha: 0.15) : AppColors.bgSurface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: t == 'Crossfade' ? AppColors.brand500 : AppColors.border),
                ),
                child: Center(child: Text(t, style: TextStyle(fontSize: 9, color: t == 'Crossfade' ? AppColors.brand500 : AppColors.textMedium))),
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Freeze Type', style: AppTypography.bodySm),
        const SizedBox(height: 8),
        ..._types.asMap().entries.map((e) => GestureDetector(
          onTap: () => HapticService.trigger(HapticLevel.light),
          child: Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: e.key == 0 ? AppColors.brand500.withValues(alpha: 0.08) : AppColors.bgSurface,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: e.key == 0 ? AppColors.brand500 : AppColors.border),
            ),
            child: Row(
              children: [
                Icon(e.key == 0 ? Icons.radio_button_checked : Icons.radio_button_off, size: 14, color: e.key == 0 ? AppColors.brand500 : AppColors.textLow),
                const SizedBox(width: 10),
                Text(e.value, style: TextStyle(fontSize: 12, color: e.key == 0 ? AppColors.brand500 : AppColors.textMedium)),
              ],
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildApplyButton() {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: () => HapticService.trigger(HapticLevel.light),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [AppColors.brand500, AppColors.brand600]),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Center(
            child: Text('Apply Freeze', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
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
            Text('${value.toStringAsFixed(1)}s', style: const TextStyle(fontSize: 12, color: AppColors.textHigh)),
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
