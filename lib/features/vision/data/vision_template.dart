import 'package:flutter/material.dart';

class VisionHabitTemplate {
  final String title;
  final String? description;
  final String
  type; // 'simple' | 'checkbox' | 'subtasks' | 'numerical' | 'timer'
  final int?
  target; // minutes for timer, value for numerical, ignored for simple
  final String? unit; // null for simple, e.g., 'dakika', 'adet'
  final String? emoji; // preferred visual; fallback to iconName mapping
  final String iconName; // material icon name used by seeds
  final int colorValue;
  final int startDay; // 1..365
  final int? endDay; // 0..365, optional
  // Target policy type for numerical/timer habits (optional: 'minimum'|'exact'|'maximum')
  final String? numericalTargetType;
  final String? timerTargetType;
  // Frequency configuration (optional; defaults to daily if null)
  final String?
  frequencyType; // 'daily' | 'specificWeekdays' | 'specificMonthDays' | 'specificYearDays' | 'periodic'
  final List<int>? selectedWeekdays; // 1=Mon..7=Sun (ISO-8601)
  final List<int>? selectedMonthDays; // 1..31
  final List<String>? selectedYearDays; // YYYY-MM-DD
  final int? periodicDays; // every N days
  // Explicit schedule: absolute day-offsets that should be active within [startDay..endDay]
  // Example: startDay=9, endDay=15, activeOffsets=[9,11,13,15]
  final List<int>? activeOffsets;
  // Reminder settings
  final bool? reminderEnabled;
  final TimeOfDay? reminderTime;
  // Subtasks for subtask type habits
  final List<Map<String, dynamic>>? subtasks;

  const VisionHabitTemplate({
    required this.title,
    this.description,
    required this.type,
    this.target,
    this.unit,
    this.emoji,
    required this.iconName,
    required this.colorValue,
    required this.startDay,
    this.endDay,
    this.numericalTargetType,
    this.timerTargetType,
    this.frequencyType,
    this.selectedWeekdays,
    this.selectedMonthDays,
    this.selectedYearDays,
    this.periodicDays,
    this.activeOffsets,
    this.reminderEnabled,
    this.reminderTime,
    this.subtasks,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'type': type,
    'target': target,
    'unit': unit,
    if (emoji != null) 'emoji': emoji,
    'iconName': iconName,
    'colorValue': colorValue,
    'startDay': startDay,
    if (endDay != null) 'endDay': endDay,
    if (numericalTargetType != null) 'numericalTargetType': numericalTargetType,
    if (timerTargetType != null) 'timerTargetType': timerTargetType,
    if (frequencyType != null) 'frequencyType': frequencyType,
    if (selectedWeekdays != null) 'selectedWeekdays': selectedWeekdays,
    if (selectedMonthDays != null) 'selectedMonthDays': selectedMonthDays,
    if (selectedYearDays != null) 'selectedYearDays': selectedYearDays,
    if (periodicDays != null) 'periodicDays': periodicDays,
    if (activeOffsets != null) 'activeOffsets': activeOffsets,
    if (reminderEnabled != null) 'reminderEnabled': reminderEnabled,
    if (reminderTime != null)
      'reminderTime': {
        'hour': reminderTime!.hour,
        'minute': reminderTime!.minute,
      },
    if (subtasks != null) 'subtasks': subtasks,
  };

  static VisionHabitTemplate fromJson(Map<String, dynamic> m) =>
      VisionHabitTemplate(
        title: m['title']?.toString() ?? 'Alışkanlık',
        description: m['description']?.toString(),
        type: (m['type']?.toString() ?? 'simple'),
        target: (m['target'] as num?)?.toInt(),
        unit: m['unit']?.toString(),
        emoji: m['emoji']?.toString(),
        iconName: (m['iconName']?.toString() ?? 'check_circle'),
        colorValue: (m['colorValue'] as num?)?.toInt() ?? 0xFF2196F3,
        startDay: ((m['startDay'] as num?)?.toInt() ?? 1).clamp(1, 365),
        endDay: (m['endDay'] as num?)?.toInt(),
        numericalTargetType: m['numericalTargetType']?.toString(),
        timerTargetType: m['timerTargetType']?.toString(),
        frequencyType: m['frequencyType']?.toString(),
        selectedWeekdays: (m['selectedWeekdays'] as List?)
            ?.map((e) => (e as num).toInt())
            .toList(),
        selectedMonthDays: (m['selectedMonthDays'] as List?)
            ?.map((e) => (e as num).toInt())
            .toList(),
        selectedYearDays: (m['selectedYearDays'] as List?)
            ?.map((e) => e.toString())
            .toList(),
        periodicDays: (m['periodicDays'] as num?)?.toInt(),
        activeOffsets: (m['activeOffsets'] as List?)
            ?.map((e) => (e as num).toInt())
            .toList(),
        reminderEnabled: m['reminderEnabled'] as bool?,
        reminderTime: (() {
          final rt = m['reminderTime'];
          if (rt is Map) {
            final hour = rt['hour'] as int?;
            final minute = rt['minute'] as int?;
            if (hour != null && minute != null) {
              return TimeOfDay(hour: hour, minute: minute);
            }
          }
          return null;
        })(),
        subtasks: (m['subtasks'] as List?)
            ?.map((e) => Map<String, dynamic>.from(e as Map))
            .toList(),
      );
}

class VisionTemplate {
  final String id;
  final String title;
  final String? description;
  final String? emoji;
  final int colorValue;
  final bool autoSeed;
  final List<VisionHabitTemplate> habits;
  final String? endDate; // optional absolute end date for the whole vision

  const VisionTemplate({
    required this.id,
    required this.title,
    this.description,
    this.emoji,
    required this.colorValue,
    this.autoSeed = false,
    this.habits = const [],
    this.endDate,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'emoji': emoji,
    'colorValue': colorValue,
    'autoSeed': autoSeed,
    'habits': habits.map((h) => h.toJson()).toList(),
    if (endDate != null) 'endDate': endDate,
  };

  static VisionTemplate fromJson(Map<String, dynamic> m) => VisionTemplate(
    id: m['id']?.toString() ?? 'vision',
    title: m['title']?.toString() ?? 'Vision',
    description: m['description']?.toString(),
    emoji: m['emoji']?.toString(),
    colorValue: (m['colorValue'] as num?)?.toInt() ?? 0xFF009688,
    autoSeed: m['autoSeed'] == true,
    habits:
        (m['habits'] as List?)
            ?.map(
              (e) => VisionHabitTemplate.fromJson(
                (e as Map).cast<String, dynamic>(),
              ),
            )
            .toList() ??
        const [],
    endDate: m['endDate']?.toString(),
  );
}
