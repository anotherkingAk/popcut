import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/app_motion.dart';
import '../../../services/haptic_service.dart';

class MultiSelectToolbar extends StatelessWidget {
  final AnimationController staggerController;
  const MultiSelectToolbar({super.key, required this.staggerController});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgElevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _ToolbarAction(Icons.checklist, 'Group', () => HapticService.trigger(HapticLevel.light)),
                _ToolbarAction(Icons.align_horizontal_left, 'Align L', () => HapticService.trigger(HapticLevel.light)),
                _ToolbarAction(Icons.align_horizontal_center, 'Center', () => HapticService.trigger(HapticLevel.light)),
                _ToolbarAction(Icons.align_horizontal_right, 'Align R', () => HapticService.trigger(HapticLevel.light)),
                _ToolbarAction(Icons.width_full, 'Equal W', () => HapticService.trigger(HapticLevel.light)),
                _ToolbarAction(Icons.space_bar, 'Distribute', () => HapticService.trigger(HapticLevel.light)),
                _ToolbarAction(Icons.merge, 'Merge', () => HapticService.trigger(HapticLevel.light)),
                _ToolbarAction(Icons.delete_outline, 'Delete', () => HapticService.trigger(HapticLevel.heavy), destructive: true),
                _ToolbarAction(Icons.copy, 'Duplicate', () => HapticService.trigger(HapticLevel.light)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5))),
      child: Row(
        children: [
          const Text('Multi-Select', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMedium)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: AppColors.brand500, borderRadius: BorderRadius.circular(8)),
            child: const Text('3', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => HapticService.trigger(HapticLevel.light),
            child: const Text('Deselect All', style: TextStyle(fontSize: 11, color: AppColors.brand500)),
          ),
        ],
      ),
    );
  }
}

class _ToolbarAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;
  const _ToolbarAction(this.icon, this.label, this.onTap, {this.destructive = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(
          color: destructive ? AppColors.error.withValues(alpha: 0.1) : AppColors.bgSurface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: destructive ? AppColors.error.withValues(alpha: 0.3) : AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: destructive ? AppColors.error : AppColors.textMedium),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 8, color: destructive ? AppColors.error : AppColors.textLow)),
          ],
        ),
      ),
    );
  }
}
