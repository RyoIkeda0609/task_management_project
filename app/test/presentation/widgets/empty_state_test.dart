import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/presentation/widgets/common/empty_state.dart';

void main() {
  group('EmptyState', () {
    testWidgets('displays icon correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              title: 'No Items',
              message: 'You have no items yet',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.inbox), findsOneWidget);
    });

    testWidgets('displays title correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              title: 'No Tasks',
              message: 'No tasks available',
            ),
          ),
        ),
      );

      expect(find.text('No Tasks'), findsOneWidget);
    });

    testWidgets('displays message correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              title: 'Empty',
              message: 'Your list is empty. Add something new!',
            ),
          ),
        ),
      );

      expect(
        find.text('Your list is empty. Add something new!'),
        findsOneWidget,
      );
    });

    testWidgets('displays action button when provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.add,
              title: 'No Goals',
              message: 'Create your first goal',
              actionText: 'Create Goal',
              onActionPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Create Goal'), findsOneWidget);
    });

    testWidgets('action button callback is triggered', (
      WidgetTester tester,
    ) async {
      bool actionPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.add,
              title: 'No Items',
              message: 'Add new item',
              actionText: 'Add',
              onActionPressed: () => actionPressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      expect(actionPressed, true);
    });

    testWidgets('does not display button when actionText is null', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              title: 'No Items',
              message: 'Empty',
            ),
          ),
        ),
      );

      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('renders all elements in correct order', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.star,
              title: 'Title Text',
              message: 'Message Text',
              actionText: 'Action',
              onActionPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.text('Title Text'), findsOneWidget);
      expect(find.text('Message Text'), findsOneWidget);
      expect(find.text('Action'), findsOneWidget);
    });
  });
}
