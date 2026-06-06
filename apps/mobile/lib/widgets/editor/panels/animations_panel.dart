import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/app_motion.dart';
import '../../../services/haptic_service.dart';

class AnimationsPanel extends StatelessWidget {
  final AnimationController staggerController;
  const AnimationsPanel({super.key, required this.staggerController});

  static const _categories = ['In', 'Out', 'Loop', 'Emphasis'];
  static const _animations = ['Fade', 'Slide', 'Bounce', 'Scale', 'Rotate', 'Flip', 'Blur In', 'Wipe', 'Reveal', '3D Spin', 'Shake', 'Pulse', 'Glow', 'Swing', 'Jello', 'Flash', 'Roll', 'Zoom', 'Sink', 'Rise'];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgElevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          Expanded(
            child: Column(
              children: [
                _buildCategoryTabs(),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(12),
                    children: [
                      _buildAnimationGrid(),
                      const SizedBox(height: 16),
                      _buildLabeledSlider('Duration', 0.5, 0.1, 3.0),
                      _buildLabeledSlider('Delay', 0, 0, 5),
                      const SizedBox(height: 12),
                      _buildEasingSelector(),
                      const SizedBox(height: 16),
                      _buildActionButtons(),
                    ],
                  ),
                ),
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
      child: const Text('Animations', style: AppTypography.titleSm),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      height: 32,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        itemCount: _categories.length,
        itemBuilder: (_, i) => GestureDetector(
          onTap: () => HapticService.trigger(HapticLevel.light),
          child: Container(
            margin: const EdgeInsets.only(right: 6),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: i == 0 ? AppColors.brand500.withValues(alpha: 0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: i == 0 ? AppColors.brand500 : AppColors.border),
            ),
            child: Text(_categories[i], style: TextStyle(fontSize: 11, color: i == 0 ? AppColors.brand500 : AppColors.textLow, fontWeight: FontWeight.w500)),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimationGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.9,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _animations.length,
      itemBuilder: (_, i) => GestureDetector(
        onTap: () => HapticService.trigger(HapticLevel.light),
        child: Container(
          decoration: BoxDecoration(
            color: i == 0 ? AppColors.brand500.withValues(alpha: 0.15) : AppColors.bgSurface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: i == 0 ? AppColors.brand500 : AppColors.border),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.animation, size: 20, color: i == 0 ? AppColors.brand500 : AppColors.textMedium),
              const SizedBox(height: 4),
              Text(_animations[i], style: TextStyle(fontSize: 8, color: i == 0 ? AppColors.brand500 : AppColors.textLow)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEasingSelector() {
    final easings = ['Linear', 'Ease In', 'Ease Out', 'Ease In-Out', 'Bounce'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Easing Curve', style: AppTypography.bodySm),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: easings.map((e) => GestureDetector(
            onTap: () => HapticService.trigger(HapticLevel.light),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: e == 'Ease In-Out' ? AppColors.brand500.withValues(alpha: 0.15) : AppColors.bgSurface,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: e == 'Ease In-Out' ? AppColors.brand500 : AppColors.border),
              ),
              child: Text(e, style: TextStyle(fontSize: 10, color: e == 'Ease In-Out' ? AppColors.brand500 : AppColors.textMedium)),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
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
              child: const Center(child: Text('Apply to All', style: TextStyle(fontSize: 11, color: AppColors.brand500, fontWeight: FontWeight.w600))),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: () => HapticService.trigger(HapticLevel.light),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
              ),
              child: const Center(child: Text('Remove All', style: TextStyle(fontSize: 11, color: AppColors.error, fontWeight: FontWeight.w600))),
            ),
          ),
        ),
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
            Text('${value.toStringAsFixed(1)}s', style: const TextStyle(fontSize: 12, color: AppColors.textHigh)),
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
