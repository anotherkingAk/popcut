import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_motion.dart';
import '../../models/project.dart';
import '../../services/haptic_service.dart';

class ToolDock extends StatefulWidget {
  final ToolType? activeTool;
  final void Function(ToolType) onToolTap;

  const ToolDock({super.key, required this.activeTool, required this.onToolTap});

  @override
  State<ToolDock> createState() => _ToolDockState();
}

class _ToolDockState extends State<ToolDock> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const _primaryTools = [
    _ToolDef('Audio', Icons.music_note, ToolType.audio),
    _ToolDef('Text', Icons.text_fields, ToolType.text),
    _ToolDef('Stickers', Icons.auto_awesome, ToolType.stickers),
    _ToolDef('Overlay', Icons.layers, ToolType.overlays),
    _ToolDef('Effects', Icons.auto_fix_high, ToolType.effects),
  ];

  static const _secondaryTools = [
    _ToolDef('Transitions', Icons.swap_horiz, ToolType.transitions),
    _ToolDef('Filters', Icons.filter_vintage, ToolType.filters),
    _ToolDef('Adjust', Icons.tune, ToolType.adjust),
    _ToolDef('Format', Icons.aspect_ratio, ToolType.format),
    _ToolDef('Background', Icons.wallpaper, ToolType.background),
    _ToolDef('Canvas', Icons.view_quilt, ToolType.canvas),
    _ToolDef('Speed', Icons.speed, ToolType.speed),
    _ToolDef('Reverse', Icons.replay, ToolType.reverse),
    _ToolDef('Freeze', Icons.ac_unit, ToolType.freeze),
    _ToolDef('Voice FX', Icons.record_voice_over, ToolType.voiceFx),
    _ToolDef('Voiceover', Icons.mic, ToolType.voiceover),
    _ToolDef('Denoise', Icons.volume_off, ToolType.denoise),
    _ToolDef('Beat Sync', Icons.music_note, ToolType.beatSync),
    _ToolDef('Captions', Icons.closed_caption, ToolType.captions),
    _ToolDef('Lyrics', Icons.lyrics, ToolType.lyrics),
    _ToolDef('3D Zoom', Icons.rotate_right, ToolType.zoom3d),
    _ToolDef('Mask', Icons.masks, ToolType.mask),
    _ToolDef('Chroma Key', Icons.grid_on, ToolType.chromaKey),
    _ToolDef('Retouch', Icons.auto_fix_normal, ToolType.retouch),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bgSurface,
        border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 48,
            child: PageView(
              controller: _pageController,
              onPageChanged: (i) => setState(() => _currentPage = i),
              children: [
                _buildToolRow(_primaryTools),
                _buildToolRow(_secondaryTools.sublist(0, 10)),
                _buildToolRow(_secondaryTools.sublist(10)),
              ],
            ),
          ),
          _buildPageIndicator(),
          if (widget.activeTool != null)
            AnimatedContainer(
              duration: AppMotion.panelOpen,
              curve: AppMotion.easeOutCubic,
              height: 36,
              decoration: BoxDecoration(
                color: _toolColor(widget.activeTool!).withValues(alpha: 0.05),
                border: Border(top: BorderSide(color: _toolColor(widget.activeTool!).withValues(alpha: 0.15), width: 0.5)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _SubTool(Icons.layers, 'Browse'),
                  _SubTool(Icons.tune, 'Adjust'),
                  _SubTool(Icons.save_outlined, 'Presets'),
                  if (widget.activeTool == ToolType.effects) _SubTool(Icons.auto_fix_high, 'AI FX'),
                  if (widget.activeTool == ToolType.text) _SubTool(Icons.animation, 'Animations'),
                  if (widget.activeTool == ToolType.audio) _SubTool(Icons.library_music, 'Library'),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildToolRow(List<_ToolDef> tools) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: tools.map((t) => _DockIcon(
        icon: t.icon,
        label: t.label,
        tool: t.tool,
        isActive: widget.activeTool == t.tool,
        onTap: () {
          HapticService.select();
          widget.onToolTap(t.tool);
        },
      )).toList(),
    );
  }

  Widget _buildPageIndicator() {
    return Container(
      height: 2,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (i) => Container(
          width: _currentPage == i ? 16 : 4,
          height: 2,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: _currentPage == i ? AppColors.brand500 : AppColors.textLow,
            borderRadius: BorderRadius.circular(1),
          ),
        )),
      ),
    );
  }

  Color _toolColor(ToolType tool) {
    return switch (tool) {
      ToolType.video => AppColors.trackVideo,
      ToolType.audio => AppColors.trackAudio,
      ToolType.text => AppColors.trackText,
      ToolType.effects || ToolType.filters => AppColors.trackEffect,
      ToolType.transitions => AppColors.trackGraphic,
      _ => AppColors.brand500,
    };
  }
}

class _ToolDef {
  final String label;
  final IconData icon;
  final ToolType tool;
  const _ToolDef(this.label, this.icon, this.tool);
}

class _DockIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final ToolType tool;
  final bool isActive;
  final VoidCallback onTap;

  const _DockIcon({required this.icon, required this.label, required this.tool, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.toolDock,
        curve: SpringCurve(),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? AppColors.brand500.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: isActive ? 1.15 : 1.0,
              duration: AppMotion.fast,
              child: Icon(icon, size: 18, color: isActive ? AppColors.brand500 : AppColors.textMedium),
            ),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: isActive ? AppColors.brand500 : AppColors.textLow,
            )),
          ],
        ),
      ),
    );
  }
}

class _SubTool extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SubTool(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: AppColors.textMedium),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMedium)),
          ],
        ),
      ),
    );
  }
}
