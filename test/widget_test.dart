// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mira/main.dart';
import 'package:mira/l10n/app_localizations.dart';

void main() {
  testWidgets('Mira app loads correctly', (WidgetTester tester) async {
    // Ensure onboarding is marked completed for test run
    SharedPreferences.setMockInitialValues({'onboarding_completed': true});
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MiraApp());
    // Let splash screen (2s) run and settle into the home screen
    await tester.pump(const Duration(milliseconds: 2100));
    await tester.pumpAndSettle();

    // Verify that the navigation bar is present.
    expect(find.byType(NavigationBar), findsOneWidget);

    // Verify that the default screen title is shown in the AppBar using current l10n.
    final appBarContext = tester.element(find.byType(AppBar));
    final l10n = AppLocalizations.of(appBarContext);
    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text(l10n.dashboard),
      ),
      findsOneWidget,
    );
  });
}
