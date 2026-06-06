import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../services/haptic_service.dart';

class OverlaysPanel extends StatelessWidget {
  final AnimationController staggerController;
  const OverlaysPanel({super.key, required this.staggerController});

  static const _tabs = ['Light Leaks', 'Bokeh', 'Gradients', 'Lens Flare', 'Film Grain', 'Light Rays', 'Dust', 'Rain'];
  static const _blendModes = ['Screen', 'Overlay', 'Soft Light', 'Hard Light', 'Add', 'Multiply'];

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
                _buildTabRow(),
                Expanded(child: _buildOverlayGrid()),
                _buildControls(),
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
      child: const Text('Overlays', style: AppTypography.titleSm),
    );
  }

  Widget _buildTabRow() {
    return Container(
      height: 34,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        itemCount: _tabs.length,
        itemBuilder: (_, i) => GestureDetector(
          onTap: () => HapticService.trigger(HapticLevel.light),
          child: Container(
            margin: const EdgeInsets.only(right: 6),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: i == 0 ? AppColors.brand500.withValues(alpha: 0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: i == 0 ? AppColors.brand500 : AppColors.border),
            ),
            child: Text(_tabs[i], style: TextStyle(fontSize: 10, color: i == 0 ? AppColors.brand500 : AppColors.textLow, fontWeight: FontWeight.w500)),
          ),
        ),
      ),
    );
  }

  Widget _buildOverlayGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.8,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 12,
      itemBuilder: (_, i) => GestureDetector(
        onTap: () => HapticService.trigger(HapticLevel.light),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: i == 0 ? AppColors.brand500 : AppColors.border),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: AppColors.bgElevated,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.auto_awesome, size: 20, color: i == 0 ? AppColors.brand500 : AppColors.textMedium),
              ),
              const SizedBox(height: 6),
              Text('Overlay ${i + 1}', style: TextStyle(fontSize: 9, color: i == 0 ? AppColors.brand500 : AppColors.textLow)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.border))),
      child: Column(
        children: [
          _buildSelector('Blend Mode', _blendModes[0], _blendModes),
          const SizedBox(height: 10),
          _buildSliderControl('Opacity', 80, 0, 100),
          _buildSliderControl('Rotate', 0, 0, 360),
          _buildSliderControl('Size', 100, 10, 200),
        ],
      ),
    );
  }

  Widget _buildSelector(String label, String current, List<String> items) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMedium)),
        const Spacer(),
        GestureDetector(
          onTap: () => HapticService.trigger(HapticLevel.light),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: AppColors.bgSurface, borderRadius: BorderRadius.circular(6), border: Border.all(color: AppColors.border)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(current, style: const TextStyle(fontSize: 11, color: AppColors.textHigh)),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_drop_down, size: 14, color: AppColors.textLow),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSliderControl(String label, double value, double min, double max) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMedium)),
            const Spacer(),
            Text('${value.toInt()}', style: const TextStyle(fontSize: 11, color: AppColors.textHigh)),
          ],
        ),
        SliderTheme(
          data: const SliderThemeData(
            trackHeight: 2, activeTrackColor: AppColors.brand500, inactiveTrackColor: AppColors.timelineGrid, thumbColor: AppColors.brand500,
          ),
          child: Slider(value: value, min: min, max: max, onChanged: (_) => HapticService.trigger(HapticLevel.light)),
        ),
      ],
    );
  }
}
