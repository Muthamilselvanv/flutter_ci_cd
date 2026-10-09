// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_ci_cd/main.dart';

void main() {
  testWidgets('default environment is displayed', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    expect(find.text('Flutter_CI/CD'), findsOneWidget);
    expect(find.text('Environment: development'), findsOneWidget);
    expect(
      find.text('API: https://gulftest.traitsolutions.in/RestApi/app_api'),
      findsOneWidget,
    );
    expect(
      find.text('Web: https://gulftest.traitsolutions.in/RestApi/web_api/'),
      findsOneWidget,
    );
  });
}
