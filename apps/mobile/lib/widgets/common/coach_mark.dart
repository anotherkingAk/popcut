import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_motion.dart';
import '../../services/haptic_service.dart';

class CoachMarkStep {
  final String title;
  final String description;
  final Rect? spotlight;
  final String? pointerLabel;

  CoachMarkStep({
    required this.title,
    required this.description,
    this.spotlight,
    this.pointerLabel,
  });
}

class CoachMarkOverlay extends StatefulWidget {
  final List<CoachMarkStep> steps;
  final VoidCallback onComplete;

  const CoachMarkOverlay({
    super.key,
    required this.steps,
    required this.onComplete,
  });

  static Future<void> show(BuildContext context, List<CoachMarkStep> steps) async {
    HapticService.trigger(HapticLevel.medium);
    await showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (_) => CoachMarkOverlay(steps: steps, onComplete: () => Navigator.pop(context)),
    );
  }

  @override
  State<CoachMarkOverlay> createState() => _CoachMarkOverlayState();
}

class _CoachMarkOverlayState extends State<CoachMarkOverlay> with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: AppMotion.normal);
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _next() {
    HapticService.trigger(HapticLevel.light);
    if (_currentStep < widget.steps.length - 1) {
      _animController.reverse().then((_) {
        setState(() => _currentStep++);
        _animController.forward();
      });
    } else {
      HapticService.trigger(HapticLevel.medium);
      widget.onComplete();
    }
  }

  void _skip() {
    HapticService.trigger(HapticLevel.light);
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.steps[_currentStep];
    final size = MediaQuery.of(context).size;

    return FadeTransition(
      opacity: _fadeAnim,
      child: Stack(
        children: [
          if (step.spotlight != null)
            ClipPath(
              clipper: _SpotlightClipper(spotlight: step.spotlight!, size: size),
              child: Container(color: Colors.black.withValues(alpha: 0.7)),
            )
          else
            Container(color: Colors.black.withValues(alpha: 0.7)),
          Positioned(
            bottom: 80,
            left: 24,
            right: 24,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: AppMotion.normal,
              builder: (context, value, child) => Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: child,
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.bgSurface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppElevation.elevatedShadow,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(step.title, style: AppTypography.titleMd),
                    const SizedBox(height: 8),
                    Text(step.description, style: AppTypography.bodyMd),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Row(
                          children: List.generate(widget.steps.length, (i) => Container(
                            width: i == _currentStep ? 20 : 6,
                            height: 6,
                            margin: const EdgeInsets.only(right: 4),
                            decoration: BoxDecoration(
                              color: i == _currentStep ? AppColors.brand500 : AppColors.textLow,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          )),
                        ),
                        const Spacer(),
                        TextButton(onPressed: _skip, child: const Text('Skip', style: TextStyle(color: AppColors.textMedium))),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _next,
                          child: Text(_currentStep < widget.steps.length - 1 ? 'Next' : 'Got It'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpotlightClipper extends CustomClipper<Path> {
  final Rect spotlight;
  final Size size;

  _SpotlightClipper({required this.spotlight, required this.size});

  @override
  Path getClip(Size _) {
    final path = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    path.addOval(RRect.fromRectAndRadius(spotlight, const Radius.circular(12)).outerRect);
    path.fillType = PathFillType.evenOdd;
    return path;
  }

  @override
  bool shouldReclip(covariant _SpotlightClipper old) => old.spotlight != spotlight;
}
