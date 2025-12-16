import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'habit_model.dart';
import 'habit_types.dart';
import '../../../core/icons/icon_mapping.dart';
import '../../gamification/gamification_repository.dart';
import '../../notifications/services/notification_service.dart';

class HabitRepository extends ChangeNotifier {
  HabitRepository._();
  static final HabitRepository instance = HabitRepository._();

  static const _storageKeyV2 = 'habits_v2';
  static const _storageKeyV1 = 'habits_v1'; // eski sürüm olası geçiş için
  static const _kPerHabitStreakKey = 'habits_streak_visibility_v1';

  bool _initialized = false;
  bool _initializing = false;
  final List<Habit> _habits = [];
  // cache for per-habit streak visibility; persisted separately
  final Map<String, bool> _perHabitStreakVisibility = {};

  List<Habit> get habits => List.unmodifiable(_habits);

  Future<void> initialize() async {
    if (_initialized || _initializing) return;
    _initializing = true;
    final prefs = await SharedPreferences.getInstance();
    // Start from a clean slate before loading to avoid duplication on re-entry
    _habits.clear();
    final rawV2 = prefs.getString(_storageKeyV2);
    if (rawV2 != null) {
      _loadFromJson(rawV2);
    } else {
      // Eski v1 verisi varsa dene, yoksa boş başla
      final rawV1 = prefs.getString(_storageKeyV1);
      if (rawV1 != null) {
        _tryMigrateV1(rawV1);
        await _persist();
      } else {
        // No defaults, clean start
        _habits.clear();
        await _persist();
      }
    }
    _ensureToday();
    _initialized = true;
    _initializing = false;
    // Load per-habit streak visibility map from prefs if available
    try {
      final p = await SharedPreferences.getInstance();
      final raw = p.getString(_kPerHabitStreakKey);
      if (raw != null) {
        final m = jsonDecode(raw) as Map<String, dynamic>;
        _perHabitStreakVisibility.clear();
        m.forEach((k, v) {
          _perHabitStreakVisibility[k] = v == true;
        });
      }
    } catch (_) {
      // ignore errors - optional data
    }
    notifyListeners();
  }

  /// Clears all habit data from memory and SharedPreferences.
  Future<void> wipeAllStoredData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKeyV2);
      await prefs.remove(_storageKeyV1);
      await prefs.remove(_kPerHabitStreakKey);
    } catch (_) {
      // ignore
    }
    _habits.clear();
    _perHabitStreakVisibility.clear();
    notifyListeners();
  }

  bool getShowStreakIndicatorFor(String habitId) {
    return _perHabitStreakVisibility[habitId] ?? true;
  }

  Future<void> setShowStreakIndicatorFor(String habitId, bool show) async {
    _perHabitStreakVisibility[habitId] = show;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _kPerHabitStreakKey,
        jsonEncode(_perHabitStreakVisibility),
      );
    } catch (_) {
      // ignore
    }
    notifyListeners();
  }

  void _loadFromJson(String raw) {
    try {
      print('[HabitRepository] Loading habits from JSON...');
      final list = jsonDecode(raw) as List<dynamic>;
      print('[HabitRepository] Found ${list.length} habits in storage');
      for (final e in list) {
        if (e is Map<String, dynamic>) {
          final habit = Habit.fromJson(e);
          print(
            '[HabitRepository] Loaded habit: ${habit.emoji} ${habit.title}, reminderEnabled=${habit.reminderEnabled}, reminderTime=${habit.reminderTime}',
          );
          _habits.add(habit);
        } else if (e is Map) {
          final habit = Habit.fromJson(e.cast<String, dynamic>());
          print(
            '[HabitRepository] Loaded habit: ${habit.emoji} ${habit.title}, reminderEnabled=${habit.reminderEnabled}, reminderTime=${habit.reminderTime}',
          );
          _habits.add(habit);
        }
      }
      print('[HabitRepository] Total habits loaded: ${_habits.length}');
    } catch (e) {
      print('[HabitRepository] Error loading habits: $e');
      _habits.clear();
      _seedDefaults();
    }
  }

  // Eski map tabanlı kaydı Habit modeline çevir.
  void _tryMigrateV1(String raw) {
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      for (final e in list) {
        if (e is Map) {
          final m = e.cast<String, dynamic>();
          try {
            _habits.add(
              Habit(
                id: m['id']?.toString() ?? UniqueKey().toString(),
                title: m['title']?.toString() ?? '',
                description: m['description']?.toString() ?? '',
                icon: (m['icon'] is IconData)
                    ? m['icon'] as IconData
                    : materialIconFromCodePoint(
                        (m['iconCodePoint'] as int?) ?? Icons.circle.codePoint,
                      ),
                color: (m['color'] is Color)
                    ? m['color'] as Color
                    : Color((m['colorValue'] as int?) ?? Colors.blue.value),
                targetCount:
                    (m['targetCount'] as int?) ?? (m['target'] as int? ?? 0),
                habitType: HabitType.values.firstWhere(
                  (h) => h.toString() == m['habitType'],
                  orElse: () => HabitType.simple,
                ),
                unit: m['unit'] as String?,
                currentStreak:
                    (m['currentStreak'] as int?) ?? (m['current'] as int? ?? 0),
                isCompleted: m['isCompleted'] as bool? ?? false,
                progressDate:
                    m['progressDate']?.toString() ?? _dateStr(DateTime.now()),
                startDate:
                    (m['startDate']?.toString() ??
                    (m['progressDate']?.toString() ??
                        _dateStr(DateTime.now()))),
                dailyLog: (m['dailyLog'] is Map)
                    ? (m['dailyLog'] as Map).map(
                        (k, v) => MapEntry(k.toString(), (v as num).toInt()),
                      )
                    : {},
              ),
            );
          } catch (_) {
            // tek öğe hatası yutuluyor
          }
        }
      }
      // if still empty, keep it empty (no defaults)
    } catch (_) {
      // On error, keep it empty
      _habits.clear();
    }
  }

  void _seedDefaults() {
    /* removed: start empty by default */
  }

  Habit? findById(String id) {
    try {
      return _habits.firstWhere((h) => h.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> addHabit(Habit habit) async {
    _habits.add(habit);
    await _persistAndNotify();
  }

  Future<void> updateHabit(Habit habit) async {
    print('💾 updateHabit called for: ${habit.title}');
    print('   - reminderEnabled: ${habit.reminderEnabled}');
    print('   - reminderTime: ${habit.reminderTime}');

    final idx = _habits.indexWhere((h) => h.id == habit.id);
    if (idx != -1) {
      _habits[idx] = habit;
      await _persistAndNotify();
      // Update reminder if changed
      await _updateHabitReminder(habit);
    }
  }

  Future<void> assignHabitToList(String habitId, String? listId) async {
    final h = findById(habitId);
    if (h == null) return;
    h.listId = listId; // null to unassign
    await _persistAndNotify();
  }

  // Reminder Management
  Future<void> _updateHabitReminder(Habit habit) async {
    print('🔔 _updateHabitReminder called for: ${habit.title}');
    print('   - reminderEnabled: ${habit.reminderEnabled}');
    print('   - reminderTime: ${habit.reminderTime}');

    if (habit.reminderEnabled && habit.reminderTime != null) {
      await NotificationService.instance.scheduleHabitReminder(habit);
    } else {
      await NotificationService.instance.cancelHabitReminder(habit);
    }
  }

  Future<void> toggleHabitReminder(String habitId, bool enabled) async {
    final habit = findById(habitId);
    if (habit == null) return;
    habit.reminderEnabled = enabled;
    await _persistAndNotify();
    await _updateHabitReminder(habit);
  }

  Future<void> setHabitReminderTime(String habitId, TimeOfDay time) async {
    final habit = findById(habitId);
    if (habit == null) return;
    habit.reminderTime = time;
    await _persistAndNotify();
    if (habit.reminderEnabled) {
      await _updateHabitReminder(habit);
    }
  }

  Future<void> removeHabit(String id) async {
    final habit = findById(id);
    if (habit != null) {
      // Cancel reminder before removing
      await NotificationService.instance.cancelHabitReminder(habit);
    }
    _habits.removeWhere((h) => h.id == id);
    await _persistAndNotify();
  }

  Future<void> insertHabit(int index, Habit habit) async {
    _habits.insert(index, habit);
    await _persistAndNotify();
  }

  /// Move a habit by relative delta (-1 up, +1 down) within the list.
  Future<void> moveHabit(String id, int delta) async {
    final idx = _habits.indexWhere((h) => h.id == id);
    if (idx == -1) return;
    final target = (idx + delta).clamp(0, _habits.length - 1);
    if (target == idx) return;
    final h = _habits.removeAt(idx);
    final insertAt = target.clamp(0, _habits.length);
    _habits.insert(insertAt, h);
    await _persistAndNotify();
  }

  /// Timer oturumu ilerlemesi ekle (dakika).
  void addTimerProgress(String habitId, Duration duration) {
    _ensureToday();
    final habit = findById(habitId);
    if (habit == null) return;
    habit.applyDailyReset(DateTime.now());
    final beforeCompleted = habit.isCompleted;
    // Apply raw timer accumulation
    habit.addTimerProgress(duration);
    // Re-evaluate completion based on timer policy using currentStreak
    habit.isCompleted = HabitRepository.evaluateCompletionForProgress(
      habit,
      habit.currentStreak,
    );
    if (!beforeCompleted && habit.isCompleted) {
      // ignore: unawaited_futures
      GamificationRepository.instance.onHabitCompleted(
        habitId: habit.id,
        when: DateTime.now(),
      );
    }
    _persistAndNotify();
  }

  /// Sayısal alışkanlık artışı
  void incrementNumerical(String habitId, [int delta = 1]) {
    _ensureToday();
    final habit = findById(habitId);
    if (habit == null || habit.habitType != HabitType.numerical) return;
    habit.applyDailyReset(DateTime.now());
    habit.currentStreak += delta;
    final today = habit.progressDate;
    habit.dailyLog[today] = (habit.dailyLog[today] ?? 0) + delta;
    final beforeCompleted = habit.isCompleted;
    // Evaluate according to central policy helper
    habit.isCompleted = HabitRepository.evaluateCompletionForProgress(
      habit,
      habit.currentStreak,
    );
    if (!beforeCompleted && habit.isCompleted) {
      // ignore: unawaited_futures
      GamificationRepository.instance.onHabitCompleted(
        habitId: habit.id,
        when: DateTime.now(),
      );
    } else if (beforeCompleted && !habit.isCompleted) {
      // If someone decremented progress below target, treat as undo
      // ignore: unawaited_futures
      GamificationRepository.instance.onHabitCompletionUndone(
        habitId: habit.id,
        when: DateTime.now(),
      );
    }
    _persistAndNotify();
  }

  /// Basit (checkbox) alışkanlık toggle - simple ve checkbox türleri için
  void toggleSimple(String habitId) {
    _ensureToday();
    final habit = findById(habitId);
    if (habit == null ||
        (habit.habitType != HabitType.simple &&
            habit.habitType != HabitType.checkbox))
      return;
    habit.applyDailyReset(DateTime.now());
    final beforeCompleted = habit.isCompleted;
    habit.isCompleted = !habit.isCompleted;
    habit.currentStreak = habit.isCompleted ? habit.targetCount : 0;
    final today = habit.progressDate;
    habit.dailyLog[today] = habit.currentStreak;
    if (!beforeCompleted && habit.isCompleted) {
      // ignore: unawaited_futures
      GamificationRepository.instance.onHabitCompleted(
        habitId: habit.id,
        when: DateTime.now(),
      );
    } else if (beforeCompleted && !habit.isCompleted) {
      // Same-day undo should deduct XP if it was awarded
      // ignore: unawaited_futures
      GamificationRepository.instance.onHabitCompletionUndone(
        habitId: habit.id,
        when: DateTime.now(),
      );
    }
    _persistAndNotify();
  }

  /// Manuel değer girişi (numerical veya timer manual override senaryosu)
  void setManualProgress(String habitId, int value) {
    if (value < 0) value = 0;
    _ensureToday();
    final habit = findById(habitId);
    if (habit == null) return;
    habit.applyDailyReset(DateTime.now());
    habit.currentStreak = value;
    final today = habit.progressDate;
    habit.dailyLog[today] = value;
    final beforeCompleted = habit.isCompleted;
    habit.isCompleted = HabitRepository.evaluateCompletionForProgress(
      habit,
      habit.currentStreak,
    );
    if (!beforeCompleted && habit.isCompleted) {
      // ignore: unawaited_futures
      GamificationRepository.instance.onHabitCompleted(
        habitId: habit.id,
        when: DateTime.now(),
      );
    } else if (beforeCompleted && !habit.isCompleted) {
      // Completion undone (value dropped below target) -> deduct if awarded today
      // ignore: unawaited_futures
      GamificationRepository.instance.onHabitCompletionUndone(
        habitId: habit.id,
        when: DateTime.now(),
      );
    }
    _persistAndNotify();
  }

  /// Geçmiş (veya bugün) belirli bir tarih için simple/checkbox toggle
  void toggleSimpleForDate(String habitId, DateTime date) {
    final habit = findById(habitId);
    if (habit == null ||
        (habit.habitType != HabitType.simple &&
            habit.habitType != HabitType.checkbox))
      return;
    final dateKey = _dateStr(date);
    // Başlangıç tarihinden önceye yazma
    if (dateKey.compareTo(habit.startDate) < 0) return;
    // Bitiş tarihinden sonrasına yazma
    if (habit.endDate != null && dateKey.compareTo(habit.endDate!) > 0) return;
    final todayKey = _dateStr(DateTime.now());
    if (dateKey == todayKey) {
      // Bugün ise mevcut mekanizma
      toggleSimple(habitId);
      return;
    }
    // Geçmiş gün: sadece dailyLog girişini değiştir
    final wasCompleted = (habit.dailyLog[dateKey] ?? 0) >= habit.targetCount;
    final nowCompleted = !wasCompleted;
    habit.dailyLog[dateKey] = nowCompleted ? habit.targetCount : 0;
    // currentStreak ve isCompleted alanları bugünün durumunu temsil eder, değiştirmiyoruz.
    _persistAndNotify();
  }

  /// Alt görev toggle (bugün için)
  void toggleSubtask(String habitId, String subtaskId, bool completed) {
    _ensureToday();
    final habit = findById(habitId);
    if (habit == null || habit.habitType != HabitType.subtasks) return;
    habit.applyDailyReset(DateTime.now());

    final subtask = habit.subtasks.firstWhere(
      (s) => s.id == subtaskId,
      orElse: () => throw StateError('Subtask not found'),
    );
    final beforeCompleted = habit.isCompleted;
    subtask.isCompleted = completed;

    // Tüm alt görevler tamamlandı mı kontrol et
    final allCompleted = habit.subtasks.every((s) => s.isCompleted);
    habit.isCompleted = allCompleted;
    habit.currentStreak = allCompleted ? 1 : 0;

    final today = habit.progressDate;
    habit.dailyLog[today] = habit.currentStreak;

    // Alt görevlerin durumunu kaydet
    habit.subtasksLog[today] = habit.subtasks.map((s) => s.toJson()).toList();

    if (!beforeCompleted && habit.isCompleted) {
      // ignore: unawaited_futures
      GamificationRepository.instance.onHabitCompleted(
        habitId: habit.id,
        when: DateTime.now(),
      );
    } else if (beforeCompleted && !habit.isCompleted) {
      // ignore: unawaited_futures
      GamificationRepository.instance.onHabitCompletionUndone(
        habitId: habit.id,
        when: DateTime.now(),
      );
    }
    _persistAndNotify();
  }

  /// Belirli bir tarih için alt görev toggle
  void toggleSubtaskForDate(
    String habitId,
    String subtaskId,
    bool completed,
    DateTime date,
  ) {
    final habit = findById(habitId);
    if (habit == null || habit.habitType != HabitType.subtasks) return;
    final dateKey = _dateStr(date);

    if (dateKey.compareTo(habit.startDate) < 0) return;
    if (habit.endDate != null && dateKey.compareTo(habit.endDate!) > 0) return;

    final todayKey = _dateStr(DateTime.now());
    if (dateKey == todayKey) {
      toggleSubtask(habitId, subtaskId, completed);
      return;
    }

    // Geçmiş gün: subtasksLog'dan yükle veya mevcut subtasks'dan kopyala
    List<Map<String, dynamic>> subtasksState;
    if (habit.subtasksLog.containsKey(dateKey)) {
      subtasksState = List<Map<String, dynamic>>.from(
        habit.subtasksLog[dateKey]!,
      );
    } else {
      subtasksState = habit.subtasks
          .map((s) => {'id': s.id, 'title': s.title, 'isCompleted': false})
          .toList();
    }

    // İlgili subtask'ı güncelle
    final subtaskIndex = subtasksState.indexWhere((s) => s['id'] == subtaskId);
    if (subtaskIndex != -1) {
      subtasksState[subtaskIndex]['isCompleted'] = completed;
    }

    // Tümü tamamlandı mı kontrol et
    final allCompleted = subtasksState.every((s) => s['isCompleted'] == true);
    habit.dailyLog[dateKey] = allCompleted ? 1 : 0;
    habit.subtasksLog[dateKey] = subtasksState;

    _persistAndNotify();
  }

  /// Belirli bir tarih için manuel değer (geçmiş/today). Today ise normal setManualProgress çağırır.
  void setManualProgressForDate(String habitId, DateTime date, int value) {
    if (value < 0) value = 0;
    final habit = findById(habitId);
    if (habit == null) return;
    final dateKey = _dateStr(date);
    // Başlangıç tarihinden önceye yazma
    if (dateKey.compareTo(habit.startDate) < 0) return;
    // Bitiş tarihinden sonrasına yazma
    if (habit.endDate != null && dateKey.compareTo(habit.endDate!) > 0) return;
    final todayKey = _dateStr(DateTime.now());
    if (dateKey == todayKey) {
      setManualProgress(habitId, value);
      return;
    }
    // Geçmiş: sadece ilgili günün kaydını güncelle
    habit.dailyLog[dateKey] = value;
    // Today dışında currentStreak / isCompleted güncellenmez.
    _persistAndNotify();
  }

  void _ensureToday() {
    final now = DateTime.now();
    for (final h in _habits) {
      h.applyDailyReset(now);
    }
  }

  static String _dateStr(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _persist() async {
    print('[HabitRepository] Persisting ${_habits.length} habits...');
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _habits.map((h) => h.toJson()).toList();
    print('[HabitRepository] JSON to save:');
    for (final json in jsonList) {
      print(
        '  - ${json['emoji']} ${json['title']}: reminderEnabled=${json['reminderEnabled']}, reminderTime=${json['reminderTime']}',
      );
    }
    await prefs.setString(_storageKeyV2, jsonEncode(jsonList));
    print('[HabitRepository] Persisted successfully');
  }

  Future<void> _persistAndNotify() async {
    await _persist();
    notifyListeners();
  }

  /// Centralized completion evaluation for a given habit and a specific progress value.
  ///
  /// Rules:
  /// - simple: progress >= targetCount
  /// - numerical: based on [numericalTargetType]
  ///   - minimum: progress >= targetCount
  ///   - exact: progress == targetCount
  ///   - maximum: progress <= targetCount
  /// - timer: based on [timerTargetType]
  ///   - minimum: progress >= targetCount
  ///   - exact: progress == targetCount
  ///   - maximum: progress <= targetCount
  static bool evaluateCompletionForProgress(Habit habit, int progress) {
    switch (habit.habitType) {
      case HabitType.simple:
      case HabitType.checkbox:
        return progress >= habit.targetCount;
      case HabitType.subtasks:
        // Subtasks için progress 1 ise (tümü tamamlanmış) tamamlandı
        return progress >= 1;
      case HabitType.numerical:
        switch (habit.numericalTargetType) {
          case NumericalTargetType.minimum:
            // En az hedefe ulaşmalı
            return progress >= habit.targetCount;
          case NumericalTargetType.exact:
            return progress == habit.targetCount;
          case NumericalTargetType.maximum:
            return progress <= habit.targetCount;
        }
      case HabitType.timer:
        switch (habit.timerTargetType) {
          case TimerTargetType.minimum:
            // Süre bazlı minimum politika: en az hedefe ulaşmalı
            return progress >= habit.targetCount;
          case TimerTargetType.exact:
            return progress == habit.targetCount;
          case TimerTargetType.maximum:
            return progress <= habit.targetCount;
        }
    }
  }

  /// Evaluate completion using the habit's dailyLog for [dateKey].
  ///
  /// Important: Returns false if there is no explicit user entry for that date.
  /// This prevents auto-completing maximum/exact/minimum policies from default 0.
  static bool evaluateCompletionFromLog(Habit habit, String dateKey) {
    if (!habit.dailyLog.containsKey(dateKey)) return false;
    final int progress = habit.dailyLog[dateKey] ?? 0;
    return evaluateCompletionForProgress(habit, progress);
  }

  /// Compute consecutive-day streak length up to [upTo] (default today).
  /// A day counts if progress for that day >= targetCount.
  /// For today, also consider in-memory [isCompleted] state in addition to dailyLog.
  int consecutiveStreakFor(Habit habit, {DateTime? upTo}) {
    final DateTime end = upTo ?? DateTime.now();
    // Clamp end to not precede habit start
    DateTime cursor = end;
    final String startKey = _dateStr(DateTime.parse(habit.startDate));
    int count = 0;
    while (true) {
      final String key = _dateStr(cursor);
      if (key.compareTo(startKey) < 0) break; // before start
      if (habit.endDate != null && key.compareTo(habit.endDate!) > 0) {
        // If cursor is beyond endDate, step back until within range
        cursor = cursor.subtract(const Duration(days: 1));
        continue;
      }
      // If habit has explicit schedule and this day is not scheduled, skip without breaking
      if (habit.scheduledDates != null && habit.scheduledDates!.isNotEmpty) {
        if (!habit.scheduledDates!.contains(key)) {
          cursor = cursor.subtract(const Duration(days: 1));
          continue;
        }
      }
      final bool isToday = _dateStr(DateTime.now()) == key;
      // consider in-memory completion for today; otherwise only count if there is an explicit log entry
      bool completed = isToday
          ? habit.isCompleted
          : HabitRepository.evaluateCompletionFromLog(habit, key);
      if (!completed) break;
      count += 1;
      // previous day
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return count;
  }

  /// Convenience wrapper by habit id.
  int consecutiveStreak(String habitId, {DateTime? upTo}) {
    final h = findById(habitId);
    if (h == null) return 0;
    return consecutiveStreakFor(h, upTo: upTo);
  }
}
