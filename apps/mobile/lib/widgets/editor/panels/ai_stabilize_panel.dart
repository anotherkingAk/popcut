import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../services/haptic_service.dart';

class AiStabilizePanel extends StatelessWidget {
  final AnimationController staggerController;
  const AiStabilizePanel({super.key, required this.staggerController});

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
                _buildPreview(),
                const SizedBox(height: 16),
                _buildModeChips(),
                const SizedBox(height: 16),
                _buildToggleRow('Auto-crop borders', true),
                const SizedBox(height: 8),
                _buildLabeledSlider('Crop Amount', 5, 0, 20),
                const SizedBox(height: 16),
                _buildAnalyzeButton(),
                const SizedBox(height: 12),
                _buildProgressBar(),
                const SizedBox(height: 12),
                _buildToggleRow('Rolling Shutter Correction', false),
                const SizedBox(height: 16),
                _buildResultIndicator(),
                const SizedBox(height: 12),
                _buildCompareToggle(),
                const SizedBox(height: 16),
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
      child: const Row(
        children: [
          Icon(Icons.videocam, size: 14, color: AppColors.textMedium),
          SizedBox(width: 6),
          Text('Stabilization', style: AppTypography.titleSm),
        ],
      ),
    );
  }

  Widget _buildPreview() {
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
                    Icon(Icons.blur_on, size: 24, color: AppColors.textLow),
                    SizedBox(height: 4),
                    Text('Before', style: TextStyle(fontSize: 11, color: AppColors.textLow)),
                    Text('Shaky', style: TextStyle(fontSize: 9, color: AppColors.textDisabled)),
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
                    Icon(Icons.videocam, size: 24, color: AppColors.brand500),
                    SizedBox(height: 4),
                    Text('After', style: TextStyle(fontSize: 11, color: AppColors.textHigh)),
                    Text('Smooth', style: TextStyle(fontSize: 9, color: AppColors.brand500)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeChips() {
    final modes = ['Smooth', 'Standard', 'Intense'];
    return Row(
      children: modes.map((m) => Expanded(
        child: GestureDetector(
          onTap: () => HapticService.trigger(HapticLevel.light),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: m == 'Standard' ? AppColors.brand500.withValues(alpha: 0.15) : AppColors.bgSurface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: m == 'Standard' ? AppColors.brand500 : AppColors.border),
            ),
            child: Text(m, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: m == 'Standard' ? AppColors.brand500 : AppColors.textMedium), textAlign: TextAlign.center),
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildAnalyzeButton() {
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
            Icon(Icons.auto_fix_high, size: 14, color: AppColors.brand500),
            SizedBox(width: 6),
            Text('Analyzing motion...', style: TextStyle(fontSize: 12, color: AppColors.brand500, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: const LinearProgressIndicator(
            value: 0.33,
            minHeight: 4,
            backgroundColor: AppColors.muted,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.brand500),
          ),
        ),
        const SizedBox(height: 6),
        const Text('Step 1 of 3', style: TextStyle(fontSize: 10, color: AppColors.textLow)),
      ],
    );
  }

  Widget _buildResultIndicator() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.check_circle, size: 14, color: AppColors.success),
              SizedBox(width: 6),
              Text('Shakiness reduced by 85%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textHigh)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: const LinearProgressIndicator(
              value: 0.85,
              minHeight: 4,
              backgroundColor: AppColors.muted,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.success),
            ),
          ),
          const SizedBox(height: 4),
          const Text('Confidence', style: TextStyle(fontSize: 9, color: AppColors.textLow)),
        ],
      ),
    );
  }

  Widget _buildCompareToggle() {
    return GestureDetector(
      onTap: () => HapticService.trigger(HapticLevel.light),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.touch_app, size: 14, color: AppColors.textMedium),
            SizedBox(width: 6),
            Text('Hold to see before', style: TextStyle(fontSize: 11, color: AppColors.textMedium)),
          ],
        ),
      ),
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
            Text('${value.toInt()}%', style: const TextStyle(fontSize: 12, color: AppColors.textHigh)),
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
