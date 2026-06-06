import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../services/haptic_service.dart';

class CompoundClipPanel extends StatelessWidget {
  final AnimationController staggerController;
  const CompoundClipPanel({super.key, required this.staggerController});

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
                _buildSelectionInfo(),
                const SizedBox(height: 12),
                _buildCreateButton(),
                const SizedBox(height: 20),
                _buildCompoundClipInfo(),
                const SizedBox(height: 16),
                _buildThumbnailStrip(),
                const SizedBox(height: 16),
                _buildActionButtons(),
                const SizedBox(height: 16),
                _buildToggleRow('Lock Compound Clip', false),
                const SizedBox(height: 16),
                _buildColorLabelSelector(),
                const SizedBox(height: 16),
                _buildBlendModeDropdown(),
                const SizedBox(height: 16),
                _buildLabeledSlider('Opacity', 100, 0, 100),
                const SizedBox(height: 16),
                _buildPreviewInfo(),
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
          Icon(Icons.folder, size: 14, color: AppColors.textMedium),
          SizedBox(width: 8),
          Text('Compound Clip', style: AppTypography.titleSm),
          Spacer(),
          Text('3 clips', style: TextStyle(fontSize: 11, color: AppColors.textLow)),
        ],
      ),
    );
  }

  Widget _buildSelectionInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        children: [
          Icon(Icons.checklist, size: 16, color: AppColors.brand500),
          SizedBox(width: 10),
          Text('3 clips selected', style: TextStyle(fontSize: 13, color: AppColors.textHigh, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildCreateButton() {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: () {
          HapticService.trigger(HapticLevel.medium);
        },
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
              Icon(Icons.merge_type, size: 16, color: AppColors.brand500),
              SizedBox(width: 8),
              Text('Create Compound Clip', style: TextStyle(fontSize: 12, color: AppColors.brand500, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompoundClipInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.folder_open, size: 16, color: AppColors.brand500),
              const SizedBox(width: 10),
              const Text('Compound Clip 1', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textHigh)),
            ],
          ),
          const SizedBox(height: 8),
          _buildInfoRow('Clips inside', '3'),
          const SizedBox(height: 4),
          _buildInfoRow('Duration', '12.5s'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textLow)),
        const Spacer(),
        Text(value, style: const TextStyle(fontSize: 11, color: AppColors.textMedium)),
      ],
    );
  }

  Widget _buildThumbnailStrip() {
    final colors = [AppColors.brand500, AppColors.trackAudio, AppColors.trackText];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Thumbnails', style: AppTypography.bodySm),
        const SizedBox(height: 6),
        SizedBox(
          height: 40,
          child: Row(
            children: List.generate(3, (i) => Expanded(
              child: Container(
                margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
                decoration: BoxDecoration(
                  color: colors[i].withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.border),
                ),
              ),
            )),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: GestureDetector(
            onTap: () => HapticService.trigger(HapticLevel.light),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.subdirectory_arrow_right, size: 14, color: AppColors.textMedium),
                  SizedBox(width: 6),
                  Text('Open Inside', style: TextStyle(fontSize: 11, color: AppColors.textMedium)),
                  SizedBox(width: 6),
                  Text('placeholder', style: TextStyle(fontSize: 9, color: AppColors.textLow, fontStyle: FontStyle.italic)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: GestureDetector(
            onTap: () => HapticService.trigger(HapticLevel.heavy),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.link_off, size: 14, color: AppColors.error),
                  SizedBox(width: 6),
                  Text('Unlink / Ungroup', style: TextStyle(fontSize: 11, color: AppColors.error)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: GestureDetector(
            onTap: () => HapticService.trigger(HapticLevel.light),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.unfold_more, size: 14, color: AppColors.textMedium),
                  SizedBox(width: 6),
                  Text('Extract All', style: TextStyle(fontSize: 11, color: AppColors.textMedium)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleRow(String label, bool value) {
    return Row(
      children: [
        Icon(Icons.lock_outline, size: 14, color: AppColors.textLow),
        const SizedBox(width: 8),
        Text(label, style: AppTypography.bodySm),
        const Spacer(),
        Switch(value: value, onChanged: (_) => HapticService.trigger(HapticLevel.light)),
      ],
    );
  }

  Widget _buildColorLabelSelector() {
    final colors = [
      AppColors.textHigh,
      AppColors.error,
      const Color(0xFFFFAA00),
      const Color(0xFF44DD44),
      const Color(0xFF4488FF),
      const Color(0xFFAA44FF),
      const Color(0xFFFF66AA),
      const Color(0xFF555555),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Color Label', style: AppTypography.bodySm),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: colors.map((c) => GestureDetector(
            onTap: () => HapticService.trigger(HapticLevel.light),
            child: Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: c,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderLight, width: 2),
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildBlendModeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Blend Mode', style: AppTypography.bodySm),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: const Row(
            children: [
              Text('Normal', style: TextStyle(fontSize: 12, color: AppColors.textMedium)),
              Spacer(),
              Icon(Icons.arrow_drop_down, size: 16, color: AppColors.textLow),
            ],
          ),
        ),
      ],
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
            trackHeight: 3,
            activeTrackColor: AppColors.brand500,
            inactiveTrackColor: AppColors.timelineGrid,
            thumbColor: AppColors.brand500,
          ),
          child: Slider(value: value, min: min, max: max, onChanged: (_) => HapticService.trigger(HapticLevel.light)),
        ),
      ],
    );
  }

  Widget _buildPreviewInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.brand500.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, size: 14, color: AppColors.brand500),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'This compound clip contains 3 video clips and 1 audio track',
              style: TextStyle(fontSize: 11, color: AppColors.textMedium, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
