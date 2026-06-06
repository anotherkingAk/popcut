import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/haptic_service.dart';
import '../../widgets/common/app_bottom_sheet.dart';

class TrackPropertiesSheet extends StatelessWidget {
  const TrackPropertiesSheet({super.key});

  static void show(BuildContext context) {
    AppBottomSheet.show(
      context: context,
      title: 'Track Properties',
      icon: Icons.layers_outlined,
      body: const TrackPropertiesSheet(),
      maxHeightFactor: 0.92,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8, height: 32,
                decoration: BoxDecoration(
                  color: AppColors.trackVideo,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.videocam, size: 18, color: AppColors.trackVideo),
              const SizedBox(width: 8),
              const Text('Video Track 1', style: AppTypography.titleMd),
            ],
          ),
          const SizedBox(height: 20),
          _ToggleRow('Visible', true),
          _ToggleRow('Locked', false),
          const SizedBox(height: 12),
          Text('Clips: 4  ·  Duration: 3:42', style: AppTypography.bodyMd),
          const SizedBox(height: 16),
          Text('Height', style: AppTypography.label),
          Row(
            children: [
              const Text('48', style: AppTypography.bodySm),
              Expanded(
                child: Slider(value: 64, min: 32, max: 160, divisions: 8, onChanged: (_) {}),
              ),
              const Text('160', style: AppTypography.bodySm),
            ],
          ),
          const SizedBox(height: 12),
          Text('Collapse', style: AppTypography.label),
          Row(
            children: [
              const Text('None', style: AppTypography.bodyMd),
              Expanded(
                child: Slider(value: 0, min: 0, max: 3, divisions: 3, onChanged: (_) {}),
              ),
              const Text('Max', style: AppTypography.bodySm),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                HapticService.trigger(HapticLevel.light);
                Navigator.pop(context);
              },
              icon: const Icon(Icons.check, size: 18),
              label: const Text('Done'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                HapticService.delete();
              },
              icon: const Icon(Icons.delete_outline, size: 18),
              label: const Text('Delete Track'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: BorderSide(color: AppColors.error.withValues(alpha: 0.3)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatefulWidget {
  final String label;
  final bool initialValue;
  const _ToggleRow(this.label, this.initialValue);

  @override
  State<_ToggleRow> createState() => _ToggleRowState();
}

class _ToggleRowState extends State<_ToggleRow> {
  late bool _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(widget.label, style: AppTypography.bodyMd),
          const Spacer(),
          Switch(
            value: _value,
            onChanged: (v) {
              HapticService.trigger(HapticLevel.light);
              setState(() => _value = v);
            },
          ),
        ],
      ),
    );
  }
}
