import 'package:flutter/material.dart';
import '../../../core/icons/icon_mapping.dart' as icmap;

enum HabitType { simple, numerical, timer }

enum FrequencyType {
  daily,
  specificWeekdays,
  specificMonthDays,
  specificYearDays,
  periodic,
}

enum NumericalTargetType { minimum, maximum, exact }

enum TimerTargetType { minimum, maximum, exact }

enum TimePeriod { daily, weekly, monthly }

enum ListType { todo, shopping, reading }

class HabitCategory {
  final String id;
  final String name;
  final IconData icon; // legacy fallback for old data
  final String? emoji; // preferred visual mark
  final Color color;

  HabitCategory(this.id, this.name, this.icon, this.color, {this.emoji});

  bool get hasEmoji => emoji != null && emoji!.isNotEmpty;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'icon': icon.codePoint,
    'emoji': emoji,
    'color': color.value,
  };

  static HabitCategory fromJson(Map<String, dynamic> json) => HabitCategory(
    json['id'] as String,
    json['name'] as String,
    icmap.materialIconFromCodePoint((json['icon'] as num).toInt()),
    Color((json['color'] as num).toInt()),
    emoji: json['emoji'] as String?,
  );
}
