import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/project.dart';

enum SyncStatus { synced, syncing, pending, conflict, offline, error }

enum SyncDirection { upload, download, both }

class SyncChange {
  final String projectId;
  final String description;
  final DateTime timestamp;
  final SyncDirection direction;

  const SyncChange({
    required this.projectId,
    required this.description,
    required this.timestamp,
    required this.direction,
  });
}

class CloudSyncService extends ChangeNotifier {
  SyncStatus _status = SyncStatus.synced;
  bool _isEnabled = true;
  DateTime? _lastSync;
  int _pendingChanges = 2;
  final List<SyncChange> _changeHistory = [];
  final StreamController<SyncStatus> _syncStreamController =
      StreamController<SyncStatus>.broadcast();

  SyncStatus get status => _status;
  bool get isEnabled => _isEnabled;
  DateTime? get lastSync => _lastSync;
  int get pendingChanges => _pendingChanges;
  List<SyncChange> get changeHistory => List.unmodifiable(_changeHistory);
  Stream<SyncStatus> get syncStream => _syncStreamController.stream;

  CloudSyncService() {
    _lastSync = DateTime.now().subtract(const Duration(hours: 2));
    _changeHistory.addAll([
      SyncChange(
        projectId: 'p1',
        description: 'Modified timeline',
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        direction: SyncDirection.upload,
      ),
      SyncChange(
        projectId: 'p3',
        description: 'Added overlay',
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        direction: SyncDirection.upload,
      ),
    ]);
  }

  Future<void> syncProject(Project project) async {
    _status = SyncStatus.syncing;
    notifyListeners();
    _syncStreamController.add(_status);

    final rng = Random();
    await Future.delayed(Duration(milliseconds: 500 + rng.nextInt(1500)));

    _changeHistory.insert(
      0,
      SyncChange(
        projectId: project.id,
        description: 'Synced project "${project.name}"',
        timestamp: DateTime.now(),
        direction: SyncDirection.upload,
      ),
    );
    _pendingChanges = (_pendingChanges - 1).clamp(0, 999);
    _lastSync = DateTime.now();
    _status = SyncStatus.synced;
    notifyListeners();
    _syncStreamController.add(_status);
  }

  Future<void> syncAll() async {
    _status = SyncStatus.syncing;
    notifyListeners();
    _syncStreamController.add(_status);

    final rng = Random();
    await Future.delayed(Duration(milliseconds: 500 + rng.nextInt(1500)));

    _pendingChanges = 0;
    _lastSync = DateTime.now();
    _status = SyncStatus.synced;
    notifyListeners();
    _syncStreamController.add(_status);
  }

  void enableSync() {
    _isEnabled = true;
    _status = SyncStatus.synced;
    notifyListeners();
    _syncStreamController.add(_status);
  }

  void disableSync() {
    _isEnabled = false;
    _status = SyncStatus.offline;
    notifyListeners();
    _syncStreamController.add(_status);
  }

  Future<bool> resolveConflict(
    Project local,
    Project remote,
    SyncDirection direction,
  ) async {
    final rng = Random();
    await Future.delayed(Duration(milliseconds: 500 + rng.nextInt(1500)));

    final winner = direction == SyncDirection.download ? remote : local;
    _changeHistory.insert(
      0,
      SyncChange(
        projectId: winner.id,
        description: 'Resolved conflict, kept "${winner.name}"',
        timestamp: DateTime.now(),
        direction: direction,
      ),
    );
    _pendingChanges = (_pendingChanges - 1).clamp(0, 999);
    _lastSync = DateTime.now();
    _status = SyncStatus.synced;
    notifyListeners();
    _syncStreamController.add(_status);
    return true;
  }

  Future<List<Project>> getRemoteProjects() async {
    final rng = Random();
    await Future.delayed(Duration(milliseconds: 500 + rng.nextInt(1500)));

    return [
      Project(id: 'remote_1', name: 'Vacation Edit', updatedAt: DateTime.now().subtract(const Duration(days: 1))),
      Project(id: 'remote_2', name: 'Tutorial Draft', updatedAt: DateTime.now().subtract(const Duration(hours: 5))),
      Project(id: 'remote_3', name: 'Portfolio Reel', updatedAt: DateTime.now().subtract(const Duration(hours: 1))),
    ];
  }

  Future<void> deleteRemote(String projectId) async {
    final rng = Random();
    await Future.delayed(Duration(milliseconds: 500 + rng.nextInt(1500)));

    _changeHistory.insert(
      0,
      SyncChange(
        projectId: projectId,
        description: 'Deleted remote project',
        timestamp: DateTime.now(),
        direction: SyncDirection.upload,
      ),
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _syncStreamController.close();
    super.dispose();
  }
}
