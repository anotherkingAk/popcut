import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/app_motion.dart';
import '../../../models/project.dart';
import '../../../services/haptic_service.dart';

class TimelineZone extends StatefulWidget {
  final List<TrackModel> tracks;
  final double totalDuration;
  final double playheadPosition;
  final String? selectedClipId;
  final String? selectedTrackId;
  final SelectionState selectionState;
  final ValueChanged<double> onPlayheadChanged;
  final void Function(String clipId, String trackId) onClipTap;
  final VoidCallback onCanvasTap;
  final VoidCallback onSplit;
  final VoidCallback onDelete;
  final void Function(TrackType) onAddTrack;
  final void Function(String) onToggleVisibility;
  final void Function(String) onToggleLock;

  const TimelineZone({
    super.key,
    required this.tracks,
    required this.totalDuration,
    required this.playheadPosition,
    this.selectedClipId,
    this.selectedTrackId,
    this.selectionState = SelectionState.idle,
    required this.onPlayheadChanged,
    required this.onClipTap,
    required this.onCanvasTap,
    this.onSplit = _noop,
    this.onDelete = _noop,
    this.onAddTrack = _noopTrackType,
    this.onToggleVisibility = _noopString,
    this.onToggleLock = _noopString,
  });

  static void _noop() {}
  static void _noopString(String _) {}
  static void _noopTrackType(TrackType _) {}

  @override
  State<TimelineZone> createState() => _TimelineZoneState();
}

class _TimelineZoneState extends State<TimelineZone> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() => _scrollOffset = _scrollController.offset);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  static const _trackLabelWidth = 52.0;
  static const _pixelsPerSecond = 20.0;

  double get _totalWidth => widget.totalDuration * _pixelsPerSecond;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        color: AppColors.background,
        child: Column(
          children: [
            _buildActionBar(),
            RepaintBoundary(
              child: _buildRuler(),
            ),
            const Divider(height: 0.5, color: AppColors.border),
            Expanded(
              child: Row(
                children: [
                  _buildTrackHeaders(),
                  Container(width: 0.5, color: AppColors.border),
                  Expanded(
                    child: GestureDetector(
                      onTap: widget.onCanvasTap,
                      child: Stack(
                        children: [
                          RepaintBoundary(
                            child: SingleChildScrollView(
                              controller: _scrollController,
                              scrollDirection: Axis.horizontal,
                              child: SizedBox(
                                width: _totalWidth,
                                child: Column(
                                  children: widget.tracks.where((t) => t.visible).map((track) => _TrackRow(
                                    track: track,
                                    totalDuration: widget.totalDuration,
                                    pixelsPerSecond: _pixelsPerSecond,
                                    isSelected: track.id == widget.selectedTrackId,
                                    selectedClipId: widget.selectedClipId,
                                    onClipTap: (clipId) => widget.onClipTap(clipId, track.id),
                                    scrollOffset: _scrollOffset,
                                    viewportWidth: MediaQuery.of(context).size.width - _trackLabelWidth,
                                  )).toList(),
                                ),
                              ),
                            ),
                          ),
                          RepaintBoundary(
                            child: _PlayheadAssembly(
                              position: widget.playheadPosition,
                              totalDuration: widget.totalDuration,
                              totalWidth: _totalWidth,
                              onChanged: widget.onPlayheadChanged,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionBar() {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Row(
        children: [
          _actionBtn(Icons.content_cut, 'Split', widget.onSplit, enabled: widget.selectedClipId != null),
          const SizedBox(width: 4),
          _actionBtn(Icons.delete_outline, 'Delete', widget.onDelete, enabled: widget.selectedClipId != null),
          const Spacer(),
          _actionBtn(Icons.add, 'Add Video', () => widget.onAddTrack(TrackType.video), enabled: true),
          const SizedBox(width: 2),
          _actionBtn(Icons.audiotrack, 'Add Audio', () => widget.onAddTrack(TrackType.audio), enabled: true),
          const SizedBox(width: 2),
          _actionBtn(Icons.text_fields, 'Add Text', () => widget.onAddTrack(TrackType.text), enabled: true),
        ],
      ),
    );
  }

  Widget _actionBtn(IconData icon, String tooltip, VoidCallback onTap, {required bool enabled}) {
    final color = enabled ? AppColors.foregroundSecondary : AppColors.foregroundMuted.withValues(alpha: 0.3);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: enabled ? () { HapticService.trigger(HapticLevel.light); onTap(); } : null,
        child: Container(
          width: 28, height: 28,
          child: Icon(icon, size: 14, color: color),
        ),
      ),
    );
  }

  Widget _buildRuler() {
    return Container(
      height: 22,
      color: AppColors.panelBg,
      padding: const EdgeInsets.only(left: _trackLabelWidth),
      child: CustomPaint(
        painter: _RulerPainter(totalDuration: widget.totalDuration, pixelsPerSecond: _pixelsPerSecond),
        size: const Size(double.infinity, 22),
      ),
    );
  }

  Widget _buildTrackHeaders() {
    return Container(
      width: _trackLabelWidth,
      color: AppColors.surface,
      child: Column(
        children: widget.tracks.where((t) => t.visible).map((track) => _TrackHeader(
          track: track,
          isActive: track.id == widget.selectedTrackId,
          onToggleVisibility: () => widget.onToggleVisibility(track.id),
          onToggleLock: () => widget.onToggleLock(track.id),
        )).toList(),
      ),
    );
  }
}

class _TrackRow extends StatelessWidget {
  final TrackModel track;
  final double totalDuration;
  final double pixelsPerSecond;
  final bool isSelected;
  final String? selectedClipId;
  final void Function(String clipId) onClipTap;
  final double scrollOffset;
  final double viewportWidth;

  const _TrackRow({
    required this.track,
    required this.totalDuration,
    required this.pixelsPerSecond,
    required this.isSelected,
    required this.selectedClipId,
    required this.onClipTap,
    this.scrollOffset = 0,
    this.viewportWidth = 400,
  });

  @override
  Widget build(BuildContext context) {
    final typeColor = _trackColor(track.type);
    final visibleStart = scrollOffset - 20;
    final visibleEnd = scrollOffset + viewportWidth + 20;

    final visibleClips = track.clips.where((clip) {
      final clipStart = clip.start * pixelsPerSecond;
      final clipEnd = clip.end * pixelsPerSecond;
      return clipEnd >= visibleStart && clipStart <= visibleEnd;
    }).toList();

    return Container(
      height: _trackHeight(track.type),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary.withValues(alpha: 0.05) : Colors.transparent,
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 0.5),
          left: isSelected ? const BorderSide(color: AppColors.primary, width: 2) : BorderSide.none,
        ),
      ),
      child: Stack(
        children: [
          CustomPaint(
            painter: _GridPainter(totalDuration: totalDuration, pixelsPerSecond: pixelsPerSecond),
            size: Size(double.infinity, _trackHeight(track.type)),
          ),
          ...visibleClips.map((clip) => Positioned(
            left: clip.start * pixelsPerSecond,
            width: (clip.end - clip.start) * pixelsPerSecond,
            top: 3,
            bottom: 3,
            child: GestureDetector(
              onTap: () { HapticService.trigger(HapticLevel.light); onClipTap(clip.id); },
              child: AnimatedContainer(
                duration: AppMotion.clipSelect,
                curve: SpringCurve(),
                decoration: BoxDecoration(
                  color: clip.id == selectedClipId
                      ? typeColor.withValues(alpha: 0.35)
                      : typeColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: clip.id == selectedClipId ? typeColor : typeColor.withValues(alpha: 0.4),
                    width: clip.id == selectedClipId ? 2 : 1,
                  ),
                  boxShadow: clip.id == selectedClipId
                      ? [BoxShadow(color: typeColor.withValues(alpha: 0.3), blurRadius: 8, spreadRadius: 1)]
                      : null,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Row(
                  children: [
                    if (track.type == TrackType.video)
                      Container(
                        width: 40, height: 26,
                        decoration: BoxDecoration(
                          color: Colors.black45, borderRadius: BorderRadius.circular(2),
                        ),
                        margin: const EdgeInsets.only(right: 6),
                        child: const Center(child: Icon(Icons.image, size: 12, color: AppColors.foregroundMuted)),
                      ),
                    if (track.type == TrackType.audio)
                      const _Waveform(),
                    Expanded(
                      child: Text(clip.name, style: const TextStyle(fontSize: 9, color: Colors.white),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(3)),
                      child: Text('${(clip.end - clip.start).toInt()}s',
                          style: const TextStyle(fontSize: 8, color: AppColors.foregroundSecondary)),
                    ),
                  ],
                ),
              ),
            ),
          )),
          if (selectedClipId != null)
            ...() {
              final clip = track.clips.where((c) => c.id == selectedClipId).firstOrNull;
              if (clip == null) return <Widget>[];
              return [
                _TrimHandle(position: clip.start, isLeft: true, pixelsPerSecond: pixelsPerSecond),
                _TrimHandle(position: clip.end, isLeft: false, pixelsPerSecond: pixelsPerSecond),
              ];
            }(),
        ],
      ),
    );
  }

  double _trackHeight(TrackType type) {
    return switch (type) {
      TrackType.video => 56,
      TrackType.audio => 44,
      TrackType.text => 28,
      TrackType.graphic => 28,
      TrackType.effect => 28,
    };
  }

  Color _trackColor(TrackType type) {
    return switch (type) {
      TrackType.video => AppColors.trackVideo,
      TrackType.audio => AppColors.trackAudio,
      TrackType.text => AppColors.trackText,
      TrackType.graphic => AppColors.trackGraphic,
      TrackType.effect => AppColors.trackEffect,
    };
  }
}

class _TrimHandle extends StatelessWidget {
  final double position;
  final bool isLeft;
  final double pixelsPerSecond;
  const _TrimHandle({required this.position, required this.isLeft, required this.pixelsPerSecond});

  @override
  Widget build(BuildContext context) {
    final x = position * pixelsPerSecond;
    return Positioned(
      left: isLeft ? x - 4 : null,
      right: isLeft ? null : x - 4,
      top: 0,
      bottom: 0,
      child: Container(
        width: 8,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.horizontal(
            left: isLeft ? const Radius.circular(2) : Radius.zero,
            right: isLeft ? Radius.zero : const Radius.circular(2),
          ),
        ),
      ),
    );
  }
}

class _TrackHeader extends StatelessWidget {
  final TrackModel track;
  final bool isActive;
  final VoidCallback onToggleVisibility;
  final VoidCallback onToggleLock;
  const _TrackHeader({required this.track, required this.isActive, required this.onToggleVisibility, required this.onToggleLock});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _trackHeight(track.type),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(_iconForType(track.type), size: 14, color: isActive ? AppColors.primary : AppColors.foregroundMuted),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _toggleIcon(track.visible ? Icons.visibility : Icons.visibility_off, onToggleVisibility),
              const SizedBox(width: 2),
              _toggleIcon(track.locked ? Icons.lock : Icons.lock_open, onToggleLock),
            ],
          ),
        ],
      ),
    );
  }

  Widget _toggleIcon(IconData icon, VoidCallback onTap) {
    return SizedBox(
      width: 18, height: 18,
      child: Material(color: Colors.transparent, child: InkWell(
        borderRadius: BorderRadius.circular(3),
        onTap: () { HapticService.trigger(HapticLevel.selection); onTap(); },
        child: Icon(icon, size: 11, color: AppColors.foregroundMuted),
      )),
    );
  }

  double _trackHeight(TrackType type) {
    return switch (type) {
      TrackType.video => 56,
      TrackType.audio => 44,
      TrackType.text => 28,
      TrackType.graphic => 28,
      TrackType.effect => 28,
    };
  }

  IconData _iconForType(TrackType type) {
    return switch (type) {
      TrackType.video => Icons.movie_outlined,
      TrackType.audio => Icons.graphic_eq,
      TrackType.text => Icons.text_fields,
      TrackType.graphic => Icons.landscape,
      TrackType.effect => Icons.auto_awesome,
    };
  }
}

class _PlayheadAssembly extends StatelessWidget {
  final double position;
  final double totalDuration;
  final double totalWidth;
  final ValueChanged<double> onChanged;

  const _PlayheadAssembly({
    required this.position,
    required this.totalDuration,
    required this.totalWidth,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final xPos = totalDuration > 0 ? (position / totalDuration) * totalWidth : 0;
    return Positioned(
      left: xPos - 5,
      top: 0,
      bottom: 0,
      child: GestureDetector(
        onHorizontalDragUpdate: (d) {
          final newPos = totalDuration > 0
              ? ((d.localPosition.dx) / totalWidth * totalDuration).clamp(0, totalDuration)
              : 0.0;
          onChanged(newPos.toDouble());
        },
        child: SizedBox(
          width: 10,
          child: Column(
            children: [
              Container(
                width: 10, height: 10,
                decoration: BoxDecoration(
                  color: AppColors.playheadColor,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: AppColors.playheadGlow.withValues(alpha: 0.5), blurRadius: 4, spreadRadius: 1)],
                ),
              ),
              Expanded(
                child: Container(
                  width: 1.5,
                  decoration: BoxDecoration(
                    color: AppColors.playheadColor,
                    boxShadow: [BoxShadow(color: AppColors.playheadGlow.withValues(alpha: 0.3), blurRadius: 4)],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RulerPainter extends CustomPainter {
  final double totalDuration;
  final double pixelsPerSecond;
  _RulerPainter({required this.totalDuration, required this.pixelsPerSecond});

  ui.Picture? _cachedPicture;
  double _cachedDuration = -1;
  double _cachedPixelsPerSecond = -1;

  @override
  void paint(Canvas canvas, Size size) {
    if (_cachedPicture != null && _cachedDuration == totalDuration && _cachedPixelsPerSecond == pixelsPerSecond) {
      canvas.drawPicture(_cachedPicture!);
      return;
    }

    final pictureRecorder = ui.PictureRecorder();
    final pictureCanvas = Canvas(pictureRecorder);
    final paint = Paint()..color = AppColors.borderLight..strokeWidth = 0.5;
    final txt = TextPainter(textDirection: TextDirection.ltr);

    for (double i = 0; i <= totalDuration; i += 0.5) {
      final x = i * pixelsPerSecond;
      final isMajor = i % 5 == 0;
      final isMinor = i % 1 == 0;

      if (isMajor) {
        pictureCanvas.drawLine(Offset(x, 12), Offset(x, size.height), paint);
        txt.text = TextSpan(text: '${i.toInt()}s', style: const TextStyle(color: AppColors.foregroundMuted, fontSize: 9));
        txt.layout();
        txt.paint(pictureCanvas, Offset(x - txt.width / 2, 2));
      } else if (isMinor) {
        pictureCanvas.drawLine(Offset(x, 16), Offset(x, size.height), paint);
      } else {
        pictureCanvas.drawLine(Offset(x, 18), Offset(x, size.height), Paint()..color = AppColors.borderLight.withValues(alpha: 0.3)..strokeWidth = 0.5);
      }
    }

    _cachedPicture = pictureRecorder.endRecording();
    _cachedDuration = totalDuration;
    _cachedPixelsPerSecond = pixelsPerSecond;
    canvas.drawPicture(_cachedPicture!);
  }

  @override
  bool shouldRepaint(covariant _RulerPainter old) => old.totalDuration != totalDuration || old.pixelsPerSecond != pixelsPerSecond;
}

class _GridPainter extends CustomPainter {
  final double totalDuration;
  final double pixelsPerSecond;
  _GridPainter({required this.totalDuration, required this.pixelsPerSecond});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.border.withValues(alpha: 0.25)..strokeWidth = 0.3;
    for (double i = 0; i <= totalDuration; i++) {
      final x = i * pixelsPerSecond;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter old) => old.totalDuration != totalDuration || old.pixelsPerSecond != pixelsPerSecond;
}

class _Waveform extends StatelessWidget {
  const _Waveform();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 20,
      child: CustomPaint(
        painter: _WaveformPainter(),
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.4)..strokeWidth = 1.5;
    for (double i = 0; i < size.width; i += 3) {
      final h = (5.0 * (1 + math.sin(i / size.width * 4) * 0.5)).abs().clamp(2, size.height);
      canvas.drawLine(Offset(i, (size.height - h) / 2), Offset(i, (size.height + h) / 2), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
