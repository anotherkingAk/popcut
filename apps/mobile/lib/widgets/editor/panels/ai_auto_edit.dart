import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../services/haptic_service.dart';

class AiAutoEdit extends StatelessWidget {
  final AnimationController staggerController;
  const AiAutoEdit({super.key, required this.staggerController});

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
                _buildStepIndicator(),
                const SizedBox(height: 16),
                _buildSelectClips(),
                const SizedBox(height: 16),
                _buildSelectMusic(),
                const SizedBox(height: 16),
                _buildChooseStyle(),
                const SizedBox(height: 16),
                _buildPreferences(),
                const SizedBox(height: 16),
                _buildGenerateButton(),
                const SizedBox(height: 12),
                _buildProcessingSteps(),
                const SizedBox(height: 12),
                _buildResultActions(),
                const SizedBox(height: 12),
                _buildRegenerateButton(),
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
      child: const Row(
        children: [
          Icon(Icons.auto_fix_high, size: 14, color: AppColors.textMedium),
          SizedBox(width: 6),
          Text('Auto Edit', style: AppTypography.titleSm),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    final steps = ['Clips', 'Music', 'Style', 'Prefs'];
    return Row(
      children: steps.asMap().entries.map((e) => Expanded(
        child: Row(
          children: [
            Container(
              width: 20, height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: e.key <= 0 ? AppColors.brand500 : AppColors.muted,
              ),
              child: Center(child: Text('${e.key + 1}', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: e.key <= 0 ? Colors.black : AppColors.textLow))),
            ),
            if (e.key < steps.length - 1)
              Expanded(
                child: Container(height: 1, color: e.key < 0 ? AppColors.brand500 : AppColors.muted),
              ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildSelectClips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Step 1: Select Clips', style: AppTypography.bodySm),
        const SizedBox(height: 8),
        SizedBox(
          height: 60,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: List.generate(6, (i) => Container(
              width: 72,
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.brand500),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, size: 12, color: AppColors.brand500),
                  const SizedBox(height: 2),
                  Text('Clip ${i + 1}', style: const TextStyle(fontSize: 8, color: AppColors.textMedium)),
                ],
              ),
            )),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectMusic() {
    final tracks = ['Summer Vibes', 'Cinematic Rise', 'Urban Flow', 'Chill Wave', 'Epic Drums', 'Ambient Pad', 'Neon Nights', 'Acoustic Soul'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Step 2: Select Music', style: AppTypography.bodySm),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: const Row(
            children: [
              Icon(Icons.search, size: 14, color: AppColors.textLow),
              SizedBox(width: 6),
              Text('Search music...', style: TextStyle(fontSize: 11, color: AppColors.textLow)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 88,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: tracks.asMap().entries.map((e) => GestureDetector(
              onTap: () => HapticService.trigger(HapticLevel.light),
              child: Container(
                width: 80,
                margin: const EdgeInsets.only(right: 6),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: e.key == 0 ? AppColors.brand500.withValues(alpha: 0.15) : AppColors.bgBase,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: e.key == 0 ? AppColors.brand500 : AppColors.border),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.music_note, size: 18, color: e.key == 0 ? AppColors.brand500 : AppColors.textLow),
                    const SizedBox(height: 4),
                    Text(e.value, style: TextStyle(fontSize: 7, color: e.key == 0 ? AppColors.brand500 : AppColors.textMedium), textAlign: TextAlign.center, maxLines: 2),
                  ],
                ),
              ),
            )).toList(),
          ),
        ),
        const SizedBox(height: 6),
        _buildToggleRow('Auto Beat Sync', true),
      ],
    );
  }

  Widget _buildChooseStyle() {
    final styles = ['Cinematic', 'Vlog', 'Fast Cut', 'Tutorial', 'Music Video', 'Slow Elegant', 'Dynamic Sports', 'Wedding'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Step 3: Choose Style', style: AppTypography.bodySm),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: styles.asMap().entries.map((e) => GestureDetector(
            onTap: () => HapticService.trigger(HapticLevel.light),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: e.key == 0 ? AppColors.brand500.withValues(alpha: 0.15) : AppColors.bgSurface,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: e.key == 0 ? AppColors.brand500 : AppColors.border),
              ),
              child: Text(e.value, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: e.key == 0 ? AppColors.brand500 : AppColors.textMedium)),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildPreferences() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Step 4: Preferences', style: AppTypography.bodySm),
        const SizedBox(height: 8),
        Row(
          children: ['15s', '30s', '60s', 'Auto'].map((d) => Expanded(
            child: GestureDetector(
              onTap: () => HapticService.trigger(HapticLevel.light),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: d == 'Auto' ? AppColors.brand500.withValues(alpha: 0.15) : AppColors.bgSurface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: d == 'Auto' ? AppColors.brand500 : AppColors.border),
                ),
                child: Text(d, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: d == 'Auto' ? AppColors.brand500 : AppColors.textMedium), textAlign: TextAlign.center),
              ),
            ),
          )).toList(),
        ),
        const SizedBox(height: 8),
        _buildToggleRow('Include Text Overlay', true),
        const SizedBox(height: 6),
        _buildToggleRow('Intro/Outro', false),
        const SizedBox(height: 8),
        Row(
          children: ['Basic', 'Smooth', 'Dynamic'].map((t) => Expanded(
            child: GestureDetector(
              onTap: () => HapticService.trigger(HapticLevel.light),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: t == 'Smooth' ? AppColors.brand500.withValues(alpha: 0.15) : AppColors.bgSurface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: t == 'Smooth' ? AppColors.brand500 : AppColors.border),
                ),
                child: Text(t, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: t == 'Smooth' ? AppColors.brand500 : AppColors.textMedium), textAlign: TextAlign.center),
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildGenerateButton() {
    return GestureDetector(
      onTap: () => HapticService.trigger(HapticLevel.light),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.brand500,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_fix_high, size: 14, color: Colors.black),
            SizedBox(width: 6),
            Text('Generate Edit', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black)),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessingSteps() {
    final steps = ['Analyzing clips...', 'Syncing to music...', 'Cutting timeline...', 'Adding transitions...', 'Color grading...', 'Done'];
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: steps.asMap().entries.map((e) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Icon(e.value == 'Done' ? Icons.check_circle : (e.key < 3 ? Icons.check_circle : Icons.circle_outlined), size: 10, color: e.value == 'Done' || e.key < 3 ? AppColors.success : AppColors.textLow),
              const SizedBox(width: 4),
              Text(e.value, style: TextStyle(fontSize: 9, color: e.value == 'Done' || e.key < 3 ? AppColors.textHigh : AppColors.textMedium)),
              if (e.key == 3)
                const Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: SizedBox(width: 8, height: 8, child: CircularProgressIndicator(strokeWidth: 1.2, color: AppColors.textLow)),
                ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildResultActions() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => HapticService.trigger(HapticLevel.light),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: const Center(child: Text('Undo', style: TextStyle(fontSize: 11, color: AppColors.textMedium))),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: () => HapticService.trigger(HapticLevel.light),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.brand500,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(child: Text('Accept', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black))),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegenerateButton() {
    return GestureDetector(
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
            Icon(Icons.shuffle, size: 14, color: AppColors.textMedium),
            SizedBox(width: 6),
            Text('Regenerate', style: TextStyle(fontSize: 11, color: AppColors.textMedium)),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditDisplay() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.2)),
      ),
      child: const Row(
        children: [
          Icon(Icons.credit_card, size: 14, color: AppColors.warning),
          SizedBox(width: 6),
          Text('This uses 1 AI credit', style: TextStyle(fontSize: 10, color: AppColors.textMedium)),
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
