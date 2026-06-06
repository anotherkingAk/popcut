import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/haptic_service.dart';
import '../../widgets/common/app_bottom_sheet.dart';

class SharePlatformSheet extends StatelessWidget {
  const SharePlatformSheet({super.key});

  static const _platforms = [
    ('Instagram', Icons.camera_alt_outlined, 'Feed, Story, Reels'),
    ('TikTok', Icons.music_video, 'Video, Trending sounds'),
    ('YouTube', Icons.videocam, 'Shorts, Main content'),
    ('WhatsApp', Icons.chat, 'Chat, Status'),
    ('Twitter', Icons.alternate_email, 'Tweets, Media'),
    ('Facebook', Icons.facebook, 'Feed, Stories'),
    ('Snapchat', Icons.bolt, 'Snaps, Spotlight'),
    ('Copy Link', Icons.link, 'Shareable URL'),
    ('More', Icons.ios_share, 'System share sheet'),
  ];

  static void show(BuildContext context) {
    AppBottomSheet.show(
      context: context,
      title: 'Share to...',
      icon: Icons.share_outlined,
      body: const SharePlatformSheet(),
      maxHeightFactor: 0.92,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ..._platforms.map((p) => _PlatformCard(
                icon: p.$2,
                name: p.$1,
                description: p.$3,
              )),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.bgElevated,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.movie_outlined, size: 16, color: AppColors.textMedium),
                    const SizedBox(width: 8),
                    const Text('project_export.mp4', style: AppTypography.bodyMd),
                    const Spacer(),
                    const Text('3:42 · 1080p', style: AppTypography.bodySm),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Include project', style: AppTypography.bodyMd),
                    const Spacer(),
                    Switch(value: false, onChanged: (v) {
                      HapticService.trigger(HapticLevel.light);
                    }),
                  ],
                ),
                Row(
                  children: [
                    const Text('High quality', style: AppTypography.bodyMd),
                    const Spacer(),
                    Switch(value: true, onChanged: (v) {
                      HapticService.trigger(HapticLevel.light);
                    }),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                HapticService.trigger(HapticLevel.light);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Share', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlatformCard extends StatelessWidget {
  final IconData icon;
  final String name;
  final String description;
  const _PlatformCard({required this.icon, required this.name, required this.description});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () => HapticService.trigger(HapticLevel.light),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.bgElevated,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: AppColors.bgOverlay,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: AppColors.textHigh),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: AppTypography.titleSm),
                    Text(description, style: AppTypography.bodySm),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
