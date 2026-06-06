import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/haptic_service.dart';
import '../../widgets/common/app_bottom_sheet.dart';

class AudioMixerSheet extends StatelessWidget {
  const AudioMixerSheet({super.key});

  static void show(BuildContext context) {
    AppBottomSheet.show(
      context: context,
      title: 'Audio Mixer',
      icon: Icons.tune,
      body: const AudioMixerSheet(),
      maxHeightFactor: 0.95,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TrackChannel(label: 'Video Audio', isVideo: true),
          const SizedBox(height: 12),
          _TrackChannel(label: 'Background Music', isVideo: false),
          const SizedBox(height: 12),
          _TrackChannel(label: 'Voiceover', isVideo: false),
          const SizedBox(height: 20),
          const Divider(color: AppColors.border),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('Master Volume', style: AppTypography.titleSm),
              const Spacer(),
              const Text('100%', style: AppTypography.bodyMd),
            ],
          ),
          Slider(value: 0.85, min: 0, max: 1, onChanged: (_) {}),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.mic, size: 16, color: AppColors.textMedium),
              const SizedBox(width: 8),
              const Text('Ducking (reduce others when speech detected)', style: AppTypography.bodySm),
              const Spacer(),
              Switch(value: false, onChanged: (v) {
                HapticService.trigger(HapticLevel.light);
              }),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                HapticService.trigger(HapticLevel.light);
              },
              icon: const Icon(Icons.auto_fix_high, size: 18),
              label: const Text('Normalize All Tracks'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textHigh,
                side: const BorderSide(color: AppColors.border),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrackChannel extends StatefulWidget {
  final String label;
  final bool isVideo;
  const _TrackChannel({required this.label, required this.isVideo});

  @override
  State<_TrackChannel> createState() => _TrackChannelState();
}

class _TrackChannelState extends State<_TrackChannel> {
  bool _mute = false;
  bool _solo = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgElevated,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                widget.isVideo ? Icons.videocam : Icons.music_note,
                size: 16,
                color: widget.isVideo ? AppColors.trackVideo : AppColors.trackAudio,
              ),
              const SizedBox(width: 8),
              Text(widget.label, style: AppTypography.titleSm),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  HapticService.trigger(HapticLevel.light);
                  setState(() => _mute = !_mute);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _mute ? AppColors.error.withValues(alpha: 0.2) : AppColors.bgOverlay,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text('Mute', style: TextStyle(
                    fontSize: 11,
                    color: _mute ? AppColors.error : AppColors.textMedium,
                    fontWeight: FontWeight.w500,
                  )),
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () {
                  HapticService.trigger(HapticLevel.light);
                  setState(() => _solo = !_solo);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _solo ? AppColors.warning.withValues(alpha: 0.2) : AppColors.bgOverlay,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text('Solo', style: TextStyle(
                    fontSize: 11,
                    color: _solo ? AppColors.warning : AppColors.textMedium,
                    fontWeight: FontWeight.w500,
                  )),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Vol', style: AppTypography.bodySm),
              const SizedBox(width: 6),
              Expanded(
                child: Slider(value: 0.8, min: 0, max: 1, onChanged: (_) {}),
              ),
              const SizedBox(width: 6),
              const Text('Pan', style: AppTypography.bodySm),
              const SizedBox(width: 6),
              Expanded(
                child: Slider(value: 0.5, min: 0, max: 1, onChanged: (_) {}),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
