import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/app_motion.dart';
import '../../../services/haptic_service.dart';

class VoiceClonePanel extends StatelessWidget {
  final AnimationController staggerController;
  const VoiceClonePanel({super.key, required this.staggerController});

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
                _buildProfileGrid(),
                const SizedBox(height: 16),
                _buildAddProfileButton(),
                const SizedBox(height: 16),
                _buildTextField(),
                const SizedBox(height: 16),
                _buildLabeledSlider('Pitch', 0, -12, 12),
                const SizedBox(height: 12),
                _buildLabeledSlider('Speed', 1.0, 0.5, 2.0),
                const SizedBox(height: 12),
                _buildLabeledSlider('Warmth', 50, 0, 100),
                const SizedBox(height: 16),
                _buildActionButtons(),
                const SizedBox(height: 12),
                _buildCreditDisplay(),
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
      child: const Text('Voice Clone', style: AppTypography.titleSm),
    );
  }

  Widget _buildProfileGrid() {
    final profiles = ['Default Voice', 'Narrator', 'Character 1', 'Character 2'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Voice Profiles', style: AppTypography.bodySm),
        const SizedBox(height: 8),
        Row(
          children: profiles.asMap().entries.map((e) => Expanded(
            child: GestureDetector(
              onTap: () => HapticService.trigger(HapticLevel.light),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: e.key == 0 ? AppColors.brand500.withValues(alpha: 0.15) : AppColors.bgSurface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: e.key == 0 ? AppColors.brand500 : AppColors.border),
                ),
                child: Column(
                  children: [
                    Icon(Icons.person, size: 24, color: e.key == 0 ? AppColors.brand500 : AppColors.textMedium),
                    const SizedBox(height: 4),
                    Text(e.value, style: TextStyle(fontSize: 9, color: e.key == 0 ? AppColors.brand500 : AppColors.textLow), textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildAddProfileButton() {
    return GestureDetector(
      onTap: () => HapticService.trigger(HapticLevel.light),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border, style: BorderStyle.solid),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: 16, color: AppColors.textMedium),
            SizedBox(width: 8),
            Text('Add Voice Profile (Record)', style: TextStyle(fontSize: 12, color: AppColors.textMedium)),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: const TextField(
        style: TextStyle(fontSize: 13, color: AppColors.textHigh),
        decoration: InputDecoration.collapsed(hintText: 'Enter text for cloned voice...', hintStyle: TextStyle(color: AppColors.textLow)),
        maxLines: 3,
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
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
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: () => HapticService.trigger(HapticLevel.light),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.brand500,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text('Save Profile', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCreditDisplay() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.2)),
      ),
      child: const Row(
        children: [
          Icon(Icons.credit_card, size: 16, color: AppColors.warning),
          SizedBox(width: 8),
          Text('API Credits: ', style: TextStyle(fontSize: 11, color: AppColors.textMedium)),
          Text('245 remaining', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textHigh)),
        ],
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
            Text(value is int ? '${value.toInt()}' : value.toStringAsFixed(1), style: const TextStyle(fontSize: 12, color: AppColors.textHigh)),
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
