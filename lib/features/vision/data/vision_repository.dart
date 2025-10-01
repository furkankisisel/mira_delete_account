import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../../habit/domain/habit_repository.dart';
import '../../habit/domain/habit_model.dart';
import '../../habit/domain/habit_types.dart';
import 'vision_template.dart';

import 'vision_model.dart';

class VisionRepository {
  static final instance = VisionRepository._();
  VisionRepository._();

  static const _storageKey = 'visions_v1';
  static const _seedKey = 'visions_seeded_v1';

  final _controller = StreamController<List<Vision>>.broadcast();
  List<Vision> _items = const [];

  Stream<List<Vision>> get stream => _controller.stream;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null && raw.isNotEmpty) {
      final list = (json.decode(raw) as List).cast<Map<String, dynamic>>();
      _items = list.map(Vision.fromJson).toList();
    } else {
      final seeded = prefs.getBool(_seedKey) ?? false;
      if (!seeded) {
        await _seedDefaults(prefs);
      } else {
        _items = const [];
      }
      await _persist();
    }
    _emit();
  }

  Future<void> _seedDefaults(SharedPreferences prefs) async {
    try {
      final raw = await _loadTemplatesRaw();
      if (raw == null) {
        _items = const [];
        await prefs.setBool(_seedKey, true);
        return;
      }
      final habitRepo = HabitRepository.instance;
      await habitRepo.initialize();
      final createdVisions = <Vision>[];
      for (final v in raw) {
        final autoSeed = (v['autoSeed'] as bool?) ?? true;
        if (!autoSeed) continue; // do not seed optional templates by default
        final nowId =
            v['id']?.toString() ??
            'vision_${DateTime.now().millisecondsSinceEpoch}';
        final colorValue =
            (v['colorValue'] as num?)?.toInt() ?? Colors.teal.toARGB32();
        final habits =
            (v['habits'] as List?)?.cast<Map<String, dynamic>>() ?? const [];
        // Use a single base date per vision
        final DateTime base = DateTime.now();
        // Determine a finite duration (in days) from template content; fallback 30
        int maxDay = -1;
        for (final h in habits) {
          final int? e = (h['endDay'] as num?)?.toInt();
          if (e != null && e > maxDay) maxDay = e;
          final offs = (h['activeOffsets'] as List?)
              ?.whereType<num>()
              .map((n) => n.toInt())
              .toList();
          if (offs != null && offs.isNotEmpty) {
            final m = offs.reduce((a, b) => a > b ? a : b);
            if (m > maxDay) maxDay = m;
          }
        }
        final int durationDays = (maxDay >= 0 ? maxDay : 30).clamp(1, 365);
        final linkedIds = <String>[];
        for (final h in habits) {
          final habitId = UniqueKey().toString();
          final typeStr = (h['type'] as String?) ?? 'simple';
          final HabitType type = switch (typeStr) {
            'numerical' => HabitType.numerical,
            'timer' => HabitType.timer,
            _ => HabitType.simple,
          };
          int target =
              (h['target'] as num?)?.toInt() ??
              (type == HabitType.simple
                  ? 1
                  : (type == HabitType.timer ? 10 : 0));
          // Enforce per type; allow numerical=0
          if (type == HabitType.simple) {
            if (target <= 0) target = 1;
          } else if (type == HabitType.numerical) {
            if (target < 0) target = 0;
          } else if (type == HabitType.timer) {
            if (target <= 0) target = 10;
          }
          String? unit = (h['unit'] as String?)?.trim();
          if (type == HabitType.timer) {
            unit = 'dakika';
            if (target == 0) target = 10;
          }
          final iconName = (h['iconName'] as String?) ?? 'check_circle';
          final icon = _iconFromName(iconName);
          final emojiStr =
              (h['emoji'] as String?)?.trim() ?? _emojiFromIconName(iconName);
          final color = Color(
            (h['colorValue'] as num?)?.toInt() ?? Colors.blue.toARGB32(),
          );
          // Map day-offsets to absolute dates based on creation date of vision (today)
          final int startDay = ((h['startDay'] as num?)?.toInt() ?? 1).clamp(
            1,
            365,
          );
          final int? endDayInput = (h['endDay'] as num?)?.toInt();
          final int clampedWithinVision = (endDayInput ?? durationDays).clamp(
            1,
            durationDays,
          );
          final int? endDay = endDayInput == null
              ? null
              : clampedWithinVision.clamp(1, 365);
          final DateTime startDt = base.add(Duration(days: startDay - 1));
          final DateTime? endDt = endDay != null
              ? base.add(Duration(days: endDay - 1))
              : null;
          final today = base.toIso8601String().split('T').first;
          final String startKey = _dateKey(startDt);
          final String? endKey = endDt != null ? _dateKey(endDt) : null;
          final List<String>? schedule = _buildSchedule(
            base: base,
            startDay: startDay,
            endDay: endDay,
            tpl: h,
          );
          // Choose target policies: default minimum; allow numerical target 0 => maximum
          // Determine target policy from template when provided; otherwise fallback.
          NumericalTargetType numType = NumericalTargetType.minimum;
          if (type == HabitType.numerical) {
            final String? policy = (h['numericalTargetType'] as String?)
                ?.toLowerCase();
            if (policy != null) {
              if (policy.contains('exact')) {
                numType = NumericalTargetType.exact;
              } else if (policy.contains('max')) {
                numType = NumericalTargetType.maximum;
              } else {
                numType = NumericalTargetType.minimum;
              }
            } else {
              numType = (target == 0)
                  ? NumericalTargetType.maximum
                  : NumericalTargetType.minimum;
            }
          }
          TimerTargetType timType = TimerTargetType.minimum;
          if (type == HabitType.timer) {
            final String? policy = (h['timerTargetType'] as String?)
                ?.toLowerCase();
            if (policy != null) {
              if (policy.contains('exact')) {
                timType = TimerTargetType.exact;
              } else if (policy.contains('max')) {
                timType = TimerTargetType.maximum;
              } else {
                timType = TimerTargetType.minimum;
              }
            } else {
              timType = TimerTargetType.minimum;
            }
          }
          final habit = Habit(
            id: habitId,
            title: (h['title'] as String?) ?? 'Alışkanlık',
            description: (h['description'] as String?) ?? '',
            icon: icon,
            emoji: emojiStr,
            color: color,
            targetCount: target,
            habitType: type,
            unit: type == HabitType.simple ? null : unit,
            currentStreak: 0,
            isCompleted: false,
            progressDate: today,
            startDate: startKey,
            endDate: endKey,
            scheduledDates: schedule,
            numericalTargetType: numType,
            timerTargetType: timType,
          );
          await habitRepo.addHabit(habit);
          linkedIds.add(habitId);
        }
        createdVisions.add(
          Vision(
            id: nowId,
            title: v['title']?.toString() ?? 'Vision',
            description: v['description']?.toString(),
            emoji: v['emoji']?.toString(),
            colorValue: colorValue,
            linkedHabitIds: linkedIds,
            createdAt: DateTime.now(),
            endDate: base.add(Duration(days: durationDays)),
            startDate: base,
          ),
        );
      }
      _items = createdVisions;
    } catch (_) {
      _items = const [];
    }
    await prefs.setBool(_seedKey, true);
  }

  /// Create a vision from seed (by id) and also create/link its habits.
  Future<Vision?> createFromSeed(String seedId) async {
    try {
      final raw = await _loadTemplatesRaw();
      if (raw == null) return null;
      final data = raw.firstWhere((e) => e['id'] == seedId, orElse: () => {});
      if (data.isEmpty) return null;
      final habitRepo = HabitRepository.instance;
      await habitRepo.initialize();
      final DateTime base = DateTime.now();
      // Compute finite duration from content (max endDay/offsets) or fallback 30; honor template endDate if present
      int maxDay = -1;
      for (final h
          in (data['habits'] as List?)?.cast<Map<String, dynamic>>() ??
              const []) {
        final int? e = (h['endDay'] as num?)?.toInt();
        if (e != null && e > maxDay) maxDay = e;
        final offs = (h['activeOffsets'] as List?)
            ?.whereType<num>()
            .map((n) => n.toInt())
            .toList();
        if (offs != null && offs.isNotEmpty) {
          final m = offs.reduce((a, b) => a > b ? a : b);
          if (m > maxDay) maxDay = m;
        }
      }
      int durationDays = (maxDay >= 0 ? maxDay : 30).clamp(1, 365);
      DateTime? templateEnd;
      final endStr = data['endDate'] as String?;
      if (endStr != null && endStr.length >= 10) {
        try {
          templateEnd = DateTime.parse(endStr);
          final diff = templateEnd.difference(base).inDays;
          if (diff > 0) durationDays = diff.clamp(1, 365);
        } catch (_) {}
      }
      final linked = <String>[];
      for (final h
          in (data['habits'] as List?)?.cast<Map<String, dynamic>>() ??
              const []) {
        final id = UniqueKey().toString();
        final typeStr = (h['type'] as String?) ?? 'simple';
        final HabitType type = switch (typeStr) {
          'numerical' => HabitType.numerical,
          'timer' => HabitType.timer,
          _ => HabitType.simple,
        };
        int target =
            (h['target'] as num?)?.toInt() ??
            (type == HabitType.simple ? 1 : (type == HabitType.timer ? 10 : 0));
        // Enforce per type; allow numerical=0
        if (type == HabitType.simple) {
          if (target <= 0) target = 1;
        } else if (type == HabitType.numerical) {
          if (target < 0) target = 0;
        } else if (type == HabitType.timer) {
          if (target <= 0) target = 10;
        }
        String? unit = (h['unit'] as String?)?.trim();
        if (type == HabitType.timer) {
          unit = 'dakika';
          if (target == 0) target = 10;
        }
        final iconName = (h['iconName'] as String?) ?? 'check_circle';
        final icon = _iconFromName(iconName);
        final emojiStr =
            (h['emoji'] as String?)?.trim() ?? _emojiFromIconName(iconName);
        final color = Color(
          (h['colorValue'] as num?)?.toInt() ?? Colors.blue.toARGB32(),
        );
        final int startDay = ((h['startDay'] as num?)?.toInt() ?? 1).clamp(
          1,
          365,
        );
        int? endDayRaw = (h['endDay'] as num?)?.toInt();
        // If endDay not provided, default to computed vision duration
        endDayRaw = (endDayRaw ?? durationDays).clamp(1, durationDays);
        final int? endDay = endDayRaw.clamp(1, 365);
        final DateTime startDt = base.add(Duration(days: startDay - 1));
        final DateTime? endDt = endDay != null
            ? base.add(Duration(days: endDay - 1))
            : null;
        final today = base.toIso8601String().split('T').first;
        final String startKey = _dateKey(startDt);
        final String? endKey = endDt != null ? _dateKey(endDt) : null;
        final List<String>? schedule = _buildSchedule(
          base: base,
          startDay: startDay,
          endDay: endDay,
          tpl: h,
        );
        NumericalTargetType numType = NumericalTargetType.minimum;
        if (type == HabitType.numerical) {
          final String? policy = (h['numericalTargetType'] as String?)
              ?.toLowerCase();
          if (policy != null) {
            if (policy.contains('exact')) {
              numType = NumericalTargetType.exact;
            } else if (policy.contains('max')) {
              numType = NumericalTargetType.maximum;
            } else {
              numType = NumericalTargetType.minimum;
            }
          } else {
            numType = (target == 0)
                ? NumericalTargetType.maximum
                : NumericalTargetType.minimum;
          }
        }
        TimerTargetType timType = TimerTargetType.minimum;
        if (type == HabitType.timer) {
          final String? policy = (h['timerTargetType'] as String?)
              ?.toLowerCase();
          if (policy != null) {
            if (policy.contains('exact')) {
              timType = TimerTargetType.exact;
            } else if (policy.contains('max')) {
              timType = TimerTargetType.maximum;
            } else {
              timType = TimerTargetType.minimum;
            }
          } else {
            timType = TimerTargetType.minimum;
          }
        }
        final habit = Habit(
          id: id,
          title: (h['title'] as String?) ?? 'Alışkanlık',
          description: (h['description'] as String?) ?? '',
          icon: icon,
          emoji: emojiStr,
          color: color,
          targetCount: target,
          habitType: type,
          unit: type == HabitType.simple ? null : unit,
          currentStreak: 0,
          isCompleted: false,
          progressDate: today,
          startDate: startKey,
          endDate: endKey,
          scheduledDates: schedule,
          numericalTargetType: numType,
          timerTargetType: timType,
        );
        await habitRepo.addHabit(habit);
        linked.add(id);
      }
      final v = Vision(
        // Use a unique id per created instance to avoid collisions with existing visions
        // even when the same seed is used multiple times.
        id: (() {
          final base = data['id']?.toString() ?? 'vision';
          final ts = DateTime.now().millisecondsSinceEpoch;
          return '${base}_$ts';
        })(),
        title: data['title']?.toString() ?? 'Vision',
        description: data['description']?.toString(),
        emoji: data['emoji']?.toString(),
        colorValue:
            (data['colorValue'] as num?)?.toInt() ?? Colors.teal.toARGB32(),
        linkedHabitIds: linked,
        createdAt: DateTime.now(),
        endDate: templateEnd ?? base.add(Duration(days: durationDays)),
        startDate: base,
      );
      await add(v);
      return v;
    } catch (_) {
      return null;
    }
  }

  /// Create a vision instance directly from a VisionTemplate.
  /// If [durationDays] is provided, any habit endDay beyond duration will be clamped to duration.
  Future<Vision?> createFromTemplate(
    dynamic template, {
    int? durationDays,
    DateTime? startDate,
  }) async {
    try {
      // Allow passing either a VisionTemplate or a Map<String,dynamic> with similar shape
      final map = template is Map<String, dynamic>
          ? template
          : (template as dynamic).toJson() as Map<String, dynamic>;
      final habitRepo = HabitRepository.instance;
      await habitRepo.initialize();
      final linked = <String>[];
      final rawBase = startDate ?? DateTime.now();
      final base = DateTime(rawBase.year, rawBase.month, rawBase.day);
      int durLocal;
      if (durationDays == null) {
        int maxDay = -1;
        for (final h
            in (map['habits'] as List?)?.cast<Map<String, dynamic>>() ??
                const []) {
          final int? e = (h['endDay'] as num?)?.toInt();
          if (e != null && e > maxDay) maxDay = e;
          final offs = (h['activeOffsets'] as List?)
              ?.whereType<num>()
              .map((n) => n.toInt())
              .toList();
          if (offs != null && offs.isNotEmpty) {
            final m = offs.reduce((a, b) => a > b ? a : b);
            if (m > maxDay) maxDay = m;
          }
        }
        durLocal = (maxDay >= 0 ? maxDay : 30).clamp(1, 365);
      } else {
        durLocal = durationDays.clamp(1, 365);
      }
      for (final h
          in (map['habits'] as List?)?.cast<Map<String, dynamic>>() ??
              const []) {
        final id = UniqueKey().toString();
        final typeStr = (h['type'] as String?) ?? 'simple';
        final HabitType type = switch (typeStr) {
          'numerical' => HabitType.numerical,
          'timer' => HabitType.timer,
          _ => HabitType.simple,
        };
        int target =
            (h['target'] as num?)?.toInt() ??
            (type == HabitType.simple ? 1 : 0);
        if (type == HabitType.timer) {
          if (target <= 0) target = 10;
        } else {
          if (target <= 0) target = 1;
        }
        String? unit = (h['unit'] as String?)?.trim();
        if (type == HabitType.timer) {
          unit = 'dakika';
          if (target == 0) target = 10;
        }
        final iconName = (h['iconName'] as String?) ?? 'check_circle';
        final icon = _iconFromName(iconName);
        final emojiStr =
            (h['emoji'] as String?)?.trim() ?? _emojiFromIconName(iconName);
        final color = Color(
          (h['colorValue'] as num?)?.toInt() ?? Colors.blue.toARGB32(),
        );
        final int startDay = ((h['startDay'] as num?)?.toInt() ?? 1).clamp(
          1,
          365,
        );
        final int? endDayInput = (h['endDay'] as num?)?.toInt();
        final int clampedWithinVision = (endDayInput ?? durLocal).clamp(
          1,
          durLocal,
        );
        final int? endDay = endDayInput == null
            ? null
            : clampedWithinVision.clamp(1, 365);
        final DateTime startDt = base.add(Duration(days: startDay - 1));
        final DateTime? endDt = endDay != null
            ? base.add(Duration(days: endDay - 1))
            : null;
        final today = base.toIso8601String().split('T').first;
        final String startKey = _dateKey(startDt);
        final String? endKey = endDt != null ? _dateKey(endDt) : null;
        final List<String>? schedule = _buildSchedule(
          base: base,
          startDay: startDay,
          endDay: endDay,
          tpl: h,
        );
        NumericalTargetType numType = NumericalTargetType.minimum;
        if (type == HabitType.numerical) {
          final String? policy = (h['numericalTargetType'] as String?)
              ?.toLowerCase();
          if (policy != null) {
            if (policy.contains('exact')) {
              numType = NumericalTargetType.exact;
            } else if (policy.contains('max')) {
              numType = NumericalTargetType.maximum;
            } else {
              numType = NumericalTargetType.minimum;
            }
          } else {
            numType = (target == 0)
                ? NumericalTargetType.maximum
                : NumericalTargetType.minimum;
          }
        }
        TimerTargetType timType = TimerTargetType.minimum;
        if (type == HabitType.timer) {
          final String? policy = (h['timerTargetType'] as String?)
              ?.toLowerCase();
          if (policy != null) {
            if (policy.contains('exact')) {
              timType = TimerTargetType.exact;
            } else if (policy.contains('max')) {
              timType = TimerTargetType.maximum;
            } else {
              timType = TimerTargetType.minimum;
            }
          } else {
            timType = TimerTargetType.minimum;
          }
        }
        final habit = Habit(
          id: id,
          title: (h['title'] as String?) ?? 'Alışkanlık',
          description: (h['description'] as String?) ?? '',
          icon: icon,
          emoji: emojiStr,
          color: color,
          targetCount: target,
          habitType: type,
          unit: type == HabitType.simple ? null : unit,
          currentStreak: 0,
          isCompleted: false,
          progressDate: today,
          startDate: startKey,
          endDate: endKey,
          scheduledDates: schedule,
          numericalTargetType: numType,
          timerTargetType: timType,
        );
        await habitRepo.addHabit(habit);
        linked.add(id);
      }
      final v = Vision(
        id: (() {
          final baseId = map['id']?.toString() ?? 'vision';
          final ts = DateTime.now().millisecondsSinceEpoch;
          return '${baseId}_$ts';
        })(),
        title: map['title']?.toString() ?? 'Vision',
        description: map['description']?.toString(),
        emoji: map['emoji']?.toString(),
        colorValue:
            (map['colorValue'] as num?)?.toInt() ?? Colors.teal.toARGB32(),
        linkedHabitIds: linked,
        createdAt: DateTime.now(),
        endDate: base.add(Duration(days: durLocal)),
        startDate: base,
      );
      await add(v);
      return v;
    } catch (_) {
      return null;
    }
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// Build concrete scheduled dates for a habit template between [startDay]..[endDay].
  /// If the template provides explicit `activeOffsets`, those are preferred.
  /// Otherwise falls back to `frequencyType` options. Returns null if no finite
  /// range is provided (i.e., endDay is null) so the habit behaves as daily by default.
  List<String>? _buildSchedule({
    required DateTime base,
    required int startDay,
    required int? endDay,
    required Map<String, dynamic> tpl,
  }) {
    if (endDay == null)
      return null; // open-ended: treat as daily without explicit list
    int s = startDay;
    int e = endDay;
    if (e < s) {
      final t = e;
      e = s;
      s = t;
    }
    // Prefer explicit activeOffsets
    if (tpl['activeOffsets'] is List) {
      final offs =
          (tpl['activeOffsets'] as List)
              .whereType<num>()
              .map((n) => n.toInt())
              .where((o) => o >= s && o <= e)
              .toSet()
              .toList()
            ..sort();
      return offs
          .map((o) => _dateKey(base.add(Duration(days: o - 1))))
          .toList(growable: false);
    }
    final String? freq = (tpl['frequencyType'] as String?);
    final List<String> out = [];
    DateTime startDate = base.add(Duration(days: s - 1));
    DateTime endDate = base.add(Duration(days: e - 1));
    bool inRange(DateTime d) =>
        !d.isBefore(DateTime(startDate.year, startDate.month, startDate.day)) &&
        !d.isAfter(DateTime(endDate.year, endDate.month, endDate.day));
    if (freq == null || freq == 'daily') {
      for (int o = s; o <= e; o++) {
        out.add(_dateKey(base.add(Duration(days: o - 1))));
      }
      return out;
    }
    switch (freq) {
      case 'specificWeekdays':
        final days =
            (tpl['selectedWeekdays'] as List?)
                ?.whereType<num>()
                .map((n) => n.toInt())
                .toSet() ??
            {};
        for (int o = s; o <= e; o++) {
          final d = base.add(Duration(days: o - 1));
          if (days.contains(d.weekday)) out.add(_dateKey(d));
        }
        return out;
      case 'specificMonthDays':
        final days =
            (tpl['selectedMonthDays'] as List?)
                ?.whereType<num>()
                .map((n) => n.toInt())
                .toSet() ??
            {};
        for (int o = s; o <= e; o++) {
          final d = base.add(Duration(days: o - 1));
          if (days.contains(d.day)) out.add(_dateKey(d));
        }
        return out;
      case 'specificYearDays':
        final ys =
            (tpl['selectedYearDays'] as List?)
                ?.map((e) => e.toString())
                .toSet() ??
            {};
        // include only those within [startDate..endDate]
        for (final y in ys) {
          try {
            final d = DateTime.parse(y);
            if (inRange(d)) out.add(_dateKey(d));
          } catch (_) {}
        }
        out.sort();
        return out;
      case 'periodic':
        final n = ((tpl['periodicDays'] as num?)?.toInt() ?? 1);
        final step = n <= 0 ? 1 : n;
        for (int o = s; o <= e; o++) {
          if ((o - s) % step == 0)
            out.add(_dateKey(base.add(Duration(days: o))));
        }
        return out;
      default:
        // Fallback daily
        for (int o = s; o <= e; o++) {
          out.add(_dateKey(base.add(Duration(days: o))));
        }
        return out;
    }
  }

  /// Attempt to load templates JSON from known asset paths.
  /// Returns parsed list on success, or null on failure.
  Future<List<Map<String, dynamic>>?> _loadTemplatesRaw() async {
    final lang = ui.PlatformDispatcher.instance.locale.languageCode;
    final paths = <String>[
      if (lang.isNotEmpty) 'assets/seeds/vision_templates.$lang.json',
      'assets/seeds/vision_templates.json',
      'assets/vision_templates.json',
    ];
    for (final p in paths) {
      try {
        final jsonStr = await rootBundle.loadString(p);
        final raw = (json.decode(jsonStr) as List).cast<Map<String, dynamic>>();
        return raw;
      } catch (_) {
        // try next path
      }
    }
    return null;
  }

  // Public helper for UI layers to map icon names consistently with seeds.
  static IconData iconFromName(String name) => _iconFromName(name);

  static IconData _iconFromName(String name) {
    switch (name) {
      case 'water_drop':
        return Icons.water_drop;
      case 'fitness_center':
        return Icons.fitness_center;
      case 'restaurant':
        return Icons.restaurant;
      case 'school':
        return Icons.school;
      case 'check_circle':
        return Icons.check_circle;
      case 'groups':
        return Icons.groups;
      case 'account_balance_wallet':
        return Icons.account_balance_wallet;
      case 'savings':
        return Icons.account_balance_wallet;
      case 'receipt_long':
        return Icons.receipt_long;
      case 'smoke_free':
        return Icons.smoke_free;
      case 'phonelink_off':
        return Icons.phonelink_off;
      case 'notifications_off':
        return Icons.notifications_off;
      case 'book':
        return Icons.book;
      case 'free_breakfast':
        return Icons.free_breakfast;
      case 'bedtime':
        return Icons.bedtime;
      case 'dark_mode':
        return Icons.dark_mode;
      case 'no_drinks':
        return Icons.no_drinks;
      case 'icecream':
        return Icons.icecream;
      case 'no_food':
        return Icons.no_food;
      default:
        return Icons.check_circle;
    }
  }

  // Map common icon names used in seeds to emoji to prefer emoji-first look
  static String _emojiFromIconName(String name) {
    switch (name) {
      case 'water_drop':
        return '💧';
      case 'fitness_center':
        return '🏋️';
      case 'restaurant':
        return '🍽️';
      case 'school':
        return '🎓';
      case 'groups':
        return '👥';
      case 'account_balance_wallet':
      case 'savings':
        return '👛';
      case 'receipt_long':
        return '🧾';
      case 'smoke_free':
        return '🚭';
      case 'phonelink_off':
        return '📵';
      case 'notifications_off':
        return '🔕';
      case 'book':
        return '📚';
      case 'free_breakfast':
        return '☕';
      case 'bedtime':
      case 'dark_mode':
        return '🌙';
      case 'no_drinks':
        return '🍹🚫';
      case 'icecream':
        return '🍦';
      case 'no_food':
        return '🍔🚫';
      default:
        return '✅';
    }
  }

  List<Vision> all() => List.unmodifiable(_items);

  Future<void> add(Vision v) async {
    _items = [..._items, v];
    await _persist();
  }

  Future<void> update(Vision v) async {
    final index = _items.indexWhere((element) => element.id == v.id);
    if (index == -1) return;

    final previous = _items[index];
    final DateTime? oldStart = previous.startDate;
    final DateTime? newStart = v.startDate;
    final bool startChanged = _hasStartChanged(oldStart, newStart);

    if (startChanged && newStart != null) {
      await _rebaseLinkedHabits(
        habitIds: v.linkedHabitIds,
        oldBase: oldStart,
        newBase: newStart,
      );
    }

    final updatedItems = [..._items];
    updatedItems[index] = v;
    _items = updatedItems;
    await _persist();
  }

  bool _hasStartChanged(DateTime? previous, DateTime? next) {
    if (previous == null && next == null) return false;
    if (previous == null || next == null) return true;
    return !_isSameDay(_dateOnly(previous), _dateOnly(next));
  }

  Future<void> _rebaseLinkedHabits({
    required List<String> habitIds,
    DateTime? oldBase,
    required DateTime newBase,
  }) async {
    if (habitIds.isEmpty) return;

    final habitRepo = HabitRepository.instance;
    await habitRepo.initialize();

    final DateTime normalizedNew = _dateOnly(newBase);
    DateTime? normalizedOld = oldBase != null ? _dateOnly(oldBase) : null;

    if (normalizedOld == null) {
      for (final id in habitIds) {
        final habit = habitRepo.findById(id);
        if (habit == null) continue;
        final start = _tryParseDay(habit.startDate);
        if (start == null) continue;
        if (normalizedOld == null || start.isBefore(normalizedOld)) {
          normalizedOld = start;
        }
      }
    }

    if (normalizedOld == null || _isSameDay(normalizedOld, normalizedNew))
      return;

    final DateTime sourceBase = normalizedOld;

    for (final id in habitIds) {
      final habit = habitRepo.findById(id);
      if (habit == null) continue;

      final DateTime habitStart = _tryParseDay(habit.startDate) ?? sourceBase;
      final int startOffset = habitStart.difference(sourceBase).inDays;
      final DateTime shiftedStart = normalizedNew.add(
        Duration(days: startOffset),
      );
      habit.startDate = _dateKey(shiftedStart);

      if (habit.endDate != null && habit.endDate!.isNotEmpty) {
        final DateTime? parsedEnd = _tryParseDay(habit.endDate!);
        if (parsedEnd != null) {
          final int endOffset = parsedEnd.difference(sourceBase).inDays;
          DateTime shiftedEnd = normalizedNew.add(Duration(days: endOffset));
          if (shiftedEnd.isBefore(shiftedStart)) {
            shiftedEnd = shiftedStart;
          }
          habit.endDate = _dateKey(shiftedEnd);
        }
      }

      if (habit.scheduledDates != null && habit.scheduledDates!.isNotEmpty) {
        final adjusted = <String>[];
        final seen = <String>{};
        for (final iso in habit.scheduledDates!) {
          final DateTime? parsed = _tryParseDay(iso);
          if (parsed == null) continue;
          final int diff = parsed.difference(sourceBase).inDays;
          final DateTime shifted = normalizedNew.add(Duration(days: diff));
          final formatted = _dateKey(shifted);
          if (seen.add(formatted)) {
            adjusted.add(formatted);
          }
        }
        adjusted.sort();
        habit.scheduledDates = adjusted.isEmpty ? null : adjusted;
      }

      await habitRepo.updateHabit(habit);
    }
  }

  Future<void> updateLayout({
    required String id,
    required double posX,
    required double posY,
    required double scale,
  }) async {
    final i = _items.indexWhere((v) => v.id == id);
    if (i == -1) return;
    final clampedX = posX; // allow beyond edges
    final clampedY = posY; // allow beyond edges
    final clampedScale = scale.clamp(0.5, 3.0);
    _items[i] = _items[i].copyWith(
      posX: clampedX,
      posY: clampedY,
      scale: clampedScale,
    );
    await _persist();
  }

  Future<void> remove(String id) async {
    _items = _items.where((e) => e.id != id).toList();
    await _persist();
  }

  /// Force re-seeding of bundled vision templates.
  ///
  /// This will clear all existing visions. If [deleteLinkedHabits] is true,
  /// it will also remove habits that were linked to those visions (best-effort).
  /// Use with caution; this is intended for development or a user “reset templates” action.
  Future<void> reseedDefaults({bool deleteLinkedHabits = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final old = List<Vision>.from(_items);
    _items = [];
    await _persist();
    if (deleteLinkedHabits && old.isNotEmpty) {
      final habitRepo = HabitRepository.instance;
      await habitRepo.initialize();
      for (final v in old) {
        for (final hid in v.linkedHabitIds) {
          try {
            await habitRepo.removeHabit(hid);
          } catch (_) {
            /* ignore */
          }
        }
      }
    }
    // Allow seeding again
    await prefs.setBool(_seedKey, false);
    await _seedDefaults(prefs);
    await _persist();
  }

  /// Remove a vision, optionally deleting its linked habits as well.
  Future<void> removeWithCascade(
    String id, {
    bool deleteLinkedHabits = false,
  }) async {
    final i = _items.indexWhere((v) => v.id == id);
    if (i == -1) return;
    final v = _items[i];
    // Remove the vision first
    _items.removeAt(i);
    await _persist();
    if (deleteLinkedHabits && v.linkedHabitIds.isNotEmpty) {
      final habitRepo = HabitRepository.instance;
      await habitRepo.initialize();
      for (final hid in v.linkedHabitIds) {
        // Best-effort removal; ignore if the habit id doesn't exist
        try {
          await habitRepo.removeHabit(hid);
        } catch (_) {
          // ignore
        }
      }
    }
  }

  Future<void> linkHabit(String visionId, String habitId) async {
    final i = _items.indexWhere((v) => v.id == visionId);
    if (i == -1) return;
    final v = _items[i];
    if (v.linkedHabitIds.contains(habitId)) return;
    final updated = v.copyWith(linkedHabitIds: [...v.linkedHabitIds, habitId]);
    _items[i] = updated;
    await _persist();
  }

  Future<void> unlinkHabit(String visionId, String habitId) async {
    final i = _items.indexWhere((v) => v.id == visionId);
    if (i == -1) return;
    final v = _items[i];
    final updated = v.copyWith(
      linkedHabitIds: v.linkedHabitIds.where((h) => h != habitId).toList(),
    );
    _items[i] = updated;
    await _persist();
  }

  Future<void> bringToFront(String id) async {
    final i = _items.indexWhere((v) => v.id == id);
    if (i <= 0) {
      return; // already front or not found
    }
    final v = _items.removeAt(i);
    _items.insert(0, v);
    await _persist();
  }

  Future<void> sendToBack(String id) async {
    final i = _items.indexWhere((v) => v.id == id);
    if (i == -1 || i == _items.length - 1) {
      return; // not found or already back
    }
    final v = _items.removeAt(i);
    _items.add(v);
    await _persist();
  }

  // Stepwise z-order controls
  Future<void> bringForward(String id) async {
    final i = _items.indexWhere((v) => v.id == id);
    if (i <= 0) {
      return; // not found or already at front
    }
    final tmp = _items[i - 1];
    _items[i - 1] = _items[i];
    _items[i] = tmp;
    await _persist();
  }

  Future<void> sendBackward(String id) async {
    final i = _items.indexWhere((v) => v.id == id);
    if (i == -1 || i >= _items.length - 1) {
      return; // not found or already at back
    }
    final tmp = _items[i + 1];
    _items[i + 1] = _items[i];
    _items[i] = tmp;
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      json.encode(_items.map((e) => e.toJson()).toList()),
    );
    _emit();
  }

  void _emit() => _controller.add(List.unmodifiable(_items));

  void dispose() => _controller.close();

  // --- Export helpers ---
  /// Convert an existing [Vision] instance into a portable [VisionTemplate]
  /// so it can be shared/imported elsewhere.
  ///
  /// Notes:
  /// - Habit schedules are exported as explicit `activeOffsets` when available.
  /// - startDay/endDay are derived as offsets from the vision's createdAt date.
  /// - Target policy types are preserved via `numericalTargetType`/`timerTargetType`.
  VisionTemplate exportAsTemplate(Vision v) {
    final habitRepo = HabitRepository.instance;
    // Ensure base date has only Y-M-D
    final DateTime base = DateTime(
      v.createdAt.year,
      v.createdAt.month,
      v.createdAt.day,
    );
    final habits = <VisionHabitTemplate>[];
    for (final hid in v.linkedHabitIds) {
      final h = habitRepo.findById(hid);
      if (h == null) continue;
      final DateTime hStart = _tryParseDay(h.startDate) ?? base;
      final int startDay = hStart.difference(base).inDays.clamp(0, 365);
      int? endDay;
      if (h.endDate != null && h.endDate!.isNotEmpty) {
        final DateTime? hEnd = _tryParseDay(h.endDate!);
        if (hEnd != null) {
          endDay = hEnd.difference(base).inDays;
          if (endDay < 0) {
            endDay = 0; // clamp before base
          } else if (endDay > 365) {
            endDay = 365;
          }
        }
      }
      // Map schedule to activeOffsets if present
      List<int>? activeOffsets;
      if (h.scheduledDates != null && h.scheduledDates!.isNotEmpty) {
        activeOffsets =
            h.scheduledDates!
                .map(_tryParseDay)
                .whereType<DateTime>()
                .map((d) => d.difference(base).inDays)
                .where((o) => o >= startDay && (endDay == null || o <= endDay))
                .toSet()
                .toList()
              ..sort();
        if (activeOffsets.isEmpty) activeOffsets = null;
      }
      // Icon name (best-effort reverse mapping)
      final iconName = _iconNameFromIcon(h.icon);
      // Emoji if present
      final emoji = h.emoji?.trim().isNotEmpty == true ? h.emoji : null;
      // Type and policy fields
      final typeStr = switch (h.habitType) {
        HabitType.simple => 'simple',
        HabitType.numerical => 'numerical',
        HabitType.timer => 'timer',
      };
      String? numericalPolicy;
      String? timerPolicy;
      if (h.habitType == HabitType.numerical) {
        numericalPolicy = switch (h.numericalTargetType) {
          NumericalTargetType.minimum => 'minimum',
          NumericalTargetType.exact => 'exact',
          NumericalTargetType.maximum => 'maximum',
        };
      } else if (h.habitType == HabitType.timer) {
        timerPolicy = switch (h.timerTargetType) {
          TimerTargetType.minimum => 'minimum',
          TimerTargetType.exact => 'exact',
          TimerTargetType.maximum => 'maximum',
        };
      }
      final tpl = VisionHabitTemplate(
        title: h.title,
        description: h.description.isNotEmpty ? h.description : null,
        type: typeStr,
        target: h.habitType == HabitType.simple ? null : h.targetCount,
        unit: h.habitType == HabitType.simple ? null : h.unit,
        emoji: emoji,
        iconName: iconName,
        colorValue: h.color.value,
        startDay: startDay,
        endDay: endDay,
        numericalTargetType: numericalPolicy,
        timerTargetType: timerPolicy,
        frequencyType: (activeOffsets == null) ? 'daily' : null,
        selectedWeekdays: null,
        selectedMonthDays: null,
        selectedYearDays: null,
        periodicDays: null,
        activeOffsets: activeOffsets,
      );
      habits.add(tpl);
    }
    return VisionTemplate(
      id: 'tpl_from_${v.id}_${DateTime.now().millisecondsSinceEpoch}',
      title: v.title,
      description: v.description,
      emoji: v.emoji,
      colorValue: v.colorValue,
      autoSeed: false,
      habits: List.unmodifiable(habits),
      endDate: null, // keep portable in shared template
    );
  }

  static DateTime? _tryParseDay(String iso) {
    try {
      final d = DateTime.parse(iso);
      return DateTime(d.year, d.month, d.day);
    } catch (_) {
      return null;
    }
  }

  static String _iconNameFromIcon(IconData icon) {
    // Extend as needed; default to check_circle
    if (icon.codePoint == Icons.water_drop.codePoint) return 'water_drop';
    if (icon.codePoint == Icons.fitness_center.codePoint)
      return 'fitness_center';
    if (icon.codePoint == Icons.restaurant.codePoint) return 'restaurant';
    if (icon.codePoint == Icons.school.codePoint) return 'school';
    if (icon.codePoint == Icons.groups.codePoint) return 'groups';
    if (icon.codePoint == Icons.account_balance_wallet.codePoint)
      return 'account_balance_wallet';
    if (icon.codePoint == Icons.receipt_long.codePoint) return 'receipt_long';
    if (icon.codePoint == Icons.smoke_free.codePoint) return 'smoke_free';
    if (icon.codePoint == Icons.phonelink_off.codePoint) return 'phonelink_off';
    if (icon.codePoint == Icons.notifications_off.codePoint)
      return 'notifications_off';
    if (icon.codePoint == Icons.book.codePoint) return 'book';
    if (icon.codePoint == Icons.free_breakfast.codePoint)
      return 'free_breakfast';
    if (icon.codePoint == Icons.bedtime.codePoint ||
        icon.codePoint == Icons.dark_mode.codePoint)
      return 'dark_mode';
    if (icon.codePoint == Icons.no_drinks.codePoint) return 'no_drinks';
    if (icon.codePoint == Icons.icecream.codePoint) return 'icecream';
    if (icon.codePoint == Icons.no_food.codePoint) return 'no_food';
    return 'check_circle';
  }
}
