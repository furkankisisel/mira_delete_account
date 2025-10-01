import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'list_model.dart';

class ListRepository extends ChangeNotifier {
  ListRepository._();
  static final ListRepository instance = ListRepository._();

  static const _storageKey = 'app_lists_v1';
  bool _initialized = false;
  final List<AppList> _lists = [];

  List<AppList> get lists => List.unmodifiable(_lists);

  Future<void> initialize() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null) {
      try {
        final list = (jsonDecode(raw) as List)
            .map((e) => AppList.fromJson((e as Map).cast<String, dynamic>()))
            .toList();
        _lists
          ..clear()
          ..addAll(list);
      } catch (_) {
        _lists.clear();
      }
    }
    _initialized = true;
    notifyListeners();
  }

  Future<void> addList(AppList list) async {
    _lists.add(list);
    await _persistAndNotify();
  }

  Future<void> removeList(String id) async {
    _lists.removeWhere((l) => l.id == id);
    await _persistAndNotify();
  }

  Future<void> updateList(AppList list) async {
    final idx = _lists.indexWhere((l) => l.id == list.id);
    if (idx != -1) {
      _lists[idx] = list;
      await _persistAndNotify();
    }
  }

  Future<void> _persist() async {
    if (!_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(_lists.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, raw);
  }

  Future<void> _persistAndNotify() async {
    await _persist();
    notifyListeners();
  }
}
