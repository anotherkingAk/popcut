import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';

enum AssetType { template, font, effect, transition, overlay, soundtrack, lut }

enum DownloadStatus { notDownloaded, downloading, paused, completed, failed }

class AssetItem {
  final String id;
  final AssetType type;
  final String name;
  final String? thumbnailUrl;
  final int sizeBytes;
  final bool isPro;
  final String? downloadUrl;
  bool isDownloaded;
  double downloadProgress;
  DownloadStatus status;

  AssetItem({
    required this.id,
    required this.type,
    required this.name,
    this.thumbnailUrl,
    required this.sizeBytes,
    this.isPro = false,
    this.downloadUrl,
    this.isDownloaded = false,
    this.downloadProgress = 0.0,
    this.status = DownloadStatus.notDownloaded,
  });
}

class AssetService extends ChangeNotifier {
  final List<AssetItem> _assets = [];
  final List<AssetItem> _downloading = [];
  final StreamController<AssetItem> _progressController =
      StreamController<AssetItem>.broadcast();
  final Map<String, Timer> _downloadTimers = {};
  final Map<String, Completer<void>> _downloadCompleters = {};

  Stream<AssetItem> get downloadProgressStream => _progressController.stream;

  int get totalCacheSize => 2400000000;
  int get maxCacheSize => 10000000000;

  AssetService() {
    _initMockAssets();
  }

  void _initMockAssets() {
    _assets.addAll([
      AssetItem(
        id: 'tpl_01',
        type: AssetType.template,
        name: 'Modern Intro',
        thumbnailUrl: 'assets/thumbnails/modern_intro.jpg',
        sizeBytes: 45000000,
        isPro: false,
      ),
      AssetItem(
        id: 'tpl_02',
        type: AssetType.template,
        name: 'Cinematic Opener',
        thumbnailUrl: 'assets/thumbnails/cinematic_opener.jpg',
        sizeBytes: 62000000,
        isPro: true,
      ),
      AssetItem(
        id: 'tpl_03',
        type: AssetType.template,
        name: 'Vlog Highlights',
        thumbnailUrl: 'assets/thumbnails/vlog_highlights.jpg',
        sizeBytes: 38000000,
        isPro: false,
      ),
      AssetItem(
        id: 'fnt_01',
        type: AssetType.font,
        name: 'Montserrat',
        sizeBytes: 180000,
        isPro: false,
      ),
      AssetItem(
        id: 'fnt_02',
        type: AssetType.font,
        name: 'Playfair Display',
        sizeBytes: 240000,
        isPro: true,
      ),
      AssetItem(
        id: 'fx_01',
        type: AssetType.effect,
        name: 'Glitch Transition',
        thumbnailUrl: 'assets/thumbnails/glitch.jpg',
        sizeBytes: 3200000,
        isPro: false,
      ),
      AssetItem(
        id: 'fx_02',
        type: AssetType.effect,
        name: 'Light Leaks',
        thumbnailUrl: 'assets/thumbnails/light_leaks.jpg',
        sizeBytes: 5100000,
        isPro: true,
      ),
      AssetItem(
        id: 'fx_03',
        type: AssetType.effect,
        name: 'VHS Distortion',
        thumbnailUrl: 'assets/thumbnails/vhs.jpg',
        sizeBytes: 2800000,
        isPro: false,
      ),
      AssetItem(
        id: 'tr_01',
        type: AssetType.transition,
        name: 'Smooth Slide',
        thumbnailUrl: 'assets/thumbnails/smooth_slide.jpg',
        sizeBytes: 1200000,
        isPro: false,
      ),
      AssetItem(
        id: 'tr_02',
        type: AssetType.transition,
        name: 'Zoom Blur',
        thumbnailUrl: 'assets/thumbnails/zoom_blur.jpg',
        sizeBytes: 1800000,
        isPro: true,
      ),
      AssetItem(
        id: 'ov_01',
        type: AssetType.overlay,
        name: 'Film Grain',
        thumbnailUrl: 'assets/thumbnails/film_grain.jpg',
        sizeBytes: 890000,
        isPro: false,
      ),
      AssetItem(
        id: 'snd_01',
        type: AssetType.soundtrack,
        name: 'Ambient Chill',
        sizeBytes: 8500000,
        isPro: true,
      ),
    ]);
  }

  Future<void> download(AssetItem item) async {
    if (item.status == DownloadStatus.downloading) return;

    item.status = DownloadStatus.downloading;
    item.downloadProgress = 0.0;
    _downloading.add(item);
    notifyListeners();

    final completer = Completer<void>();
    _downloadCompleters[item.id] = completer;

    final rng = Random();
    final duration = 2000 + rng.nextInt(3000);
    final interval = 50;
    final steps = duration ~/ interval;
    final increment = 1.0 / steps;

    int currentStep = 0;
    _downloadTimers[item.id] = Timer.periodic(Duration(milliseconds: interval), (timer) {
      if (item.status == DownloadStatus.paused) return;

      currentStep++;
      item.downloadProgress = (currentStep * increment).clamp(0.0, 1.0);
      _progressController.add(item);
      notifyListeners();

      if (item.downloadProgress >= 1.0) {
        timer.cancel();
        _downloadTimers.remove(item.id);
        item.status = DownloadStatus.completed;
        item.isDownloaded = true;
        item.downloadProgress = 1.0;
        _downloading.remove(item);
        _downloadCompleters.remove(item.id);
        _progressController.add(item);
        notifyListeners();
        completer.complete();
      }
    });

    return completer.future;
  }

  void pause(AssetItem item) {
    if (item.status != DownloadStatus.downloading) return;
    item.status = DownloadStatus.paused;
    notifyListeners();
  }

  void resume(AssetItem item) {
    if (item.status != DownloadStatus.paused) return;
    item.status = DownloadStatus.downloading;
    notifyListeners();
  }

  void cancel(AssetItem item) {
    _downloadTimers[item.id]?.cancel();
    _downloadTimers.remove(item.id);
    _downloadCompleters[item.id]?.complete();
    _downloadCompleters.remove(item.id);
    item.status = DownloadStatus.notDownloaded;
    item.downloadProgress = 0.0;
    _downloading.remove(item);
    notifyListeners();
  }

  void delete(AssetItem item) {
    item.isDownloaded = false;
    item.status = DownloadStatus.notDownloaded;
    item.downloadProgress = 0.0;
    notifyListeners();
  }

  List<AssetItem> getDownloadsByType(AssetType type) {
    return _assets.where((a) => a.type == type).toList();
  }

  Future<void> clearCache() async {
    for (final asset in _assets) {
      cancel(asset);
      asset.isDownloaded = false;
      asset.status = DownloadStatus.notDownloaded;
      asset.downloadProgress = 0.0;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    for (final timer in _downloadTimers.values) {
      timer.cancel();
    }
    _downloadTimers.clear();
    _progressController.close();
    super.dispose();
  }
}
