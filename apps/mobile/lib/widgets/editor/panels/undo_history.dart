import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/app_motion.dart';
import '../../../services/haptic_service.dart';

class UndoHistory extends StatelessWidget {
  final AnimationController staggerController;
  const UndoHistory({super.key, required this.staggerController});

  final _actions = const [
    _UndoAction('Cut Clip', '2 min ago', Icons.content_cut, false),
    _UndoAction('Delete Clip', '5 min ago', Icons.delete_outline, false),
    _UndoAction('Move Clip', '8 min ago', Icons.open_with, false),
    _UndoAction('Add Effect', '12 min ago', Icons.auto_fix_high, false),
    _UndoAction('Trim Clip', '15 min ago', Icons.content_cut, true),
    _UndoAction('Add Transition', '18 min ago', Icons.blur_linear, false),
    _UndoAction('Change Speed', '22 min ago', Icons.speed, false),
    _UndoAction('Split Clip', '30 min ago', Icons.content_cut, false),
    _UndoAction('Add Text', '35 min ago', Icons.text_fields, false),
    _UndoAction('Adjust Volume', '42 min ago', Icons.volume_up, false),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgElevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildActionBar(),
          const Divider(height: 0.5, color: AppColors.border),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: _actions.length,
              itemBuilder: (_, i) => _buildActionItem(i),
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
      child: const Text('Undo History', style: AppTypography.titleSm),
    );
  }

  Widget _buildActionBar() {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          _ActionChip(Icons.undo, 'Undo', () => HapticService.trigger(HapticLevel.light)),
          const SizedBox(width: 6),
          _ActionChip(Icons.redo, 'Redo', () => HapticService.trigger(HapticLevel.light)),
          const Spacer(),
          _ActionChip(Icons.delete_sweep, 'Clear', () => HapticService.trigger(HapticLevel.light)),
        ],
      ),
    );
  }

  Widget _buildActionItem(int index) {
    final a = _actions[index];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: a.isCurrent ? AppColors.brand500.withValues(alpha: 0.08) : Colors.transparent,
        border: const Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              color: a.isCurrent ? AppColors.brand500.withValues(alpha: 0.15) : AppColors.bgSurface,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(a.icon, size: 14, color: a.isCurrent ? AppColors.brand500 : AppColors.textMedium),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(a.description, style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w500,
                  color: a.isCurrent ? AppColors.brand500 : AppColors.textHigh,
                )),
                Text(a.timeAgo, style: const TextStyle(fontSize: 10, color: AppColors.textLow)),
              ],
            ),
          ),
          if (a.isCurrent)
            Container(
              width: 6, height: 6,
              decoration: const BoxDecoration(color: AppColors.brand500, shape: BoxShape.circle),
            ),
        ],
      ),
    );
  }
}

class _UndoAction {
  final String description;
  final String timeAgo;
  final IconData icon;
  final bool isCurrent;
  const _UndoAction(this.description, this.timeAgo, this.icon, this.isCurrent);
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionChip(this.icon, this.label, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(color: AppColors.bgSurface, borderRadius: BorderRadius.circular(6), border: Border.all(color: AppColors.border)),
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
