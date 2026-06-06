import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/app_motion.dart';
import '../../../services/haptic_service.dart';

class ProjectSettings extends StatelessWidget {
  final AnimationController staggerController;
  const ProjectSettings({super.key, required this.staggerController});

  static const _resolutions = ['4K', '1080p', '720p', '480p'];
  static const _frameRates = ['24', '25', '30', '48', '50', '60'];
  static const _aspectRatios = ['16:9', '9:16', '1:1', '4:3', '21:9'];

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
                _buildNameField(),
                const SizedBox(height: 16),
                _buildSelector('Resolution', _resolutions, 1),
                const SizedBox(height: 16),
                _buildSelector('Frame Rate', _frameRates, 1),
                const SizedBox(height: 16),
                _buildSelector('Aspect Ratio', _aspectRatios, 0),
                const SizedBox(height: 16),
                _buildBackgroundColor(),
                const SizedBox(height: 16),
                _buildDefaultDuration(),
                const SizedBox(height: 16),
                _buildToggleRow('Auto-Save', true),
                const SizedBox(height: 16),
                _buildThumbnailSelector(),
                const SizedBox(height: 24),
                _buildResetButton(),
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
      child: const Text('Project Settings', style: AppTypography.titleSm),
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Project Name', style: AppTypography.bodySm),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: AppColors.bgSurface, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
          child: const TextField(
            style: TextStyle(fontSize: 13, color: AppColors.textHigh),
            decoration: InputDecoration.collapsed(hintText: 'My Project', hintStyle: TextStyle(color: AppColors.textLow)),
          ),
        ),
      ],
    );
  }

  Widget _buildSelector(String label, List<String> items, int selected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.bodySm),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: items.asMap().entries.map((e) => GestureDetector(
            onTap: () => HapticService.trigger(HapticLevel.light),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: e.key == selected ? AppColors.brand500.withValues(alpha: 0.15) : AppColors.bgSurface,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: e.key == selected ? AppColors.brand500 : AppColors.border),
              ),
              child: Text(e.value, style: TextStyle(fontSize: 12, color: e.key == selected ? AppColors.brand500 : AppColors.textMedium)),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildBackgroundColor() {
    return Row(
      children: [
        const Text('Background', style: AppTypography.bodySm),
        const Spacer(),
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(6), border: Border.all(color: AppColors.borderLight)),
        ),
        const SizedBox(width: 8),
        const Text('#000000', style: TextStyle(fontSize: 12, color: AppColors.textMedium)),
      ],
    );
  }

  Widget _buildDefaultDuration() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Default Clip Duration', style: AppTypography.bodySm),
        const SizedBox(height: 6),
        Row(
          children: [
            GestureDetector(
              onTap: () => HapticService.trigger(HapticLevel.light),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: AppColors.brand500.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6), border: Border.all(color: AppColors.brand500)),
                child: const Text('3.0s', style: TextStyle(fontSize: 12, color: AppColors.brand500)),
              ),
            ),
            const Spacer(),
            const Text('5.0s', style: TextStyle(fontSize: 11, color: AppColors.textMedium)),
          ],
        ),
      ],
    );
  }

  Widget _buildThumbnailSelector() {
    return Row(
      children: [
        const Text('Project Thumbnail', style: AppTypography.bodySm),
        const Spacer(),
        GestureDetector(
          onTap: () => HapticService.trigger(HapticLevel.light),
          child: Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: AppColors.bgSurface, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
            child: const Icon(Icons.image, size: 20, color: AppColors.textLow),
          ),
        ),
      ],
    );
  }

  Widget _buildResetButton() {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: () => HapticService.trigger(HapticLevel.light),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
          ),
          child: const Center(
            child: Text('Reset Settings', style: TextStyle(fontSize: 13, color: AppColors.error, fontWeight: FontWeight.w600)),
          ),
        ),
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
