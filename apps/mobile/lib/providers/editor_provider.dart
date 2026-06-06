import 'package:flutter/foundation.dart';
import '../services/editor_engine.dart';
import '../models/project.dart';

class EditorProvider extends ChangeNotifier {
  final EditorEngine _engine = EditorEngine();
  Project? _project;
  bool _isInitialized = false;

  EditorEngine get engine => _engine;
  Project? get project => _project;
  bool get isInitialized => _isInitialized;

  void loadProject(Project project) {
    _project = project;
    _engine.loadProject(project);
    _isInitialized = true;
    notifyListeners();
  }

  void seek(double time) {
    _engine.seek(time);
    notifyListeners();
  }

  void togglePlay() {
    _engine.togglePlay();
    notifyListeners();
  }

  void selectClip(String clipId, String trackId) {
    _engine.selectClip(clipId, trackId);
    notifyListeners();
  }

  void deselectAll() {
    _engine.deselectAll();
    notifyListeners();
  }

  void setActiveTool(ToolType? tool) {
    _engine.setActiveTool(tool);
    notifyListeners();
  }

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

  @override
  void dispose() {
    _engine.dispose();
    super.dispose();
  }
}
