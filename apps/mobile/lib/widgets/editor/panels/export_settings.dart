import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../services/haptic_service.dart';

class ExportSettings extends StatelessWidget {
  final AnimationController staggerController;
  const ExportSettings({super.key, required this.staggerController});

  static const _resolutions = ['4K', '1080p', '720p', '480p'];
  static const _formats = ['MP4', 'MOV', 'WebM', 'GIF'];
  static const _codecs = ['H.264', 'H.265', 'VP8', 'VP9'];
  static const _bitrateModes = ['Constant', 'Variable'];

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
                _buildSelector('Resolution', _resolutions, 1),
                const SizedBox(height: 16),
                _buildQualitySlider(),
                const SizedBox(height: 12),
                _buildSelector('Format', _formats, 0),
                const SizedBox(height: 16),
                _buildSelector('Codec', _codecs, 0),
                const SizedBox(height: 16),
                _buildSelector('Bitrate Mode', _bitrateModes, 0),
                const SizedBox(height: 16),
                _buildToggleRow('Match Frame Rate', true),
                const SizedBox(height: 12),
                _buildSliderLabeled('Keyframe Interval', 12, 1, 60),
                const SizedBox(height: 12),
                _buildSliderLabeled('Audio Bitrate', 192, 64, 320),
                const SizedBox(height: 16),
                _buildExportRange(),
                const SizedBox(height: 16),
                _buildEstimatedSize(),
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
      child: const Text('Export Settings', style: AppTypography.titleSm),
    );
  }

  Widget _buildSelector(String label, List<String> items, int selected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.bodySm),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: items.asMap().entries.map((e) => GestureDetector(
            onTap: () => HapticService.trigger(HapticLevel.light),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: e.key == selected ? AppColors.brand500.withValues(alpha: 0.15) : AppColors.bgSurface,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: e.key == selected ? AppColors.brand500 : AppColors.border),
              ),
              child: Text(e.value, style: TextStyle(fontSize: 12, color: e.key == selected ? AppColors.brand500 : AppColors.textMedium)),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildQualitySlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Quality', style: AppTypography.bodySm),
            const Spacer(),
            const Text('100%', style: TextStyle(fontSize: 12, color: AppColors.textHigh)),
          ],
        ),
        SliderTheme(
          data: const SliderThemeData(
            trackHeight: 3, activeTrackColor: AppColors.brand500, inactiveTrackColor: AppColors.timelineGrid, thumbColor: AppColors.brand500,
          ),
          child: Slider(value: 100, min: 1, max: 100, onChanged: (_) => HapticService.trigger(HapticLevel.light)),
        ),
      ],
    );
  }

  Widget _buildExportRange() {
    return Row(
      children: [
        const Text('Export Range', style: AppTypography.bodySm),
        const Spacer(),
        GestureDetector(
          onTap: () => HapticService.trigger(HapticLevel.light),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.brand500.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.brand500),
            ),
            child: const Text('All', style: TextStyle(fontSize: 11, color: AppColors.brand500, fontWeight: FontWeight.w500)),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => HapticService.trigger(HapticLevel.light),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.border),
            ),
            child: const Text('Custom', style: TextStyle(fontSize: 11, color: AppColors.textMedium)),
          ),
        ),
      ],
    );
  }

  Widget _buildEstimatedSize() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.2)),
      ),
      child: const Row(
        children: [
          Icon(Icons.sd_card, size: 16, color: AppColors.info),
          SizedBox(width: 8),
          Text('Estimated File Size: ', style: TextStyle(fontSize: 11, color: AppColors.textMedium)),
          Text('~245 MB', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textHigh)),
        ],
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
