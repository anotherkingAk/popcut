import 'dart:math' as math;
import 'package:flutter/material.dart';

class AppMotion {
  // Durations
  static const instant = Duration(milliseconds: 80);
  static const fast = Duration(milliseconds: 150);
  static const normal = Duration(milliseconds: 250);
  static const slow = Duration(milliseconds: 400);
  static const expressive = Duration(milliseconds: 600);

  // Spring physics
  static const springSnappy = SpringDescription(damping: 0.7, stiffness: 200, mass: 0.5);
  static const springGentle = SpringDescription(damping: 0.8, stiffness: 150, mass: 0.5);
  static const springBouncy = SpringDescription(damping: 0.6, stiffness: 250, mass: 0.4);

  // Curves
  static const easeInOutCubic = Cubic(0.65, 0.0, 0.35, 1.0);
  static const easeInOut = Curves.easeInOut;
  static const easeOutCubic = Cubic(0.33, 1.0, 0.68, 1.0);
  static const easeInCubic = Cubic(0.32, 0.0, 0.67, 0.0);
  static const easeOutBack = Cubic(0.34, 1.56, 0.64, 1.0);

  // Legacy
  static const panelOpen = normal;
  static const panelClose = Duration(milliseconds: 200);
  static const clipSelect = fast;
  static const snapGuide = instant;
  static const toolDock = Duration(milliseconds: 200);
  static const toast = Duration(milliseconds: 300);

  // Stagger helpers
  static List<DelayInterval> stagger(int count, {Duration base = Duration.zero, Duration between = const Duration(milliseconds: 50)}) {
    return List.generate(count, (i) => DelayInterval(
      delay: base + between * i,
      duration: normal,
    ));
  }

  // Animation presets
  static Tween<Offset> slideUp = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero);
  static Tween<double> fadeIn = Tween<double>(begin: 0, end: 1);
  static Tween<double> scaleIn = Tween<double>(begin: 0.95, end: 1);
  static Tween<double> scaleInDialog = Tween<double>(begin: 0.8, end: 1);
}

class DelayInterval {
  final Duration delay;
  final Duration duration;
  const DelayInterval({required this.delay, required this.duration});
}

class SpringCurve extends Curve {
  final SpringDescription spring;
  const SpringCurve({SpringDescription? spring}) : spring = spring ?? AppMotion.springSnappy;

  @override
  double transformInternal(double t) {
    if (t >= 1.0) return 1.0;
    const double omega = 2.0 * 3.14159 * 2.0;
    final double damping = spring.damping * omega;
    final double stiffness = spring.stiffness * omega * omega;
    final double mass = spring.mass;
    final double beta = damping / (2 * mass);
    final double omega0Sqrt = (stiffness / mass).clamp(0, double.infinity) - beta * beta;

    if (omega0Sqrt <= 0) {
      return 1.0 - (1.0 + beta * t) * math.exp(-beta * t);
    }
    final double omegaD = math.sqrt(omega0Sqrt);
    final double B = (beta - 0) / omegaD;
    return 1.0 - (math.cos(beta * t) + B * math.sin(beta * t)) * math.exp(-beta * t);
  }
}

class StaggeredAnimation extends StatelessWidget {
  final AnimationController controller;
  final int index;
  final Widget child;
  final Duration between;

  const StaggeredAnimation({
    super.key,
    required this.controller,
    required this.index,
    required this.child,
    this.between = const Duration(milliseconds: 50),
  });

  @override
  Widget build(BuildContext context) {
    final delay = index * between.inMilliseconds;
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final progress = ((controller.value * AppMotion.normal.inMilliseconds) - delay)
            .clamp(0, AppMotion.normal.inMilliseconds) / AppMotion.normal.inMilliseconds;
        return Opacity(
          opacity: progress,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - progress)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class PressAnimation extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double scale;

  const PressAnimation({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.scale = 0.95,
  });

  @override
  State<PressAnimation> createState() => _PressAnimationState();
}

class _PressAnimationState extends State<PressAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: AppMotion.instant);
    _animation = Tween<double>(begin: 1, end: widget.scale).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(_) => _controller.forward();
  void _onTapUp(_) => _controller.reverse();
  void _onTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) => Transform.scale(
          scale: _animation.value,
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}
