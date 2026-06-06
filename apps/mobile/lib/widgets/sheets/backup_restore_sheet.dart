import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_motion.dart';
import '../../services/haptic_service.dart';
import '../../widgets/common/app_bottom_sheet.dart';

class BackupRestoreSheet extends StatelessWidget {
  const BackupRestoreSheet({super.key});

  static void show(BuildContext context) {
    AppBottomSheet.show(
      context: context,
      title: 'Backup & Restore',
      icon: Icons.backup_outlined,
      body: const BackupRestoreSheet(),
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
          Row(
            children: [
              const Icon(Icons.access_time, size: 16, color: AppColors.textMedium),
              const SizedBox(width: 8),
              const Text('Last backup: Today, 2:30 PM', style: AppTypography.bodyMd),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                HapticService.trigger(HapticLevel.light);
              },
              icon: const Icon(Icons.backup, size: 18),
              label: const Text('Back Up Now'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('Auto-backup', style: AppTypography.bodyMd),
              const Spacer(),
              Switch(value: true, onChanged: (v) {
                HapticService.trigger(HapticLevel.light);
              }),
            ],
          ),
          const SizedBox(height: 8),
          Text('Backup frequency', style: AppTypography.label),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.bgElevated,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: const [
                Expanded(child: Text('Daily', style: AppTypography.bodyMd)),
                Icon(Icons.arrow_drop_down, color: AppColors.textLow),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Divider(color: AppColors.border),
          const SizedBox(height: 12),
          Text('Restore', style: AppTypography.titleSm),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                HapticService.trigger(HapticLevel.light);
              },
              icon: const Icon(Icons.restore, size: 18),
              label: const Text('Restore from Backup'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textHigh,
                side: const BorderSide(color: AppColors.border),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Backup History', style: AppTypography.label),
          const SizedBox(height: 8),
          _BackupEntry(date: 'Jun 6, 2026', size: '245 MB'),
          _BackupEntry(date: 'Jun 5, 2026', size: '240 MB'),
          _BackupEntry(date: 'Jun 4, 2026', size: '238 MB'),
        ],
      ),
    );
  }
}

class _BackupEntry extends StatelessWidget {
  final String date;
  final String size;
  const _BackupEntry({required this.date, required this.size});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: GestureDetector(
        onTap: () {
          HapticService.trigger(HapticLevel.light);
          _showDeleteDialog(context);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.bgElevated,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.backup, size: 16, color: AppColors.textMedium),
              const SizedBox(width: 10),
              Expanded(child: Text(date, style: AppTypography.bodyMd)),
              Text(size, style: AppTypography.bodySm),
              const SizedBox(width: 8),
              const Icon(Icons.delete_outline, size: 16, color: AppColors.textLow),
            ],
          ),
        ),
      ),
    );
  }
}

void _showDeleteDialog(BuildContext context) {
  HapticService.trigger(HapticLevel.light);
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.bgSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Delete Backup', style: AppTypography.titleMd),
      content: const Text('Are you sure you want to delete this backup?', style: AppTypography.bodyMd),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel', style: TextStyle(color: AppColors.textMedium)),
        ),
        TextButton(
          onPressed: () {
            HapticService.delete();
            Navigator.pop(ctx);
          },
          child: const Text('Delete', style: TextStyle(color: AppColors.error)),
        ),
      ],
    ),
  );
}
