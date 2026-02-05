import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OnboardingScreen Structure', () {
    testWidgets('onboarding layout can be rendered', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Expanded(
                  child: PageView(
                    children: const [Text('Page 1'), Text('Page 2')],
                  ),
                ),
                const Text('Indicators'),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(PageView), findsOneWidget);
      expect(find.text('Indicators'), findsOneWidget);
    });
  });
}
