import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../services/haptic_service.dart';

class TextToVideoPanel extends StatelessWidget {
  final AnimationController staggerController;
  const TextToVideoPanel({super.key, required this.staggerController});

  static const _styles = ['Cinematic', 'Tutorial', 'Social Media', 'Vlog', 'Presentation', 'Music Video'];
  static const _models = ['Fast', 'Quality', 'Balanced'];

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
                _buildPromptInput(),
                const SizedBox(height: 16),
                _buildStyleChips(),
                const SizedBox(height: 12),
                _buildLabeledSlider('Duration', 15, 5, 60),
                const SizedBox(height: 16),
                _buildAspectRatioSelector(),
                const SizedBox(height: 16),
                _buildModelSelector(),
                const SizedBox(height: 16),
                _buildGenerateButton(),
                const SizedBox(height: 20),
                _buildRecentGenerations(),
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
      child: const Text('Text to Video', style: AppTypography.titleSm),
    );
  }

  Widget _buildPromptInput() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: const TextField(
        style: TextStyle(fontSize: 13, color: AppColors.textHigh),
        decoration: InputDecoration.collapsed(hintText: 'Describe the video you want to create...', hintStyle: TextStyle(color: AppColors.textLow)),
        maxLines: 4,
      ),
    );
  }

  Widget _buildStyleChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Style', style: AppTypography.bodySm),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: _styles.map((s) => GestureDetector(
            onTap: () => HapticService.trigger(HapticLevel.light),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: s == 'Cinematic' ? AppColors.brand500.withValues(alpha: 0.15) : AppColors.bgSurface,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: s == 'Cinematic' ? AppColors.brand500 : AppColors.border),
              ),
              child: Text(s, style: TextStyle(fontSize: 11, color: s == 'Cinematic' ? AppColors.brand500 : AppColors.textMedium)),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildAspectRatioSelector() {
    final ratios = ['16:9', '9:16', '1:1', '4:3'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Aspect Ratio', style: AppTypography.bodySm),
        const SizedBox(height: 6),
        Row(
          children: ratios.map((r) => Expanded(
            child: GestureDetector(
              onTap: () => HapticService.trigger(HapticLevel.light),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: r == '16:9' ? AppColors.brand500.withValues(alpha: 0.15) : AppColors.bgSurface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: r == '16:9' ? AppColors.brand500 : AppColors.border),
                ),
                child: Center(child: Text(r, style: TextStyle(fontSize: 11, color: r == '16:9' ? AppColors.brand500 : AppColors.textMedium))),
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildModelSelector() {
    return Row(
      children: _models.map((m) => Expanded(
        child: GestureDetector(
          onTap: () => HapticService.trigger(HapticLevel.light),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: m == 'Balanced' ? AppColors.brand500.withValues(alpha: 0.15) : AppColors.bgSurface,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: m == 'Balanced' ? AppColors.brand500 : AppColors.border),
            ),
            child: Column(
              children: [
                Text(m, style: TextStyle(fontSize: 11, color: m == 'Balanced' ? AppColors.brand500 : AppColors.textMedium, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(m == 'Fast' ? '3s' : m == 'Quality' ? '30s' : '10s', style: const TextStyle(fontSize: 8, color: AppColors.textLow)),
              ],
            ),
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildGenerateButton() {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: () => HapticService.trigger(HapticLevel.light),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [AppColors.brand500, AppColors.brand600]),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
              SizedBox(width: 10),
              Text('Generate', style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentGenerations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recent Generations', style: AppTypography.bodySm),
        const SizedBox(height: 8),
        ...List.generate(3, (i) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: AppColors.bgElevated, borderRadius: BorderRadius.circular(6)),
                child: const Icon(Icons.movie, size: 18, color: AppColors.textLow),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Generation ${i + 1}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textHigh)),
                    Text('${(i + 1) * 15}s', style: const TextStyle(fontSize: 10, color: AppColors.textLow)),
                  ],
                ),
              ),
              const Icon(Icons.check_circle, size: 16, color: AppColors.success),
            ],
          ),
        )),
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
            Text('${value.toInt()}s', style: const TextStyle(fontSize: 12, color: AppColors.textHigh)),
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
