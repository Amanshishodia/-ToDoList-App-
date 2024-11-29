import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';
import '../services/notification_service.dart';

class TaskViewModel extends GetxController {
  final TaskService _taskService = TaskService();
  final NotificationService _notificationService = NotificationService();

  RxList<TaskModel> tasks = <TaskModel>[].obs;
  RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadTasks();
  }

  // Load tasks from storage
  Future<void> loadTasks() async {
    tasks.value = await _taskService.getTasks();
  }

  // Add a new task
  Future<void> addTask(TaskModel task) async {
    // Schedule notification
    _notificationService.scheduleNotification(task);
//
    tasks.add(task);
    await _taskService.saveTasks(tasks);
  }

  // Update an existing task
  Future<void> updateTask(TaskModel updatedTask) async {
    int index = tasks.indexWhere((task) => task.id == updatedTask.id);
    if (index != -1) {
      tasks[index] = updatedTask;
      await _taskService.saveTasks(tasks);
    }
  }

  // Delete a task
  Future<void> deleteTask(String taskId) async {
    tasks.removeWhere((task) => task.id == taskId);
    await _taskService.saveTasks(tasks);
  }

  // Sort tasks
  void sortTasks(SortType sortType) {
    switch (sortType) {
      case SortType.priority:
        tasks.sort((a, b) => b.priority.index.compareTo(a.priority.index));
        break;
      case SortType.dueDate:
        tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
        break;
      case SortType.creationDate:
        tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }
  }

  // Search tasks
  List<TaskModel> searchTasks() {
    if (searchQuery.value.isEmpty) return tasks;

    return tasks.where((task) =>
    task.title.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
        task.title.toLowerCase().contains(searchQuery.value.toLowerCase())
    ).toList();
  }
  //

  // Create a new task
  TaskModel createTask({
    required String title,
    required String description,
    required Priority priority,
    required DateTime dueDate,
  }) {//
    return TaskModel(
      id: const Uuid().v4(),
      title: title,
      description: description,
      priority: priority,
      dueDate: dueDate,
    );
  }
}

// Enum for sorting types
enum SortType {
  priority,
  dueDate,
  creationDate
}