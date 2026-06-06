import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../services/haptic_service.dart';

class ColorGradingPanel extends StatelessWidget {
  final AnimationController staggerController;
  const ColorGradingPanel({super.key, required this.staggerController});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.panelBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
            ),
            child: Row(
              children: [
                const Text('Color Grade', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.foreground)),
                const Spacer(),
                _staggeredItem(
                  index: 0,
                  child: GestureDetector(
                    onTap: () { HapticService.trigger(HapticLevel.light); },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.compare, size: 12, color: AppColors.primary),
                          SizedBox(width: 4),
                          Text('Before/After', style: TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildStaggeredSection('Wheels', [
                  _buildColorWheel('Shadows'),
                  _buildColorWheel('Midtones'),
                  _buildColorWheel('Highlights'),
                ]),
                _buildStaggeredSection('Curves', [
                  _buildCurveEditor(),
                ]),
                _buildStaggeredSection('Adjust', [
                  _buildSlider('Exposure', 0.0),
                  _buildSlider('Contrast', 0.0),
                  _buildSlider('Highlights', 0.0),
                  _buildSlider('Shadows', 0.0),
                  _buildSlider('Saturation', 0.0),
                  _buildSlider('Vibrance', 0.0),
                  _buildSlider('Temp', 0.0),
                  _buildSlider('Tint', 0.0),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaggeredSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5))),
          child: Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.foregroundSecondary, letterSpacing: 0.5)),
        ),
        ...children,
      ],
    );
  }

  Widget _buildColorWheel(String label) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5))),
      child: Row(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.borderLight),
              gradient: const RadialGradient(
                center: Alignment.center,
                radius: 0.5,
                colors: [Colors.white, AppColors.textDisabled, AppColors.bgSurface, Colors.black],
                stops: [0.0, 0.3, 0.7, 1.0],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.foregroundSecondary)),
          const Spacer(),
          const Text('0%', style: TextStyle(fontSize: 11, color: AppColors.foregroundMuted)),
        ],
      ),
    );
  }

  Widget _buildCurveEditor() {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5))),
      child: CustomPaint(
        painter: _CurvePainter(),
        size: const Size(double.infinity, 96),
      ),
    );
  }

  Widget _buildSlider(String label, double value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: AppColors.foregroundSecondary)),
              const Spacer(),
              Text(value.toStringAsFixed(1), style: const TextStyle(fontSize: 11, color: AppColors.foreground)),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 2.5,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.muted,
              thumbColor: AppColors.primary,
            ),
            child: Slider(value: value, min: -100, max: 100, onChanged: (_) { HapticService.trigger(HapticLevel.light); }),
          ),
        ],
      ),
    );
  }

  Widget _staggeredItem({required int index, required Widget child}) {
    return AnimatedBuilder(
      animation: staggerController,
      builder: (context, _) {
        final delay = index * 20;
        final progress = ((staggerController.value * 250) - delay).clamp(0, 250) / 250;
        return Opacity(
          opacity: progress,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - progress)),
            child: child,
          ),
        );
      },
    );
  }
}

class _CurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()..color = AppColors.border.withValues(alpha: 0.3)..strokeWidth = 0.5;
    for (double i = 0; i <= 1; i += 0.25) {
      canvas.drawLine(Offset(i * size.width, 0), Offset(i * size.width, size.height), gridPaint);
      canvas.drawLine(Offset(0, i * size.height), Offset(size.width, i * size.height), gridPaint);
    }

    final curvePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, size.height);
    path.cubicTo(size.width * 0.25, size.height * 0.75, size.width * 0.5, size.height * 0.5, size.width, 0);
    canvas.drawPath(path, curvePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
