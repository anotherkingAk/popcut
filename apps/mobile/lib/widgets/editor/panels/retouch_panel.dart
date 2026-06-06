import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/app_motion.dart';
import '../../../services/haptic_service.dart';

class RetouchPanel extends StatelessWidget {
  final AnimationController staggerController;
  const RetouchPanel({super.key, required this.staggerController});

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
                _buildLabeledSlider('Skin Smoothing', 50, 0, 100),
                const SizedBox(height: 16),
                _buildToolCard('Blemish Removal', Icons.healing, false),
                const SizedBox(height: 12),
                _buildToolCard('Teeth Whitening', Icons.face, false),
                const SizedBox(height: 12),
                _buildToolCard('Eye Brightening', Icons.visibility, false),
                const SizedBox(height: 16),
                _buildToggleRow('Before/After Compare', false),
                const SizedBox(height: 16),
                _buildAutoEnhanceButton(),
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
      child: const Text('Retouch', style: AppTypography.titleSm),
    );
  }

  Widget _buildToolCard(String label, IconData icon, bool active) {
    return GestureDetector(
      onTap: () => HapticService.trigger(HapticLevel.light),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: active ? AppColors.brand500 : AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: active ? AppColors.brand500 : AppColors.textMedium),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textHigh))),
            const Text('WIP', style: TextStyle(fontSize: 10, color: AppColors.textLow, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildAutoEnhanceButton() {
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
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 16, height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
              SizedBox(width: 10),
              Text('Auto Enhance', style: TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600)),
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
