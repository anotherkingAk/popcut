import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/app_motion.dart';
import '../../../services/haptic_service.dart';

class TrackMenu extends StatelessWidget {
  final AnimationController staggerController;
  const TrackMenu({super.key, required this.staggerController});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgElevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTrackInfo(),
                const SizedBox(height: 16),
                _buildRenameField(),
                const SizedBox(height: 16),
                _buildTrackSettings(),
                const SizedBox(height: 16),
                _buildTrackActions(),
                const SizedBox(height: 16),
                _buildDeleteButton(),
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
      child: const Text('Track Settings', style: AppTypography.titleSm),
    );
  }

  Widget _buildTrackInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        children: [
          Icon(Icons.videocam, size: 20, color: AppColors.trackVideo),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Video 1', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textHigh)),
              Text('Video Track · 5 clips · 2:30', style: TextStyle(fontSize: 11, color: AppColors.textLow)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRenameField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: const TextField(
        style: TextStyle(fontSize: 13, color: AppColors.textHigh),
        decoration: InputDecoration.collapsed(hintText: 'Rename track...', hintStyle: TextStyle(color: AppColors.textLow)),
      ),
    );
  }

  Widget _buildTrackSettings() {
    return Column(
      children: [
        _buildSettingRow('Visible', Icons.visibility, true),
        const SizedBox(height: 8),
        _buildSettingRow('Locked', Icons.lock_outline, false),
        const SizedBox(height: 8),
        _buildSettingRow('Solo', Icons.headphones, false),
        const SizedBox(height: 8),
        _buildSettingRow('Mute', Icons.volume_off, false),
      ],
    );
  }

  Widget _buildSettingRow(String label, IconData icon, bool value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textMedium),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textHigh)),
        const Spacer(),
        Switch(value: value, onChanged: (_) => HapticService.trigger(HapticLevel.light)),
      ],
    );
  }

  Widget _buildTrackActions() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => HapticService.trigger(HapticLevel.light),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(color: AppColors.bgSurface, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.arrow_upward, size: 14, color: AppColors.textMedium),
                  SizedBox(width: 4),
                  Text('Move Up', style: TextStyle(fontSize: 11, color: AppColors.textMedium)),
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
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(color: AppColors.bgSurface, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.arrow_downward, size: 14, color: AppColors.textMedium),
                  SizedBox(width: 4),
                  Text('Move Down', style: TextStyle(fontSize: 11, color: AppColors.textMedium)),
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
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(color: AppColors.bgSurface, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, size: 14, color: AppColors.textMedium),
                  SizedBox(width: 4),
                  Text('Add Clip', style: TextStyle(fontSize: 11, color: AppColors.textMedium)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDeleteButton() {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: () => HapticService.trigger(HapticLevel.heavy),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.delete_outline, size: 16, color: AppColors.error),
              SizedBox(width: 8),
              Text('Delete Track', style: TextStyle(fontSize: 13, color: AppColors.error, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
