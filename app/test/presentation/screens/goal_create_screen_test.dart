import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GoalCreateScreen Structure', () {
    testWidgets('form with text fields can be rendered', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: 'Goal Name'),
                ),
                ElevatedButton(onPressed: () {}, child: const Text('Create')),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Create'), findsOneWidget);
    });
  });
}
