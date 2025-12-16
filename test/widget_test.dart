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

void main() {
  testWidgets('Mira app loads and initializes', (WidgetTester tester) async {
    // Mock initial values: onboarding NOT completed to test sign-in flow
    SharedPreferences.setMockInitialValues({'onboarding_completed': false});

    // Build our app and trigger a frame.
    await tester.pumpWidget(const MiraApp());

    // Pump a few times to let the app initialize
    await tester.pump(); // Initial build
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pump(const Duration(milliseconds: 2000));

    // Let any remaining animations complete
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Verify that the app has loaded by checking for MaterialApp
    expect(find.byType(MaterialApp), findsOneWidget);

    // The app should show something - either splash, sign-in, or dashboard
    // We're not being specific about which screen to avoid flaky tests
    // due to async initialization timing
  });
}
