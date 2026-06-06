import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/app_motion.dart';
import '../../../services/haptic_service.dart';

class RadialMenu extends StatelessWidget {
  final AnimationController staggerController;
  const RadialMenu({super.key, required this.staggerController});

  final _actions = const [
    _RadialAction('Split', Icons.content_cut),
    _RadialAction('Delete', Icons.delete_outline),
    _RadialAction('Duplicate', Icons.copy),
    _RadialAction('Copy FX', Icons.copy_all),
    _RadialAction('Paste FX', Icons.paste),
    _RadialAction('Replace', Icons.swap_horiz),
    _RadialAction('Speed', Icons.speed),
    _RadialAction('Freeze', Icons.ac_unit),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 180,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Stack(
              alignment: Alignment.center,
              children: [
                for (int i = 0; i < _actions.length; i++)
                  Positioned(
                    left: 20 + (i % 4) * 80.0,
                    top: (i < 4 ? 0 : 90.0),
                    child: _buildRadialItem(_actions[i], i),
                  ),
                GestureDetector(
                  onTap: () => HapticService.trigger(HapticLevel.light),
                  child: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.error.withValues(alpha: 0.2),
                      border: Border.all(color: AppColors.error, width: 2),
                    ),
                    child: const Icon(Icons.close, size: 18, color: AppColors.error),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadialItem(_RadialAction action, int index) {
    return GestureDetector(
      onTap: () => HapticService.trigger(HapticLevel.light),
      child: Container(
        width: 64, height: 64,
        decoration: BoxDecoration(
          color: AppColors.bgElevated.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [
            BoxShadow(color: AppColors.bgOverlay.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(action.icon, size: 20, color: AppColors.textHigh),
            const SizedBox(height: 4),
            Text(action.name, style: const TextStyle(fontSize: 9, color: AppColors.textMedium, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _RadialAction {
  final String name;
  final IconData icon;
  const _RadialAction(this.name, this.icon);
}
