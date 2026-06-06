import 'package:flutter/foundation.dart';
import '../services/command_history.dart';
import '../services/editor_commands.dart';
import '../services/editor_engine.dart';
import '../models/project.dart';

class CommandProvider extends ChangeNotifier {
  final CommandHistory history = CommandHistory();
  final EditorEngine engine;

  CommandProvider(this.engine);

  bool get canUndo => history.canUndo;
  bool get canRedo => history.canRedo;
  String? get undoDescription => history.undoDescription;
  String? get redoDescription => history.redoDescription;

  void splitClip() {
    history.execute(SplitClipCommand(engine));
    notifyListeners();
  }

  void deleteClip() {
    history.execute(DeleteClipCommand(
      engine,
      clipId: engine.selectedClipId,
      trackId: engine.selectedTrackId,
    ));
    notifyListeners();
  }

  void addTrack(TrackType type) {
    history.execute(AddTrackCommand(engine, type));
    notifyListeners();
  }

  void undo() {
    history.undo();
    notifyListeners();
  }

  void redo() {
    history.redo();
    notifyListeners();
  }

  void clearHistory() {
    history.clear();
    notifyListeners();
  }
}
