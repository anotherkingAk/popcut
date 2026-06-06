import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_motion.dart';
import '../../services/haptic_service.dart';
import '../../widgets/common/app_bottom_sheet.dart';

class AppearanceSettingsSheet extends StatelessWidget {
  const AppearanceSettingsSheet({super.key});

  static const _accentColors = [
    AppColors.primary, AppColors.error, AppColors.textMedium,
    AppColors.trackAudio, AppColors.warning, AppColors.trackText,
    AppColors.trackOverlay, AppColors.trackEffect,
  ];

  static void show(BuildContext context) {
    AppBottomSheet.show(
      context: context,
      title: 'Appearance',
      icon: Icons.palette_outlined,
      body: const AppearanceSettingsSheet(),
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
          Text('Theme Mode', style: AppTypography.label),
          const SizedBox(height: 8),
          Row(
            children: ['Dark', 'Light', 'System'].map((t) => Expanded(
              child: _ThemeChip(label: t),
            )).toList(),
          ),
          const SizedBox(height: 20),
          Text('Accent Color', style: AppTypography.label),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _accentColors.map((c) => _AccentSwatch(color: c)).toList(),
          ),
          const SizedBox(height: 20),
          Text('Timeline Density', style: AppTypography.label),
          const SizedBox(height: 8),
          Row(
            children: ['Compact', 'Normal', 'Comfortable'].map((d) => Expanded(
              child: _DensityChip(label: d),
            )).toList(),
          ),
          const SizedBox(height: 20),
          _SliderRow('Font Scale', 0.8, 1.4, 1.0),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('Reduce Motion', style: AppTypography.bodyMd),
              const Spacer(),
              Switch(value: false, onChanged: (v) {
                HapticService.trigger(HapticLevel.light);
              }),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Text('Reduce Transparency', style: AppTypography.bodyMd),
              const Spacer(),
              Switch(value: false, onChanged: (v) {
                HapticService.trigger(HapticLevel.light);
              }),
            ],
          ),
          const SizedBox(height: 14),
          Text('UI Density', style: AppTypography.label),
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
                Expanded(child: Text('Normal', style: AppTypography.bodyMd)),
                Icon(Icons.arrow_drop_down, color: AppColors.textLow),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                HapticService.trigger(HapticLevel.light);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textMedium,
                side: const BorderSide(color: AppColors.border),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Reset to Defaults'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeChip extends StatefulWidget {
  final String label;
  const _ThemeChip({required this.label});

  @override
  State<_ThemeChip> createState() => _ThemeChipState();
}

class _ThemeChipState extends State<_ThemeChip> {
  bool _selected = false;

  @override
  Widget build(BuildContext context) {
    final selected = _selected;
    final isDark = widget.label == 'Dark';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: GestureDetector(
        onTap: () {
          HapticService.trigger(HapticLevel.light);
          setState(() => _selected = !_selected);
        },
        child: AnimatedContainer(
          duration: AppMotion.normal,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? (isDark ? AppColors.bgOverlay : AppColors.textHigh.withValues(alpha: 0.1))
                : AppColors.bgElevated,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? AppColors.brand500 : AppColors.border,
              width: selected ? 1.5 : 0.5,
            ),
          ),
          child: Column(
            children: [
              Icon(
                widget.label == 'Dark' ? Icons.dark_mode : widget.label == 'Light' ? Icons.light_mode : Icons.settings_brightness,
                size: 22,
                color: selected ? AppColors.brand500 : AppColors.textMedium,
              ),
              const SizedBox(height: 4),
              Text(widget.label, style: TextStyle(
                fontSize: 12,
                color: selected ? AppColors.textHigh : AppColors.textMedium,
              )),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccentSwatch extends StatelessWidget {
  final Color color;
  const _AccentSwatch({required this.color});

  @override
  Widget build(BuildContext context) {
    final isSelected = color == AppColors.brand500;
    return GestureDetector(
      onTap: () => HapticService.trigger(HapticLevel.light),
      child: Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 2.5,
          ),
        ),
        child: isSelected
            ? const Icon(Icons.check, size: 16, color: Colors.white)
            : null,
      ),
    );
  }
}

class _DensityChip extends StatefulWidget {
  final String label;
  const _DensityChip({required this.label});

  @override
  State<_DensityChip> createState() => _DensityChipState();
}

class _DensityChipState extends State<_DensityChip> {
  bool _selected = false;

  @override
  Widget build(BuildContext context) {
    final selected = _selected;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: GestureDetector(
        onTap: () {
          HapticService.trigger(HapticLevel.light);
          setState(() => _selected = !_selected);
        },
        child: AnimatedContainer(
          duration: AppMotion.normal,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.brand500.withValues(alpha: 0.15) : AppColors.bgElevated,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: selected ? AppColors.brand500 : AppColors.border),
          ),
          child: Center(
            child: Text(widget.label, style: TextStyle(
              fontSize: 12,
              color: selected ? AppColors.textHigh : AppColors.textMedium,
            )),
          ),
        ),
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  final String label;
  final double min;
  final double max;
  final double initial;
  const _SliderRow(this.label, this.min, this.max, this.initial);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: AppTypography.label),
            const Spacer(),
            Text(initial.toStringAsFixed(1), style: AppTypography.bodySm),
          ],
        ),
        Slider(value: initial, min: min, max: max, onChanged: (_) {}),
      ],
    );
  }
}
