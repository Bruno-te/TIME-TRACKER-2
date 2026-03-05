// lib/models/task.dart
import 'dart:convert';

class Task {
  final String id;
  final String name;
  final String projectId;
  final String description;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.name,
    required this.projectId,
    required this.description,
    required this.createdAt,
  });

  Task copyWith({
    String? id,
    String? name,
    String? projectId,
    String? description,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      name: name ?? this.name,
      projectId: projectId ?? this.projectId,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'projectId': projectId,
    'description': description,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json['id'],
    name: json['name'],
    projectId: json['projectId'] ?? '',
    description: json['description'] ?? '',
    createdAt: DateTime.parse(json['createdAt']),
  );

  String toJsonString() => jsonEncode(toJson());
}
