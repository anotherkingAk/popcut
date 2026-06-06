import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/haptic_service.dart';
import '../../widgets/common/app_bottom_sheet.dart';

class ExportProgressSheet extends StatelessWidget {
  const ExportProgressSheet({super.key});

  static void show(BuildContext context) {
    AppBottomSheet.show(
      context: context,
      title: 'Exporting...',
      icon: Icons.downloading,
      body: const ExportProgressSheet(),
      maxHeightFactor: 0.7,
      showDragHandle: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Spacer(),
          SizedBox(
            width: 140, height: 140,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 140, height: 140,
                  child: CircularProgressIndicator(
                    value: 0.65,
                    strokeWidth: 6,
                    backgroundColor: AppColors.bgOverlay,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.brand500),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('65%', style: AppTypography.displayLg),
                    const Text('124 MB / 190 MB', style: AppTypography.bodySm),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.bgElevated,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 8, height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.brand500,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text('Encoding...', style: AppTypography.titleSm),
                const Spacer(),
                const Icon(Icons.timer_outlined, size: 16, color: AppColors.textLow),
                const SizedBox(width: 4),
                const Text('~1:30 remaining', style: AppTypography.bodySm),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.bgElevated,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.notifications_none, size: 18, color: AppColors.textMedium),
                const SizedBox(width: 10),
                const Text('Background export', style: AppTypography.bodyMd),
                const Spacer(),
                Switch(value: false, onChanged: (_) {}),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton.icon(
              onPressed: () {
                HapticService.trigger(HapticLevel.light);
              },
              icon: const Icon(Icons.notifications_off, size: 16),
              label: const Text('Collapse to notification'),
              style: TextButton.styleFrom(foregroundColor: AppColors.textLow),
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                HapticService.trigger(HapticLevel.light);
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.error,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Cancel Export', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}
