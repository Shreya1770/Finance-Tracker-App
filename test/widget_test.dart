import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Smoke test widget harness', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Text('PocketPal Test'),
        ),
      ),
    );
    expect(find.text('PocketPal Test'), findsOneWidget);
  });
}
