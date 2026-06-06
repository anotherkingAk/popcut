import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_motion.dart';
import '../../services/haptic_service.dart';
import '../../widgets/common/app_bottom_sheet.dart';

class AudioPickerSheet extends StatelessWidget {
  const AudioPickerSheet({super.key});

  static const _tabs = ['Music Library', 'Files', 'Recorded', 'Favorites'];

  static void show(BuildContext context) {
    AppBottomSheet.show(
      context: context,
      title: 'Select Audio',
      icon: Icons.music_note_outlined,
      body: const AudioPickerSheet(),
      maxHeightFactor: 0.95,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.bgElevated,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: const TextField(
              style: AppTypography.bodyMd,
              decoration: InputDecoration(
                hintText: 'Search audio...',
                hintStyle: TextStyle(color: AppColors.textLow, fontSize: 14),
                prefixIcon: Icon(Icons.search, size: 18, color: AppColors.textLow),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: _tabs.map((t) => _TabChip(label: t)).toList(),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _AudioItem(name: 'Cinematic Drum', duration: '2:34', artist: 'Epic Sounds'),
              _AudioItem(name: 'Lo-Fi Beat', duration: '1:15', artist: 'Chill Mode'),
              _AudioItem(name: 'Ambient Pad', duration: '3:00', artist: 'Atmosphere'),
              _AudioItem(name: 'Bass Drop', duration: '0:45', artist: 'EDM World'),
              _AudioItem(name: 'Synth Wave', duration: '1:30', artist: 'Retro'),
              _AudioItem(name: 'Acoustic Guitar', duration: '0:50', artist: 'Folk Tales'),
              _AudioItem(name: 'Piano Melody', duration: '1:00', artist: 'Classical'),
              _AudioItem(name: 'Orchestral Hit', duration: '0:25', artist: 'Cinematic'),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                HapticService.trigger(HapticLevel.light);
                Navigator.pop(context);
              },
              child: const Text('Import Selected'),
            ),
          ),
        ),
      ],
    );
  }
}

class _TabChip extends StatefulWidget {
  final String label;
  const _TabChip({required this.label});

  @override
  State<_TabChip> createState() => _TabChipState();
}

class _TabChipState extends State<_TabChip> {
  bool _selected = false;

  @override
  Widget build(BuildContext context) {
    final selected = _selected;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () {
          HapticService.trigger(HapticLevel.light);
          setState(() => _selected = !_selected);
        },
        child: AnimatedContainer(
          duration: AppMotion.normal,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? AppColors.brand500 : AppColors.bgElevated,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(widget.label, style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: selected ? Colors.white : AppColors.textMedium,
          )),
        ),
      ),
    );
  }
}

class _AudioItem extends StatelessWidget {
  final String name;
  final String duration;
  final String artist;
  const _AudioItem({required this.name, required this.duration, required this.artist});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: GestureDetector(
        onTap: () {
          HapticService.trigger(HapticLevel.light);
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.bgElevated,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: AppColors.trackAudio.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.music_note, size: 18, color: AppColors.trackAudio),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: AppTypography.titleSm),
                    Text(artist, style: AppTypography.bodySm),
                  ],
                ),
              ),
              Text(duration, style: AppTypography.bodyMd),
              const SizedBox(width: 8),
              const Icon(Icons.play_circle_outline, size: 20, color: AppColors.brand500),
            ],
          ),
        ),
      ),
    );
  }
}
