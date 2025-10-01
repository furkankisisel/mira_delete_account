import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'habit_types.dart';

class CategoryRepository extends ChangeNotifier {
  CategoryRepository._();
  static final CategoryRepository instance = CategoryRepository._();

  static const _storageKey = 'habit_categories_custom_v1';
  bool _initialized = false;
  final List<HabitCategory> _custom = [];

  List<HabitCategory> get customCategories => List.unmodifiable(_custom);

  Future<void> initialize() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null) {
      try {
        final list = (jsonDecode(raw) as List)
            .map(
              (e) => HabitCategory.fromJson((e as Map).cast<String, dynamic>()),
            )
            .toList();
        _custom
          ..clear()
          ..addAll(list);
      } catch (_) {
        _custom.clear();
      }
    }
    _initialized = true;
    notifyListeners();
  }

  Future<void> addCustom(HabitCategory category) async {
    _custom.add(category);
    await _persistAndNotify();
  }

  Future<void> updateCustom(HabitCategory category) async {
    final i = _custom.indexWhere((c) => c.id == category.id);
    if (i == -1) return;
    _custom[i] = category;
    await _persistAndNotify();
  }

  Future<void> removeCustom(String id) async {
    _custom.removeWhere((c) => c.id == id);
    await _persistAndNotify();
  }

  Future<void> clearAll() async {
    _custom.clear();
    await _persistAndNotify();
  }

  Future<void> _persist() async {
    if (!_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(_custom.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, raw);
  }

  Future<void> _persistAndNotify() async {
    await _persist();
    notifyListeners();
  }
}
