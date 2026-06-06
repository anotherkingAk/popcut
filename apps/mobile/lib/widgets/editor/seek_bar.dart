import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/haptic_service.dart';

class SeekBar extends StatelessWidget {
  final double currentPosition;
  final double totalDuration;
  final double buffered;
  final ValueChanged<double> onSeek;

  const SeekBar({
    super.key,
    required this.currentPosition,
    required this.totalDuration,
    this.buffered = 0,
    required this.onSeek,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalDuration > 0 ? (currentPosition / totalDuration).clamp(0, 1) : 0.0;
    return Container(
      height: 32,
      color: AppColors.background,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Text(_formatTime(currentPosition), style: const TextStyle(fontSize: 10, color: AppColors.foregroundSecondary, fontFeatures: [FontFeature.tabularFigures()])),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTapDown: (d) { HapticService.trigger(HapticLevel.light); onSeek((d.localPosition.dx / (context.size!.width - 16)) * totalDuration); },
              onHorizontalDragUpdate: (d) => onSeek(((d.localPosition.dx) / (context.size!.width - 16)).clamp(0, 1) * totalDuration),
              child: LayoutBuilder(
                builder: (_, constraints) {
                  return Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      Container(height: 3, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
                      Container(width: constraints.maxWidth * buffered, height: 3, decoration: BoxDecoration(color: AppColors.foregroundMuted.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
                      Container(width: constraints.maxWidth * progress, height: 3, decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primary]), borderRadius: BorderRadius.circular(2))),
                      Positioned(left: constraints.maxWidth * progress - 6, child: Container(width: 12, height: 12, decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.4), blurRadius: 4)])),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(_formatTime(totalDuration), style: const TextStyle(fontSize: 10, color: AppColors.foregroundMuted, fontFeatures: [FontFeature.tabularFigures()])),
        ],
      ),
    );
  }

  String _formatTime(double seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toStringAsFixed(0).padLeft(2, '0');
    return '$m:$s';
  }
}
