import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_motion.dart';
import '../../services/haptic_service.dart';
import '../../widgets/common/app_bottom_sheet.dart';

class MaskEditorSheet extends StatelessWidget {
  const MaskEditorSheet({super.key});

  static const _shapes = ['Circle', 'Rectangle', 'Heart', 'Star', 'Custom Path'];

  static final _shapeIcons = [
    Icons.circle_outlined,
    Icons.square_outlined,
    Icons.favorite_border,
    Icons.star_border,
    Icons.gesture,
  ];

  static void show(BuildContext context) {
    AppBottomSheet.show(
      context: context,
      title: 'Mask Editor',
      icon: Icons.style,
      body: const MaskEditorSheet(),
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
          Text('Shape', style: AppTypography.label),
          const SizedBox(height: 8),
          Row(
            children: List.generate(_shapes.length, (i) => Expanded(
              child: _ShapeTile(icon: _shapeIcons[i], label: _shapes[i]),
            )),
          ),
          const SizedBox(height: 16),
          Container(
            height: 160,
            decoration: BoxDecoration(
              color: AppColors.bgElevated,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Center(
              child: Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.brand500, width: 2),
                  color: AppColors.brand500.withValues(alpha: 0.1),
                ),
                child: const Icon(Icons.image_outlined, size: 36, color: AppColors.textLow),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _SliderRow('Feather', 0, 100, 20),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Invert', style: AppTypography.bodyMd),
              const Spacer(),
              Switch(value: false, onChanged: (v) {
                HapticService.trigger(HapticLevel.light);
              }),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    HapticService.trigger(HapticLevel.light);
                  },
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Point'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textHigh,
                    side: const BorderSide(color: AppColors.border),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    HapticService.delete();
                  },
                  icon: const Icon(Icons.remove, size: 16),
                  label: const Text('Delete Point'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: BorderSide(color: AppColors.error.withValues(alpha: 0.3)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    HapticService.trigger(HapticLevel.light);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textMedium,
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Reset'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    HapticService.trigger(HapticLevel.light);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ShapeTile extends StatefulWidget {
  final IconData icon;
  final String label;
  const _ShapeTile({required this.icon, required this.label});

  @override
  State<_ShapeTile> createState() => _ShapeTileState();
}

class _ShapeTileState extends State<_ShapeTile> {
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
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.brand500.withValues(alpha: 0.15) : AppColors.bgElevated,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? AppColors.brand500 : AppColors.border),
        ),
        child: Column(
          children: [
            Icon(widget.icon, size: 20, color: selected ? AppColors.brand500 : AppColors.textMedium),
            const SizedBox(height: 4),
            Text(widget.label, style: TextStyle(
              fontSize: 10,
              color: selected ? AppColors.textHigh : AppColors.textMedium,
            )),
          ],
        ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: AppTypography.label),
            const Spacer(),
            Text('${initial.round()}', style: AppTypography.bodySm),
          ],
        ),
        Slider(value: initial, min: min, max: max, divisions: 100, onChanged: (_) {}),
      ],
    );
  }
}
