import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../finance/data/transaction_model.dart';
import '../vision/data/vision_model.dart';
import '../../l10n/app_localizations.dart';

// Metrics used to compute badge progress
enum BadgeMetric {
  totalHabitCompletions,
  activeDays,
  totalTransactions,
  totalVisions,
  level,
  xp,
}

class GamificationRepository extends ChangeNotifier {
  GamificationRepository._();
  static final GamificationRepository instance = GamificationRepository._();

  static const _storageKey = 'gamification_v1';

  bool _initialized = false;

  int _xp = 0;
  int _level = 1;
  final Set<String> _unlockedBadges = <String>{};

  // Simple aggregate stats to drive badges
  int _totalHabitCompletions = 0;
  int _totalTransactions = 0;
  int _totalVisions = 0;
  String? _lastActiveDate; // YYYY-MM-DD when a habit was completed
  int _activeDays = 0; // Count of distinct days with at least one completion

  // Anti-cheat: track last day each habit awarded XP for completion
  final Map<String, String> _awardLastDateByHabit =
      <String, String>{}; // habitId -> YYYY-MM-DD

  int get xp => _xp;
  int get level => _level;
  int get xpIntoLevel => _xp % _xpPerLevel;
  int get xpToNextLevel => _xpPerLevel - xpIntoLevel;
  int get xpPerLevel => _xpPerLevel;
  Set<String> get unlockedBadges => Set.unmodifiable(_unlockedBadges);
  int get totalHabitCompletions => _totalHabitCompletions;
  int get totalTransactions => _totalTransactions;
  int get totalVisions => _totalVisions;
  int get activeDays => _activeDays;

  static const int _xpPerLevel = 100; // every 100 xp = +1 level

  // XP gain events to drive UI animations (e.g., "+10 XP" toasts)
  final StreamController<int> _xpGainController =
      StreamController<int>.broadcast();
  Stream<int> get xpGains => _xpGainController.stream;

  Future<void> initialize() async {
    if (_initialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw != null) {
        final m = jsonDecode(raw) as Map<String, dynamic>;
        _xp = (m['xp'] as num?)?.toInt() ?? 0;
        _level = (m['level'] as num?)?.toInt() ?? _levelForXp(_xp);
        _unlockedBadges
          ..clear()
          ..addAll(((m['badges'] as List?) ?? const []).cast<String>());
        _totalHabitCompletions =
            (m['totalHabitCompletions'] as num?)?.toInt() ?? 0;
        _totalTransactions = (m['totalTransactions'] as num?)?.toInt() ?? 0;
        _totalVisions = (m['totalVisions'] as num?)?.toInt() ?? 0;
        _lastActiveDate = m['lastActiveDate'] as String?;
        _activeDays = (m['activeDays'] as num?)?.toInt() ?? 0;
        final awardMap = m['awardLastDateByHabit'];
        if (awardMap is Map) {
          _awardLastDateByHabit
            ..clear()
            ..addAll(
              awardMap.map((k, v) => MapEntry(k.toString(), v.toString())),
            );
        }
      }
    } catch (_) {
      // ignore corrupt state
    }
    _initialized = true;
    // Backfill unlocks for any badges already achieved from stored stats
    await _reconcileBadges();
    notifyListeners();
  }

  Future<void> _save() async {
    if (!_initialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final m = <String, dynamic>{
        'xp': _xp,
        'level': _level,
        'badges': _unlockedBadges.toList(),
        'totalHabitCompletions': _totalHabitCompletions,
        'totalTransactions': _totalTransactions,
        'totalVisions': _totalVisions,
        'lastActiveDate': _lastActiveDate,
        'activeDays': _activeDays,
        'awardLastDateByHabit': _awardLastDateByHabit,
      };
      await prefs.setString(_storageKey, jsonEncode(m));
    } catch (_) {
      // ignore
    }
  }

  Future<void> _ensureInited() => initialize();

  int _levelForXp(int v) => 1 + (v ~/ _xpPerLevel);

  Future<void> _addXp(int amount) async {
    await _ensureInited();
    if (amount <= 0) return;
    _xp += amount;
    _level = _levelForXp(_xp);
    await _save();
    // Emit XP gain event for UI feedback
    if (!_xpGainController.isClosed) {
      try {
        _xpGainController.add(amount);
      } catch (_) {}
    }
    // Reconcile badge unlocks after XP/Level changes
    await _reconcileBadges();
    notifyListeners();
  }

  Future<void> _unlock(String badgeId) async {
    await _ensureInited();
    if (_unlockedBadges.contains(badgeId)) return;
    _unlockedBadges.add(badgeId);
    await _save();
    notifyListeners();
  }

  // Public API to be called from other features
  Future<void> onHabitCompleted({
    required String habitId,
    required DateTime when,
  }) async {
    await _ensureInited();
    final dayKey = _dateStr(when);
    // Anti-cheat: only award XP once per habit per day
    final lastAwarded = _awardLastDateByHabit[habitId];
    final firstTimeToday = lastAwarded != dayKey;
    if (!firstTimeToday) {
      // Already awarded for this habit today; ensure active day tracking still updates if needed, but do not add XP or double-count completions
      if (_lastActiveDate != dayKey) {
        _lastActiveDate = dayKey;
        _activeDays += 1;
        await _save();
        await _reconcileBadges();
        notifyListeners();
      }
      return;
    }

    _totalHabitCompletions += 1;
    if (_lastActiveDate != dayKey) {
      _lastActiveDate = dayKey;
      _activeDays += 1;
    }
    // Record last award date for this habit
    _awardLastDateByHabit[habitId] = dayKey;
    await _addXp(
      10,
    ); // completing a habit grants 10 xp (first time for this habit today)
    // Reconcile all badge unlocks based on updated stats
    await _reconcileBadges();
  }

  Future<void> onTransactionAdded(FinanceTransaction tx) async {
    await _ensureInited();
    _totalTransactions += 1;
    await _addXp(5); // logging a transaction grants 5 xp
    await _reconcileBadges();
  }

  Future<void> onVisionCreated(Vision v) async {
    await _ensureInited();
    _totalVisions += 1;
    await _addXp(15); // creating a vision grants 15 xp
    if ((v.linkedHabitIds).length >= 3) await _unlock('vision_habits_3');
    await _reconcileBadges();
  }

  // Badge catalog to drive UI
  List<BadgeDef> allBadges(AppLocalizations l10n) => [
    // Habit completions
    BadgeDef(
      id: 'habit_10',
      title: l10n.badgeHabit10Title,
      description: l10n.badgeHabit10Desc,
      icon: Icons.task_alt,
      category: l10n.badgeCategoryHabit,
      metric: BadgeMetric.totalHabitCompletions,
      goal: 10,
    ),
    BadgeDef(
      id: 'habit_50',
      title: l10n.badgeHabit50Title,
      description: l10n.badgeHabit50Desc,
      icon: Icons.verified,
      category: l10n.badgeCategoryHabit,
      metric: BadgeMetric.totalHabitCompletions,
      goal: 50,
    ),
    BadgeDef(
      id: 'habit_100',
      title: l10n.badgeHabit100Title,
      description: l10n.badgeHabit100Desc,
      icon: Icons.workspace_premium,
      category: l10n.badgeCategoryHabit,
      metric: BadgeMetric.totalHabitCompletions,
      goal: 100,
    ),
    BadgeDef(
      id: 'habit_200',
      title: l10n.badgeHabit200Title,
      description: l10n.badgeHabit200Desc,
      icon: Icons.emoji_events,
      category: l10n.badgeCategoryHabit,
      metric: BadgeMetric.totalHabitCompletions,
      goal: 200,
    ),

    // Active days
    BadgeDef(
      id: 'active_7d',
      title: l10n.badgeActive7dTitle,
      description: l10n.badgeActive7dDesc,
      icon: Icons.local_fire_department,
      category: l10n.badgeCategoryActivity,
      metric: BadgeMetric.activeDays,
      goal: 7,
    ),
    BadgeDef(
      id: 'active_30d',
      title: l10n.badgeActive30dTitle,
      description: l10n.badgeActive30dDesc,
      icon: Icons.whatshot,
      category: l10n.badgeCategoryActivity,
      metric: BadgeMetric.activeDays,
      goal: 30,
    ),
    BadgeDef(
      id: 'active_100d',
      title: l10n.badgeActive100dTitle,
      description: l10n.badgeActive100dDesc,
      icon: Icons.local_fire_department_outlined,
      category: l10n.badgeCategoryActivity,
      metric: BadgeMetric.activeDays,
      goal: 100,
    ),

    // Finance
    BadgeDef(
      id: 'fin_10',
      title: l10n.badgeFin10Title,
      description: l10n.badgeFin10Desc,
      icon: Icons.receipt_long,
      category: l10n.badgeCategoryFinance,
      metric: BadgeMetric.totalTransactions,
      goal: 10,
    ),
    BadgeDef(
      id: 'fin_50',
      title: l10n.badgeFin50Title,
      description: l10n.badgeFin50Desc,
      icon: Icons.list_alt,
      category: l10n.badgeCategoryFinance,
      metric: BadgeMetric.totalTransactions,
      goal: 50,
    ),
    BadgeDef(
      id: 'fin_100',
      title: l10n.badgeFin100Title,
      description: l10n.badgeFin100Desc,
      icon: Icons.fact_check,
      category: l10n.badgeCategoryFinance,
      metric: BadgeMetric.totalTransactions,
      goal: 100,
    ),
    BadgeDef(
      id: 'fin_250',
      title: l10n.badgeFin250Title,
      description: l10n.badgeFin250Desc,
      icon: Icons.account_balance_wallet,
      category: l10n.badgeCategoryFinance,
      metric: BadgeMetric.totalTransactions,
      goal: 250,
    ),

    // Vision
    BadgeDef(
      id: 'vision_1',
      title: l10n.badgeVision1Title,
      description: l10n.badgeVision1Desc,
      icon: Icons.emoji_objects,
      category: l10n.badgeCategoryVision,
      metric: BadgeMetric.totalVisions,
      goal: 1,
    ),
    BadgeDef(
      id: 'vision_5',
      title: l10n.badgeVision5Title,
      description: l10n.badgeVision5Desc,
      icon: Icons.bolt,
      category: l10n.badgeCategoryVision,
      metric: BadgeMetric.totalVisions,
      goal: 5,
    ),
    BadgeDef(
      id: 'vision_10',
      title: l10n.badgeVision10Title,
      description: l10n.badgeVision10Desc,
      icon: Icons.stars,
      category: l10n.badgeCategoryVision,
      metric: BadgeMetric.totalVisions,
      goal: 10,
    ),
    BadgeDef(
      id: 'vision_habits_3',
      title: l10n.badgeVisionHabits3Title,
      description: l10n.badgeVisionHabits3Desc,
      icon: Icons.link,
      category: l10n.badgeCategoryVision,
      metric: BadgeMetric.totalVisions,
      goal: 1, // special case handled on creation
    ),

    // Level
    BadgeDef(
      id: 'level_5',
      title: l10n.badgeLevel5Title,
      description: l10n.badgeLevel5Desc,
      icon: Icons.military_tech,
      category: l10n.badgeCategoryLevel,
      metric: BadgeMetric.level,
      goal: 5,
    ),
    BadgeDef(
      id: 'level_10',
      title: l10n.badgeLevel10Title,
      description: l10n.badgeLevel10Desc,
      icon: Icons.military_tech_outlined,
      category: l10n.badgeCategoryLevel,
      metric: BadgeMetric.level,
      goal: 10,
    ),
    BadgeDef(
      id: 'level_20',
      title: l10n.badgeLevel20Title,
      description: l10n.badgeLevel20Desc,
      icon: Icons.workspace_premium_outlined,
      category: l10n.badgeCategoryLevel,
      metric: BadgeMetric.level,
      goal: 20,
    ),

    // XP
    BadgeDef(
      id: 'xp_500',
      title: l10n.badgeXp500Title,
      description: l10n.badgeXp500Desc,
      icon: Icons.trending_up,
      category: l10n.badgeCategoryXp,
      metric: BadgeMetric.xp,
      goal: 500,
    ),
    BadgeDef(
      id: 'xp_1000',
      title: l10n.badgeXp1000Title,
      description: l10n.badgeXp1000Desc,
      icon: Icons.trending_up_outlined,
      category: l10n.badgeCategoryXp,
      metric: BadgeMetric.xp,
      goal: 1000,
    ),
  ];

  // Internal, l10n-agnostic rules for unlocking badges.
  // This decouples business logic from localized UI strings.
  static const List<_BadgeRule> _badgeRules = <_BadgeRule>[
    // Habit completions
    _BadgeRule('habit_10', BadgeMetric.totalHabitCompletions, 10),
    _BadgeRule('habit_50', BadgeMetric.totalHabitCompletions, 50),
    _BadgeRule('habit_100', BadgeMetric.totalHabitCompletions, 100),
    _BadgeRule('habit_200', BadgeMetric.totalHabitCompletions, 200),

    // Active days
    _BadgeRule('active_7d', BadgeMetric.activeDays, 7),
    _BadgeRule('active_30d', BadgeMetric.activeDays, 30),
    _BadgeRule('active_100d', BadgeMetric.activeDays, 100),

    // Finance transactions
    _BadgeRule('fin_10', BadgeMetric.totalTransactions, 10),
    _BadgeRule('fin_50', BadgeMetric.totalTransactions, 50),
    _BadgeRule('fin_100', BadgeMetric.totalTransactions, 100),
    _BadgeRule('fin_250', BadgeMetric.totalTransactions, 250),

    // Vision counts
    _BadgeRule('vision_1', BadgeMetric.totalVisions, 1),
    _BadgeRule('vision_5', BadgeMetric.totalVisions, 5),
    _BadgeRule('vision_10', BadgeMetric.totalVisions, 10),
    // Note: vision_habits_3 is handled specially in onVisionCreated()

    // Levels
    _BadgeRule('level_5', BadgeMetric.level, 5),
    _BadgeRule('level_10', BadgeMetric.level, 10),
    _BadgeRule('level_20', BadgeMetric.level, 20),

    // XP totals
    _BadgeRule('xp_500', BadgeMetric.xp, 500),
    _BadgeRule('xp_1000', BadgeMetric.xp, 1000),
  ];

  static String _dateStr(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @visibleForTesting
  Future<void> debugReset() async {
    _initialized = false;
    _xp = 0;
    _level = 1;
    _unlockedBadges.clear();
    _totalHabitCompletions = 0;
    _totalTransactions = 0;
    _totalVisions = 0;
    _lastActiveDate = null;
    _activeDays = 0;
    _awardLastDateByHabit.clear();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
    } catch (_) {}
    notifyListeners();
  }

  // Call when a previously completed habit is undone on the same day
  Future<void> onHabitCompletionUndone({
    required String habitId,
    required DateTime when,
  }) async {
    await _ensureInited();
    final dayKey = _dateStr(when);
    final lastAwarded = _awardLastDateByHabit[habitId];
    if (lastAwarded == dayKey) {
      // Clear the award marker so it can be awarded again if re-completed today
      _awardLastDateByHabit.remove(habitId);
      // Adjust stats
      if (_totalHabitCompletions > 0) _totalHabitCompletions -= 1;
      // Deduct XP (do not emit negative toast)
      const amount = 10;
      _xp = _xp >= amount ? _xp - amount : 0;
      _level = _levelForXp(_xp);
      await _save();
      notifyListeners();
    }
    // If not awarded today, ignore (we don't retroactively adjust past days)
  }
}

class BadgeDef {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final String category;
  final BadgeMetric metric;
  final int goal;
  const BadgeDef({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.category,
    required this.metric,
    required this.goal,
  });
}

extension on GamificationRepository {
  int _currentValueForMetric(BadgeMetric m) {
    switch (m) {
      case BadgeMetric.totalHabitCompletions:
        return _totalHabitCompletions;
      case BadgeMetric.activeDays:
        return _activeDays;
      case BadgeMetric.totalTransactions:
        return _totalTransactions;
      case BadgeMetric.totalVisions:
        return _totalVisions;
      case BadgeMetric.level:
        return _level;
      case BadgeMetric.xp:
        return _xp;
    }
  }

  Future<void> _reconcileBadges() async {
    bool changed = false;
    for (final rule in GamificationRepository._badgeRules) {
      final current = _currentValueForMetric(rule.metric);
      if (current >= rule.goal && !_unlockedBadges.contains(rule.id)) {
        _unlockedBadges.add(rule.id);
        changed = true;
      }
    }
    if (changed) {
      await _save();
    }
  }
}

class _BadgeRule {
  final String id;
  final BadgeMetric metric;
  final int goal;
  const _BadgeRule(this.id, this.metric, this.goal);
}
