import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_motion.dart';
import '../../services/haptic_service.dart';
import '../../widgets/common/app_bottom_sheet.dart';

class PanAnimationSheet extends StatelessWidget {
  const PanAnimationSheet({super.key});

  static const _presets = ['Pan Left', 'Pan Right', 'Zoom In', 'Zoom Out', 'Custom'];

  static void show(BuildContext context) {
    AppBottomSheet.show(
      context: context,
      title: 'Pan & Zoom',
      icon: Icons.pan_tool_outlined,
      body: const PanAnimationSheet(),
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
          Text('Ken Burns Presets', style: AppTypography.label),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _presets.map((p) => _PresetChip(label: p)).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Start', style: AppTypography.label),
                    const SizedBox(height: 6),
                    Container(
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.bgElevated,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Center(child: Icon(Icons.image_outlined, size: 28, color: AppColors.textLow)),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Icon(Icons.arrow_forward, color: AppColors.textLow),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('End', style: AppTypography.label),
                    const SizedBox(height: 6),
                    Container(
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.bgElevated,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Center(child: Icon(Icons.image_outlined, size: 28, color: AppColors.textLow)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SliderRow('Pan X', -50, 50, 0),
          _SliderRow('Pan Y', -50, 50, 0),
          _SliderRow('Zoom', 1.0, 3.0, 1.5),
          _SliderRow('Rotation', -180, 180, 0),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('Duration:', style: AppTypography.bodyMd),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.bgOverlay,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('2.0s', style: AppTypography.bodySm),
              ),
              const Spacer(),
              Row(
                children: [
                  const Text('Apply to all', style: AppTypography.bodySm),
                  const SizedBox(width: 6),
                  Switch(value: false, onChanged: (v) {
                    HapticService.trigger(HapticLevel.light);
                  }),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                HapticService.trigger(HapticLevel.light);
                Navigator.pop(context);
              },
              child: const Text('Apply'),
            ),
          ),
        ],
      ),
    );
  }
}

class _PresetChip extends StatefulWidget {
  final String label;
  const _PresetChip({required this.label});

  @override
  State<_PresetChip> createState() => _PresetChipState();
}

class _PresetChipState extends State<_PresetChip> {
  bool _selected = false;

  @override
  Widget build(BuildContext context) {
    final selected = _selected;
    return GestureDetector(
      onTap: () {
        HapticService.trigger(HapticLevel.light);
        setState(() => _selected = !_selected);
      },
      child: AnimatedContainer(
        duration: AppMotion.normal,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.brand500.withValues(alpha: 0.15) : AppColors.bgElevated,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? AppColors.brand500 : AppColors.border),
        ),
        child: Text(widget.label, style: TextStyle(
          fontSize: 13,
          color: selected ? AppColors.textHigh : AppColors.textMedium,
        )),
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  final String label;
  final double min;
  final double max;
  final double initial;
  const _SliderRow(this.label, this.min, this.max, this.initial);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label, style: AppTypography.label),
              const Spacer(),
              Text(initial.toStringAsFixed(1), style: AppTypography.bodySm),
            ],
          ),
          Slider(value: initial, min: min, max: max, onChanged: (_) {}),
        ],
      ),
    );
  }
}
