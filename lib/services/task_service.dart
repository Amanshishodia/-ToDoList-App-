import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task_model.dart';

class TaskService {
  static const String _tasksKey = 'tasks';

  // Save tasks to local storage
  Future<void> saveTasks(List<TaskModel> tasks) async {
    final prefs = await SharedPreferences.getInstance();

    // Convert tasks to JSON string list
    final taskJsonList = tasks.map((task) => json.encode(task.toJson())).toList();

    await prefs.setStringList(_tasksKey, taskJsonList);
  }

  // Retrieve tasks from local storage
  Future<List<TaskModel>> getTasks() async {
    final prefs = await SharedPreferences.getInstance();

    // Retrieve tasks as JSON string list
    final taskJsonList = prefs.getStringList(_tasksKey) ?? [];

    // Convert JSON strings back to TaskModel objects
    return taskJsonList
        .map((taskJson) => TaskModel.fromJson(json.decode(taskJson)))
        .toList();
  }

  // Clear all tasks
  Future<void> clearTasks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tasksKey);
  }
}
