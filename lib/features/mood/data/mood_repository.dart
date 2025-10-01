import 'package:shared_preferences/shared_preferences.dart';

import 'mood_entry.dart';

class MoodRepository {
  static const _storageKey = 'mood_entries_v1';

  List<MoodEntry> _items = const [];

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null && raw.isNotEmpty) {
      _items = MoodEntry.listFromJsonString(raw);
    }
    _items =
        _items
            .map((e) => MoodEntry(date: e.date, mood: e.mood, note: e.note))
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));
  }

  List<MoodEntry> all() => List.unmodifiable(_items);

  MoodEntry? getForDate(DateTime date) {
    final key = MoodEntry.dateKeyOf(date);
    for (final e in _items) {
      if (MoodEntry.dateKeyOf(e.date) == key) return e;
    }
    return null;
  }

  Future<void> upsertForDate(
    DateTime date,
    MoodValue mood,
    String? note,
  ) async {
    final key = MoodEntry.dateKeyOf(date);
    final existingIndex = _items.indexWhere(
      (e) => MoodEntry.dateKeyOf(e.date) == key,
    );
    final entry = MoodEntry(date: date, mood: mood, note: note);
    if (existingIndex >= 0) {
      _items = List.of(_items)..[existingIndex] = entry;
    } else {
      _items = [..._items, entry];
    }
    _items.sort((a, b) => b.date.compareTo(a.date));
    await _persist();
  }

  Future<void> removeForDate(DateTime date) async {
    final key = MoodEntry.dateKeyOf(date);
    _items = _items.where((e) => MoodEntry.dateKeyOf(e.date) != key).toList();
    await _persist();
  }

  List<MoodEntry> forMonth(DateTime month) {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(
      month.year,
      month.month + 1,
      1,
    ).subtract(const Duration(milliseconds: 1));
    return _items
        .where(
          (e) =>
              e.date.isAfter(start.subtract(const Duration(seconds: 1))) &&
              e.date.isBefore(end.add(const Duration(seconds: 1))),
        )
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  double averageScore({int days = 30}) {
    if (_items.isEmpty) return 0;
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final recent = _items.where((e) => e.date.isAfter(cutoff)).toList();
    if (recent.isEmpty) return 0;
    final sum = recent.fold<int>(0, (s, e) => s + e.mood.score);
    return sum / recent.length;
  }

  Map<MoodValue, int> counts({int days = 30}) {
    final map = {for (final m in MoodValue.values) m: 0};
    final cutoff = DateTime.now().subtract(Duration(days: days));
    for (final e in _items.where((e) => e.date.isAfter(cutoff))) {
      map[e.mood] = (map[e.mood] ?? 0) + 1;
    }
    return map;
  }

  Future<void> clearAll() async {
    _items = const [];
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, MoodEntry.listToJsonString(_items));
  }
}
