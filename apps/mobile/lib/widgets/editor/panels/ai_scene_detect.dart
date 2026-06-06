import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../services/haptic_service.dart';

class AiSceneDetect extends StatelessWidget {
  final AnimationController staggerController;
  const AiSceneDetect({super.key, required this.staggerController});

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
                _buildDetectButton(),
                const SizedBox(height: 12),
                _buildProcessing(),
                const SizedBox(height: 16),
                _buildResultsGrid(),
                const SizedBox(height: 16),
                _buildActionsBar(),
                const SizedBox(height: 16),
                _buildLabeledSlider('Sensitivity', 50, 0, 100),
                const SizedBox(height: 12),
                _buildRescanButton(),
                const SizedBox(height: 12),
                _buildSceneCountBadge(),
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
      child: const Text('Scene Detection', style: AppTypography.titleSm),
    );
  }

  Widget _buildDetectButton() {
    return GestureDetector(
      onTap: () => HapticService.trigger(HapticLevel.light),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.brand500.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.brand500),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.movie, size: 16, color: AppColors.brand500),
            SizedBox(width: 8),
            Text('Scan for Scene Changes', style: TextStyle(fontSize: 12, color: AppColors.brand500, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessing() {
    final stages = ['Analyzing frames...', 'Detecting cuts...', 'Adding markers...'];
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: const LinearProgressIndicator(
              value: 0.45,
              minHeight: 4,
              backgroundColor: AppColors.muted,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.brand500),
            ),
          ),
          const SizedBox(height: 10),
          ...stages.asMap().entries.map((e) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                Icon(
                  e.key < 1 ? Icons.check_circle : Icons.circle_outlined,
                  size: 12,
                  color: e.key < 1 ? AppColors.success : AppColors.textLow,
                ),
                const SizedBox(width: 6),
                Text(e.value, style: TextStyle(fontSize: 10, color: e.key < 1 ? AppColors.textHigh : AppColors.textMedium)),
                if (e.key == 1)
                  const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: SizedBox(width: 10, height: 10, child: CircularProgressIndicator(strokeWidth: 1.5, color: AppColors.textLow)),
                  ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildResultsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Detected Scenes', style: AppTypography.bodySm),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.7,
          ),
          itemCount: 8,
          itemBuilder: (context, index) {
            final timecodes = ['0:03', '0:12', '0:28', '0:41', '0:55', '1:08', '1:22', '1:36'];
            return Container(
              decoration: BoxDecoration(
                color: AppColors.bgBase,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
                        color: AppColors.muted,
                      ),
                      child: const Center(child: Icon(Icons.movie, size: 18, color: AppColors.textDisabled)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(timecodes[index], style: const TextStyle(fontSize: 8, color: AppColors.textMedium)),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            _buildSmallButton('Split'),
                            const SizedBox(width: 2),
                            _buildSmallButton('Mark'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSmallButton(String label) {
    return GestureDetector(
      onTap: () => HapticService.trigger(HapticLevel.light),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(3),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(label, style: const TextStyle(fontSize: 7, color: AppColors.textMedium)),
      ),
    );
  }

  Widget _buildActionsBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildActionChip('Split All'),
              const SizedBox(width: 6),
              _buildActionChip('Add Markers'),
              const SizedBox(width: 6),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.bgBase,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Row(
                    children: [
                      Expanded(child: Text('Basic', style: TextStyle(fontSize: 10, color: AppColors.textMedium))),
                      Icon(Icons.arrow_drop_down, size: 14, color: AppColors.textLow),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildActionChip('Add Transitions Between All'),
        ],
      ),
    );
  }

  Widget _buildActionChip(String label) {
    return GestureDetector(
      onTap: () => HapticService.trigger(HapticLevel.light),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.brand500.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.brand500),
        ),
        child: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.brand500)),
      ),
    );
  }

  Widget _buildRescanButton() {
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
            Icon(Icons.refresh, size: 14, color: AppColors.textMedium),
            SizedBox(width: 6),
            Text('Re-scan with new sensitivity', style: TextStyle(fontSize: 11, color: AppColors.textMedium)),
          ],
        ),
      ),
    );
  }

  Widget _buildSceneCountBadge() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.15)),
      ),
      child: const Row(
        children: [
          Icon(Icons.movie_creation, size: 16, color: AppColors.success),
          SizedBox(width: 8),
          Text('12 scenes detected', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textHigh)),
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
            Text('${value.toInt()}', style: const TextStyle(fontSize: 12, color: AppColors.textHigh)),
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
