import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../services/haptic_service.dart';

class AudioPanel extends StatelessWidget {
  final AnimationController staggerController;
  const AudioPanel({super.key, required this.staggerController});

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
              padding: EdgeInsets.zero,
              children: [
                _buildSearchBar(),
                _buildCategoryTabs(),
                ...List.generate(8, (i) => _AudioItem(
                  name: ['Cinematic Drum', 'Lo-Fi Beat', 'Ambient Pad', 'Bass Drop', 'Synth Wave', 'Acoustic Guitar', 'Piano Melody', 'Orchestral Hit'][i],
                  duration: ['0:30', '1:15', '2:00', '0:45', '1:30', '0:50', '1:00', '0:25'][i],
                  isFavorite: i < 2,
                )),
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
      child: Row(
        children: [
          const Text('Audio', style: AppTypography.titleSm),
          const Spacer(),
          _ActionChip(Icons.folder_open, 'Import'),
          const SizedBox(width: 8),
          _ActionChip(Icons.mic, 'Record'),
          const SizedBox(width: 8),
          _ActionChip(Icons.music_note, 'Extract'),
        ],
      ),
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
        child: Row(
          children: [
            const Icon(Icons.search, size: 16, color: AppColors.textLow),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                style: const TextStyle(fontSize: 13, color: AppColors.textHigh),
                decoration: const InputDecoration.collapsed(
                  hintText: 'Search music...',
                  hintStyle: TextStyle(color: AppColors.textLow),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    final categories = ['Featured', 'Music', 'SFX', 'Voiceover'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: categories.map((c) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.brand500.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(c, style: const TextStyle(fontSize: 11, color: AppColors.brand500, fontWeight: FontWeight.w500)),
          ),
        )).toList(),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _ActionChip(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () { HapticService.trigger(HapticLevel.light); },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: AppColors.textMedium),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMedium)),
          ],
        ),
      ),
    );
  }
}

class _AudioItem extends StatelessWidget {
  final String name;
  final String duration;
  final bool isFavorite;
  const _AudioItem({required this.name, required this.duration, required this.isFavorite});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5))),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: AppColors.trackAudio.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
            child: Icon(Icons.music_note, size: 18, color: AppColors.trackAudio),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textHigh)),
                Text(duration, style: const TextStyle(fontSize: 11, color: AppColors.textLow)),
              ],
            ),
          ),
          IconButton(
            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, size: 16),
            color: isFavorite ? AppColors.error : AppColors.textLow,
            onPressed: () { HapticService.trigger(HapticLevel.light); },
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.brand500.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text('Add', style: TextStyle(fontSize: 11, color: AppColors.brand500, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
