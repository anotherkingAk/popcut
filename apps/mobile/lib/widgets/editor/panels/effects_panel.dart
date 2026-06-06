import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../services/haptic_service.dart';

class EffectsPanel extends StatelessWidget {
  final AnimationController staggerController;
  const EffectsPanel({super.key, required this.staggerController});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.panelBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5))),
            child: const Text('Effects',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.foreground)),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 0.8,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _effects.length,
              itemBuilder: (context, i) {
                final item = _effects[i];
                return GestureDetector(
                  onTap: () { HapticService.trigger(HapticLevel.light); },
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(item.icon, size: 20, color: AppColors.foregroundSecondary),
                      ),
                      const SizedBox(height: 6),
                      Text(item.name, style: const TextStyle(fontSize: 9, color: AppColors.foregroundSecondary),
                        textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                    ),
                    ),
                    );
                },
            ),
          ),
        ],
      ),
    );
  }
}

class _EffectItem {
  final String name;
  final IconData icon;
  const _EffectItem(this.name, this.icon);
}

final _effects = [
  const _EffectItem('Blur', Icons.blur_on),
  const _EffectItem('Glitch', Icons.flash_on),
  const _EffectItem('VHS', Icons.videocam),
  const _EffectItem('Film', Icons.movie),
  const _EffectItem('Grain', Icons.grain),
  const _EffectItem('Pixelate', Icons.grid_on),
  const _EffectItem('Neon', Icons.auto_awesome),
  const _EffectItem('Mirror', Icons.flip),
  const _EffectItem('Sepia', Icons.color_lens),
  const _EffectItem('B&W', Icons.invert_colors),
  const _EffectItem('Vignette', Icons.radio_button_unchecked),
  const _EffectItem('Chromatic', Icons.leak_add),
];
