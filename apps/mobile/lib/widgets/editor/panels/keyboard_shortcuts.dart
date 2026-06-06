import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/app_motion.dart';
import '../../../services/haptic_service.dart';

class KeyboardShortcuts extends StatelessWidget {
  final AnimationController staggerController;
  const KeyboardShortcuts({super.key, required this.staggerController});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgElevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildSearchBar(),
          const Divider(height: 0.5, color: AppColors.border),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildCategory('Playback', [
                  _Shortcut('Space', 'Play/Pause'),
                  _Shortcut('K', 'Toggle Play/Pause'),
                  _Shortcut('J', 'Reverse'),
                  _Shortcut('L', 'Forward'),
                ]),
                _buildCategory('Editing', [
                  _Shortcut('S', 'Split Clip'),
                  _Shortcut('D', 'Duplicate Clip'),
                  _Shortcut('⌘+Z', 'Undo'),
                  _Shortcut('⌘+⇧+Z', 'Redo'),
                ]),
                _buildCategory('Navigation', [
                  _Shortcut('←', 'Previous Frame'),
                  _Shortcut('→', 'Next Frame'),
                  _Shortcut('↑', 'Previous Clip'),
                  _Shortcut('↓', 'Next Clip'),
                ]),
                _buildCategory('Timeline', [
                  _Shortcut('I', 'Set In Point'),
                  _Shortcut('O', 'Set Out Point'),
                  _Shortcut('A', 'Select All'),
                  _Shortcut('T', 'Trim Mode'),
                ]),
                _buildCategory('Tools', [
                  _Shortcut('V', 'Selection Tool'),
                  _Shortcut('B', 'Blade Tool'),
                  _Shortcut('X', 'Split Tool'),
                ]),
                _buildBottomBar(),
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
      child: const Text('Keyboard Shortcuts', style: AppTypography.titleSm),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(color: AppColors.bgSurface, borderRadius: BorderRadius.circular(6), border: Border.all(color: AppColors.border)),
        child: const Row(
          children: [
            Icon(Icons.search, size: 14, color: AppColors.textLow),
            SizedBox(width: 6),
            Expanded(
              child: TextField(
                style: TextStyle(fontSize: 12, color: AppColors.textHigh),
                decoration: InputDecoration.collapsed(hintText: 'Search shortcuts...', hintStyle: TextStyle(color: AppColors.textLow)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategory(String title, List<_Shortcut> shortcuts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5))),
          child: Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textLow, letterSpacing: 0.5)),
        ),
        ...shortcuts.map((s) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5))),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: AppColors.bgSurface, borderRadius: BorderRadius.circular(4), border: Border.all(color: AppColors.borderLight)),
                child: Text(s.key, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textHigh, fontFamily: 'JetBrainsMono')),
              ),
              const SizedBox(width: 12),
              Text(s.description, style: const TextStyle(fontSize: 12, color: AppColors.textMedium)),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.border))),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => HapticService.trigger(HapticLevel.light),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: AppColors.bgSurface, borderRadius: BorderRadius.circular(6), border: Border.all(color: AppColors.border)),
              child: const Row(
                children: [
                  Icon(Icons.devices, size: 12, color: AppColors.textMedium),
                  SizedBox(width: 4),
                  Text('iOS', style: TextStyle(fontSize: 10, color: AppColors.textMedium)),
                  Icon(Icons.arrow_drop_down, size: 14, color: AppColors.textLow),
                ],
              ),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => HapticService.trigger(HapticLevel.light),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: AppColors.bgSurface, borderRadius: BorderRadius.circular(6), border: Border.all(color: AppColors.border)),
              child: const Text('Customize', style: TextStyle(fontSize: 10, color: AppColors.textMedium)),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => HapticService.trigger(HapticLevel.light),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: AppColors.bgSurface, borderRadius: BorderRadius.circular(6), border: Border.all(color: AppColors.border)),
              child: const Text('Reset', style: TextStyle(fontSize: 10, color: AppColors.textMedium)),
            ),
          ),
        ],
      ),
    );
  }
}

class _Shortcut {
  final String key;
  final String description;
  const _Shortcut(this.key, this.description);
}
