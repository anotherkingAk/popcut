import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_motion.dart';
import '../../services/haptic_service.dart';
import '../../widgets/common/app_bottom_sheet.dart';

class KeyframeEditorSheet extends StatelessWidget {
  const KeyframeEditorSheet({super.key});

  static const _properties = ['Position', 'Scale', 'Rotation', 'Opacity'];

  static void show(BuildContext context) {
    AppBottomSheet.show(
      context: context,
      title: 'Keyframes',
      icon: Icons.keyboard,
      body: const KeyframeEditorSheet(),
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
          Text('Property', style: AppTypography.label),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.bgElevated,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: const [
                Expanded(child: Text('Position', style: AppTypography.bodyLg)),
                Icon(Icons.arrow_drop_down, color: AppColors.textLow),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.bgElevated,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, size: 18),
                  color: AppColors.textMedium,
                  onPressed: () => HapticService.trigger(HapticLevel.light),
                ),
                const Text('Frame 2', style: AppTypography.titleSm),
                IconButton(
                  icon: const Icon(Icons.chevron_right, size: 18),
                  color: AppColors.textMedium,
                  onPressed: () => HapticService.trigger(HapticLevel.light),
                ),
                const Spacer(),
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.bgOverlay,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('1:15', style: AppTypography.bodySm),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.bgElevated,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: CustomPaint(
              painter: _TimelineStripPainter(),
              size: const Size(double.infinity, 60),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    HapticService.trigger(HapticLevel.light);
                  },
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add'),
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
                  label: const Text('Remove'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: BorderSide(color: AppColors.error.withValues(alpha: 0.3)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Value', style: AppTypography.label),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.bgElevated,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Text('X:', style: AppTypography.bodyMd),
                const SizedBox(width: 8),
                Container(
                  width: 60,
                  child: const Text('540', style: AppTypography.bodyLg),
                ),
                const Spacer(),
                const Text('Y:', style: AppTypography.bodyMd),
                const SizedBox(width: 8),
                Container(
                  width: 60,
                  child: const Text('320', style: AppTypography.bodyLg),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text('Interpolation', style: AppTypography.label),
          const SizedBox(height: 6),
          Row(
            children: [
              _InterpolationChip(label: 'Linear'),
              const SizedBox(width: 8),
              _InterpolationChip(label: 'Ease In'),
              const SizedBox(width: 8),
              _InterpolationChip(label: 'Ease Out'),
              const SizedBox(width: 8),
              _InterpolationChip(label: 'Bezier'),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                HapticService.trigger(HapticLevel.light);
                Navigator.pop(context);
              },
              child: const Text('Done'),
            ),
          ),
        ],
      ),
    );
  }
}

class _InterpolationChip extends StatefulWidget {
  final String label;
  const _InterpolationChip({required this.label});

  @override
  State<_InterpolationChip> createState() => _InterpolationChipState();
}

class _InterpolationChipState extends State<_InterpolationChip> {
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.brand500.withValues(alpha: 0.15) : AppColors.bgElevated,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: selected ? AppColors.brand500 : AppColors.border),
        ),
        child: Text(widget.label, style: TextStyle(
          fontSize: 11,
          color: selected ? AppColors.textHigh : AppColors.textMedium,
        )),
      ),
    );
  }
}

class _TimelineStripPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.timelineGrid
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 20) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    final markerPaint = Paint()
      ..color = AppColors.brand500
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.3, size.height / 2), 5, markerPaint);
    canvas.drawCircle(Offset(size.width * 0.6, size.height / 2), 5, markerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
