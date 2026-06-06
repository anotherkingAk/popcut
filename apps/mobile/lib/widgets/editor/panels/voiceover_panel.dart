import 'dart:math';
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../services/haptic_service.dart';

class VoiceoverPanel extends StatelessWidget {
  final AnimationController staggerController;
  const VoiceoverPanel({super.key, required this.staggerController});

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
                _buildWaveformVisualizer(),
                const SizedBox(height: 16),
                _buildRecordingControls(),
                const SizedBox(height: 12),
                _buildLevelMeter(),
                const SizedBox(height: 16),
                _buildPlaybackControls(),
                const SizedBox(height: 16),
                _buildToggleRow('Noise Gate', true),
                const SizedBox(height: 12),
                _buildLabeledSlider('Gain', 100, 0, 200),
                const SizedBox(height: 12),
                _buildDeviceSelector(),
                const SizedBox(height: 12),
                _buildToggleRow('Voice Enhancement', false),
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
      child: const Text('Voiceover', style: AppTypography.titleSm),
    );
  }

  Widget _buildWaveformVisualizer() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: CustomPaint(
        painter: _VoiceWavePainter(),
        size: const Size(double.infinity, 60),
      ),
    );
  }

  Widget _buildRecordingControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => HapticService.trigger(HapticLevel.light),
          child: Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.error.withValues(alpha: 0.2),
              border: Border.all(color: AppColors.error, width: 3),
            ),
            child: const Icon(Icons.mic, size: 28, color: AppColors.error),
          ),
        ),
        const SizedBox(width: 20),
        GestureDetector(
          onTap: () => HapticService.trigger(HapticLevel.light),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(color: AppColors.bgSurface, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
            child: const Text('Pause', style: TextStyle(fontSize: 12, color: AppColors.textMedium)),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () => HapticService.trigger(HapticLevel.heavy),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.error.withValues(alpha: 0.3))),
            child: const Row(
              children: [
                Icon(Icons.refresh, size: 12, color: AppColors.error),
                SizedBox(width: 4),
                Text('Re-record', style: TextStyle(fontSize: 10, color: AppColors.error)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLevelMeter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Level', style: AppTypography.bodySm),
            const Spacer(),
            const Text('0:12', style: TextStyle(fontSize: 11, color: AppColors.textHigh, fontFamily: 'JetBrainsMono')),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Container(
            height: 6,
            color: AppColors.timelineGrid,
            child: Row(
              children: [
                Container(width: 140, color: AppColors.success),
                Container(width: 60, color: AppColors.warning),
                Container(width: 20, color: AppColors.error),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaybackControls() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => HapticService.trigger(HapticLevel.light),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.brand500.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.brand500),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_arrow, size: 16, color: AppColors.brand500),
                  SizedBox(width: 4),
                  Text('Play Preview', style: TextStyle(fontSize: 11, color: AppColors.brand500, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDeviceSelector() {
    return Row(
      children: [
        const Text('Input Device', style: AppTypography.bodySm),
        const Spacer(),
        GestureDetector(
          onTap: () => HapticService.trigger(HapticLevel.light),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: AppColors.bgSurface, borderRadius: BorderRadius.circular(6), border: Border.all(color: AppColors.border)),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Built-in Mic', style: TextStyle(fontSize: 11, color: AppColors.textHigh)),
                Icon(Icons.arrow_drop_down, size: 14, color: AppColors.textLow),
              ],
            ),
          ),
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
            Text('${value.toInt()}%', style: const TextStyle(fontSize: 12, color: AppColors.textHigh)),
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

class _VoiceWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..strokeWidth = 2..strokeCap = StrokeCap.round;
    final rng = Random(99);
    final bars = 40;
    final barW = size.width / bars;
    for (int i = 0; i < bars; i++) {
      final h = 6 + rng.nextDouble() * 36;
      paint.color = i % 3 == 0 ? AppColors.error.withValues(alpha: 0.6) : AppColors.brand500.withValues(alpha: 0.4);
      canvas.drawLine(
        Offset(i * barW + barW / 2, size.height / 2 - h / 2),
        Offset(i * barW + barW / 2, size.height / 2 + h / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
