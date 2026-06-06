import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/app_motion.dart';
import '../../../services/haptic_service.dart';

class ProxyToggle extends StatelessWidget {
  final AnimationController staggerController;
  const ProxyToggle({super.key, required this.staggerController});

  static const _resolutions = ['Original', '4K', '1080p', '720p', '480p'];

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
                _buildResolutionSelector(),
                const SizedBox(height: 16),
                _buildStatusIndicator(),
                const SizedBox(height: 16),
                _buildGenerateButton(),
                const SizedBox(height: 12),
                _buildSliderLabeled('Progress', 65, 0, 100),
                const SizedBox(height: 16),
                _buildToggleRow('Use Proxy for Playback', true),
                _buildToggleRow('Auto-Generate', false),
                const SizedBox(height: 16),
                _buildStorageInfo(),
                const SizedBox(height: 8),
                _buildDeleteButton(),
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
      child: const Text('Proxy', style: AppTypography.titleSm),
    );
  }

  Widget _buildResolutionSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Proxy Resolution', style: AppTypography.bodySm),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _resolutions.map((r) => GestureDetector(
            onTap: () => HapticService.trigger(HapticLevel.light),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: r == '720p' ? AppColors.brand500.withValues(alpha: 0.15) : AppColors.bgSurface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: r == '720p' ? AppColors.brand500 : AppColors.border),
              ),
              child: Text(r, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: r == '720p' ? AppColors.brand500 : AppColors.textMedium)),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildStatusIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.sync, size: 18, color: AppColors.warning),
          SizedBox(width: 10),
          Text('Generating Proxy...', style: TextStyle(fontSize: 13, color: AppColors.warning, fontWeight: FontWeight.w500)),
          Spacer(),
          Text('65%', style: TextStyle(fontSize: 13, color: AppColors.warning, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildGenerateButton() {
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
          child: const Center(
            child: Text('Generate Proxy', style: TextStyle(fontSize: 13, color: AppColors.brand500, fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }

  Widget _buildStorageInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.storage, size: 16, color: AppColors.success),
          SizedBox(width: 10),
          Text('Storage Saved: ', style: TextStyle(fontSize: 12, color: AppColors.textMedium)),
          Text('2.4 GB', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textHigh)),
        ],
      ),
    );
  }

  Widget _buildDeleteButton() {
    return GestureDetector(
      onTap: () => HapticService.trigger(HapticLevel.light),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
        ),
        child: const Center(
          child: Text('Delete Proxy Files', style: TextStyle(fontSize: 12, color: AppColors.error, fontWeight: FontWeight.w500)),
        ),
      ),
    );
  }

  Widget _buildSliderLabeled(String label, double value, double min, double max) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: AppTypography.bodySm),
            const Spacer(),
            Text('${value.toInt()}%', style: const TextStyle(fontSize: 11, color: AppColors.textHigh)),
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
