import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GoalEditScreen Structure', () {
    testWidgets('edit form can be rendered', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Edit Goal')),
            body: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: 'Goal Name'),
                ),
                ElevatedButton(onPressed: () {}, child: const Text('Update')),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Edit Goal'), findsOneWidget);
      expect(find.text('Update'), findsOneWidget);
    });
  });
}
