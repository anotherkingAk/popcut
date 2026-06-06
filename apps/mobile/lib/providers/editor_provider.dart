import 'package:flutter/foundation.dart';
import '../services/editor_engine.dart';
import '../models/project.dart';

class PlaybackNotifier extends ChangeNotifier {
  final EditorEngine _engine;
  PlaybackNotifier(this._engine);

  double get currentTime => _engine.currentTime;
  bool get isPlaying => _engine.isPlaying;

  void seek(double time) {
    _engine.seek(time);
    notifyListeners();
  }

  void togglePlay() {
    _engine.togglePlay();
    notifyListeners();
  }
}

class SelectionNotifier extends ChangeNotifier {
  final EditorEngine _engine;
  SelectionNotifier(this._engine);

  String? get selectedClipId => _engine.selectedClipId;
  String? get selectedTrackId => _engine.selectedTrackId;
  SelectionState get selectionState => _engine.selectionState;

  void selectClip(String clipId, String trackId) {
    _engine.selectClip(clipId, trackId);
    notifyListeners();
  }

  void deselectAll() {
    _engine.deselectAll();
    notifyListeners();
  }
}

class TimelineNotifier extends ChangeNotifier {
  final EditorEngine _engine;
  TimelineNotifier(this._engine);

  List<TrackModel> get tracks => _engine.tracks;
  double get totalDuration => _engine.totalDuration;

  void splitClip() {
    _engine.splitClip();
    notifyListeners();
  }

  void deleteClip() {
    _engine.deleteClip();
    notifyListeners();
  }

  void addTrack(TrackType type) {
    _engine.addTrack(type);
    notifyListeners();
  }

  void toggleTrackVisibility(String id) {
    _engine.toggleTrackVisibility(id);
    notifyListeners();
  }

  void toggleTrackLock(String id) {
    _engine.toggleTrackLock(id);
    notifyListeners();
  }
}

class ToolNotifier extends ChangeNotifier {
  final EditorEngine _engine;
  ToolNotifier(this._engine);

  ToolType? get activeTool => _engine.activeTool;

  void setActiveTool(ToolType? tool) {
    _engine.setActiveTool(tool);
    notifyListeners();
  }
}

class EditorProvider extends ChangeNotifier {
  final EditorEngine _engine = EditorEngine();
  Project? _project;
  bool _isInitialized = false;

  EditorEngine get engine => _engine;
  Project? get project => _project;
  bool get isInitialized => _isInitialized;

  late final PlaybackNotifier playback;
  late final SelectionNotifier selection;
  late final TimelineNotifier timeline;
  late final ToolNotifier tool;

  EditorProvider() {
    playback = PlaybackNotifier(_engine);
    selection = SelectionNotifier(_engine);
    timeline = TimelineNotifier(_engine);
    tool = ToolNotifier(_engine);
  }

  void loadProject(Project project) {
    _project = project;
    _engine.loadProject(project);
    _isInitialized = true;
    notifyListeners();
  }

  @override
  void dispose() {
    playback.dispose();
    selection.dispose();
    timeline.dispose();
    tool.dispose();
    _engine.dispose();
    super.dispose();
  }
}
