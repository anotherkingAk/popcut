import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_motion.dart';
import '../../services/haptic_service.dart';
import '../../widgets/common/app_bottom_sheet.dart';

class VolumeEnvelopeSheet extends StatelessWidget {
  const VolumeEnvelopeSheet({super.key});

  static const _presets = ['Fade In', 'Fade Out', 'Fade In-Out', 'Duck'];

  static void show(BuildContext context) {
    AppBottomSheet.show(
      context: context,
      title: 'Volume Envelope',
      icon: Icons.waves,
      body: const VolumeEnvelopeSheet(),
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
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.bgElevated,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: CustomPaint(
              painter: _WaveformPainter(),
              size: const Size(double.infinity, 120),
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
          Text('Preset Shapes', style: AppTypography.label),
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
                const Text('Volume Range:', style: AppTypography.bodyMd),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.bgOverlay,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('0% – 200%', style: AppTypography.bodySm),
                ),
                const Spacer(),
                OutlinedButton(
                  onPressed: () => HapticService.trigger(HapticLevel.light),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textMedium,
                    side: const BorderSide(color: AppColors.border),
                  ),
                  child: const Text('Reset'),
                ),
              ],
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

class _WaveformPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final wavePaint = Paint()
      ..color = AppColors.trackAudio.withValues(alpha: 0.3)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path();
    for (double x = 0; x < size.width; x += 2) {
      final amplitude = (x / size.width) * 20;
      final y = size.height / 2 + (size.height / 4) * (x < size.width * 0.3
          ? (x / (size.width * 0.3))
          : x < size.width * 0.7
              ? 1.0
              : (1 - (x - size.width * 0.7) / (size.width * 0.3)));
      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, wavePaint);

    final envelopePaint = Paint()
      ..color = AppColors.brand500
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final envPath = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width * 0.2, size.height * 0.2)
      ..lineTo(size.width * 0.5, size.height * 0.8)
      ..lineTo(size.width * 0.8, size.height * 0.3)
      ..lineTo(size.width, size.height * 0.1);
    canvas.drawPath(envPath, envelopePaint);

    final dotPaint = Paint()
      ..color = AppColors.brand500
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.2), 5, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.8), 5, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.3), 5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
