import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/app_motion.dart';
import '../../../services/haptic_service.dart';

class LyricsPanel extends StatelessWidget {
  final AnimationController staggerController;
  const LyricsPanel({super.key, required this.staggerController});

  static const _fonts = ['Inter', 'Roboto', 'Playfair', 'Montserrat', 'Poppins', 'Oswald', 'Dancing Script', 'Bebas Neue'];
  static const _animStyles = ['Typewriter', 'Fade', 'Bounce', 'Scale'];

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
                _buildSongSearch(),
                const SizedBox(height: 12),
                _buildImportButtons(),
                const SizedBox(height: 16),
                _buildSyllableDisplay(),
                const SizedBox(height: 12),
                _buildLyricEditor(),
                const SizedBox(height: 16),
                _buildTimingMode(),
                const SizedBox(height: 16),
                _buildFontPresets(),
                const SizedBox(height: 12),
                _buildKaraokeColor(),
                const SizedBox(height: 12),
                _buildAnimationStyle(),
                const SizedBox(height: 12),
                _buildToggleRow('Word-by-Word', false),
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
      child: const Text('Lyrics', style: AppTypography.titleSm),
    );
  }

  Widget _buildSongSearch() {
    return Container(
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
              decoration: InputDecoration.collapsed(hintText: 'Search song...', hintStyle: TextStyle(color: AppColors.textLow)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImportButtons() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => HapticService.trigger(HapticLevel.light),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(color: AppColors.bgSurface, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.file_present, size: 14, color: AppColors.textMedium),
                  SizedBox(width: 4),
                  Text('Text File', style: TextStyle(fontSize: 10, color: AppColors.textMedium)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: GestureDetector(
            onTap: () => HapticService.trigger(HapticLevel.light),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(color: AppColors.bgSurface, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.content_paste, size: 14, color: AppColors.textMedium),
                  SizedBox(width: 4),
                  Text('Clipboard', style: TextStyle(fontSize: 10, color: AppColors.textMedium)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
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
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.sync, size: 14, color: AppColors.brand500),
                  SizedBox(width: 4),
                  Text('Auto Sync', style: TextStyle(fontSize: 10, color: AppColors.brand500, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSyllableDisplay() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Detected Syllables: 142', style: TextStyle(fontSize: 11, color: AppColors.textMedium)),
          SizedBox(height: 4),
          LinearProgressIndicator(value: 0.8, backgroundColor: AppColors.timelineGrid, valueColor: AlwaysStoppedAnimation(AppColors.brand500)),
        ],
      ),
    );
  }

  Widget _buildLyricEditor() {
    final lines = ['I remember when we first met', 'The sun was shining bright', 'You smiled and time stood still', 'Everything felt so right'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Lyrics', style: AppTypography.bodySm),
        const SizedBox(height: 6),
        ...lines.map((l) => Container(
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: AppColors.bgSurface, borderRadius: BorderRadius.circular(6), border: Border.all(color: AppColors.border)),
          child: Row(
            children: [
              Text('0:${lines.indexOf(l) * 15 + 10}', style: const TextStyle(fontSize: 10, color: AppColors.textLow, fontFamily: 'JetBrainsMono')),
              const SizedBox(width: 10),
              Expanded(
                child: Text(l, style: const TextStyle(fontSize: 12, color: AppColors.textHigh)),
              ),
              Icon(Icons.edit, size: 12, color: AppColors.textLow),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildTimingMode() {
    return Row(
      children: [
        const Text('Timing Sync', style: AppTypography.bodySm),
        const Spacer(),
        GestureDetector(
          onTap: () => HapticService.trigger(HapticLevel.light),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: AppColors.brand500.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6), border: Border.all(color: AppColors.brand500)),
            child: const Text('Auto', style: TextStyle(fontSize: 10, color: AppColors.brand500)),
          ),
        ),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: () => HapticService.trigger(HapticLevel.light),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: AppColors.bgSurface, borderRadius: BorderRadius.circular(6), border: Border.all(color: AppColors.border)),
            child: const Text('Manual', style: TextStyle(fontSize: 10, color: AppColors.textMedium)),
          ),
        ),
      ],
    );
  }

  Widget _buildFontPresets() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Font Style', style: AppTypography.bodySm),
        const SizedBox(height: 6),
        SizedBox(
          height: 30,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _fonts.length,
            itemBuilder: (_, i) => GestureDetector(
              onTap: () => HapticService.trigger(HapticLevel.light),
              child: Container(
                margin: const EdgeInsets.only(right: 6),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: i == 0 ? AppColors.brand500.withValues(alpha: 0.15) : AppColors.bgSurface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: i == 0 ? AppColors.brand500 : AppColors.border),
                ),
                child: Text(_fonts[i], style: TextStyle(fontSize: 10, color: i == 0 ? AppColors.brand500 : AppColors.textMedium)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKaraokeColor() {
    return Row(
      children: [
        const Text('Karaoke Highlight', style: TextStyle(fontSize: 12, color: AppColors.textMedium)),
        const Spacer(),
        Container(
          width: 24, height: 24,
          decoration: BoxDecoration(color: AppColors.brand500, borderRadius: BorderRadius.circular(6), border: Border.all(color: AppColors.borderLight)),
        ),
      ],
    );
  }

  Widget _buildAnimationStyle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Animation Style', style: AppTypography.bodySm),
        const SizedBox(height: 6),
        Row(
          children: _animStyles.map((a) => Expanded(
            child: GestureDetector(
              onTap: () => HapticService.trigger(HapticLevel.light),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: a == 'Fade' ? AppColors.brand500.withValues(alpha: 0.15) : AppColors.bgSurface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: a == 'Fade' ? AppColors.brand500 : AppColors.border),
                ),
                child: Center(child: Text(a, style: TextStyle(fontSize: 11, color: a == 'Fade' ? AppColors.brand500 : AppColors.textMedium))),
              ),
            ),
          )).toList(),
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
