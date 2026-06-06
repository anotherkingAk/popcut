import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/app_motion.dart';
import '../../../services/haptic_service.dart';

class FilterPanel extends StatelessWidget {
  final AnimationController staggerController;
  const FilterPanel({super.key, required this.staggerController});

  final _filters = const [
    _FilterDef('Normal', null),
    _FilterDef('Bright', null),
    _FilterDef('Cinematic', null),
    _FilterDef('Moody', null),
    _FilterDef('Vintage', null),
    _FilterDef('Noir', null),
    _FilterDef('Warm', null),
    _FilterDef('Cool', null),
    _FilterDef('Dramatic', null),
    _FilterDef('Fade', null),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgElevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          Expanded(
            child: Column(
              children: [
                _buildFilterStrip(),
                const Divider(height: 0.5, color: AppColors.border),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Intensity', style: AppTypography.bodySm),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: AppColors.brand500,
                            inactiveTrackColor: AppColors.timelineGrid,
                            thumbColor: AppColors.brand500,
                          ),
                          child: Slider(value: 75, min: 0, max: 100, onChanged: (_) {}),
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _ActionBtn(Icons.compare, 'Compare'),
                            _ActionBtn(Icons.refresh, 'Reset'),
                            _ActionBtn(Icons.tune, 'Custom'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
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
      child: const Text('Filters', style: AppTypography.titleSm),
    );
  }

  Widget _buildFilterStrip() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(8),
        itemCount: _filters.length,
        itemBuilder: (_, i) => Container(
          width: 64,
          margin: const EdgeInsets.only(right: 8),
          child: Column(
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  color: i == 0 ? AppColors.brand500.withValues(alpha: 0.2) : AppColors.bgSurface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: i == 0 ? AppColors.brand500 : AppColors.border, width: i == 0 ? 2 : 1),
                ),
                child: Center(child: Icon(Icons.filter_vintage, size: 22, color: i == 0 ? AppColors.brand500 : AppColors.textLow)),
              ),
              const SizedBox(height: 4),
              Text(_filters[i].name, style: TextStyle(fontSize: 9, color: i == 0 ? AppColors.brand500 : AppColors.textLow)),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterDef {
  final String name;
  final Color? color;
  const _FilterDef(this.name, this.color);
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  const _ActionBtn(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () { HapticService.trigger(HapticLevel.light); },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.textMedium),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMedium)),
          ],
        ),
      ),
    );
  }
}
