// lib/providers/app_provider.dart
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/time_entry.dart';
import '../models/project.dart';
import '../models/task.dart';
import '../services/storage_service.dart';

const _uuid = Uuid();

class AppProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();

  List<TimeEntry> _timeEntries = [];
  List<Project> _projects = [];
  List<Task> _tasks = [];
  bool _isLoading = true;
  bool _groupByProject = false;

  List<TimeEntry> get timeEntries => _timeEntries;
  List<Project> get projects => _projects;
  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  bool get groupByProject => _groupByProject;

  AppProvider() {
    _loadAll();
  }

  Future<void> _loadAll() async {
    _isLoading = true;
    notifyListeners();
    _timeEntries = await _storage.loadTimeEntries();
    _projects = await _storage.loadProjects();
    _tasks = await _storage.loadTasks();
    _isLoading = false;
    notifyListeners();
  }

  void toggleGroupByProject() {
    _groupByProject = !_groupByProject;
    notifyListeners();
  }

  // Time Entries
  Future<void> addTimeEntry({
    required String projectId,
    required String projectName,
    required String taskId,
    required String taskName,
    required double totalTime,
    required String notes,
    required DateTime date,
  }) async {
    final entry = TimeEntry(
      id: _uuid.v4(),
      projectId: projectId,
      projectName: projectName,
      taskId: taskId,
      taskName: taskName,
      totalTime: totalTime,
      notes: notes,
      date: date,
      createdAt: DateTime.now(),
    );
    _timeEntries.insert(0, entry);
    _timeEntries.sort((a, b) => b.date.compareTo(a.date));
    await _storage.saveTimeEntries(_timeEntries);
    notifyListeners();
  }

  Future<void> deleteTimeEntry(String id) async {
    _timeEntries.removeWhere((e) => e.id == id);
    await _storage.saveTimeEntries(_timeEntries);
    notifyListeners();
  }

  Future<void> updateTimeEntry(TimeEntry updated) async {
    final idx = _timeEntries.indexWhere((e) => e.id == updated.id);
    if (idx != -1) {
      _timeEntries[idx] = updated;
      _timeEntries.sort((a, b) => b.date.compareTo(a.date));
      await _storage.saveTimeEntries(_timeEntries);
      notifyListeners();
    }
  }

  // Projects
  Future<void> addProject({
    required String name,
    required String color,
    String description = '',
  }) async {
    final project = Project(
      id: _uuid.v4(),
      name: name,
      color: color,
      description: description,
      createdAt: DateTime.now(),
    );
    _projects.add(project);
    _projects.sort((a, b) => a.name.compareTo(b.name));
    await _storage.saveProjects(_projects);
    notifyListeners();
  }

  Future<void> deleteProject(String id) async {
    _projects.removeWhere((p) => p.id == id);
    await _storage.saveProjects(_projects);
    notifyListeners();
  }

  Future<void> updateProject(Project updated) async {
    final idx = _projects.indexWhere((p) => p.id == updated.id);
    if (idx != -1) {
      _projects[idx] = updated;
      await _storage.saveProjects(_projects);
      notifyListeners();
    }
  }

  // Tasks
  Future<void> addTask({
    required String name,
    required String projectId,
    String description = '',
  }) async {
    final task = Task(
      id: _uuid.v4(),
      name: name,
      projectId: projectId,
      description: description,
      createdAt: DateTime.now(),
    );
    _tasks.add(task);
    _tasks.sort((a, b) => a.name.compareTo(b.name));
    await _storage.saveTasks(_tasks);
    notifyListeners();
  }

  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((t) => t.id == id);
    await _storage.saveTasks(_tasks);
    notifyListeners();
  }

  Future<void> updateTask(Task updated) async {
    final idx = _tasks.indexWhere((t) => t.id == updated.id);
    if (idx != -1) {
      _tasks[idx] = updated;
      await _storage.saveTasks(_tasks);
      notifyListeners();
    }
  }

  List<Task> getTasksForProject(String projectId) {
    if (projectId.isEmpty) return _tasks;
    return _tasks.where((t) => t.projectId == projectId || t.projectId.isEmpty).toList();
  }

  Map<String, List<TimeEntry>> getEntriesGroupedByProject() {
    final Map<String, List<TimeEntry>> grouped = {};
    for (final entry in _timeEntries) {
      grouped.putIfAbsent(entry.projectName, () => []).add(entry);
    }
    return grouped;
  }

  double getTotalHoursForProject(String projectName) {
    return _timeEntries
        .where((e) => e.projectName == projectName)
        .fold(0.0, (sum, e) => sum + e.totalTime);
  }

  Future<String?> getRawStorageData() async {
    return _storage.getRawTimeEntries();
  }
}
