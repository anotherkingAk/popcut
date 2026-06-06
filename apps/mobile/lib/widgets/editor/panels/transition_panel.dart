import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/app_motion.dart';
import '../../../services/haptic_service.dart';

class TransitionPanel extends StatelessWidget {
  final AnimationController staggerController;
  const TransitionPanel({super.key, required this.staggerController});

  final _transitions = const [
    _TransitionDef('Fade', Icons.blur_linear),
    _TransitionDef('Slide', Icons.arrow_forward),
    _TransitionDef('Zoom', Icons.zoom_in),
    _TransitionDef('Wipe', Icons.arrow_right_alt),
    _TransitionDef('Reveal', Icons.swipe),
    _TransitionDef('Spin', Icons.rotate_right),
    _TransitionDef('Mosaic', Icons.grid_view),
    _TransitionDef('Glitch', Icons.flash_on),
    _TransitionDef('Dream', Icons.wb_sunny),
    _TransitionDef('Shutter', Icons.camera),
    _TransitionDef('Radial', Icons.radio_button_checked),
    _TransitionDef('Page', Icons.turned_in),
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
            child: Column(
              children: [
                _buildCategoryTabs(),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 0.8,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: _transitions.length,
                    itemBuilder: (_, i) => _TransitionCard(transition: _transitions[i], isActive: i == 0),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.border))),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Duration', style: AppTypography.bodySm),
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: AppColors.brand500,
                                inactiveTrackColor: AppColors.timelineGrid,
                                thumbColor: AppColors.brand500,
                              ),
                              child: Slider(value: 0.5, min: 0.1, max: 5, onChanged: (_) { HapticService.trigger(HapticLevel.light); }),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () { HapticService.trigger(HapticLevel.light); },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          backgroundColor: AppColors.brand500,
                        ),
                        child: const Text('Apply', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                ),
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
      child: const Text('Transitions', style: AppTypography.titleSm),
    );
  }

  Widget _buildCategoryTabs() {
    final categories = ['Basic', 'Slide', 'Wipe', 'Fade', '3D', 'Glitch'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: categories.map((c) => Padding(
          padding: const EdgeInsets.only(right: 6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: c == 'Basic' ? AppColors.brand500.withValues(alpha: 0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: c == 'Basic' ? AppColors.brand500 : AppColors.border),
            ),
            child: Text(c, style: TextStyle(
              fontSize: 10,
              color: c == 'Basic' ? AppColors.brand500 : AppColors.textLow,
              fontWeight: FontWeight.w500,
            )),
          ),
        )).toList(),
      ),
    );
  }
}

class _TransitionDef {
  final String name;
  final IconData icon;
  const _TransitionDef(this.name, this.icon);
}

class _TransitionCard extends StatelessWidget {
  final _TransitionDef transition;
  final bool isActive;
  const _TransitionCard({required this.transition, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () { HapticService.trigger(HapticLevel.light); },
      child: Container(
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isActive ? AppColors.brand500 : AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: AppColors.bgElevated,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(transition.icon, size: 18, color: isActive ? AppColors.brand500 : AppColors.textMedium),
          ),
          const SizedBox(height: 6),
          Text(transition.name, style: TextStyle(
            fontSize: 9,
            color: isActive ? AppColors.brand500 : AppColors.textLow,
            fontWeight: FontWeight.w500,
          )),
        ],
      ),
      ),
    );
  }
}
