import 'dart:math';
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../services/haptic_service.dart';

class SpeedPanel extends StatelessWidget {
  final AnimationController staggerController;
  const SpeedPanel({super.key, required this.staggerController});

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
                _buildSpeedDial(),
                const SizedBox(height: 24),
                _buildSpeedSlider(context),
                const SizedBox(height: 16),
                _buildPresets(),
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
      child: const Row(
        children: [
          Text('Speed', style: AppTypography.titleSm),
          Spacer(),
          Text('1.0x', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.brand500)),
        ],
      ),
    );
  }

  Widget _buildSpeedDial() {
    return Container(
      height: 120,
      child: CustomPaint(
        painter: _SpeedDialPainter(),
        size: const Size(double.infinity, 120),
        child: Center(
          child: Container(
            width: 60, height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.brand500.withValues(alpha: 0.15),
              border: Border.all(color: AppColors.brand500, width: 2),
            ),
            child: const Center(
              child: Text('1.0x', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.brand500)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpeedSlider(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Speed', style: AppTypography.bodySm),
            const Spacer(),
            const Text('1.0x', style: TextStyle(fontSize: 12, color: AppColors.textHigh)),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 3,
            activeTrackColor: AppColors.brand500,
            inactiveTrackColor: AppColors.timelineGrid,
            thumbColor: AppColors.brand500,
          ),
          child: Slider(value: 1.0, min: 0.1, max: 100, divisions: 999, onChanged: (_) { HapticService.trigger(HapticLevel.light); }),
        ),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('0.1x', style: TextStyle(fontSize: 10, color: AppColors.textLow)),
            Text('100x', style: TextStyle(fontSize: 10, color: AppColors.textLow)),
          ],
        ),
      ],
    );
  }

  Widget _buildPresets() {
    final presets = ['0.25x', '0.5x', '1x', '1.5x', '2x', '4x'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Presets', style: AppTypography.titleSm),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: presets.map((p) => GestureDetector(
            onTap: () { HapticService.trigger(HapticLevel.light); },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: p == '1x' ? AppColors.brand500.withValues(alpha: 0.15) : AppColors.bgSurface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: p == '1x' ? AppColors.brand500 : AppColors.border),
              ),
              child: Text(p, style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: p == '1x' ? AppColors.brand500 : AppColors.textMedium,
              )),
            ),
          )).toList(),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Text('Preserve Pitch', style: TextStyle(fontSize: 13, color: AppColors.textMedium)),
            const Spacer(),
            Switch(value: true, onChanged: (_) { HapticService.trigger(HapticLevel.selection); }),
          ],
        ),
      ],
    );
  }
}

class _SpeedDialPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = 52.0;
    final paint = Paint()
      ..color = AppColors.timelineGrid
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawCircle(center, radius, paint);
    canvas.drawCircle(center, radius * 0.7, paint);
    canvas.drawCircle(center, radius * 0.4, paint);

    for (double i = 0; i < 360; i += 30) {
      final rad = i * 3.14159 / 180;
      final outer = Offset(center.dx + cos(rad) * radius, center.dy + sin(rad) * radius);
      final inner = Offset(center.dx + cos(rad) * radius * 0.85, center.dy + sin(rad) * radius * 0.85);
      canvas.drawLine(inner, outer, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
