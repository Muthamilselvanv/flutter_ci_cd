// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_ci_cd/main.dart';

void main() {
  testWidgets('Home Page displays correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the Home Page title is displayed.
    expect(find.text('Home Page'), findsOneWidget);

    // Verify that the welcome message is displayed.
    expect(find.text('Welcome to the Home Page!'), findsOneWidget);
  });
}
