// lib/models/project.dart
import 'dart:convert';

class Project {
  final String id;
  final String name;
  final String color; // hex color string
  final String description;
  final DateTime createdAt;

  Project({
    required this.id,
    required this.name,
    required this.color,
    required this.description,
    required this.createdAt,
  });

  Project copyWith({
    String? id,
    String? name,
    String? color,
    String? description,
    DateTime? createdAt,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'color': color,
    'description': description,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Project.fromJson(Map<String, dynamic> json) => Project(
    id: json['id'],
    name: json['name'],
    color: json['color'] ?? '#6366F1',
    description: json['description'] ?? '',
    createdAt: DateTime.parse(json['createdAt']),
  );

  String toJsonString() => jsonEncode(toJson());
}
