import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/app_motion.dart';
import '../../../services/haptic_service.dart';

class StickersGrid extends StatelessWidget {
  final AnimationController staggerController;
  const StickersGrid({super.key, required this.staggerController});

  static const _categories = ['Emoji', 'Animals', 'Food', 'Nature', 'Text', 'Celebration', 'Arrows', 'Shapes'];

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
                _buildSearchBar(),
                _buildCategoryChips(),
                Expanded(child: _buildStickerGrid()),
                _buildBottomControls(),
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
      child: const Text('Stickers', style: AppTypography.titleSm),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: const Row(
          children: [
            Icon(Icons.search, size: 16, color: AppColors.textLow),
            SizedBox(width: 8),
            Expanded(
              child: TextField(
                style: TextStyle(fontSize: 13, color: AppColors.textHigh),
                decoration: InputDecoration.collapsed(hintText: 'Search stickers...', hintStyle: TextStyle(color: AppColors.textLow)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 32,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _categories.length,
        itemBuilder: (_, i) => GestureDetector(
          onTap: () => HapticService.trigger(HapticLevel.light),
          child: Container(
            margin: const EdgeInsets.only(right: 6),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: i == 0 ? AppColors.brand500.withValues(alpha: 0.1) : AppColors.bgSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: i == 0 ? AppColors.brand500 : AppColors.border),
            ),
            child: Text(_categories[i], style: TextStyle(fontSize: 11, color: i == 0 ? AppColors.brand500 : AppColors.textMedium)),
          ),
        ),
      ),
    );
  }

  Widget _buildStickerGrid() {
    final stickers = ['😊', '😂', '❤️', '🔥', '🎉', '💯', '😍', '🤩', '🥳', '✨', '💥', '🎊', '👏', '🙌', '💪', '🤝', '🎵', '📸', '🎬', '🎭', '🌟', '⭐', '🌈', '🎨'];
    final names = ['Smile', 'LOL', 'Heart', 'Fire', 'Party', '100', 'Eyes', 'Starstruck', 'Party', 'Sparkle', 'Boom', 'Confetti', 'Clap', 'Yay', 'Muscle', 'Handshake', 'Music', 'Camera', 'Action', 'Drama', 'Star', 'Glow', 'Rainbow', 'Art'];
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemCount: stickers.length,
      itemBuilder: (_, i) => GestureDetector(
        onTap: () => HapticService.trigger(HapticLevel.light),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(stickers[i], style: const TextStyle(fontSize: 28)),
              const SizedBox(height: 4),
              Text(names[i], style: const TextStyle(fontSize: 8, color: AppColors.textLow)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.border))),
      child: Column(
        children: [
          Row(
            children: [
              const Text('Size', style: TextStyle(fontSize: 11, color: AppColors.textMedium)),
              const Spacer(),
              const Text('100%', style: TextStyle(fontSize: 11, color: AppColors.textHigh)),
            ],
          ),
          SliderTheme(
            data: const SliderThemeData(
              trackHeight: 2, activeTrackColor: AppColors.brand500, inactiveTrackColor: AppColors.timelineGrid, thumbColor: AppColors.brand500,
            ),
            child: const Slider(value: 100, min: 10, max: 200, onChanged: null),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () => HapticService.trigger(HapticLevel.light),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: AppColors.bgSurface, borderRadius: BorderRadius.circular(6), border: Border.all(color: AppColors.border)),
                  child: const Row(
                    children: [
                      Icon(Icons.drag_indicator, size: 12, color: AppColors.textMedium),
                      SizedBox(width: 4),
                      Text('Drag to reposition', style: TextStyle(fontSize: 10, color: AppColors.textMedium)),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => HapticService.trigger(HapticLevel.light),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: AppColors.bgSurface, borderRadius: BorderRadius.circular(6), border: Border.all(color: AppColors.border)),
                  child: const Text('Reset Position', style: TextStyle(fontSize: 10, color: AppColors.textMedium)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
