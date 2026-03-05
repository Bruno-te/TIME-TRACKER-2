// lib/services/storage_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/time_entry.dart';
import '../models/project.dart';
import '../models/task.dart';

class StorageService {
  static const String _timeEntriesKey = 'time_entries';
  static const String _projectsKey = 'projects';
  static const String _tasksKey = 'tasks';

  // Time Entries
  Future<List<TimeEntry>> loadTimeEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_timeEntriesKey);
    if (jsonString == null || jsonString.isEmpty) return [];
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((e) => TimeEntry.fromJson(e)).toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    } catch (_) {
      return [];
    }
  }

  Future<bool> saveTimeEntries(List<TimeEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(entries.map((e) => e.toJson()).toList());
    return prefs.setString(_timeEntriesKey, jsonString);
  }

  Future<String?> getRawTimeEntries() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_timeEntriesKey);
  }

  // Projects
  Future<List<Project>> loadProjects() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_projectsKey);
    if (jsonString == null || jsonString.isEmpty) return [];
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((e) => Project.fromJson(e)).toList()
        ..sort((a, b) => a.name.compareTo(b.name));
    } catch (_) {
      return [];
    }
  }

  Future<bool> saveProjects(List<Project> projects) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(projects.map((e) => e.toJson()).toList());
    return prefs.setString(_projectsKey, jsonString);
  }

  // Tasks
  Future<List<Task>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_tasksKey);
    if (jsonString == null || jsonString.isEmpty) return [];
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((e) => Task.fromJson(e)).toList()
        ..sort((a, b) => a.name.compareTo(b.name));
    } catch (_) {
      return [];
    }
  }

  Future<bool> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(tasks.map((e) => e.toJson()).toList());
    return prefs.setString(_tasksKey, jsonString);
  }

  Future<String?> getRawTasks() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tasksKey);
  }

  Future<String?> getRawProjects() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_projectsKey);
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
