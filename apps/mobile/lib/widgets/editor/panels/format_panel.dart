import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../services/haptic_service.dart';

class FormatPanel extends StatelessWidget {
  final AnimationController staggerController;
  const FormatPanel({super.key, required this.staggerController});

  static const _ratios = ['9:16 TikTok/Reels', '16:9 YouTube', '1:1 Instagram', '4:3 Facebook', 'Custom'];

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
                _buildRatioSelector(),
                const SizedBox(height: 16),
                _buildCropPreview(),
                const SizedBox(height: 16),
                _buildFormatLabel(),
                const SizedBox(height: 16),
                _buildToggleRow('Smart Crop AI', false),
                const SizedBox(height: 12),
                _buildToggleRow('Zoom Crop', true),
                const SizedBox(height: 16),
                _buildTimelineMarkers(),
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
      child: const Text('Format', style: AppTypography.titleSm),
    );
  }

  Widget _buildRatioSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Aspect Ratio', style: AppTypography.bodySm),
        const SizedBox(height: 8),
        ..._ratios.asMap().entries.map((e) => GestureDetector(
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
                if (e.key < 4) ...[
                  const Spacer(),
                    Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.bgElevated,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(e.value.split(' ').first, style: const TextStyle(fontSize: 9, color: AppColors.textLow, fontFamily: 'JetBrainsMono')),
                  ),
                ],
              ],
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildCropPreview() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Center(
        child: Container(
          width: 80, height: 140,
          decoration: BoxDecoration(
            color: AppColors.bgElevated,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppColors.brand500, width: 2),
          ),
          child: Center(
            child: Icon(Icons.crop, size: 24, color: AppColors.brand500.withValues(alpha: 0.5)),
          ),
        ),
      ),
    );
  }

  Widget _buildFormatLabel() {
    return Row(
      children: [
        const Text('Format Label', style: TextStyle(fontSize: 12, color: AppColors.textMedium)),
        const Spacer(),
        Container(
          width: 120,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(color: AppColors.bgSurface, borderRadius: BorderRadius.circular(6), border: Border.all(color: AppColors.border)),
          child: const TextField(
            style: TextStyle(fontSize: 12, color: AppColors.textHigh),
            decoration: InputDecoration.collapsed(hintText: 'TikTok 9:16', hintStyle: TextStyle(color: AppColors.textLow)),
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineMarkers() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Timeline Format Markers', style: TextStyle(fontSize: 11, color: AppColors.textMedium)),
          SizedBox(height: 8),
          Row(
            children: [
              _MarkerDot(color: AppColors.brand500, label: '9:16'),
              SizedBox(width: 12),
              _MarkerDot(color: AppColors.success, label: '16:9'),
              SizedBox(width: 12),
              _MarkerDot(color: AppColors.warning, label: '1:1'),
            ],
          ),
        ],
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

class _MarkerDot extends StatelessWidget {
  final Color color;
  final String label;
  const _MarkerDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 9, color: AppColors.textLow)),
      ],
    );
  }
}
