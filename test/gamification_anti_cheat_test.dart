import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mira/features/gamification/gamification_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await GamificationRepository.instance.debugReset();
    await GamificationRepository.instance.initialize();
  });

  test('awards XP only once per habit per day', () async {
    final repo = GamificationRepository.instance;
    final now = DateTime.now();

    await repo.onHabitCompleted(habitId: 'habitA', when: now);
    expect(repo.xp, 10);
    expect(repo.totalHabitCompletions, 1);

    // Same habit, same day -> no extra XP
    await repo.onHabitCompleted(habitId: 'habitA', when: now);
    expect(repo.xp, 10);
    expect(repo.totalHabitCompletions, 1);

    // Different habit, same day -> awards again
    await repo.onHabitCompleted(habitId: 'habitB', when: now);
    expect(repo.xp, 20);
    expect(repo.totalHabitCompletions, 2);

    // Next day, same habit -> awards again
    final tomorrow = now.add(const Duration(days: 1));
    await repo.onHabitCompleted(habitId: 'habitA', when: tomorrow);
    expect(repo.xp, 30);
    expect(repo.totalHabitCompletions, 3);
  });

  test('deducts XP on same-day undo and allows re-award', () async {
    final repo = GamificationRepository.instance;
    final now = DateTime.now();

    await repo.onHabitCompleted(habitId: 'habitC', when: now);
    expect(repo.xp, 10);
    expect(repo.totalHabitCompletions, 1);

    // Undo
    await repo.onHabitCompletionUndone(habitId: 'habitC', when: now);
    expect(repo.xp, 0);
    expect(repo.totalHabitCompletions, 0);

    // Re-complete same day -> award again
    await repo.onHabitCompleted(habitId: 'habitC', when: now);
    expect(repo.xp, 10);
    expect(repo.totalHabitCompletions, 1);
  });
}
