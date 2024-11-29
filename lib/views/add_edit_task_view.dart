import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../models/task_model.dart';
import '../viewmodels/task_view_model.dart';
//
class AddEditTaskView extends StatelessWidget {
  final TaskModel? task;
  final TaskViewModel _taskViewModel = Get.find();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final Rx<DateTime> _selectedDate = DateTime.now().obs;
  final Rx<Priority> _selectedPriority = Priority.low.obs;

  AddEditTaskView({Key? key, this.task}) : super(key: key) {
    // If editing an existing task, populate the controllers
    if (task != null) {
      _titleController.text = task!.title;
      _descriptionController.text = task!.description;
      _selectedDate.value = task!.dueDate;
      _selectedPriority.value = task!.priority;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(task == null ? 'Add Task' : 'Edit Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Task Title',
                prefixIcon: Icon(Icons.title),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            // Due Date Picker
            Obx(() => ListTile(
              title: const Text('Due Date'),
              subtitle: Text(
                DateFormat('MMMM dd, yyyy').format(_selectedDate.value),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () => _selectDate(context),
              ),
            )),
            const SizedBox(height: 16),
            // Priority Selector
            Obx(() => DropdownButtonFormField<Priority>(
              decoration: const InputDecoration(
                labelText: 'Priority',
                prefixIcon: Icon(Icons.priority_high),
              ),
              value: _selectedPriority.value,
              items: Priority.values
                  .map((priority) => DropdownMenuItem(
                value: priority,
                child: Text(_getPriorityText(priority)),
              ))
                  .toList(),
              onChanged: (value) {
                if (value != null) _selectedPriority.value = value;
              },
            )),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveTask,
              child: Text(task == null ? 'Add Task' : 'Update Task'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.value,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate.value) {
      _selectedDate.value = picked;
    }
  }

  void _saveTask() {
    // Validate inputs
    if (_titleController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a task title',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Create or update task
    if (task == null) {
      // Create new task
      final newTask = _taskViewModel.createTask(
        title: _titleController.text,
        description: _descriptionController.text,
        priority: _selectedPriority.value,
        dueDate: _selectedDate.value,
      );
      _taskViewModel.addTask(newTask);
    } else {
      // Update existing task
      final updatedTask = task!.copyWith(
        title: _titleController.text,
        description: _descriptionController.text,
        priority: _selectedPriority.value,
        dueDate: _selectedDate.value,
      );
      _taskViewModel.updateTask(updatedTask);
    }

    // Close the screen
    Get.back();
  }

  String _getPriorityText(Priority priority) {
    switch (priority) {
      case Priority.low:
        return 'Low Priority';
      case Priority.medium:
        return 'Medium Priority';
      case Priority.high:
        return 'High Priority';
    }
  }
}