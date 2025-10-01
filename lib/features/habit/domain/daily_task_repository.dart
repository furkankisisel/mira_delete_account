import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'daily_task_model.dart';

class DailyTaskRepository extends ChangeNotifier {
  DailyTaskRepository._();
  static final DailyTaskRepository instance = DailyTaskRepository._();

  static const _storageKey = 'daily_tasks_v1';
  bool _initialized = false;
  final List<DailyTask> _tasks = [];

  /// Returns tasks whose dateKey equals [dateKey].
  List<DailyTask> tasksForDate(String dateKey) =>
      _tasks.where((t) => t.dateKey == dateKey).toList();

  /// Returns tasks for [dateKey] including carry-over of incomplete tasks from
  /// previous days. A task will carry over forward until it is marked done.
  ///
  /// Carry-over rules (simple):
  /// - If a task has a dateKey before [dateKey] and isDone == false, it will
  ///   appear on [dateKey] as well (so users see pending tasks until completed).
  /// - Tasks with dateKey after [dateKey] are not included.
  List<DailyTask> tasksForDateWithCarryover(String dateKey) {
    try {
      final requested = DateTime.parse(dateKey);
      return _tasks.where((t) {
        try {
          final d = DateTime.parse(t.dateKey);
          // exact match always included
          if (t.dateKey == dateKey) return true;
          // include if task is from earlier date and not completed
          if (d.isBefore(requested) && !t.isDone) return true;
          return false;
        } catch (_) {
          return t.dateKey == dateKey;
        }
      }).toList();
    } catch (_) {
      // If parsing fails, fall back to exact-match behavior
      return tasksForDate(dateKey);
    }
  }

  // Expose all tasks (read-only) for maintenance operations like list deletion cascades.
  List<DailyTask> get allTasks => List.unmodifiable(_tasks);

  Future<void> initialize() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null) {
      try {
        final list = (jsonDecode(raw) as List)
            .map((e) => DailyTask.fromJson((e as Map).cast<String, dynamic>()))
            .toList();
        _tasks
          ..clear()
          ..addAll(list);
      } catch (_) {
        _tasks.clear();
      }
    }
    _initialized = true;
    notifyListeners();
  }

  Future<void> addTask(DailyTask task) async {
    _tasks.add(task);
    await _persistAndNotify();
  }

  /// Move a task by a relative delta within the internal list.
  /// delta: -1 move up, +1 move down. No-op if id not found or target index equals source.
  Future<void> moveTask(String id, int delta) async {
    final idx = _tasks.indexWhere((t) => t.id == id);
    if (idx == -1) return;
    final target = (idx + delta).clamp(0, _tasks.length - 1);
    if (target == idx) return;
    final task = _tasks.removeAt(idx);
    // Insert at target (after removal this is the desired index)
    final insertAt = target.clamp(0, _tasks.length);
    _tasks.insert(insertAt, task);
    await _persistAndNotify();
  }

  Future<void> updateTask(DailyTask task) async {
    final idx = _tasks.indexWhere((t) => t.id == task.id);
    if (idx != -1) {
      _tasks[idx] = task;
      await _persistAndNotify();
    }
  }

  Future<void> removeTask(String id) async {
    _tasks.removeWhere((t) => t.id == id);
    await _persistAndNotify();
  }

  Future<void> assignTaskToList(String id, String? listId) async {
    final t = _tasks.firstWhere(
      (e) => e.id == id,
      orElse: () => DailyTask(id: '', title: '', description: '', dateKey: ''),
    );
    if (t.id.isEmpty) return;
    t.listId = listId;
    await _persistAndNotify();
  }

  Future<void> _persist() async {
    if (!_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(_tasks.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, raw);
  }

  Future<void> _persistAndNotify() async {
    await _persist();
    notifyListeners();
  }
}
