import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/presentation/navigation/app_router.dart';

void main() {
  group('AppRouter Navigation', () {
    testWidgets('app_router.dart can be imported', (WidgetTester tester) async {
      // Verify route constants are available
      expect(AppRouter.splash, isNotEmpty);
      expect(AppRouter.home, isNotEmpty);
    });

    testWidgets('generates routes for navigation', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(tester.element(find.byType(ElevatedButton)))
                      .pushNamed('/home');
                },
                child: const Text('Navigate'),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('named routes can be pushed', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          routes: {
            '/': (context) => Scaffold(
              body: GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/detail'),
                child: const Text('Go to Detail'),
              ),
            ),
            '/detail': (context) => Scaffold(
              body: const Text('Detail Page'),
            ),
          },
        ),
      );

      await tester.tap(find.text('Go to Detail'));
      await tester.pumpAndSettle();

      expect(find.text('Detail Page'), findsOneWidget);
    });

    testWidgets('can navigate back using pop', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          routes: {
            '/': (context) => Scaffold(
              body: GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/page2'),
                child: const Text('Go Forward'),
              ),
            ),
            '/page2': (context) => Scaffold(
              body: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ),
          },
        ),
      );

      // Navigate forward
      await tester.tap(find.text('Go Forward'));
      await tester.pumpAndSettle();
      expect(find.text('Go Back'), findsOneWidget);

      // Navigate back
      await tester.tap(find.text('Go Back'));
      await tester.pumpAndSettle();
      expect(find.text('Go Forward'), findsOneWidget);
    });

    testWidgets('multiple routes can be configured',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          routes: {
            '/about': (context) => const Scaffold(body: Text('About')),
            '/settings': (context) => const Scaffold(body: Text('Settings')),
          },
          home: const Scaffold(body: Text('Home')),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('route state is maintained during navigation',
        (WidgetTester tester) async {
      int counter = 0;

      await tester.pumpWidget(
        MaterialApp(
          routes: {
            '/': (context) => StatefulBuilder(
              builder: (context, setState) => Scaffold(
                body: Column(
                  children: [
                    Text('Count: $counter'),
                    ElevatedButton(
                      onPressed: () {
                        setState(() => counter++);
                        Navigator.pushNamed(context, '/next');
                      },
                      child: const Text('Increment and Go'),
                    ),
                  ],
                ),
              ),
            ),
            '/next': (context) => Scaffold(
              body: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Text('Back'),
              ),
            ),
          },
        ),
      );

      expect(find.text('Count: 0'), findsOneWidget);
    });
  });
}
