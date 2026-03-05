// lib/models/time_entry.dart
import 'dart:convert';

class TimeEntry {
  final String id;
  final String projectId;
  final String projectName;
  final String taskId;
  final String taskName;
  final double totalTime; // in hours
  final String notes;
  final DateTime date;
  final DateTime createdAt;

  TimeEntry({
    required this.id,
    required this.projectId,
    required this.projectName,
    required this.taskId,
    required this.taskName,
    required this.totalTime,
    required this.notes,
    required this.date,
    required this.createdAt,
  });

  TimeEntry copyWith({
    String? id,
    String? projectId,
    String? projectName,
    String? taskId,
    String? taskName,
    double? totalTime,
    String? notes,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return TimeEntry(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      projectName: projectName ?? this.projectName,
      taskId: taskId ?? this.taskId,
      taskName: taskName ?? this.taskName,
      totalTime: totalTime ?? this.totalTime,
      notes: notes ?? this.notes,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'projectId': projectId,
    'projectName': projectName,
    'taskId': taskId,
    'taskName': taskName,
    'totalTime': totalTime,
    'notes': notes,
    'date': date.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
  };

  factory TimeEntry.fromJson(Map<String, dynamic> json) => TimeEntry(
    id: json['id'],
    projectId: json['projectId'],
    projectName: json['projectName'],
    taskId: json['taskId'],
    taskName: json['taskName'],
    totalTime: (json['totalTime'] as num).toDouble(),
    notes: json['notes'],
    date: DateTime.parse(json['date']),
    createdAt: DateTime.parse(json['createdAt']),
  );

  String toJsonString() => jsonEncode(toJson());

  String get formattedTime {
    final hours = totalTime.floor();
    final minutes = ((totalTime - hours) * 60).round();
    if (hours == 0) return '${minutes}m';
    if (minutes == 0) return '${hours}h';
    return '${hours}h ${minutes}m';
  }
}
