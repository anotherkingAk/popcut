enum SelectionState { idle, selected, editing, dragging }

enum TrackType { video, audio, text, graphic, effect }

enum ToolType {
  video, audio, text, effects, transitions, stickers, overlays, speed, adjust,
  filters, format, background, canvas, reverse, freeze,
  voiceFx, voiceover, denoise, beatSync, captions, lyrics,
  zoom3d, mask, chromaKey, retouch,
}

enum ProjectStatus { draft, exporting, done }

class Project {
  final String id;
  final String name;
  final DateTime updatedAt;
  final Duration duration;
  final ProjectStatus status;
  final String? thumbnailPath;
  final double aspectRatio;

  Project({
    required this.id,
    required this.name,
    DateTime? updatedAt,
    this.duration = const Duration(seconds: 30),
    this.status = ProjectStatus.draft,
    this.thumbnailPath,
    this.aspectRatio = 9 / 16,
  }) : updatedAt = updatedAt ?? DateTime.now();
}

class TrackModel {
  final String id;
  final String label;
  final TrackType type;
  final List<ClipModel> clips;
  bool locked;
  bool visible;
  double volume;

  TrackModel({
    required this.id,
    required this.label,
    required this.type,
    List<ClipModel>? clips,
    this.locked = false,
    this.visible = true,
    this.volume = 1.0,
  }) : clips = clips ?? [];
}

class ClipModel {
  final String id;
  final String name;
  double start;
  double end;
  final TrackType type;
  final String? filePath;

  ClipModel({
    required this.id,
    required this.name,
    required this.start,
    required this.end,
    required this.type,
    this.filePath,
  });

  Duration get duration => Duration(milliseconds: ((end - start) * 1000).toInt());
}

class ExportConfig {
  final int width;
  final int height;
  final int fps;
  final int bitrate;
  final String format;
  final int quality;
  final bool includeAudio;
  final bool includeProjectFile;

  const ExportConfig({
    this.width = 1920,
    this.height = 1080,
    this.fps = 30,
    this.bitrate = 8000,
    this.format = 'mp4',
    this.quality = 85,
    this.includeAudio = true,
    this.includeProjectFile = false,
  });

  ExportConfig copy() => ExportConfig(
    width: width,
    height: height,
    fps: fps,
    bitrate: bitrate,
    format: format,
    quality: quality,
    includeAudio: includeAudio,
    includeProjectFile: includeProjectFile,
  );
}
