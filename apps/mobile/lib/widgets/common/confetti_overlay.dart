import 'dart:math';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/haptic_service.dart';

class ConfettiOverlay extends StatefulWidget {
  final VoidCallback? onDismiss;

  const ConfettiOverlay({super.key, this.onDismiss});

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_ConfettiParticle> _particles;

  final _colors = [
    AppColors.brand500, AppColors.brand300, AppColors.brand200,
    AppColors.trackAudio, AppColors.trackText, AppColors.success,
    AppColors.warning, AppColors.info,
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _particles = List.generate(50, (i) => _ConfettiParticle(
      x: Random().nextDouble(),
      y: -Random().nextDouble(),
      speed: 0.3 + Random().nextDouble() * 0.7,
      size: 4 + Random().nextDouble() * 6,
      color: _colors[Random().nextInt(_colors.length)],
      rotation: Random().nextDouble() * 6.28,
      rotationSpeed: (Random().nextDouble() - 0.5) * 8,
      wobble: Random().nextDouble() * 100,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Stack(
          children: [
            GestureDetector(
              onTap: widget.onDismiss,
              child: Container(color: Colors.transparent),
            ),
            CustomPaint(
              size: MediaQuery.of(context).size,
              painter: _ConfettiPainter(particles: _particles, progress: _controller.value),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, size: 64, color: AppColors.success),
                  const SizedBox(height: 16),
                  Text('Export Complete!', style: AppTypography.displaySm.copyWith(color: AppColors.textHigh)),
                  const SizedBox(height: 8),
                  Text('45 MB', style: AppTypography.bodyLg.copyWith(color: AppColors.textMedium)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () { HapticService.trigger(HapticLevel.light); },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.brand500),
                    child: const Text('Share'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () { HapticService.trigger(HapticLevel.light); },
                    child: const Text('Play Exported Video'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () { HapticService.trigger(HapticLevel.light); },
                    child: const Text('New Project', style: TextStyle(color: AppColors.textMedium)),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ConfettiParticle {
  final double x, y, speed, size, rotation, rotationSpeed, wobble;
  final Color color;
  _ConfettiParticle({
    required this.x, required this.y, required this.speed,
    required this.size, required this.color, required this.rotation,
    required this.rotationSpeed, required this.wobble,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;

  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final y = (p.y + progress * p.speed) * size.height;
      if (y > size.height + 20) continue;
      final wobbleOffset = sin(progress * p.wobble) * 10;
      final x = (p.x * size.width + wobbleOffset).clamp(0.0, size.width);
      final opacity = (1 - (y / size.height)).clamp(0.0, 1.0);
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.rotation + progress * p.rotationSpeed);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.6),
        Paint()..color = p.color.withValues(alpha: opacity)..style = PaintingStyle.fill,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) => old.progress != progress;
}
