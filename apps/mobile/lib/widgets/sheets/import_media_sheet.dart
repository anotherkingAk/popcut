import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_motion.dart';
import '../../services/haptic_service.dart';
import '../../widgets/common/app_bottom_sheet.dart';

class ImportMediaSheet extends StatelessWidget {
  const ImportMediaSheet({super.key});

  static const _sources = [
    (Icons.photo_library, 'Camera Roll', 'Photos & videos on device'),
    (Icons.videocam, 'Record Video', 'Capture new video'),
    (Icons.folder_open, 'Files', 'Browse file manager'),
    (Icons.cloud, 'Cloud Storage', 'iCloud, Google Drive, Dropbox'),
    (Icons.link, 'YouTube URL', 'Download from link'),
  ];

  static const _recent = [
    ('video_2024.mp4', '2:34'),
    ('clip_015.mov', '0:45'),
    ('intro_take2.mp4', '1:20'),
  ];

  static void show(BuildContext context) {
    AppBottomSheet.show(
      context: context,
      title: 'Import',
      icon: Icons.add_box_outlined,
      body: const ImportMediaSheet(),
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
          Text('Source', style: AppTypography.label),
          const SizedBox(height: 8),
          ..._sources.map((s) => _SourceCard(icon: s.$1, label: s.$2, subtitle: s.$3)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent Imports', style: AppTypography.label),
              Text('See all', style: TextStyle(fontSize: 11, color: AppColors.brand500)),
            ],
          ),
          const SizedBox(height: 8),
          ..._recent.map((r) => _RecentItem(name: r.$1, duration: r.$2)),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                HapticService.trigger(HapticLevel.light);
                Navigator.pop(context);
              },
              child: const Text('Import Selected'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SourceCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  const _SourceCard({required this.icon, required this.label, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () {
          HapticService.trigger(HapticLevel.light);
        },
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
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: AppColors.textHigh),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: AppTypography.titleSm),
                    const SizedBox(height: 2),
                    Text(subtitle, style: AppTypography.bodySm),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, size: 18, color: AppColors.textLow),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentItem extends StatelessWidget {
  final String name;
  final String duration;
  const _RecentItem({required this.name, required this.duration});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: GestureDetector(
        onTap: () => HapticService.trigger(HapticLevel.light),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.bgElevated,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.movie_outlined, size: 16, color: AppColors.textMedium),
              const SizedBox(width: 10),
              Expanded(child: Text(name, style: AppTypography.bodyMd)),
              Text(duration, style: AppTypography.bodySm),
            ],
          ),
        ),
      ),
    );
  }
}
