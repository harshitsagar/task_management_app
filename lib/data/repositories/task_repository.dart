import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class TaskRepository {
  static const String _tasksKey = 'tasks';
  final SharedPreferences _prefs;

  TaskRepository(this._prefs);

  Future<List<Task>> getTasks() async {
    final String? tasksJson = _prefs.getString(_tasksKey);
    if (tasksJson == null) return [];

    final List<dynamic> decoded = json.decode(tasksJson);
    return decoded.map((item) => Task.fromJson(item)).toList();
  }

  Future<void> saveTasks(List<Task> tasks) async {
    final String encoded = json.encode(
        tasks.map((task) => task.toJson()).toList()
    );
    await _prefs.setString(_tasksKey, encoded);
  }

  Future<void> addTask(Task task) async {
    final tasks = await getTasks();
    tasks.add(task);
    await saveTasks(tasks);
  }

  Future<void> updateTask(Task updatedTask) async {
    final tasks = await getTasks();
    final index = tasks.indexWhere((task) => task.id == updatedTask.id);
    if (index != -1) {
      tasks[index] = updatedTask;
      await saveTasks(tasks);
    }
  }

  Future<void> deleteTask(String taskId) async {
    final tasks = await getTasks();
    tasks.removeWhere((task) => task.id == taskId);
    await saveTasks(tasks);
  }

  Future<Task?> getTaskById(String taskId) async {
    final tasks = await getTasks();
    try {
      return tasks.firstWhere((task) => task.id == taskId);
    } catch (e) {
      return null;
    }
  }
}