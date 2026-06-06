import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_motion.dart';
import '../../services/haptic_service.dart';
import '../../widgets/common/app_bottom_sheet.dart';

class EmojiPickerSheet extends StatelessWidget {
  const EmojiPickerSheet({super.key});

  static const _categories = ['Smileys', 'People', 'Animals', 'Food', 'Travel', 'Activities', 'Objects', 'Symbols', 'Flags'];

  static const _emojis = [
    '😀', '😂', '🤣', '😊', '😍', '🥰', '😎', '🤩', '😜', '🤪', '😇', '🥳',
    '😏', '😒', '😢', '😭', '🤔', '🙄', '😴', '🤗', '🤭', '😱', '🥺', '😤',
    '👍', '👎', '👊', '✌️', '🤞', '👋', '🖐️', '✋', '👌', '🤏', '💪', '🦶',
    '🐶', '🐱', '🐭', '🐹', '🐰', '🦊', '🐻', '🐼', '🐨', '🐯', '🦁', '🐮',
    '🍎', '🍐', '🍊', '🍋', '🍌', '🍉', '🍇', '🍓', '🫐', '🍈', '🍒', '🍑',
    '🚗', '🚕', '🚙', '🚌', '🚎', '🏎️', '🚓', '🚑', '🚒', '🚐', '🛴', '🚲',
    '⚽', '🏀', '🏈', '⚾', '🎾', '🏐', '🎱', '🏓', '🎳', '⛳', '🏄', '🚴',
    '⌚', '📱', '💻', '⌨️', '🖥️', '🖨️', '🖱️', '💿', '📀', '📷', '📹', '🔋',
    '❤️', '🧡', '💛', '💚', '💙', '💜', '🖤', '🤍', '💯', '🔥', '⭐', '✨',
    '🏁', '🚩', '🎌', '🏴', '🏳️', '🇺🇸', '🇬🇧', '🇯🇵', '🇰🇷', '🇩🇪', '🇫🇷', '🇮🇹',
  ];

  static void show(BuildContext context) {
    AppBottomSheet.show(
      context: context,
      title: 'Emoji',
      icon: Icons.emoji_emotions_outlined,
      body: const EmojiPickerSheet(),
      maxHeightFactor: 0.95,
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
                hintText: 'Search emoji...',
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
            children: _categories.map((c) => _CategoryTab(label: c)).toList(),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text('Recently Used', style: AppTypography.label),
              const Spacer(),
              const Text('😀', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 4),
              const Text('😂', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 4),
              const Text('❤️', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 4),
              const Text('👍', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 4),
              const Text('🔥', style: TextStyle(fontSize: 20)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 8,
              childAspectRatio: 1,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: _emojis.length,
            itemBuilder: (_, i) => GestureDetector(
              onTap: () => HapticService.trigger(HapticLevel.light),
              child: Container(
                alignment: Alignment.center,
                child: Text(_emojis[i], style: const TextStyle(fontSize: 24)),
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
                child: Slider(value: 24, min: 12, max: 48, onChanged: (_) {}),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.bgElevated,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Text('24', style: AppTypography.bodySm),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CategoryTab extends StatefulWidget {
  final String label;
  const _CategoryTab({required this.label});

  @override
  State<_CategoryTab> createState() => _CategoryTabState();
}

class _CategoryTabState extends State<_CategoryTab> {
  bool _selected = false;

  @override
  Widget build(BuildContext context) {
    final selected = _selected;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: () {
          HapticService.trigger(HapticLevel.light);
          setState(() => _selected = !_selected);
        },
        child: AnimatedContainer(
          duration: AppMotion.normal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? AppColors.brand500.withValues(alpha: 0.15) : AppColors.bgElevated,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: selected ? AppColors.brand500 : AppColors.border),
          ),
          child: Text(widget.label, style: TextStyle(
            fontSize: 12,
            color: selected ? AppColors.textHigh : AppColors.textMedium,
          )),
        ),
      ),
    );
  }
}
