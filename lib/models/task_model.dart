import 'package:get/get.dart';

enum Priority {
  low,    // Green
  medium, // Orange
  high    // Red
}

class TaskModel {
  final String id;
  final String title;
  final String description;
  final Priority priority;
  final DateTime dueDate;
  final DateTime createdAt;
  RxBool isCompleted = RxBool(false);

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.dueDate,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convert to JSON for storage
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'priority': priority.index,
    'dueDate': dueDate.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'isCompleted': isCompleted.value,
  };

  // Create from JSON
  factory TaskModel.fromJson(Map<String, dynamic> json) => TaskModel(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    priority: Priority.values[json['priority']],
    dueDate: DateTime.parse(json['dueDate']),
    createdAt: DateTime.parse(json['createdAt']),
  )..isCompleted.value = json['isCompleted'] ?? false;

  // Copywrite method for easy updates
  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    Priority? priority,
    DateTime? dueDate,
    DateTime? createdAt,
    bool? isCompleted,
  }) => TaskModel(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    priority: priority ?? this.priority,
    dueDate: dueDate ?? this.dueDate,
    createdAt: createdAt ?? this.createdAt,
  )..isCompleted.value = isCompleted ?? this.isCompleted.value;
}