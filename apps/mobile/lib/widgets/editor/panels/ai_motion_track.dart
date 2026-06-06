import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../services/haptic_service.dart';

class AiMotionTrack extends StatelessWidget {
  final AnimationController staggerController;
  const AiMotionTrack({super.key, required this.staggerController});

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
                _buildPreview(),
                const SizedBox(height: 12),
                _buildTrackTarget(),
                const SizedBox(height: 12),
                _buildAutoTrackButton(),
                const SizedBox(height: 8),
                _buildTrackingProgress(),
                const SizedBox(height: 16),
                _buildAttachSelector(),
                const SizedBox(height: 16),
                _buildLabeledSlider('Track Smoothing', 60, 0, 100),
                const SizedBox(height: 12),
                _buildPositionOffset(),
                const SizedBox(height: 12),
                _buildToggleRow('Scale with Motion', true),
                const SizedBox(height: 8),
                _buildToggleRow('Rotation with Motion', false),
                const SizedBox(height: 16),
                _buildKeyframeDisplay(),
                const SizedBox(height: 16),
                _buildApplyButton(),
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
      child: const Text('Motion Tracking', style: AppTypography.titleSm),
    );
  }

  Widget _buildPreview() {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: CustomPaint(
          painter: _CrosshairPainter(),
          child: const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.touch_app, size: 28, color: AppColors.textDisabled),
                SizedBox(height: 6),
                Text('Tap to select tracking target', style: TextStyle(fontSize: 11, color: AppColors.textLow)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrackTarget() {
    return GestureDetector(
      onTap: () => HapticService.trigger(HapticLevel.light),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.brand500),
        ),
        child: const Row(
          children: [
            Icon(Icons.my_location, size: 14, color: Color(0xFFFFDD00)),
            SizedBox(width: 8),
            Text('Select object to track', style: TextStyle(fontSize: 11, color: AppColors.textHigh)),
            Spacer(),
            Icon(Icons.check_circle, size: 14, color: AppColors.success),
          ],
        ),
      ),
    );
  }

  Widget _buildAutoTrackButton() {
    return GestureDetector(
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
            Icon(Icons.track_changes, size: 14, color: AppColors.brand500),
            SizedBox(width: 6),
            Text('Track Motion', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.brand500)),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingProgress() {
    final steps = ['Analyzing...', 'Tracking...', 'Done'];
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: const LinearProgressIndicator(
              value: 0.5,
              minHeight: 3,
              backgroundColor: AppColors.muted,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.brand500),
            ),
          ),
          const SizedBox(height: 8),
          ...steps.asMap().entries.map((e) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 1),
            child: Row(
              children: [
                Icon(e.key == 2 ? Icons.check_circle : (e.key == 0 ? Icons.check_circle : Icons.circle_outlined), size: 10, color: e.key <= 0 ? AppColors.success : AppColors.textLow),
                const SizedBox(width: 4),
                Text(e.value, style: TextStyle(fontSize: 9, color: e.key <= 0 ? AppColors.textHigh : AppColors.textMedium)),
                if (e.key == 1)
                  const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: SizedBox(width: 8, height: 8, child: CircularProgressIndicator(strokeWidth: 1.2, color: AppColors.textLow)),
                  ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildAttachSelector() {
    final items = ['Text', 'Emoji', 'Sticker', 'Effect', 'Blur'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Attach Element', style: AppTypography.bodySm),
        const SizedBox(height: 8),
        Row(
          children: items.map((item) => Expanded(
            child: GestureDetector(
              onTap: () => HapticService.trigger(HapticLevel.light),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: item == 'Text' ? AppColors.brand500.withValues(alpha: 0.15) : AppColors.bgSurface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: item == 'Text' ? AppColors.brand500 : AppColors.border),
                ),
                child: Text(item, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w500, color: item == 'Text' ? AppColors.brand500 : AppColors.textMedium), textAlign: TextAlign.center),
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildPositionOffset() {
    return Row(
      children: [
        Expanded(child: _buildLabeledSlider('Offset X', 0, -100, 100)),
        const SizedBox(width: 12),
        Expanded(child: _buildLabeledSlider('Offset Y', 0, -100, 100)),
      ],
    );
  }

  Widget _buildKeyframeDisplay() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.15)),
      ),
      child: const Row(
        children: [
          Icon(Icons.key, size: 14, color: AppColors.success),
          SizedBox(width: 6),
          Text('48 keyframes generated', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textHigh)),
        ],
      ),
    );
  }

  Widget _buildApplyButton() {
    return GestureDetector(
      onTap: () => HapticService.trigger(HapticLevel.light),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.brand500,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text('Apply', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black)),
        ),
      ),
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

  Widget _buildToggleRow(String label, bool value) {
    return Row(
      children: [
        Text(label, style: AppTypography.bodySm),
        const Spacer(),
        Switch(value: value, onChanged: (_) => HapticService.trigger(HapticLevel.light)),
      ],
    );
  }
}

class _CrosshairPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = AppColors.textDisabled.withValues(alpha: 0.5)
      ..strokeWidth = 0.5;
    canvas.drawLine(Offset(center.dx, 0), Offset(center.dx, size.height), paint);
    canvas.drawLine(Offset(0, center.dy), Offset(size.width, center.dy), paint);

    final circlePaint = Paint()
      ..color = AppColors.textDisabled.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    canvas.drawCircle(center, 24, circlePaint);
    canvas.drawCircle(center, 48, circlePaint);

    final dotPaint = Paint()..color = const Color(0xFFFFDD00);
    canvas.drawCircle(center, 3, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
