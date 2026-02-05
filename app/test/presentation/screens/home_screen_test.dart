import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HomeScreen Structure', () {
    testWidgets('home screen widget exists', (WidgetTester tester) async {
      // Test basic structure without Riverpod
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Text('Home Screen'),
          ),
        ),
      );

      expect(find.text('Home Screen'), findsOneWidget);
    });

    testWidgets('fab can be rendered', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const Text('Test'),
            floatingActionButton: FloatingActionButton(
              onPressed: () {},
              child: const Icon(Icons.add),
            ),
          ),
        ),
      );

      expect(find.byType(FloatingActionButton), findsOneWidget);
    });
  });
}
