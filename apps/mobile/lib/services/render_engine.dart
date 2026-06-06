import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/project.dart';

enum RenderState { idle, preparing, rendering, completed, failed }

class RenderPreset {
  final String name;
  final int width;
  final int height;
  final int fps;
  final int bitrate;
  final String format;

  const RenderPreset({
    required this.name,
    required this.width,
    required this.height,
    required this.fps,
    required this.bitrate,
    required this.format,
  });
}

class RenderEngine extends ChangeNotifier {
  RenderState _state = RenderState.idle;
  double _progress = 0.0;
  String _stage = '';
  Duration? _estimatedRemaining;
  String? _outputPath;
  String? _errorMessage;
  Timer? _renderTimer;
  bool _cancelled = false;

  RenderState get state => _state;
  double get progress => _progress;
  String get stage => _stage;
  Duration? get estimatedRemaining => _estimatedRemaining;
  String? get outputPath => _outputPath;
  String? get errorMessage => _errorMessage;

  static const List<String> _stages = [
    'Analyzing',
    'Encoding Video',
    'Encoding Audio',
    'Muxing',
    'Finalizing',
  ];

  static const Map<String, RenderPreset> _presets = {
    'Social': RenderPreset(name: 'Social', width: 1080, height: 1920, fps: 30, bitrate: 6000, format: 'mp4'),
    'Cinema': RenderPreset(name: 'Cinema', width: 3840, height: 2160, fps: 24, bitrate: 40000, format: 'mp4'),
    'Web': RenderPreset(name: 'Web', width: 1280, height: 720, fps: 30, bitrate: 2500, format: 'mp4'),
    'GIF': RenderPreset(name: 'GIF', width: 480, height: 480, fps: 15, bitrate: 1000, format: 'gif'),
  };

  RenderPreset getPreset(String name) {
    return _presets[name] ?? _presets['Web']!;
  }

  Future<String?> exportProject(Project project, ExportConfig config) async {
    if (_state == RenderState.rendering) return null;

    _cancelled = false;
    _state = RenderState.preparing;
    _progress = 0.0;
    _stage = 'Analyzing';
    _estimatedRemaining = const Duration(seconds: 8);
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 400));
    if (_cancelled) return _cancelCleanup();

    _state = RenderState.rendering;
    notifyListeners();

    const totalSteps = 15;
    final rng = Random();
    final stepDurations = List.generate(totalSteps, (_) => 300 + rng.nextInt(500));

    for (int step = 0; step < totalSteps; step++) {
      if (_cancelled) return _cancelCleanup();

      _progress = (step + 1) / totalSteps;
      _stage = _stages[(step * _stages.length) ~/ totalSteps];
      _estimatedRemaining = Duration(
        milliseconds: stepDurations.skip(step).fold(0, (a, b) => a + b),
      );
      notifyListeners();

      await Future.delayed(Duration(milliseconds: stepDurations[step]));
    }

    if (_cancelled) return _cancelCleanup();

    _outputPath = '/exports/${project.name}_${DateTime.now().millisecondsSinceEpoch}.${config.format}';
    _progress = 1.0;
    _stage = 'Finalizing';
    _state = RenderState.completed;
    _estimatedRemaining = Duration.zero;
    notifyListeners();

    return _outputPath;
  }

  String? _cancelCleanup() {
    _state = RenderState.idle;
    _progress = 0.0;
    _stage = '';
    _estimatedRemaining = null;
    _outputPath = null;
    notifyListeners();
    return null;
  }

  void cancel() {
    _cancelled = true;
    _renderTimer?.cancel();
    _renderTimer = null;
    _state = RenderState.idle;
    _progress = 0.0;
    _stage = '';
    _estimatedRemaining = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _renderTimer?.cancel();
    super.dispose();
  }
}
