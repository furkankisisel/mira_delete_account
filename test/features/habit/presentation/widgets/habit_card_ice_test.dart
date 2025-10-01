import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mira/features/habit/presentation/widgets/habit_card.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );

  testWidgets('No ice: single tap triggers onTap immediately', (tester) async {
    int calls = 0;
    await tester.pumpWidget(
      wrap(
        HabitCard(
          title: 'NoIce',
          description: 'desc',
          icon: Icons.check_circle,
          color: Colors.blue,
          currentStreak: 0,
          targetCount: 1,
          isCompleted: false,
          onTap: () => calls++,
          // default: iceEnabled=false, requiredBreakTaps=0
        ),
      ),
    );

    await tester.tap(find.text('NoIce'));
    await tester.pump();

    expect(calls, 1);
    // No snowflake indicator
    expect(find.byIcon(Icons.ac_unit), findsNothing);
    // No flame emoji when streak is zero
    expect(find.byKey(const ValueKey('streak-flame-emoji')), findsNothing);
  });

  testWidgets('Ice requires N taps before onTap fires', (tester) async {
    int calls = 0;
    await tester.pumpWidget(
      wrap(
        HabitCard(
          title: 'IceN',
          description: 'desc',
          icon: Icons.check_circle,
          color: Colors.blue,
          currentStreak: 0,
          targetCount: 1,
          isCompleted: false,
          iceEnabled: true,
          requiredBreakTaps: 3,
          onTap: () => calls++,
        ),
      ),
    );

    // Initially, the ice indicator should be visible
    expect(find.byIcon(Icons.ac_unit), findsOneWidget);
    expect(find.text('3'), findsOneWidget);

    await tester.tap(find.text('IceN'));
    await tester.pump();
    expect(calls, 0);
    // Remaining should now be 2
    expect(find.text('2'), findsOneWidget);

    await tester.tap(find.text('IceN'));
    await tester.pump();
    expect(calls, 0);
    // Remaining should now be 1
    expect(find.text('1'), findsOneWidget);

    await tester.tap(find.text('IceN'));
    await tester.pump();
    // Now onTap should have fired
    expect(calls, 1);
  });

  testWidgets('Completed day ignores ice (no overlay, onTap fires)', (
    tester,
  ) async {
    int calls = 0;
    await tester.pumpWidget(
      wrap(
        HabitCard(
          title: 'Done',
          description: 'desc',
          icon: Icons.check_circle,
          color: Colors.green,
          currentStreak: 1,
          targetCount: 1,
          isCompleted: true, // completed
          iceEnabled: true,
          requiredBreakTaps: 5,
          onTap: () => calls++,
        ),
      ),
    );

    // No snowflake indicator when done
    expect(find.byIcon(Icons.ac_unit), findsNothing);

    await tester.tap(find.text('Done'));
    await tester.pump();

    expect(calls, 1);
    // Flame emoji should be visible if streak > 0, even if completed
    expect(find.byKey(const ValueKey('streak-flame-emoji')), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('Flame badge shows when currentStreak > 0', (tester) async {
    await tester.pumpWidget(
      wrap(
        HabitCard(
          title: 'Streak',
          description: 'desc',
          icon: Icons.local_fire_department_rounded,
          color: Colors.orange,
          currentStreak: 5,
          targetCount: 1,
          isCompleted: false,
          onTap: () {},
        ),
      ),
    );

    // Emoji and count
    expect(find.byKey(const ValueKey('streak-flame-emoji')), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
  });
}
