import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../services/haptic_service.dart';

class AddTrackSheet extends StatelessWidget {
  final AnimationController staggerController;
  const AddTrackSheet({super.key, required this.staggerController});

  static const _types = [
    _TrackTypeDef('Video', Icons.videocam, 'Add a video track for clips', AppColors.trackVideo),
    _TrackTypeDef('Audio', Icons.music_note, 'Add an audio track', AppColors.trackAudio),
    _TrackTypeDef('Text', Icons.text_fields, 'Add a text/title track', AppColors.trackText),
    _TrackTypeDef('Overlay', Icons.layers, 'Add an overlay track', AppColors.trackOverlay),
    _TrackTypeDef('Stickers', Icons.emoji_emotions, 'Add a stickers track', AppColors.trackGraphic),
    _TrackTypeDef('Effects', Icons.auto_fix_high, 'Add an effects track', AppColors.trackEffect),
  ];

  static const _positions = ['Above Active', 'Below Active', 'At Top', 'At Bottom'];
  static final _colors = [AppColors.trackVideo, AppColors.trackAudio, AppColors.trackText, AppColors.trackOverlay, AppColors.trackEffect, AppColors.trackGraphic];

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
                _buildTypeGrid(),
                const SizedBox(height: 16),
                _buildPositionSelector(),
                const SizedBox(height: 16),
                _buildColorLabelPicker(),
                const SizedBox(height: 16),
                _buildNameField(),
                const SizedBox(height: 16),
                _buildCreateButton(),
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
      child: const Text('Add Track', style: AppTypography.titleSm),
    );
  }

  Widget _buildTypeGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Track Type', style: AppTypography.bodySm),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _types.map((t) => GestureDetector(
              onTap: () => HapticService.trigger(HapticLevel.light),
              child: Container(
                width: (constraints.maxWidth - 16) / 3,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.bgSurface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: t.name == 'Video' ? t.color : AppColors.border),
                ),
                child: Column(
                  children: [
                    Icon(t.icon, size: 22, color: t.color),
                    const SizedBox(height: 6),
                    Text(t.name, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textHigh)),
                    Text(t.description, style: const TextStyle(fontSize: 8, color: AppColors.textLow), textAlign: TextAlign.center, maxLines: 2),
                  ],
                ),
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPositionSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Position', style: AppTypography.bodySm),
        const SizedBox(height: 8),
        Row(
          children: _positions.map((p) => Expanded(
            child: GestureDetector(
              onTap: () => HapticService.trigger(HapticLevel.light),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: p == 'Below Active' ? AppColors.brand500.withValues(alpha: 0.15) : AppColors.bgSurface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: p == 'Below Active' ? AppColors.brand500 : AppColors.border),
                ),
                child: Center(child: Text(p, style: TextStyle(fontSize: 9, color: p == 'Below Active' ? AppColors.brand500 : AppColors.textMedium))),
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildColorLabelPicker() {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Color Label', style: AppTypography.bodySm),
            const SizedBox(height: 8),
            Row(
              children: _colors.map((c) => GestureDetector(
                onTap: () => HapticService.trigger(HapticLevel.light),
                child: Container(
                  width: 24, height: 24,
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(color: c, shape: BoxShape.circle, border: Border.all(color: AppColors.borderLight)),
                ),
              )).toList(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNameField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: const TextField(
        style: TextStyle(fontSize: 13, color: AppColors.textHigh),
        decoration: InputDecoration.collapsed(hintText: 'Enter track name...', hintStyle: TextStyle(color: AppColors.textLow)),
      ),
    );
  }

  Widget _buildCreateButton() {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: () => HapticService.trigger(HapticLevel.light),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.brand500,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Center(
            child: Text('Create Track', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
          ),
        ),
      ),
    );
  }
}

class _TrackTypeDef {
  final String name;
  final IconData icon;
  final String description;
  final Color color;
  const _TrackTypeDef(this.name, this.icon, this.description, this.color);
}
