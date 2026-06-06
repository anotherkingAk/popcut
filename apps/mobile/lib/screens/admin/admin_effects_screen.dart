import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/haptic_service.dart';

class AdminEffectsScreen extends StatelessWidget {
  final VoidCallback onBack;
  const AdminEffectsScreen({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () { HapticService.trigger(HapticLevel.light); onBack(); }),
        title: const Text('Effects Manager'),
        actions: [IconButton(icon: const Icon(Icons.add), onPressed: () { HapticService.trigger(HapticLevel.light); })],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 10,
        itemBuilder: (context, i) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
          child: Row(
            children: [
              Container(width: 44, height: 44, decoration: BoxDecoration(color: _colors[i % _colors.length].withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
                child: Icon(_icons[i % _icons.length], size: 20, color: _colors[i % _colors.length])),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Effect ${i+1}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)),
                    Text('${100 + i * 50}KB · ${_categories[i % _categories.length]}', style: const TextStyle(fontSize: 11, color: AppColors.foregroundSecondary)),
                  ],
                ),
              ),
              Switch(value: i % 3 != 0, onChanged: (_) { HapticService.trigger(HapticLevel.selection); }, activeThumbColor: AppColors.constructive, inactiveThumbColor: AppColors.foregroundMuted),
            ],
          ),
        ),
      ),
    );
  }
}

final _colors = [AppColors.primary, AppColors.trackText, AppColors.trackAudio, AppColors.trackGraphic, AppColors.caution];
final _icons = [Icons.blur_on, Icons.flash_on, Icons.grain, Icons.auto_awesome, Icons.color_lens];
final _categories = ['Blur', 'Glitch', 'Grain', 'Light', 'Color'];
