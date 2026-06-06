import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../services/haptic_service.dart';

class SnapConfig extends StatelessWidget {
  final AnimationController staggerController;
  const SnapConfig({super.key, required this.staggerController});

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
                _buildToggleRow('Snap to Clips', true),
                _buildToggleRow('Snap to Markers', true),
                _buildToggleRow('Snap to Playhead', true),
                _buildToggleRow('Snap to Track Boundaries', false),
                _buildToggleRow('Snap to Keyframes', true),
                _buildToggleRow('Snap to Grid', false),
                const SizedBox(height: 16),
                _buildSensitivitySelector(),
                const SizedBox(height: 16),
                _buildToggleRow('Show Snap Guides', true),
                const SizedBox(height: 8),
                _buildSnapAllToggle(),
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
      child: const Text('Snap Settings', style: AppTypography.titleSm),
    );
  }

  Widget _buildSensitivitySelector() {
    final levels = ['Low', 'Medium', 'High'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Snap Sensitivity', style: AppTypography.bodySm),
        const SizedBox(height: 8),
        Row(
          children: levels.map((l) => Expanded(
            child: GestureDetector(
              onTap: () => HapticService.trigger(HapticLevel.light),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: l == 'Medium' ? AppColors.brand500.withValues(alpha: 0.15) : AppColors.bgSurface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: l == 'Medium' ? AppColors.brand500 : AppColors.border),
                ),
                child: Center(child: Text(l, style: TextStyle(fontSize: 11, color: l == 'Medium' ? AppColors.brand500 : AppColors.textMedium))),
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildSnapAllToggle() {
    return GestureDetector(
      onTap: () => HapticService.trigger(HapticLevel.light),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.brand500.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.brand500.withValues(alpha: 0.3)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_fix_high, size: 16, color: AppColors.brand500),
            SizedBox(width: 8),
            Text('Snap to All', style: TextStyle(fontSize: 12, color: AppColors.brand500, fontWeight: FontWeight.w600)),
          ],
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
}
