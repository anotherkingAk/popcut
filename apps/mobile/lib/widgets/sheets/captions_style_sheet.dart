import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_motion.dart';
import '../../services/haptic_service.dart';
import '../../widgets/common/app_bottom_sheet.dart';

class CaptionsStyleSheet extends StatelessWidget {
  const CaptionsStyleSheet({super.key});

  static void show(BuildContext context) {
    AppBottomSheet.show(
      context: context,
      title: 'Caption Style',
      icon: Icons.closed_caption_outlined,
      body: const CaptionsStyleSheet(),
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
          Text('Font', style: AppTypography.label),
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
                Expanded(child: Text('Poppins', style: AppTypography.bodyLg)),
                Icon(Icons.arrow_drop_down, color: AppColors.textLow),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _SliderRow('Size', 12, 72, 28),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Text Color', style: AppTypography.label),
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
                        color: AppColors.bgOverlay,
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
          Text('Position', style: AppTypography.label),
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
                Expanded(child: Text('Bottom Center', style: AppTypography.bodyMd)),
                Icon(Icons.arrow_drop_down, color: AppColors.textLow),
              ],
            ),
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
          Text('Case', style: AppTypography.label),
          const SizedBox(height: 6),
          Row(
            children: ['UPPER', 'lower', 'Title'].map((c) => _CaseChip(label: c)).toList(),
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
                Expanded(child: Text('Typewriter', style: AppTypography.bodyMd)),
                Icon(Icons.arrow_drop_down, color: AppColors.textLow),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _SliderRow('Max Width', 50, 100, 85),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('Save as Default', style: AppTypography.bodyMd),
              const Spacer(),
              Switch(value: false, onChanged: (v) {
                HapticService.trigger(HapticLevel.light);
              }),
            ],
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

class _CaseChip extends StatefulWidget {
  final String label;
  const _CaseChip({required this.label});

  @override
  State<_CaseChip> createState() => _CaseChipState();
}

class _CaseChipState extends State<_CaseChip> {
  bool _selected = false;

  @override
  Widget build(BuildContext context) {
    final selected = _selected;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () {
          HapticService.trigger(HapticLevel.light);
          setState(() => _selected = !_selected);
        },
        child: AnimatedContainer(
          duration: AppMotion.normal,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppColors.brand500 : AppColors.bgElevated,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: selected ? AppColors.brand500 : AppColors.border),
          ),
          child: Text(widget.label, style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: selected ? Colors.white : AppColors.textMedium,
          )),
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
            Text('${initial.round()}', style: AppTypography.bodySm),
          ],
        ),
        Slider(value: initial, min: min, max: max, onChanged: (_) {}),
      ],
    );
  }
}
