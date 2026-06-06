import 'dart:math';
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/app_motion.dart';
import '../../../services/haptic_service.dart';

class BeatSyncPanel extends StatelessWidget {
  final AnimationController staggerController;
  const BeatSyncPanel({super.key, required this.staggerController});

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
                _buildWaveform(),
                const SizedBox(height: 16),
                _buildLabeledSlider('Beat Detection Sensitivity', 60, 0, 100),
                const SizedBox(height: 12),
                _buildToggleRow('Snap Cuts to Beat', true),
                const SizedBox(height: 16),
                _buildAutoSyncButton(),
                const SizedBox(height: 12),
                _buildBeatCount(),
                const SizedBox(height: 12),
                _buildAddBeatMarkerButton(),
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
          Text('Beat Sync', style: AppTypography.titleSm),
          Spacer(),
          Text('128 BPM', style: TextStyle(fontSize: 12, color: AppColors.brand500)),
        ],
      ),
    );
  }

  Widget _buildWaveform() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: CustomPaint(
        painter: _WaveformPainter(),
        size: const Size(double.infinity, 60),
      ),
    );
  }

  Widget _buildAutoSyncButton() {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: () => HapticService.trigger(HapticLevel.light),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.brand500.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.brand500),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.sync, size: 16, color: AppColors.brand500),
              SizedBox(width: 8),
              Text('Auto Sync to Beat', style: TextStyle(fontSize: 12, color: AppColors.brand500, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBeatCount() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        children: [
            Icon(Icons.music_note, size: 18, color: AppColors.success),
          SizedBox(width: 10),
          Text('Detected Beats: ', style: TextStyle(fontSize: 12, color: AppColors.textMedium)),
          Text('24', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textHigh)),
        ],
      ),
    );
  }

  Widget _buildAddBeatMarkerButton() {
    return GestureDetector(
      onTap: () => HapticService.trigger(HapticLevel.light),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: 14, color: AppColors.textMedium),
            SizedBox(width: 6),
            Text('Add Beat Marker', style: TextStyle(fontSize: 11, color: AppColors.textMedium)),
          ],
        ),
      ),
    );
  }

  Widget _buildPresets() {
    final presets = ['Fast', 'Medium', 'Slow', 'Custom'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Presets', style: AppTypography.titleSm),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: presets.map((p) => GestureDetector(
            onTap: () => HapticService.trigger(HapticLevel.light),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: p == 'Medium' ? AppColors.brand500.withValues(alpha: 0.15) : AppColors.bgSurface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: p == 'Medium' ? AppColors.brand500 : AppColors.border),
              ),
              child: Text(p, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: p == 'Medium' ? AppColors.brand500 : AppColors.textMedium)),
            ),
          )).toList(),
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

  Widget _buildLabeledSlider(String label, double value, double min, double max) {
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
}

class _WaveformPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.brand500.withValues(alpha: 0.4)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final rng = Random(42);
    final bars = 48;
    final barWidth = size.width / bars;
    for (int i = 0; i < bars; i++) {
      final h = 4 + rng.nextDouble() * 40;
      canvas.drawLine(
        Offset(i * barWidth + barWidth / 2, size.height / 2 - h / 2),
        Offset(i * barWidth + barWidth / 2, size.height / 2 + h / 2),
        paint..color = AppColors.brand500.withValues(alpha: 0.2 + rng.nextDouble() * 0.4),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
