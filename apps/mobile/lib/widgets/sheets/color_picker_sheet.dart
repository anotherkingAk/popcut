import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/haptic_service.dart';
import '../../widgets/common/app_bottom_sheet.dart';

class ColorPickerSheet extends StatelessWidget {
  const ColorPickerSheet({super.key});

  static const _recentColors = [
    Color(0xFFFFFFFF), Color(0xFFE74C3C), Color(0xFF3498DB), Color(0xFF2ECC71),
    Color(0xFFF39C12), Color(0xFF9B59B6), Color(0xFF1ABC9C), Color(0xFFE91E63),
  ];

  static const _presets = [
    Color(0xFF000000), Color(0xFF434343), Color(0xFF666666), Color(0xFF999999),
    Color(0xFFB8B8C8), Color(0xFFFFFFFF), Color(0xFFE74C3C), Color(0xFFE67E22),
    Color(0xFFF39C12), Color(0xFF2ECC71), Color(0xFF1ABC9C), Color(0xFF3498DB),
    Color(0xFF2980B9), Color(0xFF9B59B6), Color(0xFF8E44AD), Color(0xFFE91E63),
    Color(0xFFFF6B81), Color(0xFFFDA7DF), Color(0xFFB53471), Color(0xFF6C5CE7),
    Color(0xFFA29BFE), Color(0xFF00CEC9), Color(0xFF55E6C1), Color(0xFFFFC312),
  ];

  static void show(BuildContext context) {
    AppBottomSheet.show(
      context: context,
      title: 'Pick Color',
      icon: Icons.colorize,
      body: const ColorPickerSheet(),
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
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                colors: [Colors.black, Colors.white],
              ),
            ),
            child: Center(
              child: Container(
                width: 40, height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.brand500,
                  shape: BoxShape.circle,
                  border: Border.fromBorderSide(BorderSide(color: Colors.white, width: 3)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 24,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    gradient: const LinearGradient(colors: [Colors.red, Colors.yellow, Colors.green, Colors.cyan, Colors.blue, Colors.purple, Colors.red]),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text('Recent', style: AppTypography.label),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _recentColors.map((c) => _ColorSwatch(color: c)).toList(),
          ),
          const SizedBox(height: 20),
          Text('Presets', style: AppTypography.label),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _presets.map((c) => _ColorSwatch(color: c)).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.bgElevated,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const TextField(
                    style: TextStyle(fontSize: 14, color: AppColors.textHigh, fontFamily: 'JetBrainsMono'),
                    decoration: InputDecoration(
                      hintText: '#6C5CE7',
                      hintStyle: TextStyle(color: AppColors.textLow, fontSize: 14),
                      prefixIcon: Icon(Icons.tag, size: 16, color: AppColors.textLow),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: AppColors.bgElevated,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(Icons.colorize, size: 20, color: AppColors.textMedium),
              ),
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
              child: const Text('Apply'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  final Color color;
  const _ColorSwatch({required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => HapticService.trigger(HapticLevel.light),
      child: Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: color == AppColors.textHigh ? AppColors.border : Colors.transparent, width: 1.5),
        ),
      ),
    );
  }
}
