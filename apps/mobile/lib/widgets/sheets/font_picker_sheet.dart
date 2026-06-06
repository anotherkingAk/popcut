import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_motion.dart';
import '../../services/haptic_service.dart';
import '../../widgets/common/app_bottom_sheet.dart';

class FontPickerSheet extends StatelessWidget {
  const FontPickerSheet({super.key});

  static const _fonts = [
    'Roboto', 'Open Sans', 'Lato', 'Montserrat', 'Poppins',
    'Playfair Display', 'Merriweather', 'Oswald', 'Raleway', 'Ubuntu',
    'Nunito', 'PT Sans', 'Quicksand', 'Work Sans', 'Rubik',
    'Inter', 'Manrope', 'DM Sans', 'Lexend', 'Sora',
  ];

  static void show(BuildContext context) {
    AppBottomSheet.show(
      context: context,
      title: 'Select Font',
      icon: Icons.text_fields,
      body: const FontPickerSheet(),
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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bgElevated,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Text('The quick brown fox', style: AppTypography.displaySm.copyWith(fontSize: 28)),
                const SizedBox(height: 4),
                Text('jumps over the lazy dog', style: AppTypography.bodyMd),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _ToggleChip(label: 'Bold', icon: Icons.format_bold),
                const SizedBox(width: 8),
                _ToggleChip(label: 'Italic', icon: Icons.format_italic),
                const SizedBox(width: 8),
                _ToggleChip(label: 'Underline', icon: Icons.format_underline),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('Size', style: AppTypography.label),
          Row(
            children: [
              const Text('24', style: AppTypography.bodyMd),
              Expanded(
                child: Slider(value: 24, min: 8, max: 120, onChanged: (_) {}),
              ),
              const Text('120', style: AppTypography.bodySm),
            ],
          ),
          const SizedBox(height: 12),
          Text('Font Family', style: AppTypography.label),
          const SizedBox(height: 8),
          ..._fonts.take(10).map((f) => _FontItem(name: f)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                HapticService.trigger(HapticLevel.light);
                Navigator.pop(context);
              },
              child: const Text('Apply'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleChip extends StatefulWidget {
  final String label;
  final IconData icon;
  const _ToggleChip({required this.label, required this.icon});

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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppColors.brand500.withValues(alpha: 0.15) : AppColors.bgElevated,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: active ? AppColors.brand500 : AppColors.border),
        ),
        child: Row(
          children: [
            Icon(widget.icon, size: 16, color: active ? AppColors.brand500 : AppColors.textMedium),
            const SizedBox(width: 4),
            Text(widget.label, style: TextStyle(fontSize: 12, color: active ? AppColors.textHigh : AppColors.textMedium)),
          ],
        ),
      ),
    );
  }
}

class _FontItem extends StatelessWidget {
  final String name;
  const _FontItem({required this.name});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: GestureDetector(
        onTap: () => HapticService.trigger(HapticLevel.light),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.bgElevated,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontSize: 16, color: AppColors.textHigh)),
                    const SizedBox(height: 2),
                    Text('AaBbCc 123', style: TextStyle(fontSize: 13, color: AppColors.textMedium)),
                  ],
                ),
              ),
              const Icon(Icons.radio_button_unchecked, size: 18, color: AppColors.textLow),
            ],
          ),
        ),
      ),
    );
  }
}
