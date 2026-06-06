import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_motion.dart';
import '../../services/haptic_service.dart';
import '../../widgets/common/app_bottom_sheet.dart';

class FilterPickerSheet extends StatelessWidget {
  const FilterPickerSheet({super.key});

  static const _categories = ['Vintage', 'Mood', 'Cinematic', 'B&W', 'Film', 'Artistic'];

  static const _filters = [
    ('Nostalgia', Color(0xFFD4A574)),
    ('Retro', Color(0xFFE8B88A)),
    ('Sepia', Color(0xFF704214)),
    ('Golden', Color(0xFFD4AF37)),
    ('Melancholy', Color(0xFF6B7B8D)),
    ('Dark Romance', Color(0xFF4A2040)),
    ('Blockbuster', Color(0xFF2D5A27)),
    ('Noir', Color(0xFF1A1A2E)),
    ('Teal & Orange', Color(0xFFE87A5D)),
    ('Fade', Color(0xFFD4C5B5)),
    ('Kodak', Color(0xFFC41E3A)),
    ('Fuji', Color(0xFF00A1C9)),
  ];

  static void show(BuildContext context) {
    AppBottomSheet.show(
      context: context,
      title: 'Filters',
      icon: Icons.filter_vintage,
      body: const FilterPickerSheet(),
      maxHeightFactor: 0.92,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _categories.map((c) => _CategoryChip(label: c)).toList(),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _filters.map((f) => _FilterThumbnail(color: f.$2, label: f.$1)).toList(),
            ),
          ),
          const SizedBox(height: 20),
          Text('Intensity', style: AppTypography.label),
          Row(
            children: [
              const Text('0%', style: AppTypography.bodySm),
              Expanded(
                child: Slider(value: 75, min: 0, max: 100, divisions: 100, onChanged: (_) {}),
              ),
              const Text('100%', style: AppTypography.bodySm),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _ToggleChip('Compare', Icons.compare),
              const SizedBox(width: 8),
              _ToggleChip('Favorite', Icons.favorite_border),
              const Spacer(),
              TextButton(
                onPressed: () => HapticService.trigger(HapticLevel.light),
                child: const Text('Reset', style: TextStyle(color: AppColors.textLow)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                HapticService.trigger(HapticLevel.light);
                Navigator.pop(context);
              },
              child: const Text('Apply Filter'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatefulWidget {
  final String label;
  const _CategoryChip({required this.label});

  @override
  State<_CategoryChip> createState() => _CategoryChipState();
}

class _CategoryChipState extends State<_CategoryChip> {
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? AppColors.brand500 : AppColors.bgElevated,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(widget.label, style: TextStyle(
            fontSize: 12, fontWeight: FontWeight.w500,
            color: selected ? Colors.white : AppColors.textMedium,
          )),
        ),
      ),
    );
  }
}

class _FilterThumbnail extends StatelessWidget {
  final Color color;
  final String label;
  const _FilterThumbnail({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: () => HapticService.trigger(HapticLevel.light),
        child: Column(
          children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: color.withValues(alpha: 0.5)),
              ),
              child: Center(
                child: Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMedium)),
          ],
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
