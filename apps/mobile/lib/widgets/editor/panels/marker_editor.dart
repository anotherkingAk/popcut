import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../services/haptic_service.dart';

class MarkerEditor extends StatelessWidget {
  final AnimationController staggerController;
  const MarkerEditor({super.key, required this.staggerController});

  final _markerColors = const [
    AppColors.textMedium, AppColors.textMedium, AppColors.textMedium, AppColors.textMedium,
    AppColors.textMedium, AppColors.textMedium, AppColors.textMedium, AppColors.textMedium,
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
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildTimelineStrip(),
                _buildAddMarkerButton(),
                const SizedBox(height: 8),
                ...List.generate(4, (i) => _buildMarkerItem(i)),
                const SizedBox(height: 8),
                _buildSettings(),
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
      child: const Row(
        children: [
          Text('Markers', style: AppTypography.titleSm),
          Spacer(),
          Text('4 markers', style: TextStyle(fontSize: 11, color: AppColors.textLow)),
        ],
      ),
    );
  }

  Widget _buildTimelineStrip() {
    return Container(
      height: 40,
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.timelineBg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.timelineGrid),
      ),
      child: Stack(
        children: [
          Center(
            child: Row(
              children: List.generate(20, (i) => Expanded(
                child: Container(
                  height: 1,
                  color: i % 5 == 0 ? AppColors.timelineGrid : Colors.transparent,
                ),
              )),
            ),
          ),
          for (int i = 0; i < 4; i++)
            Positioned(
              left: 20 + i * 60.0,
              top: 12,
              child: Icon(Icons.diamond, size: 16, color: _markerColors[i]),
            ),
        ],
      ),
    );
  }

  Widget _buildAddMarkerButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GestureDetector(
        onTap: () => HapticService.trigger(HapticLevel.light),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.brand500.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.brand500.withValues(alpha: 0.3)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, size: 14, color: AppColors.brand500),
              SizedBox(width: 6),
              Text('Add Marker at Playhead', style: TextStyle(fontSize: 11, color: AppColors.brand500, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMarkerItem(int index) {
    final names = ['Intro', 'Verse 1', 'Chorus', 'Drop'];
    final times = ['0:00', '0:15', '0:32', '0:48'];
    return GestureDetector(
      onTap: () => HapticService.trigger(HapticLevel.light),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5))),
        child: Row(
          children: [
            Container(
              width: 12, height: 12,
              decoration: BoxDecoration(              color: _markerColors[index], borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(names[index], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textHigh)),
                  Text('Duration: 2.0s', style: const TextStyle(fontSize: 10, color: AppColors.textLow)),
                ],
              ),
            ),
            Text(times[index], style: const TextStyle(fontSize: 11, color: AppColors.textMedium)),
            const SizedBox(width: 8),
            const Icon(Icons.color_lens, size: 14, color: AppColors.textLow),
          ],
        ),
      ),
    );
  }

  Widget _buildSettings() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.border))),
      child: Column(
        children: [
          _buildToggleRow('Snap to Marker', true),
          _buildToggleRow('Export Markers', false),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => HapticService.trigger(HapticLevel.light),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.bgSurface, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
              child: const Center(child: Text('Delete All Markers', style: TextStyle(fontSize: 12, color: AppColors.error))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow(String label, bool value) {
    return Row(
      children: [
        Text(label, style: AppTypography.bodySm),
        const Spacer(),
        Switch(value: value, onChanged: (_) => HapticService.trigger(HapticLevel.light)),
      ],
    );
  }
}
