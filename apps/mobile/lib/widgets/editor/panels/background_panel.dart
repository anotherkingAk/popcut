import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../services/haptic_service.dart';

class BackgroundPanel extends StatelessWidget {
  final AnimationController staggerController;
  const BackgroundPanel({super.key, required this.staggerController});

  static const _tabs = ['Blur', 'Solid Color', 'Gradient', 'Image', 'Pattern'];

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
                _buildTabRow(),
                const SizedBox(height: 16),
                _buildLabeledSlider('Blur Amount', 25, 0, 50),
                const SizedBox(height: 16),
                _buildColorPicker(),
                const SizedBox(height: 16),
                _buildGradientControls(),
                const SizedBox(height: 16),
                _buildImagePickerButton(),
                const SizedBox(height: 16),
                _buildPatternGrid(),
                const SizedBox(height: 16),
                _buildToggleRow('Apply to All Clips', false),
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
      child: const Text('Background', style: AppTypography.titleSm),
    );
  }

  Widget _buildTabRow() {
    return SizedBox(
      height: 30,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
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

  Widget _buildColorPicker() {
    final colors = [
      Colors.black, Colors.white, Colors.grey, AppColors.brand500,
      AppColors.error, AppColors.success, AppColors.info, AppColors.warning,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Color', style: AppTypography.bodySm),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: colors.map((c) => GestureDetector(
            onTap: () => HapticService.trigger(HapticLevel.light),
            child: Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: c,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: c == Colors.black ? AppColors.borderLight : AppColors.border),
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildGradientControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Gradient', style: AppTypography.bodySm),
        const SizedBox(height: 8),
        _buildRow('Direction', 'Diagonal'),
        _buildRow('Color 1', '#6C5CE7'),
        _buildRow('Color 2', '#2ECC71'),
      ],
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMedium)),
          const Spacer(),
          GestureDetector(
            onTap: () => HapticService.trigger(HapticLevel.light),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: AppColors.bgSurface, borderRadius: BorderRadius.circular(6), border: Border.all(color: AppColors.border)),
              child: Text(value, style: const TextStyle(fontSize: 11, color: AppColors.textHigh)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePickerButton() {
    return GestureDetector(
      onTap: () => HapticService.trigger(HapticLevel.light),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 40),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border, style: BorderStyle.solid),
        ),
        child: const Column(
          children: [
            Icon(Icons.image, size: 32, color: AppColors.textLow),
            SizedBox(height: 8),
            Text('Tap to pick image', style: TextStyle(fontSize: 12, color: AppColors.textLow)),
          ],
        ),
      ),
    );
  }

  Widget _buildPatternGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Patterns', style: AppTypography.bodySm),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 1),
          itemCount: 12,
          itemBuilder: (_, i) => GestureDetector(
            onTap: () => HapticService.trigger(HapticLevel.light),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: i == 0 ? AppColors.brand500 : AppColors.border),
              ),
              child: Center(
                child: Icon(Icons.grid_on, size: 24, color: i == 0 ? AppColors.brand500 : AppColors.textLow),
              ),
            ),
          ),
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
}
