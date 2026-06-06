import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_motion.dart';
import '../../services/haptic_service.dart';
import '../../widgets/common/app_bottom_sheet.dart';

class SpeedCurveSheet extends StatelessWidget {
  const SpeedCurveSheet({super.key});

  static const _presets = ['Linear', 'Ease In', 'Ease Out', 'Ease In-Out', 'Bounce', 'Elastic'];

  static void show(BuildContext context) {
    AppBottomSheet.show(
      context: context,
      title: 'Speed Curve',
      icon: Icons.timeline,
      body: const SpeedCurveSheet(),
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
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: AppColors.bgElevated,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: CustomPaint(
              painter: _GraphEditorPainter(),
              size: const Size(double.infinity, 180),
            ),
          ),
          const SizedBox(height: 16),
          Text('Presets', style: AppTypography.label),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _presets.map((p) => _PresetChip(label: p)).toList(),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.bgElevated,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Text('Speed Range:', style: AppTypography.bodyMd),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.bgOverlay,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('0.5× – 2.0×', style: AppTypography.bodySm),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
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

class _GraphEditorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = AppColors.timelineGrid
      ..strokeWidth = 0.5;
    for (double i = 0; i <= size.width; i += size.width / 4) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);
    }
    for (double i = 0; i <= size.height; i += size.height / 4) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), gridPaint);
    }
    final curvePaint = Paint()
      ..color = AppColors.brand500
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(0, size.height)
      ..cubicTo(size.width * 0.3, size.height * 0.3, size.width * 0.7, size.height * 0.3, size.width, 0);
    canvas.drawPath(path, curvePaint);
    final dotPaint = Paint()
      ..color = AppColors.brand500
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.3), 5, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.3), 5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
