import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/project.dart';
import '../../services/haptic_service.dart';

class PropertiesPanel extends StatelessWidget {
  final ClipModel? clip;
  final TrackType? trackType;
  final VoidCallback onClose;

  const PropertiesPanel({
    super.key,
    this.clip,
    this.trackType,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      color: AppColors.bgSurface,
      child: Column(
        children: [
          _buildHeader(),
          const Divider(height: 0.5, color: AppColors.border),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _PropertySlider(label: 'Position X', value: 0, min: -2000, max: 2000),
                _PropertySlider(label: 'Position Y', value: 0, min: -2000, max: 2000),
                _PropertySlider(label: 'Scale', value: 100, min: 0, max: 500),
                _PropertySlider(label: 'Rotation', value: 0, min: 0, max: 360),
                _PropertySlider(label: 'Opacity', value: 100, min: 0, max: 100),
                if (trackType == TrackType.audio) ...[
                  _PropertySlider(label: 'Volume', value: 100, min: 0, max: 200),
                  _PropertySlider(label: 'Fade In', value: 0, min: 0, max: 5),
                  _PropertySlider(label: 'Fade Out', value: 0, min: 0, max: 5),
                ],
                if (trackType == TrackType.text) ...[
                  _PropertyRow(label: 'Font', value: 'Inter'),
                  _PropertyRow(label: 'Size', value: '48'),
                  _PropertyRow(label: 'Color', value: '#FFFFFF'),
                  _PropertyRow(label: 'Alignment', value: 'Center'),
                  _PropertyRow(label: 'Animation', value: 'Fade In'),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          const Text('Properties', style: AppTypography.titleSm),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            color: AppColors.textLow,
            onPressed: () { HapticService.trigger(HapticLevel.light); onClose(); },
          ),
        ],
      ),
    );
  }
}

class _PropertySlider extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;

  const _PropertySlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label, style: AppTypography.bodySm),
              const Spacer(),
              Text(value.toStringAsFixed(0), style: AppTypography.bodySm.copyWith(color: AppColors.textHigh)),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 2.5,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
              activeTrackColor: AppColors.brand500,
              inactiveTrackColor: AppColors.timelineGrid,
              thumbColor: AppColors.brand500,
            ),
            child: Slider(value: value, min: min, max: max, onChanged: (_) { HapticService.trigger(HapticLevel.light); }),
          ),
        ],
      ),
    );
  }
}

class _PropertyRow extends StatelessWidget {
  final String label;
  final String value;

  const _PropertyRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5))),
      child: Row(
        children: [
          Text(label, style: AppTypography.bodySm),
          const Spacer(),
          Text(value, style: AppTypography.bodySm.copyWith(color: AppColors.textHigh)),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, size: 14, color: AppColors.textLow),
        ],
      ),
    );
  }
}
