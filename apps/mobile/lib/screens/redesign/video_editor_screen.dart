import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/popcut_theme.dart';
import '../../models/project.dart';
import '../../services/editor_engine.dart';
import '../../providers/editor_provider.dart';
import '../../services/project_service.dart';
import '../../widgets/redesign/popcut_timeline.dart';
import '../../widgets/redesign/popcut_playhead.dart';
import '../../widgets/redesign/popcut_tool_dock.dart';
import '../../widgets/redesign/popcut_card.dart';
import '../../widgets/redesign/popcut_bottom_sheet.dart';

class VideoEditorScreenRedesign extends StatefulWidget {
  final String? projectId;
  final VoidCallback onBack;
  final void Function(String projectId) onExport;

  const VideoEditorScreenRedesign({
    super.key,
    this.projectId,
    required this.onBack,
    required this.onExport,
  });

  @override
  State<VideoEditorScreenRedesign> createState() =>
      _VideoEditorScreenRedesignState();
}

class _VideoEditorScreenRedesignState
    extends State<VideoEditorScreenRedesign>
    with SingleTickerProviderStateMixin {
  bool _hasInitializedProject = false;
  late AnimationController _previewAnimController;

  final _toolItems = [
    ToolDockItem(
        type: ToolType.video,
        icon: Icons.perm_media_rounded,
        label: 'Media'),
    ToolDockItem(
        type: ToolType.text, icon: Icons.text_fields_rounded, label: 'Text'),
    ToolDockItem(
        type: ToolType.audio,
        icon: Icons.music_note_rounded,
        label: 'Audio'),
    ToolDockItem(
        type: ToolType.effects,
        icon: Icons.auto_awesome_rounded,
        label: 'Effects'),
    ToolDockItem(
        type: ToolType.filters, icon: Icons.filter_alt_rounded, label: 'Filters'),
    ToolDockItem(
        type: ToolType.transitions,
        icon: Icons.swap_horiz_rounded,
        label: 'Transitions'),
    ToolDockItem(
        type: ToolType.stickers,
        icon: Icons.emoji_emotions_rounded,
        label: 'Stickers'),
    ToolDockItem(type: ToolType.captions, icon: Icons.auto_awesome, label: 'AI'),
  ];

  @override
  void initState() {
    super.initState();
    _previewAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _previewAnimController.dispose();
    super.dispose();
  }

  void _ensureProjectLoaded() {
    if (_hasInitializedProject) return;
    _hasInitializedProject = true;
    final editor = context.read<EditorProvider>();
    if (editor.isInitialized) return;
    final projects = context.read<ProjectService>();
    final project = widget.projectId != null
        ? projects.getProject(widget.projectId!)
        : projects.projects.isNotEmpty
            ? projects.projects.first
            : null;
    editor.loadProject(
        project ?? Project(id: 'new', name: 'Untitled Project'));
  }

  void _openTool(ToolType tool) {
    final editor = context.read<EditorProvider>();
    editor.tool.setActiveTool(tool);
    if (editor.engine.activeTool != null) {
      _showToolPanel(tool);
    }
  }

  void _showToolPanel(ToolType tool) {
    final editor = context.read<EditorProvider>();
    PopCutBottomSheet.show(
      context: context,
      title: _toolPanelTitle(tool),
      initialChildSize: 0.45,
      maxChildSize: 0.75,
      child: _buildToolPanel(tool),
    ).then((_) {
      editor.tool.setActiveTool(null);
    });
  }

  String _toolPanelTitle(ToolType tool) {
    switch (tool) {
      case ToolType.video: return 'Media Library';
      case ToolType.text: return 'Text';
      case ToolType.audio: return 'Audio';
      case ToolType.effects: return 'Effects';
      case ToolType.filters: return 'Filters';
      case ToolType.transitions: return 'Transitions';
      case ToolType.stickers: return 'Stickers';
      case ToolType.captions: return 'AI Tools';
      default: return 'Tools';
    }
  }

  Widget _buildToolPanel(ToolType tool) {
    switch (tool) {
      case ToolType.video:
        return _buildMediaPanel();
      case ToolType.text:
        return _buildTextPanel();
      case ToolType.audio:
        return _buildAudioPanel();
      case ToolType.effects:
        return _buildEffectsPanel();
      case ToolType.filters:
        return _buildFiltersPanel();
      case ToolType.transitions:
        return _buildTransitionsPanel();
      case ToolType.stickers:
        return _buildStickersPanel();
      case ToolType.captions:
        return _buildAiPanel();
      default:
        return Center(
          child: Text('Coming soon', style: PopCutTypography.body),
        );
    }
  }

  Widget _buildMediaPanel() {
    final items = ['Video 1.mp4', 'Video 2.mp4', 'clip_3.mov', 'intro.mp4'];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((name) {
        return PopCutCard(
          padding: const EdgeInsets.all(10),
          backgroundColor: PopCutColors.surface,
          onTap: () => Navigator.pop(context),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 60,
                decoration: BoxDecoration(
                  color: PopCutColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.videocam_rounded,
                    size: 24, color: PopCutColors.primary.withValues(alpha: 0.5)),
              ),
              const SizedBox(height: 6),
              Text(name,
                  style: PopCutTypography.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTextPanel() {
    final presets = ['Title', 'Subtitle', 'Heading', 'Body', 'Caption', 'Quote'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          style: PopCutTypography.body,
          decoration: InputDecoration(
            hintText: 'Enter your text...',
            hintStyle: PopCutTypography.body.copyWith(
              color: PopCutColors.textMuted,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text('Styles', style: PopCutTypography.captionBold),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: presets.map((p) {
            return GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: PopCutColors.glass(),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: PopCutColors.glassBorder()),
                ),
                child: Text(p, style: PopCutTypography.captionBold),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAudioPanel() {
    final tracks = ['Background 1', 'Background 2', 'Jazz Loop', 'Cinematic'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Audio Tracks', style: PopCutTypography.captionBold),
        const SizedBox(height: 12),
        ...tracks.map((t) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: PopCutColors.glass(),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: PopCutColors.glassBorder()),
              ),
              child: Row(
                children: [
                  Icon(Icons.music_note_rounded,
                      size: 18, color: PopCutColors.secondary),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Text(t, style: PopCutTypography.bodySmall)),
                  Icon(Icons.play_circle_outline,
                      size: 20, color: PopCutColors.textSecondary),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildEffectsPanel() {
    final effects = [
      {'name': 'Glitch', 'icon': Icons.flash_on, 'color': PopCutColors.primary},
      {'name': 'Neon', 'icon': Icons.light_mode, 'color': const Color(0xFF7C3AED)},
      {'name': 'Retro', 'icon': Icons.videocam, 'color': const Color(0xFFF59E0B)},
      {'name': 'VHS', 'icon': Icons.grain, 'color': const Color(0xFF22C55E)},
      {'name': 'Cinematic', 'icon': Icons.movie, 'color': const Color(0xFFEF4444)},
      {'name': 'Dream', 'icon': Icons.blur_on, 'color': const Color(0xFF00D4FF)},
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: effects.map((e) {
        final color = e['color'] as Color;
        return PopCutCard(
          padding: const EdgeInsets.all(12),
          backgroundColor: color.withValues(alpha: 0.06),
          onTap: () => Navigator.pop(context),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(e['icon'] as IconData, color: color, size: 24),
              ),
              const SizedBox(height: 6),
              Text(e['name'] as String, style: PopCutTypography.captionBold),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFiltersPanel() {
    final filters = ['Warm', 'Cool', 'Mono', 'Vintage', 'Drama', 'Fade'];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: filters.map((f) {
        return GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 80,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: PopCutColors.glass(),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: PopCutColors.glassBorder()),
            ),
            child: Column(
              children: [
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: PopCutColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 6),
                Text(f, style: PopCutTypography.caption),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTransitionsPanel() {
    final transitions = ['Fade', 'Slide', 'Zoom', 'Wipe', 'Spin', 'Blur'];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: transitions.map((t) {
        return PopCutCard(
          padding: const EdgeInsets.all(12),
          backgroundColor: PopCutColors.surface,
          onTap: () => Navigator.pop(context),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.swap_horiz_rounded,
                  size: 28, color: PopCutColors.primary.withValues(alpha: 0.6)),
              const SizedBox(height: 6),
              Text(t, style: PopCutTypography.captionBold),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStickersPanel() {
    final emojis = ['😀', '🎉', '❤️', '🔥', '⭐', '💎', '🎵', '📱', '💡', '👑'];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: emojis.map((e) {
        return GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: PopCutColors.glass(),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: PopCutColors.glassBorder()),
            ),
            child: Center(
              child: Text(e, style: const TextStyle(fontSize: 28)),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAiPanel() {
    final tools = [
      {'name': 'Auto Captions', 'desc': 'Generate captions instantly', 'icon': Icons.closed_caption_rounded},
      {'name': 'Beat Sync', 'desc': 'Sync clips to music', 'icon': Icons.music_note_rounded},
      {'name': 'Voice Clone', 'desc': 'Clone any voice', 'icon': Icons.record_voice_over_rounded},
      {'name': 'Color Grade', 'desc': 'Auto color grading', 'icon': Icons.color_lens_rounded},
    ];
    return Column(
      children: tools.map((t) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: PopCutCard(
            padding: const EdgeInsets.all(12),
            backgroundColor: PopCutColors.surface,
            onTap: () => Navigator.pop(context),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: PopCutColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(t['icon'] as IconData,
                      size: 20, color: PopCutColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t['name'] as String,
                          style: PopCutTypography.captionBold),
                      Text(t['desc'] as String,
                          style: PopCutTypography.caption),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    size: 20, color: PopCutColors.textMuted),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    _ensureProjectLoaded();
    final editor = context.watch<EditorProvider>();
    final engine = editor.engine;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            _buildTopBar(editor, engine),
            // Preview canvas
            Expanded(
              flex: 4,
              child: _buildPreviewCanvas(engine),
            ),
            // Playhead / seek bar
            PopCutPlayhead(
              position: engine.currentTime,
              totalDuration: engine.totalDuration,
              onSeek: (v) => engine.seek(v),
              height: 28,
            ),
            // Timeline
            Expanded(
              flex: 3,
              child: PopCutTimeline(
                tracks: engine.tracks,
                totalDuration: engine.totalDuration,
                playheadPosition: engine.currentTime,
                selectedClipId: engine.selectedClipId,
                selectedTrackId: engine.selectedTrackId,
                onPlayheadChanged: (p) => engine.seek(p),
                onClipTap: (clipId, trackId) =>
                    engine.selectClip(clipId, trackId),
                onCanvasTap: () => engine.deselectAll(),
              ),
            ),
            // Tool dock
            PopCutToolDock(
              activeTool: engine.activeTool,
              onToolTap: _openTool,
              items: _toolItems,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(EditorProvider editor, EditorEngine engine) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(
          bottom: BorderSide(
            color: PopCutColors.border.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded,
                color: PopCutColors.textPrimary, size: 22),
            onPressed: widget.onBack,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              editor.project?.name ?? 'Untitled',
              style: PopCutTypography.title.copyWith(fontSize: 15),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          _topBarButton(Icons.undo_rounded, () {}),
          _topBarButton(Icons.redo_rounded, () {}),
          const SizedBox(width: 4),
          Container(
            width: 1,
            height: 24,
            color: PopCutColors.border.withValues(alpha: 0.3),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () {
              final project = editor.project;
              if (project != null) widget.onExport(project.id);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [PopCutColors.primary, Color(0xFF00B4D8)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('Export',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: PopCutColors.background,
                  )),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }

  Widget _topBarButton(IconData icon, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: IconButton(
        icon: Icon(icon, color: PopCutColors.textSecondary, size: 18),
        onPressed: onTap,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      ),
    );
  }

  Widget _buildPreviewCanvas(EditorEngine engine) {
    return GestureDetector(
      onTap: () => engine.togglePlay(),
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: PopCutColors.border.withValues(alpha: 0.3),
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: PopCutColors.primary.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Canvas preview area
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFF0A0A0A),
              ),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: PopCutColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          engine.isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          size: 24,
                          color: PopCutColors.primary.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatTime(engine.currentTime),
                        style: PopCutTypography.caption.copyWith(
                          color: PopCutColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Current time indicator
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.access_time_rounded,
                        size: 10, color: PopCutColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      '${_formatTime(engine.currentTime)} / ${_formatTime(engine.totalDuration)}',
                      style: const TextStyle(
                        fontSize: 9,
                        color: PopCutColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(double seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toInt().toString().padLeft(2, '0');
    return '$m:$s';
  }
}
