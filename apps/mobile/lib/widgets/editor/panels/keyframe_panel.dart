import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/app_motion.dart';
import '../../../services/haptic_service.dart';

class KeyframePanel extends StatelessWidget {
  final AnimationController staggerController;
  const KeyframePanel({super.key, required this.staggerController});

  final _keyframes = const [
    _KFDef('Position X', '0:05', '500px', 'Linear'),
    _KFDef('Position Y', '0:10', '300px', 'Ease'),
    _KFDef('Scale', '0:15', '1.5x', 'Bezier'),
    _KFDef('Rotation', '0:20', '45°', 'Step'),
    _KFDef('Opacity', '0:25', '100%', 'Linear'),
  ];

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
              padding: EdgeInsets.zero,
              children: [
                _buildTimeline(),
                _buildAddKeyframeButton(),
                _buildKeyframeList(),
                _buildNavigationBar(),
                const SizedBox(height: 8),
                _buildSettings(),
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
      child: const Text('Keyframes', style: AppTypography.titleSm),
    );
  }

  Widget _buildTimeline() {
    return Container(
      height: 40,
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.timelineBg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.timelineGrid),
      ),
      child: Stack(
        children: [
          Center(
            child: Row(
              children: List.generate(20, (i) => Expanded(
                child: Container(height: 1, color: i % 5 == 0 ? AppColors.timelineGrid : Colors.transparent),
              )),
            ),
          ),
          for (int i = 0; i < 5; i++)
            Positioned(
              left: 16 + i * 56.0,
              top: 12,
              child: Icon(Icons.diamond, size: 14, color: AppColors.brand500),
            ),
        ],
      ),
    );
  }

  Widget _buildAddKeyframeButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: GestureDetector(
        onTap: () => HapticService.trigger(HapticLevel.light),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.brand500.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.brand500.withValues(alpha: 0.3)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, size: 14, color: AppColors.brand500),
              SizedBox(width: 6),
              Text('Add Keyframe', style: TextStyle(fontSize: 11, color: AppColors.brand500, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeyframeList() {
    return Column(
      children: _keyframes.map((kf) => GestureDetector(
        onTap: () => HapticService.trigger(HapticLevel.light),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5))),
          child: Row(
            children: [
              Container(
                width: 8, height: 8,
                decoration:                 const BoxDecoration(color: AppColors.brand500, borderRadius: BorderRadius.all(Radius.circular(2))),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(kf.property, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textHigh)),
                    Text('${kf.time} · ${kf.value}', style: const TextStyle(fontSize: 10, color: AppColors.textLow)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: AppColors.bgSurface, borderRadius: BorderRadius.circular(4), border: Border.all(color: AppColors.border)),
                child: Text(kf.interpolation, style: const TextStyle(fontSize: 8, color: AppColors.textLow)),
              ),
            ],
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildNavigationBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          _NavBtn(Icons.skip_previous, () => HapticService.trigger(HapticLevel.light)),
          const SizedBox(width: 6),
          _NavBtn(Icons.skip_next, () => HapticService.trigger(HapticLevel.light)),
          const Spacer(),
          _NavBtn(Icons.copy, () => HapticService.trigger(HapticLevel.light)),
          const SizedBox(width: 6),
          _NavBtn(Icons.paste, () => HapticService.trigger(HapticLevel.light)),
          const SizedBox(width: 6),
          _NavBtn(Icons.delete_outline, () => HapticService.trigger(HapticLevel.heavy), destructive: true),
        ],
      ),
    );
  }

  Widget _buildSettings() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: _buildToggleRow('Show All Animated Properties', false),
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

class _KFDef {
  final String property;
  final String time;
  final String value;
  final String interpolation;
  const _KFDef(this.property, this.time, this.value, this.interpolation);
}

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool destructive;
  const _NavBtn(this.icon, this.onTap, {this.destructive = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: destructive ? AppColors.error.withValues(alpha: 0.1) : AppColors.bgSurface,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: destructive ? AppColors.error.withValues(alpha: 0.3) : AppColors.border),
        ),
        child: Icon(icon, size: 14, color: destructive ? AppColors.error : AppColors.textMedium),
      ),
    );
  }
}
