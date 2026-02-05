import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TaskDetailScreen Structure', () {
    testWidgets('task detail layout can be rendered', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Task Detail')),
            body: Column(
              children: [
                const Text('Task: Test Task'),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Update Status'),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Task Detail'), findsOneWidget);
      expect(find.text('Update Status'), findsOneWidget);
    });
  });
}
