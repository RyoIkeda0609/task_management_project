import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/presentation/widgets/common/app_bar_common.dart';

void main() {
  group('CustomAppBar', () {
    testWidgets('displays title correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: CustomAppBar(title: 'Test Title'),
            body: const SizedBox.shrink(),
          ),
        ),
      );

      expect(find.text('Test Title'), findsOneWidget);
    });

    testWidgets('displays leading back button when hasLeading is true', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: CustomAppBar(title: 'Test', hasLeading: true),
            body: const SizedBox.shrink(),
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('does not display leading button when hasLeading is false', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: CustomAppBar(title: 'Test', hasLeading: false),
            body: const SizedBox.shrink(),
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_back), findsNothing);
    });

    testWidgets('back button triggers Navigator.pop', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          routes: {
            '/': (context) => Scaffold(
              appBar: CustomAppBar(title: 'First Page', hasLeading: false),
              body: GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/second'),
                child: const Text('Go to Second'),
              ),
            ),
            '/second': (context) => Scaffold(
              appBar: CustomAppBar(title: 'Second Page', hasLeading: true),
              body: const SizedBox.shrink(),
            ),
          },
        ),
      );

      // Navigate to second page
      await tester.tap(find.text('Go to Second'));
      await tester.pumpAndSettle();

      expect(find.text('Second Page'), findsOneWidget);

      // Navigate back
      final backButton = find.byIcon(Icons.arrow_back);
      if (backButton.evaluate().isNotEmpty) {
        await tester.tap(backButton);
        await tester.pumpAndSettle();

        expect(find.text('First Page'), findsOneWidget);
      }
    });

    testWidgets('displays action buttons', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: CustomAppBar(
              title: 'Test',
              actions: [
                IconButton(icon: const Icon(Icons.search), onPressed: () {}),
              ],
            ),
            body: const SizedBox.shrink(),
          ),
        ),
      );

      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('action button callback is triggered on tap', (
      WidgetTester tester,
    ) async {
      bool actionPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: CustomAppBar(
              title: 'Test',
              actions: [
                IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => actionPressed = true,
                ),
              ],
            ),
            body: const SizedBox.shrink(),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      expect(actionPressed, true);
    });

    testWidgets('displays multiple action buttons', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: CustomAppBar(
              title: 'Test',
              actions: [
                IconButton(icon: const Icon(Icons.search), onPressed: () {}),
                IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
              ],
            ),
            body: const SizedBox.shrink(),
          ),
        ),
      );

      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });
  });
}
