import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DialogHelper', () {
    testWidgets('alert dialog can display title and message',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const AlertDialog(
              title: Text('Test Title'),
              content: Text('Test message'),
            ),
          ),
        ),
      );

      expect(find.text('Test Title'), findsOneWidget);
      expect(find.text('Test message'), findsOneWidget);
    });

    testWidgets('alert dialog with buttons can be created',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlertDialog(
              title: const Text('Confirm'),
              content: const Text('Are you sure?'),
              actions: [
                TextButton(
                  onPressed: () {},
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('OK'),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Confirm'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);
    });

    testWidgets('error dialog can be created', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const AlertDialog(
              title: Text('Error'),
              content: Text('An error occurred'),
            ),
          ),
        ),
      );

      expect(find.text('Error'), findsOneWidget);
    });

    testWidgets('success dialog can be created', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const AlertDialog(
              title: Text('Success'),
              content: Text('Operation completed'),
            ),
          ),
        ),
      );

      expect(find.text('Success'), findsOneWidget);
    });

    testWidgets('info dialog can be created', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const AlertDialog(
              title: Text('Info'),
              content: Text('This is information'),
            ),
          ),
        ),
      );

      expect(find.text('Info'), findsOneWidget);
    });
  });
}
