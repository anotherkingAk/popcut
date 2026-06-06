import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_motion.dart';
import '../../services/haptic_service.dart';
import '../../widgets/common/app_bottom_sheet.dart';

class StickerPackSheet extends StatelessWidget {
  const StickerPackSheet({super.key});

  static const _packs = ['Basic', 'Emoji', 'Celebration', 'Nature', 'Food', 'Travel', 'Sports', 'Custom'];

  static const _stickers = [
    '⭐', '❤️', '🔥', '💯', '✅', '❌', '🎯', '💪',
    '🎉', '🎊', '✨', '🌟', '🌈', '☀️', '🌙', '⚡',
    '👍', '👎', '👏', '🙌', '🤝', '✌️', '🎵', '💡',
  ];

  static void show(BuildContext context) {
    AppBottomSheet.show(
      context: context,
      title: 'Stickers',
      icon: Icons.emoji_emotions_outlined,
      body: const StickerPackSheet(),
      maxHeightFactor: 0.92,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.bgElevated,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: const TextField(
              style: AppTypography.bodyMd,
              decoration: InputDecoration(
                hintText: 'Search stickers...',
                hintStyle: TextStyle(color: AppColors.textLow, fontSize: 14),
                prefixIcon: Icon(Icons.search, size: 18, color: AppColors.textLow),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: _packs.map((p) => _PackChip(label: p)).toList(),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text('Recently Used', style: AppTypography.label),
              const Spacer(),
              ...['⭐', '❤️', '🔥', '💯'].map((s) => Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(s, style: const TextStyle(fontSize: 20)),
              )),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              childAspectRatio: 1,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
            ),
            itemCount: _stickers.length,
            itemBuilder: (_, i) => GestureDetector(
              onTap: () => HapticService.trigger(HapticLevel.light),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.bgElevated,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_stickers[i], style: const TextStyle(fontSize: 24)),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Text('Size', style: AppTypography.label),
              const SizedBox(width: 12),
              Expanded(
                child: Slider(value: 32, min: 16, max: 64, onChanged: (_) {}),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.bgElevated,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Text('32', style: AppTypography.bodySm),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PackChip extends StatefulWidget {
  final String label;
  const _PackChip({required this.label});

  @override
  State<_PackChip> createState() => _PackChipState();
}

class _PackChipState extends State<_PackChip> {
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
            border: Border.all(color: selected ? AppColors.brand500 : AppColors.border),
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
