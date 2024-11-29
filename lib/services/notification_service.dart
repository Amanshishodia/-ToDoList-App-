import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/task_model.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // Initialize notification service
  Future<void> init() async {
    // Android initialization settings
    const AndroidInitializationSettings androidInitializationSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings (if you're supporting iOS)
    const DarwinInitializationSettings iOSInitializationSettings =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Combined initialization settings
    final InitializationSettings initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iOSInitializationSettings,
    );

    // Initialize the plugin
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) async {
        // Handle notification tap
        print('Notification tapped');
      },
    );
  }
  // Show highest priority task notification when app opens
  Future<void> showAppOpenNotification(List<TaskModel> tasks) async {
    if (tasks.isEmpty) return;

    TaskModel nearestTask = tasks.reduce((current, next) =>
    current.dueDate.isBefore(next.dueDate) ? current : next);

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'app_open_channel',
      'App Open Notifications',
      importance: Importance.high,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      nearestTask.id.hashCode,
      'Upcoming Task',
      'Your task "${nearestTask.title}" is coming up soon',
      platformDetails,
    );
  }


  // Schedule a notification for a task
  Future<void> scheduleNotification(TaskModel task) async {
    // Calculate notification time (1 day before due date)
    final notificationTime = task.dueDate.subtract(const Duration(days: 1));

    // Android notification details
    AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'todo_channel',
      'Todo Notifications',
      importance: Importance.high,
    );

    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      task.id.hashCode,
      'Task Due Soon',
      'Your task "${task.title}" is due tomorrow',
      tz.TZDateTime.from(notificationTime, tz.local),
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // Cancel a specific notification
  Future<void> cancelNotification(String taskId) async {
    await flutterLocalNotificationsPlugin.cancel(taskId.hashCode);
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}