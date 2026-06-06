import 'package:flutter/foundation.dart';
import '../models/project.dart';

class ProjectService extends ChangeNotifier {
  final List<Project> _projects = [];
  final List<Project> _recentProjects = [];

  List<Project> get projects => List.unmodifiable(_projects);
  List<Project> get recentProjects => List.unmodifiable(_recentProjects);

  Project createProject(String name, {double aspectRatio = 9 / 16}) {
    final project = Project(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      aspectRatio: aspectRatio,
    );
    _projects.insert(0, project);
    _recentProjects.insert(0, project);
    notifyListeners();
    return project;
  }

  Project? getProject(String id) {
    try {
      return _projects.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  void deleteProject(String id) {
    _projects.removeWhere((p) => p.id == id);
    _recentProjects.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  void updateProject(String id, {String? name, ProjectStatus? status, String? thumbnailPath}) {
    final idx = _projects.indexWhere((p) => p.id == id);
    if (idx == -1) return;
    final p = _projects[idx];
    _projects[idx] = Project(
      id: p.id,
      name: name ?? p.name,
      updatedAt: DateTime.now(),
      duration: p.duration,
      status: status ?? p.status,
      thumbnailPath: thumbnailPath ?? p.thumbnailPath,
      aspectRatio: p.aspectRatio,
    );
    notifyListeners();
  }

  List<Project> search(String query) {
    if (query.isEmpty) return _projects;
    return _projects.where((p) => p.name.toLowerCase().contains(query.toLowerCase())).toList();
  }

  void loadMockData() {
    _projects.addAll([
      Project(id: 'p1', name: 'Wedding Edit', duration: const Duration(seconds: 45)),
      Project(id: 'p2', name: 'Travel Vlog', duration: const Duration(seconds: 90)),
      Project(id: 'p3', name: 'Gaming Montage', duration: const Duration(seconds: 60)),
      Project(id: 'p4', name: 'Product Review', duration: const Duration(seconds: 30)),
      Project(id: 'p5', name: 'Birthday Highlights', duration: const Duration(seconds: 120)),
      Project(id: 'p6', name: 'Music Video', duration: const Duration(seconds: 180)),
    ]);
    _recentProjects.addAll(_projects.take(3));
    notifyListeners();
  }
}
