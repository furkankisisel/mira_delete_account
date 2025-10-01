import 'dart:convert';

import 'package:flutter/material.dart';

/// Mood levels from worst to best.
enum MoodValue { terrible, bad, ok, good, great }

extension MoodValueX on MoodValue {
  int get score => index + 1; // 1..5
  String get label => switch (this) {
    MoodValue.terrible => 'Berbat',
    MoodValue.bad => 'Kötü',
    MoodValue.ok => 'İdare',
    MoodValue.good => 'İyi',
    MoodValue.great => 'Harika',
  };
  IconData get icon => switch (this) {
    MoodValue.terrible => Icons.sentiment_very_dissatisfied,
    MoodValue.bad => Icons.sentiment_dissatisfied,
    MoodValue.ok => Icons.sentiment_neutral,
    MoodValue.good => Icons.sentiment_satisfied,
    MoodValue.great => Icons.sentiment_very_satisfied,
  };

  static MoodValue fromScore(int n) {
    final clamped = n.clamp(1, 5);
    return MoodValue.values[clamped - 1];
  }
}

/// A single daily mood entry.
class MoodEntry {
  MoodEntry({required DateTime date, required this.mood, this.note})
    : date = DateTime(date.year, date.month, date.day);

  final DateTime date; // normalized to Y-M-D
  final MoodValue mood;
  final String? note;

  String get id => _dateKey(date);

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'mood': mood.score,
    if (note != null && note!.trim().isNotEmpty) 'note': note,
  };

  static MoodEntry fromJson(Map<String, dynamic> json) => MoodEntry(
    date: DateTime.parse(json['date'] as String),
    mood: MoodValueX.fromScore(json['mood'] as int),
    note: json['note'] as String?,
  );

  static String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}'
          .toString();

  static String dateKeyOf(DateTime d) =>
      _dateKey(DateTime(d.year, d.month, d.day));

  static String listToJsonString(List<MoodEntry> list) =>
      jsonEncode(list.map((e) => e.toJson()).toList());

  static List<MoodEntry> listFromJsonString(String s) {
    final raw = jsonDecode(s) as List<dynamic>;
    return raw
        .map((e) => MoodEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
