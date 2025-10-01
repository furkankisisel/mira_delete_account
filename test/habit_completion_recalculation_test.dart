import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:mira/features/habit/domain/habit_model.dart';
import 'package:mira/features/habit/domain/habit_repository.dart';
import 'package:mira/features/habit/domain/habit_types.dart';

void main() {
  group('Habit completion recalculation', () {
    test('minimum numerical requires reaching target and unsets when lowered', () {
      final today = DateTime.now();
      final habit = Habit(
        id: 't1',
        title: 'Kitap',
        description: 'Okuma',
        icon: Icons.menu_book,
        color: Colors.black,
        targetCount: 30,
        habitType: HabitType.numerical,
        unit: 'sayfa',
        currentStreak: 0,
        isCompleted: false,
        progressDate:
            '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}',
        startDate:
            '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}',
      );

      // Progress below target should not be completed
      habit.currentStreak = 20;
      expect(
        HabitRepository.evaluateCompletionForProgress(
          habit,
          habit.currentStreak,
        ),
        isFalse,
      );

      // Reach target
      habit.currentStreak = 30;
      expect(
        HabitRepository.evaluateCompletionForProgress(
          habit,
          habit.currentStreak,
        ),
        isTrue,
      );

      // Lower target via editing (simulate user lowering targetCount to 25 -> still completed)
      habit.targetCount = 25;
      expect(
        HabitRepository.evaluateCompletionForProgress(
          habit,
          habit.currentStreak,
        ),
        isTrue,
      );

      // User edits entered progress downward below new target -> should become not completed
      habit.currentStreak = 20; // now < target 25
      expect(
        HabitRepository.evaluateCompletionForProgress(
          habit,
          habit.currentStreak,
        ),
        isFalse,
      );
    });

    test('timer minimum requires reaching target', () {
      final today = DateTime.now();
      final habit = Habit(
        id: 't2',
        title: 'Meditasyon',
        description: 'Meditasyon',
        icon: Icons.self_improvement,
        color: Colors.black,
        targetCount: 10,
        habitType: HabitType.timer,
        unit: 'dakika',
        currentStreak: 0,
        isCompleted: false,
        progressDate:
            '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}',
        startDate:
            '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}',
      );

      expect(HabitRepository.evaluateCompletionForProgress(habit, 0), isFalse);
      expect(HabitRepository.evaluateCompletionForProgress(habit, 5), isFalse);
      expect(HabitRepository.evaluateCompletionForProgress(habit, 10), isTrue);
    });
  });
}
