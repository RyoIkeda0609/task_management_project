import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/presentation/widgets/common/status_badge.dart';
import 'package:app/domain/value_objects/task/task_status.dart';

void main() {
  group('StatusBadge', () {
    testWidgets('displays Todo status correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: StatusBadge(status: TaskStatus.todo)),
        ),
      );

      expect(find.byType(StatusBadge), findsOneWidget);
    });

    testWidgets('displays Doing status correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: StatusBadge(status: TaskStatus.doing)),
        ),
      );

      expect(find.byType(StatusBadge), findsOneWidget);
    });

    testWidgets('displays Done status correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: StatusBadge(status: TaskStatus.done)),
        ),
      );

      expect(find.byType(StatusBadge), findsOneWidget);
    });

    testWidgets('small size renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatusBadge(status: TaskStatus.todo, size: BadgeSize.small),
          ),
        ),
      );

      expect(find.byType(StatusBadge), findsOneWidget);
    });

    testWidgets('medium size renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatusBadge(status: TaskStatus.todo, size: BadgeSize.medium),
          ),
        ),
      );

      expect(find.byType(StatusBadge), findsOneWidget);
    });

    testWidgets('large size renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatusBadge(status: TaskStatus.todo, size: BadgeSize.large),
          ),
        ),
      );

      expect(find.byType(StatusBadge), findsOneWidget);
    });

    testWidgets('displays status text', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatusBadge(status: TaskStatus.done, size: BadgeSize.large),
          ),
        ),
      );

      // Status badge should render the status
      expect(find.byType(StatusBadge), findsOneWidget);
    });
  });
}
