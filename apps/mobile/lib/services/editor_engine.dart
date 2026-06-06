import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/project.dart';

class EditorEngine extends ChangeNotifier {
  final List<TrackModel> tracks = [];
  double _currentTime = 0;
  double _totalDuration = 60;
  bool _isPlaying = false;
  String? _selectedClipId;
  String? _selectedTrackId;
  SelectionState _selectionState = SelectionState.idle;
  ToolType? _activeTool;

  double get currentTime => _currentTime;
  double get totalDuration => _totalDuration;
  bool get isPlaying => _isPlaying;
  String? get selectedClipId => _selectedClipId;
  String? get selectedTrackId => _selectedTrackId;
  SelectionState get selectionState => _selectionState;
  ToolType? get activeTool => _activeTool;

  Timer? _playbackTimer;
  DateTime? _playStartTime;
  double _playStartTimeOffset = 0;

  void loadProject(Project project) {
    _totalDuration = project.duration.inSeconds.toDouble();
    tracks.clear();
    tracks.addAll([
      TrackModel(id: 'v1', label: 'Video 1', type: TrackType.video, clips: [
        ClipModel(id: 'c1', name: 'clip_1.mp4', start: 2, end: 15, type: TrackType.video),
        ClipModel(id: 'c2', name: 'clip_2.mp4', start: 18, end: 32, type: TrackType.video),
      ]),
      TrackModel(id: 'v2', label: 'Video 2', type: TrackType.video),
      TrackModel(id: 'a1', label: 'Audio 1', type: TrackType.audio, clips: [
        ClipModel(id: 'c3', name: 'background.mp3', start: 0, end: 30, type: TrackType.audio),
      ]),
      TrackModel(id: 't1', label: 'Text', type: TrackType.text, clips: [
        ClipModel(id: 'c4', name: 'Hello World', start: 5, end: 12, type: TrackType.text),
      ]),
      TrackModel(id: 'e1', label: 'Effect', type: TrackType.effect),
    ]);
    notifyListeners();
  }

  void seek(double time) {
    _currentTime = time.clamp(0, _totalDuration);
    notifyListeners();
  }

  void togglePlay() {
    if (_isPlaying) {
      pause();
    } else {
      play();
    }
  }

  void play() {
    if (_currentTime >= _totalDuration) _currentTime = 0;
    _isPlaying = true;
    _playStartTime = DateTime.now();
    _playStartTimeOffset = _currentTime;
    _playbackTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      final elapsed = DateTime.now().difference(_playStartTime!).inMilliseconds / 1000;
      _currentTime = (_playStartTimeOffset + elapsed).clamp(0, _totalDuration);
      if (_currentTime >= _totalDuration) {
        _currentTime = _totalDuration;
        pause();
      }
      notifyListeners();
    });
    notifyListeners();
  }

  void pause() {
    _isPlaying = false;
    _playbackTimer?.cancel();
    _playbackTimer = null;
    notifyListeners();
  }

  void selectClip(String clipId, String trackId) {
    if (_selectionState == SelectionState.idle) {
      _selectionState = SelectionState.selected;
      _selectedClipId = clipId;
      _selectedTrackId = trackId;
    } else if (_selectionState == SelectionState.selected && _selectedClipId == clipId) {
      _selectionState = SelectionState.editing;
    } else {
      _selectionState = SelectionState.selected;
      _selectedClipId = clipId;
      _selectedTrackId = trackId;
    }
    notifyListeners();
  }

  void deselectAll() {
    _selectionState = SelectionState.idle;
    _selectedClipId = null;
    _selectedTrackId = null;
    notifyListeners();
  }

  void setActiveTool(ToolType? tool) {
    _activeTool = _activeTool == tool ? null : tool;
    notifyListeners();
  }

  void splitClip() {
    if (_selectedClipId == null || _selectedTrackId == null) return;
    final track = tracks.where((t) => t.id == _selectedTrackId).firstOrNull;
    if (track == null) return;
    final clipIdx = track.clips.indexWhere((c) => c.id == _selectedClipId);
    if (clipIdx == -1) return;
    final clip = track.clips[clipIdx];
    if (_currentTime <= clip.start || _currentTime >= clip.end) return;
    final newId = '${clip.id}_split';
    final newClip = ClipModel(
      id: newId,
      name: clip.name,
      start: _currentTime,
      end: clip.end,
      type: clip.type,
    );
    clip.end = _currentTime;
    track.clips.insert(clipIdx + 1, newClip);
    notifyListeners();
  }

  void undoLastSplit() {
    if (_selectedClipId == null || _selectedTrackId == null) return;
    final track = tracks.where((t) => t.id == _selectedTrackId).firstOrNull;
    if (track == null) return;
    final splitClipIdx = track.clips.indexWhere((c) => c.id == _selectedClipId);
    if (splitClipIdx <= 0) return;
    final splitClip = track.clips[splitClipIdx];
    if (!splitClip.id.endsWith('_split')) return;
    final prevClip = track.clips[splitClipIdx - 1];
    prevClip.end = splitClip.end;
    track.clips.removeAt(splitClipIdx);
    notifyListeners();
  }

  void deleteClip() {
    if (_selectedClipId == null || _selectedTrackId == null) return;
    final track = tracks.where((t) => t.id == _selectedTrackId).firstOrNull;
    if (track == null) return;
    track.clips.removeWhere((c) => c.id == _selectedClipId);
    deselectAll();
  }

  void addTrack(TrackType type) {
    final count = tracks.where((t) => t.type == type).length + 1;
    final label = switch (type) {
      TrackType.video => 'Video $count',
      TrackType.audio => 'Audio $count',
      TrackType.text => 'Text $count',
      TrackType.graphic => 'Graphic $count',
      TrackType.effect => 'Effect $count',
    };
    tracks.add(TrackModel(id: '${type.name}_$count', label: label, type: type));
    notifyListeners();
  }

  void removeTrack(String id) {
    tracks.removeWhere((t) => t.id == id);
    if (_selectedTrackId == id) deselectAll();
    notifyListeners();
  }

  void removeLastTrack() {
    if (tracks.isNotEmpty) {
      tracks.removeLast();
      notifyListeners();
    }
  }

  void toggleTrackVisibility(String id) {
    final track = tracks.where((t) => t.id == id).firstOrNull;
    if (track != null) {
      track.visible = !track.visible;
      notifyListeners();
    }
  }

  void toggleTrackLock(String id) {
    final track = tracks.where((t) => t.id == id).firstOrNull;
    if (track != null) {
      track.locked = !track.locked;
      notifyListeners();
    }
  }

  void moveClip(String clipId, String toTrackId, double toTime) {
    String? fromTrackId;
    int clipIndex = -1;
    ClipModel? clip;

    for (final track in tracks) {
      final idx = track.clips.indexWhere((c) => c.id == clipId);
      if (idx >= 0) {
        fromTrackId = track.id;
        clipIndex = idx;
        clip = track.clips[idx];
        break;
      }
    }

    if (clip == null || fromTrackId == null) return;

    final fromTrack = tracks.where((t) => t.id == fromTrackId).first;
    fromTrack.clips.removeAt(clipIndex);

    final toTrack = tracks.where((t) => t.id == toTrackId).first;
    clip.start = toTime;
    clip.end = toTime + (clip.end - clip.start);
    toTrack.clips.add(clip);
    notifyListeners();
  }

  void setClipProperty(String clipId, String property, dynamic value) {
    for (final track in tracks) {
      for (final clip in track.clips) {
        if (clip.id == clipId) {
          switch (property) {
            case 'start':
              clip.start = (value as num).toDouble();
              break;
            case 'end':
              clip.end = (value as num).toDouble();
              break;
          }
          notifyListeners();
          return;
        }
      }
    }
  }

  void restoreClip(ClipModel clip, String trackId, int index) {
    final track = tracks.where((t) => t.id == trackId).firstOrNull;
    if (track != null) {
      track.clips.insert(index, clip);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _playbackTimer?.cancel();
    super.dispose();
  }
}
