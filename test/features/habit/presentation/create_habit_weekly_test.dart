import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mira/features/habit/presentation/create_habit_screen.dart';
import 'package:mira/l10n/app_localizations.dart';

void main() {
  testWidgets('Weekly frequency config generates correct scheduledDates', (
    tester,
  ) async {
    final results = <Map<String, dynamic>>[];

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('tr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () async {
                  final res = await Navigator.of(context)
                      .push<Map<String, dynamic>>(
                        MaterialPageRoute(
                          builder: (_) => const CreateHabitScreen(),
                        ),
                      );
                  if (res != null) results.add(res);
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );

    // Open the create habit screen
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    // Fill required title field
    final titleField = find.widgetWithText(TextFormField, 'Alışkanlık Adı');
    expect(titleField, findsOneWidget);
    await tester.enterText(titleField, 'Test Weekly Habit');

    // Open frequency dialog by tapping the Sıklık summary tile
    final freqTile = find.widgetWithText(ListTile, 'Sıklık');
    expect(freqTile, findsOneWidget);
    await tester.tap(freqTile);
    await tester.pumpAndSettle();

    // Select weekly option
    await tester.tap(find.text('Haftalık'));
    await tester.pump();

    // Pick specific weekdays: Monday (Pzt) and Wednesday (Çar)
    await tester.tap(find.widgetWithText(FilterChip, 'Pzt'));
    await tester.tap(find.widgetWithText(FilterChip, 'Çar'));
    await tester.pump();

    // Apply frequency selection
    await tester.tap(find.widgetWithText(FilledButton, 'Uygula'));
    await tester.pumpAndSettle();

    // Submit: scroll until the localized 'Oluştur' button is visible and tap
    final submitButton = find.widgetWithText(FilledButton, 'Oluştur');
    await tester.scrollUntilVisible(
      submitButton,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(submitButton, warnIfMissed: false);
    await tester.pumpAndSettle();

    // Validate result captured from Navigator.pop
    expect(results, isNotEmpty);
    final res = results.first;

    expect(res['frequency'], 'weekly');
    expect(
      res['frequencyType'].toString().toLowerCase(),
      contains('specificweekdays'),
    );
    // Mon=1, Wed=3
    expect(res['selectedWeekdays'], [1, 3]);

    // scheduledDates should be a non-empty List<String>
    final dates = (res['scheduledDates'] as List).cast<String>();
    expect(dates, isNotEmpty);

    // All scheduled dates must fall on Monday or Wednesday
    bool _isMonOrWed(String ymd) {
      final parts = ymd.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);
      final d = DateTime(year, month, day);
      return d.weekday == DateTime.monday || d.weekday == DateTime.wednesday;
    }

    expect(dates.every(_isMonOrWed), isTrue);

    // Dates should be unique and sorted ascending
    final sorted = [...dates]..sort();
    expect(dates, sorted);
    expect(dates.toSet().length, dates.length);
  });
}
