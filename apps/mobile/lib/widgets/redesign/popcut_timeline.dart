import 'package:flutter/material.dart';
import '../../theme/popcut_theme.dart';
import '../../models/project.dart';

class PopCutTimeline extends StatefulWidget {
  final List<TrackModel> tracks;
  final double totalDuration;
  final double playheadPosition;
  final String? selectedClipId;
  final String? selectedTrackId;
  final ValueChanged<double> onPlayheadChanged;
  final void Function(String clipId, String trackId) onClipTap;
  final VoidCallback onCanvasTap;

  const PopCutTimeline({
    super.key,
    required this.tracks,
    required this.totalDuration,
    required this.playheadPosition,
    this.selectedClipId,
    this.selectedTrackId,
    required this.onPlayheadChanged,
    required this.onClipTap,
    required this.onCanvasTap,
  });

  @override
  State<PopCutTimeline> createState() => _PopCutTimelineState();
}

class _PopCutTimelineState extends State<PopCutTimeline> {
  final ScrollController _scrollController = ScrollController();
  double _zoomLevel = 1.0;
  static const double basePixelPerSecond = 40;
  double _scrollOffset = 0;

  double get pixelsPerSecond => basePixelPerSecond * _zoomLevel;
  double get totalWidth => widget.totalDuration * pixelsPerSecond;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      _scrollOffset = _scrollController.offset;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Color _trackColor(TrackType type) {
    switch (type) {
      case TrackType.video:
        return const Color(0xFF00D4FF);
      case TrackType.audio:
        return const Color(0xFF7C3AED);
      case TrackType.text:
        return const Color(0xFF22C55E);
      case TrackType.graphic:
        return const Color(0xFFF59E0B);
      case TrackType.effect:
        return const Color(0xFFEF4444);
    }
  }

  String _trackLabel(TrackType type) {
    switch (type) {
      case TrackType.video:
        return 'V';
      case TrackType.audio:
        return 'A';
      case TrackType.text:
        return 'T';
      case TrackType.graphic:
        return 'G';
      case TrackType.effect:
        return 'E';
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Column(
        children: [
          // Zoom controls
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => setState(() => _zoomLevel = (_zoomLevel - 0.2).clamp(0.4, 3.0)),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: PopCutColors.glass(),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.zoom_out, size: 16),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 2,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 8),
                      activeTrackColor: PopCutColors.primary,
                      inactiveTrackColor: PopCutColors.surfaceHover,
                      thumbColor: PopCutColors.primary,
                    ),
                    child: Slider(
                      value: _zoomLevel,
                      min: 0.4,
                      max: 3.0,
                      onChanged: (v) => setState(() => _zoomLevel = v),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => setState(() => _zoomLevel = (_zoomLevel + 0.2).clamp(0.4, 3.0)),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: PopCutColors.glass(),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.zoom_in, size: 16),
                  ),
                ),
              ],
            ),
          ),
          // Timeline tracks
          Expanded(
            child: GestureDetector(
              onTap: widget.onCanvasTap,
              child: SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: totalWidth.clamp(200, double.infinity),
                  child: ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: widget.tracks.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 2),
                    itemBuilder: (context, index) {
                      final track = widget.tracks[index];
                      final isSelected = track.id == widget.selectedTrackId;
                      final color = _trackColor(track.type);
                      return RepaintBoundary(
                        child: Container(
                          height: 40,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? color.withValues(alpha: 0.08)
                                : PopCutColors.glass(opacity: 0.04),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isSelected
                                  ? color.withValues(alpha: 0.3)
                                  : PopCutColors.border.withValues(alpha: 0.2),
                              width: isSelected ? 1 : 0.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              // Track label
                              Container(
                                width: 28,
                                alignment: Alignment.center,
                                child: Text(
                                  _trackLabel(track.type),
                                  style: PopCutTypography.captionBold.copyWith(
                                    color: color,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                              // Clips
                              Expanded(
                                child: ClipRect(
                                  child: CustomPaint(
                                    painter: _TimelineGridPainter(
                                      totalDuration: widget.totalDuration,
                                      pixelsPerSecond: pixelsPerSecond,
                                      scrollOffset: _scrollOffset,
                                    ),
                                    child: Stack(
                                      children: [
                                        ...track.clips.map((clip) {
                                          final left = clip.start * pixelsPerSecond;
                                          final width = (clip.end - clip.start) * pixelsPerSecond;
                                          final isClipSelected = clip.id == widget.selectedClipId;
                                          // Only render clips that are potentially visible
                                          if (left + width < _scrollOffset - 100 ||
                                              left > _scrollOffset + 1000 + 100) {
                                            return const SizedBox.shrink();
                                          }
                                          return Positioned(
                                            left: left,
                                            top: 4,
                                            bottom: 4,
                                            child: GestureDetector(
                                              onTap: () => widget.onClipTap(clip.id, track.id),
                                              child: Container(
                                                width: width.clamp(20, double.infinity),
                                                padding: const EdgeInsets.symmetric(horizontal: 6),
                                                decoration: BoxDecoration(
                                                  color: isClipSelected
                                                      ? color.withValues(alpha: 0.4)
                                                      : color.withValues(alpha: 0.25),
                                                  borderRadius: BorderRadius.circular(4),
                                                  border: Border.all(
                                                    color: isClipSelected ? color : color.withValues(alpha: 0.3),
                                                    width: isClipSelected ? 1.5 : 1,
                                                  ),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      _clipIcon(track.type),
                                                      size: 10,
                                                      color: color,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Expanded(
                                                      child: Text(
                                                        clip.name,
                                                        style: TextStyle(
                                                          fontSize: 9,
                                                          color: PopCutColors.textPrimary,
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        }),
                                        // Playhead
                                        Positioned(
                                          left: widget.playheadPosition * pixelsPerSecond,
                                          top: 0,
                                          bottom: 0,
                                          child: Container(
                                            width: 1.5,
                                            color: PopCutColors.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _clipIcon(TrackType type) {
    switch (type) {
      case TrackType.video:
        return Icons.videocam_rounded;
      case TrackType.audio:
        return Icons.music_note_rounded;
      case TrackType.text:
        return Icons.text_fields_rounded;
      case TrackType.graphic:
        return Icons.image_rounded;
      case TrackType.effect:
        return Icons.auto_awesome_rounded;
    }
  }
}

class _TimelineGridPainter extends CustomPainter {
  final double totalDuration;
  final double pixelsPerSecond;
  final double scrollOffset;

  _TimelineGridPainter({
    required this.totalDuration,
    required this.pixelsPerSecond,
    required this.scrollOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = PopCutColors.border.withValues(alpha: 0.08)
      ..strokeWidth = 0.5;

    final startT = (scrollOffset / pixelsPerSecond).floor().toDouble();
    final endT = ((scrollOffset + size.width) / pixelsPerSecond).ceil().toDouble();
    final clampedStart = startT.clamp(0, totalDuration);
    final clampedEnd = endT.clamp(0, totalDuration);

    for (double t = clampedStart; t < clampedEnd; t += 1) {
      final x = t * pixelsPerSecond;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(_TimelineGridPainter oldDelegate) =>
      oldDelegate.totalDuration != totalDuration ||
      oldDelegate.pixelsPerSecond != pixelsPerSecond ||
      oldDelegate.scrollOffset != scrollOffset;
}
