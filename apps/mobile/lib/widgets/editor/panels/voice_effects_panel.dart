import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/app_motion.dart';
import '../../../services/haptic_service.dart';

class VoiceEffectsPanel extends StatelessWidget {
  final AnimationController staggerController;
  const VoiceEffectsPanel({super.key, required this.staggerController});

  final _presets = const [
    _EffectPreset('Robot', Icons.android),
    _EffectPreset('Helium', Icons.air),
    _EffectPreset('Deep', Icons.speaker),
    _EffectPreset('Echo', Icons.repeat),
    _EffectPreset('Reverb', Icons.music_video),
    _EffectPreset('Chorus', Icons.group),
    _EffectPreset('Flanger', Icons.waves),
    _EffectPreset('Megaphone', Icons.volume_up),
    _EffectPreset('Radio', Icons.radio),
    _EffectPreset('Underwater', Icons.water),
    _EffectPreset('Chipmunk', Icons.pets),
    _EffectPreset('Giant', Icons.gavel),
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
              padding: const EdgeInsets.all(16),
              children: [
                _buildPresetGrid(),
                const SizedBox(height: 16),
                _buildLabeledSlider('Intensity', 50, 0, 100),
                const SizedBox(height: 12),
                _buildLabeledSlider('Dry/Wet Mix', 50, 0, 100),
                const SizedBox(height: 16),
                _buildPreviewButton(),
                const SizedBox(height: 12),
                _buildFineTuneControls(),
                const SizedBox(height: 16),
                _buildSavePresetButton(),
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
      child: const Text('Voice Effects', style: AppTypography.titleSm),
    );
  }

  Widget _buildPresetGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.9,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _presets.length,
      itemBuilder: (_, i) => GestureDetector(
        onTap: () => HapticService.trigger(HapticLevel.light),
        child: Container(
          decoration: BoxDecoration(
            color: i == 0 ? AppColors.brand500.withValues(alpha: 0.15) : AppColors.bgSurface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: i == 0 ? AppColors.brand500 : AppColors.border),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_presets[i].icon, size: 22, color: i == 0 ? AppColors.brand500 : AppColors.textMedium),
              const SizedBox(height: 4),
              Text(_presets[i].name, style: TextStyle(fontSize: 9, color: i == 0 ? AppColors.brand500 : AppColors.textLow)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFineTuneControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Fine-Tune', style: AppTypography.bodySm),
        const SizedBox(height: 8),
        _buildFineSlider('Pitch Shift', 0, -12, 12),
        _buildFineSlider('Formant', 50, 0, 100),
        _buildFineSlider('Modulation', 30, 0, 100),
      ],
    );
  }

  Widget _buildFineSlider(String label, double value, double min, double max) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMedium)),
            const Spacer(),
            Text('${value.toInt()}', style: const TextStyle(fontSize: 11, color: AppColors.textHigh)),
          ],
        ),
        SliderTheme(
          data: const SliderThemeData(
            trackHeight: 2, activeTrackColor: AppColors.brand500, inactiveTrackColor: AppColors.timelineGrid, thumbColor: AppColors.brand500,
          ),
          child: Slider(value: value, min: min, max: max, onChanged: (_) => HapticService.trigger(HapticLevel.light)),
        ),
      ],
    );
  }

  Widget _buildPreviewButton() {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: () => HapticService.trigger(HapticLevel.light),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.brand500.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.brand500),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.play_arrow, size: 16, color: AppColors.brand500),
              SizedBox(width: 6),
              Text('Preview', style: TextStyle(fontSize: 12, color: AppColors.brand500, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSavePresetButton() {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: () => HapticService.trigger(HapticLevel.light),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.save, size: 14, color: AppColors.textMedium),
              SizedBox(width: 6),
              Text('Save as Preset', style: TextStyle(fontSize: 12, color: AppColors.textMedium)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabeledSlider(String label, double value, double min, double max) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: AppTypography.bodySm),
            const Spacer(),
            Text('${value.toInt()}%', style: const TextStyle(fontSize: 12, color: AppColors.textHigh)),
          ],
        ),
        SliderTheme(
          data: const SliderThemeData(
            trackHeight: 3, activeTrackColor: AppColors.brand500, inactiveTrackColor: AppColors.timelineGrid, thumbColor: AppColors.brand500,
          ),
          child: Slider(value: value, min: min, max: max, onChanged: (_) => HapticService.trigger(HapticLevel.light)),
        ),
      ],
    );
  }
}

class _EffectPreset {
  final String name;
  final IconData icon;
  const _EffectPreset(this.name, this.icon);
}
