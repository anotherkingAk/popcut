import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../services/haptic_service.dart';

class ReversePanel extends StatelessWidget {
  final AnimationController staggerController;
  const ReversePanel({super.key, required this.staggerController});

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
                const SizedBox(height: 20),
                _buildApplyButton(),
                const SizedBox(height: 16),
                _buildToggleRow('Keep Original', true),
                const SizedBox(height: 12),
                _buildToggleRow('Reverse Audio with Video', true),
                const SizedBox(height: 16),
                _buildDurationInfo(),
                const SizedBox(height: 16),
                _buildUndoButton(),
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
          Text('Reverse', style: AppTypography.titleSm),
          Spacer(),
          Text('0:00 - 2:30', style: TextStyle(fontSize: 11, color: AppColors.textLow)),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: CustomPaint(
        painter: _MirrorWavePainter(),
        size: const Size(double.infinity, 80),
      ),
    );
  }

  Widget _buildApplyButton() {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: () => HapticService.trigger(HapticLevel.light),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [AppColors.brand500, AppColors.brand600]),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.swap_horiz, size: 20, color: Colors.white),
              SizedBox(width: 8),
              Text('Apply Reverse', style: TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDurationInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Original', style: TextStyle(fontSize: 10, color: AppColors.textLow)),
              Text('2:30', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textHigh)),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Icon(Icons.arrow_forward, size: 18, color: AppColors.brand500),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Reversed', style: TextStyle(fontSize: 10, color: AppColors.textLow)),
              Text('2:30', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textHigh)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUndoButton() {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: () => HapticService.trigger(HapticLevel.light),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.undo, size: 14, color: AppColors.textMedium),
              SizedBox(width: 6),
              Text('Undo Reverse', style: TextStyle(fontSize: 12, color: AppColors.textMedium)),
            ],
          ),
        ),
      ),
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

class _MirrorWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.brand500.withValues(alpha: 0.3)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final centerX = size.width / 2;
    for (int i = 0; i < 30; i++) {
      final h = 8 + (i % 7) * 6.0;
      final x = centerX + i * 6.0;
      final xMirror = centerX - i * 6.0;
      if (x < size.width) {
        canvas.drawLine(Offset(x, size.height / 2 - h / 2), Offset(x, size.height / 2 + h / 2), paint);
      }
      if (xMirror > 0) {
        paint.color = AppColors.brand500.withValues(alpha: 0.15);
        canvas.drawLine(Offset(xMirror, size.height / 2 - h / 2), Offset(xMirror, size.height / 2 + h / 2), paint);
        paint.color = AppColors.brand500.withValues(alpha: 0.3);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
