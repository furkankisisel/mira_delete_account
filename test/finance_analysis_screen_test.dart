import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mira/features/finance/finance_analysis_screen.dart';
import 'package:mira/design_system/theme/theme_variations.dart';
import 'package:mira/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FinanceAnalysisScreen', () {
    testWidgets('builds and settles without throwing', (tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('tr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: FinanceAnalysisScreen(
            month: DateTime(DateTime.now().year, DateTime.now().month, 1),
            variant: ThemeVariant.world,
          ),
        ),
      );

      // Initial frame
      await tester.pump();
      // Allow async initializations to complete
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.textContaining('Finans Analizi'), findsOneWidget);
      expect(find.text('Tasarruf / Bütçe Planı'), findsOneWidget);
    });
  });
}
