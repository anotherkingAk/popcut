import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/app_motion.dart';
import '../../../services/haptic_service.dart';

class DenoisePanel extends StatelessWidget {
  final AnimationController staggerController;
  const DenoisePanel({super.key, required this.staggerController});

  static const _tabs = ['Background Noise', 'Wind', 'Hum', 'Click/Pop', 'Hiss'];

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
                _buildLabeledSlider('Noise Reduction', 50, 0, 100),
                const SizedBox(height: 16),
                _buildTabRow(),
                const SizedBox(height: 16),
                _buildLearnNoiseButton(),
                const SizedBox(height: 16),
                _buildToggleRow('Real-Time Preview', true),
                const SizedBox(height: 12),
                _buildLabeledSlider('Reduce Amount', 70, 0, 100),
                const SizedBox(height: 16),
                _buildToggleRow('Preserve Music', true),
                _buildToggleRow('Voice Clarity Enhance', false),
                const SizedBox(height: 16),
                _buildModeSelector(),
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
      child: const Text('Denoise', style: AppTypography.titleSm),
    );
  }

  Widget _buildTabRow() {
    return SizedBox(
      height: 30,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _tabs.length,
        itemBuilder: (_, i) => GestureDetector(
          onTap: () => HapticService.trigger(HapticLevel.light),
          child: Container(
            margin: const EdgeInsets.only(right: 6),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: i == 0 ? AppColors.brand500.withValues(alpha: 0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: i == 0 ? AppColors.brand500 : AppColors.border),
            ),
            child: Text(_tabs[i], style: TextStyle(fontSize: 10, color: i == 0 ? AppColors.brand500 : AppColors.textLow, fontWeight: FontWeight.w500)),
          ),
        ),
      ),
    );
  }

  Widget _buildLearnNoiseButton() {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: () => HapticService.trigger(HapticLevel.light),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.hearing, size: 16, color: AppColors.textMedium),
              SizedBox(width: 8),
              Text('Learn Noise Sample', style: TextStyle(fontSize: 12, color: AppColors.textMedium)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeSelector() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => HapticService.trigger(HapticLevel.light),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.brand500.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.brand500),
              ),
              child: const Center(child: Text('Aggressive', style: TextStyle(fontSize: 11, color: AppColors.brand500, fontWeight: FontWeight.w500))),
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
              child: const Center(child: Text('Gentle', style: TextStyle(fontSize: 11, color: AppColors.textMedium))),
            ),
          ),
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
