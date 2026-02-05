import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/presentation/widgets/common/progress_indicator.dart' as app_progress;

void main() {
  group('ProgressIndicator', () {
    testWidgets('displays progress bar correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: app_progress.ProgressIndicator(
              percentage: 50,
            ),
          ),
        ),
      );

      expect(find.byType(app_progress.ProgressIndicator), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('displays 0% progress', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: app_progress.ProgressIndicator(
              percentage: 0.0,
            ),
          ),
        ),
      );

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('displays 50% progress', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: app_progress.ProgressIndicator(
              percentage: 50,
            ),
          ),
        ),
      );

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('displays 100% progress', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: app_progress.ProgressIndicator(
              percentage: 100,
            ),
          ),
        ),
      );

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('displays label when showLabel is true',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: app_progress.ProgressIndicator(
              percentage: 75,
              showLabel: true,
            ),
          ),
        ),
      );

      expect(find.text('75%'), findsOneWidget);
    });

    testWidgets('does not display label when showLabel is false',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: app_progress.ProgressIndicator(
              percentage: 75,
              showLabel: false,
            ),
          ),
        ),
      );

      expect(find.text('75%'), findsNothing);
    });

    testWidgets('updates progress value correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: app_progress.ProgressIndicator(
              percentage: 30,
              showLabel: true,
            ),
          ),
        ),
      );

      expect(find.text('30%'), findsOneWidget);
    });

    testWidgets('handles progress greater than 100',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: app_progress.ProgressIndicator(
              percentage: 150,
            ),
          ),
        ),
      );

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('handles negative progress value', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: app_progress.ProgressIndicator(
              percentage: -50,
            ),
          ),
        ),
      );

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });
  });
}
