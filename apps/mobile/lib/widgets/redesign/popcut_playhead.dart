import 'package:flutter/material.dart';
import '../../theme/popcut_theme.dart';

class PopCutPlayhead extends StatelessWidget {
  final double position;
  final double totalDuration;
  final ValueChanged<double>? onSeek;
  final double height;

  const PopCutPlayhead({
    super.key,
    required this.position,
    required this.totalDuration,
    this.onSeek,
    this.height = 32,
  });

  @override
  Widget build(BuildContext context) {
    final fraction = totalDuration > 0 ? position / totalDuration : 0.0;

    return RepaintBoundary(
      child: SizedBox(
      height: height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final playheadX = constraints.maxWidth * fraction;
          return Stack(
            children: [
              // Time ruler background
              Positioned.fill(
                child: CustomPaint(
                  painter: _TimeRulerPainter(
                    totalDuration: totalDuration,
                    width: constraints.maxWidth,
                    color: PopCutColors.textMuted.withValues(alpha: 0.3),
                    accentColor: PopCutColors.textMuted.withValues(alpha: 0.15),
                  ),
                ),
              ),
              // Seekable area
              GestureDetector(
                onTapDown: (details) {
                  if (onSeek == null) return;
                  final seekPos = details.localPosition.dx / constraints.maxWidth;
                  onSeek!(seekPos * totalDuration);
                },
                onHorizontalDragUpdate: (details) {
                  if (onSeek == null) return;
                  final seekPos = details.localPosition.dx / constraints.maxWidth;
                  onSeek!((seekPos * totalDuration).clamp(0, totalDuration));
                },
                child: Container(
                  color: Colors.transparent,
                  width: double.infinity,
                  height: height,
                ),
              ),
              // Playhead line
              Positioned(
                left: playheadX - 1,
                top: 0,
                bottom: 0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: PopCutColors.primary,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(2),
                          bottomRight: Radius.circular(2),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: PopCutColors.primary.withValues(alpha: 0.5),
                            blurRadius: 8,
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 2,
                      color: PopCutColors.primary,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    ),
  );
  }
}

class _TimeRulerPainter extends CustomPainter {
  final double totalDuration;
  final double width;
  final Color color;
  final Color accentColor;

  _TimeRulerPainter({
    required this.totalDuration,
    required this.width,
    required this.color,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.5;

    final accentPaint = Paint()
      ..color = accentColor
      ..strokeWidth = 0.5;

    final interval = totalDuration > 60 ? 10.0 : 5.0;

    for (double t = 0; t <= totalDuration; t += interval) {
      final x = (t / totalDuration) * width;
      final isMajor = t % (interval * 2) == 0;
      canvas.drawLine(
        Offset(x, isMajor ? 10 : 14),
        Offset(x, size.height),
        isMajor ? paint : accentPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_TimeRulerPainter oldDelegate) =>
      oldDelegate.totalDuration != totalDuration ||
      oldDelegate.width != width;
}
