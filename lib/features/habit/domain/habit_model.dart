import 'package:flutter/material.dart';
import 'habit_types.dart';

class Habit {
  Habit({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.emoji,
    required this.color,
    required this.targetCount,
    required this.habitType,
    required this.unit,
    this.frequency,
    this.frequencyType,
    this.selectedWeekdays,
    this.selectedMonthDays,
    this.selectedYearDays,
    this.periodicDays,
    required this.currentStreak,
    required this.isCompleted,
    required this.progressDate,
    required this.startDate,
    this.endDate,
    this.leftoverSeconds = 0,
    Map<String, int>? dailyLog,
    this.listId,
    this.categoryName,
    List<String>? scheduledDates,
    this.numericalTargetType = NumericalTargetType.minimum,
    this.timerTargetType = TimerTargetType.minimum,
  }) : dailyLog = dailyLog ?? <String, int>{};

  final String id;
  String title;
  String description;
  IconData icon;
  String? emoji; // preferred visual mark; fallback to icon if null
  Color color;
  int targetCount;
  HabitType habitType;
  String? unit;
  // Simple habit frequency hint (e.g., 'daily' | 'weekly'). Advanced flows use detailed scheduling elsewhere.
  String? frequency;
  // Vision-style frequency configuration for preserving edit selections
  String?
  frequencyType; // 'daily' | 'specificWeekdays' | 'specificMonthDays' | 'specificYearDays' | 'periodic'
  List<int>? selectedWeekdays; // 1..7
  List<int>? selectedMonthDays; // 1..31
  List<String>? selectedYearDays; // 'MM-DD'
  int? periodicDays; // every N days
  int currentStreak;
  bool isCompleted;
  String progressDate; // YYYY-MM-DD
  String startDate; // YYYY-MM-DD (alışkanlığın başlangıç tarihi)
  String? endDate; // YYYY-MM-DD (alışkanlığın bitiş tarihi - dahil)
  final Map<String, int> dailyLog; // tarih -> dakika/adet
  int leftoverSeconds; // Timer habit: birikmiş 60'a tamamlanmamış saniyeler
  String? listId; // ait olduğu liste
  String?
  categoryName; // Optional user-visible category name (custom categories)
  bool isAdvanced = false; // gelişmiş habit mi (çoklu saat vb.)
  List<String>?
  scheduledDates; // ISO-YYYY-MM-DD list of days when this habit is active
  // Target evaluation policy
  NumericalTargetType numericalTargetType;
  TimerTargetType timerTargetType;

  void applyDailyReset(DateTime now) {
    final today = _dateStr(now);
    if (progressDate != today) {
      progressDate = today;
      currentStreak = 0;
      isCompleted = false;
      leftoverSeconds = 0;
    }
  }

  void addTimerProgress(Duration duration) {
    if (habitType != HabitType.timer) return;
    final secs = duration.inSeconds;
    if (secs <= 0) return;
    leftoverSeconds += secs;
    int gainedMinutes = 0;
    if (leftoverSeconds >= 60) {
      gainedMinutes = leftoverSeconds ~/ 60;
      leftoverSeconds = leftoverSeconds % 60;
    }
    if (gainedMinutes > 0) {
      final today = progressDate; // reset önce çağrılmış olmalı
      currentStreak += gainedMinutes;
      dailyLog[today] = (dailyLog[today] ?? 0) + gainedMinutes;
      if (currentStreak >= targetCount) isCompleted = true;
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'iconCodePoint': icon.codePoint,
    'emoji': emoji,
    'colorValue': color.value,
    'targetCount': targetCount,
    'habitType': habitType.toString(),
    'unit': unit,
    'frequency': frequency,
    'frequencyType': frequencyType,
    if (selectedWeekdays != null) 'selectedWeekdays': selectedWeekdays,
    if (selectedMonthDays != null) 'selectedMonthDays': selectedMonthDays,
    if (selectedYearDays != null) 'selectedYearDays': selectedYearDays,
    if (periodicDays != null) 'periodicDays': periodicDays,
    'currentStreak': currentStreak,
    'isCompleted': isCompleted,
    'progressDate': progressDate,
    'startDate': startDate,
    'endDate': endDate,
    'dailyLog': dailyLog,
    'leftoverSeconds': leftoverSeconds,
    'listId': listId,
    'categoryName': categoryName,
    'isAdvanced': isAdvanced,
    'numericalTargetType': numericalTargetType.toString(),
    'timerTargetType': timerTargetType.toString(),
    if (scheduledDates != null) 'scheduledDates': scheduledDates,
  };

  static Habit fromJson(Map<String, dynamic> json) {
    final type = HabitType.values.firstWhere(
      (h) => h.toString() == json['habitType'],
      orElse: () => HabitType.simple,
    );
    int target = json['targetCount'] as int? ?? 0;

    final numTypeStr = json['numericalTargetType']?.toString();
    NumericalTargetType numType = NumericalTargetType.minimum;
    if (numTypeStr != null) {
      if (numTypeStr.contains('exact'))
        numType = NumericalTargetType.exact;
      else if (numTypeStr.contains('maximum'))
        numType = NumericalTargetType.maximum;
      else
        numType = NumericalTargetType.minimum;
    }
    final timTypeStr = json['timerTargetType']?.toString();
    // Clamp invalid targets with awareness of type
    if (type == HabitType.timer) {
      if (target <= 0) target = 10; // default sensible minimum for timers
    } else if (type == HabitType.simple) {
      if (target <= 0) target = 1; // simple checkboxes require at least 1
    } else {
      // numerical: allow 0 (for abstinence-style maximum policies)
      if (target < 0) target = 0;
    }
    TimerTargetType timType = TimerTargetType.minimum;
    if (timTypeStr != null) {
      if (timTypeStr.contains('exact'))
        timType = TimerTargetType.exact;
      else if (timTypeStr.contains('maximum'))
        timType = TimerTargetType.maximum;
      else
        timType = TimerTargetType.minimum;
    }

    return Habit(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      icon: IconData(json['iconCodePoint'] as int, fontFamily: 'MaterialIcons'),
      emoji: json['emoji'] as String?,
      color: Color(json['colorValue'] as int),
      targetCount: target,
      habitType: type,
      unit: json['unit'] as String?,
      frequency: json['frequency'] as String?,
      frequencyType: json['frequencyType'] as String?,
      selectedWeekdays: (json['selectedWeekdays'] as List?)
          ?.whereType<num>()
          .map((e) => e.toInt())
          .toList(),
      selectedMonthDays: (json['selectedMonthDays'] as List?)
          ?.whereType<num>()
          .map((e) => e.toInt())
          .toList(),
      selectedYearDays: (json['selectedYearDays'] as List?)
          ?.map((e) => e.toString())
          .toList(),
      periodicDays: (json['periodicDays'] as num?)?.toInt(),
      currentStreak: json['currentStreak'] as int? ?? 0,
      isCompleted: json['isCompleted'] as bool? ?? false,
      progressDate: json['progressDate'] as String? ?? _dateStr(DateTime.now()),
      startDate:
          json['startDate'] as String? ??
          (json['progressDate'] as String? ?? _dateStr(DateTime.now())),
      endDate: json['endDate'] as String?,
      dailyLog:
          (json['dailyLog'] as Map?)?.map(
            (k, v) => MapEntry(k.toString(), (v as num).toInt()),
          ) ??
          {},
      leftoverSeconds: (json['leftoverSeconds'] as num?)?.toInt() ?? 0,
      listId: json['listId'] as String?,
      categoryName: json['categoryName'] as String?,
      scheduledDates: (json['scheduledDates'] as List?)
          ?.map((e) => e.toString())
          .toList(),
      numericalTargetType: numType,
      timerTargetType: timType,
    )..isAdvanced = (json['isAdvanced'] as bool?) ?? false;
  }

  static String _dateStr(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
