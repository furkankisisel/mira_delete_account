import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mira/features/mood/data/mood_models.dart';
import 'package:mira/features/mood/data/detailed_mood_repository.dart';

void main() {
  setUp(() async {
    // Ensure a clean in-memory store for each test
    SharedPreferences.setMockInitialValues({});
  });

  group('DetailedMoodRepository', () {
    test('save and load mood entries preserves newest-first order', () async {
      final repo = DetailedMoodRepository();

      final older = MoodEntry(
        id: '1',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        mood: MoodLevel.good,
        subEmotion: SubEmotion.motivated,
        reason: ReasonCategory.work,
        journalText: 'Wrapped up a feature.',
      );

      final newer = MoodEntry(
        id: '2',
        timestamp: DateTime.now(),
        mood: MoodLevel.neutral,
        subEmotion: SubEmotion.ordinary,
        reason: ReasonCategory.other,
        journalText: 'Just another day.',
      );

      await repo.saveMoodEntry(older);
      await repo.saveMoodEntry(newer);

      final all = await repo.getAllMoodEntries();
      expect(all.length, 2);
      expect(all.first.id, newer.id, reason: 'Newest entry should come first');
      expect(all.last.id, older.id, reason: 'Older entry should come last');
    });

    test('getMoodStatistics returns counts and averages', () async {
      final repo = DetailedMoodRepository();

      final now = DateTime.now();
      final entries = [
        MoodEntry(
          id: 'a',
          timestamp: now.subtract(const Duration(days: 1)),
          mood: MoodLevel.bad,
          subEmotion: SubEmotion.sad,
          reason: ReasonCategory.relationship,
          journalText: 'Felt a bit down.',
        ),
        MoodEntry(
          id: 'b',
          timestamp: now,
          mood: MoodLevel.good,
          subEmotion: SubEmotion.happy,
          reason: ReasonCategory.work,
          journalText: 'Good progress at work.',
        ),
        MoodEntry(
          id: 'c',
          timestamp: now,
          mood: MoodLevel.good,
          subEmotion: SubEmotion.motivated,
          reason: ReasonCategory.personalGrowth,
          journalText: 'Gym and reading.',
        ),
      ];

      for (final e in entries) {
        await repo.saveMoodEntry(e);
      }

      final stats = await repo.getMoodStatistics(
        startDate: now.subtract(const Duration(days: 7)),
        endDate: now.add(const Duration(days: 1)),
      );

      expect(stats.totalEntries, entries.length);
      expect(stats.averageMoodScore, greaterThan(0));
      expect(stats.mostCommonMood, MoodLevel.good);
      expect(stats.moodDistribution[MoodLevel.good], 2);
    });
  });
}
