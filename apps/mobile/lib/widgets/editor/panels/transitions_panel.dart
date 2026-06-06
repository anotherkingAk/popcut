import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../services/haptic_service.dart';

class TransitionsPanel extends StatefulWidget {
  final AnimationController staggerController;
  const TransitionsPanel({super.key, required this.staggerController});

  @override
  State<TransitionsPanel> createState() => _TransitionsPanelState();
}

class _TransitionsPanelState extends State<TransitionsPanel> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  double _duration = 0.5;
  bool _applyToAll = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  static const _categories = ['Popular', 'Fade', 'Slide', 'Zoom', 'Glitch', '3D'];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.panelBg,
      child: Column(
        children: [
          Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5))),
            child: const Text('Transitions', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.foreground)),
          ),
          Container(
            height: 32,
            color: AppColors.panelBg,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.foregroundMuted,
              labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              indicatorColor: AppColors.primary,
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: _categories.map((c) => Tab(text: c)).toList(),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _categories.map((_) => _buildGrid()).toList(),
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.75,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _transitions.length,
      itemBuilder: (_, i) {
        final t = _transitions[i];
        return GestureDetector(
          onTap: () { HapticService.trigger(HapticLevel.light); },
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(t.icon, size: 22, color: AppColors.foregroundSecondary),
              ),
              const SizedBox(height: 6),
              Text(t.name, style: const TextStyle(fontSize: 9, color: AppColors.foregroundSecondary),
                textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text('${t.duration}s', style: const TextStyle(fontSize: 8, color: AppColors.foregroundMuted)),
            ],
          ),
          ),
        );
      },
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Text('Duration', style: TextStyle(fontSize: 12, color: AppColors.foregroundSecondary)),
                const Spacer(),
                Text('${_duration.toStringAsFixed(1)}s', style: const TextStyle(fontSize: 12, color: AppColors.foreground, fontWeight: FontWeight.w500)),
              ],
            ),
            SliderTheme(
              data: SliderThemeData(
                trackHeight: 2.5,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
                activeTrackColor: AppColors.primary,
                inactiveTrackColor: AppColors.muted,
                thumbColor: AppColors.primary,
              ),
              child: Slider(value: _duration, min: 0.1, max: 2.0, divisions: 19, onChanged: (v) { HapticService.trigger(HapticLevel.light); setState(() => _duration = v); }),
            ),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () { HapticService.trigger(HapticLevel.selection); setState(() => _applyToAll = !_applyToAll); },
              child: Row(
                children: [
                  Container(
                    width: 16, height: 16,
                    decoration: BoxDecoration(
                      color: _applyToAll ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(color: _applyToAll ? Colors.transparent : AppColors.foregroundMuted),
                    ),
                    child: _applyToAll ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
                  ),
                  const SizedBox(width: 8),
                  const Text('Apply to all', style: TextStyle(fontSize: 11, color: AppColors.foregroundSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransitionItem {
  final String name;
  final IconData icon;
  final double duration;
  const _TransitionItem(this.name, this.icon, this.duration);
}

const _transitions = [
  _TransitionItem('Fade', Icons.blur_linear, 0.5),
  _TransitionItem('Cross Fade', Icons.blur_on, 0.5),
  _TransitionItem('Slide L', Icons.arrow_back, 0.4),
  _TransitionItem('Slide R', Icons.arrow_forward, 0.4),
  _TransitionItem('Slide Up', Icons.arrow_upward, 0.4),
  _TransitionItem('Slide Dn', Icons.arrow_downward, 0.4),
  _TransitionItem('Zoom In', Icons.zoom_in, 0.5),
  _TransitionItem('Zoom Out', Icons.zoom_out, 0.5),
  _TransitionItem('Glitch', Icons.flash_on, 0.3),
  _TransitionItem('Distort', Icons.waves, 0.4),
  _TransitionItem('Wipe', Icons.swipe, 0.5),
  _TransitionItem('Reveal', Icons.unfold_more, 0.5),
  _TransitionItem('Spin', Icons.rotate_right, 0.5),
  _TransitionItem('Mosaic', Icons.grid_view, 0.5),
  _TransitionItem('Dream', Icons.auto_awesome, 0.6),
  _TransitionItem('Filmstrip', Icons.movie, 0.5),
];
