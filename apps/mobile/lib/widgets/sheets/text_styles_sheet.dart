import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_motion.dart';
import '../../services/haptic_service.dart';
import '../../widgets/common/app_bottom_sheet.dart';

class TextStylesSheet extends StatelessWidget {
  const TextStylesSheet({super.key});

  static void show(BuildContext context) {
    AppBottomSheet.show(
      context: context,
      title: 'Text Styles',
      icon: Icons.text_fields,
      body: const TextStylesSheet(),
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
          Text('Presets', style: AppTypography.label),
          const SizedBox(height: 8),
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: List.generate(20, (i) => _StylePreset(index: i)),
            ),
          ),
          const SizedBox(height: 16),
          Text('Font', style: AppTypography.label),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.bgElevated,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: const [
                Expanded(child: Text('Poppins', style: AppTypography.bodyLg)),
                Icon(Icons.arrow_drop_down, color: AppColors.textLow),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text('Size', style: AppTypography.label),
          Row(
            children: [
              const Text('12', style: AppTypography.bodySm),
              Expanded(child: Slider(value: 36, min: 12, max: 120, onChanged: (_) {})),
              const Text('120', style: AppTypography.bodySm),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Color', style: AppTypography.label),
                    const SizedBox(height: 6),
                    Container(
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.textHigh,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Background', style: AppTypography.label),
                    const SizedBox(height: 6),
                    Container(
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.brand500.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _ToggleChip('Shadow', Icons.blur_on),
              const SizedBox(width: 8),
              _ToggleChip('Outline', Icons.border_style),
            ],
          ),
          const SizedBox(height: 14),
          Text('Alignment', style: AppTypography.label),
          const SizedBox(height: 6),
          Row(
            children: [
              _AlignChip(Icons.format_align_left),
              const SizedBox(width: 6),
              _AlignChip(Icons.format_align_center),
              const SizedBox(width: 6),
              _AlignChip(Icons.format_align_right),
            ],
          ),
          const SizedBox(height: 14),
          Text('Animation', style: AppTypography.label),
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
                Expanded(child: Text('Fade In', style: AppTypography.bodyMd)),
                Icon(Icons.arrow_drop_down, color: AppColors.textLow),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                HapticService.trigger(HapticLevel.light);
                Navigator.pop(context);
              },
              child: const Text('Apply Style'),
            ),
          ),
        ],
      ),
    );
  }
}

class _StylePreset extends StatelessWidget {
  final int index;
  const _StylePreset({required this.index});

  @override
  Widget build(BuildContext context) {
    final colors = [AppColors.textHigh, AppColors.brand500, AppColors.success, AppColors.error, AppColors.warning];
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: () => HapticService.trigger(HapticLevel.light),
        child: Container(
          width: 72, height: 90,
          decoration: BoxDecoration(
            color: AppColors.bgElevated,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Aa', style: TextStyle(
                fontSize: 24,
                fontWeight: index % 2 == 0 ? FontWeight.w700 : FontWeight.w300,
                color: colors[index % colors.length],
              )),
              const SizedBox(height: 4),
              Text('Style ${index + 1}', style: const TextStyle(fontSize: 9, color: AppColors.textLow)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToggleChip extends StatefulWidget {
  final String label;
  final IconData icon;
  const _ToggleChip(this.label, this.icon);

  @override
  State<_ToggleChip> createState() => _ToggleChipState();
}

class _ToggleChipState extends State<_ToggleChip> {
  bool _active = false;

  @override
  Widget build(BuildContext context) {
    final active = _active;
    return GestureDetector(
      onTap: () {
        HapticService.trigger(HapticLevel.light);
        setState(() => _active = !_active);
      },
      child: AnimatedContainer(
        duration: AppMotion.normal,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.brand500.withValues(alpha: 0.15) : AppColors.bgElevated,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: active ? AppColors.brand500 : AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(widget.icon, size: 14, color: active ? AppColors.brand500 : AppColors.textMedium),
            const SizedBox(width: 4),
            Text(widget.label, style: TextStyle(
              fontSize: 12, color: active ? AppColors.textHigh : AppColors.textMedium)),
          ],
        ),
      ),
    );
  }
}

class _AlignChip extends StatefulWidget {
  final IconData icon;
  const _AlignChip(this.icon);

  @override
  State<_AlignChip> createState() => _AlignChipState();
}

class _AlignChipState extends State<_AlignChip> {
  bool _selected = false;

  @override
  Widget build(BuildContext context) {
    final selected = _selected;
    return GestureDetector(
      onTap: () {
        HapticService.trigger(HapticLevel.light);
        setState(() => _selected = !_selected);
      },
      child: AnimatedContainer(
        duration: AppMotion.normal,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: selected ? AppColors.brand500.withValues(alpha: 0.15) : AppColors.bgElevated,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? AppColors.brand500 : AppColors.border),
        ),
        child: Icon(widget.icon, size: 18, color: selected ? AppColors.brand500 : AppColors.textMedium),
      ),
    );
  }
}
