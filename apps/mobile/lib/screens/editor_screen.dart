import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../theme/app_motion.dart';
import '../models/project.dart';
import '../services/editor_engine.dart';
import '../providers/editor_provider.dart';
import '../services/project_service.dart';
import '../widgets/editor/contextual_toolbar.dart';
import '../widgets/editor/preview_canvas.dart';
import '../widgets/editor/timeline/timeline_zone.dart';
import '../widgets/editor/tool_dock.dart';
import '../widgets/editor/properties_panel.dart';
import '../widgets/editor/seek_bar.dart';
import '../widgets/editor/panels/color_grading_panel.dart';
import '../widgets/editor/panels/text_editor_panel.dart';
import '../widgets/editor/panels/effects_panel.dart';
import '../widgets/editor/panels/audio_panel.dart';
import '../widgets/editor/panels/speed_panel.dart';
import '../widgets/editor/panels/filter_panel.dart';
import '../widgets/editor/panels/transition_panel.dart';
import '../widgets/editor/panels/chroma_key_panel.dart';
import '../widgets/editor/panels/mask_panel.dart';
import '../widgets/editor/panels/retouch_panel.dart';
import '../widgets/editor/panels/beat_sync_panel.dart';
import '../widgets/editor/panels/zoom3d_panel.dart';
import '../widgets/editor/panels/stickers_grid.dart';
import '../widgets/editor/panels/overlays_panel.dart';
import '../widgets/editor/panels/lyrics_panel.dart';
import '../widgets/editor/panels/voiceover_panel.dart';
import '../widgets/editor/panels/voice_effects_panel.dart';
import '../widgets/editor/panels/denoise_panel.dart';
import '../widgets/editor/panels/reverse_panel.dart';
import '../widgets/editor/panels/freeze_panel.dart';
import '../widgets/editor/panels/background_panel.dart';
import '../widgets/editor/panels/canvas_panel.dart';
import '../widgets/editor/panels/format_panel.dart';
import '../widgets/editor/panels/adjust_panel.dart';
import '../widgets/editor/ai_captioning_wizard.dart';

class EditorScreen extends StatefulWidget {
  final String? projectId;
  final VoidCallback onBack;
  final void Function(String projectId) onExport;

  const EditorScreen({
    super.key,
    this.projectId,
    required this.onBack,
    required this.onExport,
  });

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> with TickerProviderStateMixin {
  late AnimationController _panelAnimController;
  late AnimationController _staggerController;
  late Animation<double> _panelSlide;
  bool _hasInitializedProject = false;

  @override
  void initState() {
    super.initState();
    _panelAnimController = AnimationController(vsync: this, duration: AppMotion.panelOpen);
    _staggerController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _panelSlide = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _panelAnimController, curve: AppMotion.easeOutCubic),
    );
  }

  void _ensureProjectLoaded() {
    if (_hasInitializedProject) return;
    _hasInitializedProject = true;
    final editor = context.read<EditorProvider>();
    if (editor.isInitialized) return;
    final projects = context.read<ProjectService>();
    final project = widget.projectId != null
        ? projects.getProject(widget.projectId!)
        : projects.projects.isNotEmpty ? projects.projects.first : null;
    editor.loadProject(project ?? Project(id: 'new', name: 'Untitled Project'));
  }

  @override
  void dispose() {
    _panelAnimController.dispose();
    _staggerController.dispose();
    super.dispose();
  }

  void _openTool(ToolType tool) {
    final editor = context.read<EditorProvider>();
    final wasClosed = editor.tool.activeTool == null;
    editor.tool.setActiveTool(tool);
    if (wasClosed) {
      _panelAnimController.forward(from: 0);
      _staggerController.forward(from: 0);
    } else if (editor.tool.activeTool == null) {
      _panelAnimController.reverse();
    }
  }

  void _onExport() {
    final editor = context.read<EditorProvider>();
    final project = editor.project;
    if (project != null) widget.onExport(project.id);
  }

  @override
  Widget build(BuildContext context) {
    _ensureProjectLoaded();
    final editor = context.read<EditorProvider>();
    final engine = editor.engine;
    final hasPanelOpen = editor.tool.activeTool != null;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Selector<SelectionNotifier, SelectionState>(
              selector: (_, s) => s.selectionState,
              builder: (_, selectionState, _) {
                final clipName = _selectedClipName(context.read<SelectionNotifier>());
                return ContextualToolbar(
                  selectionState: selectionState,
                  selectedClipName: clipName,
                  onBack: widget.onBack,
                  onExport: _onExport,
                  onUndo: () {},
                  onRedo: () {},
                );
              },
            ),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Selector<PlaybackNotifier, bool>(
                            selector: (_, p) => p.isPlaying,
                            builder: (_, isPlaying, _) {
                              final selectionState = context.select<SelectionNotifier, SelectionState>((s) => s.selectionState);
                              return _buildPreviewArea(isPlaying, selectionState, engine);
                            },
                          ),
                        ),
                        Selector<PlaybackNotifier, double>(
                          selector: (_, p) => p.currentTime,
                          builder: (_, currentTime, _) => SeekBar(
                            currentPosition: currentTime,
                            totalDuration: engine.totalDuration,
                            onSeek: (v) => engine.seek(v),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: hasPanelOpen
                              ? _buildPanelLayout(engine)
                              : Selector<TimelineNotifier, List<TrackModel>>(
                                  selector: (_, t) => t.tracks,
                                  builder: (_, tracks, _) {
                                    final playback = context.read<PlaybackNotifier>();
                                    final selection = context.read<SelectionNotifier>();
                                    return TimelineZone(
                                      tracks: tracks,
                                      totalDuration: engine.totalDuration,
                                      playheadPosition: playback.currentTime,
                                      selectedClipId: selection.selectedClipId,
                                      selectedTrackId: selection.selectedTrackId,
                                      selectionState: selection.selectionState,
                                      onPlayheadChanged: (p) => playback.seek(p),
                                      onClipTap: (clipId, trackId) {
                                        selection.selectClip(clipId, trackId);
                                      },
                                      onCanvasTap: () {
                                        selection.deselectAll();
                                      },
                                      onSplit: () => engine.splitClip(),
                                      onDelete: () => engine.deleteClip(),
                                      onAddTrack: (type) => engine.addTrack(type),
                                      onToggleVisibility: (id) => engine.toggleTrackVisibility(id),
                                      onToggleLock: (id) => engine.toggleTrackLock(id),
                                    );
                                  },
                                ),
                        ),
                        if (!hasPanelOpen)
                          Selector<ToolNotifier, ToolType?>(
                            selector: (_, t) => t.activeTool,
                            builder: (_, activeTool, _) => ToolDock(activeTool: activeTool, onToolTap: _openTool),
                          ),
                      ],
                    ),
                  ),
                  Selector<SelectionNotifier, String?>(
                    selector: (_, s) => s.selectedClipId,
                    builder: (_, selectedClipId, _) {
                      if (selectedClipId == null) return const SizedBox.shrink();
                      final selection = context.read<SelectionNotifier>();
                      final trackType = _findTrackType(selection.selectedTrackId, engine);
                      return PropertiesPanel(
                        clip: _findClip(selection.selectedClipId, selection.selectedTrackId, engine),
                        trackType: trackType,
                        onClose: () => selection.deselectAll(),
                      );
                    },
                  ),
                ],
              ),
            ),
            if (hasPanelOpen)
              Selector<ToolNotifier, ToolType?>(
                selector: (_, t) => t.activeTool,
                builder: (_, activeTool, _) => ToolDock(activeTool: activeTool, onToolTap: _openTool),
              ),
          ],
        ),
      ),
    );
  }

  ClipModel? _findClip(String? clipId, String? trackId, EditorEngine engine) {
    if (clipId == null || trackId == null) return null;
    final track = engine.tracks.where((t) => t.id == trackId).firstOrNull;
    return track?.clips.where((c) => c.id == clipId).firstOrNull;
  }

  TrackType? _findTrackType(String? trackId, EditorEngine engine) {
    if (trackId == null) return null;
    return engine.tracks.where((t) => t.id == trackId).firstOrNull?.type;
  }

  String? _selectedClipName(SelectionNotifier selection) {
    if (selection.selectedClipId == null || selection.selectedTrackId == null) return null;
    final track = context.read<EditorProvider>().engine.tracks.where((t) => t.id == selection.selectedTrackId).firstOrNull;
    return track?.clips.where((c) => c.id == selection.selectedClipId).firstOrNull?.name;
  }

  Widget _buildPreviewArea(bool isPlaying, SelectionState selectionState, EditorEngine engine) {
    return PreviewCanvas(
      isPlaying: isPlaying,
      onTap: () {
        if (selectionState != SelectionState.idle) engine.deselectAll();
      },
      onTogglePlay: () => engine.togglePlay(),
      selectionState: selectionState,
    );
  }

  Widget _buildPanelLayout(EditorEngine engine) {
    return Column(
      children: [
        Expanded(
          child: AnimatedBuilder(
            animation: _panelSlide,
            builder: (context, child) {
              return FractionallySizedBox(
                heightFactor: 0.45,
                child: Transform.translate(
                  offset: Offset(0, _panelSlide.value * 200),
                  child: child,
                ),
              );
            },
            child: _buildActivePanel(engine),
          ),
        ),
        SizedBox(
          height: 48,
          child: Selector<ToolNotifier, ToolType?>(
            selector: (_, t) => t.activeTool,
            builder: (_, activeTool, _) => ToolDock(activeTool: activeTool, onToolTap: _openTool),
          ),
        ),
      ],
    );
  }

  Widget _buildActivePanel(EditorEngine engine) {
    switch (engine.activeTool) {
      case ToolType.video:
        return AdjustPanel(staggerController: _staggerController);
      case ToolType.audio:
        return AudioPanel(staggerController: _staggerController);
      case ToolType.text:
        return TextEditorPanel(staggerController: _staggerController);
      case ToolType.effects:
        return EffectsPanel(staggerController: _staggerController);
      case ToolType.transitions:
        return TransitionPanel(staggerController: _staggerController);
      case ToolType.stickers:
        return StickersGrid(staggerController: _staggerController);
      case ToolType.overlays:
        return OverlaysPanel(staggerController: _staggerController);
      case ToolType.speed:
        return SpeedPanel(staggerController: _staggerController);
      case ToolType.adjust:
        return ColorGradingPanel(staggerController: _staggerController);
      case ToolType.filters:
        return FilterPanel(staggerController: _staggerController);
      case ToolType.format:
        return FormatPanel(staggerController: _staggerController);
      case ToolType.background:
        return BackgroundPanel(staggerController: _staggerController);
      case ToolType.canvas:
        return CanvasPanel(staggerController: _staggerController);
      case ToolType.reverse:
        return ReversePanel(staggerController: _staggerController);
      case ToolType.freeze:
        return FreezePanel(staggerController: _staggerController);
      case ToolType.voiceFx:
        return VoiceEffectsPanel(staggerController: _staggerController);
      case ToolType.voiceover:
        return VoiceoverPanel(staggerController: _staggerController);
      case ToolType.denoise:
        return DenoisePanel(staggerController: _staggerController);
      case ToolType.beatSync:
        return BeatSyncPanel(staggerController: _staggerController);
      case ToolType.captions:
        return AiCaptioningWizard(onClose: () => _openTool(ToolType.captions));
      case ToolType.lyrics:
        return LyricsPanel(staggerController: _staggerController);
      case ToolType.zoom3d:
        return Zoom3DPanel(staggerController: _staggerController);
      case ToolType.mask:
        return MaskPanel(staggerController: _staggerController);
      case ToolType.chromaKey:
        return ChromaKeyPanel(staggerController: _staggerController);
      case ToolType.retouch:
        return RetouchPanel(staggerController: _staggerController);
      default:
        return Container(
          color: AppColors.bgElevated,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.construction, size: 32, color: AppColors.textLow),
                const SizedBox(height: 8),
                Text('${engine.activeTool?.name ?? ''} panel', style: AppTypography.bodySm),
              ],
            ),
          ),
        );
    }
  }
}
