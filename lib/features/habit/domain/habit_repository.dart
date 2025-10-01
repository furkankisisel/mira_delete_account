import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'habit_model.dart';
import 'habit_types.dart';
import '../../gamification/gamification_repository.dart';

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
      // Eski v1 verisi varsa dene, yoksa seed et
      final rawV1 = prefs.getString(_storageKeyV1);
      if (rawV1 != null) {
        _tryMigrateV1(rawV1);
        await _persist();
      } else {
        _seedDefaults();
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
      final list = jsonDecode(raw) as List<dynamic>;
      for (final e in list) {
        if (e is Map<String, dynamic>) {
          _habits.add(Habit.fromJson(e));
        } else if (e is Map) {
          _habits.add(Habit.fromJson(e.cast<String, dynamic>()));
        }
      }
    } catch (_) {
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
                    : IconData(
                        (m['iconCodePoint'] as int?) ?? Icons.circle.codePoint,
                        fontFamily: 'MaterialIcons',
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
      if (_habits.isEmpty) _seedDefaults();
    } catch (_) {
      _seedDefaults();
    }
  }

  void _seedDefaults() {
    final today = _dateStr(DateTime.now());
    _habits.clear();
    _habits.addAll([
      Habit(
        id: 'h1',
        title: 'Su İçmek',
        description: 'Günde 8 bardak su içmek',
        icon: Icons.water_drop,
        color: Colors.blue,
        targetCount: 8,
        habitType: HabitType.numerical,
        unit: 'bardak',
        currentStreak: 0,
        isCompleted: false,
        progressDate: today,
        startDate: today,
      ),
      Habit(
        id: 'h2',
        title: 'Egzersiz',
        description: '30 dakika yürüyüş veya koşu',
        icon: Icons.fitness_center,
        color: Colors.orange,
        targetCount: 30,
        habitType: HabitType.timer,
        unit: 'dakika',
        currentStreak: 0,
        isCompleted: false,
        progressDate: today,
        startDate: today,
      ),
      Habit(
        id: 'h3',
        title: 'Kitap Okuma',
        description: 'Günde 20 sayfa kitap okumak',
        icon: Icons.menu_book,
        color: Colors.green,
        targetCount: 20,
        habitType: HabitType.numerical,
        unit: 'sayfa',
        currentStreak: 0,
        isCompleted: false,
        progressDate: today,
        startDate: today,
      ),
      Habit(
        id: 'h4',
        title: 'Meditasyon',
        description: '10 dakika nefes egzersizi',
        icon: Icons.self_improvement,
        color: Colors.purple,
        targetCount: 10,
        habitType: HabitType.timer,
        unit: 'dakika',
        currentStreak: 0,
        isCompleted: false,
        progressDate: today,
        startDate: today,
      ),
      Habit(
        id: 'h5',
        title: 'Vitamin',
        description: 'Günlük vitamin takviyesi almak',
        icon: Icons.medical_services,
        color: Colors.red,
        targetCount: 1,
        habitType: HabitType.simple,
        unit: null,
        currentStreak: 0,
        isCompleted: false,
        progressDate: today,
        startDate: today,
      ),
    ]);
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
    final idx = _habits.indexWhere((h) => h.id == habit.id);
    if (idx != -1) {
      _habits[idx] = habit;
      await _persistAndNotify();
    }
  }

  Future<void> assignHabitToList(String habitId, String? listId) async {
    final h = findById(habitId);
    if (h == null) return;
    h.listId = listId; // null to unassign
    await _persistAndNotify();
  }

  Future<void> removeHabit(String id) async {
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

  /// Basit (checkbox) alışkanlık toggle
  void toggleSimple(String habitId) {
    _ensureToday();
    final habit = findById(habitId);
    if (habit == null || habit.habitType != HabitType.simple) return;
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

  /// Geçmiş (veya bugün) belirli bir tarih için simple toggle (global currentStreak'i sadece bugün için değiştirir)
  void toggleSimpleForDate(String habitId, DateTime date) {
    final habit = findById(habitId);
    if (habit == null || habit.habitType != HabitType.simple) return;
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
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _habits.map((h) => h.toJson()).toList();
    await prefs.setString(_storageKeyV2, jsonEncode(jsonList));
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
        return progress >= habit.targetCount;
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
