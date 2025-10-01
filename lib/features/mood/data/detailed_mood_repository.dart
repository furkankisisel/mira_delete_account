import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'mood_models.dart';

class DetailedMoodRepository {
  static const String _moodEntriesKey = 'detailed_mood_entries_v1';
  static const String _moodStatsKey = 'detailed_mood_stats_v1';
  static const int _maxStoredEntries = 100;

  /// Save a new mood entry
  Future<void> saveMoodEntry(MoodEntry entry) async {
    final prefs = await SharedPreferences.getInstance();

    // Get existing entries
    final existingEntries = await getAllMoodEntries();

    // Add new entry at the beginning
    existingEntries.insert(0, entry);

    // Keep only the most recent entries
    final entriesToSave = existingEntries.take(_maxStoredEntries).toList();

    // Convert to JSON strings
    final jsonStrings = entriesToSave
        .map((e) => jsonEncode(e.toJson()))
        .toList();

    // Save to SharedPreferences
    await prefs.setStringList(_moodEntriesKey, jsonStrings);

    // Update statistics
    await _updateMoodStats(entry);
  }

  /// Get all mood entries, ordered by timestamp (newest first)
  Future<List<MoodEntry>> getAllMoodEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStrings = prefs.getStringList(_moodEntriesKey) ?? [];

    return jsonStrings
        .map((jsonString) {
          try {
            final json = jsonDecode(jsonString) as Map<String, dynamic>;
            return MoodEntry.fromJson(json);
          } catch (e) {
            // Skip invalid entries
            return null;
          }
        })
        .whereType<MoodEntry>()
        .toList();
  }

  /// Get mood entries for a specific date
  Future<List<MoodEntry>> getMoodEntriesForDate(DateTime date) async {
    final allEntries = await getAllMoodEntries();

    return allEntries.where((entry) {
      return entry.timestamp.year == date.year &&
          entry.timestamp.month == date.month &&
          entry.timestamp.day == date.day;
    }).toList();
  }

  /// Get mood entries for a date range
  Future<List<MoodEntry>> getMoodEntriesForRange(
    DateTime start,
    DateTime end,
  ) async {
    final allEntries = await getAllMoodEntries();

    return allEntries.where((entry) {
      return entry.timestamp.isAfter(start) &&
          entry.timestamp.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  /// Get the most recent mood entry
  Future<MoodEntry?> getLatestMoodEntry() async {
    final entries = await getAllMoodEntries();
    return entries.isNotEmpty ? entries.first : null;
  }

  /// Delete a mood entry by ID
  Future<void> deleteMoodEntry(String entryId) async {
    final prefs = await SharedPreferences.getInstance();
    final allEntries = await getAllMoodEntries();

    // Remove the entry with the specified ID
    final updatedEntries = allEntries
        .where((entry) => entry.id != entryId)
        .toList();

    // Save back to storage
    final jsonStrings = updatedEntries
        .map((e) => jsonEncode(e.toJson()))
        .toList();
    await prefs.setStringList(_moodEntriesKey, jsonStrings);
  }

  /// Update an existing mood entry
  Future<void> updateMoodEntry(MoodEntry updatedEntry) async {
    final prefs = await SharedPreferences.getInstance();
    final allEntries = await getAllMoodEntries();

    // Find and replace the entry
    final entryIndex = allEntries.indexWhere(
      (entry) => entry.id == updatedEntry.id,
    );
    if (entryIndex != -1) {
      allEntries[entryIndex] = updatedEntry;

      // Save back to storage
      final jsonStrings = allEntries
          .map((e) => jsonEncode(e.toJson()))
          .toList();
      await prefs.setStringList(_moodEntriesKey, jsonStrings);
    }
  }

  /// Get mood statistics for analysis
  Future<MoodStatistics> getMoodStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final now = DateTime.now();
    final start = startDate ?? now.subtract(const Duration(days: 30));
    final end = endDate ?? now;

    final entries = await getMoodEntriesForRange(start, end);

    if (entries.isEmpty) {
      return MoodStatistics.empty();
    }

    // Calculate mood distribution
    final moodCounts = <MoodLevel, int>{};
    final subEmotionCounts = <SubEmotion, int>{};
    final reasonCounts = <ReasonCategory, int>{};

    for (final entry in entries) {
      moodCounts[entry.mood] = (moodCounts[entry.mood] ?? 0) + 1;
      subEmotionCounts[entry.subEmotion] =
          (subEmotionCounts[entry.subEmotion] ?? 0) + 1;
      reasonCounts[entry.reason] = (reasonCounts[entry.reason] ?? 0) + 1;
    }

    // Calculate average mood (terrible=1, bad=2, neutral=3, good=4, excellent=5)
    final totalMoodScore = entries.fold<int>(0, (sum, entry) {
      return sum + (entry.mood.index + 1);
    });
    final averageMoodScore = totalMoodScore / entries.length;

    // Find most common mood, sub-emotion, and reason
    final mostCommonMood = moodCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    final mostCommonSubEmotion = subEmotionCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    final mostCommonReason = reasonCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    return MoodStatistics(
      totalEntries: entries.length,
      averageMoodScore: averageMoodScore,
      mostCommonMood: mostCommonMood,
      mostCommonSubEmotion: mostCommonSubEmotion,
      mostCommonReason: mostCommonReason,
      moodDistribution: moodCounts,
      subEmotionDistribution: subEmotionCounts,
      reasonDistribution: reasonCounts,
      dateRange: DateTimeRange(start: start, end: end),
    );
  }

  /// Get mood trend over time (daily averages)
  Future<List<DailyMoodData>> getDailyMoodTrend({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final now = DateTime.now();
    final start = startDate ?? now.subtract(const Duration(days: 30));
    final end = endDate ?? now;

    final entries = await getMoodEntriesForRange(start, end);

    // Group entries by date
    final dailyEntries = <DateTime, List<MoodEntry>>{};

    for (final entry in entries) {
      final dateKey = DateTime(
        entry.timestamp.year,
        entry.timestamp.month,
        entry.timestamp.day,
      );

      dailyEntries.putIfAbsent(dateKey, () => []).add(entry);
    }

    // Calculate daily averages
    final dailyData = <DailyMoodData>[];

    for (final mapEntry in dailyEntries.entries) {
      final date = mapEntry.key;
      final dayEntries = mapEntry.value;

      final totalMoodScore = dayEntries.fold<int>(0, (sum, entry) {
        return sum + (entry.mood.index + 1);
      });

      final averageMoodScore = totalMoodScore / dayEntries.length;

      dailyData.add(
        DailyMoodData(
          date: date,
          averageMoodScore: averageMoodScore,
          entryCount: dayEntries.length,
        ),
      );
    }

    // Sort by date
    dailyData.sort((a, b) => a.date.compareTo(b.date));

    return dailyData;
  }

  /// Clear all mood data
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_moodEntriesKey);
    await prefs.remove(_moodStatsKey);
  }

  /// Export mood data as JSON
  Future<String> exportData() async {
    final entries = await getAllMoodEntries();
    final statistics = await getMoodStatistics();

    final exportData = {
      'version': '1.0',
      'exportDate': DateTime.now().toIso8601String(),
      'entries': entries.map((e) => e.toJson()).toList(),
      'statistics': statistics.toJson(),
    };

    return jsonEncode(exportData);
  }

  /// Import mood data from JSON
  Future<bool> importData(String jsonData) async {
    try {
      final data = jsonDecode(jsonData) as Map<String, dynamic>;
      final entriesJson = data['entries'] as List<dynamic>;

      final entries = entriesJson
          .map(
            (entryJson) =>
                MoodEntry.fromJson(entryJson as Map<String, dynamic>),
          )
          .toList();

      // Clear existing data
      await clearAllData();

      // Save imported entries
      for (final entry in entries) {
        await saveMoodEntry(entry);
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Update internal mood statistics
  Future<void> _updateMoodStats(MoodEntry entry) async {
    final prefs = await SharedPreferences.getInstance();

    // For now, we'll keep this simple
    // In the future, we could store more detailed analytics
    final stats = {
      'lastEntryDate': entry.timestamp.toIso8601String(),
      'totalEntries': await _getTotalEntryCount(),
    };

    await prefs.setString(_moodStatsKey, jsonEncode(stats));
  }

  /// Get total entry count
  Future<int> _getTotalEntryCount() async {
    final entries = await getAllMoodEntries();
    return entries.length;
  }
}

/// Data class for mood statistics
class MoodStatistics {
  final int totalEntries;
  final double averageMoodScore;
  final MoodLevel mostCommonMood;
  final SubEmotion mostCommonSubEmotion;
  final ReasonCategory mostCommonReason;
  final Map<MoodLevel, int> moodDistribution;
  final Map<SubEmotion, int> subEmotionDistribution;
  final Map<ReasonCategory, int> reasonDistribution;
  final DateTimeRange dateRange;

  const MoodStatistics({
    required this.totalEntries,
    required this.averageMoodScore,
    required this.mostCommonMood,
    required this.mostCommonSubEmotion,
    required this.mostCommonReason,
    required this.moodDistribution,
    required this.subEmotionDistribution,
    required this.reasonDistribution,
    required this.dateRange,
  });

  factory MoodStatistics.empty() {
    return MoodStatistics(
      totalEntries: 0,
      averageMoodScore: 0.0,
      mostCommonMood: MoodLevel.neutral,
      mostCommonSubEmotion: SubEmotion.ordinary,
      mostCommonReason: ReasonCategory.other,
      moodDistribution: {},
      subEmotionDistribution: {},
      reasonDistribution: {},
      dateRange: DateTimeRange(
        start: DateTime.now().subtract(const Duration(days: 30)),
        end: DateTime.now(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalEntries': totalEntries,
      'averageMoodScore': averageMoodScore,
      'mostCommonMood': mostCommonMood.name,
      'mostCommonSubEmotion': mostCommonSubEmotion.name,
      'mostCommonReason': mostCommonReason.name,
      'moodDistribution': moodDistribution.map((k, v) => MapEntry(k.name, v)),
      'subEmotionDistribution': subEmotionDistribution.map(
        (k, v) => MapEntry(k.name, v),
      ),
      'reasonDistribution': reasonDistribution.map(
        (k, v) => MapEntry(k.name, v),
      ),
      'dateRange': {
        'start': dateRange.start.toIso8601String(),
        'end': dateRange.end.toIso8601String(),
      },
    };
  }
}

/// Data class for daily mood tracking
class DailyMoodData {
  final DateTime date;
  final double averageMoodScore;
  final int entryCount;

  const DailyMoodData({
    required this.date,
    required this.averageMoodScore,
    required this.entryCount,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'averageMoodScore': averageMoodScore,
      'entryCount': entryCount,
    };
  }

  factory DailyMoodData.fromJson(Map<String, dynamic> json) {
    return DailyMoodData(
      date: DateTime.parse(json['date'] as String),
      averageMoodScore: (json['averageMoodScore'] as num).toDouble(),
      entryCount: json['entryCount'] as int,
    );
  }
}

/// Helper class for date ranges
class DateTimeRange {
  final DateTime start;
  final DateTime end;

  const DateTimeRange({required this.start, required this.end});

  Duration get duration => end.difference(start);

  bool contains(DateTime date) {
    return date.isAfter(start) && date.isBefore(end);
  }
}
