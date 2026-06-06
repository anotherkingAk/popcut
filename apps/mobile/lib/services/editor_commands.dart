import 'editor_engine.dart';
import 'command_history.dart';
import '../models/project.dart';

class SplitClipCommand extends Command {
  final EditorEngine engine;
  final String? clipId;
  final double? splitTime;

  SplitClipCommand(this.engine, {this.clipId, this.splitTime});

  @override
  String get description => 'Split clip';

  @override
  void execute() => engine.splitClip();

  @override
  void undo() => engine.undoLastSplit();
}

class DeleteClipCommand extends Command {
  final EditorEngine engine;
  final String? clipId;
  final String? trackId;
  ClipModel? _deletedClip;
  int? _originalIndex;

  DeleteClipCommand(this.engine, {this.clipId, this.trackId});

  @override
  String get description => 'Delete clip';

  @override
  void execute() {
    if (clipId != null && trackId != null) {
      final track = engine.tracks.where((t) => t.id == trackId).firstOrNull;
      if (track != null) {
        final idx = track.clips.indexWhere((c) => c.id == clipId);
        if (idx >= 0) {
          _originalIndex = idx;
          _deletedClip = track.clips[idx];
        }
      }
    }
    engine.deleteClip();
  }

  @override
  void undo() {
    if (_deletedClip != null && trackId != null) {
      engine.restoreClip(_deletedClip!, trackId!, _originalIndex ?? 0);
    }
  }
}

class AddTrackCommand extends Command {
  final EditorEngine engine;
  final TrackType type;

  AddTrackCommand(this.engine, this.type);

  @override
  String get description => 'Add ${type.name} track';

  @override
  void execute() => engine.addTrack(type);

  @override
  void undo() => engine.removeLastTrack();
}

class MoveClipCommand extends Command {
  final EditorEngine engine;
  final String clipId;
  final String fromTrackId;
  final String toTrackId;
  final double fromTime;
  final double toTime;
  double _previousTime = 0;

  MoveClipCommand(
    this.engine,
    this.clipId,
    this.fromTrackId,
    this.toTrackId,
    this.fromTime,
    this.toTime,
  );

  @override
  String get description => 'Move clip';

  @override
  bool get canMerge => true;

  @override
  Command? mergeWith(Command other) {
    if (other is MoveClipCommand && other.clipId == clipId) {
      return MoveClipCommand(
        engine, clipId, fromTrackId, other.toTrackId, fromTime, other.toTime,
      );
    }
    return null;
  }

  @override
  void execute() {
    _previousTime = engine.currentTime;
    engine.moveClip(clipId, toTrackId, toTime);
  }

  @override
  void undo() {
    engine.moveClip(clipId, fromTrackId, fromTime);
    engine.seek(_previousTime);
  }
}

class EditPropertyCommand extends Command {
  final EditorEngine engine;
  final String clipId;
  final String property;
  final dynamic oldValue;
  final dynamic newValue;

  EditPropertyCommand(
    this.engine,
    this.clipId,
    this.property,
    this.oldValue,
    this.newValue,
  );

  @override
  String get description => 'Edit $property';

  @override
  bool get canMerge => true;

  @override
  Command? mergeWith(Command other) {
    if (other is EditPropertyCommand &&
        other.clipId == clipId &&
        other.property == property) {
      return EditPropertyCommand(
        engine, clipId, property, oldValue, other.newValue,
      );
    }
    return null;
  }

  @override
  void execute() => engine.setClipProperty(clipId, property, newValue);

  @override
  void undo() => engine.setClipProperty(clipId, property, oldValue);
}
