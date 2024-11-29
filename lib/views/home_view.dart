import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../models/task_model.dart';
import '../viewmodels/task_view_model.dart';
import 'add_edit_task_view.dart';

class HomeView extends StatelessWidget {
  final TaskViewModel _taskViewModel = Get.put(TaskViewModel());

  HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
        actions: [
          PopupMenuButton<SortType>(
            icon: const Icon(Icons.sort),
            onSelected: (SortType result) {
              _taskViewModel.sortTasks(result);
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<SortType>>[
              const PopupMenuItem<SortType>(
                value: SortType.priority,
                child: Text('Sort by Priority'),
              ),
              const PopupMenuItem<SortType>(
                value: SortType.dueDate,
                child: Text('Sort by Due Date'),
              ),
              const PopupMenuItem<SortType>(
                value: SortType.creationDate,
                child: Text('Sort by Creation Date'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search tasks...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                _taskViewModel.searchQuery.value = value;
              },
            ),
          ),
          Expanded(
            child: Obx(() {
              final filteredTasks = _taskViewModel.searchTasks();

              if (filteredTasks.isEmpty) {
                return const Center(
                  child: Text('No tasks found'),
                );
              }

              return ListView.builder(
                itemCount: filteredTasks.length,
                itemBuilder: (context, index) {
                  final task = filteredTasks[index];
                  return TaskListItem(
                    task: task,
                    onDelete: () => _taskViewModel.deleteTask(task.id),
                    onEdit: () => _navigateToEditTask(task),
                    onToggleComplete: () {
                      task.isCompleted.value = !task.isCompleted.value;
                      _taskViewModel.updateTask(task);
                    },
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddTask,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _navigateToAddTask() {
    Get.to(() => AddEditTaskView());
  }

  void _navigateToEditTask(TaskModel task) {
    Get.to(() => AddEditTaskView(task: task));
  }
}

class TaskListItem extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onToggleComplete;

  const TaskListItem({
    Key? key,
    required this.task,
    required this.onDelete,
    required this.onEdit,
    required this.onToggleComplete,
  }) : super(key: key);

  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.high:
        return Colors.red;
      case Priority.medium:
        return Colors.orange;
      case Priority.low:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Dismissible(
      key: Key(task.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) => onDelete(),
      child: Card(
        color: task.isCompleted.value ? Colors.grey[300] : null,
        child: ListTile(
          leading: Checkbox(
            value: task.isCompleted.value,
            onChanged: (bool? value) => onToggleComplete(),
            activeColor: _getPriorityColor(task.priority),
          ),
          title: Text(
            task.title,
            style: TextStyle(
              decoration: task.isCompleted.value
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: _getPriorityColor(task.priority),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('MMM dd, yyyy').format(task.dueDate),
                    style: TextStyle(
                      color: _getPriorityColor(task.priority),
                    ),
                  ),
                ],
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: onEdit,
              ),
              Container(
                width: 8,
                height: 20,
                color: _getPriorityColor(task.priority),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}