import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../services/haptic_service.dart';

class AiBackgroundRemoval extends StatelessWidget {
  final AnimationController staggerController;
  const AiBackgroundRemoval({super.key, required this.staggerController});

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
                _buildBeforeAfterPreview(),
                const SizedBox(height: 16),
                _buildModeChips(),
                const SizedBox(height: 16),
                _buildLabeledSlider('Refine Edge', 50, 0, 100),
                const SizedBox(height: 16),
                _buildOutputOptions(),
                const SizedBox(height: 16),
                _buildToggleRow('Feather Edge', false),
                const SizedBox(height: 8),
                _buildLabeledSlider('Feather Amount', 5, 0, 20),
                const SizedBox(height: 16),
                _buildApplyButton(),
                const SizedBox(height: 12),
                _buildProcessingSteps(),
                const SizedBox(height: 12),
                _buildUpsellCard(),
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
          Text('AI Background Removal', style: AppTypography.titleSm),
          SizedBox(width: 8),
          _ProBadge(),
        ],
      ),
    );
  }

  Widget _buildBeforeAfterPreview() {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(7), bottomLeft: Radius.circular(7)),
                color: Color(0xFF003300),
              ),
              child: const Center(
                child: Text('Original', style: TextStyle(fontSize: 11, color: AppColors.textLow)),
              ),
            ),
          ),
          Container(width: 1, color: AppColors.border),
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(topRight: Radius.circular(7), bottomRight: Radius.circular(7)),
              child: CustomPaint(
                painter: _CheckerboardPainter(),
                child: const Center(
                  child: Text('Removed', style: TextStyle(fontSize: 11, color: AppColors.textLow)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeChips() {
    final modes = ['Person', 'Object', 'Custom'];
    return Row(
      children: modes.map((m) => Expanded(
        child: GestureDetector(
          onTap: () => HapticService.trigger(HapticLevel.light),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: m == 'Person' ? AppColors.brand500.withValues(alpha: 0.15) : AppColors.bgSurface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: m == 'Person' ? AppColors.brand500 : AppColors.border),
            ),
            child: Text(m, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: m == 'Person' ? AppColors.brand500 : AppColors.textMedium), textAlign: TextAlign.center),
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildOutputOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Output', style: AppTypography.bodySm),
        const SizedBox(height: 8),
        _buildToggleRow('Transparent', true),
        const SizedBox(height: 8),
        const Text('Solid Color', style: AppTypography.bodySm),
        const SizedBox(height: 6),
        _buildColorRow(),
        const SizedBox(height: 8),
        _buildLabeledSlider('Blur Background', 0, 0, 50),
        const SizedBox(height: 8),
        GestureDetector(
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
                Icon(Icons.image, size: 14, color: AppColors.textMedium),
                SizedBox(width: 6),
                Text('Replace Background', style: TextStyle(fontSize: 11, color: AppColors.textMedium)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildColorRow() {
    final colors = [
      AppColors.textHigh, AppColors.textMedium, AppColors.textLow, AppColors.textDisabled,
      AppColors.brand500, AppColors.warning, AppColors.error, AppColors.success,
    ];
    return Row(
      children: colors.map((c) => Expanded(
        child: GestureDetector(
          onTap: () => HapticService.trigger(HapticLevel.light),
          child: Container(
            height: 28,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: c,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.borderLight),
            ),
          ),
        ),
      )).toList(),
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
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 14, height: 14,
              child: CircularProgressIndicator(strokeWidth: 1.5, color: Colors.black),
            ),
            SizedBox(width: 8),
            Text('Analyzing frame...', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black)),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessingSteps() {
    final steps = ['Detecting subject...', 'Refining edges...', 'Applying mask...', 'Done'];
    return Column(
      children: steps.asMap().entries.map((e) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            Icon(
              e.value == 'Done' ? Icons.check_circle : Icons.circle_outlined,
              size: 12,
              color: e.value == 'Done' ? AppColors.success : AppColors.textLow,
            ),
            const SizedBox(width: 8),
            Text(e.value, style: TextStyle(fontSize: 11, color: e.value == 'Done' ? AppColors.textHigh : AppColors.textMedium)),
            if (e.value != 'Done')
              const Spacer(),
            if (e.value != 'Done')
              const SizedBox(
                width: 10, height: 10,
                child: CircularProgressIndicator(strokeWidth: 1.5, color: AppColors.textLow),
              ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildUpsellCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.stars, size: 16, color: AppColors.warning),
          const SizedBox(width: 8),
          const Expanded(child: Text('Upgrade to Pro for AI Background Removal', style: TextStyle(fontSize: 11, color: AppColors.textMedium))),
          GestureDetector(
            onTap: () => HapticService.trigger(HapticLevel.light),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.warning,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('Upgrade', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.black)),
            ),
          ),
        ],
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

class _ProBadge extends StatelessWidget {
  const _ProBadge();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(3),
      ),
      child: const Text('PRO', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.warning)),
    );
  }
}

class _CheckerboardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const tileSize = 12.0;
    final lightPaint = Paint()..color = const Color(0xFFCCCCCC);
    final darkPaint = Paint()..color = const Color(0xFF999999);
    for (double y = 0; y < size.height; y += tileSize) {
      for (double x = 0; x < size.width; x += tileSize) {
        final isOdd = ((x / tileSize).floor() + (y / tileSize).floor()) % 2 == 0;
        canvas.drawRect(Rect.fromLTWH(x, y, tileSize, tileSize), isOdd ? lightPaint : darkPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
