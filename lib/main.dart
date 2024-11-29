import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todolist/services/task_service.dart';
import './views/home_view.dart';
import './services/notification_service.dart';
import 'models/task_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.init();

  runApp( TodoListApp());
}

class TodoListApp extends StatefulWidget {

   TodoListApp({Key? key}) : super(key: key);

  @override
  State<TodoListApp> createState() => _TodoListAppState();
}

class _TodoListAppState extends State<TodoListApp> {
  final NotificationService _notificationService = NotificationService();
  List<TaskModel> _tasks = [];
  final TaskService _taskService = TaskService();

  @override
  void initState() {
    super.initState();
    _loadTasksAndShowNotification();
  }

  Future<void> _loadTasksAndShowNotification() async {
    // Fetch tasks from local storage
    _tasks = await _taskService.getTasks();

    // Show notification if there are any tasks
    if (_tasks.isNotEmpty) {
      await _notificationService.showAppOpenNotification(_tasks);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Todo List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // Material Design guidelines
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      home: HomeView(),
      debugShowCheckedModeBanner: false,
    );
  }
}