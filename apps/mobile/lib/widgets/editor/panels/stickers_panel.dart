import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../services/haptic_service.dart';

class StickersPanel extends StatelessWidget {
  const StickersPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.panelBg,
      child: Column(
        children: [
          _header('Stickers'),
          Expanded(
            child: Column(
              children: [
                Container(
                  height: 32,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TextField(
                    style: const TextStyle(fontSize: 13, color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search stickers...',
                      hintStyle: const TextStyle(color: AppColors.foregroundMuted),
                      prefixIcon: const Icon(Icons.search, size: 16, color: AppColors.foregroundMuted),
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 28,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: ['Trending', 'Emotions', 'Celebrations', 'Reactions', 'Festivals'].map((c) => GestureDetector(
                      onTap: () { HapticService.trigger(HapticLevel.light); },
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                        child: Text(c, style: const TextStyle(fontSize: 11, color: AppColors.foregroundSecondary)),
                      ),
                    )).toList(),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 1,
                    ),
                    itemCount: 24,
                    itemBuilder: (_, i) {
                      final emojis = ['😊', '😂', '❤️', '🔥', '🎉', '💯', '😍', '🤩', '🥳', '✨', '💥', '🎊', '👏', '🙌', '💪', '🤝', '🎵', '📸', '🎬', '🎭', '🌟', '⭐', '🌈', '🎨'];
                      return GestureDetector(
                        onTap: () { HapticService.trigger(HapticLevel.light); },
                        child: Container(
                          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
                          child: Center(child: Text(emojis[i % emojis.length], style: const TextStyle(fontSize: 28))),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(String title) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerLeft,
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
      child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.foreground)),
    );
  }
}
