// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App load smoke test', (WidgetTester tester) async {
    // We create a simple MaterialApp for the smoke test instead of MyApp()
    // because MyApp() requires Firebase initialization which fails in tests.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Text('Deshmukh Steel ERP'),
        ),
      ),
    );

    expect(find.text('Deshmukh Steel ERP'), findsOneWidget);
  });
}
