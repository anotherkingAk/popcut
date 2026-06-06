import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/project.dart';
import '../../services/haptic_service.dart';

class PreviewCanvas extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onTap;
  final VoidCallback onTogglePlay;
  final SelectionState selectionState;

  const PreviewCanvas({
    super.key,
    required this.isPlaying,
    required this.onTap,
    required this.onTogglePlay,
    required this.selectionState,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgBase,
      child: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () { HapticService.trigger(HapticLevel.light); onTap(); },
              onDoubleTap: () { HapticService.trigger(HapticLevel.light); },
              child: Center(
                child: AspectRatio(
                  aspectRatio: 9 / 16,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.bgSurface,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.borderLight, width: 0.5),
                    ),
                    child: _buildCanvasContent(context),
                  ),
                ),
              ),
            ),
          ),
          _buildControls(),
        ],
      ),
    );
  }

  Widget _buildCanvasContent(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.play_circle_outline, size: 48, color: Colors.white.withValues(alpha: 0.15)),
              const SizedBox(height: 8),
              Text('Tap to preview', style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.25))),
            ],
          ),
        ),
        if (selectionState == SelectionState.selected || selectionState == SelectionState.editing)
          Positioned(
            left: 4, top: 4, right: 4,
            child: Row(
              children: [
                _SafeZoneBadge(label: '93%', color: AppColors.foregroundSecondary),
                const SizedBox(width: 6),
                _SafeZoneBadge(label: 'Action Safe', color: AppColors.foregroundMuted),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildControls() {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _ControlBtn(Icons.skip_previous, 'Previous frame'),
          const SizedBox(width: 6),
          _PlayBtn(isPlaying: isPlaying, onTap: onTogglePlay),
          const SizedBox(width: 6),
          _ControlBtn(Icons.skip_next, 'Next frame'),
          const Spacer(),
          _ControlBtn(Icons.zoom_out_map, 'Fit'),
          const SizedBox(width: 4),
          Text('100%', style: TextStyle(fontSize: 11, color: AppColors.foregroundSecondary)),
          const SizedBox(width: 4),
          _ControlBtn(Icons.aspect_ratio, 'Aspect'),
        ],
      ),
    );
  }
}

class _ControlBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  const _ControlBtn(this.icon, this.tooltip);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: () { HapticService.trigger(HapticLevel.light); },
        child: Container(
          width: 30, height: 30,
          child: Icon(icon, size: 15, color: AppColors.foregroundSecondary),
        ),
      ),
    );
  }
}

class _PlayBtn extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onTap;
  const _PlayBtn({required this.isPlaying, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: () { HapticService.trigger(HapticLevel.medium); onTap(); },
        child: Container(
          width: 34, height: 30,
          child: Icon(isPlaying ? Icons.pause : Icons.play_arrow, size: 18, color: AppColors.primary),
        ),
      ),
    );
  }
}

class _SafeZoneBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _SafeZoneBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(3)),
      child: Text(label, style: TextStyle(fontSize: 8, color: color)),
    );
  }
}
