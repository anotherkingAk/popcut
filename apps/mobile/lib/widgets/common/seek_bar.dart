import 'dart:async';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_motion.dart';
import '../../services/haptic_service.dart';

class SeekBar extends StatefulWidget {
  final double currentTime;
  final double totalDuration;
  final ValueChanged<double> onSeek;

  const SeekBar({
    super.key,
    required this.currentTime,
    required this.totalDuration,
    required this.onSeek,
  });

  @override
  State<SeekBar> createState() => _SeekBarState();
}

class _SeekBarState extends State<SeekBar> {
  bool _isDragging = false;
  double _dragValue = 0;
  Timer? _autoScrollTimer;

  double get _progress => widget.totalDuration > 0
      ? (_isDragging ? _dragValue : widget.currentTime) / widget.totalDuration
      : 0;

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    super.dispose();
  }

  void _onDragStart(double globalX, RenderBox box) {
    setState(() => _isDragging = true);
    _updateDrag(globalX, box);
    HapticService.select();
  }

  void _onDragUpdate(double globalX, RenderBox box) {
    _updateDrag(globalX, box);
  }

  void _onDragEnd() {
    HapticService.trigger(HapticLevel.light);
    widget.onSeek((_dragValue * widget.totalDuration).clamp(0, widget.totalDuration));
    setState(() => _isDragging = false);
  }

  void _updateDrag(double globalX, RenderBox box) {
    final pos = box.globalToLocal(Offset(globalX, 0));
    _dragValue = (pos.dx / box.size.width).clamp(0, 1);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      color: AppColors.bgBase,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: LayoutBuilder(
        builder: (context, constraints) => Center(
          child: GestureDetector(
            onTapDown: (d) {
              final pos = d.localPosition.dx / constraints.maxWidth;
              widget.onSeek((pos * widget.totalDuration).clamp(0, widget.totalDuration));
              HapticService.snap();
            },
            onHorizontalDragStart: (d) => _onDragStart(d.globalPosition.dx, context.findRenderObject() as RenderBox),
            onHorizontalDragUpdate: (d) => _onDragUpdate(d.globalPosition.dx, context.findRenderObject() as RenderBox),
            onHorizontalDragEnd: (_) => _onDragEnd(),
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Container(height: 4, decoration: BoxDecoration(
                  color: AppColors.timelineGrid,
                  borderRadius: BorderRadius.circular(2),
                )),
                FractionallySizedBox(
                  widthFactor: _progress,
                  child: Container(height: 4, decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppColors.brand500, AppColors.brand300]),
                    borderRadius: BorderRadius.circular(2),
                  )),
                ),
                Positioned(
                  left: _progress * constraints.maxWidth - 8,
                  child: GestureDetector(
                    child: Container(
                      width: 16, height: 16,
                      decoration: BoxDecoration(
                        color: AppColors.brand500,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.brand500.withValues(alpha: 0.4),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
